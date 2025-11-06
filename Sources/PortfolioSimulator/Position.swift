public final class Position {
    public let instrument: Instrument
    private var quantity: Double = 0
    private var averagePrice: Money

    public init(instrument: Instrument) {
        self.instrument = instrument
        self.averagePrice = Money(0, currency: instrument.currency)
    }

    public func update(with trade: Trade) {
        let q = trade.order.quantity

        switch trade.order.type {
        case .buy:
            let newValue = averagePrice.times(quantity).plus(trade.value())
            quantity += q
            if quantity > 0 {
                averagePrice = newValue.times(1 / quantity)
            }
        case .sell:
            quantity -= q
            if quantity < 0 { quantity = 0 }
        }
    }

    public func marketValue(currentPrice: Money) -> Money {
        return currentPrice.times(quantity)
    }
}
