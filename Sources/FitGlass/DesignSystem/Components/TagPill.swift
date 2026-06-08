import SwiftUI

/// Small rounded label — glass by default, or filled with the accent for emphasis.
struct TagPill: View {
    let text: LocalizedStringKey
    var style: Style = .glass

    enum Style { case glass, accent }

    var body: some View {
        Text(text)
            .font(Theme.Typography.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .foregroundStyle(style == .accent ? Theme.Palette.onAccent : Theme.Palette.primaryText)
            .modifier(PillBackground(style: style))
    }
}

private struct PillBackground: ViewModifier {
    let style: TagPill.Style
    func body(content: Content) -> some View {
        switch style {
        case .accent:
            content.background(Theme.Palette.accent, in: Capsule())
        case .glass:
            content.glassSurface(Capsule())
        }
    }
}
