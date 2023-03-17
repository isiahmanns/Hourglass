import SwiftUI

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
