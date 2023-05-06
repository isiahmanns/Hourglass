import Combine

/**
 A manager object that subscribes to timer events and handles associated `Timer.Model` state mutation.
 */
class TimerModelStateManager {
    static let shared = TimerModelStateManager(dataManager: DataManager.shared,
                                               settingsManager: SettingsManager.shared,
                                               timerEventProvider: TimerManager.shared)

    private let timerModels: [Timer.Model.ID: Timer.Model]
    private let timerEvents: [HourglassEventKey.Timer: TimerEvent]
    private let settingsManager: SettingsManager
    weak var delegate: TimerModelStateNotifying?

    private var activeTimerModelId: Timer.Model.ID?
    private var activeTimerModel: Timer.Model? {
        guard let activeTimerModelId else { return nil }
        return timerModels[activeTimerModelId]
    }

    /**
     An amount of focus time that when met, the user is notified to take a rest soon.

     This setting is triggered immediately, on the tick of the timer.
     */
    private var restWarningThreshold: Int? {
        let restWarningThreshold = settingsManager.getRestWarningThreshold()
        return restWarningThreshold > 0 ? restWarningThreshold : nil
    }

    /**
     An amount of focus time that when met or surpassed, the user is forced to take a rest.

     This setting is triggered when a timer is cancelled or completed.
     */
    private var enforceRestThreshold: Int? {
        let enforceRestThreshold = settingsManager.getEnforceRestThreshold()
        return enforceRestThreshold > 0 ? enforceRestThreshold : nil
    }

    private var getBackToWorkIsEnabled: Bool {
        settingsManager.getGetBackToWorkIsEnabled()
    }

    /**
     The accumulating time-span that is represented by ticking focus timers.

     This value is incremented as a focus timer ticks and used as a gate to trigger the user's rest settings.
     This is an ever-incrementing value (even through timer cancellations) and is only reset when a rest timer is completed.
     */
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

                setTimers(state: .inactive)
                delegate?.notifyUser(timerEvent: .timerDidComplete)

                switch activeTimerModel.category {
                case .focus:
                    enforceRestIfNeeded()
                case .rest:
                    focusStride = 0
                    enforceFocusIfNeeded()
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
            delegate?.notifyUser(progressEvent: .restWarningThresholdMet)
        }
    }

    private func enforceRestIfNeeded() {
        if let enforceRestThreshold, focusStride >= enforceRestThreshold {
            setTimers(category: .focus, state: .disabled)
            delegate?.notifyUser(progressEvent: .enforceRestThresholdMet)
        }
    }

    private func enforceFocusIfNeeded() {
        if getBackToWorkIsEnabled {
            setTimers(category: .rest, state: .disabled)
        }
    }

    private func setTimers(state: Timer.State) {
        timerModels
            .forEach { id, timerModel in
                timerModel.state = state
            }
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
