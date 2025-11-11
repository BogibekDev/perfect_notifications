import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            let defaults = UserDefaults(suiteName: "group.com.yourcompany.yourapp") ?? .standard
            let locale = defaults.string(forKey: "perfect_notifications_locale") ?? "uz"
            let enable = defaults.object(forKey: "sound_enable") as? Bool ?? true;
            print("NSE: Locale = \(locale)")
            // Modify the notification content here...
            
            let data = NotificationData.parse(from: bestAttemptContent.userInfo)
            
            let details = data?.toNotificationDetails(locale: locale,soundEnable: enable)
            
            bestAttemptContent.title = details?.title ?? bestAttemptContent.title
            bestAttemptContent.body = details?.body ?? bestAttemptContent.body
            
            if let sound = details?.soundUri {
                bestAttemptContent.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: sound))
            }
            if let imageUrlString = details?.imageUrl,
               let imageUrl = URL(string: imageUrlString), imageUrl.scheme == "https" {
                
                let task = URLSession.shared.dataTask(with: imageUrl) { data, _, _ in
                    if let data = data, let attachment = try? UNNotificationAttachment(identifier: "image", url: self.saveImage(data: data), options: nil) {
                        bestAttemptContent.attachments = [attachment]
                    }
                        contentHandler(bestAttemptContent)
                }
                task.resume()
                return
            }
            
            
            
            
            contentHandler(bestAttemptContent)
        }
    }
    
    private func saveImage(data: Data) throws -> URL {
            let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("image.jpg")
            try data.write(to: url)
            return url
        }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
