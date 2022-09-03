import Foundation
import FirebaseFirestore
import CoreData

class ChannelsModel {
    
    private lazy var database = Firestore.firestore()
    private lazy var reference = database.collection("channels")
    
    private let coreDataService: ICDSaveable = NewCoreDataService.get()
    
    private var delegate: (IRefreshable & NSFetchedResultsControllerDelegate)?
    
    public var fetched: NSFetchedResultsController<NBChannel> {
        return self.fetchedResultsController
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<NBChannel> = {
        let fetchRequest = NBChannel.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(NBChannel.lastActivity), ascending: false)
        ]
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: coreDataService.getMainContext(),
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        controller.delegate = self.delegate
        do {
            try controller.performFetch()
        } catch {
            Logger.log(error.localizedDescription)
        }
        return controller
    }()
    
    public init(_ vc: NSFetchedResultsControllerDelegate & IRefreshable) {
        self.delegate = vc
    }
    
    public func getData(_ indexPath: IndexPath) -> NBChannel {
        return fetchedResultsController.object(at: indexPath)
    }
    
    public func getChannels() {
        reference.addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                
                Logger.log(error?.localizedDescription ?? "No docs")
                return
            }
            for document in documents {
                let data = document.data()
                let name = data["name"] as? String ?? ""
                let identifier = document.documentID
                let lastMessage = data["lastMessage"] as? String ?? ""
                let lastActivity = (data["lastActivity"] as? Timestamp)?.dateValue()
                Logger.log("Firebase loaded name: \(name)")
                
                self.coreDataService.performSave { [weak self] context in
                    try? self?.updateData(context,
                                          identifier: identifier,
                                          name: name,
                                          lastMessage: lastMessage,
                                          lastActivity: lastActivity)
                }
            }
            Logger.log("Firebase loaded")
            self.delegate?.refresh()
        }
    }
    
    public func addChannel(name: String) {
        let values: [String: Any] = ["name": name, "lastMessage": "", "lastActivity": ""]
        reference.addDocument(data: values)
    }
    
    public func deleteChannel(identifier: String) {
        
        reference.document(identifier).delete { error in
            if error != nil {
                Logger.log(error?.localizedDescription ?? "error")
            } else {
                Logger.log("Document successfully removed!")
            }
        }
    }
    
    public func updateData(_ context: NSManagedObjectContext, identifier: String, name: String, lastMessage: String?, lastActivity: Date?) throws {
        let savedChannel = fetchedResultsController.fetchedObjects?.first(where: {
            $0.identifier == identifier
        })
        if savedChannel == nil {
            try? self.insertData(context,
                                 identifier: identifier,
                                 name: name,
                                 lastMessage: lastMessage,
                                 lastActivity: lastActivity)
            return
        }
        
        savedChannel?.identifier = identifier
        savedChannel?.lastActivity = lastActivity
        savedChannel?.lastMessage = lastMessage
        savedChannel?.name = name
        
    }

    public func insertData(_ context: NSManagedObjectContext, identifier: String?, name: String, lastMessage: String?, lastActivity: Date?) throws {
        guard let newChannel = NSEntityDescription.insertNewObject(
            forEntityName: "NBChannel",
            into: context
        ) as? NBChannel else { throw NSError(domain: "",
                                             code: 0,
                                             userInfo: [NSLocalizedDescriptionKey: "Channel creation failed"]) }
        
        newChannel.name = name
        newChannel.identifier = identifier
        newChannel.lastMessage = lastMessage
        newChannel.lastActivity = lastActivity
    }

    public func deleteData(_ context: NSManagedObjectContext, channel: NBChannel) throws {
        
        deleteChannel(identifier: channel.identifier ?? "")
        coreDataService.performSave { context in
            context.delete(channel)
        }
        
    }
}
