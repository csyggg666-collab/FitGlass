import SwiftUI

/// Root tab bar. On iOS 26 the system tab bar renders with Liquid Glass automatically.
struct RootTabView: View {
    var body: some View {
        TabView {
            Tab("tab.home", systemImage: "house.fill") {
                HomeView()
            }
            Tab("tab.library", systemImage: "square.stack.3d.up.fill") {
                LibraryView()
            }
            Tab("tab.progress", systemImage: "chart.bar.fill") {
                ProgressDashboardView()
            }
            Tab("tab.settings", systemImage: "gearshape.fill") {
                SettingsView()
            }
        }
    }
}
