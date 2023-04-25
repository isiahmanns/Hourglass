import SwiftUI

struct AlertView: View {
    @StateObject var viewModel: ViewModel

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
            .alert(Copy.timerCompleteAlert, isPresented: $viewModel.viewState.showTimerCompleteAlert) {}
            .alert(Copy.timerResetAlert, isPresented: $viewModel.viewState.showTimerResetAlert) {}
            .alert(Copy.restWarningAlert, isPresented: $viewModel.viewState.showRestWarningAlert) {}
            .alert(Copy.enforceRestAlert, isPresented: $viewModel.viewState.showEnforceRestAlert) {}
    }
}

private extension AlertView {
    enum Copy {
        static let startNewTimerDialogPrompt = "Are you sure you want to start a new timer?"
        static let startNewTimerDialogConfirm = "Start timer"
        static let startNewTimerDialogCancel = "Cancel"
        static let timerCompleteAlert = Constants.timerCompleteAlert
        static let timerResetAlert = "Timer has been reset"
        static let restWarningAlert = Constants.restWarningAlert
        static let enforceRestAlert = "You've been focused for a while now. Let your mind rest."
    }
}
