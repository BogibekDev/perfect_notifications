//
// Created by Bog'ibek on 22/10/25.
//

import Foundation

struct NotificationData: Codable {
    let title: [String: String]
    let sound: [String: String]
    let body: [String: String]
    let image: [String: String]
    let type: [String: String]

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
            title: decodeMap(for: "title"),
            sound: decodeMap(for: "sound"),
            body: decodeMap(for: "body"),
            image: decodeMap(for: "image"),
            type: decodeMap(for: "type")
        )
    }

    func toNotificationDetails(locale: String) -> NotificationDetails {
        let channelId = sound[locale] ?? "default_channel"
        let title = title[locale] ?? "Notification"
        let body = body[locale] ?? ""
        let sound = (sound[locale] ?? "default") + ".caf"
        let imageUrl = image[locale]
        let type = type[locale]

        return NotificationDetails(
            channelId: channelId,
            title: title,
            body: body,
            id: nil,
            soundUri: sound,
            subtitle: nil,
            badge: nil,
            imageUrl: imageUrl,
            largeIcon: nil,
            color: nil,
            autoCancel: true,
            silent: false,
            payload: type
        )
    }
}
