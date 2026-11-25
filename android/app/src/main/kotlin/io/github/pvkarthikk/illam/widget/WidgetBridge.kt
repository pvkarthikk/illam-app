package io.github.pvkarthikk.illam.widget

import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.github.pvkarthikk.illam.MainActivity
import java.util.Collections
import java.util.IdentityHashMap

object WidgetBridge {
    const val CHANNEL = "io.github.pvkarthikk.illam/widgets"
    const val EXTRA_WIDGET_ROUTE = "illam_widget_route"

    private val mainHandler = Handler(Looper.getMainLooper())

    @Volatile
    private var foregroundChannel: MethodChannel? = null

    private val headlessChannels: MutableMap<FlutterEngine, MethodChannel> =
        Collections.synchronizedMap(IdentityHashMap())

    @Volatile
    private var pendingInitialRoute: String? = null

    fun attachForeground(context: Context, engine: FlutterEngine) {
        val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
        registerHandler(context.applicationContext, channel, onDone = null)
        foregroundChannel = channel
    }

    fun detachForeground() {
        foregroundChannel?.setMethodCallHandler(null)
        foregroundChannel = null
    }

    fun attachHeadless(context: Context, engine: FlutterEngine, onDone: () -> Unit) {
        val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
        registerHandler(context.applicationContext, channel, onDone = onDone)
        headlessChannels[engine] = channel
    }

    fun detachHeadless(engine: FlutterEngine) {
        headlessChannels.remove(engine)?.setMethodCallHandler(null)
    }

    private fun registerHandler(
        appContext: Context,
        channel: MethodChannel,
        onDone: (() -> Unit)?,
    ) {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "updateSnapshots" -> {
                    val staffJson = call.argument<String>("staffJson")
                    val todosJson = call.argument<String>("todosJson")
                    WidgetStore.saveSnapshots(appContext, staffJson, todosJson)
                    refreshAllWidgets(appContext)
                    result.success(null)
                }

                "takePendingActions" -> {
                    result.success(WidgetStore.peekPendingActions(appContext))
                }

                "ackPendingActions" -> {
                    @Suppress("UNCHECKED_CAST")
                    val ids = call.argument<List<String>>("ids") ?: emptyList()
                    WidgetStore.ackPendingActions(appContext, ids)
                    result.success(null)
                }

                "consumeInitialRoute" -> {
                    val route = pendingInitialRoute
                    pendingInitialRoute = null
                    result.success(route)
                }

                "backgroundDone" -> {
                    result.success(null)
                    onDone?.invoke()
                }

                else -> result.notImplemented()
            }
        }
    }

    fun onLaunchOrNewIntent(intent: Intent?) {
        val route = intent?.getStringExtra(EXTRA_WIDGET_ROUTE) ?: return
        intent.removeExtra(EXTRA_WIDGET_ROUTE)
        if (route.isEmpty()) return
        val ch = foregroundChannel
        if (ch != null) {
            mainHandler.post {
                val active = foregroundChannel
                if (active != null) {
                    active.invokeMethod("openRoute", route)
                } else {
                    pendingInitialRoute = route
                }
            }
        } else {
            pendingInitialRoute = route
        }
    }

    fun openRoute(context: Context, route: String) {
        val launch = Intent(context, MainActivity::class.java).apply {
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP,
            )
            putExtra(EXTRA_WIDGET_ROUTE, route)
        }
        context.startActivity(launch)
    }

    fun dispatchAction(
        context: Context,
        action: Map<String, Any?>,
        pendingResult: android.content.BroadcastReceiver.PendingResult?,
    ) {
        val appContext = context.applicationContext
        WidgetStore.applyOptimisticAction(appContext, action)
        refreshAllWidgets(appContext)

        mainHandler.post {
            val ch = foregroundChannel
            if (ch != null) {
                ch.invokeMethod(
                    "performAction",
                    action,
                    object : MethodChannel.Result {
                        override fun success(result: Any?) {
                            pendingResult?.finish()
                        }

                        override fun error(code: String, message: String?, details: Any?) {
                            WidgetStore.enqueueAction(appContext, action)
                            WidgetBackgroundRunner.drain(appContext, pendingResult)
                        }

                        override fun notImplemented() {
                            WidgetStore.enqueueAction(appContext, action)
                            WidgetBackgroundRunner.drain(appContext, pendingResult)
                        }
                    },
                )
            } else {
                WidgetStore.enqueueAction(appContext, action)
                WidgetBackgroundRunner.drain(appContext, pendingResult)
            }
        }
    }

    fun hasForegroundEngine(): Boolean = foregroundChannel != null

    fun refreshAllWidgets(context: Context) {
        val appContext = context.applicationContext
        StaffWidgetProvider.updateAll(appContext)
        TodayTodoWidgetProvider.updateAll(appContext)
    }
}
