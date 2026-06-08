import XCTest
import PlanParsingKit
@testable import FitGlass

final class PlanMapperTests: XCTestCase {
    func testMapsDTOToModelGraph() {
        let dto = TrainingPlanDTO(
            title: "Test Plan",
            summary: "s",
            goal: "strength",
            level: "beginner",
            weeks: 4,
            daysPerWeek: 2,
            language: "en",
            workouts: [
                WorkoutDTO(day: 1, title: "A", focus: "legs", estimatedMinutes: 50,
                           exercises: [ExerciseDTO(name: "Squat", sets: 5, reps: "5", restSeconds: 180)]),
                WorkoutDTO(title: "B", exercises: []),   // nil day -> defaults to index + 1
            ]
        )

        let plan = PlanMapper.makePlan(from: dto, source: .ai, fallbackLanguage: "en")

        XCTAssertEqual(plan.title, "Test Plan")
        XCTAssertEqual(plan.goal, .strength)
        XCTAssertEqual(plan.level, .beginner)
        XCTAssertEqual(plan.source, .ai)
        XCTAssertEqual(plan.workouts.count, 2)

        let sorted = plan.sortedWorkouts
        XCTAssertEqual(sorted[0].day, 1)
        XCTAssertEqual(sorted[1].day, 2)            // defaulted from order
        XCTAssertEqual(sorted[0].exercises.first?.name, "Squat")
        XCTAssertEqual(sorted[0].exercises.first?.volumeLabel, "5 × 5")
    }

    func testDaysPerWeekFallsBackToWorkoutCount() {
        let dto = TrainingPlanDTO(title: "P", workouts: [
            WorkoutDTO(title: "A"), WorkoutDTO(title: "B"), WorkoutDTO(title: "C"),
        ])
        let plan = PlanMapper.makePlan(from: dto, source: .imported, fallbackLanguage: "zh-Hans")
        XCTAssertEqual(plan.daysPerWeek, 3)
        XCTAssertEqual(plan.languageCode, "zh-Hans")
        XCTAssertEqual(plan.source, .imported)
    }
}
