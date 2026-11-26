package io.github.pvkarthikk.illam.sms

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony

class SmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return
        if (!SmsQueueStore.isCaptureEnabled(context)) return

        val parts = Telephony.Sms.Intents.getMessagesFromIntent(intent)
        if (parts.isNullOrEmpty()) return

        // Reassemble multi-part PDUs grouped by originating sender address.
        val grouped = LinkedHashMap<String, StringBuilder>()
        var latestTs = System.currentTimeMillis()
        for (sms in parts) {
            val sender = sms.displayOriginatingAddress?.trim().orEmpty()
            val body = sms.messageBody.orEmpty()
            val ts = sms.timestampMillis
            if (ts > 0) latestTs = ts
            grouped.getOrPut(sender) { StringBuilder() }.append(body)
        }

        for ((sender, bodyBuilder) in grouped) {
            val fullBody = bodyBuilder.toString().trim()
            if (!SmsQueueStore.looksLikeSpendSms(sender, fullBody)) continue
            SmsQueueStore.enqueue(context, sender, fullBody, latestTs)
            SmsBridge.notifyForegroundIncoming(sender, fullBody, latestTs)
        }
    }
}
