import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        VStack(alignment: .center, spacing: 30.0) {
            Logo()

            TimerGrid(viewModel: viewModel)

            SettingsButton()
        }
        .padding(40)
        .background(Color.background)
        .cornerRadius(50)
        .alert("Start a new timer?", isPresented: $viewModel.showCancelTimerAlert) {
            Button("Button", role: .none) {}
        }
        .alert("Timer completed!", isPresented: $viewModel.showTimerCompleteAlert) {
            Button("Button", role: .none) {}
        }
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
    }
}

private struct Logo: View {
    let size: Double = 40

    var body: some View {
        Image("hourglassLogo")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
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
    var body: some View {
        Image(systemName: "gearshape.fill")
            .imageScale(.large)
            .foregroundColor(Color.onBackgroundSecondary)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .font(Font.poppins)
    }
}
