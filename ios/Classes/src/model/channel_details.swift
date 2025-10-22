import Foundation

/// Notification Channel (Android uchun)
/// iOS'da channel tizimi yo'q, lekin Flutter API compatibility uchun model kerak
struct ChannelDetails: Codable {
    let id: String
    let name: String
    let description: String
    let importance: Int
    let enableSound: Bool
    let soundUri: String?
    let enableVibration: Bool

    // iOS'da ishlatilmaydigan field'lar (Android compatibility)
    let vibrationPattern: [Int]?
    let enableLights: Bool?
    let lightColor: String?
    let showBadge: Bool?
    let visibility: Int?
    let playSound: Bool?
    let groupId: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case importance
        case enableSound
        case soundUri
        case enableVibration
        case vibrationPattern
        case enableLights
        case lightColor
        case showBadge
        case visibility
        case playSound
        case groupId
    }

    /// Map'dan yaratish
    static func fromMap(_ map: [String: Any]) throws -> ChannelDetails {
        let data = try JSONSerialization.data(withJSONObject: map)
        return try JSONDecoder().decode(ChannelDetails.self, from: data)
    }

    /// Map'ga o'tkazish
    func toMap() -> [String: Any?] {
        var result: [String: Any?] = [
            "id": id,
            "name": name,
            "description": description,
            "importance": importance,
            "enableSound": enableSound,
            "enableVibration": enableVibration,
        ]

        if let soundUri = soundUri { result["soundUri"] = soundUri }
        if let vibrationPattern = vibrationPattern { result["vibrationPattern"] = vibrationPattern }
        if let enableLights = enableLights { result["enableLights"] = enableLights }
        if let lightColor = lightColor { result["lightColor"] = lightColor }
        if let showBadge = showBadge { result["showBadge"] = showBadge }
        if let visibility = visibility { result["visibility"] = visibility }
        if let playSound = playSound { result["playSound"] = playSound }
        if let groupId = groupId { result["groupId"] = groupId }

        return result
    }
}