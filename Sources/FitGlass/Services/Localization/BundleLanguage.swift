import Foundation
import ObjectiveC

// Enables instant in-app language switching. SwiftUI `Text(LocalizedStringKey)`,
// `NSLocalizedString`, and String Catalog lookups all funnel through
// `Bundle.localizedString(forKey:value:table:)`. We swap `Bundle.main`'s class once
// and route lookups through the chosen `.lproj` bundle, so the whole UI re-localizes
// without changing every call site.

private var associatedBundleKey: UInt8 = 0

final class LanguageRoutingBundle: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let override = objc_getAssociatedObject(self, &associatedBundleKey) as? Bundle {
            return override.localizedString(forKey: key, value: value, table: tableName)
        }
        return super.localizedString(forKey: key, value: value, table: tableName)
    }
}

enum BundleLanguage {
    /// Point `Bundle.main` at the `.lproj` for `languageCode` (e.g. "zh-Hans", "en").
    static func set(_ languageCode: String) {
        if !(Bundle.main is LanguageRoutingBundle) {
            object_setClass(Bundle.main, LanguageRoutingBundle.self)
        }
        let lproj = Bundle.main.path(forResource: languageCode, ofType: "lproj").flatMap(Bundle.init(path:))
        objc_setAssociatedObject(Bundle.main, &associatedBundleKey, lproj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
