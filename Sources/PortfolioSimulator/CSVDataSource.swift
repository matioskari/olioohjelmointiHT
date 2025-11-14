import Foundation

public final class CSVDataSource: MarketDataSource {
    private let filePath: String
    private let instrument: Instrument
    private var companyName: String?

    public init(filePath: String, instrument: Instrument) {
        self.filePath = filePath
        self.instrument = instrument
    }
    
    public func getCompanyName() -> String? {
        // If already parsed, return cached value
        if let c = companyName { return c }

        // Try to read only the first lines to extract the company name without parsing all candles.
        guard let raw = try? String(contentsOfFile: filePath, encoding: .utf8) else { return nil }
        let normalized = raw
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
        let lines = normalized
            .split(separator: "\n")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
        guard !lines.isEmpty else { return nil }

        let firstLine = lines[0]
        if firstLine.lowercased().contains("company") {
            let companyFields = firstLine.split(separator: ",").map(String.init)
            if companyFields.count >= 2 {
                var name = companyFields[1].trimmingCharacters(in: .whitespacesAndNewlines)
                if name.hasPrefix("\"") && name.hasSuffix("\"") && name.count >= 2 {
                    name.removeFirst()
                    name.removeLast()
                }
                self.companyName = name
                return name
            }
        }
        return nil
    }

    public func load() -> [Candle] {
        print("📄 CSVDataSource: trying to read file at \(filePath)")

        // 1) Lue tiedosto UTF-8:na
        guard let raw = try? String(contentsOfFile: filePath, encoding: .utf8) else {
            print("❌ CSVDataSource: unable to read file at \(filePath)")
            return []
        }

        // 2) Normalisoi rivinvaihdot -> \n
        let normalized = raw
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")

        // 3) Splittaa riveihin ja poista tyhjät rivit reunoista
        var lines = normalized
            .split(separator: "\n")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }

        guard lines.count > 2 else {
            print("⚠️ CSVDataSource: file is empty or contains no data rows.")
            return []
        }

        // Check for company name in the first line
        let firstLine = lines[0]
        if firstLine.lowercased().contains("company") {
            let companyFields = firstLine.split(separator: ",").map(String.init)
            if companyFields.count >= 2 {
                self.companyName = unquote(String(companyFields[1]))
                lines.removeFirst() // Remove company name line
            }
        }
        
        guard lines.count > 1 else {
            print("⚠️ CSVDataSource: file contains no data rows after company name.")
            return []
        }

        // 4) Päättele erotin: jos headerissa on ';', käytetään sitä, muuten ','
        let delimiter: Character = lines[0].contains(";") ? ";" : ","
        print("✅ CSVDataSource: using delimiter '\(delimiter)'")

        // 5) Parsitaan header ja etsitään sarakeindeksit
        let rawHeader = lines.removeFirst()
        let headerCols = splitCSV(rawHeader, delimiter: delimiter)
            .map { unquote($0).trimmingCharacters(in: .whitespaces) }

        func findColumnIndex(_ headers: [String], names: [String]) -> Int? {
            let lowered = headers.map { $0.lowercased() }
            let targets = names.map { $0.lowercased() }
            for (i, h) in lowered.enumerated() {
                if targets.contains(h) { return i }
            }
            return nil
        }

        guard let dateIdx   = findColumnIndex(headerCols, names: ["date","time","timestamp","päivä","paiva"])
        else { print("❌ CSVDataSource: no date column found in header: \(headerCols)"); return [] }
        guard let openIdx   = findColumnIndex(headerCols, names: ["open","avaus"])
        else { print("❌ CSVDataSource: no open column"); return [] }
        guard let highIdx   = findColumnIndex(headerCols, names: ["high","korkein"])
        else { print("❌ CSVDataSource: no high column"); return [] }
        guard let lowIdx    = findColumnIndex(headerCols, names: ["low","matalin","matala"])
        else { print("❌ CSVDataSource: no low column"); return [] }
        // Huom: hyväksytään myös "Adj Close" jos pelkkää "Close" ei ole
        let closeIdx: Int
        if let idx = findColumnIndex(headerCols, names: ["close","päätös","paatos"]) {
            closeIdx = idx
        } else if let idx = findColumnIndex(headerCols, names: ["adj close","adjclose"]) {
            closeIdx = idx
        } else {
            print("❌ CSVDataSource: no close/adj close column")
            return []
        }
        let volumeIdx = findColumnIndex(headerCols, names: ["volume","volyymi"])

        // 6) Apufunktiot: päivämäärä & numerot
        // Robust CSV field cleanup: trims whitespace and surrounding quotes
        func unquote(_ s: String) -> String {
            var t = s.trimmingCharacters(in: .whitespacesAndNewlines)
            if t.hasPrefix("\"") && t.hasSuffix("\"") && t.count >= 2 {
                t.removeFirst()
                t.removeLast()
            }
            return t
        }

        func parseDate(_ text: String) -> Date? {
            let t = unquote(text)
            let formats = [
                "yyyy-MM-dd",
                "yyyy/MM/dd",
                "dd.MM.yyyy",
                "MM/dd/yyyy",
                "yyyyMMdd",
                "dd-MM-yyyy",
                "MM-dd-yyyy"
            ]

            for f in formats {
                let df = DateFormatter()
                df.dateFormat = f
                df.locale = Locale(identifier: "en_US_POSIX")
                if let d = df.date(from: t) { return d }
            }
            return nil
        }

        func parseDouble(_ s: String) -> Double? {
            // Poista välilyönnit, ympäröivät lainausmerkit ja korvaa pilkut pisteiksi
            let cleaned = unquote(s)
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: ",", with: ".")
            return Double(cleaned)
        }

        // Split CSV line into fields, respecting quoted fields which may contain delimiters
        func splitCSV(_ line: String, delimiter: Character) -> [String] {
            // More robust CSV splitting using index-based iteration to allow lookahead
            var fields: [String] = []
            var current = ""
            var inQuotes = false
            let chars = Array(line)
            var i = 0
            while i < chars.count {
                let ch = chars[i]
                if ch == "\"" {
                    // Escaped quote inside quoted field
                    if inQuotes && i + 1 < chars.count && chars[i + 1] == "\"" {
                        current.append("\"")
                        i += 2
                        continue
                    } else {
                        inQuotes.toggle()
                        i += 1
                        continue
                    }
                }

                if ch == delimiter && !inQuotes {
                    fields.append(current)
                    current = ""
                    i += 1
                    continue
                }

                current.append(ch)
                i += 1
            }
            fields.append(current)
            return fields
        }

        // 7) Parsitaan datarivit
        var candles: [Candle] = []
        let cur = instrument.currency

        for line in lines {
            if line.isEmpty { continue }
            let cols = splitCSV(line, delimiter: delimiter).map { String($0) }
            // Varmista, että ainakin vaaditut indeksit löytyvät
            let needed = [dateIdx, openIdx, highIdx, lowIdx, closeIdx].allSatisfy { $0 < cols.count }
            if !needed {
                print("⚠️ Skipping malformed row (not enough columns). Parsed columns: \(cols.count), required: \(max(dateIdx, openIdx, highIdx, lowIdx, closeIdx)+1). Line: \(line)")
                print("    -> cols: \(cols)")
                continue
            }

            let tsString = cols[dateIdx]  // <-- tämä on nyt määritelty selkeästi
            guard let date = parseDate(tsString) else {
                print("⚠️ Invalid date: \(tsString) in line: \(line)")
                continue
            }

            guard
                let openVal  = parseDouble(cols[openIdx]),
                let highVal  = parseDouble(cols[highIdx]),
                let lowVal   = parseDouble(cols[lowIdx]),
                let closeVal = parseDouble(cols[closeIdx])
            else {
                print("⚠️ Invalid numeric value(s) in line: \(line)")
                continue
            }

            let vol: Double = {
                if let vIdx = volumeIdx, vIdx < cols.count {
                    return parseDouble(cols[vIdx]) ?? 0
                } else { return 0 }
            }()

            let candle = Candle(
                timestamp: date,
                open:  Money(openVal,  currency: cur),
                close: Money(closeVal, currency: cur),
                high:  Money(highVal,  currency: cur),
                low:   Money(lowVal,   currency: cur),
                volume: vol
            )
            candles.append(candle)
        }

        print("✅ CSVDataSource: loaded \(candles.count) candles.")
        return candles
    }
}
