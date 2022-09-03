import UIKit

protocol ThemesPickerDelegate: AnyObject {
    func updateTheme(theme: Settings.Theme)
}

class ThemesViewController: UIViewController {
    
    @IBOutlet weak var classicThemeView: UIView!
    @IBOutlet weak var dayThemeView: UIView!
    @IBOutlet weak var nightThemeView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    
    private var tapClassic: UITapGestureRecognizer!
    private var tapDay: UITapGestureRecognizer!
    private var tapNight: UITapGestureRecognizer!
    
    @IBAction func handleClassicThemeButton(_ sender: Any) {
//        self.delegate?.updateTheme(theme: .classic)
        self.closure?(.classic)
        handleTap(self.tapClassic)
    }
    
    @IBAction func handleDayThemeButton(_ sender: Any) {
//        self.delegate?.updateTheme(theme: .day)
        self.closure?(.day)
        handleTap(self.tapDay)
    }
    
    @IBAction func handleNightThemeButton(_ sender: Any) {
//        self.delegate?.updateTheme(theme: .night)
        self.closure?(.night)
        handleTap(self.tapNight)
    }
    
//    если бы не было weak, возник бы retain cycle
    weak var delegate: ThemesPickerDelegate?
    var closure: ((Settings.Theme) -> Void )?
    
    private var bubbleViews: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRecognizer(view: self.classicThemeView,
                      tapGestureRecognizer: &tapClassic,
                      action: #selector(handleTap(_:)))
        setRecognizer(view: self.dayThemeView,
                      tapGestureRecognizer: &tapDay,
                      action: #selector(handleTap(_:)))
        setRecognizer(view: self.nightThemeView,
                      tapGestureRecognizer: &tapNight,
                      action: #selector(handleTap(_:)))
        self.view.backgroundColor = Settings.currentColors.backgroundColor
        self.backgroundView.backgroundColor = Settings.currentColors.settingsBackgroundColor
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationItem.title = "Settings"
        for view in 0..<self.bubbleViews.count {
            self.bubbleViews[view].removeFromSuperview()
        }
            buildBubbleDemo(.systemGray4, UIColor(red: 129 / 256,
                                                  green: 232 / 256,
                                                  blue: 252 / 256,
                                                  alpha: 1),
                            view: classicThemeView)
            buildBubbleDemo(.systemGray5, UIColor(red: 214 / 256,
                                                  green: 249 / 256,
                                                  blue: 192 / 256,
                                                  alpha: 1),
                            view: dayThemeView)
            buildBubbleDemo(UIColor(red: 0.18,
                                    green: 0.18,
                                    blue: 0.18,
                                    alpha: 1), .gray,
                            view: nightThemeView)
    }
    
    func setRecognizer(view: UIView, tapGestureRecognizer: inout UITapGestureRecognizer?, action: Selector?) {
        view.layer.cornerRadius = 20
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: action)
        guard let tapGR = tapGestureRecognizer else { return }
        view.addGestureRecognizer(tapGR)
    }

    func buildBubbleDemo(_ incomingMessageColor: UIColor, _ outgoingMessageColor: UIColor, view: UIView) {
        let incomingMessageView = createFoundationView(view: view, color: incomingMessageColor)
        let outgoingMessageView = createFoundationView(view: view, color: outgoingMessageColor)
        buildDemoConstraints(isIncoming: true, view: incomingMessageView, parentView: view)
        buildDemoConstraints(isIncoming: false, view: outgoingMessageView, parentView: view)
    }
    
    func createFoundationView(view: UIView, color: UIColor) -> UIView {
        let foundationView = UIView()
        view.addSubview(foundationView)
        foundationView.backgroundColor = color
        foundationView.translatesAutoresizingMaskIntoConstraints = false
        foundationView.layer.cornerRadius = 10
        self.bubbleViews.append(foundationView)
        return foundationView
    }

    func buildDemoConstraints(isIncoming: Bool, view: UIView, parentView: UIView) {
        let constraints = [
            view.topAnchor.constraint(equalTo: parentView.topAnchor,
                                      constant: isIncoming ? 10 : 20),
            view.bottomAnchor.constraint(equalTo: parentView.bottomAnchor,
                                         constant: isIncoming ? -20 : -10),
            view.leadingAnchor.constraint(equalTo: parentView.leadingAnchor,
                                          constant: isIncoming ?
                                                    parentView.frame.width / 8 :
                                                    parentView.frame.width * 0.52),
            view.trailingAnchor.constraint(equalTo: parentView.trailingAnchor,
                                           constant: isIncoming ? -parentView.frame.width * 0.52 : -parentView.frame.width / 8)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func tapTheme(_ theme: Settings.Theme, view: UIView) {
//        self.delegate?.updateTheme(theme: theme)
        self.closure?(theme)
        view.layer.borderColor = UIColor.systemBlue.cgColor
        view.layer.borderWidth = 4
//        Settings.saveTheme(theme: theme)
//        saveManager.saveTheme(theme)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.classicThemeView.layer.borderWidth = 0
        self.dayThemeView.layer.borderWidth = 0
        self.nightThemeView.layer.borderWidth = 0
        switch sender {
        case self.tapClassic:
            tapTheme(.classic, view: classicThemeView)
        case self.tapDay:
            tapTheme(.day, view: dayThemeView)
        case self.tapNight:
            tapTheme(.night, view: nightThemeView)
        default: return
        }
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Settings.currentColors.textColor]
        self.navigationController?.navigationBar.tintColor = Settings.currentColors.buttonColor
        self.navigationController?.navigationBar.backgroundColor = Settings.currentColors.backgroundColor
        self.backgroundView.backgroundColor = Settings.currentColors.settingsBackgroundColor
        self.view.backgroundColor = Settings.currentColors.backgroundColor
    }
}
