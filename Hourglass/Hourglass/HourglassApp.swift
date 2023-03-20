import SwiftUI

@main
struct HourglassApp: App {
    let timerManager = TimerManager.shared
    let userNotificationManager = UserNotificationManager.shared
    let settingsManager = SettingsManager.shared

    var body: some Scene {
        MenuBarExtra {
            let viewModel = ViewModel(timerManager: timerManager,
                                      userNotificationManager: userNotificationManager,
                                      settingsManager: settingsManager)

            ContentView(viewModel: viewModel)
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

        Window("About Hourglass", id: Constants.aboutWindowId) {
            AboutView()
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
    }
}
