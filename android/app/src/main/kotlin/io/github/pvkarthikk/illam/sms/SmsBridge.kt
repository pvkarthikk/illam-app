package io.github.pvkarthikk.illam.sms

import android.Manifest
import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.provider.Telephony
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.RejectedExecutionException

object SmsBridge {
    private const val CHANNEL = "io.github.pvkarthikk.illam/sms"
    private const val REQ_SMS_PERMISSIONS = 44102

    private val mainHandler = Handler(Looper.getMainLooper())
    private var executor: ExecutorService? = null
    private var channel: MethodChannel? = null
    private var activityRef: WeakReference<Activity>? = null
    private var pendingPermResult: MethodChannel.Result? = null

    fun attach(activity: Activity, flutterEngine: FlutterEngine) {
        activityRef = WeakReference(activity)
        val appContext = activity.applicationContext
        val exec = executor ?: Executors.newSingleThreadExecutor().also { executor = it }
        channel?.setMethodCallHandler(null)
        val mc = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        mc.setMethodCallHandler { call, result ->
            when (call.method) {
                "checkPermissions" -> {
                    result.success(buildPermissionMap(appContext, activityRef?.get()))
                }

                "requestPermissions" -> {
                    handleRequestPermissions(appContext, result)
                }

                "openAppSettings" -> {
                    openAppDetailsSettings(appContext)
                    result.success(null)
                }

                "setBackgroundCaptureEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    setReceiverEnabled(appContext, enabled)
                    result.success(null)
                }

                "readInbox" -> {
                    val sinceMs = (call.argument<Number>("sinceMs"))?.toLong() ?: 0L
                    val limit = (call.argument<Number>("limit"))?.toInt() ?: 400
                    try {
                        exec.execute {
                            val list = readInboxSafely(appContext, sinceMs, limit)
                            mainHandler.post { result.success(list) }
                        }
                    } catch (_: RejectedExecutionException) {
                        result.success(emptyList<Map<String, Any>>())
                    }
                }

                "drainQueuedMessages" -> {
                    try {
                        exec.execute {
                            val list = SmsQueueStore.drainQueue(appContext)
                            mainHandler.post { result.success(list) }
                        }
                    } catch (_: RejectedExecutionException) {
                        result.success(emptyList<Map<String, Any>>())
                    }
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
        pendingPermResult = null
        executor?.shutdownNow()
        executor = null
    }

    fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ): Boolean {
        if (requestCode != REQ_SMS_PERMISSIONS) return false
        val activity = activityRef?.get()
        val pending = pendingPermResult
        pendingPermResult = null
        if (pending != null) {
            val ctx = activity?.applicationContext
            if (ctx != null) {
                val map = buildPermissionMap(ctx, activity)
                if ((map["readGranted"] as? Boolean) == true &&
                    (map["receiveGranted"] as? Boolean) == true &&
                    SmsQueueStore.isCaptureEnabled(ctx)
                ) {
                    setReceiverEnabled(ctx, true)
                }
                pending.success(map)
            } else {
                pending.success(
                    mapOf(
                        "supported" to true,
                        "readGranted" to false,
                        "receiveGranted" to false,
                        "permanentlyDenied" to false,
                    ),
                )
            }
        }
        return true
    }

    fun notifyForegroundIncoming(sender: String, body: String, receivedAtMs: Long) {
        val ch = channel ?: return
        mainHandler.post {
            ch.invokeMethod(
                "onIncomingSms",
                mapOf(
                    "sender" to sender,
                    "body" to body,
                    "receivedAtMs" to receivedAtMs,
                ),
            )
        }
    }

    private fun handleRequestPermissions(appContext: Context, result: MethodChannel.Result) {
        val activity = activityRef?.get()
        if (activity == null) {
            result.success(buildPermissionMap(appContext, null))
            return
        }
        val current = buildPermissionMap(appContext, activity)
        if ((current["readGranted"] as? Boolean) == true &&
            (current["receiveGranted"] as? Boolean) == true
        ) {
            result.success(current)
            return
        }
        pendingPermResult?.success(current)
        pendingPermResult = result
        SmsQueueStore.markRequestedPermission(appContext)
        ActivityCompat.requestPermissions(
            activity,
            arrayOf(Manifest.permission.READ_SMS, Manifest.permission.RECEIVE_SMS),
            REQ_SMS_PERMISSIONS,
        )
    }

    private fun buildPermissionMap(appContext: Context, activity: Activity?): Map<String, Any> {
        val readGranted = ContextCompat.checkSelfPermission(
            appContext,
            Manifest.permission.READ_SMS,
        ) == PackageManager.PERMISSION_GRANTED
        val receiveGranted = ContextCompat.checkSelfPermission(
            appContext,
            Manifest.permission.RECEIVE_SMS,
        ) == PackageManager.PERMISSION_GRANTED
        val askedBefore = SmsQueueStore.hasRequestedPermission(appContext)
        val permanentlyDenied = if (!readGranted && askedBefore && activity != null) {
            !ActivityCompat.shouldShowRequestPermissionRationale(
                activity,
                Manifest.permission.READ_SMS,
            )
        } else {
            false
        }
        return mapOf(
            "supported" to true,
            "readGranted" to readGranted,
            "receiveGranted" to receiveGranted,
            "permanentlyDenied" to permanentlyDenied,
        )
    }

    private fun setReceiverEnabled(appContext: Context, enabled: Boolean) {
        SmsQueueStore.setCaptureEnabled(appContext, enabled)
        val receiveGranted = ContextCompat.checkSelfPermission(
            appContext,
            Manifest.permission.RECEIVE_SMS,
        ) == PackageManager.PERMISSION_GRANTED
        val state = if (enabled && receiveGranted) {
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED
        } else {
            PackageManager.COMPONENT_ENABLED_STATE_DISABLED
        }
        appContext.packageManager.setComponentEnabledSetting(
            ComponentName(appContext, SmsReceiver::class.java),
            state,
            PackageManager.DONT_KILL_APP,
        )
    }

    private fun openAppDetailsSettings(appContext: Context) {
        val intent = Intent(
            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
            Uri.fromParts("package", appContext.packageName, null),
        ).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        appContext.startActivity(intent)
    }

    private fun readInboxSafely(
        appContext: Context,
        sinceMs: Long,
        limit: Int,
    ): List<Map<String, Any>> {
        if (ContextCompat.checkSelfPermission(
                appContext,
                Manifest.permission.READ_SMS,
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return emptyList()
        }

        val out = ArrayList<Map<String, Any>>()
        val projection = arrayOf(
            Telephony.Sms._ID,
            Telephony.Sms.ADDRESS,
            Telephony.Sms.BODY,
            Telephony.Sms.DATE,
        )
        val selection = "${Telephony.Sms.DATE} >= ?"
        val args = arrayOf(sinceMs.toString())
        val sortOrder = "${Telephony.Sms.DATE} DESC"

        try {
            appContext.contentResolver.query(
                Telephony.Sms.Inbox.CONTENT_URI,
                projection,
                selection,
                args,
                sortOrder,
            )?.use { cursor ->
                val idIdx = cursor.getColumnIndexOrThrow(Telephony.Sms._ID)
                val addrIdx = cursor.getColumnIndexOrThrow(Telephony.Sms.ADDRESS)
                val bodyIdx = cursor.getColumnIndexOrThrow(Telephony.Sms.BODY)
                val dateIdx = cursor.getColumnIndexOrThrow(Telephony.Sms.DATE)
                while (cursor.moveToNext() && out.size < limit) {
                    val sender = cursor.getString(addrIdx)?.trim().orEmpty()
                    val body = cursor.getString(bodyIdx)?.trim().orEmpty()
                    if (!SmsQueueStore.looksLikeSpendSms(sender, body)) continue
                    out.add(
                        mapOf(
                            "id" to (cursor.getString(idIdx) ?: ""),
                            "sender" to sender,
                            "body" to body,
                            "receivedAtMs" to cursor.getLong(dateIdx),
                        ),
                    )
                }
            }
        } catch (_: Throwable) {
            return emptyList()
        }
        return out
    }
}
