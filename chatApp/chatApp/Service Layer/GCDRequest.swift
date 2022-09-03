import Foundation
import UIKit

class GCDRequest: IRequestable {
    
    let picQueue: DispatchQueue
    
    init() {
        self.picQueue = DispatchQueue(label: "PicDownloader", qos: .userInitiated, attributes: .concurrent)
    }
    
    func loadPic(url: URL, _ completion: @escaping (UIImage) -> Void,
                 _ cacheAction: @escaping (String, UIImage) -> Void) {
        picQueue.async {
            if let imageData = try? Data(contentsOf: url) {
                if let pic = UIImage(data: imageData) {
                    DispatchQueue.main.sync {
                        completion(pic)
                        cacheAction(url.absoluteString, pic)
                    }
                }
            }
        }
    }
}
