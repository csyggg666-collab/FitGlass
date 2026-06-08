import Foundation
import SwiftData
import PlanParsingKit

/// Maps a parsed `TrainingPlanDTO` (from import or the Claude hand-off) into the
/// SwiftData store. Shared by the Import and AI-generate flows.
enum PlanSaver {
    @MainActor
    @discardableResult
    static func save(
        _ dto: TrainingPlanDTO,
        source: PlanSource,
        language: String,
        into context: ModelContext
    ) -> TrainingPlan {
        let plan = PlanMapper.makePlan(from: dto, source: source, fallbackLanguage: language)
        context.insert(plan)
        try? context.save()
        return plan
    }
}
