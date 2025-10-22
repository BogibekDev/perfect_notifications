// src/model/importance.dart

/// Notification muhimligi (Android 8+)
enum Importance {
  /// Notification ko'rsatilmaydi
  none(0),

  /// Minimal - ovoz va vibration yo'q, status bar'da ham yo'q
  min(1),

  /// Low - ovoz yo'q, lekin status bar'da ko'rinadi
  low(2),

  /// Default - ovoz bor, status bar'da ko'rinadi
  def(3),

  /// High - ovoz bor, heads-up notification
  high(4),

  /// Max - eng muhim, ovoz va heads-up har doim
  max(5),

  /// Unspecified - system default
  unspecified(-1000);

  final int value;
  const Importance(this.value);

  /// Android NotificationManager importance'ga mapping
  int get androidValue {
    switch (this) {
      case Importance.none:
        return 0; // IMPORTANCE_NONE
      case Importance.min:
        return 1; // IMPORTANCE_MIN
      case Importance.low:
        return 2; // IMPORTANCE_LOW
      case Importance.def:
        return 3; // IMPORTANCE_DEFAULT
      case Importance.high:
        return 4; // IMPORTANCE_HIGH
      case Importance.max:
        return 5; // IMPORTANCE_MAX
      case Importance.unspecified:
        return -1000; // IMPORTANCE_UNSPECIFIED
    }
  }

  /// Priority'dan Importance'ga mapping (Android < 8)
  static Importance fromPriority(int priority) {
    if (priority >= 2) return Importance.max;
    if (priority >= 1) return Importance.high;
    if (priority >= 0) return Importance.def;
    if (priority >= -1) return Importance.low;
    return Importance.min;
  }
}