import Foundation

enum Timer {
    class Model: Identifiable, ObservableObject {
        let id: UUID
        @Published var length: Int
        @Published var state: State
        let category: Category
        let size: Size

        init(id: UUID = UUID(), length: Int, state: State = .inactive, category: Category, size: Size) {
            self.id = id
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
    }

    enum Category {
        case focus
        case rest
    }

    enum Size {
        case small
        case medium
        case large
    }
}

extension [Timer.Model] {
    func filterByCategory(_ category: Timer.Category) -> [Timer.Model] {
        self
            .filter { timerModel in
                timerModel.category == category
            }
            .sorted(by: {$0.length < $1.length})
    }
}
