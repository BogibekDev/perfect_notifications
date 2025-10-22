import 'package:perfect_notifications/perfect_notifications.dart';

/// Notification Channel sozlamalari (Android 8+ uchun)
/// iOS'da channel yo'q, lekin model compatibility uchun ishlatiladi
class ChannelDetails {
  /// Channel ID - unique identifier
  final String id;

  /// Channel nomi (foydalanuvchi ko'radigan)
  final String name;

  /// Channel tavsifi
  final String description;

  /// Channel muhimligi (Android)
  /// iOS'da bu field ignore qilinadi
  final Importance importance;

  /// Sound yoqilgan/o'chirilgan
  final bool enableSound;

  /// Custom sound fayl nomi (extension bilan)
  /// Android: "sound_name.mp3" yoki "sound_name.ogg" (res/raw/)
  /// iOS: ignore qilinadi (notification'da beriladi)
  final String? soundUri;

  /// Vibration yoqilgan/o'chirilgan
  final bool enableVibration;

  /// Vibration pattern (milliseconds)
  /// Masalan: [0, 250, 250, 250] - wait, vibrate, wait, vibrate
  /// null bo'lsa, default pattern ishlatiladi
  final List<int>? vibrationPattern;

  /// LED light yoqilgan/o'chirilgan (Android)
  final bool enableLights;

  /// LED light rangi (hex format: "#FF0000")
  /// Faqat Android uchun
  final String? lightColor;

  /// Badge ko'rsatish (iOS/Android)
  final bool showBadge;

  /// Lock screen'da qanday ko'rinishi
  final NotificationVisibility? visibility;

  /// Notification sound importance (Android)
  /// true bo'lsa, har safar ovoz chiqadi
  /// false bo'lsa, faqat birinchi notification'da
  final bool playSound;

  /// Channel group ID (bir nechta channel'ni birlash)
  final String? groupId;

  const ChannelDetails({
    required this.id,
    required this.name,
    required this.description,
    this.importance = Importance.high,
    this.enableSound = true,
    this.soundUri,
    this.enableVibration = true,
    this.vibrationPattern,
    this.enableLights = true,
    this.lightColor,
    this.showBadge = true,
    this.visibility,
    this.playSound = true,
    this.groupId,
  });

  /// Map'ga o'tkazish (Native'ga yuborish uchun)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'importance': importance.value,
      'enableSound': enableSound,
      if (soundUri != null) 'soundUri': soundUri,
      'enableVibration': enableVibration,
      if (vibrationPattern != null) 'vibrationPattern': vibrationPattern,
      'enableLights': enableLights,
      if (lightColor != null) 'lightColor': lightColor,
      'showBadge': showBadge,
      if (visibility != null) 'visibility': visibility!.value,
      'playSound': playSound,
      if (groupId != null) 'groupId': groupId,
    };
  }

  /// Map'dan yaratish (Native'dan kelganda)
  factory ChannelDetails.fromMap(Map<dynamic, dynamic> map) {
    return ChannelDetails(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      importance: Importance.values.firstWhere(
        (e) => e.value == (map['importance'] as int? ?? Importance.high.value),
        orElse: () => Importance.high,
      ),
      enableSound: map['enableSound'] as bool? ?? true,
      soundUri: map['soundUri'] as String?,
      enableVibration: map['enableVibration'] as bool? ?? true,
      vibrationPattern: map['vibrationPattern'] != null
          ? List<int>.from(map['vibrationPattern'] as List)
          : null,
      enableLights: map['enableLights'] as bool? ?? true,
      lightColor: map['lightColor'] as String?,
      showBadge: map['showBadge'] as bool? ?? true,
      visibility: map['visibility'] != null
          ? NotificationVisibility.values.firstWhere(
              (e) => e.value == map['visibility'],
              orElse: () => NotificationVisibility.publicVisibility,
            )
          : null,
      playSound: map['playSound'] as bool? ?? true,
      groupId: map['groupId'] as String?,
    );
  }

  /// Copy with - qisman o'zgartirish uchun
  ChannelDetails copyWith({
    String? id,
    String? name,
    String? description,
    Importance? importance,
    bool? enableSound,
    String? soundUri,
    bool? enableVibration,
    List<int>? vibrationPattern,
    bool? enableLights,
    String? lightColor,
    bool? showBadge,
    NotificationVisibility? visibility,
    bool? playSound,
    String? groupId,
  }) {
    return ChannelDetails(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      importance: importance ?? this.importance,
      enableSound: enableSound ?? this.enableSound,
      soundUri: soundUri ?? this.soundUri,
      enableVibration: enableVibration ?? this.enableVibration,
      vibrationPattern: vibrationPattern ?? this.vibrationPattern,
      enableLights: enableLights ?? this.enableLights,
      lightColor: lightColor ?? this.lightColor,
      showBadge: showBadge ?? this.showBadge,
      visibility: visibility ?? this.visibility,
      playSound: playSound ?? this.playSound,
      groupId: groupId ?? this.groupId,
    );
  }

  @override
  String toString() {
    return 'ChannelDetails('
        'id: $id, '
        'name: $name, '
        'importance: ${importance.name}, '
        'sound: $soundUri'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChannelDetails &&
        other.id == id &&
        other.name == name &&
        other.importance == importance;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, importance);
  }
}
