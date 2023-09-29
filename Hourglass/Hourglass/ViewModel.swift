import Combine
import Foundation

protocol EventNotifying: AnyObject {
    func notifyUser(timerEvent: HourglassEventKey.Timer)
    func notifyUser(progressEvent: HourglassEventKey.Progress)
}

protocol TimerHandling: AnyObject {
    func resetActiveTimer() throws
}

// TODO: - Split root view model into domain specific groups of responsibilities
class ViewModel: ObservableObject {
    private let analyticsManager: AnalyticsManager
    let timerModels: [TimerButton.PresenterModel.ID: TimerButton.PresenterModel]
    let timerCategoryTogglePresenterModel: TimerCategoryToggle.PresenterModel
    private let timerManager: TimerManager
    private let userNotificationManager: NotificationManager
    private let settingsManager: SettingsManager
    weak var windowCoordinator: WindowCoordinator?

    var activeTimerModel: TimerButton.PresenterModel? {
        guard let activeTimerModelId = timerManager.activeTimerModelId else { return nil }
        return timerModels[activeTimerModelId]
    }

    private var pendingTimerModel: TimerButton.PresenterModel?
    @Published var viewState = ViewState()

    init(analyticsManager: AnalyticsManager,
         dataManager: DataManaging,
         settingsManager: SettingsManager,
         timerManager: TimerManager,
         userNotificationManager: NotificationManager) {

        self.analyticsManager = analyticsManager
        self.timerModels = dataManager.timerModels
        self.timerCategoryTogglePresenterModel = dataManager.timerCategoryTogglePresenterModel
        self.settingsManager = settingsManager
        self.timerManager = timerManager
        self.userNotificationManager = userNotificationManager
    }

    func didTapTimer(from model: TimerButton.PresenterModel) -> Void {
        if let activeTimerModel {
            if model === activeTimerModel {
                try? cancelTimer()
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
            try? cancelTimer()

            guard let pendingTimerModel else {
                fatalError()
            }

            startTimer(for: pendingTimerModel)
        }

        pendingTimerModel = nil
    }

    func showWindow(_ windowContext: WindowContext) {
        if windowContext == .statistics {
            logEvent(.statisticsViewOpened)
        }
        windowCoordinator?.showWindow(windowContext)
    }

    func logEvent(_ event: AnalyticsEvent) {
        analyticsManager.logEvent(event)
    }

    private func cancelTimer() throws {
        try timerManager.cancelTimer()
    }

    private func startTimer(for model: TimerButton.PresenterModel) {
        timerManager.startTimer(length: model.length, activeTimerModelId: model.id)
    }

    private func promptStartNewTimer(for model: TimerButton.PresenterModel) {
        pendingTimerModel = model
        viewState.showStartNewTimerDialog.toggle()
    }
}

extension ViewModel: TimerHandling {
    func resetActiveTimer() throws {
        try cancelTimer()
        viewState.showTimerResetAlert.toggle()
    }
}

extension ViewModel: EventNotifying {
    @objc func notifyUser(timerEvent: HourglassEventKey.Timer) {
        switch timerEvent {
        case .timerDidComplete:
            notifyUser(.timerCompleted)
        default:
            break
        }
    }

    @objc func notifyUser(progressEvent: HourglassEventKey.Progress) {
        switch progressEvent {
        case .restWarningThresholdMet:
            notifyUser(.restWarningThresholdMet)
        case .enforceRestThresholdMet:
            notifyUser(.enforceRestThresholdMet)
        case .getBackToWork:
            notifyUser(.getBackToWork)
        }
    }

    private func notifyUser(_ notification: HourglassNotification) {
        userNotificationManager.fireNotification(notification, soundIsEnabled: settingsManager.getSoundIsEnabled())
    }
}

extension ViewModel {
    struct ViewState {
        var showStartNewTimerDialog: Bool = false
        var showTimerResetAlert: Bool = false
        var showRestSettingsFlow: Bool = false
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
