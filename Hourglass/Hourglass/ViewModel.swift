import Foundation

class ViewModel: ObservableObject {
    // TODO: - TimerModels should be fetched from cache before setting to default
    private(set) var timerModels: [Timer.Category: [Timer.Model]]
    private let timerManager: TimerManager
    private let userNotificationManager: NotificationManager
    private let settingsManager: SettingsManager
    private var activeTimerModel: Timer.Model?
    private var pendingTimerModel: Timer.Model?
    @Published var viewState = ViewState()

    init(timerModels: [Timer.Category: [Timer.Model]] = [
        .focus: [
            Timer.Model(length: 15, category: .focus, size: .small),
            Timer.Model(length: 25, category: .focus, size: .medium),
            Timer.Model(length: 35, category: .focus, size: .large)],

        .rest: [
            Timer.Model(length: 3, category: .rest, size: .small),
            Timer.Model(length: 5, category: .rest, size: .medium),
            Timer.Model(length: 10, category: .rest, size: .large)]
        ],
         timerManager: TimerManager = TimerManager.shared,
         userNotificationManager: NotificationManager = UserNotificationManager.shared,
         settingsManager: SettingsManager = SettingsManager.shared) {
        // TODO: - Add a DataManager dependency, use it to set timerModels
        // TODO: - Explicitly inject dependencies from call site
        self.timerModels = timerModels
        self.timerManager = timerManager
        self.userNotificationManager = userNotificationManager
        self.settingsManager = settingsManager
    }

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

    func didReceiveStartNewTimerDialog(response: StartNewTimerDialogResponse) -> Void {
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
            // TODO: - Save completed time block via data manager
            model.state = .inactive
            self?.notifyUser(.timerCompleted)
        }
        model.state = .active
        activeTimerModel = model
    }

    private func promptStartNewTimer(for model: Timer.Model) {
        pendingTimerModel = model
        viewState.showStartNewTimerDialog = true
    }

    private func notifyUser(_ event: HourglassEvent) {
        switch event {
        case .timerCompleted:
            let soundIsEnabled = settingsManager.getSoundIsEnabled()

            switch settingsManager.getNotificationStyle() {
            case .banner:
                userNotificationManager.fireNotification(.timerCompleteBanner,
                                                         soundIsEnabled: soundIsEnabled)
            case .popup:
                if soundIsEnabled {
                    userNotificationManager.fireNotification(.noBanner,
                                                             soundIsEnabled: true)
                }
                viewState.showTimerCompleteAlert = true
            }
        }
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
