import UIKit
import SpriteKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBAction func handleSaveButton(_ sender: Any) {
        setButtonAnimated(button: saveButton)
    }
    @IBAction func handleCloseButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var editPhotoButton: UIButton!
    
    @IBAction func handleEditPhotoButton(_ sender: Any) {
        buildPhotoAlert()
    }
    
    private var nameBackup: String = ""
    private var descriptionBackup: String = ""
    
    private var counter: Int = 0
    
    private var initialNameLabel = UILabel()
    private var initialSurnameLabel = UILabel()
    
    private var saveButtonClicked: UIButton?
    private var repeatNeeded: Bool = false
    private let emitterNode = SKEmitterNode(fileNamed: "Rain.sks")
    private var skView: SKView?
    
    private lazy var model: ProfileModel = {
        let model = ProfileModel()
        return model
    }()
    
    private lazy var saveGCDButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(touchedSet), for: .touchUpInside)
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(revertChanges(sender:)), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roundOff(profileImage)
        saveButton.layer.cornerRadius = 14
        saveButton.clipsToBounds = true
        saveButton.backgroundColor = Settings.currentColors.buttonColor
        descriptionTextView.delegate = self
        descriptionTextView.layer.borderColor = UIColor.systemGray6.cgColor
        descriptionTextView.layer.borderWidth = 2
        
        self.nameTextField.addTarget(self, action: #selector(textFieldDidChanged), for: .editingChanged)

        self.model.load { [weak self] data in
            self?.updateUI(profileData: data)
        }
        activityView.isHidden = true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        self.saveGCDButton.isEnabled = true
    }
    
    @objc func textFieldDidChanged() {
        self.saveGCDButton.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setViewsColors()
        self.descriptionTextView.isEditable = false
        self.nameTextField.isUserInteractionEnabled = false
        self.saveGCDButton.isHidden = true
        self.cancelButton.isHidden = true
        self.saveButton.isHidden = false
        self.editPhotoButton.isHidden = false
        saveGCDButton.isEnabled = false
        
        addRain()
        _ = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(stopScreensaver), userInfo: nil, repeats: false)
    }
    
    @objc func stopScreensaver() {
        guard let skv = self.skView else { return }
        
        UIView.animate(withDuration: 1, delay: 0, options: []) {
            skv.scene?.view?.layer.opacity = 0
//            skv.removeFromSuperview()
        }
    }
    
    func setButtonAnimated(button: UIButton) {
        guard counter == 0 else {
            button.layer.removeAllAnimations()
            UIView.animate(withDuration: 0.3, delay: 0, options: []) {
                button.transform = .identity
            }
            counter = 0
            return }
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: [.repeat, .autoreverse, .allowUserInteraction]) {
            button.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 10)
            button.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 10)
            
            let animation = CABasicAnimation(keyPath: "position")
            animation.repeatCount = .infinity
            animation.autoreverses = true
            animation.fromValue = NSValue(cgPoint: CGPoint(x: button.center.x - 5, y: button.center.y - 5))
            animation.toValue = NSValue(cgPoint: CGPoint(x: button.center.x + 5, y: button.center.y + 5))
            button.layer.add(animation, forKey: "position")
            self.counter = 1
        }
    }
    
    func updateUI(profileData: ProfileData) {
        guard profileData.name != nil && profileData.description != nil else { return }
        DispatchQueue.main.async {
            self.nameTextField.text = profileData.name
            self.descriptionTextView.text = profileData.description
            self.putNameFirstLetters(imageView: self.profileImage,
                                     nameLabel: self.initialNameLabel,
                                     surnameLabel: self.initialSurnameLabel,
                                     fullname: self.nameTextField.text ?? "No name")
            self.activityView.stopAnimating()
            self.activityView.isHidden = true
            self.changeModeOn(false)
        }
    }
    
    func buildPhotoAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraButton = UIAlertAction(title: "Take photo", style: .default) { [weak self] _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = false
                self?.present(imagePicker, animated: true, completion: nil)
            }
            self?.changeModeOn(true)
        }
        
        let photoLibraryButton = UIAlertAction(title: "Choose photo from libraby", style: .default) { [weak self] _ in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                self?.present(imagePicker, animated: true, completion: nil)
            }
            self?.changeModeOn(true)
        }
        
        let uploadPhotoButton = UIAlertAction(title: "Upload photo", style: .default) { [weak self] _ in
            let vc = PicturesViewController()
            vc.delegate = self
            vc.modalPresentationStyle = .popover
            self?.present(vc, animated: true)
        }
        
        let changeProfileButton = UIAlertAction(title: "Change profile", style: .default) { [weak self] _ in
            self?.changeModeOn(true)
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alert.addAction(cameraButton)
        alert.addAction(photoLibraryButton)
        alert.addAction(uploadPhotoButton)
        alert.addAction(changeProfileButton)
        alert.addAction(cancelButton)
        present(alert, animated: true, completion: nil)
    }
    
    func roundOff(_ imageView: UIImageView) {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.borderWidth = 1.0
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        initialNameLabel.text = ""
        initialSurnameLabel.text = ""
        profileImage.image = image
        self.dismiss(animated: true, completion: nil)
    }
    
    func putNameFirstLetters(imageView: UIImageView, nameLabel: UILabel, surnameLabel: UILabel, fullname: String) {
        nameLabel.text = ""
        surnameLabel.text = ""
        nameLabel.removeFromSuperview()
        surnameLabel.removeFromSuperview()
        if fullname.contains(" ") {
            let delimiter = " "
            let token = fullname.components(separatedBy: delimiter)
            let name = token[0]
            let surname = token[1]
            initInitionalLabel(label: nameLabel, name: name, imageView: imageView)
            initInitionalLabel(label: surnameLabel, name: surname, imageView: imageView)
            NSLayoutConstraint.activate([
                nameLabel.centerXAnchor.constraint(equalTo: imageView.leftAnchor,
                                                   constant: 96),
                nameLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
                surnameLabel.centerXAnchor.constraint(equalTo: imageView.rightAnchor,
                                                      constant: -80),
                surnameLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
            ])
        } else {
            initInitionalLabel(label: nameLabel, name: fullname, imageView: imageView)
            NSLayoutConstraint.activate([
                nameLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
                nameLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
            ])
        }
    }
    
    func putNamefirstLetters(imageView: UIImageView, nameLabel: UILabel, name: String, surname: String) {
        initInitionalLabel(label: nameLabel, name: name, surname: surname, imageView: imageView)
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
    
    func initInitionalLabel(label: UILabel, name: String, imageView: UIImageView) {
        label.text = "\(name.prefix(1))"
        label.font = label.font.withSize(120)
        label.textColor = Settings.profilePictureColor
        label.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(label)
    }
    
    func initInitionalLabel(label: UILabel, name: String, surname: String, imageView: UIImageView) {
        label.text = "\(name.prefix(1) + surname.prefix(1))"
        label.font = label.font.withSize(120)
        label.textColor = Settings.profilePictureColor
        label.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(label)
    }
    
    func buildButton(button: UIButton,
                     title: String,
                     leadingConstraintConstant: CGFloat,
                     trailingConstraintConstant: CGFloat,
                     bottomConstraintConstant: CGFloat) {
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        button.layer.cornerRadius = 18
        button.clipsToBounds = true
        button.backgroundColor = Settings.buttonBackgroundColor
        button.setTitle(title, for: .normal)
        button.setTitleColor(Settings.currentColors.buttonColor, for: .normal)
        button.isHidden = false
        let constraints = [
            button.heightAnchor.constraint(equalToConstant: 50),
            button.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,
                                            constant: leadingConstraintConstant),
            button.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,
                                             constant: trailingConstraintConstant),
            button.bottomAnchor.constraint(equalTo: self.view.bottomAnchor,
                                           constant: bottomConstraintConstant)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func changeModeOn(_ isOn: Bool) {
        self.saveButton.isHidden = isOn ? true : false
        self.editPhotoButton.isHidden = isOn ? true : false
        if isOn {
            buildButton(button: self.saveGCDButton,
                        title: "Save GCD",
                        leadingConstraintConstant: 20,
                        trailingConstraintConstant: -20,
                        bottomConstraintConstant: -20)

            buildButton(button: self.cancelButton,
                        title: "Cancel",
                        leadingConstraintConstant: 20,
                        trailingConstraintConstant: -20,
                        bottomConstraintConstant: -90)
            self.nameTextField.becomeFirstResponder()
        } else {
            self.saveGCDButton.isHidden = true
            self.cancelButton.isHidden = true
        }
        self.descriptionTextView.isEditable = isOn ? true : false
        self.nameTextField.isUserInteractionEnabled = isOn ? true : false
        guard self.nameTextField.text != nil && descriptionTextView.text != nil else { return }
        self.nameBackup = self.nameTextField.text ?? ""
        self.descriptionBackup = self.descriptionTextView.text ?? ""
    }
    
    @objc func touchedSet(sender: UIButton!) {
        startActivityIndicator()
        self.saveButtonClicked = sender
        self.saveGCDButton.isEnabled = false
        self.nameTextField.isUserInteractionEnabled = false
        self.descriptionTextView.isEditable = false
        self.model.save(profileData: ProfileData(name: nameTextField.text,
                                                 description: descriptionTextView.text)) { [weak self] errors in
            self?.handleSaved(errors)
        }
    }
    
    func handleSaved(_ errors: [Error]) {
        
        DispatchQueue.main.sync {
            self.activityView.stopAnimating()
            self.activityView.isHidden = true
            self.putNameFirstLetters(imageView: self.profileImage,
                                     nameLabel: self.initialNameLabel,
                                     surnameLabel: self.initialSurnameLabel,
                                     fullname: self.nameTextField.text ?? "No name")
            self.changeModeOn(false)
            if !errors.isEmpty {
                self.buildErrorAlert()
            } else {
                self.buildSuccessfulLoadAlert()
            }
        }
        
        if self.repeatNeeded {
            self.repeatNeeded = false
            touchedSet(sender: self.saveButtonClicked)
        }
    }
    
    @objc func revertChanges(sender: UIButton!) {
        self.nameTextField.text = self.nameBackup
        self.descriptionTextView.text = self.descriptionBackup
        changeModeOn(false)
    }
    
    func startActivityIndicator() {
        self.activityView.isHidden = false
        self.activityView.startAnimating()
    }
    
    func buildSuccessfulLoadAlert() {
        let alert = UIAlertController(title: "Данные сохранены",
                                      message: nil,
                                      preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok",
                                     style: .default) { [weak self] _ in
            self?.changeModeOn(false)
        }
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
    
    func buildErrorAlert() {
        let alert = UIAlertController(title: "Ошибка",
                                      message: "Не удалось сохранить данные",
                                      preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok",
                                     style: .default) { [weak self] _ in
            self?.changeModeOn(false)
        }
        
        let repeatButton = UIAlertAction(title: "Повторить",
                                         style: .default) { [weak self] _ in
            self?.repeatNeeded = true
        }
        alert.addAction(okButton)
        alert.addAction(repeatButton)
        present(alert, animated: true, completion: nil)
    }
    
    func setViewsColors() {
        self.view.backgroundColor = Settings.currentColors.backgroundColor
        self.nameTextField.textColor = Settings.currentColors.textColor
        self.descriptionTextView.textColor = Settings.currentColors.textColor
        self.saveButton.tintColor = Settings.currentColors.buttonColor
        self.saveButton.backgroundColor = Settings.currentColors.sectionBarColor
        self.editPhotoButton.tintColor = Settings.currentColors.buttonColor
        self.closeButton.tintColor = Settings.currentColors.buttonColor
        self.navigationController?.navigationBar.backgroundColor = Settings.currentColors.backgroundColor
    }
    
    private func addRain() {
        self.skView = SKView(frame: view.frame)
        guard let skv = self.skView else { return }
        skv.backgroundColor = .clear
        let scene = SKScene(size: view.frame.size)
        scene.backgroundColor = .clear
        skv.presentScene(scene)
        skv.isUserInteractionEnabled = false
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        guard let emtNode = self.emitterNode else { return }
        scene.addChild(emtNode)
        emtNode.position.y = scene.frame.maxY
        emtNode.particlePositionRange.dx = scene.frame.width
        view.addSubview(skv)
    }
}

extension ProfileViewController: IPicturePickable {
    func handlePicturePicked(image: UIImage, url: String) {
        self.profileImage.image = image
        self.initialNameLabel.text = ""
        self.initialSurnameLabel.text = ""
    }
}
 
