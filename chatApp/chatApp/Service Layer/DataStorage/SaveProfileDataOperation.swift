import Foundation

class SaveProfileDataOperation: Operation {
    
    private var profileData: ProfileData
    private var completion: ([Error]) -> Void
    
    public init(data: ProfileData, _ completion: @escaping ([Error]) -> Void) {
        self.profileData = data
        self.completion = completion
        super.init()
    }
    
    override func main() {
        var jsonString: String = ""
        do {
            let jsonData = try JSONEncoder().encode(self.profileData)
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
