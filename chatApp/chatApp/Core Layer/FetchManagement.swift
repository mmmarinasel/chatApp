import Foundation
import CoreData
import UIKit

protocol IMessageScrollable {
    func jumpToBottom()
}

protocol IRefreshable {
    func refresh()
}

protocol ICDSaveable {
    func performSave(_ block: @escaping(NSManagedObjectContext) -> Void)
    func getMainContext() -> NSManagedObjectContext
}

struct PicResponseItem: Codable {
    var previewURL: String
}

struct PicsResponse: Codable {
    var totalHits: Int
    var hits: [PicResponseItem]
}

protocol IPictureLoadable {
    func getImagesList(_ completion: @escaping ([PicResponseItem]) -> Void)
    func loadImage(_ url: URL, _ completion: @escaping (UIImage) -> Void,
                   _ cacheAction: @escaping (String, UIImage) -> Void)
}
