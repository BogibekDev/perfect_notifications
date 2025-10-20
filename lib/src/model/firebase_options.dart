class NotificationOptions {
  const NotificationOptions({
    required this.apiKey,
    required this.appId,
    required this.messagingSenderId,
    required this.projectId,
    this.authDomain,
    this.databaseURL,
    this.storageBucket,
    this.measurementId,
    // ios specific
    this.trackingId,
    this.deepLinkURLScheme,
    this.androidClientId,
    this.iosClientId,
    this.iosBundleId,
    this.appGroupId,
  });

  NotificationOptions copyWith({
    String? apiKey,
    String? appId,
    String? messagingSenderId,
    String? projectId,
    String? authDomain,
    String? databaseURL,
    String? storageBucket,
    String? measurementId,
    String? trackingId,
    String? deepLinkURLScheme,
    String? androidClientId,
    String? iosClientId,
    String? iosBundleId,
    String? appGroupId,
  }) {
    return NotificationOptions(
      apiKey: apiKey ?? this.apiKey,
      appId: appId ?? this.appId,
      messagingSenderId: messagingSenderId ?? this.messagingSenderId,
      projectId: projectId ?? this.projectId,
      authDomain: authDomain ?? this.authDomain,
      databaseURL: databaseURL ?? this.databaseURL,
      storageBucket: storageBucket ?? this.storageBucket,
      measurementId: measurementId ?? this.measurementId,
      trackingId: trackingId ?? this.trackingId,
      deepLinkURLScheme: deepLinkURLScheme ?? this.deepLinkURLScheme,
      androidClientId: androidClientId ?? this.androidClientId,
      iosClientId: iosClientId ?? this.iosClientId,
      iosBundleId: iosBundleId ?? this.iosBundleId,
      appGroupId: appGroupId ?? this.appGroupId,
    );
  }

  /// An API key used for authenticating requests from your app to Google
  /// servers.
  final String apiKey;

  /// The Google App ID that is used to uniquely identify an instance of an app.
  final String appId;

  /// The unique sender ID value used in messaging to identify your app.
  final String messagingSenderId;

  /// The Project ID from the Firebase console, for example "my-awesome-app".
  final String projectId;

  /// The auth domain used to handle redirects from OAuth provides on web
  /// platforms, for example "my-awesome-app.firebaseapp.com".
  final String? authDomain;

  /// The database root URL, for example "https://my-awesome-app.firebaseio.com."
  ///
  /// This property should be set for apps that use Firebase Database.
  final String? databaseURL;

  /// The Google Cloud Storage bucket name, for example
  /// "my-awesome-app.appspot.com".
  final String? storageBucket;

  /// The project measurement ID value used on web platforms with analytics.
  final String? measurementId;

  /// The tracking ID for Google Analytics, for example "UA-12345678-1", used to
  /// configure Google Analytics.
  ///
  /// This property is used on iOS only.
  final String? trackingId;

  /// The URL scheme used by iOS secondary apps for Dynamic Links.
  final String? deepLinkURLScheme;

  /// The Android OAuth client ID from the Firebase Console, for example
  /// "12345.apps.googleusercontent.com."
  ///
  /// This value is used on Android only.
  final String? androidClientId;

  /// The iOS client ID from the Firebase Console, for example
  /// "12345.apps.googleusercontent.com."
  ///
  /// This value is used by iOS only.
  final String? iosClientId;

  /// The iOS bundle ID for the application. Defaults to `[[NSBundle mainBundle] bundleID]`
  /// when not set manually or in a plist.
  ///
  /// This property is used on iOS only.
  final String? iosBundleId;

  /// The iOS App Group identifier to share data between the application and the
  /// application extensions.
  ///
  /// Note that if using this then the App Group must be configured in the
  /// application and on the Apple Developer Portal.
  ///
  /// This property is used on iOS only.
  final String? appGroupId;

  /// The current instance as a [Map].
  Map<String, String?> get asMap {
    return <String, String?>{
      'apiKey': apiKey,
      'appId': appId,
      'messagingSenderId': messagingSenderId,
      'projectId': projectId,
      'authDomain': authDomain,
      'databaseURL': databaseURL,
      'storageBucket': storageBucket,
      'measurementId': measurementId,
      'trackingId': trackingId,
      'deepLinkURLScheme': deepLinkURLScheme,
      'androidClientId': androidClientId,
      'iosClientId': iosClientId,
      'iosBundleId': iosBundleId,
      'appGroupId': appGroupId,
    };
  }

  @override
  String toString() => asMap.toString();
}