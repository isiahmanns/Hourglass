import Combine
import Foundation

protocol TimerModelStateNotifying: AnyObject {
    func notifyUser(timerEvent: HourglassEventKey.Timer)
    func notifyUser(progressEvent: HourglassEventKey.Progress)
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
    @objc func notifyUser(timerEvent: HourglassEventKey.Timer) {
        switch timerEvent {
        case .timerDidComplete:
            notifyUser(.timerCompleteBanner, alertFlag: &viewState.showTimerCompleteAlert)
        default:
            break
        }
    }

    @objc func notifyUser(progressEvent: HourglassEventKey.Progress) {
        switch progressEvent {
        case .restWarningThresholdMet:
            // TODO: - Either make this a silent/alt-sound user notification, or just make it a simple alert
            notifyUser(.restWarningThresholdMetBanner, alertFlag: &viewState.showRestWarningAlert)
        case .enforceRestThresholdMet:
            viewState.showEnforceRestAlert = true
            windowCoordinator?.showPopoverIfNeeded()
        }
    }

    private func notifyUser(_ notification: HourglassNotification, alertFlag: inout Bool) {
        let soundIsEnabled = settingsManager.getSoundIsEnabled()

        switch settingsManager.getNotificationStyle() {
        case .banner:
            userNotificationManager.fireNotification(notification, soundIsEnabled: soundIsEnabled)
        case .popup:
            if soundIsEnabled {
                userNotificationManager.fireNotification(.soundOnly, soundIsEnabled: true)
            }
            alertFlag = true
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

class ViewModelMock: ViewModel {
    var notificationCount = (timerEvents: [HourglassEventKey.Timer: Int](),
                             progressEvents: [HourglassEventKey.Progress: Int]())

    override func notifyUser(timerEvent: HourglassEventKey.Timer) {
        notificationCount.timerEvents[timerEvent, default: 0] += 1
    }

    override func notifyUser(progressEvent: HourglassEventKey.Progress) {
        notificationCount.progressEvents[progressEvent, default: 0] += 1
    }
}
