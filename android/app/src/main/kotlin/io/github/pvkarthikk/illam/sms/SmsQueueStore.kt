package io.github.pvkarthikk.illam.sms

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

object SmsQueueStore {
    private const val PREFS_NAME = "illam_sms_queue"
    private const val KEY_CAPTURE_ENABLED = "capture_enabled"
    private const val KEY_ASKED_BEFORE = "asked_before"
    private const val KEY_PENDING = "pending_sms"
    private const val MAX_QUEUE_SIZE = 100

    private val lock = Any()
    private val phoneSenderRegex = Regex("^\\+?\\d{10,15}$")
    private val currencyOrAmountRegex = Regex("(?:₹|rs\\.?|inr|\\bby\\s+\\d)", RegexOption.IGNORE_CASE)
    private val debitCueRegex = Regex(
        "\\b(?:debited|spent|paid|deducted|charged|withdrawn|sent|transferred|autopay|auto-?debit|ecs|nach|purchase|dr\\.)\\b",
        RegexOption.IGNORE_CASE,
    )
    private val otpOnlyRegex = Regex(
        "\\b(?:otp|one[ -]?time password|verification code|security code|do not share|never share)\\b",
        RegexOption.IGNORE_CASE,
    )

    private fun prefs(context: Context) =
        context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun isCaptureEnabled(context: Context): Boolean = synchronized(lock) {
        prefs(context).getBoolean(KEY_CAPTURE_ENABLED, false)
    }

    fun setCaptureEnabled(context: Context, enabled: Boolean) {
        synchronized(lock) {
            prefs(context).edit().putBoolean(KEY_CAPTURE_ENABLED, enabled).apply()
        }
    }

    fun hasRequestedPermission(context: Context): Boolean = synchronized(lock) {
        prefs(context).getBoolean(KEY_ASKED_BEFORE, false)
    }

    fun markRequestedPermission(context: Context) {
        synchronized(lock) {
            prefs(context).edit().putBoolean(KEY_ASKED_BEFORE, true).apply()
        }
    }

    /**
     * Fast privacy pre-filter so personal chats and OTPs are never queued to disk
     * or crossed over the platform channel.
     */
    fun looksLikeSpendSms(sender: String, body: String): Boolean {
        val cleanSender = sender.trim().replace(Regex("[\\s\\-()]"), "")
        if (cleanSender.isNotEmpty() && phoneSenderRegex.matches(cleanSender)) {
            return false
        }
        val compactBody = body.trim()
        if (compactBody.length < 15) return false
        if (otpOnlyRegex.containsMatchIn(compactBody)) return false
        return debitCueRegex.containsMatchIn(compactBody) &&
            currencyOrAmountRegex.containsMatchIn(compactBody)
    }

    fun enqueue(context: Context, sender: String, body: String, receivedAtMs: Long) {
        synchronized(lock) {
            val sp = prefs(context)
            val arr = parseArray(sp.getString(KEY_PENDING, null))
            val cleanBody = body.trim()
            val cleanSender = sender.trim()

            // Avoid queuing exact duplicates back-to-back.
            for (i in 0 until arr.length()) {
                val obj = arr.optJSONObject(i) ?: continue
                if (obj.optString("body") == cleanBody &&
                    obj.optLong("receivedAtMs") == receivedAtMs
                ) {
                    return
                }
            }

            arr.put(
                JSONObject().apply {
                    put("sender", cleanSender)
                    put("body", cleanBody)
                    put("receivedAtMs", receivedAtMs)
                },
            )

            val trimmed = if (arr.length() > MAX_QUEUE_SIZE) {
                JSONArray().apply {
                    for (i in (arr.length() - MAX_QUEUE_SIZE) until arr.length()) {
                        put(arr.get(i))
                    }
                }
            } else {
                arr
            }
            sp.edit().putString(KEY_PENDING, trimmed.toString()).apply()
        }
    }

    fun drainQueue(context: Context): List<Map<String, Any>> = synchronized(lock) {
        val sp = prefs(context)
        val raw = sp.getString(KEY_PENDING, null) ?: return emptyList()
        sp.edit().remove(KEY_PENDING).apply()
        val arr = parseArray(raw)
        val out = ArrayList<Map<String, Any>>(arr.length())
        for (i in 0 until arr.length()) {
            val obj = arr.optJSONObject(i) ?: continue
            out.add(
                mapOf(
                    "sender" to obj.optString("sender"),
                    "body" to obj.optString("body"),
                    "receivedAtMs" to obj.optLong("receivedAtMs"),
                ),
            )
        }
        out
    }

    private fun parseArray(raw: String?): JSONArray {
        if (raw.isNullOrBlank()) return JSONArray()
        return try {
            JSONArray(raw)
        } catch (_: Throwable) {
            JSONArray()
        }
    }
}
