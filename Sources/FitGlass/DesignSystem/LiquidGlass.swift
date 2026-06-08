import SwiftUI

// Central wrappers for iOS 26 Liquid Glass so glass styling stays consistent and
// is defined in one place. Group several `glassSurface` views inside a
// `GlassEffectContainer` to get blending + morphing between them.
extension View {

    /// Nike-style floating surface backed by Liquid Glass.
    func glassSurface(_ shape: some Shape = Capsule(),
                      tint: Color? = nil,
                      interactive: Bool = false) -> some View {
        var glass: Glass = .regular
        if let tint { glass = glass.tint(tint) }
        if interactive { glass = glass.interactive() }
        return glassEffect(glass, in: shape)
    }

    /// Rounded-rectangle glass card surface with the standard corner radius.
    func glassCard(cornerRadius: CGFloat = Theme.Layout.cardRadius,
                   tint: Color? = nil) -> some View {
        glassSurface(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous), tint: tint)
    }

    /// Standard near-black screen backdrop.
    func screenBackground() -> some View {
        background(Theme.Palette.background.ignoresSafeArea())
    }
}
