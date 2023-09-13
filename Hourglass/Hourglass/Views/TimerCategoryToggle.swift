import SwiftUI

// TODO: - Disable category toggle when timer is running, access via viewModel
// TODO: - Make active timer stroke thinner
// TODO: - Animate selection capsule movement and toggle re-sizing
struct TimerCategoryToggle: View {
    @State var state: TimerCategoryToggleState = .focus

    var body: some View {
        let containerPadding: CGFloat = 4

        ZStack {
            ZStack {
                Capsule()
                    .fill(Color.Hourglass.background)
                    .frame(width: TimerCategoryButtonStyle.width, height: TimerCategoryButtonStyle.height)
                    .position(selectionCapsulePosition)

                HStack(spacing: 0) {
                    if state != .restOnly {
                        Button {
                            state = .focus
                            Timer.Model.category = .focus
                        } label: {
                            Text("Focus")
                        }
                    }

                    if state != .focusOnly {
                        Button {
                            state = .rest
                            Timer.Model.category = .rest
                        } label: {
                            Text("Rest")
                        }
                    }
                }
                .font(.poppinsBody)
                .foregroundColor(Color.Hourglass.onBackgroundPrimary)
                .buttonStyle(TimerCategoryButtonStyle())
            }
            .frame(width: toggleWidth, height: TimerCategoryButtonStyle.height)
        }
        .frame(width: toggleWidth + containerPadding, height: TimerCategoryButtonStyle.height + containerPadding)
        .background(Color.Hourglass.onBackgroundSecondary)
        .cornerRadius((TimerCategoryButtonStyle.height + containerPadding) / 2)
    }

    private var selectionCapsulePosition: CGPoint {
        let y = 1 / 2 * TimerCategoryButtonStyle.height

        switch state {
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
        switch state {
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

enum TimerCategoryToggleState {
    case focus
    case rest
    case focusOnly
    case restOnly
}

struct TimerCategoryToggle_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TimerCategoryToggle(state: .focus)
            TimerCategoryToggle(state: .rest)
            TimerCategoryToggle(state: .focusOnly)
            TimerCategoryToggle(state: .restOnly)
        }
    }
}
