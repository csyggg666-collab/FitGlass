import SwiftUI

/// Receives a plan payload handed back via the `fitglass://import` URL scheme — e.g.
/// from an Apple Shortcut that ran Claude's "Ask Claude" action and called back.
/// The AI-generate screen observes `incomingPlanJSON` and parses it.
@Observable
@MainActor
final class DeepLinkInbox {
    var incomingPlanJSON: String?

    func handle(_ url: URL) {
        guard url.scheme == "fitglass", url.host == "import" else { return }
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
        if let json = items?.first(where: { $0.name == "json" })?.value {
            incomingPlanJSON = json
        } else if let text = items?.first(where: { $0.name == "text" })?.value {
            incomingPlanJSON = text
        }
    }
}
