import Combine

extension TimerCategoryToggle {
    class PresenterModel: ObservableObject {
        @Published var state: State {
            didSet {
                switch state {
                case .focus, .focusOnly:
                    Timer.Model.category = .focus
                case .rest, .restOnly:
                    Timer.Model.category = .rest
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
