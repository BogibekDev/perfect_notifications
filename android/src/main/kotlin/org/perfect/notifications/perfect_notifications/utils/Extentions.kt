package org.perfect.notifications.perfect_notifications.utils

import com.google.firebase.FirebaseOptions

fun Any?.asInt(): Int = when (this) {
    is Int -> this
    null -> 0
    else -> toString().toInt()
}

fun Any?.asBool(): Boolean = when (this) {
    is Boolean -> this
    null -> true
    else -> false
}

fun Any?.asLong(): Long = when (this) {
    is Long -> this

    null -> 0L

    else -> toString().toLong()
}

fun FirebaseOptions.Builder.fromMap(map: Map<String, Any?>): FirebaseOptions {

    return FirebaseOptions.Builder()
        .setApiKey(map["apiKey"] as String)
        .setApplicationId(map["appId"] as String)
        .setProjectId(map["projectId"] as? String)
        .setGcmSenderId(map["messagingSenderId"] as? String)
        .setStorageBucket(map["storageBucket"] as? String)
        .setDatabaseUrl(map["databaseURL"] as? String)
        .build()
}