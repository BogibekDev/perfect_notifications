//
// Created by Bog'ibek on 22/10/25.
//

import Foundation

struct NotificationData: Codable {
    let coreTitle: [String: String]
    let coreSound: [String: String]
    let coreBody: [String: String]
    let coreImage: [String: String]
    let coreType: [String: String]

    static func parse(from userInfo: [AnyHashable: Any]) -> NotificationData? {
        var dataDict: [String: Any] = [:]

        // 🔹 1. FCM `data` obyektini topamiz
        if let d = userInfo["data"] as? [String: Any] {
            dataDict = d
        } else if let dStr = userInfo["data"] as? String,
                  let dData = dStr.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: dData) as? [String: Any] {
            dataDict = json
        } else {
            // Ba'zan FCM data kalitlari yuqori darajada bo'lishi mumkin
            for (k, v) in userInfo {
                if let key = k as? String {
                    dataDict[key] = v
                }
            }
        }

        // 🔹 2. Har bir field JSON string ko‘rinishida keladi → [String:String] ga parse qilamiz
        func decodeMap(for key: String) -> [String: String] {
            guard let jsonStr = dataDict[key] as? String,
                  let jsonData = jsonStr.data(using: .utf8),
                  let map = try? JSONDecoder().decode([String: String].self, from: jsonData)
            else {
                return [:]
            }
            return map
        }

        // 🔹 3. Obyektni yasaymiz
        return NotificationData(
            coreTitle: decodeMap(for: "core_title"),
            coreSound: decodeMap(for: "core_sound"),
            coreBody: decodeMap(for: "core_body"),
            coreImage: decodeMap(for: "core_image"),
            coreType: decodeMap(for: "core_type")
        )
    }

    func toNotificationDetails(locale: String) -> NotificationDetails {
        let channelId = coreSound[locale] ?? "default_channel"
        let title = coreTitle[locale] ?? "Notification"
        let body = coreBody[locale] ?? ""
        let rawSound = coreSound[locale]                      // masalan "happy_birthday" yoki "happy_birthday.caf"
        let soundName = rawSound.flatMap {
            $0.hasSuffix(".caf") || $0.hasSuffix(".wav") || $0.hasSuffix(".aiff") ? $0 : $0 + ".caf"
        }
        let imageUrl = image[locale]
        
        let payloadMap: [String: AnyCodable]? = type.isEmpty
                ? nil
                : type.reduce(into: [String: AnyCodable]()) { acc, kv in
                    acc[kv.key] = AnyCodable(kv.value)
                }


        return NotificationDetails(
            channelId: channelId,
            title: title,
            body: body,
            id: nil,
            soundUri: soundName,
            subtitle: nil,
            badge: nil,
            imageUrl: imageUrl,
            largeIcon: nil,
            color: nil,
            autoCancel: true,
            silent: false,
            payload: payloadMap
        )
    }
}
