import Combine

protocol TimerEventForwarding {
    func forwardEvent(_ event: HourglassEventKey.Timer, timerModelId: Timer.Model.ID)
}

class ProgressTrackingManager {
    static let shared = ProgressTrackingManager(dataManager: DataManager.shared,
                                                settingsManager: SettingsManager.shared,
                                                timerEventProvider: TimerManager.shared)

    let timerModels: [Timer.Model.ID: Timer.Model]
    let timerEvents: [HourglassEventKey.Timer: TimerEvent]
    let settingsManager: SettingsManager
    // TODO: - Delegate call for showing alerts

    private(set) var activeTimerModelId: Timer.Model.ID?
    var activeTimerModel: Timer.Model? {
        guard let activeTimerModelId else { return nil }
        return timerModels[activeTimerModelId]
    }

    var restWarningThreshold: Int {
        // TODO: - Read value from cache
        5
    }

    var forceRestThreshold: Int {
        // TODO: - Read value from cache
        10
    }

    private var focusStride: Int = 0
    private var cancellables: Set<AnyCancellable> = []

    private init(dataManager: DataManaging,
                 settingsManager: SettingsManager,
                 timerEventProvider: TimerEventProviding) {
        self.timerModels = dataManager.getTimerModels()
        self.settingsManager = settingsManager
        self.timerEvents = timerEventProvider.events
        configureEventSubscriptions()
    }

    private func configureEventSubscriptions() {
        timerEvents[.timerDidStart]?
            .sink { [weak self] timerModelId in
                self?.activeTimerModelId = timerModelId
            }
            .store(in: &cancellables)

        timerEvents[.timerDidTick]?
            .sink { [weak self] timerModelId in
                guard let self else { return }
                guard let activeTimerModel, timerModelId == activeTimerModel.id else {
                    // TODO: - Analytics, invalid state
                    fatalError()
                }

                switch activeTimerModel.category {
                case .focus:
                    focusStride += 1
                    showRestWarningIfNeeded()
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }

    private func showRestWarningIfNeeded() {
        if focusStride == restWarningThreshold {
            // TODO: - Delegate call to show alert
            print("showing rest warning")
        }
    }

    private func enforceRestIfNeeded() {
        if focusStride >= forceRestThreshold {
            setTimers(category: .focus, state: .disabled)
        }
    }

    private func deEnforceRest() {
        setTimers(category: .focus, state: .inactive)
    }

    private func setTimers(category: Timer.Category, state: Timer.State) {
        timerModels.filterByCategory(category)
            .forEach { timerModel in
                timerModel.state = state
            }
    }
}

extension ProgressTrackingManager: TimerEventForwarding {
    func forwardEvent(_ event: HourglassEventKey.Timer, timerModelId: Timer.Model.ID) {
        guard let activeTimerModel, timerModelId == activeTimerModel.id else {
            // TODO: - Analytics, invalid state
            fatalError()
        }

        switch event {
        case .timerDidComplete:
            switch activeTimerModel.category {
            case .focus:
                enforceRestIfNeeded()
            case .rest:
                deEnforceRest()
                focusStride = 0
                // TODO: - Disable rest timers based on "Get back to work after rest" setting
            }

            activeTimerModelId = nil
        case .timerWasCancelled:
            switch activeTimerModel.category {
            case .focus:
                enforceRestIfNeeded()
            default:
                break
            }

            activeTimerModelId = nil
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
