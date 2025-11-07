import Foundation

public func drawEquityChart(values: [Double]) {
    guard values.count > 1 else {
        print("Not enough data for graph.")
        return
    }

    let maxVal = values.max()!
    let minVal = values.min()!

    let range = maxVal - minVal
    let scale = range == 0 ? 1 : range

    print("\n=== ASCII Equity Curve ===")

    for v in values {
        let barLength = Int((v - minVal) / scale * 60)
        let bar = String(repeating: "▇", count: max(1, barLength))
        print(String(format: "%10.2f | %@", v, bar))
    }

    print("============================\n")
}
