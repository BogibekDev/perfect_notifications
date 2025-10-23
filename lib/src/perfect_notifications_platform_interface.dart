// src/perfect_notifications_platform_interface.dart

import 'package:perfect_notifications/perfect_notifications.dart';
import 'package:perfect_notifications/src/enum/language.dart';
import 'package:perfect_notifications/src/model/notfication_click_event.dart';
import 'package:perfect_notifications/src/perfect_notifications_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class PerfectNotificationsPlatform extends PlatformInterface {
  PerfectNotificationsPlatform() : super(token: _token);

  static final Object _token = Object();

  static PerfectNotificationsPlatform _instance =
  MethodChannelPerfectNotifications();

  static PerfectNotificationsPlatform get instance => _instance;

  static set instance(PerfectNotificationsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // MARK: - Platform Info

  /// Platform versiyasini olish
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }

  // MARK: - Firebase Options


  /// Til ni saqlash
  Future<bool> saveLanguage(Language lan) {
    throw UnimplementedError('saveLanguage() has not been implemented.');
  }

  /// iOS uchun init
  Future<bool> initialize() {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// Firebase sozlamalarini initialize qilish
  Future<bool> initOptions(NotificationOptions options) {
    throw UnimplementedError('initOptions() has not been implemented.');
  }

  // MARK: - Channel Management

  /// Notification channel yaratish (Android 8+)
  Future<void> createChannel(ChannelDetails details) {
    throw UnimplementedError('createChannel() has not been implemented.');
  }

  /// Channel o'chirish
  Future<void> deleteChannel(String channelId) {
    throw UnimplementedError('deleteChannel() has not been implemented.');
  }

  /// Channel mavjudligini tekshirish
  Future<bool> channelExists(String channelId) {
    throw UnimplementedError('channelExists() has not been implemented.');
  }

  /// Barcha channel'larni olish
  Future<List<Map<String, dynamic>>> getAllChannels() {
    throw UnimplementedError('getAllChannels() has not been implemented.');
  }

  // MARK: - Show Notification

  /// Notification ko'rsatish
  Future<void> showNotification(NotificationDetails details) {
    throw UnimplementedError('showNotification() has not been implemented.');
  }

  /// Notification bosilganda ishlaydi
  Stream<NotificationClickEvent> get onNotificationClick {
    throw UnimplementedError('onNotificationClick() has not been implemented.');
  }

  // MARK: - Cancel Notification

  /// Bitta notification'ni o'chirish
  Future<void> cancelNotification(int id) {
    throw UnimplementedError('cancelNotification() has not been implemented.');
  }

  /// Barcha notification'larni o'chirish
  Future<void> cancelAllNotifications() {
    throw UnimplementedError('cancelAllNotifications() has not been implemented.');
  }
}