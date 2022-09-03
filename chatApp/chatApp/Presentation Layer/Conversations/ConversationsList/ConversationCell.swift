import UIKit

protocol ConversationCellConfiguration {
    
    var name: String? { get set }
    var message: String? { get set }
    var date: Date? { get set }
    var online: Bool { get set }
    var hasUnreadMessages: Bool { get set }
}

class ConversationCell: UITableViewCell {

    @IBOutlet weak var conversationImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    private var messageContent: String?
    private var isOnline: Bool = false
    private var isTextBold: Bool = false
    private var messageDate: Date?
    let dateFormatter = DateFormatter()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension ConversationCell: ConversationCellConfiguration {

    var name: String? {
        get { return self.nameLabel.text }
        set {
            self.nameLabel.text = newValue
            self.nameLabel.textColor = Settings.currentColors.textColor
        }
    }
    
    var message: String? {
        get { return self.messageContent }
        set {
            if newValue != nil {
                self.messageLabel.text = newValue
                self.messageContent = newValue
            } else {
                self.messageContent = nil
                self.messageLabel.font = .italicSystemFont(ofSize: 13)
                self.messageLabel.text = "No messages yet"
            }
            self.messageLabel.textColor = Settings.currentColors.textColor
        }
    }

    var date: Date? {
        get { return self.messageDate }
        set {
            guard newValue != nil else {
                self.dateLabel.text = ""
                self.messageDate = nil
                return
            }
            let diffComponents = Calendar.current.dateComponents([.hour], from: newValue ?? Date(), to: Date())
            if diffComponents.hour ?? 0 >= 24 {
                self.dateFormatter.dateFormat = "dd MMM"
            } else {
                self.dateFormatter.dateFormat = "HH:mm"
            }
            self.messageDate = newValue ?? Date()
            self.dateLabel.text = dateFormatter.string(from: newValue ?? Date())
            self.dateLabel.textColor = Settings.currentColors.textColor
        }
    }

    var online: Bool {
        get { return self.isOnline }
        set { self.isOnline = newValue }
    }

    var hasUnreadMessages: Bool {
        get { return self.isTextBold }
        set {
            self.isTextBold = newValue
            if isTextBold {
                self.messageLabel.font = .boldSystemFont(ofSize: 13)
            } else if self.messageContent != nil {
                self.messageLabel.font = .systemFont(ofSize: 13)
            }
        }
    }
}
