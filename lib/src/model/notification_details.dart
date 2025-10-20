class NotificationDetails {
  final String channelId;
  final String channelName;
  final String title;
  final String description;

  const NotificationDetails({
    required this.channelId,
    required this.channelName,
    required this.title,
    required this.description,
  });

  Map<String, Object> toMap() {
    return {
      'channelId': channelId,
      'channelName': channelName,
      'title': title,
      'description': description,
    };
  }

  factory NotificationDetails.fromMap(Map<dynamic, dynamic> map) {
    return NotificationDetails(
      channelId: map['channelId'] as String,
      channelName: map['channelName'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
    );
  }

  @override
  String toString() =>
      'NotificationDetails(channelId: $channelId, title: $title)';
}
