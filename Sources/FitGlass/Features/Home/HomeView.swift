import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \TrainingPlan.createdAt, order: .reverse) private var plans: [TrainingPlan]
    @State private var showGenerate = false
    @State private var showImport = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Layout.sectionSpacing) {
                    HeroHeader(title: "home.greeting", subtitle: "home.subtitle")
                    quickActions
                    featured
                }
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            .screenBackground()
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: TrainingPlan.self) { PlanDetailView(plan: $0) }
            .sheet(isPresented: $showGenerate) { AIGenerateView() }
            .sheet(isPresented: $showImport) { ImportView() }
        }
    }

    private var quickActions: some View {
        GlassEffectContainer(spacing: 16) {
            HStack(spacing: 12) {
                GlassButton(title: "home.generate", systemImage: "sparkles") { showGenerate = true }
                GlassButton(title: "home.import", systemImage: "square.and.arrow.down") { showImport = true }
            }
        }
        .padding(.horizontal, Theme.Layout.screenPadding)
    }

    @ViewBuilder
    private var featured: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "home.featured")
                .padding(.horizontal, Theme.Layout.screenPadding)

            if plans.isEmpty {
                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("home.noPlanTitle")
                            .font(Theme.Typography.headline)
                            .foregroundStyle(Theme.Palette.primaryText)
                        Text("home.noPlanMessage")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Palette.secondaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, Theme.Layout.screenPadding)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(plans) { plan in
                            NavigationLink(value: plan) {
                                PlanCard(plan: plan).frame(width: 260)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, Theme.Layout.screenPadding)
                }
            }
        }
    }
}
