package org.perfect.notifications.perfect_notifications.service

import android.content.Intent
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import org.perfect.notifications.perfect_notifications.models.ChannelDetails
import org.perfect.notifications.perfect_notifications.models.Importance
import org.perfect.notifications.perfect_notifications.models.NotificationData
import org.perfect.notifications.perfect_notifications.models.NotificationDetails

class FCMService : FirebaseMessagingService() {

    override fun onMessageReceived(message: RemoteMessage) {
        LogService.info(message.data, "data")

        val service = NotificationService(this)
        val cacheManager = CacheManager(this)

        val notificationData = NotificationData.parse(message.data)
        val locale = cacheManager.getLocale()

        val channelId =
            localizedCore(notificationData.coreSound, locale, "core_sound") ?: "default_channel"
        val title =
            localizedCore(notificationData.coreTitle, locale, "core_title") ?: "Notification"
        val body = localizedCore(notificationData.coreBody, locale, "core_body") ?: ""
        val sound = localizedCore(notificationData.coreSound, locale, "core_sound")
        val image = localizedCore(notificationData.coreImage, locale, "core_image")

        val enable = cacheManager.getSoundEnable()
        val id = if (enable) "$channelId-enable" else "$channelId-disable"

        val channel = ChannelDetails(
            id,
            "Notification",
            body,
            Importance.IMPORTANCE_HIGH,
            true,
            sound,
            true
        )

        service.createNotificationChannel(channel)

        val launchIntent = packageManager.getLaunchIntentForPackage(packageName) ?: Intent()

        val notification = NotificationDetails(
            channelId = id,
            title = title,
            body = body,
            imageUrl = image,
            payload = mapOf("data" to notificationData)
        )

        service.showNotification(launchIntent, notification)
    }

    override fun onNewToken(token: String) {
        // TODO: Bu tokenni Dart tomoniga MethodChannel/EventChannel orqali yetkazishingiz mumkin.
        // Yoki SharedPreferences ga saqlab, keyin o‘qib olish.
    }

    fun localizedCore(core: Map<String, String>, locale: String, key: String): String? {
        return try {
            val result = core[locale]
            if (result == null) {
                LogService.error(
                    Exception("Missing locale '$locale' for '$key' field."),
                    "localized"
                )
            }
            result
        } catch (e: Exception) {
            LogService.error(Exception("$locale is missing error:${e.message}"), "localized")
            null
        }
    }
}