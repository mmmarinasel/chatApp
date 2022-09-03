import CoreData

class NewCoreDataService: ICDSaveable {

    private static var instance: NewCoreDataService = NewCoreDataService()
    
    private lazy var container: NSPersistentContainer = {
       let container = NSPersistentContainer(name: "Chat")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as? NSError {
                fatalError(error.localizedDescription)
            } else {
                print(storeDescription)
            }
        }
        return container
    }()
    
    private lazy var mainContext: NSManagedObjectContext = {
        let context = self.container.viewContext
        return context
    }()
    
    private lazy var privateContext: NSManagedObjectContext = {
        let context = self.container.newBackgroundContext()
        return context
    }()
    
    private init() {
        self.privateContext.mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)
    }
    
    public static func get() -> NewCoreDataService {
        return NewCoreDataService.instance
    }
    
    public func fetchChannels() -> [NBChannel] {
        let fetchRequest: NSFetchRequest<NBChannel> = NBChannel.fetchRequest()
        let fetched = try? mainContext.fetch(fetchRequest)
        
        return fetched ?? []
    }
    
    public func fetchChannels(_ id: String) -> [NBChannel] {
        let fetchRequest: NSFetchRequest<NBChannel> = NBChannel.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "identifier LIKE %@", "\(id)")
        let fetched = try? mainContext.fetch(fetchRequest)
        return fetched ?? []
    }
    
    public func performSave(_ block: @escaping(NSManagedObjectContext) -> Void) {
        privateContext.perform {
            block(self.mainContext)
            if self.mainContext.hasChanges {
                do {
                    try self.mainContext.save()
                    Logger.log("successfully saved context")
                } catch {
                    print(error.localizedDescription)
                }
            }
            
        }
    }
    
    public func getPrivateContext() -> NSManagedObjectContext {
        return self.privateContext
    }
    
    public func getMainContext() -> NSManagedObjectContext {
        return self.mainContext
    }

    func performTaskOnMainQueueContextAndSave(_ block: @escaping (NSManagedObjectContext) -> Void) {
        self.mainContext.performAndWait {
            block(self.mainContext)
        }
        saveViewContext()
    }

    private func saveViewContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
