import SwiftUI

/// Glass summary card for a training plan — used on Home (carousel) and Library (grid).
struct PlanCard: View {
    let plan: TrainingPlan

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    TagPill(text: sourceKey)
                    Spacer()
                    Image(systemName: goalIcon)
                        .font(.title3)
                        .foregroundStyle(Theme.Palette.accent)
                }
                Text(verbatim: plan.title)
                    .font(Theme.Typography.title)
                    .foregroundStyle(Theme.Palette.primaryText)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if !plan.summary.isEmpty {
                    Text(verbatim: plan.summary)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Palette.secondaryText)
                        .lineLimit(2)
                }
                HStack(spacing: 6) {
                    Text(verbatim: L.string("plan.weeksValue", String(plan.weeks)))
                    Text(verbatim: "·")
                    Text(verbatim: L.string("plan.daysPerWeekValue", String(plan.daysPerWeek)))
                }
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Palette.secondaryText)
            }
        }
    }

    private var sourceKey: LocalizedStringKey {
        switch plan.source {
        case .ai:       return "source.ai"
        case .imported: return "source.imported"
        case .builtIn:  return "source.builtIn"
        }
    }

    private var goalIcon: String {
        switch plan.goal {
        case .strength:    return "dumbbell.fill"
        case .hypertrophy: return "figure.strengthtraining.traditional"
        case .endurance:   return "figure.run"
        case .fatLoss:     return "flame.fill"
        case .general:     return "figure.mixed.cardio"
        }
    }
}
