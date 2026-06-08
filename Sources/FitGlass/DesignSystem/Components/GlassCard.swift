import SwiftUI

/// Padded content sitting on a Liquid Glass card.
struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = Theme.Layout.cardRadius
    var tint: Color? = nil
    var padding: CGFloat = Theme.Layout.cardSpacing
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .glassCard(cornerRadius: cornerRadius, tint: tint)
    }
}
