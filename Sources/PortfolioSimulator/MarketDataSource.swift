public protocol MarketDataSource {
    func load() -> [Candle]
    func getCompanyName() -> String?
}
