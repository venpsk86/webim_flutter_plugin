package ru.webim.webim

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import ru.webim.android.sdk.Webim
import ru.webim.android.sdk.WebimSession
import ru.webim.android.sdk.MessageStream
import ru.webim.android.sdk.MessageTracker
import ru.webim.android.sdk.MessageListener
import ru.webim.android.sdk.Message

/** WebimPlugin */
class WebimPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private var session: WebimSession? = null
  private var attachEvent: EventChannel.EventSink? = null

  val eventHandler = object : EventChannel.StreamHandler {

    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
    attachEvent = eventSink
    }
    override fun onCancel(arguments: Any?) {
    attachEvent = null
    }
  }


  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "webim")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
    EventChannel(flutterPluginBinding.binaryMessenger, "events").setStreamHandler(eventHandler)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "webimSession") {
      webimSession(call, result)
    } else if (call.method == "getSession") {
      getSession(call, result)
    } else if (call.method == "getUnreadMessagesCount") {
      getUnreadMessagesCount(call, result)
    } else if (call.method == "sendMessage") {
      sendMessage(call, result)
    } else if (call.method == "getCurrentOperator") {
      getCurrentOperator(call, result)
    }  else if (call.method == "getLastMessages") {
      getLastMessages(call, result)
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

  private fun getUnreadMessagesCount(@NonNull call: MethodCall, @NonNull result: Result) {
    session?.resume();
    val unreadMessagesCount = session?.getStream()?.getUnreadByVisitorMessageCount()

    result.success(unreadMessagesCount.toString())
  }

  private fun sendMessage(@NonNull call: MethodCall, @NonNull result: Result) {
    session?.resume();
    val message = call.argument<String?>("MESSAGE") as String
    val messageId = session?.getStream()?.sendMessage(message)

    result.success(messageId.toString())
  }

  private fun getCurrentOperator(@NonNull call: MethodCall, @NonNull result: Result) {
    session?.resume();
    val currentOperator = session?.getStream()?.getCurrentOperator()

    result.success(currentOperator?.getName().toString())
  }

  private fun getLastMessages(@NonNull call: MethodCall, @NonNull result: Result) {
    session?.resume();

    val listener: MessageListener = MessageListenerDefault(attachEvent)
    val tracker: MessageTracker = session?.getStream()!!.newMessageTracker(listener)
    val getMessagesCallback = object : MessageTracker.GetMessagesCallback {
      override fun receive(messages: List<Message>) {
        for (message in messages) {
          println(message.getText()!!)
        }
      }
    }

    val MESSAGES_PER_REQUEST = 25
    tracker.getLastMessages(MESSAGES_PER_REQUEST, getMessagesCallback)
  }
}

class MessageListenerDefault (attachEvent: EventChannel.EventSink?) : MessageListener {
  val attachEvent = attachEvent
  override fun messageAdded(before: Message?, message: Message) {
    attachEvent!!.success(message.getText()!!);
    println(message.getText())
  }

  override fun messageRemoved(message: Message) {
    // body
  }

  override fun allMessagesRemoved() {
    // body
  }

  override fun messageChanged(from: Message, to: Message) {
    // body
  }
}
