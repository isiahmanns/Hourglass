import Foundation
// TODO: - Import Combine
// TODO: - Refactor to use PresenterModel naming pattern
enum Timer {
    class Model: Identifiable, ObservableObject {
        let length: Int
        @Published var state: State
        static var category: Category = .focus

        init(length: Int, state: State = .inactive) {
            self.length = length
            self.state = state
        }
    }
}

extension Timer {
    enum State {
        case active
        case inactive
    }

    enum Category: Int {
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
}

extension Dictionary<Timer.Model.ID, Timer.Model>.Values {
    func sortBySize() -> [Timer.Model] {
        self.sorted(by: {$0.length < $1.length})
    }
}
