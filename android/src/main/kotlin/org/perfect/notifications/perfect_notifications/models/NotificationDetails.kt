package org.perfect.notifications.perfect_notifications.models

data class NotificationDetails(
    val channelId: String,
    val title: String,
    val description: String,
) {
    companion object {
        fun fromMap(map: Map<String, Any?>) = NotificationDetails(
            channelId = map["channelId"] as String,
            title = map["title"] as String,
            description = map["description"] as String
        )

    }

    fun toMap(): Map<String, Any> = mapOf(
        "channelId" to channelId,
        "title" to title,
        "description" to description
    )
}