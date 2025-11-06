public final class Portfolio {
    private var cash: Money
    private var positions: [Instrument: Position] = [:]

    public init(cash: Money) {
        self.cash = cash
    }

    public func applyTrade(_ trade: Trade) {
        let total = trade.value()

        switch trade.order.type {
        case .buy:
            cash = cash.minus(total)
        case .sell:
            cash = cash.plus(total)
        }

        let instr = trade.order.instrument
        if positions[instr] == nil {
            positions[instr] = Position(instrument: instr)
        }
        positions[instr]?.update(with: trade)
    }

    public func value(marketPrices: [Instrument: Money]) -> Money {
        var total = cash

        for (instrument, pos) in positions {
            if let price = marketPrices[instrument] {
                total = total.plus(pos.marketValue(currentPrice: price))
            }
        }

        return total
    }

    public func allInstruments() -> [Instrument] {
        return Array(positions.keys)
    }
}