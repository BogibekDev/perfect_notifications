
/// Notification xatosi
class NotificationException implements Exception {
  /// Xato xabari
  final String message;

  /// Xato kodi (platform'dan keladi)
  final String? code;

  /// Qo'shimcha ma'lumot
  final dynamic details;

  const NotificationException(
      this.message, {
        this.code,
        this.details,
      });

  @override
  String toString() {
    if (code != null) {
      return 'NotificationException($code): $message${details != null ? ' - $details' : ''}';
    }
    return 'NotificationException: $message';
  }
}