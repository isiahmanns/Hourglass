import Combine

extension TimerButton {
    class PresenterModel: Identifiable, ObservableObject {
        let length: Int
        @Published var state: State

        init(length: Int, state: State = .inactive) {
            self.length = length
            self.state = state
        }
    }

    enum State {
        case active
        case inactive
    }
}
