import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_notifications/perfect_notifications.dart';
import 'package:perfect_notifications/src/perfect_notifications_method_channel.dart';
import 'package:perfect_notifications/src/perfect_notifications_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPerfectNotificationsPlatform
    with MockPlatformInterfaceMixin
    implements PerfectNotificationsPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String?> initialize(ChannelDetails details) {
    // TODO: implement initialize
    throw UnimplementedError();
  }

  @override
  Future<String?> showNotification(NotificationDetails details) {
    // TODO: implement showNotification
    throw UnimplementedError();
  }

  @override
  Future<bool?> initOptions(NotificationOptions options) {
    // TODO: implement initOptions
    throw UnimplementedError();
  }



}

void main() {
  final PerfectNotificationsPlatform initialPlatform = PerfectNotificationsPlatform.instance;

  test('$MethodChannelPerfectNotifications is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPerfectNotifications>());
  });

  test('getPlatformVersion', () async {
    PerfectNotifications perfectNotificationsPlugin = PerfectNotifications();
    MockPerfectNotificationsPlatform fakePlatform = MockPerfectNotificationsPlatform();
    PerfectNotificationsPlatform.instance = fakePlatform;

    expect(await perfectNotificationsPlugin.getPlatformVersion(), '42');
  });
}
