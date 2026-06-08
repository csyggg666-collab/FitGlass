import SwiftData

/// One shared SwiftData container used by both the app UI and App Intents
/// (Shortcuts / Siri), so a plan imported through an intent lands in the same store
/// the app reads from.
enum SharedStore {
    @MainActor
    static let container: ModelContainer = {
        do {
            return try ModelContainer(
                for: TrainingPlan.self, Workout.self, Exercise.self, WorkoutSession.self
            )
        } catch {
            fatalError("Failed to create shared ModelContainer: \(error)")
        }
    }()
}
