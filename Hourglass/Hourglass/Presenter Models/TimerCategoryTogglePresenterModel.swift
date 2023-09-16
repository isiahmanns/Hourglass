import Combine

extension TimerCategoryToggle {
    static var category: TimerCategory = .focus

    class PresenterModel: ObservableObject {
        @Published var state: State {
            didSet {
                switch state {
                case .focus, .focusOnly:
                    TimerCategoryToggle.category = .focus
                case .rest, .restOnly:
                    TimerCategoryToggle.category = .rest
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

enum TimerCategory: Int {
    case focus
    case rest

    var asString: String {
        switch self {
        case .focus:
            return "Focus"
        case .rest:
            return "Rest"
        }
    }
}
