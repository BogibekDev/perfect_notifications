package org.perfect.notifications.perfect_notifications.service

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class NotificationReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "NotificationReceiver"
        var onNotificationClick: ((Map<String, Any?>) -> Unit)? = null
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "onReceive called with action: ${intent.action}")

        if (intent.action == "org.perfect.notifications.NOTIFICATION_CLICKED") {
            val data = intent.getStringExtra("data")
            val fromPush = intent.getBooleanExtra("fromPush", false)

            Log.d(TAG, "Notification clicked - data: $data, fromPush: $fromPush")

            val payload = mapOf(
                "data" to data,
                "fromPush" to fromPush,
                "timestamp" to System.currentTimeMillis()
            )

            // Callback orqali Flutter ga yuborish
            onNotificationClick?.invoke(payload)

            // App ni ochish
            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                putExtra("data", data)
                putExtra("fromPush", fromPush)
            }
            launchIntent?.let { context.startActivity(it) }
        }
    }
}