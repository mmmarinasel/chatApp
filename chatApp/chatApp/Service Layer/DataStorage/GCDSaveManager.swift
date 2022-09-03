import Foundation
import UIKit

class GCDSaveManager: ISaveManager {
    
    let queue: DispatchQueue
    let picQueue: DispatchQueue
    
    init() {
        self.queue = DispatchQueue(label: "GCDProfileInfo", qos: .userInitiated, attributes: .concurrent)
        self.picQueue = DispatchQueue(label: "PicDownloader", qos: .userInitiated, attributes: .concurrent)
    }
    
    func save(profileData: ProfileData, _ completion: @escaping ([Error]) -> Void) {
        queue.async {
            var jsonString: String = ""
            do {
                let jsonData = try JSONEncoder().encode(profileData)
                jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"
                Logger.log(jsonString)
            } catch {
                Logger.log(error.localizedDescription)
                return
            }
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                                   in: .userDomainMask).first {
                let pathWithFilename = documentDirectory.appendingPathComponent("ProfileData.json")
                do {
                    try jsonString.write(to: pathWithFilename,
                                         atomically: true,
                                         encoding: .utf8)
                    Logger.log("saved to: \(documentDirectory)")
                    completion([])
                } catch {
                    Logger.log("save error to: \(documentDirectory)")
                    var err = [Error]()
                    err.append(error)
                    completion(err)
                }
            }
        }
    }
    
    func load(_ completion: @escaping (ProfileData) -> Void) {
        queue.async {
            var jsonString: String = ""
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                                   in: .userDomainMask).first {
                let pathWithFilename = documentDirectory.appendingPathComponent("ProfileData.json")
                do {
                    jsonString = try String(contentsOf: pathWithFilename, encoding: .utf8)
                } catch {
                    Logger.log("load error from: \(documentDirectory)")
                    return
                }
            }
            do {
                let jsonData = Data(jsonString.utf8)
                let decodedData = try JSONDecoder().decode(ProfileData.self, from: jsonData)
                completion(decodedData)
            } catch {
                Logger.log(error.localizedDescription)
                
            }
        }
    }
    
    func saveTheme(_ theme: Settings.Theme) {
        queue.async {
            var jsonString: String = ""
            var themeJson = ThemeJson(theme: "")
            switch theme {
            case Settings.Theme.classic:
                themeJson.theme = "classic"
            case Settings.Theme.day:
                themeJson.theme = "day"
            case Settings.Theme.night:
                themeJson.theme = "night"
            }
            
            do {
                let jsonData = try JSONEncoder().encode(themeJson)
                jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"
                Logger.log(jsonString)
            } catch {
                Logger.log(error.localizedDescription)
                return
            }
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                                   in: .userDomainMask).first {
                let pathWithFilename = documentDirectory.appendingPathComponent("ThemeData.json")
                do {
                    try jsonString.write(to: pathWithFilename,
                                         atomically: true,
                                         encoding: .utf8)
                    Logger.log("saved to: \(documentDirectory)")
                } catch {
                    Logger.log("theme save error to: \(documentDirectory)")
                }
            }
        }
        
    }
    
    func loadTheme(_ completion: @escaping (Settings.Theme) -> Void) {
        queue.async {
            var jsonString: String = ""
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                                   in: .userDomainMask).first {
                let pathWithFilename = documentDirectory.appendingPathComponent("ThemeData.json")
                do {
                    jsonString = try String(contentsOf: pathWithFilename, encoding: .utf8)
                } catch {
                    Logger.log("load error from: \(documentDirectory)")
                    return
                }
            }
            do {
                let jsonData = Data(jsonString.utf8)
                let decodedData = try JSONDecoder().decode(ThemeJson.self, from: jsonData)
                var theme: Settings.Theme
                switch decodedData.theme {
                case "classic":
                    theme = .classic
                case "day":
                    theme = .day
                case "night":
                    theme = .night
                default:
                    theme = .day
                }
                completion(theme)
            } catch {
                Logger.log(error.localizedDescription)
                
            }
        }
    }
}
