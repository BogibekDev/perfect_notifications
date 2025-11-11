# 📦 Perfect Notifications

**Perfect Notifications** — bu Flutter uchun ishlab chiqilgan kuchli va moslashuvchan push hamda lokal xabarnomalar plagini.  
U Firebase Cloud Messaging (FCM) bilan ishlaydi va Android hamda iOS platformalarida to‘liq qo‘llab-quvvatlanadi.

---
[Ingliz tilida](/README.md)

## 🚀 Boshlang‘ich sozlash

### 1. Zarur paketlarni o‘rnatish

`pubspec.yaml` faylga quyidagilarni qo‘shing:

```yaml
permission_handler: ^latest version
firebase_core: ^latest version
firebase_messaging: ^latest version

perfect_notifications:
  git:
    url: https://github.com/BogibekDev/perfect_notifications.git
    ref: latest release
```

### 2. Firebase-ni ishga tushirish (`main.dart` ichida)

```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

### 3. Perfect Notifications-ni ishga tushirish

```dart
await PerfectNotifications.instance.initialize(
  appGroupId: 'your.group.id', // iOS uchun muhim
);
```

### 4. Tilni saqlash (ixtiyoriy)

```dart
await PerfectNotifications.instance.saveLanguage(locale);
```

#### Qo‘llab-quvvatlanadigan [tillar](/lib/src/enum/language.dart):

---

## ⚙️ Ruxsat (Permission) so‘rash

Xabarnomalar uchun ruxsat so‘rash kerak.  
Buni [`permission_handler`](https://pub.dev/packages/permission_handler) yordamida amalga oshirish mumkin:

```dart
Permission.notification.isDenied.then((value) {
  if (value) Permission.notification.request();
});
```

---

## 🔥 Firebase Messaging sozlamalari

Quyidagilarni `main.dart` yoki `init` funksiyada qo‘shing:

```dart
FirebaseMessaging.instance.setAutoInitEnabled(true);

FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  alert: true,
  badge: true,
  sound: true,
);
```

---

## 🔑 Token olish va kuzatish

FCM token — bu qurilmangizni identifikatsiya qiladi.  
Uni serverga yuborish uchun quyidagilarni ishlating:

```dart
try {
  String? token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    // Tokenni serverga yuboring
  }

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    // Yangilangan token uchun logika
  });
} catch (e) {
  // Xatolikni handle qilish
}
```

> 💡 **Maslahat:** Tokenni o‘z serveringizda saqlang, push yuborish uchun kerak bo‘ladi.

---

## 🔔 Notification bosilganda ishlovchi funksiya

```dart
PerfectNotificationService.instance.onNotificationClick.listen((message) {
  if (message.data == null) return;

  final msg = json.decode(message.data!);
  if (msg["data"] == null) return;

  // Sizning logikingiz bu yerda
});

FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  // Sizning logikingiz bu yerda
});
```

---

## 💤 Ilova background yoki yopiq holatda bo‘lganda xabarni olish

```dart
final initial = await FirebaseMessaging.instance.getInitialMessage();

if (initial != null) {
  // Sizning logikingiz bu yerda
}
```

---

## 🌍 Backenddan yuboriladigan xabar misoli

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
      "core_title": "{"uz":"title_uz", "ru":"title_ru"}",
      "core_body": "{"uz":"body_uz", "ru":"body_ru"}",
      "core_image": "{"uz":"image_url_uz", "ru":"image_url_ru"}",
      "core_sound": "{"uz":"sound_uz", "ru":"sound_ru"}",
      "core_type": "{"type":"your_type", "action":"your_action", "data":"your data"}"
    }
  }
}
```

> ⚠️ **Eslatma:** iOS qurilmalarda `apns` bo‘limi muhim. `title` va `body` fallback text bo‘lishi kerak.

---

## 🍏 iOS uchun Notification Service Extension (NSE)

### NSE nima?
**Notification Service Extension (NSE)** — bu iOS tizimida xabarnoma foydalanuvchiga ko‘rsatilishidan oldin fonda uni qayta ishlashga imkon beradi.  
Masalan, tarjima, rasm, tovush yoki maxsus ma’lumot qo‘shish uchun ishlatiladi.

### 1. NSE yaratish
1. Xcode’da `File → New → Target...` bosing  
2. `Notification Service Extension` ni tanlang  
3. Nomini kiriting, masalan: `PerfectNotificationServiceExtension`  
4. `Include Notification Content Extension` belgisi **belgilangan bo‘lmasin**  

### 2. App Group ID sozlash
NSE bilan asosiy ilova ma’lumot almashishi uchun `App Group` kerak bo‘ladi.

1. `Runner` va `PerfectNotificationServiceExtension` targetlarini tanlang  
2. `Signing & Capabilities` → `+ Capability` → `App Groups` ni qo‘shing  
3. Yangi App Group yarating, masalan: `group.com.yourcompany.yourapp`  
4. Shu ID’ni Perfect Notifications-ni ishga tushirish qismida `initialize()` ichida kiriting:

```dart
await PerfectNotifications.instance.initialize(appGroupId: 'group.com.yourcompany.yourapp');
```

### 3. Zarur fayllarni qo‘shish
NSE ichida quyidagi fayllarni joylashtiring:

- [NotificationService.swift](/additional_files/NotificationService.swift) (yangilangan)
- [LogService.swift](/additional_files/LogService.swift)
- [NotificationData.swift](/additional_files/NotificationData.swift)
- [notification_details.swift](/additional_files/notification_details.swift)

Bu fayllar `perfect_notifications` paketidagi iOS logikasi bilan integratsiya qilish uchun kerak.

---

✅ Endi sizning **Perfect Notifications** tizimingiz to‘liq tayyor!  
Siz push va lokal xabarnomalarni Android hamda iOS’da ishlatishingiz mumkin.


## 🐛 Xatolik yoki takliflar
Agar sizda taklif yoki xatolik bo‘lsa, [GitHub Issues](https://github.com/BogibekDev/perfect_notifications/issues) bo‘limida yozib qoldiring.

## 📜 Litsenziya
Bu loyiha [MIT License](LICENSE) asosida tarqatiladi.

## 🤝 Hissa qo‘shish
Takliflar, pull request va o‘zgarishlar xush kelibsiz.  
Iltimos, PR yuborishdan oldin kodni formatlang va testdan o‘tkazing.

## ☕ Rahmat sifatida qo‘llab-quvvatlang
Agar bu loyiha sizga foyda keltirgan bo‘lsa, rahmat sifatida quyidagi havola orqali qo‘llab-quvvatlashingiz mumkin
[Tirikchilik.uz](https://tirikchilik.uz/Bogibekdev)  | `9860 1601 0611 5142`
