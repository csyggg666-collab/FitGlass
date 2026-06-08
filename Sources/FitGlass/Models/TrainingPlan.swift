import Foundation
import SwiftData

@Model
final class TrainingPlan {
    var id: UUID
    var title: String
    var summary: String
    var goalRaw: String
    var levelRaw: String
    var weeks: Int
    var daysPerWeek: Int
    var languageCode: String
    var sourceRaw: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Workout.plan)
    var workouts: [Workout]

    init(
        id: UUID = UUID(),
        title: String,
        summary: String = "",
        goal: Goal = .general,
        level: ExperienceLevel = .beginner,
        weeks: Int = 0,
        daysPerWeek: Int = 0,
        languageCode: String = "en",
        source: PlanSource = .ai,
        createdAt: Date = .now,
        workouts: [Workout] = []
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.goalRaw = goal.rawValue
        self.levelRaw = level.rawValue
        self.weeks = weeks
        self.daysPerWeek = daysPerWeek
        self.languageCode = languageCode
        self.sourceRaw = source.rawValue
        self.createdAt = createdAt
        self.workouts = workouts
    }

    var goal: Goal { Goal(rawValue: goalRaw) ?? .general }
    var level: ExperienceLevel { ExperienceLevel(rawValue: levelRaw) ?? .beginner }
    var source: PlanSource { PlanSource(rawValue: sourceRaw) ?? .ai }

    var sortedWorkouts: [Workout] { workouts.sorted { $0.day < $1.day } }
}
