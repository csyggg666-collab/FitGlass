import SwiftUI

/// Filled, high-emphasis CTA (volt accent, black text) — the primary Nike-style action.
struct PrimaryButton: View {
    let title: LocalizedStringKey
    var systemImage: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage { Image(systemName: systemImage) }
                Text(title)
            }
            .font(Theme.Typography.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .foregroundStyle(Theme.Palette.onAccent)
        .background(Theme.Palette.accent, in: Capsule())
        .contentShape(Capsule())
    }
}

/// Secondary action on a Liquid Glass capsule.
struct GlassButton: View {
    let title: LocalizedStringKey
    var systemImage: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage { Image(systemName: systemImage) }
                Text(title)
            }
            .font(Theme.Typography.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .foregroundStyle(Theme.Palette.primaryText)
        .glassSurface(Capsule(), interactive: true)
    }
}
