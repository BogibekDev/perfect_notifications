import 'package:perfect_notifications/perfect_notifications.dart';
import 'package:perfect_notifications/src/perfect_notifications_platform_interface.dart';

export 'package:perfect_notifications/src/model/channel_details.dart';
export 'package:perfect_notifications/src/model/notification_details.dart';
export 'package:perfect_notifications/src/model/importance.dart';
export 'package:perfect_notifications/src/model/firebase_options.dart';

class PerfectNotifications {
  Future<String?> getPlatformVersion() {
    return PerfectNotificationsPlatform.instance.getPlatformVersion();
  }

  Future<String?> initialize(ChannelDetails details) {
    return PerfectNotificationsPlatform.instance.initialize(details);
  }

  Future<String?> showNotification(NotificationDetails details) {
    return PerfectNotificationsPlatform.instance.showNotification(details);
  }

  static Future<bool?> initOptions(NotificationOptions options) {
    return PerfectNotificationsPlatform.instance.initOptions(options);
  }
}
