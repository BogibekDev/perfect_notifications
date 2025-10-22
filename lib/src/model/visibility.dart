
/// Lock screen'da notification qanday ko'rinishi
enum NotificationVisibility {
  /// Hamma content ko'rinadi (default)
  publicVisibility(1),

  /// Faqat icon va title
  private(0),

  /// Hech narsa ko'rinmaydi
  secret(-1);

  final int value;
  const NotificationVisibility(this.value);
}