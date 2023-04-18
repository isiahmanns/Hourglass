protocol DataManaging {
    func loadTimerModels() -> [Timer.Model.ID: Timer.Model]
}

struct DataManager: DataManaging {
    static let shared = DataManager(settingsManager: SettingsManager.shared)
    let settingsManager: SettingsManager

    private init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
    }

    func loadTimerModels() -> [Timer.Model.ID: Timer.Model] {
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

        return Dictionary(uniqueKeysWithValues: timerModels.map { ($0.id, $0) })
    }
}

struct DataManagerMock: DataManaging {
    let timerModels: [Timer.Model]

    func loadTimerModels() -> [Timer.Model.ID: Timer.Model] {
        return Dictionary(uniqueKeysWithValues: timerModels.map { ($0.id, $0) })
    }
}

// TODO: - Persist and fetch completed time blocks for statistics window
