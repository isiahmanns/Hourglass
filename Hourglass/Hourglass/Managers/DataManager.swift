import Combine
import CoreData
import Foundation

protocol DataManaging {
    var timerModels: [Timer.Model.ID: Timer.Model] { get }
    var timerCategoryTogglePresenterModel: TimerCategoryToggle.PresenterModel { get }
}

class DataManager: DataManaging {
    static let shared = DataManager(timerLengths: Constants.timerLengths,
                                    store: CoreDataStore.shared,
                                    timerEventProvider: TimerManager.shared)
    let timerModels: [Timer.Model.ID: Timer.Model]
    let timerCategoryTogglePresenterModel: TimerCategoryToggle.PresenterModel = .init()
    private let timerEvents: [HourglassEventKey.Timer: TimerEvent]
    private let store: CoreDataStore
    private var cancellables: Set<AnyCancellable> = []

    fileprivate init(timerLengths: [Int],
                     store: CoreDataStore,
                     timerEventProvider: TimerEventProviding) {
        self.timerModels = timerLengths.reduce(into: [Timer.Model.ID: Timer.Model]()) { partialResult, timerLength in
            let timerModel = Timer.Model(length: timerLength)
            partialResult[timerModel.id] = timerModel
        }
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

        timeBlock.category = Int16(Timer.Model.category.rawValue)
        timeBlock.start = now - TimeInterval(timerModel.length * 60)
        timeBlock.end = now
        return timeBlock
    }
}

class DataManagerMock: DataManager {
    override init(timerLengths: [Int],
                  store: CoreDataStore,
                  timerEventProvider: TimerEventProviding) {

        super.init(timerLengths: timerLengths,
                   store: store,
                   timerEventProvider: timerEventProvider)
    }
}
