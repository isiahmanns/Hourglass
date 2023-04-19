protocol DataManaging {
    func getTimerModels() -> [Timer.Model.ID: Timer.Model]
}

class DataManager: DataManaging {
    static let shared = DataManager(settingsManager: SettingsManager.shared)
    let timerModels: [Timer.Model]

    private init(settingsManager: SettingsManager) {
        self.timerModels = [
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

    func getTimerModels() -> [Timer.Model.ID: Timer.Model] {
        return Dictionary(uniqueKeysWithValues: timerModels.map { ($0.id, $0) })
    }
}

struct DataManagerMock: DataManaging {
    let timerModels: [Timer.Model]

    func getTimerModels() -> [Timer.Model.ID: Timer.Model] {
        return Dictionary(uniqueKeysWithValues: timerModels.map { ($0.id, $0) })
    }
}

// TODO: - Persist and fetch completed time blocks for statistics window
