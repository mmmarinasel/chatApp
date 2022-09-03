import UIKit
import FirebaseFirestore
import CoreData

class ConversationsListViewController: UIViewController {
    
    @IBOutlet weak var conversationsTableView: UITableView!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    
    @IBAction func addChannelHandleButton(_ sender: Any) {
        buindAddChannelAlert()
    }
    
    private let rowHeight: CGFloat = 89
    private var selectedId: String?
    private var selectedUserName: String?

    var selectedNBChannel: NBChannel?
    
    private lazy var model: ChannelsModel = {
        let model = ChannelsModel(self)
        return model
    }()
    
    private let coreDataService = NewCoreDataService.get()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Logger.setEnabled(true)
        
        let saveManager = GCDSaveManager()
        saveManager.loadTheme { theme in
            Settings.appTheme = theme
        }
        
        navigationItem.title = "Channels"

        if #available(iOS 15.0, *) {
            conversationsTableView.sectionHeaderTopPadding = 0.0
        }
        self.model.getChannels()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barTintColor = Settings.currentColors.backgroundColor
        self.view.backgroundColor = Settings.currentColors.backgroundColor
        self.conversationsTableView.backgroundColor = Settings.currentColors.sectionBarColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Settings.currentColors.textColor]
        self.navigationController?.navigationBar.tintColor = Settings.currentColors.buttonColor

    }
    
    func buindAddChannelAlert() {
        let alert = UIAlertController(title: "Создать канал", message: nil, preferredStyle: .alert)
        var alertTextField: UITextField!
        alert.addTextField { textField in
            alertTextField = textField
            textField.placeholder = "Новый канал"
        }
        let createButton = UIAlertAction(title: "Создать", style: .default) { [weak self] _ in
            guard let text = alertTextField.text, !text.isEmpty else { return }
            self?.model.addChannel(name: text)
        }
        let cancelButton = UIAlertAction(title: "Отмена", style: .destructive, handler: nil)
        alert.addAction(createButton)
        alert.addAction(cancelButton)
        present(alert, animated: true, completion: nil)
        self.conversationsTableView.reloadData()
    }
}

extension ConversationsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let channel = self.model.getData(indexPath)
        self.selectedId = channel.identifier
        self.selectedNBChannel = channel
        self.selectedUserName = channel.name
        self.performSegue(withIdentifier: "conversationSegue", sender: self)
    }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "conversationSegue":
            guard let vc = segue.destination as? ConversationViewController else { return }
            vc.navigationItem.title = self.selectedUserName
            vc.selectedId = self.selectedId
            vc.selectedNBChannel = self.selectedNBChannel
            
        case "settingsSegue":
            guard let vc = segue.destination as? ThemesViewController else { return }
            vc.closure = { [weak self] theme in
                self?.updateTheme(theme: theme)
            }
            vc.delegate = self
        default: return
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let channel = self.model.getData(indexPath)
        if editingStyle == .delete {
            try? self.deleteData(self.coreDataService.getMainContext(), channel: channel)
        }
    }
}

extension ConversationsListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let sections = self.model.fetched.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        return sections[section].numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.conversationsTableView.dequeueReusableCell(withIdentifier: "conversationCell")
                as? ConversationCell else { return ConversationCell() }
        
        let channel = self.model.getData(indexPath)
        cell.message = channel.lastMessage
        cell.date = channel.lastActivity
        cell.name = channel.name
        cell.backgroundColor = Settings.currentColors.conversationOnlineCellColor

        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = Settings.currentColors.sectionBarColor
    }
}

extension ConversationsListViewController: ThemesPickerDelegate {
    func updateTheme(theme: Settings.Theme) {
        Settings.appTheme = theme
        conversationsTableView.reloadData()
    }  
}

extension ConversationsListViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.conversationsTableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.conversationsTableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }

            conversationsTableView.insertRows(at: [newIndexPath], with: .bottom)

        case .delete:
            guard let indexPath = indexPath else { return }

            conversationsTableView.deleteRows(at: [indexPath], with: .left)

        case .move:
            guard let indexPath = indexPath,
                    let newIndexPath = newIndexPath else { return }

            conversationsTableView.deleteRows(at: [indexPath], with: .automatic)
            conversationsTableView.insertRows(at: [newIndexPath], with: .automatic)

        case .update:
            guard let indexPath = indexPath else { return }

            conversationsTableView.reloadRows(at: [indexPath], with: .automatic)

        @unknown default:
            return
        }
    }
    
    private func updateData(_ context: NSManagedObjectContext, identifier: String, name: String, lastMessage: String?, lastActivity: Date?) throws {

        try? self.model.updateData(context, identifier: identifier, name: name, lastMessage: lastMessage, lastActivity: lastActivity)
    }

    private func insertData(_ context: NSManagedObjectContext, identifier: String?, name: String, lastMessage: String?, lastActivity: Date?) throws {
        try? self.model.insertData(context, identifier: identifier, name: name, lastMessage: lastMessage, lastActivity: lastActivity)
    }

    private func deleteData(_ context: NSManagedObjectContext, channel: NBChannel) throws {
        try? self.model.deleteData(context, channel: channel)
    }
}

extension ConversationsListViewController: IRefreshable {
    func refresh() {
        self.conversationsTableView.reloadData()
    }
}
