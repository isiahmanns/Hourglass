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

    private var activeTimerModel: Timer.Model?

    private var pendingTimerModel: Timer.Model?

    private let timerManager = TimerManager.shared

    @Published var viewState = ViewState()

    // TODO: - Inject dependencies into ViewModel (support a MockTimerManager)
    init() {}

    // TODO: - Protocol
    func didTapTimer(from model: Timer.Model) -> Void {
        if timerManager.isTimerActive {
            if model.id == timerManager.activeTimerModelId {
                stopTimer(for: model)
            } else {
                promptStartNewTimer(for: model)
            }
        } else {
            startTimer(for: model)
        }
    }

    func handleStartNewTimerDialog(response: StartNewTimerDialogResponse) -> Void {
        switch response {
        case .no:
            break
        case .yes:
            guard let activeTimerModel, let pendingTimerModel else { fatalError() }

            stopTimer(for: activeTimerModel)
            startTimer(for: pendingTimerModel)
        }

        pendingTimerModel = nil
    }

    private func stopTimer(for model: Timer.Model) {
        timerManager.stopTimer()
        model.state = .inactive
        activeTimerModel = nil
    }

    private func startTimer(for model: Timer.Model) {
        timerManager.startTimer(length: model.length,
                                activeTimerModelId: model.id) { [weak self] in
            // TODO: - Play sound FX
            model.state = .inactive
            self?.viewState.showTimerCompleteAlert = true
        }
        model.state = .active
        activeTimerModel = model
    }

    private func promptStartNewTimer(for model: Timer.Model) {
        pendingTimerModel = model
        viewState.showStartNewTimerDialog = true
    }
}

extension ViewModel {
    struct ViewState {
        var showStartNewTimerDialog: Bool = false
        var showTimerCompleteAlert: Bool = false
    }

    enum StartNewTimerDialogResponse {
        case yes
        case no
    }
}
