import Combine

protocol DataManaging {
    var timerModels: [Timer.Model.ID: Timer.Model] { get }
}

class DataManager: DataManaging {
    static let shared = DataManager(settingsManager: SettingsManager.shared,
                                    timerEventProvider: TimerManager.shared)
    let timerModels: [Timer.Model.ID: Timer.Model]
    private let timerEvents: [HourglassEventKey.Timer: TimerEvent]
    private var cancellables: Set<AnyCancellable> = []

    private init(settingsManager: SettingsManager,
                 timerEventProvider: TimerEventProviding) {
        let timerModels = [
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
        self.timerModels = Dictionary(uniqueKeysWithValues: timerModels.map { ($0.id, $0) })
        self.timerEvents = timerEventProvider.events
        configureEventSubscriptions()
    }

    private func configureEventSubscriptions() {
        timerEvents[.timerDidComplete]?
            .sink { [weak self] timerModelId in
                guard let self else { return }
                guard let timerModel = timerModels[timerModelId] else { return }
                // TODO: - Persist data
            }
            .store(in: &cancellables)
    }
}

struct DataManagerMock: DataManaging {
    let timerModels: [Timer.Model.ID: Timer.Model]

    init(timerModels: [Timer.Model]) {
        self.timerModels = Dictionary(uniqueKeysWithValues: timerModels.map { ($0.id, $0) })
    }
}

// TODO: - Persist and fetch completed time blocks for statistics window
