import Foundation

/// Transport / parse format shared by the import pipeline and the Claude AI hand-off.
/// Decoded leniently (see `Lenient`): unknown keys are ignored, numbers and strings
/// are coerced, and every field except `title`/`workouts` is optional — so partial or
/// loosely-formatted plans still decode instead of failing outright.
public struct TrainingPlanDTO: Codable, Equatable, Sendable {
    public var title: String
    public var summary: String?
    public var goal: String?
    public var level: String?
    public var weeks: Int?
    public var daysPerWeek: Int?
    public var language: String?
    public var workouts: [WorkoutDTO]

    public init(
        title: String,
        summary: String? = nil,
        goal: String? = nil,
        level: String? = nil,
        weeks: Int? = nil,
        daysPerWeek: Int? = nil,
        language: String? = nil,
        workouts: [WorkoutDTO] = []
    ) {
        self.title = title
        self.summary = summary
        self.goal = goal
        self.level = level
        self.weeks = weeks
        self.daysPerWeek = daysPerWeek
        self.language = language
        self.workouts = workouts
    }

    enum CodingKeys: String, CodingKey {
        case title, summary, goal, level, weeks, daysPerWeek, language, workouts
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.title = (try? c.decode(String.self, forKey: .title)) ?? ""
        self.summary = Lenient.string(c, .summary)
        self.goal = Lenient.string(c, .goal)
        self.level = Lenient.string(c, .level)
        self.weeks = Lenient.int(c, .weeks)
        self.daysPerWeek = Lenient.int(c, .daysPerWeek)
        self.language = Lenient.string(c, .language)
        self.workouts = (try? c.decode([WorkoutDTO].self, forKey: .workouts)) ?? []
    }
}

public struct WorkoutDTO: Codable, Equatable, Sendable {
    public var day: Int?
    public var title: String
    public var focus: String?
    public var estimatedMinutes: Int?
    public var exercises: [ExerciseDTO]

    public init(
        day: Int? = nil,
        title: String,
        focus: String? = nil,
        estimatedMinutes: Int? = nil,
        exercises: [ExerciseDTO] = []
    ) {
        self.day = day
        self.title = title
        self.focus = focus
        self.estimatedMinutes = estimatedMinutes
        self.exercises = exercises
    }

    enum CodingKeys: String, CodingKey {
        case day, title, focus, estimatedMinutes, exercises
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.day = Lenient.int(c, .day)
        self.title = (try? c.decode(String.self, forKey: .title)) ?? ""
        self.focus = Lenient.string(c, .focus)
        self.estimatedMinutes = Lenient.int(c, .estimatedMinutes)
        self.exercises = (try? c.decode([ExerciseDTO].self, forKey: .exercises)) ?? []
    }
}

public struct ExerciseDTO: Codable, Equatable, Sendable {
    public var name: String
    public var sets: Int?
    /// String so the model can return ranges ("8-12"), "AMRAP", or timed reps ("30s").
    public var reps: String?
    public var restSeconds: Int?
    public var weight: String?
    public var notes: String?

    public init(
        name: String,
        sets: Int? = nil,
        reps: String? = nil,
        restSeconds: Int? = nil,
        weight: String? = nil,
        notes: String? = nil
    ) {
        self.name = name
        self.sets = sets
        self.reps = reps
        self.restSeconds = restSeconds
        self.weight = weight
        self.notes = notes
    }

    enum CodingKeys: String, CodingKey {
        case name, sets, reps, restSeconds, weight, notes
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.name = Lenient.string(c, .name) ?? ""
        self.sets = Lenient.int(c, .sets)
        self.reps = Lenient.string(c, .reps)
        self.restSeconds = Lenient.int(c, .restSeconds)
        self.weight = Lenient.string(c, .weight)
        self.notes = Lenient.string(c, .notes)
    }
}
