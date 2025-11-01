package org.perfect.notifications.perfect_notifications.enum

object Methods {
    const val INITIALIZE   = "initialize"
    const val GET_PLATFORM_VERSION   = "getPlatformVersion"
    const val INIT_OPTIONS           = "init_options"
    const val SAVE_LANGUAGE           = "save_language"

    const val CHANGE_SOUND_ENABLE     = "change_sound_enable"

    // Channels
    const val CREATE_CHANNEL         = "create_channel"
    const val DELETE_CHANNEL         = "delete_channel"
    const val CHANNEL_EXISTS         = "channel_exists"
    const val GET_ALL_CHANNELS       = "get_all_channels"

    // Notifications
    const val SHOW_NOTIFICATION      = "show_notification"
    const val CANCEL_NOTIFICATION    = "cancel_notification"
    const val CANCEL_ALL             = "cancel_all_notifications"

}