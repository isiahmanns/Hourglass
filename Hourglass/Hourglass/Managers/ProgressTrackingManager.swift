import Combine

struct ProgressTrackingManager {
    static let shared = ProgressTrackingManager(dataManager: DataManager.shared,
                                                settingsManager: SettingsManager.shared,
                                                timerEventProvider: TimerManager.shared)

    let timerModels: [Timer.Model.ID: Timer.Model]
    let timerEvents: [HourglassEventKey.Timer: TimerEvent]
    let settingsManager: SettingsManager

    var restWarningThreshold: Int {
        // TODO: - Read value from cache
        5
    }

    var forceRestThreshold: Int {
        // TODO: - Read value from cache
        10
    }

    var forceRestIsEnabled: Bool = false
    private var focusStride: Int = 0
    private var restStride: Int = 0
    private var cancellables: Set<AnyCancellable> = []

    private init(dataManager: DataManaging,
                 settingsManager: SettingsManager,
                 timerEventProvider: TimerEventProviding) {
        self.timerModels = dataManager.getTimerModels()
        self.settingsManager = settingsManager
        self.timerEvents = timerEventProvider.events
        configureEventSubscriptions()
    }

    // TODO: - Handle start (set active timer) and tick events
    private func configureEventSubscriptions() {
        // timerEvents
    }

    // TODO: - Forward cancel and complete events to sequence model state mutation
    func forwardEvent(_ event: HourglassEventKey.Timer, timerModelId: Timer.Model.ID) {
        switch event {
        case .timerDidComplete:
            // Check if event timer is a focus timer
            if forceRestIsEnabled {
                timerModels.filterByCategory(.focus)
                    .forEach { focusTimerModel in
                        focusTimerModel.state = .disabled
                    }
                return
            }

            // TODO: - Reset active timer to nil, or use timerManager like in view model


            break
        default:
            break
        }
    }
}


/**
 TODO:
 Decide whether to force break immediately and cancel timer, or let remainder of timer finish and then force break
 Does DataManager log only completed time intervals.... YES.
 Tracking partial focus periods (cancelling) can result in user initiated bugs where they spam the cancel function and have fake tracked progress.
 So it makes better sense to force the break after the remainder of the timer. Or if the timer is cancelled.
 The latter case will result in the partial work period not being tracked.
 */
