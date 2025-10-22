import Flutter
import Foundation

/// Channel operatsiyalarini handle qilish
/// iOS'da notification channel tizimi yo'q, lekin Android compatibility uchun
class ChannelHandler {

    // MARK: - Properties

    private let cacheManager: CacheManager
    private let notificationService: NotificationService
    private let argumentParser: ArgumentParser
    private let resultHandler: ResultHandler

    // MARK: - Initialization

    init(
        cacheManager: CacheManager,
        notificationService: NotificationService,
        argumentParser: ArgumentParser = ArgumentParser(),
        resultHandler: ResultHandler = ResultHandler()
    ) {
        self.cacheManager = cacheManager
        self.notificationService = notificationService
        self.argumentParser = argumentParser
        self.resultHandler = resultHandler
    }

    // MARK: - Create Channel

    /// Channel yaratish (iOS'da faqat cache'ga saqlash)
    /// - Parameters:
    ///   - call: MethodCall
    ///   - result: FlutterResult
    func handleCreateChannel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let parseResult = argumentParser.parse(arguments: call.arguments) { map in
            try ChannelDetails.fromMap(map)
        }

        resultHandler.handleParseResult(result, parseResult: parseResult) { channel in
            // iOS'da channel yaratilmaydi, faqat cache'ga saqlaymiz
            var channels = self.cacheManager.readChannels()

            // Agar mavjud bo'lsa, o'chirish
            channels.removeAll { $0.id == channel.id }

            // Yangi channel qo'shish
            channels.append(channel)

            // Saqlash
            let defaultId = self.cacheManager.getDefaultChannelId()
            self.cacheManager.saveChannels(channels, defaultId: defaultId)

            print("💾 Channel cached (iOS): \(channel.id)")

            // Permission so'rash (agar hali so'ralmagan bo'lsa)
            self.notificationService.checkAuthorizationStatus { status in
                if status == .notDetermined {
                    self.notificationService.requestAuthorization { _ in
                        self.resultHandler.success(result, data: true)
                    }
                } else {
                    self.resultHandler.success(result, data: true)
                }
            }
        }
    }

    // MARK: - Delete Channel

    /// Channel o'chirish (iOS'da faqat cache'dan o'chirish)
    /// - Parameters:
    ///   - call: MethodCall
    ///   - result: FlutterResult
    func handleDeleteChannel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let channelId = argumentParser.getString(arguments: call.arguments, key: "channelId") else {
            resultHandler.error(
                result,
                code: "INVALID_ARGUMENTS",
                message: "channelId is required",
                details: nil
            )
            return
        }

        // Cache'dan o'chirish
        var channels = cacheManager.readChannels()
        channels.removeAll { $0.id == channelId }

        let defaultId = cacheManager.getDefaultChannelId()
        cacheManager.saveChannels(channels, defaultId: defaultId)

        print("🗑️ Channel removed from cache (iOS): \(channelId)")
        resultHandler.success(result, data: true)
    }

    // MARK: - Channel Exists

    /// Channel mavjudligini tekshirish
    /// - Parameters:
    ///   - call: MethodCall
    ///   - result: FlutterResult
    func handleChannelExists(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let channelId = argumentParser.getString(arguments: call.arguments, key: "channelId") else {
            resultHandler.error(
                result,
                code: "INVALID_ARGUMENTS",
                message: "channelId is required",
                details: nil
            )
            return
        }

        let exists = cacheManager.findChannel(id: channelId) != nil
        resultHandler.success(result, data: exists)
    }

    // MARK: - Get All Channels

    /// Barcha channel'larni olish
    /// - Parameters:
    ///   - call: MethodCall
    ///   - result: FlutterResult
    func handleGetAllChannels(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let channels = cacheManager.readChannels()
        let channelMaps = channels.map { $0.toMap() }
        resultHandler.success(result, data: channelMaps)
    }
}