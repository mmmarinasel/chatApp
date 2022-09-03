import Foundation

class Logger {
    
    private static var enabled: Bool = true
    
    static func setEnabled(_ enabled: Bool) {
        self.enabled = enabled
    }
    
    static func log(_ message: String) {
        guard enabled else { return }
        print(message)
    }
}
