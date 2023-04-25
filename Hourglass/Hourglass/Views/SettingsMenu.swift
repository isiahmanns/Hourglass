import SwiftUI

struct SettingsMenu: View {
    let viewModel: ViewModel

    /**
     Note: These default values are not persisted.
     - They serve as temporary values to display in the Menu, that sync up with default values
       consumed by the ViewModel via SettingsManager.
     - The UserDefaults cache gets written to only when selecting new options via the Menu.
     */

    @AppStorage(SettingsKeys.notificationStyle.rawValue)
    var notificationStyle: NotificationStyle = .init(rawValue: Constants.notificationStyle)!

    @AppStorage(SettingsKeys.soundIsEnabled.rawValue)
    var soundIsEnabled: Bool = Constants.soundIsEnabled

    @AppStorage(SettingsKeys.TimerSetting.timerFocusSmall.rawValue)
    var timerFocusSmallPreset: Int = Constants.timerFocusSmallDefault

    @AppStorage(SettingsKeys.TimerSetting.timerFocusMedium.rawValue)
    var timerFocusMediumPreset: Int = Constants.timerFocusMediumDefault

    @AppStorage(SettingsKeys.TimerSetting.timerFocusLarge.rawValue)
    var timerFocusLargePreset: Int = Constants.timerFocusLargeDefault

    @AppStorage(SettingsKeys.TimerSetting.timerRestSmall.rawValue)
    var timerRestSmallPreset: Int = Constants.timerRestSmallDefault

    @AppStorage(SettingsKeys.TimerSetting.timerRestMedium.rawValue)
    var timerRestMediumPreset: Int = Constants.timerRestMediumDefault

    @AppStorage(SettingsKeys.TimerSetting.timerRestLarge.rawValue)
    var timerRestLargePreset: Int = Constants.timerRestLargeDefault

    @AppStorage(SettingsKeys.restWarningThreshold.rawValue)
    var restWarningThreshold: Int = Constants.restWarningThresholdDefault

    @AppStorage(SettingsKeys.enforceRestThreshold.rawValue)
    var enforceRestThreshold: Int = Constants.enforceRestThresholdDefault

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
                    // open window
                }
                Section("Options") {
                    Picker("Notification Style", selection: $notificationStyle) {
                        Text("Menu Bar Popup").tag(NotificationStyle.popup)
                        Text("Notification Banner").tag(NotificationStyle.banner)
                    }
                    Toggle("Sound", isOn: $soundIsEnabled)
                    Toggle("Fullscreen on Rest", isOn: .constant(true))
                }
                Section("Timer Presets") {
                    let focusTimerModels = viewModel.timerModels.filterByCategory(.focus)
                    let restTimerModels = viewModel.timerModels.filterByCategory(.rest)

                    Menu("Focus Timers") {
                        Picker("Small", selection: $timerFocusSmallPreset) {
                            Text("15").tag(15)
                            Text("20").tag(20)
                        }.onChange(of: timerFocusSmallPreset) { value in
                            handleTimerPresetSelection(value, for: focusTimerModels[0])
                        }

                        Picker("Medium", selection: $timerFocusMediumPreset) {
                            Text("25").tag(25)
                            Text("30").tag(30)
                        }.onChange(of: timerFocusMediumPreset) { value in
                            handleTimerPresetSelection(value, for: focusTimerModels[1])
                        }

                        Picker("Large", selection: $timerFocusLargePreset) {
                            Text("35").tag(35)
                            Text("40").tag(40)
                        }.onChange(of: timerFocusLargePreset) { value in
                            handleTimerPresetSelection(value, for: focusTimerModels[2])
                        }
                    }.pickerStyle(.inline)
                    Menu("Rest Timers") {
                        Picker("Small", selection: $timerRestSmallPreset) {
                            Text("3").tag(3)
                            Text("5").tag(5)
                        }.onChange(of: timerRestSmallPreset) { value in
                            handleTimerPresetSelection(value, for: restTimerModels[0])
                        }

                        Picker("Medium", selection: $timerRestMediumPreset) {
                            Text("10").tag(10)
                            Text("15").tag(15)
                        }.onChange(of: timerRestMediumPreset) { value in
                            handleTimerPresetSelection(value, for: restTimerModels[1])
                        }

                        Picker("Large", selection: $timerRestLargePreset) {
                            Text("20").tag(20)
                            Text("25").tag(25)
                        }.onChange(of: timerRestLargePreset) { value in
                            handleTimerPresetSelection(value, for: restTimerModels[2])
                        }
                    }
                    .pickerStyle(.inline)
                }
                Section("Reminders") {
                    Picker("Rest Warning", selection: $restWarningThreshold) {
                        Text("Off").tag(0)
                        Text("15").tag(15)
                        Text("20").tag(20)
                        Text("30").tag(30)
                        Text("40").tag(40)
                        Text("50").tag(50)
                        Text("60").tag(60)
                    }
                    Picker("Enforce Rest", selection: $enforceRestThreshold) {
                        Text("Off").tag(0)
                        Text("15").tag(15)
                        Text("20").tag(20)
                        Text("30").tag(30)
                        Text("40").tag(40)
                        Text("50").tag(50)
                        Text("60").tag(60)
                    }
                    Toggle("Get Back to Work", isOn: $getBackToWorkIsEnabled)
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
                .foregroundColor(Color.onBackgroundSecondary)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("settings-button")
    }

    private func handleTimerPresetSelection(_ length: Int, for timerModel: Timer.Model) {
        viewModel.didChangeTimerPreset(for: timerModel)
        timerModel.length = length
    }
}
