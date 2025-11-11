
# 📦 Perfect Notifications

**Perfect Notifications** is a powerful and flexible plugin for Flutter that enables both push and local notifications.  
It works with Firebase Cloud Messaging (FCM) and provides full support for both Android and iOS platforms.

---
[Read in Uzbek](/README_UZ.md)

## 🚀 Getting Started

### 1. Install Required Packages

Add the following dependencies to your `pubspec.yaml` file:

```yaml
permission_handler: ^latest version
firebase_core: ^latest version
firebase_messaging: ^latest version

perfect_notifications:
  git:
    url: https://github.com/BogibekDev/perfect_notifications.git
    ref: latest release
```

### 2. Initialize Firebase (inside `main.dart`)

```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

### 3. Initialize Perfect Notifications

```dart
await PerfectNotifications.instance.initialize(
  appGroupId: 'your.group.id', // Important for iOS
);
```

### 4. Save App Language (optional)

```dart
await PerfectNotifications.instance.saveLanguage(locale);
```

#### Supported [languages](/lib/src/enum/language.dart):

---

## ⚙️ Requesting Permissions

Notifications require user permission.  
You can request it using the [`permission_handler`](https://pub.dev/packages/permission_handler) package:

```dart
Permission.notification.isDenied.then((value) {
  if (value) Permission.notification.request();
});
```

---

## 🔥 Firebase Messaging Setup

Add the following inside your `main.dart` or initialization method:

```dart
FirebaseMessaging.instance.setAutoInitEnabled(true);

FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  alert: true,
  badge: true,
  sound: true,
);
```

---

## 🔑 Retrieve and Monitor Token

The FCM token identifies the device.  
Use the following code to retrieve and send it to your server:

```dart
try {
  String? token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    // Send token to your server
  }

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    // Handle token refresh
  });
} catch (e) {
  // Handle error
}
```

> 💡 **Tip:** Save the token on your server for targeted push notifications.

---

## 🔔 Handling Notification Clicks

```dart
PerfectNotificationService.instance.onNotificationClick.listen((message) {
  if (message.data == null) return;

  final msg = json.decode(message.data!);
  if (msg["data"] == null) return;

  // Your logic here
});

FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  // Your logic here
});
```

---

## 💤 Handling Notifications When App is Closed or in Background

```dart
final initial = await FirebaseMessaging.instance.getInitialMessage();

if (initial != null) {
  // Your logic here
}
```

---

## 🌍 Example of a Backend Notification Payload

```json
{
  "message": {
    "token": "<DEVICE_FCM_TOKEN>",
    "topic": "<TOPIC_NAME>",
    "apns": {
      "payload": {
        "aps": {
          "alert": {
            "title": "iOS title fallback",
            "body": "iOS body fallback"
          },
          "content-available": 1,
          "mutable-content": 1
        }
      }
    },
    "data": {
      "default_title": "Default title",
      "default_body": "Default body",
      "default_sound": "Default sound",
      "default_image": "Default image url",
      "core_title": "{\"uz\":\"title_uz\", \"ru\":\"title_ru\"}",
      "core_body": "{\"uz\":\"body_uz\", \"ru\":\"body_ru\"}",
      "core_image": "{\"uz\":\"image_url_uz\", \"ru\":\"image_url_ru\"}",
      "core_sound": "{\"uz\":\"sound_uz\", \"ru\":\"sound_ru\"}",
      "core_type": "{\"type\":\"your_type\", \"action\":\"your_action\", \"data\":\"your data\"}"
    }
  }
}
```

> ⚠️ **Note:** The `apns` section is required for iOS.  
> The `title` and `body` fields act as fallback values.

---

## 🍏 iOS — Notification Service Extension (NSE)

### What is NSE?
**Notification Service Extension (NSE)** allows you to process push notifications in the background before they are displayed to the user.  
You can use it to translate messages, add images, sounds, or custom data.

### 1. Create an NSE
1. In Xcode, go to `File → New → Target...`
2. Select **Notification Service Extension**
3. Enter a name, for example: `PerfectNotificationServiceExtension`
4. Make sure **“Include Notification Content Extension”** is **unchecked**

### 2. Set Up App Group ID
App Groups enable your main app and NSE to share data.

1. Select both `Runner` and `PerfectNotificationServiceExtension` targets  
2. Go to `Signing & Capabilities` → click `+ Capability` → select `App Groups`  
3. Create a new App Group, for example: `group.com.yourcompany.yourapp`  
4. Use the same ID inside your Flutter initialization:

```dart
await PerfectNotifications.instance.initialize(appGroupId: 'group.com.yourcompany.yourapp');
```

### 3. Add Required Files
Inside your NSE folder, add these files:

- [NotificationService.swift](/additional_files/NotificationService.swift) (updated)
- [LogService.swift](/additional_files/LogService.swift)
- [NotificationData.swift](/additional_files/NotificationData.swift)
- [notification_details.swift](/additional_files/notification_details.swift)

These files connect your NSE logic with the iOS part of the `perfect_notifications` package.

---

✅ Your **Perfect Notifications** setup is now complete!  
You can now send and receive both push and local notifications on Android and iOS.



## 🐛 🐛 Issues and Suggestions
If you have any ideas, feature requests, or found a bug, please open an issue in the [GitHub Issues](https://github.com/BogibekDev/perfect_notifications/issues) section.
## 📜 License
This project is distributed under the [MIT License](LICENSE)

## 🤝 Contributing
Contributions, pull requests, and improvements are always welcome.
Please make sure to format your code and run tests before submitting a PR.

## ☕ Support the Project
If this project has been helpful to you, you can show your appreciation by supporting it here:

[Tirikchilik.uz](https://tirikchilik.uz/Bogibekdev)  | `9860 1601 0611 5142`