import Foundation
import SwiftData

/// Seeds a couple of built-in plans on first launch so Home/Library aren't empty.
enum SampleData {
    @MainActor
    static func seedIfNeeded(_ context: ModelContext) {
        let existing = (try? context.fetchCount(FetchDescriptor<TrainingPlan>())) ?? 0
        guard existing == 0 else { return }
        for plan in builtInPlans() { context.insert(plan) }
        try? context.save()
    }

    static func builtInPlans() -> [TrainingPlan] {
        [fullBodyStrength(), pushPullLegs()]
    }

    private static func fullBodyStrength() -> TrainingPlan {
        let plan = TrainingPlan(
            title: "Full Body Strength",
            summary: "A 3-day full-body strength base built on the big compound lifts.",
            goal: .strength, level: .beginner, weeks: 8, daysPerWeek: 3,
            languageCode: "en", source: .builtIn
        )
        let a = Workout(day: 1, title: "Day A", focus: "Squat focus", estimatedMinutes: 50)
        a.exercises.append(contentsOf: [
            Exercise(order: 0, name: "Back Squat", sets: 5, reps: "5", restSeconds: 180, weight: "barbell"),
            Exercise(order: 1, name: "Bench Press", sets: 5, reps: "5", restSeconds: 180, weight: "barbell"),
            Exercise(order: 2, name: "Barbell Row", sets: 5, reps: "5", restSeconds: 120, weight: "barbell"),
        ])
        let b = Workout(day: 2, title: "Day B", focus: "Deadlift focus", estimatedMinutes: 55)
        b.exercises.append(contentsOf: [
            Exercise(order: 0, name: "Deadlift", sets: 3, reps: "5", restSeconds: 210, weight: "barbell"),
            Exercise(order: 1, name: "Overhead Press", sets: 5, reps: "5", restSeconds: 150, weight: "barbell"),
            Exercise(order: 2, name: "Pull-up", sets: 4, reps: "AMRAP", restSeconds: 120, weight: "bodyweight"),
        ])
        let c = Workout(day: 3, title: "Day C", focus: "Volume", estimatedMinutes: 50)
        c.exercises.append(contentsOf: [
            Exercise(order: 0, name: "Front Squat", sets: 4, reps: "8", restSeconds: 150, weight: "barbell"),
            Exercise(order: 1, name: "Incline Dumbbell Press", sets: 4, reps: "10", restSeconds: 120, weight: "dumbbells"),
            Exercise(order: 2, name: "Plank", sets: 3, reps: "60s", restSeconds: 60, weight: "bodyweight"),
        ])
        plan.workouts.append(contentsOf: [a, b, c])
        return plan
    }

    private static func pushPullLegs() -> TrainingPlan {
        let plan = TrainingPlan(
            title: "Push / Pull / Legs",
            summary: "Classic hypertrophy split hitting each pattern across the week.",
            goal: .hypertrophy, level: .intermediate, weeks: 6, daysPerWeek: 3,
            languageCode: "en", source: .builtIn
        )
        let push = Workout(day: 1, title: "Push", focus: "Chest · Shoulders · Triceps", estimatedMinutes: 60)
        push.exercises.append(contentsOf: [
            Exercise(order: 0, name: "Bench Press", sets: 4, reps: "8-10", restSeconds: 120, weight: "barbell"),
            Exercise(order: 1, name: "Seated Shoulder Press", sets: 3, reps: "10-12", restSeconds: 90, weight: "dumbbells"),
            Exercise(order: 2, name: "Cable Fly", sets: 3, reps: "12-15", restSeconds: 60, weight: "cable"),
            Exercise(order: 3, name: "Triceps Pushdown", sets: 3, reps: "12-15", restSeconds: 60, weight: "cable"),
        ])
        let pull = Workout(day: 2, title: "Pull", focus: "Back · Biceps", estimatedMinutes: 60)
        pull.exercises.append(contentsOf: [
            Exercise(order: 0, name: "Deadlift", sets: 3, reps: "5", restSeconds: 180, weight: "barbell"),
            Exercise(order: 1, name: "Lat Pulldown", sets: 4, reps: "10-12", restSeconds: 90, weight: "cable"),
            Exercise(order: 2, name: "Seated Row", sets: 3, reps: "10-12", restSeconds: 90, weight: "cable"),
            Exercise(order: 3, name: "Barbell Curl", sets: 3, reps: "12", restSeconds: 60, weight: "barbell"),
        ])
        let legs = Workout(day: 3, title: "Legs", focus: "Quads · Hamstrings · Calves", estimatedMinutes: 65)
        legs.exercises.append(contentsOf: [
            Exercise(order: 0, name: "Back Squat", sets: 4, reps: "8", restSeconds: 150, weight: "barbell"),
            Exercise(order: 1, name: "Romanian Deadlift", sets: 3, reps: "10", restSeconds: 120, weight: "barbell"),
            Exercise(order: 2, name: "Leg Press", sets: 3, reps: "12", restSeconds: 90, weight: "machine"),
            Exercise(order: 3, name: "Standing Calf Raise", sets: 4, reps: "15", restSeconds: 45, weight: "machine"),
        ])
        plan.workouts.append(contentsOf: [push, pull, legs])
        return plan
    }
}
