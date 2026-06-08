import SwiftUI
import SwiftData

@main
struct FitGlassApp: App {
    @State private var localization = LocalizationManager()
    @State private var deepLinks = DeepLinkInbox()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(localization)
                .environment(deepLinks)
                .environment(\.locale, localization.locale)
                .id(localization.refreshToken)          // rebuild the tree on language change
                .tint(Theme.Palette.accent)
                .preferredColorScheme(.dark)
                .task { SampleData.seedIfNeeded(SharedStore.container.mainContext) }
                .onOpenURL { deepLinks.handle($0) }
        }
        .modelContainer(SharedStore.container)
    }
}
