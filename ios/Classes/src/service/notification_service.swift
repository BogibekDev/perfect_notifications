import Foundation
import UIKit
import UserNotifications

/// Notification'larni boshqarish va ko'rsatish
class NotificationService: NSObject {

    // MARK: - Properties

    private let center = UNUserNotificationCenter.current()

    // MARK: - Permission

    /// Permission so'rash
    /// - Parameter completion: Granted yoki yo'qligi
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .badge, .sound, .criticalAlert]) { granted, error in
            if let error = error {
                print("❌ Permission error: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    /// Permission status'ni tekshirish
    func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }

    // MARK: - Show Notification

    /// Notification ko'rsatish
    /// - Parameters:
    ///   - details: NotificationDetails
    ///   - userInfo: Qo'shimcha data (payload)
    func showNotification(
        _ details: NotificationDetails,
        userInfo: [AnyHashable: Any] = [:]
    ) throws {
        print("Show Notification is working for id: \(String(describing: details.id))")
        // Content yaratish
        let content = createContent(from: details, userInfo: userInfo)

        // Unique ID
        let identifier = details.id.map { String($0) } ?? UUID().uuidString
        
        print("Process with continue with this id: \(identifier)")

        // Request yaratish
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: nil
        )

        // Notification qo'shish
        center.add(request) { error in
            if let error = error {
                print("❌ Failed to show notification: \(error.localizedDescription)")
            } else {
                print("✅ Notification shown: \(details.title)")
            }
        }
    }

    // MARK: - Cancel Notification

    /// Bitta notification'ni o'chirish
    /// - Parameter id: Notification ID
    func cancelNotification(id: Int) {
        let identifier = String(id)
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        center.removeDeliveredNotifications(withIdentifiers: [identifier])
        print("🗑️ Notification cancelled: \(id)")
    }

    /// Barcha notification'larni o'chirish
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        print("🗑️ All notifications cancelled")
    }

    // MARK: - Badge

    /// Badge sonini o'rnatish
    /// - Parameter count: Badge soni
    func setBadge(_ count: Int) {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }

    /// Badge'ni reset qilish
    func clearBadge() {
        setBadge(0)
    }

    // MARK: - Private Helpers

    /// Content yaratish
    private func createContent(
        from details: NotificationDetails,
        userInfo: [AnyHashable: Any]
    ) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()

        // Basic fields
        content.title = details.title
        content.body = details.body

        // Subtitle (iOS specific)
        if let subtitle = details.subtitle {
            content.subtitle = subtitle
        }

        // Badge
        if let badge = details.badge {
            content.badge = NSNumber(value: badge)
        }

        // Category (channelId as category)
        content.categoryIdentifier = details.channelId

        // UserInfo (payload)
        var finalUserInfo = userInfo

        // // Payload'dan data qo'shish
        // if let payload = details.payload {
        //     let payloadDict = payload.mapValues { $0.value }
        //     finalUserInfo.merge(payloadDict) { (_, new) in new }
        // }

        // NotificationDetails'ni ham qo'shish (tap handler uchun)
        finalUserInfo["channelId"] = details.channelId
        finalUserInfo["notificationId"] = details.id

        content.userInfo = finalUserInfo

        // Sound
        if details.silent == true {
            // Silent notification
            content.sound = nil
        } else if let soundUri = details.soundUri {
            content.sound = UNNotificationSound.from(soundUri: soundUri)
        } else {
            content.sound = .default
        }

        // Image attachment (agar imageUrl bo'lsa)
        if let imageUrl = details.imageUrl {
            addImageAttachment(to: content, imageUrl: imageUrl)
        }

        print("Notification content has been created for id: \(String(describing: details.id))")
        return content
    }

    /// Image attachment qo'shish
    private func addImageAttachment(to content: UNMutableNotificationContent, imageUrl: String) {
        // URL dan image yuklab, attachment qilish
        guard let url = URL(string: imageUrl) else { return }

        // Background thread'da image yuklash
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  error == nil,
                  let image = UIImage(data: data) else {
                return
            }

            // Temporary file'ga saqlash
            let tempDir = FileManager.default.temporaryDirectory
            let fileName = UUID().uuidString + ".png"
            let fileURL = tempDir.appendingPathComponent(fileName)

            guard let imageData = image.pngData(),
                  (try? imageData.write(to: fileURL)) != nil else {
                return
            }

            // Attachment yaratish
            if let attachment = try? UNNotificationAttachment(
                identifier: UUID().uuidString,
                url: fileURL,
                options: nil
            ) {
                content.attachments = [attachment]
            }
        }.resume()
    }
}

// MARK: - UNUserNotificationCenterDelegate Extension

extension NotificationService: UNUserNotificationCenterDelegate {

    /// Foreground'da notification kelganda
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        
        let isRemote = notification.request.trigger is UNPushNotificationTrigger
        
        if isRemote {
            do {
                let userInfo = notification.request.content.userInfo
                
                let data = NotificationData.parse(from: userInfo)
                let locale = CacheManager().getLocale()
            
                let details = data?.toNotificationDetails(locale: locale)
                
                print("App language: \(locale)")
                print("Notification details: \(String(describing: details?.title))")
                print("Notification details (sound): \(String(describing: details?.soundUri))")
                
                if let details {
                    try showNotification(details, userInfo: userInfo)
                    completionHandler([])
                    return
                }
            } catch {
                print("❌ showNotification failed: \(error.localizedDescription)")
            }
        }
        
        // For locals (or when parsing failed), just present normally
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .list, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    

    /// Notification tap qilinganda
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        
        let userInfo = response.notification.request.content.userInfo
        print("📱 Notification tapped: \(userInfo)")
        let data = NotificationData.parse(from: userInfo)
        let locale = CacheManager().getLocale()
    
        let _ = data?.toNotificationDetails(locale: locale)
        
        // TODO: Event'ni Flutter'ga yuborish (EventChannel orqali)

        completionHandler()

    }
}
