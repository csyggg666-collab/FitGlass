import Foundation
import SwiftData

@Model
final class Workout {
    var id: UUID
    var day: Int
    var title: String
    var focus: String
    var estimatedMinutes: Int
    var plan: TrainingPlan?

    @Relationship(deleteRule: .cascade, inverse: \Exercise.workout)
    var exercises: [Exercise]

    init(
        id: UUID = UUID(),
        day: Int = 1,
        title: String,
        focus: String = "",
        estimatedMinutes: Int = 0,
        exercises: [Exercise] = []
    ) {
        self.id = id
        self.day = day
        self.title = title
        self.focus = focus
        self.estimatedMinutes = estimatedMinutes
        self.exercises = exercises
    }

    var sortedExercises: [Exercise] { exercises.sorted { $0.order < $1.order } }
}
