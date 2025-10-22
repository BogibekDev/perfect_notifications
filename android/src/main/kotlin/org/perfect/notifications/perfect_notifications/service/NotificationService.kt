package org.perfect.notifications.perfect_notifications.service

import android.annotation.SuppressLint
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.net.Uri
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

        val iconName = "ic_notification"
        val tryResId = context.resources.getIdentifier(iconName, "drawable", context.packageName)
        val smallIcon = when {
            tryResId != 0 -> tryResId
            context.applicationInfo.icon != 0 -> context.applicationInfo.icon
            else -> android.R.drawable.ic_dialog_info
        }

        val notification = NotificationCompat.Builder(context, data.channelId)
            .setSmallIcon(smallIcon)
            .setContentTitle(data.title)
            .setContentText(data.body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(data.body))
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .build()

        val id = data.channelId.hashCode()
        notificationManager.notify(id, notification)
    }


    @SuppressLint("WrongConstant")
    fun createNotificationChannel(data: ChannelDetails) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val existed = channelExists(data.id)
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


    fun recreateNotificationChannel(data: ChannelDetails) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            deleteNotificationChannel(data.id)
            createNotificationChannel(data)
        }
    }

    fun deleteNotificationChannel(channelId: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notificationManager.deleteNotificationChannel(channelId)
        }
    }

    fun channelExists(id: String): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notificationManager.notificationChannels.any { it.id == id }
        } else true
    }

    fun getAllChannels(): List<Map<String, Any?>> {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return emptyList()

        return notificationManager.notificationChannels.map {
            mapOf(
                "id" to it.id,
                "name" to it.name?.toString(),
                "description" to it.description,
                "importance" to it.importance,
                "canBypassDnd" to it.canBypassDnd(),
                "group" to it.group
            )
        }
    }

    fun cancel(id: Int) {
        notificationManager.cancel(id)
    }

    fun cancelAll() {
        notificationManager.cancelAll()
    }

    fun getAttributes(): AudioAttributes {
        return AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_NOTIFICATION)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
    }

    fun getSoundUri(sound: String?): Uri? {
        return sound?.let {
            val resId = context.resources.getIdentifier(it, "raw", context.packageName)
            if (resId != 0) "android.resource://${context.packageName}/$resId".toUri() else null
        }

    }
}