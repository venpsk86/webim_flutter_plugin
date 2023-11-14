package ru.webim.webim

import android.content.Context
import androidx.annotation.NonNull
import org.json.JSONArray
import org.json.JSONObject
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
import ru.webim.android.sdk.MessageStream.OperatorTypingListener

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

  private lateinit var listener: MessageListener
  private lateinit var tracker: MessageTracker
  var visitorName: String? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    EventChannel(flutterPluginBinding.binaryMessenger, "events").setStreamHandler(object : EventChannel.StreamHandler {
      override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
        attachEvent = eventSink
      }
      override fun onCancel(arguments: Any?) {
        attachEvent = null
      }
    })
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
    } else if (call.method == "getUnreadMessagesCount") {
      getUnreadMessagesCount(call, result)
    } else if (call.method == "sendMessage") {
      sendMessage(call, result)
    } else if (call.method == "getCurrentOperator") {
      getCurrentOperator(call, result)
    } else if (call.method == "getLastMessages") {
      getLastMessages(call, result)
    }  else if (call.method == "getNextMessages") {
      getNextMessages(call, result)
    }   else if (call.method == "setVisitorTyping") {
      setVisitorTyping(call, result)
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

    tracker = session?.getStream()!!.newMessageTracker(MessageListenerDefault(attachEvent))

    session?.getStream()?.setOperatorTypingListener(object : OperatorTypingListener {
      override fun onOperatorTypingStateChanged(isTyping : Boolean) {
        attachEvent!!.success("""
          {
            "event_type":"TYPING_OP",
            "value":"${isTyping}"
          }
        """.trimIndent());
      }
    })

    visitorName = JSONObject(visitor.substring(visitor.indexOf("{"), visitor.lastIndexOf("}") + 1))
                  .getJSONObject("fields")
                  .getString("display_name")

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

    result.success("""
      {
        "success":"true",
        "id":"${messageId}"
      }
    """.trimIndent())
  }

  private fun getCurrentOperator(@NonNull call: MethodCall, @NonNull result: Result) {
    session?.resume();
    val currentOperator = session?.getStream()?.getCurrentOperator()
    val jsonArray = JSONArray()
    val rootObject= JSONObject()
    rootObject.put("id", currentOperator?.getId())
    rootObject.put("name", currentOperator?.getName())
    rootObject.put("avatarUrl", currentOperator?.getAvatarUrl())

    result.success(rootObject.toString())
  }

  private fun getLastMessages(@NonNull call: MethodCall, @NonNull result: Result) {
    session?.resume();

    val getMessagesCallback = object : MessageTracker.GetMessagesCallback {
      override fun receive(messages: List<Message>) {
        val jsonArray = JSONArray()
        for (message in messages) {
          val rootObject= JSONObject()
          rootObject.put("id", message.clientSideId)
          rootObject.put("text", message.getText())
          rootObject.put("type", message.getType())
          rootObject.put("avatarUrl", message.getSenderAvatarUrl())
          rootObject.put("sendStatus", message.getSendStatus())
          rootObject.put("senderName", message.getSenderName())
          rootObject.put("operatorId", message.operatorId)
          rootObject.put("time", message.getTime())
          rootObject.put("isEdited", message.isEdited())
          jsonArray.put(rootObject)
        }

        result.success(jsonArray.toString())
      }
    }

    val MESSAGES_PER_REQUEST = 25
    tracker.getLastMessages(MESSAGES_PER_REQUEST, getMessagesCallback)
  }

  private fun getNextMessages(@NonNull call: MethodCall, @NonNull result: Result) {
    session?.resume();

    val getMessagesCallback = object : MessageTracker.GetMessagesCallback {
      override fun receive(messages: List<Message>) {
        val jsonArray = JSONArray()
        for (message in messages) {
          val rootObject= JSONObject()
          rootObject.put("id", message.clientSideId)
          rootObject.put("text", message.getText())
          rootObject.put("type", message.getType())
          rootObject.put("avatarUrl", message.getSenderAvatarUrl())
          rootObject.put("sendStatus", message.getSendStatus())
          rootObject.put("senderName", message.getSenderName())
          rootObject.put("operatorId", message.operatorId)
          rootObject.put("time", message.getTime())
          rootObject.put("isEdited", message.isEdited())
          jsonArray.put(rootObject)
        }
        result.success(jsonArray.toString())
      }
    }

    val MESSAGES_PER_REQUEST = 25
    tracker.getNextMessages(MESSAGES_PER_REQUEST, getMessagesCallback)
  }

  private fun setVisitorTyping(@NonNull call: MethodCall, @NonNull result: Result) {
    session?.resume();
    var draftMessage = call.argument<String?>("MESSAGE")

    if (draftMessage != null) draftMessage = visitorName
    session?.getStream()?.setVisitorTyping(draftMessage)
  }
}

class MessageListenerDefault (attachEvent: EventChannel.EventSink?) : MessageListener {
  val attachEvent = attachEvent
  override fun messageAdded(before: Message?, message: Message) {
    attachEvent?.success(message.getText()!!);
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
