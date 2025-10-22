/// Notification ma'lumotlari - iOS va Android uchun
class NotificationDetails {
  /// Notification channel ID (Android uchun majburiy)
  final String channelId;

  /// Notification sarlavhasi
  final String title;

  /// Notification matni
  final String body;

  /// Unique notification ID - update/cancel uchun
  /// Agar null bo'lsa, avtomatik generate qilinadi
  final int? id;

  /// Custom sound fayl nomi (extension bilan)
  /// iOS: "sound_name.caf" yoki "sound_name.wav"
  /// Android: channel'dan olinadi, bu field ignore qilinadi
  final String? soundUri;

  /// iOS uchun qo'shimcha sarlavha (title va body orasida)
  final String? subtitle;

  /// iOS uchun app icon badge raqami
  final int? badge;

  /// Katta rasm URL yoki local path
  /// Android: Big Picture Style
  /// iOS: Attachment
  final String? imageUrl;

  /// Kichik icon URL yoki local path (masalan, user profile picture)
  /// Android: Large Icon
  /// iOS: Bu field ignore qilinadi
  final String? largeIcon;

  /// Notification rangi (hex format: "#FF5722")
  /// Faqat Android uchun
  final String? color;

  /// Bosilganda avtomatik yo'qolishi
  /// Default: true
  final bool autoCancel;

  /// Ovoz va vibration'siz ko'rsatish
  /// Default: false
  final bool silent;

  /// Custom data - notification bosilganda qayta ishlash uchun
  /// Masalan: {"userId": "123", "type": "message"}
  final Map<String, dynamic>? payload;

  const NotificationDetails({
    required this.channelId,
    required this.title,
    required this.body,
    this.id,
    this.soundUri,
    this.subtitle,
    this.badge,
    this.imageUrl,
    this.largeIcon,
    this.color,
    this.autoCancel = true,
    this.silent = false,
    this.payload,
  });

  /// Map'ga o'tkazish (Native'ga yuborish uchun)
  Map<String, dynamic> toMap() {
    return {
      'channelId': channelId,
      'title': title,
      'body': body,
      'description': body, // Android compatibility
      if (id != null) 'id': id,
      if (soundUri != null) 'soundUri': soundUri,
      if (subtitle != null) 'subtitle': subtitle,
      if (badge != null) 'badge': badge,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (largeIcon != null) 'largeIcon': largeIcon,
      if (color != null) 'color': color,
      'autoCancel': autoCancel,
      'silent': silent,
      if (payload != null) 'payload': payload,
    };
  }

  /// Map'dan yaratish (Native'dan kelganda)
  factory NotificationDetails.fromMap(Map<dynamic, dynamic> map) {
    return NotificationDetails(
      channelId: map['channelId'] as String,
      title: map['title'] as String,
      body: (map['body'] ?? map['description']) as String,
      id: map['id'] as int?,
      soundUri: map['soundUri'] as String?,
      subtitle: map['subtitle'] as String?,
      badge: map['badge'] as int?,
      imageUrl: map['imageUrl'] as String?,
      largeIcon: map['largeIcon'] as String?,
      color: map['color'] as String?,
      autoCancel: map['autoCancel'] as bool? ?? true,
      silent: map['silent'] as bool? ?? false,
      payload: map['payload'] != null
          ? Map<String, dynamic>.from(map['payload'] as Map)
          : null,
    );
  }

  /// Copy with - qisman o'zgartirish uchun
  NotificationDetails copyWith({
    String? channelId,
    String? title,
    String? body,
    int? id,
    String? soundUri,
    String? subtitle,
    int? badge,
    String? imageUrl,
    String? largeIcon,
    String? color,
    bool? autoCancel,
    bool? silent,
    Map<String, dynamic>? payload,
  }) {
    return NotificationDetails(
      channelId: channelId ?? this.channelId,
      title: title ?? this.title,
      body: body ?? this.body,
      id: id ?? this.id,
      soundUri: soundUri ?? this.soundUri,
      subtitle: subtitle ?? this.subtitle,
      badge: badge ?? this.badge,
      imageUrl: imageUrl ?? this.imageUrl,
      largeIcon: largeIcon ?? this.largeIcon,
      color: color ?? this.color,
      autoCancel: autoCancel ?? this.autoCancel,
      silent: silent ?? this.silent,
      payload: payload ?? this.payload,
    );
  }

  @override
  String toString() {
    return 'NotificationDetails('
        'channelId: $channelId, '
        'title: $title, '
        'id: $id, '
        'soundUri: $soundUri'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationDetails &&
        other.channelId == channelId &&
        other.title == title &&
        other.body == body &&
        other.id == id;
  }

  @override
  int get hashCode {
    return Object.hash(channelId, title, body, id);
  }
}