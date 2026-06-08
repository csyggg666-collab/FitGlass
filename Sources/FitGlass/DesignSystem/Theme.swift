import SwiftUI

/// Nike-Training-flavoured visual language: near-black canvas, off-white type,
/// a single high-energy "volt" accent (the asset `AccentColor`), heavy rounded display fonts.
enum Theme {
    enum Palette {
        static let background = Color(red: 0.04, green: 0.04, blue: 0.05)
        static let elevated = Color(red: 0.09, green: 0.09, blue: 0.11)
        static let primaryText = Color(white: 0.97)
        static let secondaryText = Color(white: 0.62)
        static let accent = Color.accentColor
        static let onAccent = Color.black
        static let danger = Color(red: 1.0, green: 0.32, blue: 0.32)
    }

    enum Layout {
        static let screenPadding: CGFloat = 20
        static let cardRadius: CGFloat = 24
        static let cardSpacing: CGFloat = 16
        static let sectionSpacing: CGFloat = 28
    }

    enum Typography {
        static func display(_ size: CGFloat) -> Font { .system(size: size, weight: .heavy, design: .rounded) }
        static let largeTitle = Font.system(size: 34, weight: .heavy, design: .rounded)
        static let title = Font.system(size: 22, weight: .bold, design: .rounded)
        static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 16, weight: .regular)
        static let caption = Font.system(size: 13, weight: .medium)
    }
}
