import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:perfect_notifications/perfect_notifications.dart';
import 'package:perfect_notifications_example/firebase_options.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  final token = await FirebaseMessaging.instance.getToken();
  print("my FCM token : $token");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _perfectNotificationsPlugin = PerfectNotifications();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    Permission.notification.request();
    final details = ChannelDetails(
      id: 'default_channel',
      name: 'Chat Notifications',
      importance: Importance.high.value,
      description: 'Shows notifications for incoming chat messages',
      enableSound: true,
      soundUri: 'content://settings/system/notification_sound',
      enableVibration: true,
    );

    _perfectNotificationsPlugin.initialize(details);
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _perfectNotificationsPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: Column(
            spacing: 20,
            children: [
              MaterialButton(
                onPressed: () {
                  final details = NotificationDetails(
                    channelId: 'chat_channel',
                    channelName: 'Chat Notifications',
                    title: 'New Message',
                    description:
                        'Ogabek sent you a message: "Hey, are you coming today?" Ogabek sent you a message: "Hey, are you coming today?" Ogabek sent you a message: "Hey, are you coming today?"',
                  );

                  _perfectNotificationsPlugin.showNotification(details);
                },
                child: Text('Show notification'),
              ),
              Text('Running on: $_platformVersion\n'),
            ],
          ),
        ),
      ),
    );
  }
}
