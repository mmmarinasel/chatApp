import Foundation

class ProfileModel {
    private var saveManager: ISaveManager?
    
    public init() {
        saveManager = GCDSaveManager()
    }
    
    public func load(_ completion: @escaping (ProfileData) -> Void) {
        saveManager?.load(completion)
    }
    
    public func save(profileData: ProfileData, _ completion: @escaping ([Error]) -> Void) {
        saveManager?.save(profileData: profileData, completion)
    }
}
