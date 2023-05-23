import Combine
import CoreData
import Foundation

protocol DataManaging {
    var timerModels: [Timer.Model.ID: Timer.Model] { get }
}

class DataManager: DataManaging {
    static let shared = DataManager(settingsManager: SettingsManager.shared,
                                    store: CoreDataStore.shared,
                                    timerEventProvider: TimerManager.shared)
    let timerModels: [Timer.Model.ID: Timer.Model]
    private let timerEvents: [HourglassEventKey.Timer: TimerEvent]
    private let store: CoreDataStore
    private var cancellables: Set<AnyCancellable> = []

    private convenience init(settingsManager: SettingsManager,
                             store: CoreDataStore,
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

        self.init(timerModels: timerModels,
                  store: store,
                  timerEventProvider: timerEventProvider)
    }

    fileprivate init(timerModels: [Timer.Model],
                     store: CoreDataStore,
                     timerEventProvider: TimerEventProviding) {
        self.timerModels = Dictionary(uniqueKeysWithValues: timerModels.map { ($0.id, $0) })
        self.store = store
        self.timerEvents = timerEventProvider.events
        configureEventSubscriptions()
    }

    private func configureEventSubscriptions() {
        timerEvents[.timerDidComplete]?
            .sink { [weak self] timerModelId in
                guard let self else { return }
                guard let timerModel = timerModels[timerModelId] else { return }
                let timeBlock = createTimeBlock(from: timerModel)
                store.insert(object: timeBlock)
                store.save()
            }
            .store(in: &cancellables)
    }

    private func createTimeBlock(from timerModel: Timer.Model) -> TimeBlock {
        let now = Date.now
        let entity = NSEntityDescription.entity(forEntityName: CoreDataEntity.timeBlock.rawValue,
                                                in: store.context)
        let timeBlock = NSManagedObject(entity: entity!, insertInto: nil) as! TimeBlock

        timeBlock.category = Int16(timerModel.category.rawValue)
        timeBlock.start = now - TimeInterval(timerModel.length * 60)
        timeBlock.end = now
        return timeBlock
    }
}

class DataManagerMock: DataManager {
    override init(timerModels: [Timer.Model],
                  store: CoreDataStore,
                  timerEventProvider: TimerEventProviding) {

        super.init(timerModels: timerModels,
                   store: store,
                   timerEventProvider: timerEventProvider)
    }
}
