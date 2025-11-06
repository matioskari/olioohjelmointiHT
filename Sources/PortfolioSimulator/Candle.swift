import Foundation

public struct Candle {
    public let timestamp: Date
    public let open: Money
    public let close: Money
    public let high: Money
    public let low: Money
    public let volume: Double

    public func closingPrice() -> Money {
        return close
    }
}
