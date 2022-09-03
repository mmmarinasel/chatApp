import Foundation
import UIKit

protocol ISaveManager {
    func save(profileData: ProfileData, _ completion: @escaping ([Error]) -> Void)
    func load(_ completion: @escaping (ProfileData) -> Void)
}

protocol IRequestable {
    func loadPic(url: URL, _ completion: @escaping (UIImage) -> Void,
                 _ cacheAction: @escaping (String, UIImage) -> Void)
}

struct ProfileData: Codable {
    var name: String?
    var description: String?
}

struct ThemeJson: Codable {
    var theme: String
}
