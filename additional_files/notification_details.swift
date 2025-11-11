
import Foundation

struct NotificationDetails: Codable {
    let channelId: String
    let title: String
    let body: String

    let id: Int?
    let soundUri: String?       // iOS uchun: "sound.caf"
    let subtitle: String?       // iOS uchun
    let badge: Int?             // iOS uchun
    let imageUrl: String?       // Attachment
    let largeIcon: String?      // iOS'da ishlatilmaydi
    let color: String?          // iOS'da ishlatilmaydi
    let autoCancel: Bool?
    let silent: Bool?
    let payload: [String: String]?

    enum CodingKeys: String, CodingKey {
        case channelId
        case title
        case body
        case description        // Android compatibility
        case id
        case soundUri
        case subtitle
        case badge
        case imageUrl
        case largeIcon
        case color
        case autoCancel
        case silent
        case payload
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        channelId = try container.decode(String.self, forKey: .channelId)
        title = try container.decode(String.self, forKey: .title)

        if let bodyValue = try? container.decode(String.self, forKey: .body) {
            body = bodyValue
        } else {
            body = try container.decode(String.self, forKey: .description)
        }

        // Optional fields
        id = try? container.decode(Int.self, forKey: .id)
        soundUri = try? container.decode(String.self, forKey: .soundUri)
        subtitle = try? container.decode(String.self, forKey: .subtitle)
        badge = try? container.decode(Int.self, forKey: .badge)
        imageUrl = try? container.decode(String.self, forKey: .imageUrl)
        largeIcon = try? container.decode(String.self, forKey: .largeIcon)
        color = try? container.decode(String.self, forKey: .color)
        autoCancel = try? container.decode(Bool.self, forKey: .autoCancel)
        silent = try? container.decode(Bool.self, forKey: .silent)
        payload = try? container.decode([String: String].self, forKey: .payload)
    }
    
    init(
        channelId: String,
        title: String,
        body: String,
        id: Int? = nil,
        soundUri: String? = nil,
        subtitle: String? = nil,
        badge: Int? = nil,
        imageUrl: String? = nil,
        largeIcon: String? = nil,
        color: String? = nil,
        autoCancel: Bool? = nil,
        silent: Bool? = nil,
        payload: [String: String]? = nil
    ) {
        self.channelId = channelId
        self.title = title
        self.body = body
        self.id = id
        self.soundUri = soundUri
        self.subtitle = subtitle
        self.badge = badge
        self.imageUrl = imageUrl
        self.largeIcon = largeIcon
        self.color = color
        self.autoCancel = autoCancel
        self.silent = silent
        self.payload = payload
    }
    
    // MARK: - Encodable
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(channelId, forKey: .channelId)
            try container.encode(title, forKey: .title)
            // body’ni **body** kaliti bilan yozamiz (description emas)
            try container.encode(body, forKey: .body)

            try container.encodeIfPresent(id, forKey: .id)
            try container.encodeIfPresent(soundUri, forKey: .soundUri)
            try container.encodeIfPresent(subtitle, forKey: .subtitle)
            try container.encodeIfPresent(badge, forKey: .badge)
            try container.encodeIfPresent(imageUrl, forKey: .imageUrl)
            try container.encodeIfPresent(largeIcon, forKey: .largeIcon)
            try container.encodeIfPresent(color, forKey: .color)
            try container.encodeIfPresent(autoCancel, forKey: .autoCancel)
            try container.encodeIfPresent(silent, forKey: .silent)
            try container.encodeIfPresent(payload, forKey: .payload)
            // Eslatma: .description kalitini umuman encode qilmaymiz.
        }

    /// Map'dan yaratish (MethodCall arguments'dan)
    static func fromMap(_ map: [String: Any]) throws -> NotificationDetails {
        let data = try JSONSerialization.data(withJSONObject: map)
        return try JSONDecoder().decode(NotificationDetails.self, from: data)
    }

    /// Map'ga o'tkazish
    func toMap() -> [String: Any?] {
        var result: [String: Any?] = [
            "channelId": channelId,
            "title": title,
            "body": body,
        ]

        if let id = id { result["id"] = id }
        if let soundUri = soundUri { result["soundUri"] = soundUri }
        if let subtitle = subtitle { result["subtitle"] = subtitle }
        if let badge = badge { result["badge"] = badge }
        if let imageUrl = imageUrl { result["imageUrl"] = imageUrl }
        if let largeIcon = largeIcon { result["largeIcon"] = largeIcon }
        if let color = color { result["color"] = color }
        if let autoCancel = autoCancel { result["autoCancel"] = autoCancel }
        if let silent = silent { result["silent"] = silent }
        if let payload = payload {
            result["payload"] = payload.mapValues { $0 }
        }

        return result
    }
}
