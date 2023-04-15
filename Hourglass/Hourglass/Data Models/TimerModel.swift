import Foundation

enum Timer {
    class Model: Identifiable, ObservableObject {
        let id: UUID = UUID()
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

        var isEnabled: Bool {
            self != .disabled
        }
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
