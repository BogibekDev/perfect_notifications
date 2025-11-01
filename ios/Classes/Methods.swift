//
// Created by Bog'ibek on 22/10/25.
//

import Foundation

enum Methods {
    // Platform
    static let INITIALIZE = "initialize"
    static let GET_PLATFORM_VERSION = "getPlatformVersion"
    static let INIT_OPTIONS         = "init_options"
    static let SAVE_LANGUAGE        = "save_language"
    static let CHANGE_SOUND_ENABLE  = "change_sound_enable"

    // Channels
    static let CREATE_CHANNEL       = "create_channel"
    static let DELETE_CHANNEL       = "delete_channel"
    static let CHANNEL_EXISTS       = "channel_exists"
    static let GET_ALL_CHANNELS     = "get_all_channels"

    // Notifications
    static let SHOW_NOTIFICATION    = "show_notification"
    static let CANCEL_NOTIFICATION  = "cancel_notification"
    static let CANCEL_ALL           = "cancel_all_notifications"
}
