enum Console {
    static func green(_ text: String) { print("\u{001B}[0;32m\(text)\u{001B}[0m") }
    static func red(_ text: String) { print("\u{001B}[0;31m\(text)\u{001B}[0m") }
    static func yellow(_ text: String) { print("\u{001B}[0;33m\(text)\u{001B}[0m") }
    static func blue(_ text: String) { print("\u{001B}[0;34m\(text)\u{001B}[0m") }
}
