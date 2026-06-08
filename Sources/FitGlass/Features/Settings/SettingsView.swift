import SwiftUI

struct SettingsView: View {
    @Environment(LocalizationManager.self) private var localization

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(selection: languageBinding) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.titleKey).tag(language)
                        }
                    } label: {
                        Text("settings.language")
                    }
                } header: {
                    Text("settings.language")
                } footer: {
                    Text("settings.languageFooter")
                }

                Section("settings.aiGenerator") {
                    Label("settings.generator.claude", systemImage: "sparkles")
                        .foregroundStyle(Theme.Palette.primaryText)
                    Label("settings.generator.onDevice", systemImage: "cpu")
                        .foregroundStyle(Theme.Palette.secondaryText)
                }

                Section("settings.about") {
                    LabeledContent("settings.version") {
                        Text(verbatim: appVersion)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.Palette.background.ignoresSafeArea())
            .navigationTitle("settings.title")
        }
    }

    private var languageBinding: Binding<AppLanguage> {
        Binding(
            get: { localization.language },
            set: { localization.setLanguage($0) }
        )
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
