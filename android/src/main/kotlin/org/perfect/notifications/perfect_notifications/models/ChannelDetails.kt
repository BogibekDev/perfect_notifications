package org.perfect.notifications.perfect_notifications.models

data class ChannelDetails(
    val id: String,
    val name: String,
    val description: String,
    val importance: Int = Importance.IMPORTANCE_HIGH,
    val enableSound: Boolean = true,
    val soundUri: String? = null,
    val enableVibration: Boolean = true
) {
    companion object {
        fun fromMap(map: Map<String, Any?>): ChannelDetails {
            return ChannelDetails(
                id = map["id"] as String,
                name = map["name"] as String,
                importance = (map["importance"] as Number).toInt(),
                description = map["description"] as String,
                enableSound = map["enableSound"] as Boolean,
                soundUri = map["soundUri"] as? String,
                enableVibration = map["enableVibration"] as Boolean
            )
        }
    }

    fun toMap(): Map<String, Any?> = mapOf(
        "id" to id,
        "name" to name,
        "importance" to importance,
        "description" to description,
        "enableSound" to enableSound,
        "soundUri" to soundUri,
        "enableVibration" to enableVibration
    )
}