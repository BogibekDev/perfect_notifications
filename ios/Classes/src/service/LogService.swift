import Foundation

class LogService {
    static func log(_ message: String, tag: String = "") {
        NSLog("Perfect Notifications: \(tag) : \(message)")
    }

    static func log(_ message: Any, tag: String = "") {
        NSLog("Perfect Notifications: \(tag) : \(message)")
    }
}
