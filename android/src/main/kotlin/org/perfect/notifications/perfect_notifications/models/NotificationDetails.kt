package org.perfect.notifications.perfect_notifications.models

import org.perfect.notifications.perfect_notifications.utils.asBool
import org.perfect.notifications.perfect_notifications.utils.asInt

data class NotificationDetails(
    val channelId: String,
    val title: String,
    val body: String,
    val id: Int? = null,
    val imageUrl: String? = null,
    val largeIcon: String? = null,
    val color: String? = null,
    val autoCancel: Boolean = true,
    val silent: Boolean = false,
    val payload: Map<String, Any?>? = null
) {
    companion object {
        @Suppress("UNCHECKED_CAST")
        fun fromMap(map: Map<String, Any?>) = NotificationDetails(
            channelId = map["channelId"] as String,
            title = map["title"] as String,
            body = (map["body"] ?: map["description"]) as String,
            id = (map["id"]).asInt(),
            imageUrl = map["imageUrl"] as? String,
            largeIcon = map["largeIcon"] as? String,
            color = map["color"] as? String,
            autoCancel = (map["autoCancel"]).asBool(),
            silent = (map["silent"]).asBool(),
            payload = map["payload"] as? Map<String, Any?>
        )


    }

    fun toMap(): Map<String, Any?> = mapOf(
        "channelId" to channelId,
        "title" to title,
        "body" to body,
        "id" to id,
        "imageUrl" to imageUrl,
        "largeIcon" to largeIcon,
        "color" to color,
        "autoCancel" to autoCancel,
        "silent" to silent,
        "payload" to payload
    )
}