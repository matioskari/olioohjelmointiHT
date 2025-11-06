public final class Simulator {
    private let strategy: Strategy
    private let marketData: MarketDataSource
    private let broker: Broker

    public init(strategy: Strategy, marketData: MarketDataSource, broker: Broker) {
        self.strategy = strategy
        self.marketData = marketData
        self.broker = broker
    }

    public func run() -> Report {
        let candles = marketData.load()
        guard !candles.isEmpty else {
            return Report(strategyName: strategy.name(),
                          trades: [],
                          equityCurve: [],
                          cagr: 0,
                          maxDrawdown: 0,
                          sharpe: 0)
        }

        // 1) Strategia päättää, mitä tehdään
        let orders = strategy.decideActions(marketData: candles)

        // 2) Toteutetaan toimeksiannot niiden tapahtumahetken mukaisilla hinnoilla
        var trades: [Trade] = []
        for (i, order) in orders.enumerated() {
            let idx = min(i, candles.count - 1)
            let price = candles[idx].closingPrice()
            let trade = broker.execute(order: order, price: price)
            trades.append(trade)
        }

        // 3) Equity curve päivittäin
        var equityCurve: [Money] = []

        for c in candles {
            // Hinnasto kaikille positioille (nyt vain yksi instrumentti)
            var priceMap: [Instrument: Money] = [:]

            // Lisää hinnat kaikille salkun instrumenteille
            let instruments = broker.allInstruments()
            for instr in instruments {
                // Käytetään tämän päivän candle-hintaa (close)
                priceMap[instr] = c.close
            }

            // Salkun arvon laskenta
            let totalValue = broker.portfolioValue(marketPrices: priceMap)
            equityCurve.append(totalValue)
        }

        // 4) Laske tuotot
        var returns: [Double] = []
        for i in 1..<equityCurve.count {
            let prev = equityCurve[i-1].amount
            let curr = equityCurve[i].amount
            returns.append(curr / prev - 1.0)
        }

        // 5) Riskimittarit
        let cagr = RiskMetrics.calculateCAGR(values: equityCurve)
        let maxDD = RiskMetrics.calculateMaxDrawdown(values: equityCurve)
        let sharpe = RiskMetrics.sharpeRatio(returns: returns, riskFreeRate: 0.0)

        return Report(
            strategyName: strategy.name(),
            trades: trades,
            equityCurve: equityCurve,
            cagr: cagr,
            maxDrawdown: maxDD,
            sharpe: sharpe
        )
    }
}
