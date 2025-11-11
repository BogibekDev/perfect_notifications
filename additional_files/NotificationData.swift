import Foundation

struct NotificationData: Codable {
    let defaultTitle:String?
    let defaultBody:String?
    let defaultImage:String?
    let defaultSound:String?
    
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
            defaultTitle: dataDict["default_title"] as? String,
            defaultBody: dataDict["default_body"] as? String,
            defaultImage: dataDict["default_image"] as? String,
            defaultSound: dataDict["default_sound"] as? String,
            
            coreTitle: decodeMap(for: "core_title"),
            coreSound: decodeMap(for: "core_sound"),
            coreBody: decodeMap(for: "core_body"),
            coreImage: decodeMap(for: "core_image"),
            coreType: decodeMap(for: "core_type")
        )
    }

    func toNotificationDetails(locale: String,soundEnable:Bool) -> NotificationDetails {
        let channelId = defaultSound.isNilOrBlank
                ? (localizedCore(core: coreSound, locale: locale, key: "core_sound") ?? "default_channel")
                : defaultSound!

        let title = defaultTitle.isNilOrBlank
                ? (localizedCore(core: coreTitle, locale: locale, key: "core_title") ?? "Notification")
                : defaultTitle!

        let body = defaultBody.isNilOrBlank
                ? (localizedCore(core: coreBody, locale: locale, key: "core_body") ?? "")
                : defaultBody!

        let rawSound = defaultSound.isNilOrBlank
                ? localizedCore(core: coreSound, locale: locale, key: "core_sound")
                : defaultSound
        let imageUrl = defaultImage.isNilOrBlank
                ? localizedCore(core: coreImage, locale: locale, key: "core_image")
                : defaultImage
        
        let soundName = rawSound.flatMap {
            $0.hasSuffix(".caf") || $0.hasSuffix(".wav") || $0.hasSuffix(".aiff") ? $0 : $0 + ".wav"
        }
        let sound = soundEnable ? soundName : "default"
        
        
        let payloadMap: [String: String]? = coreType.isEmpty
                ? nil
                : coreType.reduce(into: [String: String]()) { acc, kv in
                    acc[kv.key] = String(kv.value)
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

extension Optional where Wrapped == String {
    var isNilOrBlank: Bool {
        return self?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
    }
}
