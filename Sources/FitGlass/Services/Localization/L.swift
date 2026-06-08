import Foundation

/// Tiny helper for formatted, language-routed strings. Static `Text("key")` resolves
/// fine through the routed `Bundle.main`; this covers the cases that need runtime
/// arguments. Use `%@` placeholders and pass `String` values so there are no
/// integer-width pitfalls. The whole view tree rebuilds on language change
/// (root `.id(refreshToken)`), so results re-localize automatically.
enum L {
    static func string(_ key: String, _ args: String...) -> String {
        let format = Bundle.main.localizedString(forKey: key, value: key, table: nil)
        guard !args.isEmpty else { return format }
        return String(format: format, arguments: args)
    }
}
