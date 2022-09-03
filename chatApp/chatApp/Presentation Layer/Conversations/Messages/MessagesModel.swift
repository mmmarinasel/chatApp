import Foundation
import FirebaseFirestore
import CoreData

class MessagesModel {
    
    private lazy var database = Firestore.firestore()
    private lazy var reference = database.collection("channels")

    private let coreDataService: ICDSaveable = NewCoreDataService.get()
    
    private var delegate: (IRefreshable & NSFetchedResultsControllerDelegate & IMessageScrollable)?
    
    public var selectedNBChannel: NBChannel?

    private var profileName: String = ""
    private var loader: IRequestable = GCDRequest()
    
    public var fetched: NSFetchedResultsController<NBMessage> {
        return self.fetchedResultsController
    }
    
    private lazy var saveManager: GCDSaveManager = {
        let saveManager = GCDSaveManager()
        return saveManager
    }()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<NBMessage> = {
        let fetchRequest = NBMessage.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(NBMessage.created), ascending: true)
        ]
        guard let channel = self.selectedNBChannel else { return NSFetchedResultsController() }
        let id: String = channel.identifier ?? ""
        let predicate = NSPredicate(format: "channel.identifier = %@", "\(id)")
        fetchRequest.predicate = predicate
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
    
    public init(_ vc: NSFetchedResultsControllerDelegate & IRefreshable & IMessageScrollable) {
        self.delegate = vc
        
        saveManager.load { [weak self] data in
            self?.profileName = data.name ?? ""
        }
    }
    
    public func setSelectedChannel(channel: NBChannel) {
        self.selectedNBChannel = channel
        self.reference = database.collection("channels").document(selectedNBChannel?.identifier ?? "").collection("messages")
    }
    
    public func getData(_ indexPath: IndexPath) -> NBMessage {
        return fetchedResultsController.object(at: indexPath)
    }
    
    public func getMessages() {
        reference.addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                Logger.log(error?.localizedDescription ?? "No docs")
                return
            }
            Logger.log("get messages firebase process start")

            for doc in documents {
                let data = doc.data()
                let content = data["content"] as? String ?? ""
                let senderId = data["senderId"] as? String ?? ""
                let senderName = data["senderName"] as? String ?? ""
                let created = (data["created"] as? Timestamp)?.dateValue() ?? Date()
                let id = doc.documentID
                Logger.log("Firebase loaded content: \(content)")
                
                self?.coreDataService.performSave { [weak self] context in
                    try? self?.updateData(context,
                                          id: id,
                                          content: content,
                                          created: created,
                                          senderId: senderId,
                                          senderName: senderName)
                }
            }
            self?.delegate?.refresh()
            self?.delegate?.jumpToBottom()
        }
    }
    
    public func sendMessage(content: String) {
        reference.addDocument(data: ["content": content,
                                     "senderId": UIDevice.current.identifierForVendor?.uuidString ?? "",
                                     "senderName": self.profileName,
                                     "created": Date()
        ])
    }
    
    public func updateData(_ context: NSManagedObjectContext, id: String, content: String, created: Date, senderId: String, senderName: String) throws {
        let savedMessage = fetchedResultsController.fetchedObjects?.first(where: {
            $0.id == id
        })
        if savedMessage == nil {
            try? self.insertData(context,
                                 id: id,
                                 content: content,
                                 created: created,
                                 senderId: senderId,
                                 senderName: senderName)
            return
        }
        savedMessage?.senderName = senderName
        savedMessage?.senderId = senderId
        savedMessage?.created = created
        savedMessage?.content = content
        savedMessage?.id = id
    }

    public func insertData(_ context: NSManagedObjectContext, id: String, content: String, created: Date, senderId: String, senderName: String) throws {
        guard let newMessage = NSEntityDescription.insertNewObject(
            forEntityName: "NBMessage",
            into: context
        ) as? NBMessage else { throw NSError(domain: "",
                                             code: 0,
                                             userInfo: [NSLocalizedDescriptionKey: "Message creation failed"]) }
        
        newMessage.senderName = senderName
        newMessage.senderId = senderId
        newMessage.content = content
        newMessage.created = created
        newMessage.id = id
        
        selectedNBChannel?.addToMessages(newMessage)
    }
    
    func loadImage(_ url: URL, _ completion: @escaping (UIImage) -> Void,
                   _ cacheAction: @escaping (String, UIImage) -> Void) {
        loader.loadPic(url: url, completion, cacheAction)
    }
}
