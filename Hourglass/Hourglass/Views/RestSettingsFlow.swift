import SwiftUI

struct RestSettingsFlow: View {
    let viewModel: ViewModel

    @AppStorage(SettingsKeys.restWarningThreshold.rawValue)
    var restWarningThreshold: Int = Constants.restWarningThreshold

    @AppStorage(SettingsKeys.enforceRestThreshold.rawValue)
    var enforceRestThreshold: Int = Constants.enforceRestThreshold

    @AppStorage(SettingsKeys.getBackToWork.rawValue)
    var getBackToWorkIsEnabled: Bool = Constants.getBackToWorkIsEnabled

    var body: some View {
        Form {
            Picker("Rest Reminder:", selection: $restWarningThreshold) {
                Text("Off").tag(-1)
                Text("15").tag(15)
                Text("20").tag(20)
                Text("30").tag(30)
                Text("40").tag(40)
                Text("50").tag(50)
                Text("60").tag(60)
            }
            Picker("Enforce Rest:", selection: $enforceRestThreshold) {
                Text("Off").tag(-1)
                Text("15").tag(15)
                Text("20").tag(20)
                Text("30").tag(30)
                Text("40").tag(40)
                Text("50").tag(50)
                Text("60").tag(60)
            }
            Toggle("Get Back to Work", isOn: $getBackToWorkIsEnabled)

            Button("Close") {
                viewModel.viewState.showRestSettingsFlow.toggle()
            }
        }
        .padding(20)
        .font(.system(.body))
    }
}
