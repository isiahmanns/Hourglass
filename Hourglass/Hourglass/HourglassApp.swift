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

        Window("Options", id: "options-window") {
            Form {
                Text("asdf")
                Slider(value: .constant(0.5))
                    .frame(width: 300)
            }
            .padding(40)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.top)
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
