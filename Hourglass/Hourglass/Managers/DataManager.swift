import Combine
import CoreData
import Foundation

protocol DataManaging {
    var timerModels: [TimerButton.PresenterModel.ID: TimerButton.PresenterModel] { get }
    var timerCategoryTogglePresenterModel: TimerCategoryToggle.PresenterModel { get }
}

class DataManager: DataManaging {
    static let shared = DataManager(timerLengths: Constants.timerLengths,
                                    store: CoreDataStore.shared,
                                    timerEventProvider: TimerManager.shared)
    let timerModels: [TimerButton.PresenterModel.ID: TimerButton.PresenterModel]
    let timerCategoryTogglePresenterModel: TimerCategoryToggle.PresenterModel = .init()
    private let timerEvents: [HourglassEventKey.Timer: TimerEvent]
    private let store: CoreDataStore
    private var cancellables: Set<AnyCancellable> = []

    fileprivate init(timerLengths: [Int],
                     store: CoreDataStore,
                     timerEventProvider: TimerEventProviding) {
        self.timerModels = timerLengths.reduce(into: [TimerButton.PresenterModel.ID: TimerButton.PresenterModel]()) { partialResult, timerLength in
            let timerModel = TimerButton.PresenterModel(length: timerLength)
            partialResult[timerModel.id] = timerModel
        }
        self.store = store
        self.timerEvents = timerEventProvider.events
        configureEventSubscriptions()
    }

    private func configureEventSubscriptions() {
        timerEvents[.timerDidComplete]?
            .sink { [weak self] timerModelId, timerCategory in
                guard let self else { return }
                guard let timerModel = timerModels[timerModelId] else { return }
                let timeBlock = createTimeBlock(from: timerModel, for: timerCategory)
                store.insert(object: timeBlock)
                store.save()
            }
            .store(in: &cancellables)
    }

    private func createTimeBlock(from timerModel: TimerButton.PresenterModel,
                                 for timerCategory: TimerCategory) -> TimeBlock {
        let now = Date.now
        let entity = NSEntityDescription.entity(forEntityName: CoreDataEntity.timeBlock.rawValue,
                                                in: store.context)
        let timeBlock = NSManagedObject(entity: entity!, insertInto: nil) as! TimeBlock

        timeBlock.category = Int16(timerCategory.rawValue)
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
