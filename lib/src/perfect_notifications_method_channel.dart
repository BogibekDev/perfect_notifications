import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:perfect_notifications/perfect_notifications.dart';
import 'package:perfect_notifications/src/methods.dart';
import 'package:perfect_notifications/src/perfect_notifications_platform_interface.dart';

/// An implementation of [PerfectNotificationsPlatform] that uses method channels.
class MethodChannelPerfectNotifications extends PerfectNotificationsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('perfect_notifications');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> initialize(ChannelDetails details) async {
    print("method: ${Methods.initialize.name}");
    print("details: ${details.toMap()}");
    final version = await methodChannel.invokeMethod<String?>(
      Methods.initialize.name,
      details.toMap(),
    );
    return version;
  }

  @override
  Future<String?> showNotification(NotificationDetails details) async {
    print("method: ${Methods.showNotification.name}");
    print("details: ${details.toMap()}");
    final version = await methodChannel.invokeMethod<String?>(
      Methods.showNotification.name,
      details.toMap(),
    );
    return version;
  }

  @override
  Future<bool?> initOptions(NotificationOptions options) async {
    print("method: ${Methods.initOptions.name}");
    print("details: ${options.asMap}");
    final isInitialized = await methodChannel.invokeMethod<bool?>(
      Methods.initOptions.name,
      options.asMap,
    );
    return isInitialized;
  }
}
