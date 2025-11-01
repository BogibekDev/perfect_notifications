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
    private var cacheManager: CacheManager? // Make optional
    private var notificationHandler: NotificationHandler?
    private var channelHandler: ChannelHandler?
    private var languageHandler: LanguageHandler?

    private let resultHandler = ResultHandler()


    override init() {
        // super.init()
        self.notificationService = NotificationService()

        self.notificationHandler = NotificationHandler(
            notificationService: notificationService
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
            name: "perfect_notifications/notification_click",
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

        case "change_sound_enable":

            guard let enable = ArgumentParser().getBool(arguments: call.arguments, key: "enable") else {
                resultHandler.error(
                    result,
                    code: "INVALID_ARGUMENTS",
                    message: "enable is required",
                    details: nil
                )
                return
            }



            // Save
            self.cacheManager?.changeSoundEnable(enable)

            resultHandler.success(result, data: true)

        case "save_language":
            guard let languageHandler = languageHandler else {
                resultHandler.error(result, code: "NOT_INITIALIZED", message: "LanguageHandler not initialized", details: nil)
                return
            }
            languageHandler.handleSaveLanguage(call: call, result: result)

        case "get_language":
                    guard let languageHandler = languageHandler else {
                        resultHandler.error(result, code: "NOT_INITIALIZED", message: "LanguageHandler not initialized", details: nil)
                        return
                    }
                    languageHandler.handleGetLanguage(call: call, result: result)

        case "get_supported_languages":
                    guard let languageHandler = languageHandler else {
                        resultHandler.error(result, code: "NOT_INITIALIZED", message: "LanguageHandler not initialized", details: nil)
                        return
                    }
                    languageHandler.handleGetSupportedLanguages(call: call, result: result)

        case "create_channel":
                    guard let channelHandler = channelHandler else {
                        resultHandler.error(result, code: "NOT_INITIALIZED", message: "ChannelHandler not initialized", details: nil)
                        return
                    }
                    channelHandler.handleCreateChannel(call: call, result: result)

        case "delete_channel":
                    guard let channelHandler = channelHandler else {
                        resultHandler.error(result, code: "NOT_INITIALIZED", message: "ChannelHandler not initialized", details: nil)
                        return
                    }
                    channelHandler.handleDeleteChannel(call: call, result: result)

        case "channel_exists":
                    guard let channelHandler = channelHandler else {
                        resultHandler.error(result, code: "NOT_INITIALIZED", message: "ChannelHandler not initialized", details: nil)
                        return
                    }
                    channelHandler.handleChannelExists(call: call, result: result)

        case "get_all_channels":
                    guard let channelHandler = channelHandler else {
                        resultHandler.error(result, code: "NOT_INITIALIZED", message: "ChannelHandler not initialized", details: nil)
                        return
                    }
                    channelHandler.handleGetAllChannels(call: call, result: result)

        case "show_notification":
                    guard let notificationHandler = notificationHandler else {
                        resultHandler.error(result, code: "NOT_INITIALIZED", message: "NotificationHandler not initialized", details: nil)
                        return
                    }
                    notificationHandler.handleShowNotification(call: call, result: result)

                case "cancel_notification":
                    guard let notificationHandler = notificationHandler else {
                        resultHandler.error(result, code: "NOT_INITIALIZED", message: "NotificationHandler not initialized", details: nil)
                        return
                    }
                    notificationHandler.handleCancelNotification(call: call, result: result)

                case "cancel_all_notifications":
                    guard let notificationHandler = notificationHandler else {
                        resultHandler.error(result, code: "NOT_INITIALIZED", message: "NotificationHandler not initialized", details: nil)
                        return
                    }
                    notificationHandler.handleCancelAll(call: call, result: result)

                case "request_permission":
                    guard let notificationHandler = notificationHandler else {
                        resultHandler.error(result, code: "NOT_INITIALIZED", message: "NotificationHandler not initialized", details: nil)
                        return
                    }
                    notificationHandler.handleRequestPermission(call: call, result: result)

                case "check_permission":
                    guard let notificationHandler = notificationHandler else {
                        resultHandler.error(result, code: "NOT_INITIALIZED", message: "NotificationHandler not initialized", details: nil)
                        return
                    }
                    notificationHandler.handleCheckPermission(call: call, result: result)

                case "set_badge":
                    guard let notificationHandler = notificationHandler else {
                        resultHandler.error(result, code: "NOT_INITIALIZED", message: "NotificationHandler not initialized", details: nil)
                        return
                    }
                    notificationHandler.handleSetBadge(call: call, result: result)

                case "clear_badge":
                    guard let notificationHandler = notificationHandler else {
                        resultHandler.error(result, code: "NOT_INITIALIZED", message: "NotificationHandler not initialized", details: nil)
                        return
                    }
                    notificationHandler.handleClearBadge(call: call, result: result)

        default:
            resultHandler.notImplemented(result)
        }
    }

    private func handleInitalize(call: FlutterMethodCall, result: @escaping FlutterResult) {

        print("Plugin : handleInitalize : ")
        
        guard let appGroupId = ArgumentParser().getString(arguments: call.arguments, key: "app_group_id") else {
            resultHandler.error(
                result,
                code: "INVALID_ARGUMENTS",
                message: "app_group_id is required",
                details: nil
            )
            return
        }

        self.cacheManager = CacheManager(defaults: UserDefaults(suiteName: appGroupId) ?? .standard)
        self.notificationHandler = NotificationHandler(notificationService: notificationService)
        self.channelHandler = ChannelHandler(cacheManager: cacheManager!, notificationService: notificationService)
        self.languageHandler = LanguageHandler(cacheManager: cacheManager!)

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
}
