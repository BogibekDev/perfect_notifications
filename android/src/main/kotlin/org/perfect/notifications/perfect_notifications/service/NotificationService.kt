package org.perfect.notifications.perfect_notifications.service

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.net.toUri
import org.perfect.notifications.perfect_notifications.models.ChannelDetails
import org.perfect.notifications.perfect_notifications.models.NotificationDetails

class NotificationService(private val context: Context) {
    private val notificationManager: NotificationManager =
        context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    fun showNotification(activityIntent: Intent, data: NotificationDetails) {
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            activityIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val iconName = "ic_notification"//TODO
        val resId = context.resources.getIdentifier(iconName, "drawable", context.packageName)
        val notification = NotificationCompat.Builder(context, data.channelId)
            .setSmallIcon(resId)
            .setContentTitle(data.title)
            .setContentText(data.description)
            .setStyle(NotificationCompat.BigTextStyle())
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .build()

        notificationManager.notify(0, notification)
    }

    fun createNotificationChannel(data: ChannelDetails) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val existed = notificationManager.notificationChannels.any { it.id == data.id }

        if (existed) return

        val channel = NotificationChannel(data.id, data.name, data.importance).apply {
            description = data.description
            enableVibration(data.enableVibration)
            if (data.enableSound) {
                val soundUri = data.soundUri?.let {
                    val resId = context.resources.getIdentifier(it, "raw", context.packageName)
                    if (resId != 0) "android.resource://${context.packageName}/$resId".toUri() else null
                }

                val audioAttribute = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()

                setSound(soundUri, audioAttribute)
            } else {
                setSound(null, null)
            }
        }

        notificationManager.createNotificationChannel(channel)
    }


}