package io.github.pvkarthikk.illam

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.tom_roush.pdfbox.android.PDFBoxResourceLoader
import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.text.PDFTextStripper
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.RejectedExecutionException

object PdfTextChannel {
    private const val CHANNEL = "io.github.pvkarthikk.illam/pdf_text"

    @Volatile
    private var initialized = false
    private val initLock = Any()
    private val mainHandler = Handler(Looper.getMainLooper())
    private var executor: ExecutorService? = null
    private var channel: MethodChannel? = null

    fun attach(context: Context, flutterEngine: FlutterEngine) {
        val appContext = context.applicationContext
        val exec = executor ?: Executors.newSingleThreadExecutor().also { executor = it }
        channel?.setMethodCallHandler(null)
        val mc = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        mc.setMethodCallHandler { call, result ->
            if (call.method != "extractText") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val bytes = call.argument<ByteArray>("bytes")
            if (bytes == null || bytes.isEmpty()) {
                result.success("")
                return@setMethodCallHandler
            }
            try {
                exec.execute {
                    val text = extractSafely(appContext, bytes)
                    mainHandler.post { result.success(text) }
                }
            } catch (_: RejectedExecutionException) {
                result.success("")
            }
        }
        channel = mc
    }

    fun detach() {
        channel?.setMethodCallHandler(null)
        channel = null
        executor?.shutdownNow()
        executor = null
    }

    private fun ensureInitialized(appContext: Context) {
        if (initialized) return
        synchronized(initLock) {
            if (!initialized) {
                PDFBoxResourceLoader.init(appContext)
                initialized = true
            }
        }
    }

    private fun extractSafely(appContext: Context, bytes: ByteArray): String {
        return try {
            ensureInitialized(appContext)
            PDDocument.load(bytes).use { doc ->
                val stripper = PDFTextStripper().apply {
                    sortByPosition = true
                }
                stripper.getText(doc)
            }
        } catch (_: Throwable) {
            ""
        }
    }
}
