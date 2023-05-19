import CoreData

enum StorageType {
    case disk
    case inMemory
}

enum CoreDataModel: String {
    case timerHistory = "TimerHistory"
}

enum CoreDataEntity: String {
    case timeBlock = "TimeBlock"
}

class CoreDataStore {
    static let shared = CoreDataStore(storageType: .disk, modelName: .timerHistory)
    private let container: NSPersistentContainer
    lazy var context: NSManagedObjectContext = container.viewContext

    fileprivate init(storageType: StorageType, modelName: CoreDataModel) {
        self.container = NSPersistentContainer(name: modelName.rawValue)
        configureStores(for: storageType)
        loadStores()
    }

    private func configureStores(for storageType: StorageType) {
        switch storageType {
        case .inMemory:
            let url = URL.init(filePath: "/dev/null")
            let description = NSPersistentStoreDescription(url: url)
            container.persistentStoreDescriptions = [description]
        default:
            break
        }
    }

    private func loadStores() {
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
    }

    func fetch<T>(_ request: NSFetchRequest<T>) -> [T]? where T: NSFetchRequestResult {
        try? context.fetch(request)
    }

    func insert(object: NSManagedObject) {
        context.insert(object)
    }

    func save() {
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch let error {
            print("Error persisting managed object: \(error)")
        }
    }
}

class CoreDataTestStore: CoreDataStore {
    init() {
        super.init(storageType: .inMemory, modelName: .timerHistory)
    }
}
