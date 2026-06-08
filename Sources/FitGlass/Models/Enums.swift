import Foundation

enum PlanSource: String, Codable, CaseIterable, Sendable {
    case builtIn
    case imported
    case ai
}

enum Goal: String, Codable, CaseIterable, Sendable {
    case strength
    case hypertrophy
    case endurance
    case fatLoss = "fat_loss"
    case general

    var titleKey: String {
        switch self {
        case .strength:   return "goal.strength"
        case .hypertrophy: return "goal.hypertrophy"
        case .endurance:  return "goal.endurance"
        case .fatLoss:    return "goal.fatLoss"
        case .general:    return "goal.general"
        }
    }
}

enum ExperienceLevel: String, Codable, CaseIterable, Sendable {
    case beginner
    case intermediate
    case advanced

    var titleKey: String {
        switch self {
        case .beginner:     return "level.beginner"
        case .intermediate: return "level.intermediate"
        case .advanced:     return "level.advanced"
        }
    }
}
