import Foundation

class LogService {

    static func debug(_ message: String, tag: String = "") {
        NSLog("🤖 Perfect Notifications [\(tag)] : \n\(message)")
    }

    static func info(_ message: Any, tag: String = "") {
        NSLog("ℹ️ Perfect Notifications [\(tag)] : \n\(message)")
    }

    static func success(_ message: Any, tag: String = "") {
        NSLog("✅ Perfect Notifications [\(tag)] : \n\(message)")
    }

    static func warning(_ message: Any, tag: String = "") {
        NSLog("⚠️ Perfect Notifications [\(tag)] : \n\(message)")
    }

    static func error(_ error: String, tag: String = "") {
        NSLog("❌ Perfect Notifications [\(tag)] : \nmessage: \(error)")
    }
}
