import UIKit

class PicturesViewController: UIViewController {
    private let sections: Int = 3
    private lazy var activityView: UIActivityIndicatorView = {
        let actView = UIActivityIndicatorView()
        self.view.addSubview(actView)
        return actView
    }()
    
    var picturesCollectionView: UICollectionView?
    
    private let cellId = "pictureCell"
    public var delegate: IPicturePickable?
    
    private lazy var model: PicturesModel = {
        let model = PicturesModel(self)
        return model
    }()
    
    private var padding: CGFloat = 0
    private let paddingCoefficient: CGFloat = 0.03
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.buildView()
    }
    
    func buildView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        self.padding = self.view.frame.width * self.paddingCoefficient
        layout.sectionInset = UIEdgeInsets(top: padding,
                                           left: padding,
                                           bottom: padding,
                                           right: padding)
        
        layout.minimumLineSpacing = padding

        let side = (self.view.frame.width - 4 * padding) / 3
        layout.itemSize = CGSize(width: side,
                                 height: side)
        
        picturesCollectionView = UICollectionView(frame: self.view.frame,
                                                  collectionViewLayout: layout)
        picturesCollectionView?.register(PictureCollectionViewCell.self,
                                         forCellWithReuseIdentifier: cellId)
        
        picturesCollectionView?.dataSource = self
        picturesCollectionView?.delegate = self
        
        self.view.addSubview(picturesCollectionView ?? UICollectionView())
        
        self.picturesCollectionView?.backgroundColor = Settings.currentColors.backgroundColor
    }
}

extension PicturesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pic = self.model.loadedPictures[indexPath.item]
        guard let image = pic.img else { return }
        delegate?.handlePicturePicked(image: image, url: pic.previewURL)
        self.dismiss(animated: true)
    }
}

extension PicturesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.model.loadedPictures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.picturesCollectionView?.dequeueReusableCell(
            withReuseIdentifier: cellId,
            for: indexPath) as? PictureCollectionViewCell
        else { return PictureCollectionViewCell() }
        cell.backgroundColor = Settings.currentColors.settingsBackgroundColor
        
        let picItem = self.model.loadedPictures[indexPath.item]
        print("Loading image #\(indexPath.item)")
        cell.setPlaceholderImage(nil)
        self.model.loadPic(url: picItem.previewURL) { image in
            cell.setPlaceholderImage(image)
        }
        return cell
    }
    
}

extension PicturesViewController: IRefreshable {
    func refresh() {
        DispatchQueue.main.sync {
            self.picturesCollectionView?.reloadData()
        }
    }
}
