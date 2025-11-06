import Foundation

public final class MovingAverageCrossoverStrategy: Strategy {
    private let shortWindow: Int
    private let longWindow: Int
    private let instrument: Instrument

    public init(shortWindow: Int, longWindow: Int, instrument: Instrument) {
        precondition(shortWindow > 0 && longWindow > 0 && shortWindow < longWindow,
                     "Windows must be positive and short < long")
        self.shortWindow = shortWindow
        self.longWindow = longWindow
        self.instrument = instrument
    }

    public func name() -> String {
        "Moving Average Crossover (\(shortWindow)/\(longWindow))"
    }

    public func decideActions(marketData: [Candle]) -> [Order] {
        guard marketData.count >= longWindow else { return [] }

        var orders: [Order] = []
        var holding = false  // onko positio auki

        // Lasketaan SMA:t “rullaavasti” indeksin mukaan
        for i in (longWindow - 1)..<marketData.count {
            guard
                let shortMA = sma(marketData, period: shortWindow, endIndex: i),
                let longMA  = sma(marketData, period: longWindow,  endIndex: i)
            else { continue }

            // BUY-signaali: short ylittää longin (ja ei olla jo positiolla)
            if shortMA > longMA && !holding {
                orders.append(Order(instrument: instrument, quantity: 1.0, type: .buy))
                holding = true
            }

            // SELL-signaali: short alittaa longin (ja positio on auki)
            if shortMA < longMA && holding {
                orders.append(Order(instrument: instrument, quantity: 1.0, type: .sell))
                holding = false
            }
        }

        return orders
    }

    /// SMA viimeisestä `period` kynttilästä päättyen indeksiin `endIndex` (mukana endIndex)
    private func sma(_ data: [Candle], period: Int, endIndex: Int) -> Double? {
        guard period > 0, endIndex >= period - 1 else { return nil }
        var sum = 0.0
        let start = endIndex - period + 1
        for j in start...endIndex {
            sum += data[j].close.amount
        }
        return sum / Double(period)
    }
}
