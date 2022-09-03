import CoreData

final class OldCoreDataService {

    private static var instance = OldCoreDataService()
    
    private init() {
    }
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let moduleURL = Bundle.main.url(forResource: "Chat", withExtension: "momd")
        return NSManagedObjectModel(contentsOf: moduleURL ?? URL(fileURLWithPath: "")) ?? NSManagedObjectModel()
    }()

    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        let fileManager = FileManager.default
        let storeName = "Chat.sqlite"

        let documentDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]

        let persistentStoreURL = documentDirectoryURL.appendingPathComponent(storeName)
        
        let dummy = try? coordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: persistentStoreURL)
        
        return coordinator
    }()

    private lazy var readContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        return context
    }()

    private lazy var writeContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        context.mergePolicy = NSOverwriteMergePolicy
        return context
    }()
    
    public static func get() -> OldCoreDataService {
        return instance
    }

    func fetchChannels() -> [NBChannel] {
        let fetchRequest: NSFetchRequest<NBChannel> = NBChannel.fetchRequest()
        return (try? readContext.fetch(fetchRequest)) ?? []
    }
    
    func fetchChannels(_ id: String) -> [NBChannel] {
        let fetchRequest: NSFetchRequest<NBChannel> = NBChannel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier LIKE %@", "\(id)")
        let fetched = try? readContext.fetch(fetchRequest)
        return fetched ?? []
    }

    func performSave(_ block: @escaping(NSManagedObjectContext) -> Void) {
        let context = writeContext
        context.perform {
            block(context)
            if context.hasChanges {
                do {
                    try self.performSave(in: context)
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            }

        }
    }

    public func performSave(in context: NSManagedObjectContext) throws {
        try context.save()
    }
    
    func getPrivateContext() -> NSManagedObjectContext {
        return self.writeContext
    }
    
    func getMainContext() -> NSManagedObjectContext {
        return self.readContext
    }
}
