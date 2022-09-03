import UIKit
import FirebaseFirestore
import CoreData

class ConversationViewController: UIViewController {

    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var sendPictureButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBAction func handleSendMessageButton(_ sender: Any) {
        guard let text = messageTextField.text, !text.isEmpty else { return }
        self.model.sendMessage(content: text)
        messageTextField.text = ""
    }

    @IBAction func handleSendPictureButton(_ sender: Any) {
    }
    private var profileName: String = ""

    public var selectedId: String?
    public var selectedNBChannel: NBChannel?
    
    private lazy var model: MessagesModel = {
        let model = MessagesModel(self)
        return model
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messagesTableView.rowHeight = UITableView.automaticDimension
        self.messagesTableView.estimatedRowHeight = 56
        self.sendMessageButton.tintColor = Settings.currentColors.buttonColor
        self.sendPictureButton.tintColor = Settings.currentColors.buttonColor
        self.messagesTableView.backgroundColor = Settings.currentColors.backgroundColor
        self.sendMessageButton.isEnabled = false
        self.messageTextField.addTarget(self, action: #selector(textFieldDidChanged), for: .editingChanged)
        
        guard let channel = self.selectedNBChannel else { return }
        self.model.setSelectedChannel(channel: channel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.backgroundColor = Settings.currentColors.backgroundColor
        self.view.backgroundColor = Settings.currentColors.backgroundColor
        self.model.getMessages()
    }
    
    @objc func textFieldDidChanged() {
        guard let text = messageTextField.text, !text.isEmpty else {
            self.sendMessageButton.isEnabled = false
            return
        }
        self.sendMessageButton.isEnabled = true
    }
}

extension ConversationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ConversationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let sections = self.model.fetched.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        
        return sections[section].numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.messagesTableView.dequeueReusableCell(withIdentifier: "messageCell")
                as? MessageCell else { return MessageCell() }
        
        let message = self.model.getData(indexPath)
        if message.senderId == UIDevice.current.identifierForVendor?.uuidString ?? "" {
            cell.isOwn = true
        } else {
            cell.isOwn = false
        }
        
//        if let text = message.content {
//            if text.isValidURL(), let url = URL(string: text) {
//            cell.isImage = true
//              self.model.loadImage(url) { image in
//                  cell.image = image
//              }
//          }
//        }
        
        cell.messageText = message.content
        cell.date = message.created
        cell.senderName = message.senderName
        cell.build()
        cell.backgroundColor = Settings.currentColors.backgroundColor
        return cell
    }
}

extension String {
    func isValidURL() -> Bool {
        let regEx = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
        let predicate = NSPredicate(format: "SELF MATCHES %@", argumentArray: [regEx])
        return predicate.evaluate(with: self)
    }
}

extension ConversationViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.messagesTableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.messagesTableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }

            messagesTableView.insertRows(at: [newIndexPath], with: .bottom)

        case .delete:
            guard let indexPath = indexPath else { return }

            messagesTableView.deleteRows(at: [indexPath], with: .left)

        case .move:
            guard let indexPath = indexPath,
                    let newIndexPath = newIndexPath else { return }

            messagesTableView.deleteRows(at: [indexPath], with: .automatic)
            messagesTableView.insertRows(at: [newIndexPath], with: .automatic)

        case .update:
            guard let indexPath = indexPath else { return }

            messagesTableView.reloadRows(at: [indexPath], with: .automatic)

        @unknown default:
            return
        }
    }
    
    private func updateData(_ context: NSManagedObjectContext, id: String, content: String, created: Date, senderId: String, senderName: String) throws {
        try? self.model.updateData(context, id: id, content: content, created: created, senderId: senderId, senderName: senderName)
    }

    private func insertData(_ context: NSManagedObjectContext, id: String, content: String, created: Date, senderId: String, senderName: String) throws {
        try? self.model.insertData(context, id: id, content: content, created: created, senderId: senderId, senderName: senderName)
    }
}

extension ConversationViewController: IRefreshable {
    func refresh() {
        self.messagesTableView.reloadData()
    }
}

extension ConversationViewController: IMessageScrollable {
    func jumpToBottom() {

        guard let count = self.model.fetched.fetchedObjects?.count else { return }
        guard count > -1 + 1 else { return }
        
        let indexPath = IndexPath(item: count - 1, section: 0)
        self.messagesTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
}

// extension ConversationViewController: IPicturePickable {
//    func handlePicturePicked(image: UIImage, url: String) {
//        DispatchQueue.main.sync {
//            guard !url.isEmpty else { return }
//            self.model.sendMessage(content: url)
//        }
//    }
// }
