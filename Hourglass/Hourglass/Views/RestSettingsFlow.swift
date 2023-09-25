import SwiftUI

struct RestSettingsFlow: View {
    let viewModel: ViewModel
    let settingsManager: SettingsManager

    @State var restWarningThreshold: SettingsThreshold
    @State var enforceRestThreshold: SettingsThreshold
    @State var getBackToWorkIsEnabled: Bool

    init(viewModel: ViewModel, settingsManager: SettingsManager) {
        self.viewModel = viewModel
        self.settingsManager = settingsManager
        self.restWarningThreshold = settingsManager.getRestWarningThreshold()
        self.enforceRestThreshold = settingsManager.getEnforceRestThreshold()
        self.getBackToWorkIsEnabled = settingsManager.getGetBackToWorkIsEnabled()
    }

    var body: some View {
        VStack {
            // TODO: - Think about reducing these options to 3
            Form {
                Picker("Rest Reminder:", selection: $restWarningThreshold) {
                    Text("Off").tag(SettingsThreshold.off)
                    Text("1 focus block").tag(SettingsThreshold.k1)
                    Text("2 focus blocks").tag(SettingsThreshold.k2)
                    Text("3 focus blocks").tag(SettingsThreshold.k3)
                    Text("4 focus blocks").tag(SettingsThreshold.k4)
                    Text("5 focus blocks").tag(SettingsThreshold.k5)
                }
                .onChange(of: restWarningThreshold) { _ in
                    if !dataIsValid { enforceRestThreshold = .off }
                }
                .help(Copy.restReminderHelp)
                .accessibilityIdentifier("rest-reminder-picker")

                Picker("Enforce Rest:", selection: $enforceRestThreshold) {
                    Text("Off").tag(SettingsThreshold.off)
                    Text("1 focus block").tag(SettingsThreshold.k1)
                    Text("2 focus blocks").tag(SettingsThreshold.k2)
                    Text("3 focus blocks").tag(SettingsThreshold.k3)
                    Text("4 focus blocks").tag(SettingsThreshold.k4)
                    Text("5 focus blocks").tag(SettingsThreshold.k5)
                    Text("6 focus blocks").tag(SettingsThreshold.k6)
                }
                .onChange(of: enforceRestThreshold) { _ in
                    if !dataIsValid { restWarningThreshold = .off }
                }
                .help(Copy.enforceRestHelp)
                .accessibilityIdentifier("enforce-rest-picker")

                Toggle("Get Back to Work", isOn: $getBackToWorkIsEnabled)
                    .help(Copy.getBackToWorkHelp)
                    .accessibilityIdentifier("get-back-to-work-toggle")

                Button("Close") {
                    defer {
                        // TODO: - Remove SettingsManager direct dependency and access via viewModel
                        settingsManager.setRestWarningThreshold(restWarningThreshold)
                        settingsManager.setEnforceRestThreshold(enforceRestThreshold)
                        settingsManager.setGetBackToWork(isEnabled: getBackToWorkIsEnabled)
                    }
                    viewModel.viewState.showRestSettingsFlow.toggle()
                }
            }

            Spacer(minLength: 10)

            Text(Copy.footnote)
                .font(.system(.footnote))
        }
        .font(.system(.body))
        .padding([.leading, .top, .trailing], 20)
        .padding(.bottom, 10)
    }

    private var dataIsValid: Bool {
        let (a, b) = (restWarningThreshold, enforceRestThreshold)
        if [a, b].allSatisfy({$0 != .off}) {
            return a.rawValue < b.rawValue
        }

        return true
    }
}

private extension RestSettingsFlow {
    enum Copy {
        static let restReminderHelp = "Reminds you to take a rest after completing (x) consecutive focus blocks. Must be less than the enforce rest threshold."
        static let enforceRestHelp = "Forces you to take a rest after completing (x) consecutive focus blocks. Must be greater than the rest reminder threshold."
        static let getBackToWorkHelp = "Forces you to get back to work after completing a rest block."
        static let footnote = "Note: Hover to see settings descriptions."
    }
}
