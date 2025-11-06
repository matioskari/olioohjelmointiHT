public final class DCAStrategy: Strategy {
    private let investmentAmount: Money
    private let intervalDays: Int
    private let instrument: Instrument

    public init(investmentAmount: Money, intervalDays: Int, instrument: Instrument) {
        self.investmentAmount = investmentAmount
        self.intervalDays = intervalDays
        self.instrument = instrument
    }

    public func decideActions(marketData: [Candle]) -> [Order] {
        var orders: [Order] = []

        for (i, candle) in marketData.enumerated() {
            if i % intervalDays == 0 {
                let qty = investmentAmount.amount / candle.closingPrice().amount
                let order = Order(
                    instrument: instrument,
                    quantity: qty,
                    type: .buy
                )
                orders.append(order)
            }
        }

        return orders
    }

    public func name() -> String {
        return "Dollar-Cost Averaging"
    }
}
