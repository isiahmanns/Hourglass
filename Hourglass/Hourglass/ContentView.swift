import SwiftUI

struct ContentView: View {
    private var viewModel = ViewModel()

    var body: some View {
        VStack(alignment: .center, spacing: 30.0) {
            Logo()

            TimerGrid(viewModel: viewModel)

            SettingsButton()
        }
        .padding(40)
        .background(Color.background)
        .cornerRadius(50)
    }
}

private struct TimerGrid: View {
    @StateObject var viewModel: ViewModel
    let ySpacing = 20.0
    let xSpacing = 26.0

    var body: some View {
        HStack(alignment: .center, spacing: xSpacing) {
            VStack(alignment: .center, spacing: ySpacing) {
                Header(content: "Focus")

                if let focusTimerModels = viewModel.timerModels[.focus] {
                    ForEach(Array(focusTimerModels.enumerated()), id: \.element) { index, model in
                        TimerButton(value: model.length, state: model.state) {
                            viewModel.didTapTimer(from: model.category, index: index)
                        }
                    }
                }
            }

            VStack(alignment: .center, spacing: ySpacing) {
                Header(content: "Break")

                if let restTimerModels = viewModel.timerModels[.rest] {
                    ForEach(Array(restTimerModels.enumerated()), id: \.element) { index, model in
                        TimerButton(value: model.length, state: model.state) {
                            viewModel.didTapTimer(from: model.category, index: index)
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
