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
        
        LogService.info("Received data: \(dataDict)", tag: "data")

        // 🔹 2. Har bir field JSON string ko‘rinishida keladi → [String:String] ga parse qilamiz
        func decodeMap(for key: String) -> [String: String] {
            guard let jsonStr = dataDict[key] as? String,
                  let jsonData = jsonStr.data(using: .utf8),
                  let map = try? JSONDecoder().decode([String: String].self, from: jsonData)
            else {
                LogService.error("Missing key '\(key)' in notification data.", tag: "parsing")
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

    func toNotificationDetails(locale: String,soundEnable:Bool) -> NotificationDetails {
        let channelId = localizedCore(core: coreSound, locale: locale, key: "core_sound") ?? "default_channel"
        let title = localizedCore(core: coreTitle, locale: locale, key: "core_title") ?? "Notification"
        let body = localizedCore(core: coreBody, locale: locale, key: "core_body") ?? ""
        let rawSound = localizedCore(core: coreSound, locale: locale, key: "core_sound")
        let soundName = rawSound.flatMap {
            $0.hasSuffix(".caf") || $0.hasSuffix(".wav") || $0.hasSuffix(".aiff") ? $0 : $0 + ".wav"
        }
        let sound = soundEnable ? soundName : "default"
        let imageUrl = localizedCore(core: coreImage, locale: locale, key: "core_image")
        
        let payloadMap: [String: AnyCodable]? = coreType.isEmpty
                ? nil
                : coreType.reduce(into: [String: AnyCodable]()) { acc, kv in
                    acc[kv.key] = AnyCodable(kv.value)
                }


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
            payload: payloadMap
        )
    }
    
    func localizedCore(core: [String: String], locale: String, key: String) -> String? {
        let result = core[locale]
        
        if result == nil {
            LogService.error("Missing locale '\(locale)' for '\(key)' field.", tag: "Localized")
        }
        
        return result
       
    }
}
