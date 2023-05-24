import Foundation

enum Timer {
    class Model: Identifiable, ObservableObject {
        @Published var length: Int
        @Published var state: State
        let category: Category
        let size: Size

        init(length: Int, state: State = .inactive, category: Category, size: Size) {
            self.length = length
            self.state = state
            self.category = category
            self.size = size
        }
    }
}

extension Timer {
    enum State {
        case active
        case inactive
        case disabled
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

    enum Size {
        case small
        case medium
        case large
    }
}

extension Dictionary<Timer.Model.ID, Timer.Model> {
    func filterByCategory(_ category: Timer.Category) -> [Timer.Model] {
        self.values
            .filter { timerModel in
                timerModel.category == category
            }
    }
}

extension Array<Timer.Model> {
    func sortByLength() -> [Timer.Model] {
        self.sorted(by: {$0.length < $1.length})
    }
}
