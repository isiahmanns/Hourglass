import SwiftUI

struct SettingsMenu: View {
    let viewModel: ViewModel

    /**
     Note: These default values are not persisted.
     - They serve as temporary values to display in the Menu, that sync up with default values
       consumed by the ViewModel via SettingsManager.
     - The UserDefaults cache gets written to only when selecting new options via the Menu.
     */

    // TODO: - Remove timer settings
    @AppStorage(SettingsKeys.soundIsEnabled.rawValue)
    var soundIsEnabled: Bool = Constants.soundIsEnabled

    @AppStorage(SettingsKeys.TimerSetting.timerFocusSmall.rawValue)
    var timerFocusSmallPreset: Int = Constants.timerFocusSmall

    @AppStorage(SettingsKeys.TimerSetting.timerFocusMedium.rawValue)
    var timerFocusMediumPreset: Int = Constants.timerFocusMedium

    @AppStorage(SettingsKeys.TimerSetting.timerFocusLarge.rawValue)
    var timerFocusLargePreset: Int = Constants.timerFocusLarge

    @AppStorage(SettingsKeys.TimerSetting.timerRestSmall.rawValue)
    var timerRestSmallPreset: Int = Constants.timerRestSmall

    @AppStorage(SettingsKeys.TimerSetting.timerRestMedium.rawValue)
    var timerRestMediumPreset: Int = Constants.timerRestMedium

    @AppStorage(SettingsKeys.TimerSetting.timerRestLarge.rawValue)
    var timerRestLargePreset: Int = Constants.timerRestLarge

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
                Section("Timer Presets") {
                    Menu("Focus Timers") {
                        Picker("Small", selection: $timerFocusSmallPreset) {
                            Text("15 minutes").tag(15)
                            Text("20 minutes").tag(20)
                        }

                        Picker("Medium", selection: $timerFocusMediumPreset) {
                            Text("25 minutes").tag(25)
                            Text("30 minutes").tag(30)
                        }

                        Picker("Large", selection: $timerFocusLargePreset) {
                            Text("35 minutes").tag(35)
                            Text("40 minutes").tag(40)
                        }
                    }.pickerStyle(.inline)
                    Menu("Rest Timers") {
                        Picker("Small", selection: $timerRestSmallPreset) {
                            Text("3 minutes").tag(3)
                            Text("5 minutes").tag(5)
                        }

                        Picker("Medium", selection: $timerRestMediumPreset) {
                            Text("10 minutes").tag(10)
                            Text("15 minutes").tag(15)
                        }

                        Picker("Large", selection: $timerRestLargePreset) {
                            Text("20 minutes").tag(20)
                            Text("25 minutes").tag(25)
                        }
                    }
                    .pickerStyle(.inline)
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
                .imageScale(.large)
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
