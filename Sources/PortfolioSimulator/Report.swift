import Foundation

public struct Report {
    public let strategyName: String
    public let trades: [Trade]
    public let equityCurve: [Money]
    public let cagr: Double
    public let maxDrawdown: Double
    public let sharpe: Double
    public let companyName: String?
    
    public init(strategyName: String, trades: [Trade], equityCurve: [Money], cagr: Double, maxDrawdown: Double, sharpe: Double, companyName: String?) {
        self.strategyName = strategyName
        self.trades = trades
        self.equityCurve = equityCurve
        self.cagr = cagr
        self.maxDrawdown = maxDrawdown
        self.sharpe = sharpe
        self.companyName = companyName
    }

    public func printSummary() {
        print("=== Report ===")
        if let company = companyName {
            print("Company: \(company)")
        }
        print("Strategy: \(strategyName)")
        print("Trades: \(trades.count)")
        print(String(format: "CAGR: %.2f%%", cagr * 100))
        print(String(format: "Max Drawdown: %.2f%%", maxDrawdown * 100))
        print(String(format: "Sharpe: %.2f", sharpe))
        if let last = equityCurve.last {
            print(String(format: "Final equity: %.2f %@", last.amount, last.currency.rawValue))
        }
    }

    // ✅ CSV export
    public func exportCSV(to path: String) throws {
        var rows: [String] = []
        rows.append("timestamp,value")

        for candleIndex in equityCurve.indices {
            let v = equityCurve[candleIndex]
            rows.append("\(candleIndex),\(v.amount)")
        }

        let csv = rows.joined(separator: "\n")
        try csv.write(to: URL(fileURLWithPath: path), atomically: true, encoding: .utf8)
    }

    // ✅ JSON export (equity + metrics)
    public func exportJSON(to path: String) throws {
        struct JSONReport: Codable {
            let strategy: String
            let cagr: Double
            let maxDrawdown: Double
            let sharpe: Double
            let finalEquity: Double
            let equityCurve: [Double]
        }

        let jr = JSONReport(
            strategy: strategyName,
            cagr: cagr,
            maxDrawdown: maxDrawdown,
            sharpe: sharpe,
            finalEquity: equityCurve.last?.amount ?? 0,
            equityCurve: equityCurve.map { $0.amount }
        )

        let data = try JSONEncoder().encode(jr)
        try data.write(to: URL(fileURLWithPath: path))
    }
}
