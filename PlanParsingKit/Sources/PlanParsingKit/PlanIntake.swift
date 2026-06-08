import Foundation

/// The user's answers from the "AI generate" form. Feeds `PromptBuilder`.
public struct PlanIntake: Codable, Equatable, Sendable {
    public var goal: String          // strength | hypertrophy | endurance | fat_loss | general
    public var level: String         // beginner | intermediate | advanced
    public var daysPerWeek: Int
    public var sessionMinutes: Int
    public var weeks: Int
    public var equipment: [String]   // e.g. ["dumbbells", "bodyweight"]
    public var focusAreas: [String]  // e.g. ["upper body", "core"]
    public var limitations: String?  // injuries / constraints, free text
    public var language: String      // "zh-Hans" | "en"

    public init(
        goal: String = "general",
        level: String = "beginner",
        daysPerWeek: Int = 3,
        sessionMinutes: Int = 45,
        weeks: Int = 8,
        equipment: [String] = ["bodyweight"],
        focusAreas: [String] = [],
        limitations: String? = nil,
        language: String = "en"
    ) {
        self.goal = goal
        self.level = level
        self.daysPerWeek = daysPerWeek
        self.sessionMinutes = sessionMinutes
        self.weeks = weeks
        self.equipment = equipment
        self.focusAreas = focusAreas
        self.limitations = limitations
        self.language = language
    }
}
