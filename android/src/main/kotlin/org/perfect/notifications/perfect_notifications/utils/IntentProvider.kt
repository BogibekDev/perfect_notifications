package org.perfect.notifications.perfect_notifications.utils

import android.app.Activity
import android.content.Context
import android.content.Intent

class IntentProvider(private val context: Context) {

    private var activity: Activity? = null

    fun setActivity(activity: Activity?) {
        this.activity = activity
    }

    fun getLaunchIntent(): Intent? {
        return activity?.intent
            ?: context.packageManager.getLaunchIntentForPackage(context.packageName)
    }
}