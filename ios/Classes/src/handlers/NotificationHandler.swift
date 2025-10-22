import Flutter
import Foundation

/// Notification operatsiyalarini handle qilish
class NotificationHandler {

    // MARK: - Properties

    private let notificationService: NotificationService
    private let argumentParser: ArgumentParser
    private let resultHandler: ResultHandler

    // MARK: - Initialization

    init(
        notificationService: NotificationService,
        argumentParser: ArgumentParser = ArgumentParser(),
        resultHandler: ResultHandler = ResultHandler()
    ) {
        self.notificationService = notificationService
        self.argumentParser = argumentParser
        self.resultHandler = resultHandler
    }

    // MARK: - Show Notification

    /// Notification ko'rsatish
    /// - Parameters:
    ///   - call: MethodCall
    ///   - result: FlutterResult
    func handleShowNotification(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Arguments parse qilish
        let parseResult = argumentParser.parse(arguments: call.arguments) { map in
            try NotificationDetails.fromMap(map)
        }

        resultHandler.handleParseResult(result, parseResult: parseResult) { details in
            do {
                // Permission tekshirish
                notificationService.checkAuthorizationStatus { status in
                    switch status {
                    case .authorized, .provisional, .ephemeral:
                        // Permission bor - notification ko'rsatish
                        do {
                            // UserInfo yaratish (payload uchun)
                            let userInfo = self.createUserInfo(from: call.arguments)

                            try self.notificationService.showNotification(details, userInfo: userInfo)
                            self.resultHandler.success(result, data: true)
                        } catch {
                            self.resultHandler.error(
                                result,
                                code: "SHOW_NOTIFICATION_ERROR",
                                message: error.localizedDescription,
                                details: error.userFriendlyMessage
                            )
                        }

                    case .denied:
                        self.resultHandler.error(
                            result,
                            code: "PERMISSION_DENIED",
                            message: "Notification permission denied. Please enable in Settings.",
                            details: nil
                        )

                    case .notDetermined:
                        self.resultHandler.error(
                            result,
                            code: "PERMISSION_NOT_DETERMINED",
                            message: "Notification permission not requested yet. Call requestPermission first.",
                            details: nil
                        )

                    @unknown default:
                        self.resultHandler.error(
                            result,
                            code: "PERMISSION_UNKNOWN",
                            message: "Unknown permission status",
                            details: nil
                        )
                    }
                }
            }
        }
    }

    // MARK: - Cancel Notification

    /// Bitta notification'ni o'chirish
    /// - Parameters:
    ///   - call: MethodCall
    ///   - result: FlutterResult
    func handleCancelNotification(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let id = argumentParser.getInt(arguments: call.arguments, key: "id") else {
            resultHandler.error(
                result,
                code: "INVALID_ARGUMENTS",
                message: "id is required",
                details: nil
            )
            return
        }

        notificationService.cancelNotification(id: id)
        resultHandler.success(result, data: true)
    }

    /// Barcha notification'larni o'chirish
    /// - Parameters:
    ///   - call: MethodCall
    ///   - result: FlutterResult
    func handleCancelAll(call: FlutterMethodCall, result: @escaping FlutterResult) {
        notificationService.cancelAllNotifications()
        resultHandler.success(result, data: true)
    }

    // MARK: - Permission

    /// Permission so'rash
    /// - Parameters:
    ///   - call: MethodCall
    ///   - result: FlutterResult
    func handleRequestPermission(call: FlutterMethodCall, result: @escaping FlutterResult) {
        notificationService.requestAuthorization { granted in
            self.resultHandler.success(result, data: granted)
        }
    }

    /// Permission status tekshirish
    /// - Parameters:
    ///   - call: MethodCall
    ///   - result: FlutterResult
    func handleCheckPermission(call: FlutterMethodCall, result: @escaping FlutterResult) {
        notificationService.checkAuthorizationStatus { status in
            let statusString: String
            switch status {
            case .authorized: statusString = "authorized"
            case .denied: statusString = "denied"
            case .notDetermined: statusString = "notDetermined"
            case .provisional: statusString = "provisional"
            // case .ephemeral: statusString = "ephemeral"
            @unknown default: statusString = "unknown"
            }

            self.resultHandler.success(result, data: [
                "status": statusString,
                "isAuthorized": status == .authorized || status == .provisional
            ])
        }
    }

    // MARK: - Badge

    /// Badge o'rnatish
    /// - Parameters:
    ///   - call: MethodCall
    ///   - result: FlutterResult
    func handleSetBadge(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let count = argumentParser.getInt(arguments: call.arguments, key: "count") else {
            resultHandler.error(
                result,
                code: "INVALID_ARGUMENTS",
                message: "count is required",
                details: nil
            )
            return
        }

        notificationService.setBadge(count)
        resultHandler.success(result, data: true)
    }

    /// Badge tozalash
    /// - Parameters:
    ///   - call: MethodCall
    ///   - result: FlutterResult
    func handleClearBadge(call: FlutterMethodCall, result: @escaping FlutterResult) {
        notificationService.clearBadge()
        resultHandler.success(result, data: true)
    }

    // MARK: - Private Helpers

    /// UserInfo yaratish (arguments'dan)
    private func createUserInfo(from arguments: Any?) -> [AnyHashable: Any] {
        guard let map = arguments as? [String: Any] else {
            return [:]
        }

        var userInfo: [AnyHashable: Any] = [:]

        // Barcha field'larni qo'shish
        map.forEach { key, value in
            userInfo[key] = value
        }

        return userInfo
    }
}