package org.perfect.notifications.perfect_notifications

import android.app.Activity
import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.perfect.notifications.perfect_notifications.models.ChannelDetails
import org.perfect.notifications.perfect_notifications.models.NotificationDetails
import org.perfect.notifications.perfect_notifications.service.NotificationService

class PerfectNotificationsPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null
    private lateinit var service: NotificationService

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        service = NotificationService(context)
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "perfect_notifications")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {

            Methods.INITIALIZE -> {
                initialize(call, result)
            }


            Methods.SHOW_NOTIFICATION -> {
                showNotification(call, result)
            }

            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }

            else -> result.notImplemented()

        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }


    private fun initialize(call: MethodCall, result: Result) {
        val args = call.arguments
        if (args is Map<*, *>) {
            try {
                // 🔹 Convert to safe Map<String, Any?> manually
                val map = args.entries
                    .filter { it.key is String }
                    .associate { it.key as String to it.value }

                val data = ChannelDetails.fromMap(map)
                service.createNotificationChannel(data)
                result.success(null)
            } catch (e: Exception) {
                e.printStackTrace()
                result.error("INITIALIZE_ERROR", e.message, null)
            }
        } else {
            result.error("INVALID_ARGUMENTS", "Expected Map<String, Any?>", null)
        }

    }


    private fun showNotification(call: MethodCall, result: Result) {
        val args = call.arguments
        if (args is Map<*, *>) {
            try {
                // 🔹 Convert to safe Map<String, Any?> manually
                val map = args.entries
                    .filter { it.key is String }
                    .associate { it.key as String to it.value }

                val data = NotificationDetails.fromMap(map)

                activity?.let {
                    service.showNotification(activity!!.intent, data)
                }
                result.success(null)
            } catch (e: Exception) {
                e.printStackTrace()
                result.error("INITIALIZE_ERROR", e.message, null)
            }
        } else {
            result.error("INVALID_ARGUMENTS", "Expected Map<String, Any?>", null)
        }

    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

}
