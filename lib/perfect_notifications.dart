import 'package:perfect_notifications/src/enum/language.dart';
import 'package:perfect_notifications/src/model/channel_details.dart';
import 'package:perfect_notifications/src/model/firebase_options.dart';
import 'package:perfect_notifications/src/model/notfication_click_event.dart';
import 'package:perfect_notifications/src/model/notification_details.dart';
import 'package:perfect_notifications/src/model/notification_exception.dart';
import 'package:perfect_notifications/src/perfect_notifications_platform_interface.dart';

export 'package:perfect_notifications/src/model/channel_details.dart';
export 'package:perfect_notifications/src/model/extension.dart';
export 'package:perfect_notifications/src/model/firebase_options.dart';
export 'package:perfect_notifications/src/model/importance.dart';
export 'package:perfect_notifications/src/model/notification_details.dart';
export 'package:perfect_notifications/src/model/notification_exception.dart';
export 'package:perfect_notifications/src/model/visibility.dart';
export 'package:perfect_notifications/src/enum/language.dart';
export 'package:perfect_notifications/src/model/notfication_click_event.dart';

/// Perfect Notifications Plugin
///
/// iOS va Android uchun notification'larni boshqarish
class PerfectNotifications {
  PerfectNotifications._();

  /// Singleton instance
  static final PerfectNotifications instance = PerfectNotifications._();

  /// Platform interface
  static PerfectNotificationsPlatform get _platform => PerfectNotificationsPlatform.instance;

  // MARK: - Platform Info

  /// Platform versiyasini olish
  ///
  /// Returns:
  /// - Android: "Android 13"
  /// - iOS: "iOS 16.0"
  Future<String?> getPlatformVersion() async {
    return await _platform.getPlatformVersion();
  }

  // MARK: - Firebase Initialization

  /// Firebase notification sozlamalarini initialize qilish
  ///
  /// [options] - Firebase configuration
  ///
  /// Throws:
  /// - [NotificationException] agar initialization muvaffaqiyatsiz bo'lsa
  ///
  /// Example:
  /// ```dart
  /// await PerfectNotifications.instance.initializeFirebase(
  ///   NotificationOptions(
  ///     apiKey: 'your-api-key',
  ///     appId: 'your-app-id',
  ///     messagingSenderId: 'sender-id',
  ///     projectId: 'project-id',
  ///   ),
  /// );
  /// ```
  Future<void> initializeFirebase(NotificationOptions options) async {
    final success = await _platform.initOptions(options);
    if (!success) {
      throw const NotificationException(
        'Failed to initialize Firebase options',
        code: 'INIT_FAILED',
      );
    }
  }

  // MARK: - Channel Management

  /// Notification channel yaratish (Android 8+ uchun)
  /// iOS'da bu method hech narsa qilmaydi
  ///
  /// [channel] - Channel sozlamalari
  ///
  /// Throws:
  /// - [NotificationException] agar channel yaratilmasa
  ///
  /// Example:
  /// ```dart
  /// await PerfectNotifications.instance.createChannel(
  ///   ChannelDetails(
  ///     id: 'messages',
  ///     name: 'Messages',
  ///     description: 'Message notifications',
  ///     importance: Importance.high,
  ///     soundUri: 'custom_sound.mp3',
  ///   ),
  /// );
  /// ```
  Future<void> createChannel(ChannelDetails channel) async {
    await _platform.createChannel(channel);
  }

  /// Bir nechta channel'larni yaratish
  ///
  /// [channels] - Channel'lar ro'yxati
  ///
  /// Throws:
  /// - [NotificationException] agar biron channel yaratilmasa
  Future<void> createChannels(List<ChannelDetails> channels) async {
    for (final channel in channels) {
      await createChannel(channel);
    }
  }

  /// Channel o'chirish
  ///
  /// [channelId] - Channel ID
  ///
  /// Note: Android restriction - agar foydalanuvchi channel sozlamalarini
  /// o'zgartirgan bo'lsa, channel o'chirilganda ham sozlamalar saqlanadi
  Future<void> deleteChannel(String channelId) async {
    await _platform.deleteChannel(channelId);
  }

  /// Channel mavjudligini tekshirish
  ///
  /// [channelId] - Channel ID
  ///
  /// Returns: true agar channel mavjud bo'lsa
  Future<bool> channelExists(String channelId) async {
    return await _platform.channelExists(channelId);
  }

  /// Tildagi ma'lumotni saqlaydi.
  ///
  /// [lan] - Saqlanadigan til obyekti.
  ///
  /// Returns: `true` agar til muvaffaqiyatli saqlansa.
  Future<bool> saveLanguage(Language lan) async {
    return await _platform.saveLanguage(lan);
  }



  /// Returns: `true` agar  muvaffaqiyatli bo'lsa.
  Future<bool> initialize() async {
    return await _platform.initialize();
  }


  /// Barcha channel'larni olish
  ///
  /// Returns: Channel'lar ro'yxati (faqat Android)
  /// iOS'da bo'sh list qaytadi
  Future<List<Map<String, dynamic>>> getAllChannels() async {
    return await _platform.getAllChannels();
  }

  // MARK: - Show Notification

  /// Notification ko'rsatish
  ///
  /// [notification] - Notification ma'lumotlari
  ///
  /// Throws:
  /// - [NotificationException] agar notification ko'rsatilmasa
  ///
  /// Example:
  /// ```dart
  /// await PerfectNotifications.instance.show(
  ///   NotificationDetails(
  ///     channelId: 'messages',
  ///     title: 'New Message',
  ///     body: 'You have a new message',
  ///     soundUri: 'custom_sound', // iOS uchun
  ///     badge: 5,
  ///   ),
  /// );
  /// ```
  Future<void> show(NotificationDetails notification) async {
    // Channel mavjudligini tekshirish (faqat debug mode'da)
    assert(
      await channelExists(notification.channelId),
      'Channel "${notification.channelId}" does not exist. '
      'Create channel first using createChannel()',
    );

    await _platform.showNotification(notification);
  }

  Stream<NotificationClickEvent> get onNotificationClick => _platform.onNotificationClick;

  /// Bir nechta notification'larni ko'rsatish
  ///
  /// [notifications] - Notification'lar ro'yxati
  Future<void> showMultiple(List<NotificationDetails> notifications) async {
    for (final notification in notifications) {
      await show(notification);
    }
  }

  // MARK: - Cancel Notification

  /// Bitta notification'ni o'chirish
  ///
  /// [id] - Notification ID
  ///
  /// Example:
  /// ```dart
  /// await PerfectNotifications.instance.cancel(123);
  /// ```
  Future<void> cancel(int id) async {
    await _platform.cancelNotification(id);
  }

  /// Bir nechta notification'larni o'chirish
  ///
  /// [ids] - Notification ID'lar ro'yxati
  Future<void> cancelMultiple(List<int> ids) async {
    for (final id in ids) {
      await cancel(id);
    }
  }

  /// Barcha notification'larni o'chirish
  ///
  /// Example:
  /// ```dart
  /// await PerfectNotifications.instance.cancelAll();
  /// ```
  Future<void> cancelAll() async {
    await _platform.cancelAllNotifications();
  }

  // MARK: - Utility Methods

  /// Channel yaratish va notification ko'rsatish (shortcut)
  ///
  /// Agar channel mavjud bo'lmasa, avval yaratadi, keyin notification ko'rsatadi
  ///
  /// [channel] - Channel sozlamalari
  /// [notification] - Notification ma'lumotlari
  Future<void> createChannelAndShow({
    required ChannelDetails channel,
    required NotificationDetails notification,
  }) async {
    if (!await channelExists(channel.id)) {
      await createChannel(channel);
    }
    await show(notification);
  }

  /// Scheduled notification (kelajakda ko'rsatish)
  /// TODO: Implement later
  @Deprecated('Not implemented yet')
  Future<void> schedule({
    required NotificationDetails notification,
    required DateTime scheduledDate,
  }) async {
    throw UnimplementedError('Scheduled notifications not implemented yet');
  }

  /// Repeating notification (takrorlanadigan)
  /// TODO: Implement later
  @Deprecated('Not implemented yet')
  Future<void> showRepeating({
    required NotificationDetails notification,
    required Duration interval,
  }) async {
    throw UnimplementedError('Repeating notifications not implemented yet');
  }
}
