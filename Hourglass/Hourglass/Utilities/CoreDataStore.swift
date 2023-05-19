import CoreData

enum StorageType {
    case disk
    case inMemory
}

enum CoreDataModelName: String {
    case timeBlock = "TimeBlock"
}

struct CoreDataStore {
    private let container: NSPersistentContainer

    init(storageType: StorageType, modelName: CoreDataModelName) {
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
        try? container.viewContext.fetch(request)
    }

    func insert(object: NSManagedObject) {
        container.viewContext.insert(object)
    }

    func save() {
        guard container.viewContext.hasChanges else { return }

        do {
            try container.viewContext.save()
        } catch let error {
            print("Error persisting managed object: \(error)")
        }
    }
}
