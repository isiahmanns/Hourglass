import SwiftUI

struct ContentView: View {
    private let viewModel = ViewModel()

    var body: some View {
        ZStack {
            AlertWrapper(viewModel: viewModel)

            VStack(alignment: .center, spacing: 30.0) {
                Logo()

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

private struct Logo: View {
    let size: Double = 40

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
    let focusTimerModels: [Timer.Model]
    let restTimerModels: [Timer.Model]

    init(viewModel: ViewModel) {
        self.focusTimerModels = viewModel.timerModels.filterByCategory(.focus)
        self.restTimerModels = viewModel.timerModels.filterByCategory(.rest)
    }

    @AppStorage(SettingsKeys.notificationStyle.rawValue)
    var notificationStyle: NotificationStyle = .popup

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
                Button("About") {
                    // open window
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
                    Toggle("Sound", isOn: .constant(true))
                    Toggle("Fullscreen on Rest", isOn: .constant(true))
                }
                Section("Timer Presets") {
                    // TODO: - If timer in progress while changing setting, prompt user to stop timer first. (use activeTimerModel) (#21)
                    Menu("Focus Timers") {
                        Picker("Small", selection: $timerFocusSmallPreset) {
                            Text("15").tag(15)
                            Text("20").tag(20)
                        }.onChange(of: timerFocusSmallPreset) { value in
                            focusTimerModels[0].length = value
                        }

                        Picker("Medium", selection: $timerFocusMediumPreset) {
                            Text("25").tag(25)
                            Text("30").tag(30)
                        }.onChange(of: timerFocusMediumPreset) { value in
                            focusTimerModels[1].length = value
                        }

                        Picker("Large", selection: $timerFocusLargePreset) {
                            Text("35").tag(35)
                            Text("40").tag(40)
                        }.onChange(of: timerFocusLargePreset) { value in
                            focusTimerModels[2].length = value
                        }
                    }.pickerStyle(.inline)
                    Menu("Rest Timers") {
                        Picker("Small", selection: $timerRestSmallPreset) {
                            Text("3").tag(3)
                            Text("5").tag(5)
                        }.onChange(of: timerRestSmallPreset) { value in
                            restTimerModels[0].length = value
                        }

                        Picker("Medium", selection: $timerRestMediumPreset) {
                            Text("10").tag(10)
                            Text("15").tag(15)
                        }.onChange(of: timerRestMediumPreset) { value in
                            restTimerModels[1].length = value
                        }

                        Picker("Large", selection: $timerRestLargePreset) {
                            Text("20").tag(20)
                            Text("25").tag(25)
                        }.onChange(of: timerRestLargePreset) { value in
                            restTimerModels[2].length = value
                        }
                    }
                    .pickerStyle(.inline)
                }
            }
            Section {
                Button("Quit") {
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .font(Font.poppins)
    }
}
