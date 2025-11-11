package org.perfect.notifications.perfect_notifications.models

import com.google.gson.Gson
import com.google.gson.annotations.SerializedName
import com.google.gson.reflect.TypeToken
import org.perfect.notifications.perfect_notifications.service.LogService

data class NotificationData(
    val defaultTitle: String?,
    val defaultBody: String?,
    val defaultSound: String?,
    val defaultImage: String?,

    @SerializedName("core_title")
    val coreTitle: Map<String, String> = mapOf(),
    @SerializedName("core_sound")
    val coreSound: Map<String, String> = mapOf(),
    @SerializedName("core_body")
    val coreBody: Map<String, String> = mapOf(),
    @SerializedName("core_image")
    val coreImage: Map<String, String> = mapOf(),
    @SerializedName("core_type")
    val coreType: Map<String, String> = mapOf(),
) {
    companion object {
        private val gson = Gson()
        private val type = object : TypeToken<Map<String, String>>() {}.type
        fun parse(data: Map<String, String>): NotificationData {

            val title: Map<String, String> = safeFromJson(json = data["core_title"], "core_title")
            val body: Map<String, String> = safeFromJson(json = data["core_body"], "core_body")
            val sound: Map<String, String> = safeFromJson(json = data["core_sound"], "core_sound")
            val image: Map<String, String> = safeFromJson(json = data["core_image"], "core_image")
            val typeData: Map<String, String> = safeFromJson(json = data["core_type"], "core_type")

            return NotificationData(
                defaultTitle = data["default_title"],
                defaultBody = data["default_body"],
                defaultSound = data["default_sound"],
                defaultImage = data["default_image"],

                coreTitle = title,
                coreBody = body,
                coreSound = sound,
                coreImage = image,
                coreType = typeData,
            )
        }

        private fun safeFromJson(json: String?, key: String): Map<String, String> {
            if (json == null) {
                LogService.error(Exception("Missing key: '$key' in notification data"), "parsing")
                return mapOf()
            }

            return try {
                gson.fromJson(json, type)
            } catch (e: Exception) {
                LogService.error(e, tag = "Failed to parse key: '$key'")
                mapOf()
            }
        }
    }

}


