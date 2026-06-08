import Foundation
import PlanParsingKit

/// Converts the parse/transport `TrainingPlanDTO` (from import or the Claude hand-off)
/// into the SwiftData object graph. Insert the returned `TrainingPlan` into a
/// `ModelContext` — the cascade relationships persist its workouts and exercises.
enum PlanMapper {
    static func makePlan(
        from dto: TrainingPlanDTO,
        source: PlanSource,
        fallbackLanguage: String
    ) -> TrainingPlan {
        let plan = TrainingPlan(
            title: dto.title,
            summary: dto.summary ?? "",
            goal: Goal(rawValue: dto.goal ?? "") ?? .general,
            level: ExperienceLevel(rawValue: dto.level ?? "") ?? .beginner,
            weeks: dto.weeks ?? 0,
            daysPerWeek: dto.daysPerWeek ?? dto.workouts.count,
            languageCode: dto.language ?? fallbackLanguage,
            source: source
        )

        for (workoutIndex, workoutDTO) in dto.workouts.enumerated() {
            let workout = Workout(
                day: workoutDTO.day ?? (workoutIndex + 1),
                title: workoutDTO.title,
                focus: workoutDTO.focus ?? "",
                estimatedMinutes: workoutDTO.estimatedMinutes ?? 0
            )
            for (exerciseIndex, exerciseDTO) in workoutDTO.exercises.enumerated() {
                workout.exercises.append(
                    Exercise(
                        order: exerciseIndex,
                        name: exerciseDTO.name,
                        sets: exerciseDTO.sets ?? 0,
                        reps: exerciseDTO.reps ?? "",
                        restSeconds: exerciseDTO.restSeconds ?? 0,
                        weight: exerciseDTO.weight ?? "",
                        notes: exerciseDTO.notes ?? ""
                    )
                )
            }
            plan.workouts.append(workout)
        }
        return plan
    }
}
