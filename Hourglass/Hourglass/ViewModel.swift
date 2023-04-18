import Combine
import Foundation

class ViewModel: ObservableObject {
    private(set) var timerModels: [Timer.Model]
    private let timerManager: TimerManager
    private let userNotificationManager: NotificationManager
    private let settingsManager: SettingsManager
    weak private var windowCoordinator: WindowCoordinator?

    var activeTimerModel: Timer.Model? {
        guard let activeTimerModelId = timerManager.activeTimerModelId else { return nil }
        return timerModels.filterById(activeTimerModelId)
    }

    private var pendingTimerModel: Timer.Model?
    @Published var viewState = ViewState()
    private var cancellables: Set<AnyCancellable> = []

    // TODO: - Configure TimerModels in DataManager outside of init
    init(timerModels: [Timer.Model]? = nil,
         timerManager: TimerManager,
         userNotificationManager: NotificationManager,
         settingsManager: SettingsManager,
         windowCoordinator: WindowCoordinator) {
        self.timerManager = timerManager
        self.userNotificationManager = userNotificationManager
        self.settingsManager = settingsManager
        self.windowCoordinator = windowCoordinator
        self.timerModels = timerModels ?? [
            Timer.Model(length: settingsManager.getTimerLength(for: .timerFocusSmall),
                        category: .focus,
                        size: .small),
            Timer.Model(length: settingsManager.getTimerLength(for: .timerFocusMedium),
                        category: .focus,
                        size: .medium),
            Timer.Model(length: settingsManager.getTimerLength(for: .timerFocusLarge),
                        category: .focus,
                        size: .large),
            Timer.Model(length: settingsManager.getTimerLength(for: .timerRestSmall),
                        category: .rest,
                        size: .small),
            Timer.Model(length: settingsManager.getTimerLength(for: .timerRestMedium),
                        category: .rest,
                        size: .medium),
            Timer.Model(length: settingsManager.getTimerLength(for: .timerRestLarge),
                        category: .rest,
                        size: .large)
        ]
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

    private func notifyUser(_ event: HourglassEvent.Timer) {
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
        timerManager.events[.timerDidStart]?
            .sink { [weak self] timerModelId in
                let timerModel = self?.timerModels.filterById(timerModelId)
                timerModel?.state = .active
            }
            .store(in: &cancellables)

        timerManager.events[.timerDidComplete]?
            .sink { [weak self] timerModelId in
                guard let self else { return }
                let timerModel = timerModels.filterById(timerModelId)
                timerModel?.state = .inactive
                notifyUser(.timerDidComplete)
                // TODO: - Save completed time block via data manager
            }
            .store(in: &cancellables)

        timerManager.events[.timerWasCancelled]?
            .sink { [weak self] timerModelId in
                let timerModel = self?.timerModels.filterById(timerModelId)
                timerModel?.state = .inactive
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
