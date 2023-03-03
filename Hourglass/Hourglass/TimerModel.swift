import Foundation

enum Timer {
    class Model: Identifiable {
        let id: UUID
        let length: Int
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
