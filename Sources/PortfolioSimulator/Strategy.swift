public protocol Strategy {
    func decideActions(marketData: [Candle]) -> [Order]
    func name() -> String
}
