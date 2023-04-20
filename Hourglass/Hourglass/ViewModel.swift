import Combine
import Foundation

class ViewModel: ObservableObject {
    let timerModels: [Timer.Model.ID: Timer.Model]
    private let timerEvents: [HourglassEventKey.Timer: TimerEvent]
    private let timerManager: TimerManager
    private let timerEventForwarder: TimerEventForwarding
    private let userNotificationManager: NotificationManager
    private let settingsManager: SettingsManager
    weak private var windowCoordinator: WindowCoordinator?

    var activeTimerModel: Timer.Model? {
        guard let activeTimerModelId = timerManager.activeTimerModelId else { return nil }
        return timerModels[activeTimerModelId]
    }

    private var pendingTimerModel: Timer.Model?
    @Published var viewState = ViewState()
    private var cancellables: Set<AnyCancellable> = []

    init(dataManager: DataManaging,
         settingsManager: SettingsManager,
         timerEventForwarder: TimerEventForwarding,
         timerManager: TimerManager,
         userNotificationManager: NotificationManager,
         windowCoordinator: WindowCoordinator) {

        self.timerModels = dataManager.getTimerModels()
        self.settingsManager = settingsManager
        self.timerEvents = timerManager.events
        self.timerManager = timerManager
        self.timerEventForwarder = timerEventForwarder
        self.userNotificationManager = userNotificationManager
        self.windowCoordinator = windowCoordinator
        configureEventSubscriptions()
    }

    func didTapTimer(from model: Timer.Model) -> Void {
        guard model.state.isEnabled else { return }

        if let activeTimerModel {
            if model === activeTimerModel {
                cancelTimer()
            } else {
                promptStartNewTimer(for: model)
            }
        } else {
            startTimer(for: model)
        }
    }

    func didReceiveStartNewTimerDialog(response: StartNewTimerDialogResponse) -> Void {
        switch response {
        case .no:
            break
        case .yes:
            if activeTimerModel != nil {
                cancelTimer()
            }

            guard let pendingTimerModel else {
                // TODO: - Analytics, invalid state
                fatalError()
            }

            startTimer(for: pendingTimerModel)
        }

        pendingTimerModel = nil
    }

    func didChangeTimerPreset(for timerModel: Timer.Model) {
        if activeTimerModel === timerModel {
            cancelTimer()
            viewState.showTimerResetAlert = true
        }
    }

    func showAboutWindow() {
        windowCoordinator?.showAboutWindow()
    }

    private func cancelTimer() {
        timerManager.cancelTimer()
    }

    private func startTimer(for model: Timer.Model) {
        timerManager.startTimer(length: model.length, activeTimerModelId: model.id)
    }

    private func promptStartNewTimer(for model: Timer.Model) {
        pendingTimerModel = model
        viewState.showStartNewTimerDialog = true
    }

    private func notifyUser(_ event: HourglassEventKey.Timer) {
        switch event {
        case .timerDidComplete:
            let soundIsEnabled = settingsManager.getSoundIsEnabled()

            switch settingsManager.getNotificationStyle() {
            case .banner:
                userNotificationManager.fireNotification(.timerCompleteBanner,
                                                         soundIsEnabled: soundIsEnabled)
            case .popup:
                if soundIsEnabled {
                    userNotificationManager.fireNotification(.timerCompleteNoBanner,
                                                             soundIsEnabled: true)
                }
                viewState.showTimerCompleteAlert = true
                windowCoordinator?.showPopoverIfNeeded()
            }
        default:
            break
        }
    }

    private func configureEventSubscriptions() {
        timerEvents[.timerDidStart]?
            .sink { [weak self] timerModelId in
                self?.timerModels[timerModelId]?.state = .active
            }
            .store(in: &cancellables)

        timerEvents[.timerDidComplete]?
            .sink { [weak self] timerModelId in
                guard let self else { return }
                if let timerModel = timerModels[timerModelId] {
                    timerModel.state = .inactive
                    notifyUser(.timerDidComplete)
                    timerEventForwarder.forwardEvent(.timerDidComplete, timerModelId: timerModelId)
                }
            }
            .store(in: &cancellables)

        timerEvents[.timerWasCancelled]?
            .sink { [weak self] timerModelId in
                guard let self else { return }
                timerModels[timerModelId]?.state = .inactive
                timerEventForwarder.forwardEvent(.timerWasCancelled, timerModelId: timerModelId)
            }
            .store(in: &cancellables)
    }
}

extension ViewModel {
    struct ViewState {
        var showStartNewTimerDialog: Bool = false
        var showTimerCompleteAlert: Bool = false
        var showTimerResetAlert: Bool = false
    }

    enum StartNewTimerDialogResponse {
        case yes
        case no
    }
}
