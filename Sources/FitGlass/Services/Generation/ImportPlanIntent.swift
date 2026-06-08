import AppIntents
import SwiftData
import PlanParsingKit

/// App Intent so an Apple Shortcut can hand a JSON plan — e.g. the reply from
/// Claude's "Ask Claude" action — straight into FitGlass. This enables a near
/// one-tap generate → import round-trip without manual pasting, complementing the
/// `fitglass://import` URL scheme.
struct ImportPlanIntent: AppIntent {
    static var title: LocalizedStringResource = "Import training plan"
    static var description = IntentDescription(
        "Parse a JSON training plan (for example Claude's reply) and save it into FitGlass."
    )
    static var openAppWhenRun = false

    @Parameter(title: "Plan JSON")
    var planJSON: String

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let dto = try PlanJSONParser.parse(planJSON)
        let language = UserDefaults.standard.string(forKey: LocalizationManager.storageKey)
            .flatMap(AppLanguage.init(rawValue:))?.resolvedCode ?? "en"
        let plan = PlanSaver.save(
            dto, source: .ai, language: language,
            into: SharedStore.container.mainContext
        )
        return .result(dialog: "Saved “\(plan.title)” to FitGlass.")
    }
}

/// Exposes the import intent to Shortcuts and Spotlight with ready-made phrases.
struct FitGlassShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ImportPlanIntent(),
            phrases: [
                "Import a plan into \(.applicationName)",
                "Add a workout plan to \(.applicationName)",
            ],
            shortTitle: "Import plan",
            systemImageName: "square.and.arrow.down"
        )
    }
}
