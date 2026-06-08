import SwiftUI
import SwiftData

struct LibraryView: View {
    @Query(sort: \TrainingPlan.createdAt, order: .reverse) private var plans: [TrainingPlan]
    @Environment(\.modelContext) private var context
    @State private var showGenerate = false
    @State private var showImport = false

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                if plans.isEmpty {
                    emptyState
                } else {
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
                        ForEach(plans) { plan in
                            NavigationLink(value: plan) {
                                PlanCard(plan: plan)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button("common.delete", systemImage: "trash", role: .destructive) {
                                    delete(plan)
                                }
                            }
                        }
                    }
                    .padding(Theme.Layout.screenPadding)
                }
            }
            .scrollIndicators(.hidden)
            .screenBackground()
            .navigationTitle("library.title")
            .navigationDestination(for: TrainingPlan.self) { PlanDetailView(plan: $0) }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("home.generate", systemImage: "sparkles") { showGenerate = true }
                        Button("home.import", systemImage: "square.and.arrow.down") { showImport = true }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showGenerate) { AIGenerateView() }
            .sheet(isPresented: $showImport) { ImportView() }
        }
    }

    private var emptyState: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "square.stack.3d.up")
                    .font(.largeTitle)
                    .foregroundStyle(Theme.Palette.accent)
                Text("library.empty")
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Palette.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Theme.Layout.screenPadding)
    }

    private func delete(_ plan: TrainingPlan) {
        context.delete(plan)
        try? context.save()
    }
}
