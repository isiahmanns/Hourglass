import Foundation

class ViewModel: ObservableObject {
    // TODO: - TimerModels should be fetched from cache before setting to default
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

    private let timerManager = TimerManager.shared

    @Published var viewState = ViewState()

    // TODO: - Inject dependencies into ViewModel (support a MockTimerManager)
    init() {}

    // TODO: - Protocol
    func didTapTimer(from model: Timer.Model) -> Void {
        if timerManager.isTimerActive {
            if model.id == timerManager.activeTimerModelId {
                timerManager.stopTimer()
                model.state = .inactive
            } else {
                // TODO: - Prompt to cancel currently active timer and start new one
                viewState.showCancelTimerAlert = true
            }
        } else {
            timerManager.startTimer(length: model.length,
                                    activeTimerModelId: model.id) { [weak self] in
                // TODO: - Show timer complete alert, play sound FX
                model.state = .inactive
                self?.viewState.showTimerCompleteAlert = true
            }
            model.state = .active
        }
    }
}

extension ViewModel {
    struct ViewState {
        var showCancelTimerAlert: Bool = false
        var showTimerCompleteAlert: Bool = false
    }
}

// TODO: - BOOKMARK - handle alerts appropriately, write tests for timer and timerButton states to close #3, then create ticket for hooking up menu bar
