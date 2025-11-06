package org.perfect.notifications.perfect_notifications.service

import android.util.Log

object LogService {
    fun debug(message: String, tag: String = "") {
        Log.d("🤖 Perfect Notifications: $tag : ", "\n$message")
    }

    fun info(message: Any, tag: String = "") {
        Log.i("ℹ️ Perfect Notifications: $tag : ", "\n$message")
    }

    fun success(message: Any, tag: String = "") {
        Log.i("✅ Perfect Notifications: $tag : ", "\n$message")
    }

    fun warning(message: Any, tag: String = "") {
        Log.w("⚠️ Perfect Notifications: $tag : ", "'\n$message")
    }

    fun error(error: Exception, tag: String = "") {
        Log.e("❌ Perfect Notifications: $tag : ", "\nmessage : ${error.message}")
    }
}