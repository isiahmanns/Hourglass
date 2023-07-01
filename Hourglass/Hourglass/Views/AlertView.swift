import SwiftUI

struct AlertView: View {
    @StateObject var viewModel: ViewModel
    let settingsManager: SettingsManager

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .confirmationDialog(Copy.startNewTimerDialogPrompt,
                                isPresented: $viewModel.viewState.showStartNewTimerDialog) {
                Button(Copy.startNewTimerDialogConfirm, role: .none) {
                    viewModel.didReceiveStartNewTimerDialog(response: .yes)
                }
                Button(Copy.startNewTimerDialogCancel, role: .cancel) {
                    viewModel.didReceiveStartNewTimerDialog(response: .no)
                }
            }
            .alert(Copy.getBackToWorkAlert, isPresented: $viewModel.viewState.showGetBackToWorkAlert) {}
            .alert(Copy.timerResetAlert, isPresented: $viewModel.viewState.showTimerResetAlert) {}
            .alert(Copy.enforceRestAlert, isPresented: $viewModel.viewState.showEnforceRestAlert) {}
            .alert(Copy.restWarningAlert, isPresented: $viewModel.viewState.showRestWarningAlert) {}
            .alert(Copy.timerCompleteAlert, isPresented: $viewModel.viewState.showTimerCompleteAlert) {}
            .sheet(isPresented: $viewModel.viewState.showRestSettingsFlow) {
                RestSettingsFlow(viewModel: viewModel, settingsManager: settingsManager)
            }
    }
}

private extension AlertView {
    enum Copy {
        static let startNewTimerDialogPrompt = "Are you sure you want to start a new timer?"
        static let startNewTimerDialogConfirm = "Start timer"
        static let startNewTimerDialogCancel = "Cancel"
        static let timerCompleteAlert = Constants.timerCompleteAlert
        static let timerResetAlert = "Timer has been reset."
        static let restWarningAlert = Constants.restWarningAlert
        static let enforceRestAlert = "You've been focused for a while now. Take a rest."
        static let getBackToWorkAlert = "Get back to work!"
    }
}
