protocol DataManaging {
    func loadTimerModels() -> [Timer.Model]
}

struct DataManager: DataManaging {
    static let shared = DataManager(settingsManager: SettingsManager.shared)
    let settingsManager: SettingsManager

    private init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
    }

    func loadTimerModels() -> [Timer.Model] {
        [Timer.Model(length: settingsManager.getTimerLength(for: .timerFocusSmall),
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
                     size: .large)]
    }
}

struct DataManagerMock: DataManaging {
    let timerModels: [Timer.Model]

    func loadTimerModels() -> [Timer.Model] {
        return timerModels
    }
}

// TODO: - Persist and fetch completed time blocks for statistics window
