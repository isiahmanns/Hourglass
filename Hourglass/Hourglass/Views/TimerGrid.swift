import SwiftUI

struct TimerGrid: View {
    let viewModel: ViewModel
    let ySpacing = 16.0
    let xSpacing = 26.0

    var body: some View {
        HStack(alignment: .center, spacing: xSpacing) {
            VStack(alignment: .center, spacing: ySpacing) {
                Header(content: Copy.focusHeader)

                ForEach(viewModel.timerModels.filterByCategory(.focus).sortBySize()) { model in
                    TimerButton(model: model) {
                        viewModel.didTapTimer(from: model)
                    }
                }
            }
            .frame(width: TimerButton.size)

            VStack(alignment: .center, spacing: ySpacing) {
                Header(content: Copy.restHeader)

                ForEach(viewModel.timerModels.filterByCategory(.rest).sortBySize()) { model in
                    TimerButton(model: model) {
                        viewModel.didTapTimer(from: model)
                    }
                }
            }
            .frame(width: TimerButton.size)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("timer-grid")
    }
}

private extension TimerGrid {
    enum Copy {
        static let focusHeader = "Focus"
        static let restHeader = "Rest"
    }
}

private struct Header: View {
    let content: String

    var body: some View {
        Text(content)
            .fixedSize()
            .foregroundColor(Color.Hourglass.onBackgroundPrimary)
    }
}
