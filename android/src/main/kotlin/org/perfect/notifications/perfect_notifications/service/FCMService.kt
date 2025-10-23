package org.perfect.notifications.perfect_notifications.service

import android.content.Intent
import android.os.Build
import androidx.annotation.RequiresApi
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import com.google.gson.Gson
import org.perfect.notifications.perfect_notifications.models.ChannelDetails
import org.perfect.notifications.perfect_notifications.models.Importance
import org.perfect.notifications.perfect_notifications.models.NotificationData
import org.perfect.notifications.perfect_notifications.models.NotificationDetails

class FCMService : FirebaseMessagingService() {

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onMessageReceived(message: RemoteMessage) {
        val service = NotificationService(this)
        val cacheManager = CacheManager(this)

        val notificationData = NotificationData.parse(message.data)
        print(notificationData)
        val locale = cacheManager.getLocale()

        val channelId = notificationData?.sound[locale] ?: "default_channel"
        val title = notificationData?.title[locale] ?: "Notification"
        val body = notificationData?.body[locale] ?: ""
        val sound = notificationData?.sound[locale]

        val channel = ChannelDetails(
            channelId,
            "Notification",
            body,
            Importance.IMPORTANCE_HIGH,
            true,
            sound,
            true
        )

        service.recreateNotificationChannel(channel)

        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putExtra("data", Gson().toJson(data))
            putExtra("fromPush", true)
        } ?: Intent() // fallback

        val notification = NotificationDetails(
            channelId = channelId,
            title = title,
            body = body,
            payload = mapOf("data" to notificationData)
        )

        service.showNotification(launchIntent, notification)
    }

    override fun onNewToken(token: String) {
        // TODO: Bu tokenni Dart tomoniga MethodChannel/EventChannel orqali yetkazishingiz mumkin.
        // Yoki SharedPreferences ga saqlab, keyin o‘qib olish.
    }
}