import Foundation

class ViewModel {
    private(set) var timerModels: [Timer.Category: [Timer.Model]] = [
        .focus: [
            Timer.Model(length: 15, category: .focus, size: .small),
            Timer.Model(length: 25, category: .focus, size: .medium),
            Timer.Model(length: 35, category: .focus, size: .large)],

        .rest: [
            Timer.Model(length: 3, category: .rest, size: .small),
            Timer.Model(length: 5, category: .rest, size: .medium),
            Timer.Model(length: 10, category: .rest, size: .large)]
    ]

    func didTapTimer(from model: Timer.Model) -> Void {
        model.state = .active
        // TODO: - Selection logic based on timer manager state
        // Timer is active
            // Same timer? Then cancel
            // Different timer? Prompt to cancel currently active timer and start new one

        // Timer is not active
            // Begin timer
    }
}
