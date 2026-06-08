import Foundation

/// Tolerant decoding helpers. LLM JSON output is inconsistent — a field the
/// schema calls a string may come back as a number (and vice-versa). These
/// coerce whatever the model emitted into the type we want instead of throwing.
enum Lenient {
    static func string<K: CodingKey>(_ c: KeyedDecodingContainer<K>, _ key: K) -> String? {
        if let s = try? c.decode(String.self, forKey: key) { return s }
        if let i = try? c.decode(Int.self, forKey: key) { return String(i) }
        if let d = try? c.decode(Double.self, forKey: key) { return numberString(d) }
        if let b = try? c.decode(Bool.self, forKey: key) { return String(b) }
        return nil
    }

    static func int<K: CodingKey>(_ c: KeyedDecodingContainer<K>, _ key: K) -> Int? {
        if let i = try? c.decode(Int.self, forKey: key) { return i }
        if let d = try? c.decode(Double.self, forKey: key) { return Int(d) }
        if let s = try? c.decode(String.self, forKey: key) {
            let t = s.trimmingCharacters(in: .whitespaces)
            if let i = Int(t) { return i }
            if let d = Double(t) { return Int(d) }
        }
        return nil
    }

    /// Render a Double without a trailing ".0" when it is integral.
    static func numberString(_ d: Double) -> String {
        d == d.rounded() ? String(Int(d)) : String(d)
    }
}
