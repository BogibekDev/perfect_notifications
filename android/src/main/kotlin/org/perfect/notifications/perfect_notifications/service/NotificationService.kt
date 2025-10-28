package org.perfect.notifications.perfect_notifications.service

import android.annotation.SuppressLint
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.net.toUri
import com.google.gson.Gson
import org.perfect.notifications.perfect_notifications.models.ChannelDetails
import org.perfect.notifications.perfect_notifications.models.NotificationDetails
import java.net.URL

class NotificationService(private val context: Context) {
    private val notificationManager: NotificationManager =
        context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    @SuppressLint("LaunchActivityFromNotification", "DiscouragedApi")
    fun showNotification(activityIntent: Intent, data: NotificationDetails) {
//        val clickIntent = Intent(context, NotificationReceiver::class.java).apply {
//            action = "org.perfect.notifications.NOTIFICATION_CLICKED"
//            putExtra("data", Gson().toJson(data.payload))
//            putExtra("fromPush", true)
//        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            System.currentTimeMillis().toInt(), // unique ID
            activityIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )


        val icon = run {
            val customResId = context.resources.getIdentifier("ic_stat_name", "drawable", context.packageName)
            if (customResId != 0) customResId else android.R.drawable.presence_online
        }


        val bitmap = try {
            if (data.imageUrl != null && data.imageUrl.isNotBlank()) {
                val url = URL(data.imageUrl)
                BitmapFactory.decodeStream(url.openConnection().getInputStream())
            } else null
        } catch (e: Exception) {
            null
        }

        val style = if (bitmap != null) {
            NotificationCompat.BigPictureStyle().bigPicture(bitmap).bigLargeIcon(null as Bitmap?)
        } else NotificationCompat.BigTextStyle().bigText(data.body)

        val notification = NotificationCompat.Builder(context, data.channelId)
            .setSmallIcon(icon)
            .setContentTitle(data.title)
            .setContentText(data.body)
            .setStyle(style)
            .setLargeIcon(bitmap)
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