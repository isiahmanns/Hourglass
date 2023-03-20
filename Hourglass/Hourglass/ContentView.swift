import SwiftUI

struct ContentView: View {
    // TODO: - Move views into separate files
    private let viewModel = ViewModel()

    var body: some View {
        ZStack {
            AlertWrapper(viewModel: viewModel)

            VStack(alignment: .center, spacing: 30.0) {
                Logo(size: 40)

                TimerGrid(viewModel: viewModel)

                SettingsButton(viewModel: viewModel)
            }
            .padding([.top, .bottom], 40)
            .padding([.leading, .trailing], 60)
            .background(Color.background)
        }
    }
}

private struct AlertWrapper: View {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .confirmationDialog("Are you sure you want to start a new timer?",
                                isPresented: $viewModel.viewState.showStartNewTimerDialog) {
                Button("Start timer", role: .none) {
                    viewModel.didReceiveStartNewTimerDialog(response: .yes)
                }
                Button("Cancel", role: .cancel) {
                    viewModel.didReceiveStartNewTimerDialog(response: .no)
                }
            }
            .alert("Time's up", isPresented: $viewModel.viewState.showTimerCompleteAlert) {}
            .alert("Timer has been reset.", isPresented: $viewModel.viewState.showTimerResetAlert) {}
    }
}

private struct TimerGrid: View {
    let viewModel: ViewModel
    let ySpacing = 20.0
    let xSpacing = 26.0

    var body: some View {
        HStack(alignment: .center, spacing: xSpacing) {
            VStack(alignment: .center, spacing: ySpacing) {
                Header(content: "Focus")

                ForEach(viewModel.timerModels.filterByCategory(.focus)) { model in
                    TimerButton(model: model) {
                        viewModel.didTapTimer(from: model)
                    }
                }
            }

            VStack(alignment: .center, spacing: ySpacing) {
                Header(content: "Break")

                ForEach(viewModel.timerModels.filterByCategory(.rest)) { model in
                    TimerButton(model: model) {
                        viewModel.didTapTimer(from: model)
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("timer-grid")
    }
}

struct Logo: View {
    let size: Double

    var body: some View {
        Image("hourglassLogo")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityIdentifier("hourglass-logo")
    }
}

private struct Header: View {
    let content: String

    var body: some View {
        Text(content)
            .foregroundColor(Color.onBackgroundPrimary)
    }
}

private struct SettingsButton: View {
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

    @Environment(\.openWindow) var openWindow

    var body: some View {
        Menu {
            Section {
                Button("About Hourglass") {
                    openWindow(id: Constants.aboutWindowId)
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
        viewModel.cancelTimerIfNeeded(timerModel)
        timerModel.length = length
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .font(Font.poppins)
    }
}
