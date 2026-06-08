import SwiftUI
import UIKit
import PlanParsingKit

/// The reliable, no-API Claude round-trip: show a strict prompt, let the user send it
/// to the Claude app (share sheet / copy + open), then paste the JSON reply back here
/// to be parsed. Shared by both the AI-generate and import flows.
struct ClaudeHandoffView: View {
    let prompt: String
    let onParsed: (TrainingPlanDTO) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(DeepLinkInbox.self) private var inbox

    @State private var pasted = ""
    @State private var errorMessage: String?
    @State private var statusMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    steps
                    promptBox
                    handoffActions
                    pasteSection
                    if let statusMessage {
                        Text(verbatim: statusMessage)
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Palette.accent)
                    }
                    if let errorMessage {
                        Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Palette.danger)
                    }
                }
                .padding(Theme.Layout.screenPadding)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            .screenBackground()
            .navigationTitle("ai.howItWorks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("common.close") { dismiss() }
                }
            }
            .onAppear { consumeInbox() }
            .onChange(of: inbox.incomingPlanJSON) { _, _ in consumeInbox() }
        }
    }

    private var steps: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("ai.step1")
                Text("ai.step2")
                Text("ai.step3")
            }
            .font(Theme.Typography.body)
            .foregroundStyle(Theme.Palette.primaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var promptBox: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView {
                Text(verbatim: prompt)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(Theme.Palette.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 180)
            .padding(Theme.Layout.cardSpacing)
            .glassCard(cornerRadius: 18)

            Button {
                copyPrompt()
            } label: {
                Label("ai.copyPrompt", systemImage: "doc.on.doc")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Palette.accent)
            }
        }
    }

    private var handoffActions: some View {
        GlassEffectContainer(spacing: 12) {
            HStack(spacing: 12) {
                ShareLink(item: prompt) {
                    HandoffLabel(titleKey: "ai.sharePrompt", systemImage: "square.and.arrow.up")
                }
                Button { openClaude() } label: {
                    HandoffLabel(titleKey: "ai.openClaude", systemImage: "arrow.up.forward.app")
                }
            }
        }
    }

    private var pasteSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $pasted)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 120)
                    .foregroundStyle(Theme.Palette.primaryText)
                    .padding(8)
                    .glassCard(cornerRadius: 16)
                if pasted.isEmpty {
                    Text("ai.pastePlaceholder")
                        .font(Theme.Typography.body)
                        .foregroundStyle(Theme.Palette.secondaryText)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 16)
                        .allowsHitTesting(false)
                }
            }
            Button {
                pasted = UIPasteboard.general.string ?? pasted
            } label: {
                Label("ai.pasteFromClipboard", systemImage: "clipboard")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Palette.accent)
            }
            PrimaryButton(title: "ai.buildFromReply", systemImage: "checkmark.circle.fill") {
                build()
            }
        }
    }

    // MARK: - Actions

    private func consumeInbox() {
        if let json = inbox.incomingPlanJSON {
            pasted = json
            inbox.incomingPlanJSON = nil
        }
    }

    private func copyPrompt() {
        UIPasteboard.general.string = prompt
        statusMessage = L.string("ai.promptCopied")
    }

    private func openClaude() {
        UIPasteboard.general.string = prompt
        guard let url = URL(string: "claude://") else { return }
        if UIApplication.shared.canOpenURL(url) {
            openURL(url)
            statusMessage = L.string("ai.promptCopied")
        } else {
            statusMessage = L.string("ai.claudeMissing")
        }
    }

    private func build() {
        errorMessage = nil
        do {
            onParsed(try PlanJSONParser.parse(pasted))
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? L.string("ai.parseError")
        }
    }
}

private struct HandoffLabel: View {
    let titleKey: LocalizedStringKey
    let systemImage: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
            Text(titleKey)
        }
        .font(Theme.Typography.headline)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .foregroundStyle(Theme.Palette.primaryText)
        .glassSurface(Capsule(), interactive: true)
    }
}
