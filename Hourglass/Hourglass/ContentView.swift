import SwiftUI

struct ContentView: View {
    private var viewModel = ViewModel()

    var body: some View {
        ZStack {
            AlertWrapper(viewModel: viewModel)

            VStack(alignment: .center, spacing: 30.0) {
                Logo()

                TimerGrid(viewModel: viewModel)

                SettingsButton()
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
    var viewModel: ViewModel
    let ySpacing = 20.0
    let xSpacing = 26.0

    var body: some View {
        HStack(alignment: .center, spacing: xSpacing) {
            VStack(alignment: .center, spacing: ySpacing) {
                Header(content: "Focus")

                if let focusTimerModels = viewModel.timerModels[.focus] {
                    ForEach(focusTimerModels) { model in
                        TimerButton(value: model.length,
                                    //TODO: - pass length binding to button view
                                    state: model.state,
                                    publisher: model.$state.eraseToAnyPublisher()) {
                            viewModel.didTapTimer(from: model)
                        }
                    }
                }
            }

            VStack(alignment: .center, spacing: ySpacing) {
                Header(content: "Break")

                if let restTimerModels = viewModel.timerModels[.rest] {
                    ForEach(restTimerModels) { model in
                        TimerButton(value: model.length,
                                    state: model.state,
                                    publisher: model.$state.eraseToAnyPublisher()) {
                            viewModel.didTapTimer(from: model)
                        }
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
    @AppStorage(SettingsKeys.notificationStyle.rawValue)
    var notificationStyle: NotificationStyle = .popup

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
                    Menu("Focus Timers") {
                        Picker("Small", selection: .constant(true)) {
                            Text("15")
                            Text("20")
                        }
                        Picker("Medium", selection: .constant(true)) {
                            Text("25")
                            Text("30")
                        }
                        Picker("Large", selection: .constant(true)) {
                            Text("35")
                            Text("40")
                        }
                    }.pickerStyle(.inline)
                    Menu("Rest Timers") {
                        Picker("Small", selection: .constant(true)) {
                            Text("3")
                            Text("5")
                        }
                        Picker("Medium", selection: .constant(true)) {
                            Text("10")
                            Text("15")
                        }
                        Picker("Large", selection: .constant(true)) {
                            Text("20")
                            Text("25")
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
