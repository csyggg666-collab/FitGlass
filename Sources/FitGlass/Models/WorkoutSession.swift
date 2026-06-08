import Foundation
import SwiftData

/// A completed-workout log entry, powering the Progress tab. Kept denormalised
/// (titles copied in) so history survives even if the source plan is deleted.
@Model
final class WorkoutSession {
    var id: UUID
    var date: Date
    var planTitle: String
    var workoutTitle: String
    var durationMinutes: Int
    var completedExercises: Int
    var totalExercises: Int
    var notes: String

    init(
        id: UUID = UUID(),
        date: Date = .now,
        planTitle: String = "",
        workoutTitle: String = "",
        durationMinutes: Int = 0,
        completedExercises: Int = 0,
        totalExercises: Int = 0,
        notes: String = ""
    ) {
        self.id = id
        self.date = date
        self.planTitle = planTitle
        self.workoutTitle = workoutTitle
        self.durationMinutes = durationMinutes
        self.completedExercises = completedExercises
        self.totalExercises = totalExercises
        self.notes = notes
    }
}
