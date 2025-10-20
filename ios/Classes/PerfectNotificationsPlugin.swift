import Flutter
import UIKit
import UserNotifications
import FirebaseCore
import FirebaseMessaging

public class PerfectNotificationsPlugin: NSObject, FlutterPlugin, UNUserNotificationCenterDelegate, MessagingDelegate, FlutterStreamHandler {
  private var methodChannel: FlutterMethodChannel!
  private var eventChannel: FlutterEventChannel!
  private var eventSink: FlutterEventSink?
  private let notifier = NotificationService()

  // MARK: - FlutterPlugin
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = PerfectNotificationsPlugin()

    instance.methodChannel = FlutterMethodChannel(name: "perfect_notifications", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: instance.methodChannel)

    // (ixtiyoriy) token/notification eventlari uchun stream
    instance.eventChannel = FlutterEventChannel(name: "perfect_notifications/events", binaryMessenger: registrar.messenger())
    instance.eventChannel.setStreamHandler(instance)

    // AppDelegate delegatlari kerak bo‘ladi
    registrar.addApplicationDelegate(instance)
  }

  // MARK: - MethodChannel
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize": // Android bilan mos :contentReference[oaicite:7]{index=7}
      ensureFirebase()
      // Android’da ChannelDetails’dan kanal ochiladi; iOS’da ruxsat so‘raymiz va custom sound nomini eslab qolamiz :contentReference[oaicite:8]{index=8} :contentReference[oaicite:9]{index=9}
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected Map", details: nil))
        return
      }
      // decode channel details (ishlatish ixtiyoriy, lekin sound nomi kerak bo‘lishi mumkin)
      _ = decodeChannel(args)
      UNUserNotificationCenter.current().delegate = self
      notifier.requestAuthorization { _ in
        DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
      }
      result(nil)

    case "show_notification": // Android bilan mos :contentReference[oaicite:10]{index=10}
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected Map", details: nil)); return
      }
      guard let nd = decodeNotification(args) else {
        result(FlutterError(code: "DECODING_ERROR", message: "NotificationDetails decode failed", details: nil)); return
      }

      // Android’da activity intent beriladi; iOS’da userInfo orqali data uzatiladi :contentReference[oaicite:11]{index=11}
      var userInfo: [AnyHashable: Any] = [:]
      args.forEach { userInfo[$0.key] = $0.value }
      let soundName = (args["soundUri"] as? String) ?? nil
      notifier.showNotification(nd, userInfo: userInfo, soundName: soundName)
      result(nil)

    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

    private func ensureFirebase() {
        // Agar firebase_core yo‘q bo‘lsa, shunda configure qilamiz
        if NSClassFromString("FLTFirebaseCorePlugin") == nil, FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
    }

  private func decodeChannel(_ map: [String: Any]) -> ChannelDetails? {
    // Android modelini mirroring qilyapmiz: id, name, importance, description, enableSound, soundUri, enableVibration :contentReference[oaicite:12]{index=12}
    do {
      let data = try JSONSerialization.data(withJSONObject: map, options: [])
      return try JSONDecoder().decode(ChannelDetails.self, from: data)
    } catch {
      return nil
    }
  }

  private func decodeNotification(_ map: [String: Any]) -> NotificationDetails? {
    // Android: channelId, title, description :contentReference[oaicite:13]{index=13}
    do {
      let data = try JSONSerialization.data(withJSONObject: map, options: [])
      return try JSONDecoder().decode(NotificationDetails.self, from: data)
    } catch {
      return nil
    }
  }

  // MARK: - UNUserNotificationCenterDelegate
  public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                     willPresent notification: UNNotification,
                                     withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    // Foregroundda ham ko‘rsatamiz — Android’dagi onMessageReceivedga o‘xshash tajriba :contentReference[oaicite:14]{index=14}
    completionHandler([.banner, .list, .sound])
  }

  // MARK: - MessagingDelegate
  public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    // Android’dagi onNewToken ga mos keladi :contentReference[oaicite:15]{index=15}
    if let token = fcmToken {
      eventSink?(["event": "token", "token": token])
    }
  }

  // MARK: - FlutterStreamHandler
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    return nil
  }
  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }

  // MARK: - UIApplicationDelegate forwarders
  public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
  }

  public func application(_ application: UIApplication,
                          didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                          fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    // Agar silent push (content-available) kelsa — xabarni local ko‘rsatish Android’dagi FCMService ga o‘xshash
    if let title = userInfo["title"] as? String ?? (userInfo["aps"] as? [String: Any])?["alert"] as? String {
      let body = userInfo["body"] as? String ?? ""
      let channelId = userInfo["channelId"] as? String ?? "default_channel"
      let nd = NotificationDetails(channelId: channelId, title: title, description: body)
      notifier.showNotification(nd, userInfo: userInfo)
    }
    completionHandler(.newData)
  }
}

