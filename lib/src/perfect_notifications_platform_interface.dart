import 'package:perfect_notifications/perfect_notifications.dart';
import 'package:perfect_notifications/src/perfect_notifications_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class PerfectNotificationsPlatform extends PlatformInterface {
  /// Constructs a PerfectNotificationsPlatform.
  PerfectNotificationsPlatform() : super(token: _token);

  static final Object _token = Object();

  static PerfectNotificationsPlatform _instance = MethodChannelPerfectNotifications();

  /// The default instance of [PerfectNotificationsPlatform] to use.
  ///
  /// Defaults to [MethodChannelPerfectNotifications].
  static PerfectNotificationsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PerfectNotificationsPlatform] when
  /// they register themselves.
  static set instance(PerfectNotificationsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool?> initOptions(NotificationOptions options) {
    throw UnimplementedError('initOptions() has not been implemented.');
  }

  Future<String?> initialize(ChannelDetails details) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<String?> showNotification(NotificationDetails details) {
    throw UnimplementedError('showNotification() has not been implemented.');
  }
}
