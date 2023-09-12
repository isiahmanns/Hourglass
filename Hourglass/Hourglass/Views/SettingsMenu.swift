import SwiftUI

struct SettingsMenu: View {
    let viewModel: ViewModel
    let size: CGFloat = 24

    /**
     Note: These default values are not persisted.
     - They serve as temporary values to display in the Menu, that sync up with default values
       consumed by the ViewModel via SettingsManager.
     - The UserDefaults cache gets written to only when selecting new options via the Menu.
     */

    @AppStorage(SettingsKeys.soundIsEnabled.rawValue)
    var soundIsEnabled: Bool = Constants.soundIsEnabled

    @AppStorage(SettingsKeys.restWarningThreshold.rawValue)
    var restWarningThreshold: Int = Constants.restWarningThreshold

    @AppStorage(SettingsKeys.enforceRestThreshold.rawValue)
    var enforceRestThreshold: Int = Constants.enforceRestThreshold

    @AppStorage(SettingsKeys.getBackToWork.rawValue)
    var getBackToWorkIsEnabled: Bool = Constants.getBackToWorkIsEnabled

    var body: some View {
        Menu {
            Section {
                Button("About Hourglass") {
                    viewModel.showAboutWindow()
                }
            }
            Section {
                Button("Statistics") {
                    viewModel.showStatisticsWindow()
                }
                Section("Options") {
                    Toggle("Sound", isOn: $soundIsEnabled)
                    // TODO: - Implement fullscreen on rest (#14)
                    // Toggle("Fullscreen on Rest", isOn: .constant(true))
                }
                Section("Rest Settings") {
                    Button("Edit Rest Settings") {
                        viewModel.viewState.showRestSettingsFlow.toggle()
                    }

                    let restWarningThreshold = restWarningThreshold > 0 ? "\(restWarningThreshold)fb" : "Off"
                    DetailText("Rest Reminder: \(restWarningThreshold)")

                    let enforceRestThreshold = enforceRestThreshold > 0 ? "\(enforceRestThreshold)fb" : "Off"
                    DetailText("Enforce Rest: \(enforceRestThreshold)")

                    let getBackToWorkIsEnabled = getBackToWorkIsEnabled ? "On" : "Off"
                    DetailText("Get Back To Work: \(getBackToWorkIsEnabled)")
                }
            }
            Section {
                Button("Quit Hourglass") {
                    NSApplication.shared.terminate(self)
                }
            }
        } label: {
            Image(systemName: "gearshape.fill")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .foregroundColor(Color.Hourglass.onBackgroundSecondary)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("settings-button")
    }
}

private struct DetailText: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.system(size: 10))
    }
}
