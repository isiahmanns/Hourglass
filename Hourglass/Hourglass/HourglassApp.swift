import SwiftUI

@main
struct HourglassApp: App {
    @StateObject var timerManager = TimerManager.shared
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
                // TODO: - Make logo into symbol
                Image(systemName: "hourglass")

                let timeStamp = timerManager.timeStamp
                if timeStamp != Constants.timeStampZero {
                    Text(timeStamp)
                        // TODO: - This modifier doesn't seem to work. Switch to UIKit startup for custom menu bar label.
                        .monospacedDigit()
                }
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
