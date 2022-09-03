import Foundation
import UIKit

class PicturesLoader: IPictureLoadable {
    private let pageSize: Int = 100
    private let token: String = "26831246-5a4dfbf06ad0dfb3768f42f4a"
    private var loader: IRequestable = GCDRequest()
    private let defaultURL = "https://pixabay.com/api/?"
    
    func getImagesList(_ completion: @escaping ([PicResponseItem]) -> Void) {
        let page: Int = 1
        guard let url = URL(string: "\(defaultURL)key=\(token)&page=\(page)&per_page=\(pageSize)")
        else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForResource = 10
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { data, _, _ in
            guard let data = data else { return }
            let picsList = try? JSONDecoder().decode(PicsResponse.self, from: data)
            completion(picsList?.hits ?? [])
        }
        task.resume()

    }
    
    func loadImage(_ url: URL, _ completion: @escaping (UIImage) -> Void,
                   _ cacheAction: @escaping (String, UIImage) -> Void) {
        loader.loadPic(url: url, completion, cacheAction)
    }
}
