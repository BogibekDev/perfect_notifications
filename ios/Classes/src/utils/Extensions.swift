import Foundation
import UserNotifications

// MARK: - Dictionary Extensions

extension Dictionary where Key == String, Value == Any {

    /// Safe Int olish
    func int(forKey key: String) -> Int? {
        return self[key] as? Int
    }

    /// Safe String olish
    func string(forKey key: String) -> String? {
        return self[key] as? String
    }

    /// Safe Bool olish (default true)
    func bool(forKey key: String, default defaultValue: Bool = true) -> Bool {
        return self[key] as? Bool ?? defaultValue
    }

    /// Safe Array olish
    func array(forKey key: String) -> [Any]? {
        return self[key] as? [Any]
    }

    /// Safe Dictionary olish
    func dictionary(forKey key: String) -> [String: Any]? {
        return self[key] as? [String: Any]
    }
}

// MARK: - String Extensions

extension String {

    /// Sound fayl extension'ni tekshirish (iOS uchun valid)
    var isValidSoundFile: Bool {
        let validExtensions = [".caf", ".wav", ".aiff", ".aif"]
        return validExtensions.contains { self.hasSuffix($0) }
    }

    /// Sound file nomi (extension bilan)
    var soundFileName: String {
        if isValidSoundFile {
            return self
        } else if !self.contains(".") {
            // Extension yo'q bo'lsa, .caf qo'shish (default)
            return self + ".caf"
        } else {
            // Noto'g'ri extension
            print("⚠️ Warning: Invalid sound format '\(self)'. iOS requires .caf, .wav, or .aiff")
            return "default.caf"
        }
    }
}

// MARK: - UNNotificationSound Extensions

extension UNNotificationSound {

    /// Sound yaratish (validation bilan)
    /// - Parameter soundUri: Sound fayl nomi
    /// - Returns: UNNotificationSound yoki default
    static func from(soundUri: String?) -> UNNotificationSound {
        guard let soundUri = soundUri, !soundUri.isEmpty else {
            return .default
        }

        // "default" string'i bo'lsa, default sound qaytarish
        if soundUri.lowercased() == "default" {
            return .default
        }

        // Valid format tekshirish va sound yaratish
        let fileName = soundUri.soundFileName
        return UNNotificationSound(named: UNNotificationSoundName(rawValue: fileName))
    }
}

// MARK: - Error Extensions

extension Error {

    /// Error'ni user-friendly string'ga o'tkazish
    var userFriendlyMessage: String {
        if let decodingError = self as? DecodingError {
            switch decodingError {
            case .keyNotFound(let key, _):
                return "Missing required field: \(key.stringValue)"
            case .typeMismatch(let type, let context):
                return "Invalid type for field '\(context.codingPath.last?.stringValue ?? "unknown")'. Expected \(type)"
            case .valueNotFound(let type, let context):
                return "Missing value for field '\(context.codingPath.last?.stringValue ?? "unknown")' of type \(type)"
            case .dataCorrupted(let context):
                return "Data corrupted: \(context.debugDescription)"
            @unknown default:
                return localizedDescription
            }
        }
        return localizedDescription
    }
}

// MARK: - Date Extensions

extension Date {

    /// Timestamp (seconds)
    var timestamp: Int {
        return Int(timeIntervalSince1970)
    }

    /// Timestamp (milliseconds)
    var timestampMillis: Int64 {
        return Int64(timeIntervalSince1970 * 1000)
    }
}

// MARK: - NSObject Extensions (for debugging)

extension NSObject {

    /// Class nomi
    var className: String {
        return String(describing: type(of: self))
    }

    /// Static class nomi
    static var className: String {
        return String(describing: self)
    }
}

// MARK: - Optional Extensions

extension Optional where Wrapped == String {

    /// Empty bo'lsa nil qaytaradi
    var nilIfEmpty: String? {
        switch self {
        case .some(let value):
            return value.isEmpty ? nil : value
        case .none:
            return nil
        }
    }
}

// MARK: - UserDefaults Extensions

extension UserDefaults {

    /// Perfect Notifications uchun shared instance
    static let perfectNotifications = UserDefaults(suiteName: "group.perfect.notifications") ?? .standard
}