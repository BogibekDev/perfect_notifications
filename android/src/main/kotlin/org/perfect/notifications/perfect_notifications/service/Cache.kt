package org.perfect.notifications.perfect_notifications.service

import android.content.Context
import android.util.Log
import androidx.core.content.edit
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import org.perfect.notifications.perfect_notifications.enum.LanguageEnum
import org.perfect.notifications.perfect_notifications.models.ChannelDetails

class CacheManager(private val context: Context) {

    companion object {
        private const val KEY_DEFAULT = "default_channel_id"
        private const val PREF = "perfect_notifications_prefs"
        private const val KEY_CHANNELS_JSON = "channels_json"
        private const val KEY_LOCALE = "locale"

        private const val KEY_SOUND_ENABLE = "sound_enable"
    }

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

    fun saveLocale(locale: String) {
        val prefs = context.getSharedPreferences(PREF, Context.MODE_PRIVATE)
        prefs.edit { putString(KEY_LOCALE, locale) }
    }

    fun changeSoundEnable(enable: Boolean) {
        val prefs = context.getSharedPreferences(PREF, Context.MODE_PRIVATE)
        prefs.edit { putBoolean(KEY_SOUND_ENABLE, enable) }
        Log.d("Cache Manager", "changeSoundEnable: $enable")
    }

    fun getLocale(): String {
        val prefs = context.getSharedPreferences(PREF, Context.MODE_PRIVATE)
        return prefs.getString(KEY_LOCALE, LanguageEnum.UzbekLatin.locale)
            ?: LanguageEnum.UzbekLatin.locale
    }

    fun getSoundEnable(): Boolean {
        val prefs = context.getSharedPreferences(PREF, Context.MODE_PRIVATE)
        return prefs.getBoolean(KEY_SOUND_ENABLE, false)
    }

}