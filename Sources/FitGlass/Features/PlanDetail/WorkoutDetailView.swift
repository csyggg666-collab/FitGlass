import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if !workout.focus.isEmpty {
                    Text(verbatim: workout.focus)
                        .font(Theme.Typography.headline)
                        .foregroundStyle(Theme.Palette.accent)
                }
                ForEach(workout.sortedExercises) { exercise in
                    ExerciseRow(exercise: exercise)
                }
                PrimaryButton(title: "workout.markComplete", systemImage: "checkmark") {
                    logSession()
                }
                .padding(.top, 8)
            }
            .padding(Theme.Layout.screenPadding)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .screenBackground()
        .navigationTitle(workout.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func logSession() {
        let session = WorkoutSession(
            date: .now,
            planTitle: workout.plan?.title ?? "",
            workoutTitle: workout.title,
            durationMinutes: workout.estimatedMinutes,
            completedExercises: workout.exercises.count,
            totalExercises: workout.exercises.count
        )
        context.insert(session)
        try? context.save()
        dismiss()
    }
}

private struct ExerciseRow: View {
    let exercise: Exercise
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(verbatim: exercise.name)
                    .font(Theme.Typography.headline)
                    .foregroundStyle(Theme.Palette.primaryText)
                Spacer()
                if !exercise.volumeLabel.isEmpty {
                    Text(verbatim: exercise.volumeLabel)
                        .font(Theme.Typography.headline)
                        .foregroundStyle(Theme.Palette.accent)
                }
            }
            HStack(spacing: 10) {
                if !exercise.weight.isEmpty {
                    Label(exercise.weight, systemImage: "scalemass")
                }
                if exercise.restSeconds > 0 {
                    Label(L.string("exercise.restValue", String(exercise.restSeconds)), systemImage: "timer")
                }
            }
            .font(Theme.Typography.caption)
            .foregroundStyle(Theme.Palette.secondaryText)
            if !exercise.notes.isEmpty {
                Text(verbatim: exercise.notes)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Palette.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Layout.cardSpacing)
        .glassCard(cornerRadius: 20)
    }
}
