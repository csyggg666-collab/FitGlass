import SwiftUI

/// Full-bleed gradient header with a big bold title, Nike-cover style.
/// Uses a gradient + faint SF Symbol as a stand-in for real hero imagery
/// (drop a photo in `Assets.xcassets` and swap the `Image` later).
struct HeroHeader: View {
    let title: LocalizedStringKey
    var subtitle: LocalizedStringKey? = nil
    var systemImage: String = "figure.strengthtraining.traditional"
    var height: CGFloat = 300

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [Theme.Palette.accent.opacity(0.55), Theme.Palette.background],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            Image(systemName: systemImage)
                .font(.system(size: 150, weight: .black))
                .foregroundStyle(.white.opacity(0.10))
                .offset(x: 70, y: 10)
            VStack(alignment: .leading, spacing: 8) {
                if let subtitle {
                    Text(subtitle)
                        .font(Theme.Typography.caption)
                        .textCase(.uppercase)
                        .foregroundStyle(Theme.Palette.primaryText.opacity(0.85))
                }
                Text(title)
                    .font(Theme.Typography.display(42))
                    .foregroundStyle(.white)
                    .lineLimit(2)
            }
            .padding(Theme.Layout.screenPadding)
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
    }
}
