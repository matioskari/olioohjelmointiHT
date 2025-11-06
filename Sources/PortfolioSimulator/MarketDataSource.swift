public protocol MarketDataSource {
    func load() -> [Candle]
}
