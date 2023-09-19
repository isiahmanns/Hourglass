import Combine

extension TimerCategoryToggle {
    class PresenterModel: ObservableObject {
        @Published var state: State {
            didSet {
                switch state {
                case .focus, .focusOnly:
                    TimerCategory.current = .focus
                case .rest, .restOnly:
                    TimerCategory.current = .rest
                }
            }
        }

        init(state: State = .focus) {
            self.state = state
        }
    }

    enum State {
        case focus
        case rest
        case focusOnly
        case restOnly
    }
}
