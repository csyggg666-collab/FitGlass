import SwiftUI
import SwiftData
import PlanParsingKit

struct AIGenerateView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(LocalizationManager.self) private var localization

    @State private var goal: Goal = .general
    @State private var level: ExperienceLevel = .beginner
    @State private var daysPerWeek = 3
    @State private var sessionMinutes = 45
    @State private var weeks = 8
    @State private var selectedEquipment: Set<String> = ["bodyweight"]
    @State private var focus = ""
    @State private var limitations = ""
    @State private var showHandoff = false

    private let equipmentOptions = ["bodyweight", "dumbbells", "barbell", "machine", "cable", "kettlebell", "bands"]
    private let generator: WorkoutPlanGenerator = ClaudeHandoffGenerator()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("ai.intro")
                        .font(Theme.Typography.body)
                        .foregroundStyle(Theme.Palette.secondaryText)
                }
                Section("ai.goal") {
                    Picker("ai.goal", selection: $goal) {
                        ForEach(Goal.allCases, id: \.self) { g in
                            Text(verbatim: L.string(g.titleKey)).tag(g)
                        }
                    }
                    .pickerStyle(.menu)
                }
                Section("ai.level") {
                    Picker("ai.level", selection: $level) {
                        ForEach(ExperienceLevel.allCases, id: \.self) { l in
                            Text(verbatim: L.string(l.titleKey)).tag(l)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section {
                    Stepper(value: $daysPerWeek, in: 1...7) {
                        LabeledContent("ai.daysPerWeek") { Text(verbatim: "\(daysPerWeek)") }
                    }
                    Stepper(value: $sessionMinutes, in: 15...120, step: 5) {
                        LabeledContent("ai.sessionMinutes") { Text(verbatim: "\(sessionMinutes)") }
                    }
                    Stepper(value: $weeks, in: 1...16) {
                        LabeledContent("ai.weeks") { Text(verbatim: "\(weeks)") }
                    }
                }
                Section("ai.equipment") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(equipmentOptions, id: \.self) { option in
                                equipmentChip(option)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                Section("ai.focus") {
                    TextField("ai.focus", text: $focus)
                }
                Section("ai.limitations") {
                    TextField("ai.limitationsPlaceholder", text: $limitations, axis: .vertical)
                        .lineLimit(1...3)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.Palette.background.ignoresSafeArea())
            .navigationTitle("ai.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("common.close") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                PrimaryButton(title: "ai.buildPrompt", systemImage: "sparkles") {
                    showHandoff = true
                }
                .padding(Theme.Layout.screenPadding)
            }
            .sheet(isPresented: $showHandoff) {
                ClaudeHandoffView(prompt: generator.makePrompt(from: intake)) { dto in
                    PlanSaver.save(dto, source: .ai,
                                   language: localization.contentLanguageCode, into: context)
                    showHandoff = false
                    dismiss()
                }
            }
        }
    }

    private func equipmentChip(_ option: String) -> some View {
        let isOn = selectedEquipment.contains(option)
        return Button {
            if isOn { selectedEquipment.remove(option) } else { selectedEquipment.insert(option) }
        } label: {
            Text(option.capitalized)
                .font(Theme.Typography.caption)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundStyle(isOn ? Theme.Palette.onAccent : Theme.Palette.primaryText)
                .background {
                    if isOn {
                        Capsule().fill(Theme.Palette.accent)
                    } else {
                        Capsule().stroke(Theme.Palette.secondaryText.opacity(0.4), lineWidth: 1)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private var intake: PlanIntake {
        PlanIntake(
            goal: goal.rawValue,
            level: level.rawValue,
            daysPerWeek: daysPerWeek,
            sessionMinutes: sessionMinutes,
            weeks: weeks,
            equipment: Array(selectedEquipment),
            focusAreas: focus
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty },
            limitations: limitations.isEmpty ? nil : limitations,
            language: localization.contentLanguageCode
        )
    }
}
