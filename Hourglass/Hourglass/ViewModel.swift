import Foundation

class ViewModel: ObservableObject {
    private(set) var timerModels: [Timer.Model]
    private let timerManager: TimerManager
    private let userNotificationManager: NotificationManager
    private let settingsManager: SettingsManager

    var activeTimerModel: Timer.Model? {
        timerModels.filter({$0.id == timerManager.activeTimerModelId}).first
    }

    private var pendingTimerModel: Timer.Model?
    @Published var viewState = ViewState()

    init(timerModels: [Timer.Model]? = nil,
         timerManager: TimerManager = TimerManager.shared,
         userNotificationManager: NotificationManager = UserNotificationManager.shared,
         settingsManager: SettingsManager = SettingsManager.shared) {
        // TODO: - Explicitly inject dependencies from call site
        self.timerManager = timerManager
        self.userNotificationManager = userNotificationManager
        self.settingsManager = settingsManager
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
            if let activeTimerModel {
                stopTimer(for: activeTimerModel)
            }

            guard let pendingTimerModel else {
                // TODO: - Analytics, invalid state
                fatalError()
            }

            startTimer(for: pendingTimerModel)
        }

        pendingTimerModel = nil
    }

    func cancelTimerIfNeeded(_ timerModel: Timer.Model) {
        if activeTimerModel === timerModel {
            stopTimer(for: timerModel)
            viewState.showTimerResetAlert = true
        }
    }

    private func stopTimer(for model: Timer.Model) {
        timerManager.stopTimer()
        model.state = .inactive
    }

    private func startTimer(for model: Timer.Model) {
        timerManager.startTimer(length: model.length,
                                activeTimerModelId: model.id) { [weak self] in
            // TODO: - Save completed time block via data manager
            model.state = .inactive
            self?.notifyUser(.timerCompleted)
        }
        model.state = .active
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
        var showTimerResetAlert: Bool = false
    }

    enum StartNewTimerDialogResponse {
        case yes
        case no
    }
}
