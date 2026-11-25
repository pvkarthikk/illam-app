package io.github.pvkarthikk.illam.widget

import android.content.BroadcastReceiver
import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor

object WidgetBackgroundRunner {
    private val mainHandler = Handler(Looper.getMainLooper())
    private var running = false
    private var engine: FlutterEngine? = null
    private val heldResults = mutableListOf<BroadcastReceiver.PendingResult>()
    private var timeoutRunnable: Runnable? = null

    fun drain(context: Context, pendingResult: BroadcastReceiver.PendingResult?) {
        val appContext = context.applicationContext
        mainHandler.post {
            if (pendingResult != null) {
                heldResults.add(pendingResult)
            }
            if (running) return@post
            startEngine(appContext)
        }
    }

    private fun startEngine(appContext: Context) {
        running = true
        val timeout = Runnable { finishEngine(appContext) }
        timeoutRunnable = timeout
        mainHandler.postDelayed(timeout, 9000L)

        try {
            val loader = FlutterInjector.instance().flutterLoader()
            loader.startInitialization(appContext)
            loader.ensureInitializationComplete(appContext, null)

            val newEngine = FlutterEngine(appContext)
            engine = newEngine
            WidgetBridge.attachHeadless(appContext, newEngine) {
                mainHandler.post { finishEngine(appContext) }
            }
            val entrypoint = DartExecutor.DartEntrypoint(
                loader.findAppBundlePath(),
                "widgetBackgroundMain",
            )
            newEngine.dartExecutor.executeDartEntrypoint(entrypoint)
        } catch (_: Exception) {
            finishEngine(appContext)
        }
    }

    private fun finishEngine(appContext: Context) {
        timeoutRunnable?.let { mainHandler.removeCallbacks(it) }
        timeoutRunnable = null

        val currentEngine = engine
        engine = null
        if (currentEngine != null) {
            WidgetBridge.detachHeadless(currentEngine)
            try {
                currentEngine.destroy()
            } catch (_: Exception) {
            }
        }

        val results = ArrayList(heldResults)
        heldResults.clear()
        running = false
        for (r in results) {
            try {
                r.finish()
            } catch (_: Exception) {
            }
        }

        if (WidgetStore.peekPendingActions(appContext).isNotEmpty()) {
            mainHandler.post {
                if (!running) startEngine(appContext)
            }
        }
    }
}
