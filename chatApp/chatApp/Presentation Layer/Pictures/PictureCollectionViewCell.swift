import UIKit

class PictureCollectionViewCell: UICollectionViewCell {
    private var imageView: UIImageView?
    
    func setPlaceholderImage(_ image: UIImage?) {
        if imageView == nil {
            self.imageView = UIImageView(frame: CGRect(x: 0,
                                                       y: 0,
                                                       width: self.contentView.frame.width,
                                                       height: self.contentView.frame.height))
            if let imgView = self.imageView {
                self.contentView.addSubview(imgView)
            }
        }
        
        if image == nil {
            let deafaultImage = UIImage(named: "placeholderImage")
            self.imageView?.image = deafaultImage
        } else {
            self.imageView?.image = image
        }
        
    }
}
