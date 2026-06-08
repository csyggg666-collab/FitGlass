import SwiftUI

struct PlanDetailView: View {
    let plan: TrainingPlan

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Layout.sectionSpacing) {
                header
                stats
                if !plan.summary.isEmpty {
                    Text(verbatim: plan.summary)
                        .font(Theme.Typography.body)
                        .foregroundStyle(Theme.Palette.secondaryText)
                        .padding(.horizontal, Theme.Layout.screenPadding)
                }
                workouts
            }
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .screenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationDestination(for: Workout.self) { WorkoutDetailView(workout: $0) }
    }

    private var header: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [Theme.Palette.accent.opacity(0.5), Theme.Palette.background],
                startPoint: .topTrailing, endPoint: .bottomLeading
            )
            VStack(alignment: .leading, spacing: 8) {
                Text(verbatim: L.string(plan.goal.titleKey).uppercased())
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Palette.primaryText.opacity(0.85))
                Text(verbatim: plan.title)
                    .font(Theme.Typography.display(38))
                    .foregroundStyle(.white)
                    .lineLimit(3)
            }
            .padding(Theme.Layout.screenPadding)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 260)
    }

    private var stats: some View {
        GlassEffectContainer(spacing: 12) {
            HStack(spacing: 12) {
                StatChip(value: L.string("plan.weeksValue", String(plan.weeks)))
                StatChip(value: L.string("plan.daysPerWeekValue", String(plan.daysPerWeek)))
                StatChip(value: L.string("plan.workoutsCount", String(plan.workouts.count)))
            }
        }
        .padding(.horizontal, Theme.Layout.screenPadding)
    }

    private var workouts: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "plan.overview")
                .padding(.horizontal, Theme.Layout.screenPadding)
            ForEach(plan.sortedWorkouts) { workout in
                NavigationLink(value: workout) {
                    WorkoutRow(workout: workout)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, Theme.Layout.screenPadding)
            }
        }
    }
}

private struct StatChip: View {
    let value: String
    var body: some View {
        Text(verbatim: value)
            .font(Theme.Typography.headline)
            .foregroundStyle(Theme.Palette.primaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .glassCard(cornerRadius: 18)
    }
}

private struct WorkoutRow: View {
    let workout: Workout
    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: L.string("plan.dayValue", String(workout.day)))
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Palette.accent)
                Text(verbatim: workout.title)
                    .font(Theme.Typography.headline)
                    .foregroundStyle(Theme.Palette.primaryText)
                if !workout.focus.isEmpty {
                    Text(verbatim: workout.focus)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Palette.secondaryText)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.Palette.secondaryText)
        }
        .padding(Theme.Layout.cardSpacing)
        .glassCard(cornerRadius: 20)
    }
}
