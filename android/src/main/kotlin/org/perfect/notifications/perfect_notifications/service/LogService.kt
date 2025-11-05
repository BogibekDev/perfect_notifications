package org.perfect.notifications.perfect_notifications.service

import android.util.Log

object LogService {
    fun log(message: String, tag: String = "") {
        Log.d("Perfect Notifications: $tag : ", message)
    }

    fun log(message: Any, tag: String = "") {
        Log.d("Perfect Notifications: $tag : ", "$message")
    }
}