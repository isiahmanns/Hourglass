import Combine

class TimerModelStateManager {
    static let shared = TimerModelStateManager(dataManager: DataManager.shared,
                                               settingsManager: SettingsManager.shared,
                                               timerEventProvider: TimerManager.shared)

    private let timerModels: [Timer.Model.ID: Timer.Model]
    private let timerEvents: [HourglassEventKey.Timer: TimerEvent]
    private let settingsManager: SettingsManager
    weak var delegate: TimerModelStateNotifying?

    private(set) var activeTimerModelId: Timer.Model.ID?
    private var activeTimerModel: Timer.Model? {
        guard let activeTimerModelId else { return nil }
        return timerModels[activeTimerModelId]
    }

    private var restWarningThreshold: Int? {
        settingsManager.getRestWarningThreshold()
    }

    private var enforceRestThreshold: Int? {
        settingsManager.getEnforceRestThreshold()
    }

    private var focusStride: Int = 0
    private var cancellables: Set<AnyCancellable> = []

    fileprivate init(dataManager: DataManaging,
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
                guard let self else { return }
                activeTimerModelId = timerModelId
                activeTimerModel?.state = .active
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

        timerEvents[.timerDidComplete]?
            .sink { [weak self] timerModelId in
                guard let self else { return }
                guard let activeTimerModel, timerModelId == activeTimerModel.id else {
                    // TODO: - Analytics, invalid state
                    fatalError()
                }

                activeTimerModel.state = .inactive
                delegate?.notifyUser(.timerDidComplete)

                switch activeTimerModel.category {
                case .focus:
                    enforceRestIfNeeded()
                case .rest:
                    deEnforceRest()
                    focusStride = 0
                    // TODO: - Disable rest timers based on "Get back to work after rest" setting
                }

                activeTimerModelId = nil
            }
            .store(in: &cancellables)

        timerEvents[.timerWasCancelled]?
            .sink { [weak self] timerModelId in
                guard let self else { return }
                guard let activeTimerModel, timerModelId == activeTimerModel.id else {
                    // TODO: - Analytics, invalid state
                    fatalError()
                }

                activeTimerModel.state = .inactive

                switch activeTimerModel.category {
                case .focus:
                    enforceRestIfNeeded()
                default:
                    break
                }

                activeTimerModelId = nil
            }
            .store(in: &cancellables)
    }

    private func showRestWarningIfNeeded() {
        if let restWarningThreshold, focusStride == restWarningThreshold {
            delegate?.notifyUser(.restWarningThresholdMet)
        }
    }

    private func enforceRestIfNeeded() {
        if let enforceRestThreshold, focusStride >= enforceRestThreshold {
            setTimers(category: .focus, state: .disabled)
            delegate?.notifyUser(.enforceRestThresholdMet)
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

class TimerModelStateManagerFake: TimerModelStateManager {
    override init(dataManager: DataManaging,
                  settingsManager: SettingsManager,
                  timerEventProvider: TimerEventProviding) {
        super.init(dataManager: dataManager,
                   settingsManager: settingsManager,
                   timerEventProvider: timerEventProvider)
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
