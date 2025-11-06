import Foundation

// === CLI ARGUMENTIT ====
let args = CommandLine.arguments


// defaults
var strategyName = "dca"
var candles = 200
var interval = 20
var startCash = 10_000.0
var commission = 0.001
var csvPath: String? = nil


// parse
for (i, a) in args.enumerated() {
    switch a {
    case "--strategy":
        if i+1 < args.count { strategyName = args[i+1] }
    case "--candles":
        if i+1 < args.count { candles = Int(args[i+1]) ?? candles }
    case "--interval":
        if i+1 < args.count { interval = Int(args[i+1]) ?? interval }
    case "--cash":
        if i+1 < args.count { startCash = Double(args[i+1]) ?? startCash }
    case "--commission":
        if i+1 < args.count { commission = Double(args[i+1]) ?? commission }
    case "--csv":
        if i+1 < args.count { csvPath = args[i+1] }
    default:
        continue
    }
}

// === Luodaan komponentit ===
let instrument = Instrument(symbol: "AAPL", currency: .USD)
let portfolio = Portfolio(cash: Money(startCash, currency: .USD))
let broker = Broker(commissionRate: commission, portfolio: portfolio)
let dataSource: MarketDataSource

if let path = csvPath {
    dataSource = CSVDataSource(filePath: path, instrument: instrument)
    print("Using CSV data from: \(path)")
} else {
    dataSource = SyntheticDataSource(currency: .USD, candleCount: candles)
    print("Using synthetic test data.")
}


// === Valitaan strategia ===
let strategy: Strategy
if strategyName.lowercased() == "ma" {
    strategy = MovingAverageCrossoverStrategy(shortWindow: 10, longWindow: 25, instrument: instrument)
} else {
    strategy = DCAStrategy(investmentAmount: Money(500, currency: .USD), intervalDays: interval, instrument: instrument)
}


// === Ajetaan simulaattori ===
let sim = Simulator(strategy: strategy, marketData: dataSource, broker: broker)
let report = sim.run()

report.printSummary()

// === Tallennetaan raportit ===
do {
    try report.exportCSV(to: "report_equity.csv")
    try report.exportJSON(to: "report.json")
    print("Saved CSV & JSON reports.")
} catch {
    print("Failed to save reports: \(error)")
}
