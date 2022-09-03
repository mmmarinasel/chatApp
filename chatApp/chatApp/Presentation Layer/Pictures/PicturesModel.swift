import Foundation
import UIKit

protocol IPicturePickable {
    func handlePicturePicked(image: UIImage, url: String)
}

class PicturesModel {
    
    struct LoadedPicture {
        var previewURL: String
        var img: UIImage?
    }
    
    public var loadedPictures: [LoadedPicture] = []
    
    private var delegate: IRefreshable?
    private var picturesList: [PicResponseItem] = []
    private var picLoader: IPictureLoadable = PicturesLoader()
    
    init(_ delegate: IRefreshable) {
        self.delegate = delegate
        self.picLoader.getImagesList { [weak self] pictures in
            self?.picturesList = pictures
            for pic in (self?.picturesList) ?? [] {
                self?.loadedPictures.append(LoadedPicture(previewURL: pic.previewURL))
            }
            self?.delegate?.refresh()
        }
    }
    
    func loadPic(url: String, _ completion: @escaping (UIImage) -> Void) {
        if let row = self.loadedPictures.firstIndex(where: { $0.previewURL == url }) {
            if let image = self.loadedPictures[row].img {
                completion(image)
            }
        }
        
        guard let picURL = URL(string: url) else { return }
        picLoader.loadImage(picURL, completion) { [weak self] url, loadedImage in
            guard let row = self?.loadedPictures.firstIndex(where: { $0.previewURL == url }) else { return }
            self?.loadedPictures[row].img = loadedImage
        }
        
    }
    
}
