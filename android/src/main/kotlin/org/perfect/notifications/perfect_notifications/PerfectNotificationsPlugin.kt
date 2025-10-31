package org.perfect.notifications.perfect_notifications

import android.app.Activity
import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import org.perfect.notifications.perfect_notifications.enum.Methods
import org.perfect.notifications.perfect_notifications.models.ChannelDetails
import org.perfect.notifications.perfect_notifications.models.NotificationDetails
import org.perfect.notifications.perfect_notifications.service.CacheManager
import org.perfect.notifications.perfect_notifications.service.NotificationReceiver
import org.perfect.notifications.perfect_notifications.service.NotificationService
import org.perfect.notifications.perfect_notifications.utils.ArgumentParser
import org.perfect.notifications.perfect_notifications.utils.IntentProvider
import org.perfect.notifications.perfect_notifications.utils.PermissionHelper

class PerfectNotificationsPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    PluginRegistry.NewIntentListener {

    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var context: Context
    private var activity: Activity? = null
    private lateinit var service: NotificationService
    private lateinit var intentProvider: IntentProvider
    private val parser = ArgumentParser()

    private var eventSink: EventChannel.EventSink? = null
    private var pendingNotificationData: Map<String, Any?>? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        service = NotificationService(context)
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "perfect_notifications")
        channel.setMethodCallHandler(this)
        eventChannel = EventChannel(
            flutterPluginBinding.binaryMessenger,
            "perfect_notifications/notification_click"
        )
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
                // Agar pending data bo'lsa, yuborish
                NotificationReceiver.onNotificationClick = { data ->
                    android.util.Log.d("PerfectNotifications", "Sending to Flutter: $data")
                    events?.success(data)
                }

                // Pending data bormi tekshirish
                pendingNotificationData?.let {
                    android.util.Log.d("PerfectNotifications", "Sending pending data: $it")
                    events?.success(it)
                    pendingNotificationData = null
                }
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
                NotificationReceiver.onNotificationClick = null
            }
        })

        intentProvider = IntentProvider(context)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            Methods.INITIALIZE -> result.success(true)
            Methods.SAVE_LANGUAGE -> saveLanguage(call, result)

            Methods.GET_PLATFORM_VERSION -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            Methods.INIT_OPTIONS -> initOptions(result)

            Methods.CREATE_CHANNEL -> createChannel(call, result)
            Methods.DELETE_CHANNEL -> deleteChannel(call, result)
            Methods.CHANNEL_EXISTS -> channelExists(call, result)
            Methods.GET_ALL_CHANNELS -> getAllChannels(result)

            Methods.SHOW_NOTIFICATION -> showNotification(call, result)
            Methods.CANCEL_NOTIFICATION -> cancelNotification(call, result)
            Methods.CANCEL_ALL -> cancelAll(result)

            else -> result.notImplemented()

        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    private fun initOptions(result: Result) {
        //TODO
        result.success(true)
    }

    private fun saveLanguage(call: MethodCall, result: MethodChannel.Result) {
        try {
            val locale = call.argument<String>("locale") ?: run {
                result.error("INVALID_ARGUMENTS", "locale is required", null)
                return
            }
            val cache = CacheManager(context)
            cache.saveLocale(locale)
            result.success(true)

        } catch (e: Exception) {
            e.printStackTrace()
            result.error("CREATE_CHANNEL_ERROR", e.message, null)
        }
    }

    private fun createChannel(call: MethodCall, result: Result) {
        when (val pr = parser.parse(call) { map -> ChannelDetails.fromMap(map) }) {
            is ArgumentParser.ParseResult.Success -> {
                val data = pr.data
                try {
                    val cache = CacheManager(context)
                    val all = cache.readAll().toMutableList().apply {
                        removeAll { it.id == data.id }
                        add(data)
                    }
                    cache.saveChannels(cache.readDefault(), all)
                    service.createNotificationChannel(data)
                    result.success(true)
                } catch (e: Exception) {
                    e.printStackTrace()
                    result.error("CREATE_CHANNEL_ERROR", e.message, null)
                }
            }

            is ArgumentParser.ParseResult.Error -> {
                result.error(pr.code, pr.message, pr.details)
            }
        }
    }

    private fun deleteChannel(call: MethodCall, result: Result) {
        val id = call.argument<String>("channelId") ?: run {
            result.error("INVALID_ARGUMENTS", "channelId is required", null)
            return
        }
        try {
            service.deleteNotificationChannel(id)
            val cache = CacheManager(context)
            val all = cache.readAll().filterNot { it.id == id }
            cache.saveChannels(cache.readDefault(), all)
            result.success(true)
        } catch (e: Exception) {
            result.error("DELETE_CHANNEL_ERROR", e.message, null)
        }
    }

    private fun showNotification(call: MethodCall, result: Result) {
        if (!PermissionHelper.hasPermission(context)) {
            result.error("PERMISSION_DENIED", "POST_NOTIFICATIONS not granted", null)
            return
        }

        when (val pr = parser.parse(call) { map -> NotificationDetails.fromMap(map) }) {
            is ArgumentParser.ParseResult.Success -> {
                val data = pr.data
                try {
                    intentProvider.setActivity(activity)
                    val launchIntent = intentProvider.getLaunchIntent()
                    if (launchIntent == null) {
                        result.error("LAUNCH_INTENT_ERROR", "Could not resolve launch intent", null)
                        return
                    }
                    service.showNotification(launchIntent, data)
                    result.success(true)
                } catch (e: Exception) {
                    e.printStackTrace()
                    result.error("SHOW_NOTIFICATION_ERROR", e.message, null)
                }
            }

            is ArgumentParser.ParseResult.Error -> {
                result.error(pr.code, pr.message, pr.details)
            }
        }
    }

    private fun cancelNotification(call: MethodCall, result: Result) {
        val id = call.argument<Int>("id") ?: 0
        service.cancel(id)
        result.success(true)
    }

    private fun cancelAll(result: Result) {
        service.cancelAll()
        result.success(true)
    }


    private fun getAllChannels(result: MethodChannel.Result) {
        result.success(service.getAllChannels())
    }


    private fun channelExists(call: MethodCall, result: MethodChannel.Result) {
        val id = call.argument<String>("channelId") ?: run {
            result.error("INVALID_ARGUMENTS", "channelId is required", null)
            return
        }
        val exists = service.channelExists(id)
        result.success(exists)
    }

    private fun handleIntent(intent: Intent?) {
        if (intent?.getBooleanExtra("fromPush", false) == true) {
            val data = intent.getStringExtra("data")
            val payload = mapOf(
                "data" to data,
                "fromPush" to true,
                "timestamp" to System.currentTimeMillis()
            )

            val sink = eventSink
            if (sink != null) {
                sink.success(payload)
            } else {
                pendingNotificationData = payload
            }
        }
    }

    override fun onNewIntent(intent: Intent): Boolean {
        handleIntent(intent)
        return false
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        intentProvider.setActivity(activity)
        binding.addOnNewIntentListener(this)
        handleIntent(binding.activity.intent)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null

        intentProvider.setActivity(null)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        intentProvider.setActivity(activity)
        binding.addOnNewIntentListener(this)
        handleIntent(binding.activity.intent)
    }

    override fun onDetachedFromActivity() {
        activity = null
        intentProvider.setActivity(null)
    }

}
