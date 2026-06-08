import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID
    var order: Int
    var name: String
    var sets: Int
    /// String so ranges ("8-12"), "AMRAP", or timed reps ("30s") survive round-trips.
    var reps: String
    var restSeconds: Int
    var weight: String
    var notes: String
    var workout: Workout?

    init(
        id: UUID = UUID(),
        order: Int = 0,
        name: String,
        sets: Int = 0,
        reps: String = "",
        restSeconds: Int = 0,
        weight: String = "",
        notes: String = ""
    ) {
        self.id = id
        self.order = order
        self.name = name
        self.sets = sets
        self.reps = reps
        self.restSeconds = restSeconds
        self.weight = weight
        self.notes = notes
    }

    /// e.g. "4 × 8-12" — compact planned-volume label.
    var volumeLabel: String {
        let repsPart = reps.isEmpty ? "" : reps
        if sets > 0 && !repsPart.isEmpty { return "\(sets) × \(repsPart)" }
        if sets > 0 { return "\(sets) sets" }
        return repsPart
    }
}
