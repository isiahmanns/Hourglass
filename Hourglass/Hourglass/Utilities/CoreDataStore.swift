import CoreData

enum StorageType {
    case disk
    case inMemory
}

struct CoreDataStore {
    private let container: NSPersistentContainer

    init(storageType: StorageType, modelName: String) {
        self.container = NSPersistentContainer(name: modelName)
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

    func save(object: NSManagedObject) {
        container.viewContext.insert(object)

        guard container.viewContext.hasChanges else { return }

        do {
            try container.viewContext.save()
        } catch let error {
            print("Error persisting managed object: \(error)")
        }
    }
}
