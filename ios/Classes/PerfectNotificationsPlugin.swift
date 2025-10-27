import Flutter
import UIKit
import UserNotifications
import FirebaseCore
import FirebaseMessaging

/// Perfect Notifications Plugin - iOS Implementation
public class PerfectNotificationsPlugin: NSObject, FlutterPlugin {


    private var methodChannel: FlutterMethodChannel!
    private var eventChannel: FlutterEventChannel?
    private var eventSink: FlutterEventSink?

    private let notificationService: NotificationService
    private let cacheManager: CacheManager

    private let notificationHandler: NotificationHandler
    private let channelHandler: ChannelHandler
    private let languageHandler: LanguageHandler

    private let resultHandler = ResultHandler()


    override init() {
        // super.init()
        self.notificationService = NotificationService()

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


    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = PerfectNotificationsPlugin()

        instance.methodChannel = FlutterMethodChannel(
            name: "perfect_notifications",
            binaryMessenger: registrar.messenger()
        )
        registrar.addMethodCallDelegate(instance, channel: instance.methodChannel)

        instance.eventChannel = FlutterEventChannel(
            name: "perfect_notifications/events",
            binaryMessenger: registrar.messenger()
        )
        instance.eventChannel?.setStreamHandler(instance)

        registrar.addApplicationDelegate(instance)

        UNUserNotificationCenter.current().delegate = instance.notificationService

        print("✅ PerfectNotificationsPlugin registered")
    }


    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {

        case "getPlatformVersion":
            let version = "iOS " + UIDevice.current.systemVersion
            resultHandler.success(result, data: version)

        case "init_options":
            handleInitOptions(call: call, result: result)

        case "initialize":
            handleInitalize(call: call, result: result)

        case "save_language":
            languageHandler.handleSaveLanguage(call: call, result: result)

        case "get_language":
            languageHandler.handleGetLanguage(call: call, result: result)

        case "get_supported_languages":
            languageHandler.handleGetSupportedLanguages(call: call, result: result)

        case "create_channel":
            channelHandler.handleCreateChannel(call: call, result: result)

        case "delete_channel":
            channelHandler.handleDeleteChannel(call: call, result: result)

        case "channel_exists":
            channelHandler.handleChannelExists(call: call, result: result)

        case "get_all_channels":
            channelHandler.handleGetAllChannels(call: call, result: result)

        case "show_notification":
            notificationHandler.handleShowNotification(call: call, result: result)

        case "cancel_notification":
            notificationHandler.handleCancelNotification(call: call, result: result)

        case "cancel_all_notifications":
            notificationHandler.handleCancelAll(call: call, result: result)

        case "request_permission":
            notificationHandler.handleRequestPermission(call: call, result: result)

        case "check_permission":
            notificationHandler.handleCheckPermission(call: call, result: result)

        case "set_badge":
            notificationHandler.handleSetBadge(call: call, result: result)

        case "clear_badge":
            notificationHandler.handleClearBadge(call: call, result: result)

        default:
            resultHandler.notImplemented(result)
        }
    }

    private func handleInitalize(call: FlutterMethodCall, result: @escaping FlutterResult) {

        print("Plugin : handleInitalize : ")
        
        guard let appGroupId = argumentParser.getString(arguments: call.arguments, key: "app_group_id") else {
            resultHandler.error(
                result,
                code: "INVALID_ARGUMENTS",
                message: "app_group_id is required",
                details: nil
            )
            return
        }

        
        self.cacheManager = CacheManager(defaults: UserDefaults(suiteName: appGroupId) ?? .standard)

        Messaging.messaging().delegate = self

        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }

        resultHandler.success(result, data: true)
    }


    private func handleInitOptions(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if FirebaseApp.app() == nil {
            if let args = call.arguments as? [String: Any] {
                do {
                    let options = try createFirebaseOptions(from: args)
                    FirebaseApp.configure(options: options)
                    print("🔥 Firebase configured via plugin")
                } catch {
                    print("⚠️ Firebase configuration error: \(error.localizedDescription)")
                    FirebaseApp.configure()
                }
            } else {
                FirebaseApp.configure()
            }
        }

        Messaging.messaging().delegate = self

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


extension PerfectNotificationsPlugin: MessagingDelegate {

    public func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        guard let token = fcmToken else {
            return
        }

        print("🔑 FCM Token: \(token)")

        eventSink?([
                       "event": "token",
                       "token": token
                   ])
    }
}


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


extension PerfectNotificationsPlugin {

    public func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken

        let tokenString = deviceToken.map {
            String(format: "%02.2hhx", $0)
        }
        .joined()
        print("📱 APNS Token: \(tokenString)")
    }

    public func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    }

    public func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("📬 Remote notification received: \(userInfo)")

        //handleRemoteNotification(userInfo: userInfo)

        completionHandler(.newData)
    }


    private func handleRemoteNotification(userInfo: [AnyHashable: Any]) {

        NSLog("PerfectNotifications: handleRemoteNotification")
        guard let data = NotificationData.parse(from: userInfo) else {
            print("PerfectNotifications: failed to parse NotificationData")
            return
        }

        let locale = cacheManager.getLocale()

        let channelId = data.sound[locale] ?? "default_channel"
        let title = data.title[locale] ?? "Notification"
        let body = data.body[locale] ?? ""
        let sound = data.sound[locale]

        let notificationDetails = NotificationDetails(
            channelId: channelId,
            title: title,
            body: body,
            id: nil,
            soundUri: sound,
            subtitle: nil,
            badge: nil,
            imageUrl: nil,
            largeIcon: nil,
            color: nil,
            autoCancel: true,
            silent: false,
            payload: nil
        )

        do {
            try notificationService.showNotification(notificationDetails, userInfo: userInfo)
        } catch {
            print("❌ Failed to show notification: \(error.localizedDescription)")
        }
    }
}
