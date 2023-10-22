package ru.webim.webim

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import ru.webim.android.sdk.Webim
import ru.webim.android.sdk.WebimSession
import ru.webim.android.sdk.MessageStream
import ru.webim.android.sdk.MessageTracker

/** WebimPlugin */
class WebimPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private var session: WebimSession? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "webim")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "webimSession") {
      webimSession(call, result)
    } else if (call.method == "getSession") {
      getSession(call, result)
    } else if (call.method == "getMessagesHistory") {
      getMessagesHistory(call, result)
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun webimSession(@NonNull call: MethodCall, @NonNull result: Result) {
    val accountName = call.argument<String?>("ACCOUNT_NAME") as String
    val location = call.argument<String?>("LOCATION_NAME") as String
    val visitor = call.argument<String?>("VISITOR") as String

    session = Webim.newSessionBuilder()
            .setContext(context)
            .setAccountName(accountName)
            .setLocation(location)
            .setVisitorFieldsJson(visitor)
            .build()

    result.success(session.toString())
  }

  private fun getSession(@NonNull call: MethodCall, @NonNull result: Result) {
    result.success(session.toString())
  }

  private fun getMessagesHistory(@NonNull call: MethodCall, @NonNull result: Result) {
//    session.resume();
//    val tracker: MessageTracker = session.getStream.newMessageTracker(this)
//    val MESSAGES_PER_REQUEST = 25
//    val history = tracker.getLastMessages(MESSAGES_PER_REQUEST, object : GetMessagesCallback() {
//
//    })
//
//    result.success(history)
  }
}
