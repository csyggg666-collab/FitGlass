import Foundation
import PlanParsingKit
#if canImport(FoundationModels)
import FoundationModels
#endif

/// On-device generation via Apple's Foundation Models framework (iOS 26+). Stubbed
/// behind the same `WorkoutPlanGenerator` protocol so it can replace the Claude
/// hand-off for a seamless, offline, zero-cost experience without changing the UI.
///
/// To finish: add `func generate(from intake: PlanIntake) async throws -> TrainingPlanDTO`
/// that runs a `LanguageModelSession` with guided generation against `TrainingPlanDTO`,
/// and have the AI screen call it directly instead of going through the paste round-trip.
struct FoundationModelsGenerator: WorkoutPlanGenerator {
    let id = "on_device"

    func makePrompt(from intake: PlanIntake) -> String {
        PromptBuilder.generatePlanPrompt(from: intake)
    }

    func parse(_ raw: String) throws -> TrainingPlanDTO {
        try PlanJSONParser.parse(raw)
    }

    /// Whether on-device generation is usable on this device/build.
    static var isAvailable: Bool {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            if case .available = SystemLanguageModel.default.availability { return true }
        }
        #endif
        return false
    }
}
