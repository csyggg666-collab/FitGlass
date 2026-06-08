import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import PlanParsingKit

struct ImportView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(LocalizationManager.self) private var localization

    @State private var pickerShown = false
    @State private var extractedText = ""
    @State private var errorMessage: String?
    @State private var showHandoff = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("import.howto")
                        .font(Theme.Typography.body)
                        .foregroundStyle(Theme.Palette.secondaryText)

                    PrimaryButton(title: "import.chooseFile", systemImage: "doc.badge.plus") {
                        pickerShown = true
                    }
                    Text("import.supported")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Palette.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .center)

                    if let errorMessage {
                        Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Palette.danger)
                    }

                    if !extractedText.isEmpty {
                        SectionHeader(title: "import.extractedText")
                        Text(verbatim: extractedText)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundStyle(Theme.Palette.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(maxHeight: 260)
                            .padding(Theme.Layout.cardSpacing)
                            .glassCard(cornerRadius: 18)

                        PrimaryButton(title: "import.structure", systemImage: "sparkles") {
                            showHandoff = true
                        }
                    }
                }
                .padding(Theme.Layout.screenPadding)
            }
            .scrollIndicators(.hidden)
            .screenBackground()
            .navigationTitle("import.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("common.close") { dismiss() }
                }
            }
            .fileImporter(isPresented: $pickerShown,
                          allowedContentTypes: allowedTypes,
                          allowsMultipleSelection: false) { handlePick($0) }
            .sheet(isPresented: $showHandoff) {
                ClaudeHandoffView(
                    prompt: PromptBuilder.structureImportedTextPrompt(
                        rawText: extractedText,
                        language: localization.contentLanguageCode
                    )
                ) { dto in
                    PlanSaver.save(dto, source: .imported,
                                   language: localization.contentLanguageCode, into: context)
                    showHandoff = false
                    dismiss()
                }
            }
        }
    }

    private var allowedTypes: [UTType] {
        var types: [UTType] = [.pdf]
        if let docx = UTType("org.openxmlformats.wordprocessingml.document") {
            types.append(docx)
        }
        return types
    }

    private func handlePick(_ result: Result<[URL], Error>) {
        errorMessage = nil
        guard let url = try? result.get().first else { return }
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }
        do {
            extractedText = try DocumentImporter.extractText(from: url)
        } catch {
            extractedText = ""
            errorMessage = L.string("import.failed")
        }
    }
}
