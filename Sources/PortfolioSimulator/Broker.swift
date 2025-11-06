import Foundation

public final class Broker {
    private let commissionRate: Double
    private let portfolio: Portfolio

    public init(commissionRate: Double, portfolio: Portfolio) {
        self.commissionRate = commissionRate
        self.portfolio = portfolio
    }

    public func execute(order: Order, price: Money) -> Trade {
        let commission = price.times(order.quantity * commissionRate)
        let finalPrice = price.plus(commission)
        let trade = Trade(order: order, price: finalPrice, timestamp: Date())
        portfolio.applyTrade(trade)
        return trade
    }

    public func portfolioValue(marketPrices: [Instrument: Money]) -> Money {
        return portfolio.value(marketPrices: marketPrices)
    }

    // ✅ UUSI getter
    public func allInstruments() -> [Instrument] {
        return portfolio.allInstruments()
    }
}
