import Foundation

public final class SyntheticDataSource: MarketDataSource {
    private let seed: Int
    private let instrumentCurrency: Currency
    private let candleCount: Int

    // ✅ Tämä init vastaa main.swift-kutsua
    public init(seed: Int = 123, currency: Currency = .USD, candleCount: Int = 200) {
        self.seed = seed
        self.instrumentCurrency = currency
        self.candleCount = candleCount
    }

    public func load() -> [Candle] {
        var candles: [Candle] = []
        var price = 100.0
        var date = Date()

        // yksinkertainen “satunnaisliike”
        for _ in 0..<candleCount {
            let change = Double.random(in: -1.0...1.0) * 0.5
            price = max(1.0, price + change)

            let close = Money(price, currency: instrumentCurrency)
            let open  = close
            let high  = close.times(1.01)
            let low   = close.times(0.99)

            let c = Candle(timestamp: date, open: open, close: close, high: high, low: low, volume: 1000)
            candles.append(c)

            date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        }
        return candles
    }
}
