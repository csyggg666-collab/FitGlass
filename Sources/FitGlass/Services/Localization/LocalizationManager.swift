import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case system
    case english = "en"
    case chinese = "zh-Hans"

    var id: String { rawValue }

    var titleKey: LocalizedStringKey {
        switch self {
        case .system:  return "language.system"
        case .english: return "language.english"
        case .chinese: return "language.chinese"
        }
    }

    /// Resolves `.system` to the best supported match for the device.
    var resolvedCode: String {
        switch self {
        case .system:
            let preferred = Locale.preferredLanguages.first ?? "en"
            return preferred.hasPrefix("zh") ? "zh-Hans" : "en"
        case .english: return "en"
        case .chinese: return "zh-Hans"
        }
    }
}

/// Owns the user's language choice, persists it, and routes `Bundle.main` so the
/// whole app re-localizes instantly. Views observe `refreshToken` (via the root
/// `.id(...)`) to rebuild on change.
@Observable
@MainActor
final class LocalizationManager {
    static let storageKey = "app_language"

    private(set) var language: AppLanguage
    private(set) var refreshToken: Int = 0

    init() {
        let raw = UserDefaults.standard.string(forKey: Self.storageKey)
        language = raw.flatMap(AppLanguage.init(rawValue:)) ?? .system
        BundleLanguage.set(language.resolvedCode)
    }

    func setLanguage(_ newValue: AppLanguage) {
        guard newValue != language else { return }
        language = newValue
        UserDefaults.standard.set(newValue.rawValue, forKey: Self.storageKey)
        BundleLanguage.set(newValue.resolvedCode)
        refreshToken &+= 1
    }

    /// Locale for date/number formatting and SwiftUI environment.
    var locale: Locale { Locale(identifier: language.resolvedCode) }

    /// Language code passed to AI / import content ("zh-Hans" | "en").
    var contentLanguageCode: String { language.resolvedCode }
}
