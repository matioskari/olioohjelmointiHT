import Foundation

public final class CSVDataSource: MarketDataSource {
    private let filePath: String
    private let instrument: Instrument
    private let dateFormatter: DateFormatter

    public init(filePath: String, instrument: Instrument) {
        self.filePath = filePath
        self.instrument = instrument

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.locale = Locale(identifier: "en_US_POSIX")
        self.dateFormatter = df
    }

    public func load() -> [Candle] {
        print("📄 CSVDataSource: trying to read file at \(filePath)")

        // --- Read file contents ---
        guard let data = try? String(contentsOfFile: filePath, encoding: .utf8) else {
            print("❌ CSVDataSource: unable to read file at \(filePath)")
            return []
        }

    let lines = data
        .replacingOccurrences(of: "\r\n", with: "\n")
        .replacingOccurrences(of: "\r", with: "\n")
        .split(separator: "\n")
        .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }


        // Nothing to parse?
        if lines.count <= 1 {
            print("⚠️ CSVDataSource: file is empty or contains no data rows.")
            return []
        }

        // Detect delimiter automatically: comma or semicolon
        let delimiter: Character = lines[1].contains(";") ? ";" : ","

        print("✅ CSVDataSource: using delimiter '\(delimiter)'")

        var candles: [Candle] = []

        // Skip header
        for line in lines.dropFirst() {
            if line.isEmpty { continue }
            let parts = line.split(separator: delimiter)

            if parts.count < 5 {
                print("⚠️ Skipping malformed row: \(line)")
                continue
            }

            // Parse components
            let ts = String(parts[0])
            guard let date = dateFormatter.date(from: ts) else {
                print("⚠️ Invalid date format in line: \(line)")
                continue
            }

            func parseMoney(_ str: Substring) -> Double? {
                let s = String(str).replacingOccurrences(of: ",", with: ".")
                return Double(s)
            }

            guard
                let openVal = parseMoney(parts[1]),
                let highVal = parseMoney(parts[2]),
                let lowVal  = parseMoney(parts[3]),
                let closeVal = parseMoney(parts[4])
            else {
                print("⚠️ Invalid numeric value in line: \(line)")
                continue
            }

            let volume: Double =
                (parts.count > 5 ? Double(parts[5]) : 0) ?? 0

            let cur = instrument.currency

            let candle = Candle(
                timestamp: date,
                open: Money(openVal, currency: cur),
                close: Money(closeVal, currency: cur),
                high: Money(highVal, currency: cur),
                low: Money(lowVal, currency: cur),
                volume: volume
            )

            candles.append(candle)
        }

        print("✅ CSVDataSource: loaded \(candles.count) candles.")
        return candles
    }
}
