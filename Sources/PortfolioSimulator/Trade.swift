import Foundation

public struct Trade {
    public let order: Order
    public let price: Money
    public let timestamp: Date

    public func value() -> Money {
        return price.times(order.quantity)
    }
}
