package org.perfect.notifications.perfect_notifications.service

import android.content.Intent
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import com.google.gson.Gson
import org.perfect.notifications.perfect_notifications.models.NotificationDetails

class FCMService : FirebaseMessagingService() {

    override fun onMessageReceived(message: RemoteMessage) {
        println(message)
        val service = NotificationService(this)
        val data = message.data
        val title = message.notification?.title ?: data["title"] ?: "Notification"
        val body = message.notification?.body ?: data["body"] ?: ""

        val channelId = data["channelId"] ?: "default_channel"

        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putExtra("data", Gson().toJson(data))
            putExtra("fromPush", true)
        } ?: Intent() // fallback

        val notification = NotificationDetails(
            channelId = channelId,
            title = title,
            description = body,
        )
        service.showNotification(launchIntent, notification)
    }

    override fun onNewToken(token: String) {
        // TODO: Bu tokenni Dart tomoniga MethodChannel/EventChannel orqali yetkazishingiz mumkin.
        // Yoki SharedPreferences ga saqlab, keyin o‘qib olish.
    }
}