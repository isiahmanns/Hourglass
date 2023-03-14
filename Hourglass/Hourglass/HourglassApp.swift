import SwiftUI

#if DEBUG || RELEASE
@main
struct HourglassApp: App {
    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .font(Font.poppins)
        } label: {
            HStack {
                Image(systemName: "hourglass")
                Text("<timestamp>")
            }
            .accessibilityElement(children: .ignore)
            .accessibilityIdentifier("menu-bar-select")
        }
        .menuBarExtraStyle(.window)
    }
}

#elseif CITESTING
@main
struct HourglassApp: App {
    var body: some Scene {
        // Note: Only need to build target for *unit testing* on CI 12.6.3
        WindowGroup {}
    }
}
#endif
