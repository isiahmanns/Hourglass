import SwiftUI

struct TimerCategoryToggle: View {
    let viewModel: ViewModel
    @StateObject var presenterModel: PresenterModel

    var body: some View {
        let containerPadding: CGFloat = 4

        ZStack {
            ZStack {
                Capsule()
                    .fill(Color.Hourglass.toggleSelection)
                    .frame(width: TimerCategoryButtonStyle.width, height: TimerCategoryButtonStyle.height)
                    .position(selectionCapsulePosition)

                HStack(spacing: 0) {
                    if presenterModel.state != .restOnly {
                        Button {
                            if viewModel.activeTimerModel == nil {
                                withAnimation(.easeOut(duration: 0.1)) {
                                    presenterModel.state = .focus
                                }

                                viewModel.logEvent(.timerCategoryToggled(.focus))
                            }
                        } label: {
                            Text("Focus")
                        }
                        .disabled(presenterModel.state == .focusOnly)
                    }

                    if presenterModel.state != .focusOnly {
                        Button {
                            if viewModel.activeTimerModel == nil {
                                withAnimation(.easeOut(duration: 0.1)) {
                                    presenterModel.state = .rest
                                }

                                viewModel.logEvent(.timerCategoryToggled(.rest))
                            }
                        } label: {
                            Text("Rest")
                        }
                        .disabled(presenterModel.state == .restOnly)
                    }
                }
                .font(.poppinsBody)
                .foregroundColor(Color.Hourglass.onBackgroundPrimary)
                .buttonStyle(TimerCategoryButtonStyle())
                .animation(.easeOut(duration: 0.1), value: presenterModel.state)
            }
            .frame(width: toggleWidth, height: TimerCategoryButtonStyle.height)
        }
        .frame(width: toggleWidth + containerPadding, height: TimerCategoryButtonStyle.height + containerPadding)
        .background(Color.Hourglass.toggleBackground)
        .cornerRadius((TimerCategoryButtonStyle.height + containerPadding) / 2)
    }

    private var selectionCapsulePosition: CGPoint {
        let y = 1 / 2 * TimerCategoryButtonStyle.height

        switch presenterModel.state {
        case .focus:
            return CGPoint(x: 1 / 4 * TimerCategoryButtonStyle.width * 2, y: y)
        case .rest:
            return CGPoint(x: 3 / 4 * TimerCategoryButtonStyle.width * 2, y: y)
        case .focusOnly:
            return CGPoint(x: 1 / 2 * TimerCategoryButtonStyle.width, y: y)
        case .restOnly:
            return CGPoint(x: 1 / 2 * TimerCategoryButtonStyle.width, y: y)
        }
    }

    private var toggleWidth: CGFloat {
        switch presenterModel.state {
        case .focus, .rest:
            return TimerCategoryButtonStyle.width * 2
        case .focusOnly, .restOnly:
            return TimerCategoryButtonStyle.width
        }
    }
}

fileprivate struct TimerCategoryButtonStyle: ButtonStyle {
    static let width: CGFloat = 64
    static let height: CGFloat = 20

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: Self.width, height: Self.height)
            .contentShape(Rectangle())
            .background(.clear)
    }
}

struct TimerCategoryToggle_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ViewModelMock(analyticsManager: AnalyticsManager.shared,
                                      dataManager: DataManager.shared,
                                      settingsManager: SettingsManager.shared,
                                      timerManager: TimerManager.shared,
                                      userNotificationManager: UserNotificationManager.shared)

        VStack {
            TimerCategoryToggle(viewModel: viewModel, presenterModel: .init(state: .focus))
            TimerCategoryToggle(viewModel: viewModel, presenterModel: .init(state: .rest))
            TimerCategoryToggle(viewModel: viewModel, presenterModel: .init(state: .focusOnly))
            TimerCategoryToggle(viewModel: viewModel, presenterModel: .init(state: .restOnly))
        }
    }
}
