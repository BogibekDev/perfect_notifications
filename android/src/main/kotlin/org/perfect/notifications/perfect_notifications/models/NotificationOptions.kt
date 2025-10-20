package org.perfect.notifications.perfect_notifications.models

data class NotificationOptions(
    val apiKey: String,
    val appId: String,
    val messagingSenderId: String,
    val projectId: String,
    val authDomain: String? = null,
    val databaseURL: String? = null,
    val storageBucket: String? = null,
    val measurementId: String? = null,
    val trackingId: String? = null,
    val deepLinkURLScheme: String? = null,
    val androidClientId: String? = null,
    val iosClientId: String? = null,
    val iosBundleId: String? = null,
    val appGroupId: String? = null
) {
    val asMap: Map<String, String?>
        get() = mapOf(
            "apiKey" to apiKey,
            "appId" to appId,
            "messagingSenderId" to messagingSenderId,
            "projectId" to projectId,
            "authDomain" to authDomain,
            "databaseURL" to databaseURL,
            "storageBucket" to storageBucket,
            "measurementId" to measurementId,
            "trackingId" to trackingId,
            "deepLinkURLScheme" to deepLinkURLScheme,
            "androidClientId" to androidClientId,
            "iosClientId" to iosClientId,
            "iosBundleId" to iosBundleId,
            "appGroupId" to appGroupId
        )

    companion object {
        fun fromMap(map: Map<*, *>): NotificationOptions {
            return NotificationOptions(
                apiKey = map["apiKey"] as String,
                appId = map["appId"] as String,
                messagingSenderId = map["messagingSenderId"] as String,
                projectId = map["projectId"] as String,
                authDomain = map["authDomain"] as? String,
                databaseURL = map["databaseURL"] as? String,
                storageBucket = map["storageBucket"] as? String,
                measurementId = map["measurementId"] as? String,
                trackingId = map["trackingId"] as? String,
                deepLinkURLScheme = map["deepLinkURLScheme"] as? String,
                androidClientId = map["androidClientId"] as? String,
                iosClientId = map["iosClientId"] as? String,
                iosBundleId = map["iosBundleId"] as? String,
                appGroupId = map["appGroupId"] as? String
            )
        }
    }
}
