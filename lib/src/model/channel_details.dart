class ChannelDetails {
  final String id;
  final String name;
  final int importance;
  final String description;
  final bool enableSound;
  final String? soundUri;
  final bool enableVibration;

  const ChannelDetails({
    required this.id,
    required this.name,
    required this.importance,
    required this.description,
    required this.enableSound,
    this.soundUri,
    required this.enableVibration,
  });

  Map<String, Object> toMap() {
    return {
      'id': id,
      'name': name,
      'importance': importance,
      'description': description,
      'enableSound': enableSound,
      'soundUri': ?soundUri,
      'enableVibration': enableVibration,
    };
  }

  factory ChannelDetails.fromMap(Map<dynamic, dynamic> map) {
    return ChannelDetails(
      id: map['id'] as String,
      name: map['name'] as String,
      importance: map['importance'] as int,
      description: map['description'] as String,
      enableSound: map['enableSound'] as bool,
      soundUri: map['soundUri'] as String?,
      enableVibration: map['enableVibration'] as bool,
    );
  }

  @override
  String toString() => 'ChannelDetails($id, $name, $importance)';
}
