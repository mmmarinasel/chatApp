import UIKit

protocol MessageCellConfiguration {
    var messageText: String? { get set }
    var isOwn: Bool { get set }
    var date: Date? { get set }
    var senderName: String? { get set }
}

class MessageCell: UITableViewCell {

    private let horPadding: CGFloat = 16
    private let verPadding: CGFloat = 5
    
    private var bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    private var messageTextLabel = UILabel()
    private var senderNameLabel = UILabel()
    private var dateLabel = UILabel()
    
    private var _date: Date?
    private var alignRight: Bool = false
    private var incomingMessageColor = Settings.currentColors.incomingMessageColor
    private var outgoingMessageColor = Settings.currentColors.outgoingMessageColor
    private var _messageText: String = ""
    let dateFormatter = DateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func build() {
        self.addSubview(bubbleView)
        
        bubbleView.addSubview(dateLabel)
        bubbleView.addSubview(senderNameLabel)
        bubbleView.addSubview(messageTextLabel)
        
        self.messageTextLabel.text = _messageText
        self.messageTextLabel.sizeToFit()
    
        self.senderNameLabel.sizeToFit()
        self.messageTextLabel.textColor = Settings.currentColors.textColor
        self.senderNameLabel.textColor = Settings.currentColors.textColor
        self.dateLabel.textColor = Settings.currentColors.textColor
        self.dateLabel.font = UIFont.systemFont(ofSize: 13)
        self.senderNameLabel.font = UIFont.boldSystemFont(ofSize: 15)
        
        self.messageTextLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.senderNameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.messageTextLabel.numberOfLines = 0
        self.senderNameLabel.numberOfLines = 0
        self.dateLabel.sizeToFit()
        
        var constraints: [NSLayoutConstraint] = [
            senderNameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 2 * verPadding),
            senderNameLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: horPadding),
            messageTextLabel.topAnchor.constraint(equalTo: senderNameLabel.bottomAnchor, constant: verPadding),
            messageTextLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: horPadding),
            dateLabel.topAnchor.constraint(equalTo: messageTextLabel.bottomAnchor, constant: verPadding),
            dateLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -horPadding),
            bubbleView.topAnchor.constraint(equalTo: senderNameLabel.topAnchor, constant: -verPadding),
            bubbleView.bottomAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: verPadding),
            self.bottomAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: verPadding)
        ]
        
        if let widestView = self.getWidestWidth([messageTextLabel, senderNameLabel, dateLabel]) {
            if widestView.frame.width + 2 * horPadding + horPadding >= self.frame.width * 0.75 {
                constraints.append(bubbleView.widthAnchor.constraint(equalToConstant: self.frame.width * 0.75 - horPadding))
            } else {
                constraints.append(bubbleView.widthAnchor.constraint(equalTo: widestView.widthAnchor, constant: 2 * horPadding))
            }
        }
        
        if messageTextLabel.frame.width + 2 * horPadding + horPadding >= self.frame.width * 0.75 {
            constraints.append(self.messageTextLabel.widthAnchor.constraint(equalToConstant: self.frame.width * 0.75 - 2 * horPadding - horPadding))
        }
        
        if senderNameLabel.frame.width + 2 * horPadding + horPadding >= self.frame.width * 0.75 {
            constraints.append(self.senderNameLabel.widthAnchor.constraint(equalToConstant: self.frame.width * 0.75 - 2 * horPadding - horPadding))
        }

        if self.alignRight {
            constraints.append(bubbleView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -horPadding))
        } else {
            constraints.append(bubbleView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: horPadding))
        }
        
        bubbleView.backgroundColor = isOwn ? outgoingMessageColor : incomingMessageColor
        NSLayoutConstraint.activate(constraints)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.messageTextLabel.removeFromSuperview()
        self.dateLabel.removeFromSuperview()
        self.senderNameLabel.removeFromSuperview()
        self.bubbleView.removeFromSuperview()
        bubbleView = UIView()
        messageTextLabel = UILabel()
        senderNameLabel = UILabel()
        dateLabel = UILabel()
        bubbleView.layer.cornerRadius = 10
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        messageTextLabel.translatesAutoresizingMaskIntoConstraints = false
        senderNameLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func getWidestWidth(_ views: [UIView]) -> UIView? {
        guard !views.isEmpty else { return nil }
        
        var maxW: CGFloat = 0
        var maxV: UIView?
        for v in views where v.frame.width > maxW {
            maxW = v.frame.width
            maxV = v
        }
        return maxV
    }
}

extension MessageCell: MessageCellConfiguration {
    var date: Date? {
        get {
            return self._date
        }
        set {
            guard newValue != nil else {
                self.dateLabel.text = ""
                self._date = nil
                return
            }
            let diffComponents = Calendar.current.dateComponents([.hour], from: newValue ?? Date(), to: Date())
            if diffComponents.hour ?? 0 >= 24 {
                self.dateFormatter.dateFormat = "dd MMM"
            } else {
                self.dateFormatter.dateFormat = "HH:mm"
            }
            self._date = newValue ?? Date()
            self.dateLabel.text = dateFormatter.string(from: newValue ?? Date())
            self.dateLabel.textColor = Settings.currentColors.textColor
        }
    }
    
    var senderName: String? {
        get {
            return self.senderNameLabel.text
        }
        set {
            self.senderNameLabel.text = newValue
            self.senderNameLabel.textColor = Settings.currentColors.textColor
        }
    }
    
    var messageText: String? {
        get { return _messageText }
        set {
            _messageText = newValue ?? ""
        }
    }
    
    var isOwn: Bool {
        get { return self.alignRight }
        set { self.alignRight = newValue }
    }
}
