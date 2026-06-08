import SwiftUI
import SwiftData

struct ProgressDashboardView: View {
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]

    var body: some View {
        NavigationStack {
            ScrollView {
                if sessions.isEmpty {
                    emptyState
                } else {
                    VStack(alignment: .leading, spacing: Theme.Layout.sectionSpacing) {
                        statsRow
                        recent
                    }
                    .padding(Theme.Layout.screenPadding)
                    .padding(.bottom, 40)
                }
            }
            .scrollIndicators(.hidden)
            .screenBackground()
            .navigationTitle("progress.title")
        }
    }

    private var statsRow: some View {
        GlassEffectContainer(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(value: "\(sessions.count)", caption: "progress.totalWorkouts")
                StatCard(value: "\(thisWeekCount)", caption: "progress.thisWeek")
                StatCard(value: "\(totalMinutes)", caption: "progress.minutes")
            }
        }
    }

    private var recent: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "progress.recent")
            ForEach(sessions) { session in
                SessionRow(session: session)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 44))
                .foregroundStyle(Theme.Palette.accent)
            Text("progress.empty")
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Palette.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 120)
        .padding(Theme.Layout.screenPadding)
    }

    private var thisWeekCount: Int {
        let calendar = Calendar.current
        return sessions.filter { calendar.isDate($0.date, equalTo: .now, toGranularity: .weekOfYear) }.count
    }

    private var totalMinutes: Int {
        sessions.reduce(0) { $0 + $1.durationMinutes }
    }
}

private struct StatCard: View {
    let value: String
    let caption: LocalizedStringKey
    var body: some View {
        VStack(spacing: 6) {
            Text(verbatim: value)
                .font(Theme.Typography.display(28))
                .foregroundStyle(Theme.Palette.accent)
            Text(caption)
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Palette.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .glassCard(cornerRadius: 18)
    }
}

private struct SessionRow: View {
    let session: WorkoutSession
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: session.workoutTitle)
                    .font(Theme.Typography.headline)
                    .foregroundStyle(Theme.Palette.primaryText)
                if !session.planTitle.isEmpty {
                    Text(verbatim: session.planTitle)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Palette.secondaryText)
                }
            }
            Spacer()
            Text(verbatim: session.date.formatted(date: .abbreviated, time: .omitted))
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Palette.secondaryText)
        }
        .padding(Theme.Layout.cardSpacing)
        .glassCard(cornerRadius: 18)
    }
}
