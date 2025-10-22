package org.perfect.notifications.perfect_notifications.utils

import io.flutter.plugin.common.MethodChannel.Result


class ResultHandler {

    fun success(result: Result, data: Any? = null) {
        result.success(data)
    }

    fun error(result: Result, code: String, message: String, details: Any? = null) {
        result.error(code, message, details)
    }

    fun notImplemented(result: Result) {
        result.notImplemented()
    }
}