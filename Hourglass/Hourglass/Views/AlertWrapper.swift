import SwiftUI

struct AlertWrapper: View {
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
