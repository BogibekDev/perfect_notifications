package org.perfect.notifications.perfect_notifications

import android.content.Context
import androidx.core.content.edit
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import org.perfect.notifications.perfect_notifications.models.ChannelDetails

class CacheManager(private val context: Context) {

    private val PREF = "perfect_notifications_prefs"
    private val KEY_DEFAULT = "default_channel_id"
    private val KEY_CHANNELS_JSON = "channels_json"
    private val gson = Gson()

    fun find(id: String): ChannelDetails? = readAll().firstOrNull { it.id == id }

    fun saveChannels(defaultId: String, channels: List<ChannelDetails>) {
        val prefs = context.getSharedPreferences(PREF, Context.MODE_PRIVATE)
        val json = gson.toJson(channels)
        prefs.edit {
            putString(KEY_DEFAULT, defaultId)
            putString(KEY_CHANNELS_JSON, json)
        }
    }

    fun readDefault(): String = context.getSharedPreferences(PREF, Context.MODE_PRIVATE)
        .getString(KEY_DEFAULT, "default_channel") ?: "default_channel"

    fun readAll(): List<ChannelDetails> {
        val prefs = context.getSharedPreferences(PREF, Context.MODE_PRIVATE)
        val raw = prefs.getString(KEY_CHANNELS_JSON, null) ?: return emptyList()
        val type = object : TypeToken<List<ChannelDetails>>() {}.type
        return gson.fromJson(raw, type)
    }

}