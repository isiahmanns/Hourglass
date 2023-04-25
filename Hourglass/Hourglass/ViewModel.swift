import Combine
import Foundation

protocol TimerModelStateNotifying: AnyObject {
    func notifyUser(_ event: HourglassEventKey.Timer)
    func notifyUser(_ event: HourglassEventKey.Progress)
}

class ViewModel: ObservableObject {
    let timerModels: [Timer.Model.ID: Timer.Model]
    private let timerManager: TimerManager
    private let userNotificationManager: NotificationManager
    private let settingsManager: SettingsManager
    weak var windowCoordinator: WindowCoordinator?

    private var activeTimerModel: Timer.Model? {
        guard let activeTimerModelId = timerManager.activeTimerModelId else { return nil }
        return timerModels[activeTimerModelId]
    }

    private var pendingTimerModel: Timer.Model?
    @Published var viewState = ViewState()

    init(dataManager: DataManaging,
         settingsManager: SettingsManager,
         timerManager: TimerManager,
         userNotificationManager: NotificationManager) {

        self.timerModels = dataManager.getTimerModels()
        self.settingsManager = settingsManager
        self.timerManager = timerManager
        self.userNotificationManager = userNotificationManager
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
}

extension ViewModel: TimerModelStateNotifying {
    func notifyUser(_ event: HourglassEventKey.Timer) {
        switch event {
        case .timerDidComplete:
            let soundIsEnabled = settingsManager.getSoundIsEnabled()

            switch settingsManager.getNotificationStyle() {
            case .banner:
                userNotificationManager.fireNotification(.timerCompleteBanner,
                                                         soundIsEnabled: soundIsEnabled)
            case .popup:
                if soundIsEnabled {
                    userNotificationManager.fireNotification(.soundOnly,
                                                             soundIsEnabled: true)
                }
                viewState.showTimerCompleteAlert = true
                windowCoordinator?.showPopoverIfNeeded()
            }
        default:
            break
        }
    }

    func notifyUser(_ event: HourglassEventKey.Progress) {
        switch event {
        case .restWarningThresholdMet:
            let soundIsEnabled = settingsManager.getSoundIsEnabled()

            switch settingsManager.getNotificationStyle() {
            case .banner:
                userNotificationManager.fireNotification(.restWarningThresholdMetBanner,
                                                         soundIsEnabled: soundIsEnabled)
            case .popup:
                if soundIsEnabled {
                    userNotificationManager.fireNotification(.soundOnly,
                                                             soundIsEnabled: true)
                }
                viewState.showRestWarningAlert = true
                windowCoordinator?.showPopoverIfNeeded()
            }
        case .enforceRestThresholdMet:
            viewState.showEnforceRestAlert = true
            windowCoordinator?.showPopoverIfNeeded()
        }
    }
}

extension ViewModel {
    struct ViewState {
        var showStartNewTimerDialog: Bool = false
        var showTimerCompleteAlert: Bool = false
        var showTimerResetAlert: Bool = false
        var showRestWarningAlert: Bool = false
        var showEnforceRestAlert: Bool = false
    }

    enum StartNewTimerDialogResponse {
        case yes
        case no
    }
}
