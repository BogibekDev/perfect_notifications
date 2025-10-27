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
  Future<String?> showNotification(NotificationDetails details) {
    // TODO: implement showNotification
    throw UnimplementedError();
  }


  @override
  Future<void> cancelAllNotifications() {
    // TODO: implement cancelAllNotifications
    throw UnimplementedError();
  }

  @override
  Future<void> cancelNotification(int id) {
    // TODO: implement cancelNotification
    throw UnimplementedError();
  }

  @override
  Future<bool> channelExists(String channelId) {
    // TODO: implement channelExists
    throw UnimplementedError();
  }

  @override
  Future<void> createChannel(ChannelDetails details) {
    // TODO: implement createChannel
    throw UnimplementedError();
  }

  @override
  Future<void> deleteChannel(String channelId) {
    // TODO: implement deleteChannel
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> getAllChannels() {
    // TODO: implement getAllChannels
    throw UnimplementedError();
  }

  @override
  Future<bool> initOptions(NotificationOptions options) {
    // TODO: implement initOptions
    throw UnimplementedError();
  }

  @override
  Future<bool> saveLanguage(Language lan) {
    // TODO: implement saveLanguage
    throw UnimplementedError();
  }

  @override
  Future<bool> initialize({String appGroupId=''}) {
    // TODO: implement initialize

    throw UnimplementedError();
  }

  @override
  // TODO: implement onNotificationClick
  Stream<NotificationClickEvent> get onNotificationClick => throw UnimplementedError();



}

void main() {
  final PerfectNotificationsPlatform initialPlatform = PerfectNotificationsPlatform.instance;

  test('$MethodChannelPerfectNotifications is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPerfectNotifications>());
  });

  test('getPlatformVersion', () async {
    PerfectNotifications perfectNotificationsPlugin = PerfectNotifications.instance;
    MockPerfectNotificationsPlatform fakePlatform = MockPerfectNotificationsPlatform();
    PerfectNotificationsPlatform.instance = fakePlatform;

    expect(await perfectNotificationsPlugin.getPlatformVersion(), '42');
  });
}
