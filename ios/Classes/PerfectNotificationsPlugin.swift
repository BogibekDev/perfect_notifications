// ios/Classes/PerfectNotificationsPlugin.swift

import Flutter
import UIKit
import UserNotifications
import FirebaseCore
import FirebaseMessaging

/// Perfect Notifications Plugin - iOS Implementation
public class PerfectNotificationsPlugin: NSObject, FlutterPlugin {
    
    // MARK: - Properties
    
    private var methodChannel: FlutterMethodChannel!
    private var eventChannel: FlutterEventChannel?
    private var eventSink: FlutterEventSink?
    
    // Services
    private let notificationService: NotificationService
    private let cacheManager: CacheManager
    
    // Handlers
    private let notificationHandler: NotificationHandler
    private let channelHandler: ChannelHandler
    private let languageHandler: LanguageHandler
    
    // Utils
    private let resultHandler = ResultHandler()
    
    // MARK: - Initialization
    
    override init() {
        // Initialize services
        self.notificationService = NotificationService()
        self.cacheManager = CacheManager()
        
        // Initialize handlers
        self.notificationHandler = NotificationHandler(
            notificationService: notificationService
        )
        self.channelHandler = ChannelHandler(
            cacheManager: cacheManager,
            notificationService: notificationService
        )
        self.languageHandler = LanguageHandler(
            cacheManager: cacheManager
        )
        
        super.init()
    }
    
    // MARK: - FlutterPlugin
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = PerfectNotificationsPlugin()
        
        // Method Channel
        instance.methodChannel = FlutterMethodChannel(
            name: "perfect_notifications",
            binaryMessenger: registrar.messenger()
        )
        registrar.addMethodCallDelegate(instance, channel: instance.methodChannel)
        
        // Event Channel (optional - token/notification events uchun)
        instance.eventChannel = FlutterEventChannel(
            name: "perfect_notifications/events",
            binaryMessenger: registrar.messenger()
        )
        instance.eventChannel?.setStreamHandler(instance)
        
        // AppDelegate delegates
        registrar.addApplicationDelegate(instance)
        
        // UNUserNotificationCenter delegate
        UNUserNotificationCenter.current().delegate = instance.notificationService
        
        print("✅ PerfectNotificationsPlugin registered")
    }
    
    // MARK: - Method Channel Handler
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            
        // MARK: - Platform Info
        case "getPlatformVersion":
            let version = "iOS " + UIDevice.current.systemVersion
            resultHandler.success(result, data: version)
            
        // MARK: - Firebase Options
        case "init_options":
            handleInitOptions(call: call, result: result)
            
        // MARK: - Language
        case "save_language":
            languageHandler.handleSaveLanguage(call: call, result: result)
            
        case "get_language":
            languageHandler.handleGetLanguage(call: call, result: result)
            
        case "get_supported_languages":
            languageHandler.handleGetSupportedLanguages(call: call, result: result)
            
        // MARK: - Channels (iOS dummy)
        case "create_channel":
            channelHandler.handleCreateChannel(call: call, result: result)
            
        case "delete_channel":
            channelHandler.handleDeleteChannel(call: call, result: result)
            
        case "channel_exists":
            channelHandler.handleChannelExists(call: call, result: result)
            
        case "get_all_channels":
            channelHandler.handleGetAllChannels(call: call, result: result)
            
        // MARK: - Notifications
        case "show_notification":
            notificationHandler.handleShowNotification(call: call, result: result)
            
        case "cancel_notification":
            notificationHandler.handleCancelNotification(call: call, result: result)
            
        case "cancel_all_notifications":
            notificationHandler.handleCancelAll(call: call, result: result)
            
        // MARK: - Permission
        case "request_permission":
            notificationHandler.handleRequestPermission(call: call, result: result)
            
        case "check_permission":
            notificationHandler.handleCheckPermission(call: call, result: result)
            
        // MARK: - Badge
        case "set_badge":
            notificationHandler.handleSetBadge(call: call, result: result)
            
        case "clear_badge":
            notificationHandler.handleClearBadge(call: call, result: result)
            
        // MARK: - Not Implemented
        default:
            resultHandler.notImplemented(result)
        }
    }
    
    // MARK: - Firebase Initialization
    
    private func handleInitOptions(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Firebase'ni initialize qilish (agar firebase_core yo'q bo'lsa)
        if FirebaseApp.app() == nil {
            // Arguments'dan FirebaseOptions yaratish
            if let args = call.arguments as? [String: Any] {
                do {
                    let options = try createFirebaseOptions(from: args)
                    FirebaseApp.configure(options: options)
                    print("🔥 Firebase configured via plugin")
                } catch {
                    print("⚠️ Firebase configuration error: \(error.localizedDescription)")
                    // Agar xatolik bo'lsa, default configure
                    FirebaseApp.configure()
                }
            } else {
                // Arguments yo'q bo'lsa, default configure
                FirebaseApp.configure()
            }
        }
        
        // FCM delegate
        Messaging.messaging().delegate = self
        
        // Remote notifications registration
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        resultHandler.success(result, data: true)
    }
    
    private func createFirebaseOptions(from map: [String: Any]) throws -> FirebaseOptions {
        guard let apiKey = map["apiKey"] as? String,
              let appId = map["appId"] as? String,
              let messagingSenderId = map["messagingSenderId"] as? String,
              let projectId = map["projectId"] as? String else {
            throw NSError(
                domain: "PerfectNotifications",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Missing required Firebase options"]
            )
        }
        
        let options = FirebaseOptions(
            googleAppID: appId,
            gcmSenderID: messagingSenderId
        )
        options.apiKey = apiKey
        options.projectID = projectId
        options.storageBucket = map["storageBucket"] as? String
        options.databaseURL = map["databaseURL"] as? String
        
        return options
    }
}

// MARK: - MessagingDelegate (FCM)

extension PerfectNotificationsPlugin: MessagingDelegate {
    
    /// FCM token yangilanganda
    public func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        guard let token = fcmToken else { return }
        
        print("🔑 FCM Token: \(token)")
        
        // Event channel orqali Flutter'ga yuborish
        eventSink?([
            "event": "token",
            "token": token
        ])
    }
}

// MARK: - FlutterStreamHandler (Event Channel)

extension PerfectNotificationsPlugin: FlutterStreamHandler {
    
    public func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}

// MARK: - UIApplicationDelegate (Remote Notifications)

extension PerfectNotificationsPlugin {
    
    /// APNS token qabul qilish
    public func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // FCM'ga APNS token berish
        Messaging.messaging().apnsToken = deviceToken
        
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("📱 APNS Token: \(tokenString)")
    }
    
    /// APNS registration error
    public func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    /// Background/killed holatda notification kelganda
    public func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("📬 Remote notification received: \(userInfo)")
        
        // FCM'dan kelgan notification'ni handle qilish
        handleRemoteNotification(userInfo: userInfo)
        
        completionHandler(.newData)
    }
    
    // MARK: - Private Helpers
    
    private func handleRemoteNotification(userInfo: [AnyHashable: Any]) {
        // Multilang notification processing (Android FCMService'dagi kabi)
        
        // Get locale
        let locale = cacheManager.getLocale()
        
        // Parse notification data
        let title = extractLocalizedString(from: userInfo, key: "title", locale: locale)
        let body = extractLocalizedString(from: userInfo, key: "body", locale: locale)
        let soundUri = extractLocalizedString(from: userInfo, key: "sound", locale: locale)
        
        // Channel ID
        let channelId = soundUri ?? "default_channel"
        
        // Create notification details
        let notificationDetails = NotificationDetails(
            channelId: channelId,
            title: title ?? "Notification",
            body: body ?? "",
            id: nil,
            soundUri: soundUri,
            subtitle: nil,
            badge: nil,
            imageUrl: nil,
            largeIcon: nil,
            color: nil,
            autoCancel: true,
            silent: false,
            payload: nil
        )
        
        // Show notification
        do {
            try notificationService.showNotification(notificationDetails, userInfo: userInfo)
        } catch {
            print("❌ Failed to show notification: \(error.localizedDescription)")
        }
    }
    
    /// Multilang string extraction
    private func extractLocalizedString(
        from userInfo: [AnyHashable: Any],
        key: String,
        locale: String
    ) -> String? {
        // Try to get JSON string and parse
        guard let jsonString = userInfo[key] as? String,
              let jsonData = jsonString.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: String] else {
            // Fallback: direct string
            return userInfo[key] as? String
        }
        
        // Get localized value
        return dict[locale] ?? dict["en"] ?? dict.values.first
    }
}
