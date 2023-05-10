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
        configureSettingsObservations()
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

    func showAboutWindow() {
        windowCoordinator?.showAboutWindow()
    }

    private func configureSettingsObservations() {
        let focusTimers = timerModels.filterByCategory(.focus)
        let restTimers = timerModels.filterByCategory(.rest)

        settingsManager.observe(\.timerFocusSmall) { length in
            guard let timerModel = focusTimers.first(where: { $0.size == .small }) else { return }
            self.didChangeTimerPreset(for: timerModel, to: length)
        }

        settingsManager.observe(\.timerFocusMedium) { length in
            guard let timerModel = focusTimers.first(where: { $0.size == .medium }) else { return }
            self.didChangeTimerPreset(for: timerModel, to: length)
        }

        settingsManager.observe(\.timerFocusLarge) { length in
            guard let timerModel = focusTimers.first(where: { $0.size == .large }) else { return }
            self.didChangeTimerPreset(for: timerModel, to: length)
        }

        settingsManager.observe(\.timerRestSmall) { length in
            guard let timerModel = restTimers.first(where: { $0.size == .small }) else { return }
            self.didChangeTimerPreset(for: timerModel, to: length)
        }

        settingsManager.observe(\.timerRestMedium) { length in
            guard let timerModel = restTimers.first(where: { $0.size == .medium }) else { return }
            self.didChangeTimerPreset(for: timerModel, to: length)
        }

        settingsManager.observe(\.timerRestLarge) { length in
            guard let timerModel = restTimers.first(where: { $0.size == .large }) else { return }
            self.didChangeTimerPreset(for: timerModel, to: length)
        }
    }

    private func didChangeTimerPreset(for timerModel: Timer.Model, to length: Int) {
        defer { timerModel.length = length }
        if activeTimerModel === timerModel {
            cancelTimer()
            viewState.showTimerResetAlert = true
        }
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
