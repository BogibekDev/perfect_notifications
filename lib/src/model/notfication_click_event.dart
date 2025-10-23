class NotificationClickEvent {
  final String? data;
  final bool fromPush;
  final int? timestamp;

  NotificationClickEvent({
    this.data,
    required this.fromPush,
    this.timestamp,
  });

  factory NotificationClickEvent.fromMap(Map<String, dynamic> map) {
    return NotificationClickEvent(
      data: map['data'] as String?,
      fromPush: map['fromPush'] == true,
      timestamp: map['timestamp'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'data': data,
      'fromPush': fromPush,
      'timestamp': timestamp,
    };
  }

  @override
  String toString() {
    return 'NotificationClickEvent(data: $data, fromPush: $fromPush, timestamp: $timestamp)';
  }
}