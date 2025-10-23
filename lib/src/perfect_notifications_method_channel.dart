import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:perfect_notifications/perfect_notifications.dart';
import 'package:perfect_notifications/src/enum/methods.dart';
import 'package:perfect_notifications/src/model/notfication_click_event.dart';
import 'package:perfect_notifications/src/perfect_notifications_platform_interface.dart';

/// Method channel implementation - Native platform bilan aloqa
class MethodChannelPerfectNotifications extends PerfectNotificationsPlatform {
  /// Method channel instance
  @visibleForTesting
  final methodChannel = const MethodChannel('perfect_notifications');
  final EventChannel _eventChannel =  const EventChannel('perfect_notifications/notification_click');
  Stream<NotificationClickEvent>? _onNotificationClickStream;

  // MARK: - Platform Version

  @override
  Future<String?> getPlatformVersion() async {
    try {
      final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
      return version;
    } on PlatformException catch (e) {
      debugPrint('Error getting platform version: ${e.message}');
      return null;
    }
  }

  // MARK: - Firebase Options

  @override
  Future<bool> initOptions(NotificationOptions options) async {
    try {
      final result = await methodChannel.invokeMethod<bool>(
        Methods.initOptions.name,
        options.asMap,
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error initializing options: ${e.code} - ${e.message}');
      throw NotificationException(
        'Failed to initialize notification options',
        code: e.code,
        details: e.details,
      );
    } catch (e) {
      debugPrint('Unexpected error initializing options: $e');
      throw NotificationException('Unexpected error: $e');
    }
  }

  // MARK: - Channel Management

  @override
  Future<void> createChannel(ChannelDetails details) async {
    try {
      await methodChannel.invokeMethod<void>(Methods.createChannel.name, details.toMap());
    } on PlatformException catch (e) {
      debugPrint('Error creating channel: ${e.code} - ${e.message}');
      throw NotificationException(
        'Failed to create notification channel',
        code: e.code,
        details: e.details,
      );
    } catch (e) {
      debugPrint('Unexpected error creating channel: $e');
      throw NotificationException('Unexpected error: $e');
    }
  }

  @override
  Future<void> deleteChannel(String channelId) async {
    try {
      await methodChannel.invokeMethod<void>(Methods.deleteChannel.name, {'channelId': channelId});
    } on PlatformException catch (e) {
      debugPrint('Error deleting channel: ${e.code} - ${e.message}');
      throw NotificationException('Failed to delete channel', code: e.code, details: e.details);
    } catch (e) {
      debugPrint('Unexpected error deleting channel: $e');
      throw NotificationException('Unexpected error: $e');
    }
  }

  @override
  Future<bool> channelExists(String channelId) async {
    try {
      final result = await methodChannel.invokeMethod<bool>(Methods.channelExists.name, {
        'channelId': channelId,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error checking channel: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Unexpected error checking channel: $e');
      return false;
    }
  }

  @override
  Future<bool> saveLanguage(Language lan) async {
    try {
      final bool? result = await methodChannel.invokeMethod<bool>(Methods.saveLanguage.name, {
        'locale': lan.locale,
      });

      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('PlatformException in saveLanguage: ${e.code} - ${e.message}');
      return false;
    } catch (e, stack) {
      debugPrint('Unexpected error in saveLanguage: $e');
      debugPrint('$stack');
      return false;
    }
  }

  @override
  Future<bool> initialize() async {
    try {
      final bool? result = await methodChannel.invokeMethod<bool>(Methods.initialize.name);

      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('PlatformException in saveLanguage: ${e.code} - ${e.message}');
      return false;
    } catch (e, stack) {
      debugPrint('Unexpected error in saveLanguage: $e');
      debugPrint('$stack');
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllChannels() async {
    try {
      final result = await methodChannel.invokeMethod<List>(Methods.getAllChannels.name);
      if (result == null) return [];

      return result.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } on PlatformException catch (e) {
      debugPrint('Error getting channels: ${e.code} - ${e.message}');
      return [];
    } catch (e) {
      debugPrint('Unexpected error getting channels: $e');
      return [];
    }
  }

  // MARK: - Show Notification

  @override
  Future<void> showNotification(NotificationDetails details) async {
    try {
      await methodChannel.invokeMethod<void>(
        Methods.showNotification.name,
        details.toMap(), // ✅ Clean - hech narsa qo'shilmaydi
      );
    } on PlatformException catch (e) {
      debugPrint('Error showing notification: ${e.code} - ${e.message}');
      throw NotificationException('Failed to show notification', code: e.code, details: e.details);
    } catch (e) {
      debugPrint('Unexpected error showing notification: $e');
      throw NotificationException('Unexpected error: $e');
    }
  }
@override
  Stream<NotificationClickEvent> get onNotificationClick {
    _onNotificationClickStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => NotificationClickEvent.fromMap(Map<String, dynamic>.from(event)))
        .handleError((error) {
      print('Notification click error: $error');
    });
    return _onNotificationClickStream!;
  }

  // MARK: - Cancel Notification

  @override
  Future<void> cancelNotification(int id) async {
    try {
      await methodChannel.invokeMethod<void>(Methods.cancelNotification.name, {'id': id});
    } on PlatformException catch (e) {
      debugPrint('Error cancelling notification: ${e.code} - ${e.message}');
      throw NotificationException(
        'Failed to cancel notification',
        code: e.code,
        details: e.details,
      );
    } catch (e) {
      debugPrint('Unexpected error cancelling notification: $e');
      throw NotificationException('Unexpected error: $e');
    }
  }

  @override
  Future<void> cancelAllNotifications() async {
    try {
      await methodChannel.invokeMethod<void>(Methods.cancelAllNotifications.name);
    } on PlatformException catch (e) {
      debugPrint('Error cancelling all notifications: ${e.code} - ${e.message}');
      throw NotificationException(
        'Failed to cancel all notifications',
        code: e.code,
        details: e.details,
      );
    } catch (e) {
      debugPrint('Unexpected error cancelling all notifications: $e');
      throw NotificationException('Unexpected error: $e');
    }
  }
}
