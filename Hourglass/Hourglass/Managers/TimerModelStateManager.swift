import Combine

/**
 A manager object that subscribes to timer events and handles associated `Timer.Model` state mutation.
 */
class TimerModelStateManager {
    static let shared = TimerModelStateManager(analyticsManager: AnalyticsManager.shared,
                                               dataManager: DataManager.shared,
                                               settingsManager: SettingsManager.shared,
                                               timerEventProvider: TimerManager.shared)

    private let analyticsManager: AnalyticsManager
    private let timerModels: [Timer.Model.ID: Timer.Model]
    private let timerEvents: [HourglassEventKey.Timer: TimerEvent]
    private let settingsManager: SettingsManager
    weak var delegate: (EventNotifying & TimerHandling)?

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

    fileprivate init(analyticsManager: AnalyticsManager,
                     dataManager: DataManaging,
                     settingsManager: SettingsManager,
                     timerEventProvider: TimerEventProviding) {
        self.analyticsManager = analyticsManager
        self.timerModels = dataManager.timerModels
        self.settingsManager = settingsManager
        self.timerEvents = timerEventProvider.events
        configureEventSubscriptions()
        configureSettingsObservations()
    }

    private func configureEventSubscriptions() {
        timerEvents[.timerDidStart]?
            .sink { [weak self] timerModelId in
                guard let self else { return }
                activeTimerModelId = timerModelId
                activeTimerModel?.state = .active
            }
            .store(in: &cancellables)

        timerEvents[.timerDidComplete]?
            .sink { [weak self] timerModelId in
                guard let self else { return }
                guard let activeTimerModel, timerModelId == activeTimerModel.id else {
                    fatalError()
                }

                defer { self.activeTimerModelId = nil }

                setTimers(state: .inactive)
                delegate?.notifyUser(timerEvent: .timerDidComplete)

                switch activeTimerModel.category {
                case .focus:
                    focusStride += 1
                    showRestWarningIfNeeded()
                    enforceRestIfNeeded()
                case .rest:
                    resetFocusStride()
                    enforceFocusIfNeeded()
                }

                analyticsManager.logEvent(.timerDidComplete(activeTimerModel))
            }
            .store(in: &cancellables)

        timerEvents[.timerWasCancelled]?
            .sink { [weak self] timerModelId in
                guard let self else { return }
                guard let activeTimerModel, timerModelId == activeTimerModel.id else {
                    fatalError()
                }

                defer { self.activeTimerModelId = nil }

                activeTimerModel.state = .inactive
                analyticsManager.logEvent(.timerWasCancelled(activeTimerModel))
            }
            .store(in: &cancellables)
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

        settingsManager.observe(\.restWarningThreshold) { [self] newValue in
            didChangeRestSettings()
            analyticsManager.logEvent(.restWarningThresholdSet(newValue))
        }

        settingsManager.observe(\.enforceRestThreshold) { [self] newValue in
            didChangeRestSettings()
            analyticsManager.logEvent(.enforceRestThresholdSet(newValue))
        }

        settingsManager.observe(\.getBackToWork) { [self] isEnabled in
            if !isEnabled {
                if timerModels.filterByCategory(.rest).allSatisfy({$0.state == .disabled}) {
                    setTimers(category: .rest, state: .inactive)
                }
            }

            analyticsManager.logEvent(.getBackToWorkSet(isEnabled))
        }
    }

    private func didChangeTimerPreset(for timerModel: Timer.Model, to length: Int) {
        defer {
            timerModel.length = length
            analyticsManager.logEvent(.timerPresetSet(timerModel))
        }
        delegate?.resetTimer(for: timerModel)
    }

    private func didChangeRestSettings() {
        resetFocusStride()
        delegate?.resetActiveTimer()
        setTimers(state: .inactive)
    }

    private func resetFocusStride() {
        focusStride = 0
    }

    private func showRestWarningIfNeeded() {
        if let restWarningThreshold, focusStride == restWarningThreshold {
            delegate?.notifyUser(progressEvent: .restWarningThresholdMet)
        }
    }

    private func enforceRestIfNeeded() {
        if let enforceRestThreshold, focusStride == enforceRestThreshold {
            setTimers(category: .focus, state: .disabled)
            setTimers(category: .rest, state: .inactive)
            delegate?.notifyUser(progressEvent: .enforceRestThresholdMet)
        }
    }

    private func enforceFocusIfNeeded() {
        if getBackToWorkIsEnabled {
            delegate?.notifyUser(progressEvent: .getBackToWork)
            setTimers(category: .rest, state: .disabled)
            setTimers(category: .focus, state: .inactive)
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
    override init(analyticsManager: AnalyticsManager,
                  dataManager: DataManaging,
                  settingsManager: SettingsManager,
                  timerEventProvider: TimerEventProviding) {
        super.init(analyticsManager: analyticsManager,
                   dataManager: dataManager,
                   settingsManager: settingsManager,
                   timerEventProvider: timerEventProvider)
    }
}
