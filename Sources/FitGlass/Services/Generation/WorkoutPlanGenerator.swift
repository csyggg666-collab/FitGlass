import Foundation
import PlanParsingKit

/// Pluggable AI plan generator. The UI builds a prompt and parses a reply through
/// this protocol, so swapping the Claude hand-off for on-device Foundation Models
/// or a cloud API later doesn't touch any view code.
protocol WorkoutPlanGenerator {
    var id: String { get }
    func makePrompt(from intake: PlanIntake) -> String
    func parse(_ raw: String) throws -> TrainingPlanDTO
}

/// Default: hand the prompt to the Claude app (user's own Pro account), then parse
/// the JSON the user pastes back. No API key, no backend, no per-call cost.
struct ClaudeHandoffGenerator: WorkoutPlanGenerator {
    let id = "claude"
    func makePrompt(from intake: PlanIntake) -> String {
        PromptBuilder.generatePlanPrompt(from: intake)
    }
    func parse(_ raw: String) throws -> TrainingPlanDTO {
        try PlanJSONParser.parse(raw)
    }
}
