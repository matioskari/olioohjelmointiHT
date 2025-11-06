import Foundation

extension Array where Element == Candle {
    /// Rerturns the simple moving average for the last `period` closing prices.
    func simpleMovingAverage(period: Int) -> Double? {
        guard self.count >= period else {
            return nil
        }

        let slice = self.suffix(period)
        let sum = slice.reduce(0.0) { $0 + $1.close.amount}
        return sum / Double(period)
    }
}