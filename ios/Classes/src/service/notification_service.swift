import UIKit
import UserNotifications

final class NotificationService: NSObject {
    private let center = UNUserNotificationCenter.current()

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    func showNotification(_ data: NotificationDetails, userInfo: [AnyHashable: Any] = [:], soundName: String? = nil) {
        let content = UNMutableNotificationContent()
        content.title = data.title
        content.body = data.description
        content.userInfo = userInfo

        if let soundName, !soundName.isEmpty, soundName != "default" {
            // soundUri Android’da raw resurs edi; iOS’da main bundle’dan .caf/.aiff/.wav qidiramiz :contentReference[oaicite:6]{index=6}
            content.sound = UNNotificationSound(named: UNNotificationSoundName(soundName))
        } else {
            content.sound = .default
        }

        // iOS’da "channelId" yo‘q, lekin kerak bo‘lsa categoryIdentifier sifatida saqlab qo‘yamiz
        content.categoryIdentifier = data.channelId

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let reqId = UUID().uuidString
        let request = UNNotificationRequest(identifier: reqId, content: content, trigger: trigger)
        center.add(request, withCompletionHandler: nil)
    }
}
