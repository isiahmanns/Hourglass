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

    static var current: TimerCategory = .focus
}
