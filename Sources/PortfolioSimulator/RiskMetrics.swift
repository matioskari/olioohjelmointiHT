// RiskMetrics.swift
import Foundation

public struct RiskMetrics {
    public static func calculateCAGR(values: [Money]) -> Double {
        guard let first = values.first, let last = values.last, values.count > 1 else { return 0 }
        let years = Double(values.count) / 252.0 // karkea arvio pörssipäivistä
        return pow(last.amount / first.amount, 1.0/years) - 1.0
    }

    public static func calculateMaxDrawdown(values: [Money]) -> Double {
        var peak = values.first?.amount ?? 0
        var maxDD = 0.0
        for v in values {
            peak = max(peak, v.amount)
            let dd = (v.amount - peak) / peak
            maxDD = min(maxDD, dd)
        }
        return maxDD
    }

    public static func volatility(returns: [Double]) -> Double {
        guard returns.count > 1 else { return 0 }
        let mean = returns.reduce(0,+) / Double(returns.count)
        let varSum = returns.reduce(0) { $0 + pow($1 - mean, 2) }
        // vuositasolle
        return sqrt(varSum / Double(returns.count - 1)) * sqrt(252.0)
    }

    public static func sharpeRatio(returns: [Double], riskFreeRate: Double) -> Double {
        let dailyRf = riskFreeRate / 252.0
        let excess = returns.map { $0 - dailyRf }
        let vol = volatility(returns: excess)
        guard vol != 0 else { return 0 }
        let mean = excess.reduce(0,+) / Double(excess.count)
        return (mean * 252.0) / vol
    }
}
