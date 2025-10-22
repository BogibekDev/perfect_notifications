import 'package:perfect_notifications/perfect_notifications.dart';

/// NotificationDetails extension methods
extension NotificationDetailsExtension on NotificationDetails {
  /// iOS notification yaratish (soundUri bilan)
  NotificationDetails forIOS({required String soundUri}) {
    return copyWith(soundUri: soundUri);
  }

  /// Android notification yaratish
  NotificationDetails forAndroid() {
    return copyWith(soundUri: null); // Android channel'dan sound oladi
  }

  /// Silent notification yaratish
  NotificationDetails asSilent() {
    return copyWith(silent: true);
  }

  /// Badge bilan notification
  NotificationDetails withBadge(int badge) {
    return copyWith(badge: badge);
  }

  /// Image bilan notification
  NotificationDetails withImage(String imageUrl) {
    return copyWith(imageUrl: imageUrl);
  }

  /// Custom payload bilan
  NotificationDetails withPayload(Map<String, dynamic> payload) {
    return copyWith(payload: payload);
  }
}

/// ChannelDetails extension methods
extension ChannelDetailsExtension on ChannelDetails {
  /// Silent channel yaratish
  ChannelDetails asSilent() {
    return copyWith(
      enableSound: false,
      enableVibration: false,
      importance: Importance.low,
    );
  }

  /// High priority channel
  ChannelDetails asHighPriority() {
    return copyWith(
      importance: Importance.high,
      enableSound: true,
      enableVibration: true,
    );
  }

  /// Custom sound bilan
  ChannelDetails withSound(String soundUri) {
    return copyWith(
      soundUri: soundUri,
      enableSound: true,
    );
  }
}