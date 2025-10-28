package org.perfect.notifications.perfect_notifications.models

import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

data class NotificationData(
    val coreTitle: Map<String, String> = mapOf(),
    val coreSound: Map<String, String> = mapOf(),
    val coreBody: Map<String, String> = mapOf(),
    val coreImage: Map<String, String> = mapOf(),
    val coreType: Map<String, String> = mapOf(),
) {
    companion object {
        private val gson = Gson()
        private val type = object : TypeToken<Map<String, String>>() {}.type
        fun parse(data: Map<String, String>): NotificationData? {

            val title: Map<String, String> = safeFromJson(json = data["core_title"])
            val body: Map<String, String> = safeFromJson(json = data["core_body"])
            val sound: Map<String, String> = safeFromJson(json = data["core_sound"])
            val image: Map<String, String> = safeFromJson(json = data["core_image"])
            val typeData: Map<String, String> = safeFromJson(json = data["core_type"])

            return NotificationData(
                coreTitle = title,
                coreBody = body,
                coreSound = sound,
                coreImage = image,
                coreType = typeData
            )
        }

        private fun safeFromJson(json: String?): Map<String, String> {
            if (json == null) return mapOf()

            return try {
                gson.fromJson(json, type)
            } catch (_: Exception) {
                mapOf()
            }
        }
    }

}


