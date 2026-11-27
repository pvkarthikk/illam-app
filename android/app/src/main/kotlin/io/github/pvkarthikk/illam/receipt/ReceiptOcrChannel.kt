package io.github.pvkarthikk.illam.receipt

import android.Manifest
import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import com.googlecode.tesseract.android.TessBaseAPI
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.lang.ref.WeakReference
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.RejectedExecutionException

/**
 * Native Android bridge for offline receipt capture and Tesseract OCR extraction.
 */
object ReceiptOcrChannel {
    private const val CHANNEL = "io.github.pvkarthikk.illam/receipt_ocr"
    private const val REQ_CAMERA_PERMISSION = 44201
    private const val REQ_CAPTURE_IMAGE = 44202
    private const val REQ_PICK_IMAGE = 44203

    private const val SCAN_DIR = "receipt_scans"
    private const val TESSDATA_DIR = "tessdata"
    private const val TRAINEDDATA_NAME = "eng.traineddata"
    private const val MAX_PICKED_BYTES = 25 * 1024 * 1024

    private val mainHandler = Handler(Looper.getMainLooper())
    private val tessLock = Any()

    private var executor: ExecutorService? = null
    private var channel: MethodChannel? = null
    private var activityRef: WeakReference<Activity>? = null
    private var tessApi: TessBaseAPI? = null

    private var pendingPickResult: MethodChannel.Result? = null
    private var pendingCaptureFile: File? = null
    private var waitingCameraPermission = false

    fun attach(activity: Activity, flutterEngine: FlutterEngine) {
        activityRef = WeakReference(activity)
        val appContext = activity.applicationContext
        val exec = executor ?: Executors.newSingleThreadExecutor().also { executor = it }
        channel?.setMethodCallHandler(null)
        val mc = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        mc.setMethodCallHandler { call, result ->
            when (call.method) {
                "isSupported" -> result.success(true)

                "pickOrCaptureImage" -> {
                    val source = call.argument<String>("source") ?: "camera"
                    handlePickOrCapture(source, result)
                }

                "recognizeImage" -> {
                    val path = call.argument<String>("path")
                    val rotation = (call.argument<Number>("rotationDegrees"))?.toInt() ?: 0
                    if (path.isNullOrBlank()) {
                        result.error("invalid_args", "Missing image path", null)
                        return@setMethodCallHandler
                    }
                    try {
                        exec.execute {
                            val output = recognizeSafely(appContext, path, rotation)
                            mainHandler.post { result.success(output) }
                        }
                    } catch (_: RejectedExecutionException) {
                        result.error("failed", "OCR executor unavailable", null)
                    }
                }

                "deleteTempImage" -> {
                    val path = call.argument<String>("path")
                    if (!path.isNullOrBlank()) {
                        deleteAllowedFile(appContext, path)
                    }
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
        channel = mc
    }

    fun detach() {
        channel?.setMethodCallHandler(null)
        channel = null
        activityRef = null
        pendingPickResult = null
        pendingCaptureFile = null
        waitingCameraPermission = false
        executor?.shutdownNow()
        executor = null
        synchronized(tessLock) {
            tessApi?.recycle()
            tessApi = null
        }
    }

    private fun handlePickOrCapture(source: String, result: MethodChannel.Result) {
        val activity = activityRef?.get()
        if (activity == null) {
            result.error("failed", "Activity unavailable", null)
            return
        }
        if (pendingPickResult != null) {
            result.error("busy", "Another image picker operation is in progress", null)
            return
        }

        if (source == "gallery") {
            launchGalleryPicker(activity, result)
            return
        }

        val granted = ContextCompat.checkSelfPermission(
            activity,
            Manifest.permission.CAMERA,
        ) == PackageManager.PERMISSION_GRANTED
        if (!granted) {
            pendingPickResult = result
            waitingCameraPermission = true
            ActivityCompat.requestPermissions(
                activity,
                arrayOf(Manifest.permission.CAMERA),
                REQ_CAMERA_PERMISSION,
            )
            return
        }
        launchCameraCapture(activity, result)
    }

    private fun launchCameraCapture(activity: Activity, result: MethodChannel.Result) {
        val appContext = activity.applicationContext
        val dir = scanCacheDir(appContext).apply { mkdirs() }
        val target = File(dir, "scan_${System.currentTimeMillis()}.jpg")
        val authority = "${activity.packageName}.receipt_fileprovider"
        val uri = try {
            FileProvider.getUriForFile(activity, authority, target)
        } catch (t: Throwable) {
            result.error("failed", t.message ?: "FileProvider error", null)
            return
        }

        val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE).apply {
            putExtra(MediaStore.EXTRA_OUTPUT, uri)
            addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION or Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        if (intent.resolveActivity(activity.packageManager) == null) {
            target.delete()
            result.error("no_camera_app", "No camera app available", null)
            return
        }

        pendingCaptureFile = target
        pendingPickResult = result
        try {
            @Suppress("DEPRECATION")
            activity.startActivityForResult(intent, REQ_CAPTURE_IMAGE)
        } catch (_: ActivityNotFoundException) {
            pendingCaptureFile = null
            pendingPickResult = null
            target.delete()
            result.error("no_camera_app", "No camera app available", null)
        } catch (t: Throwable) {
            pendingCaptureFile = null
            pendingPickResult = null
            target.delete()
            result.error("failed", t.message ?: "Could not open camera", null)
        }
    }

    private fun launchGalleryPicker(activity: Activity, result: MethodChannel.Result) {
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "image/*"
        }
        pendingPickResult = result
        try {
            @Suppress("DEPRECATION")
            activity.startActivityForResult(intent, REQ_PICK_IMAGE)
        } catch (t: Throwable) {
            pendingPickResult = null
            result.error("failed", t.message ?: "Could not open gallery", null)
        }
    }

    fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ): Boolean {
        if (requestCode != REQ_CAMERA_PERMISSION || !waitingCameraPermission) {
            return false
        }
        waitingCameraPermission = false
        val pending = pendingPickResult
        pendingPickResult = null
        if (pending == null) return true

        val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
        if (!granted) {
            pending.error("permission_denied", "Camera permission denied", null)
            return true
        }
        val activity = activityRef?.get()
        if (activity == null) {
            pending.error("failed", "Activity unavailable", null)
            return true
        }
        launchCameraCapture(activity, pending)
        return true
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQ_CAPTURE_IMAGE && requestCode != REQ_PICK_IMAGE) {
            return false
        }
        val pending = pendingPickResult
        val captureFile = pendingCaptureFile
        pendingPickResult = null
        pendingCaptureFile = null
        if (pending == null) return true

        if (requestCode == REQ_CAPTURE_IMAGE) {
            if (resultCode == Activity.RESULT_OK && captureFile != null && captureFile.length() > 0L) {
                pending.success(captureFile.absolutePath)
            } else {
                captureFile?.delete()
                pending.success(null)
            }
            return true
        }

        // Gallery pick
        val uri: Uri? = if (resultCode == Activity.RESULT_OK) data?.data else null
        if (uri == null) {
            pending.success(null)
            return true
        }
        val appContext = activityRef?.get()?.applicationContext
        val exec = executor
        if (appContext == null || exec == null) {
            pending.error("failed", "OCR channel not attached", null)
            return true
        }
        try {
            exec.execute {
                val copied = copyUriToCacheSafely(appContext, uri)
                mainHandler.post {
                    if (copied != null) {
                        pending.success(copied.absolutePath)
                    } else {
                        pending.error("failed", "Could not read selected image", null)
                    }
                }
            }
        } catch (_: RejectedExecutionException) {
            pending.error("failed", "OCR executor unavailable", null)
        }
        return true
    }

    private fun copyUriToCacheSafely(appContext: Context, uri: Uri): File? {
        val dir = scanCacheDir(appContext).apply { mkdirs() }
        val target = File(dir, "pick_${System.currentTimeMillis()}.jpg")
        return try {
            appContext.contentResolver.openInputStream(uri)?.use { input ->
                FileOutputStream(target).use { out ->
                    val buf = ByteArray(16 * 1024)
                    var total = 0
                    while (true) {
                        val read = input.read(buf)
                        if (read <= 0) break
                        total += read
                        if (total > MAX_PICKED_BYTES) {
                            throw IllegalStateException("Image too large")
                        }
                        out.write(buf, 0, read)
                    }
                }
            } ?: return null
            if (target.length() > 0L) target else {
                target.delete()
                null
            }
        } catch (_: Throwable) {
            target.delete()
            null
        }
    }

    private fun recognizeSafely(
        appContext: Context,
        path: String,
        rotationDegrees: Int,
    ): Map<String, Any> {
        if (!isAllowedTempPath(appContext, path)) {
            return mapOf("text" to "", "confidence" to 0)
        }
        val bmp = ReceiptPreprocessor.prepare(path, rotationDegrees)
            ?: return mapOf("text" to "", "confidence" to 0)
        return try {
            synchronized(tessLock) {
                val tess = ensureTessApi(appContext)
                if (tess == null) {
                    return mapOf("text" to "", "confidence" to 0)
                }
                tess.setPageSegMode(TessBaseAPI.PageSegMode.PSM_SINGLE_BLOCK)
                tess.setVariable("preserve_interword_spaces", "1")
                tess.setImage(bmp)
                val text = tess.utF8Text ?: ""
                val confidence = tess.meanConfidence()
                tess.clear()
                mapOf("text" to text, "confidence" to confidence)
            }
        } catch (_: Throwable) {
            mapOf("text" to "", "confidence" to 0)
        } finally {
            bmp.recycle()
        }
    }

    private fun ensureTessApi(appContext: Context): TessBaseAPI? {
        tessApi?.let { return it }
        if (!ensureTrainedData(appContext)) return null
        val api = TessBaseAPI()
        val ok = api.init(appContext.filesDir.absolutePath, "eng")
        if (!ok) {
            api.recycle()
            return null
        }
        tessApi = api
        return api
    }

    private fun ensureTrainedData(appContext: Context): Boolean {
        val dir = File(appContext.filesDir, TESSDATA_DIR).apply { mkdirs() }
        val dest = File(dir, TRAINEDDATA_NAME)
        val assetPath = "$TESSDATA_DIR/$TRAINEDDATA_NAME"
        val expectedSize = try {
            appContext.assets.openFd(assetPath).use { it.length }
        } catch (_: Throwable) {
            -1L
        }
        if (dest.exists() && dest.length() > 0L &&
            (expectedSize < 0L || dest.length() == expectedSize)
        ) {
            return true
        }
        val tmp = File(dir, "$TRAINEDDATA_NAME.tmp")
        return try {
            appContext.assets.open(assetPath).use { input ->
                FileOutputStream(tmp).use { output ->
                    input.copyTo(output)
                }
            }
            if (tmp.length() <= 0L) {
                tmp.delete()
                return false
            }
            if (dest.exists()) dest.delete()
            tmp.renameTo(dest)
        } catch (_: Throwable) {
            tmp.delete()
            false
        }
    }

    private fun scanCacheDir(appContext: Context): File = File(appContext.cacheDir, SCAN_DIR)

    private fun isAllowedTempPath(appContext: Context, path: String): Boolean {
        return try {
            val base = scanCacheDir(appContext).canonicalFile.toPath()
            val candidate = File(path).canonicalFile.toPath()
            candidate.startsWith(base)
        } catch (_: Throwable) {
            false
        }
    }

    private fun deleteAllowedFile(appContext: Context, path: String) {
        if (isAllowedTempPath(appContext, path)) {
            try {
                File(path).delete()
            } catch (_: Throwable) {
            }
        }
    }
}
