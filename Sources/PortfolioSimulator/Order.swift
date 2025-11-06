public enum OrderType: String {
    case buy
    case sell
}

public struct Order {
    public let instrument: Instrument
    public let quantity: Double
    public let type: OrderType
}
