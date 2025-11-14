import Foundation

public enum StrategySelection {
    case dca
    case ma
}

public final class SimulatorFactory {

    public init() {}

    public func createSimulator(
        strategy: StrategySelection,
        dcaAmount: Money? = nil,
        dcaInterval: Int? = nil,
        maShortPeriod: Int? = nil,
        maLongPeriod: Int? = nil,
        csvPath: String? = nil
    ) -> Simulator {
        let instrument = Instrument(symbol: "AAPL", currency: .USD)
        
        // Use data.csv by default, or specified CSV path
        let path = csvPath ?? "data.csv"
        let dataSource = CSVDataSource(filePath: path, instrument: instrument)
        let portfolio = Portfolio(cash: Money(10_000, currency: .USD))
        let broker = Broker(commissionRate: 0.001, portfolio: portfolio)

        let strategyObj: Strategy
        switch strategy {
        case .dca:
            strategyObj = DCAStrategy(
                investmentAmount: dcaAmount ?? Money(500, currency: .USD),
                intervalDays: dcaInterval ?? 20,
                instrument: instrument
            )
        case .ma:
            strategyObj = MovingAverageCrossoverStrategy(
                shortWindow: maShortPeriod ?? 10,
                longWindow: maLongPeriod ?? 25,
                instrument: instrument
            )
        }

        return Simulator(strategy: strategyObj, marketData: dataSource, broker: broker)
    }

    public func createSimulator(csvPath: String) -> Simulator {
        let instrument = Instrument(symbol: "AAPL", currency: .USD)

        let dataSource = CSVDataSource(filePath: csvPath, instrument: instrument)
        let portfolio = Portfolio(cash: Money(10_000, currency: .USD))
        let broker = Broker(commissionRate: 0.001, portfolio: portfolio)

        // default: MA strategy
        let strategy = MovingAverageCrossoverStrategy(
            shortWindow: 10,
            longWindow: 25,
            instrument: instrument
        )

        return Simulator(strategy: strategy, marketData: dataSource, broker: broker)
    }
}
