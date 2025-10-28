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

            val titleJson = data["core_title"]
            val bodyJson = data["core_body"]
            val soundJson = data["core_sound"]
            val imageJson = data["core_image"]
            val typeDataJson = data["core_type"]

            val title: Map<String, String> = gson.fromJson(titleJson, type)
            val body: Map<String, String> = gson.fromJson(bodyJson, type)
            val sound: Map<String, String> = gson.fromJson(soundJson, type)
            val image: Map<String, String> = gson.fromJson(imageJson, type)
            val typeData: Map<String, String> = gson.fromJson(typeDataJson, type)

            return NotificationData(
                coreTitle = title,
                coreBody = body,
                coreSound = sound,
                coreImage = image,
                coreType = typeData
            )
        }
    }

}


