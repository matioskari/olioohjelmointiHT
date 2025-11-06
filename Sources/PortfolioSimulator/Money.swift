// Money.swift
public struct Money: Equatable {
    public let amount: Double
    public let currency: Currency

    public init(_ amount: Double, currency: Currency) {
        self.amount = amount
        self.currency = currency
    }

    public func plus(_ other: Money) -> Money {
        precondition(currency == other.currency, "Currency mismatch")
        return Money(amount + other.amount, currency: currency)
    }

    public func minus(_ other: Money) -> Money {
        precondition(currency == other.currency, "Currency mismatch")
        return Money(amount - other.amount, currency: currency)
    }

    // ⬇️ Tämä puuttui
    public func times(_ factor: Double) -> Money {
        Money(amount * factor, currency: currency)
    }

    // (hyödyllinen joillekin kaavoille)
    public func divided(by divisor: Double) -> Money {
        Money(amount / divisor, currency: currency)
    }
}

// (valinnaiset, mutta kätevät operaattorit)
public func + (lhs: Money, rhs: Money) -> Money { lhs.plus(rhs) }
public func - (lhs: Money, rhs: Money) -> Money { lhs.minus(rhs) }
public func * (lhs: Money, rhs: Double) -> Money { lhs.times(rhs) }
public func * (lhs: Double, rhs: Money) -> Money { rhs.times(lhs) }