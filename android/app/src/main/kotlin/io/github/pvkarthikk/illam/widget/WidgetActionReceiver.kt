package io.github.pvkarthikk.illam.widget

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class WidgetActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.getStringExtra(EXTRA_ACTION) ?: return
        if (action == "open_route") {
            val route = intent.getStringExtra(EXTRA_ROUTE) ?: "/today"
            WidgetBridge.openRoute(context, route)
            return
        }

        val payload = HashMap<String, Any?>()
        payload["action"] = action
        intent.getStringExtra(EXTRA_STAFF_ID)?.let { payload["staffId"] = it }
        intent.getStringExtra(EXTRA_ITEM_ID)?.let { payload["itemId"] = it }
        intent.getStringExtra(EXTRA_TITLE)?.let { payload["title"] = it }
        intent.getStringExtra(EXTRA_DUE)?.let { payload["due"] = it }
        if (intent.hasExtra(EXTRA_AMOUNT_PAISE)) {
            payload["amountPaise"] = intent.getIntExtra(EXTRA_AMOUNT_PAISE, 0)
        }
        intent.getStringExtra(EXTRA_MERCHANT)?.let { payload["merchant"] = it }
        intent.getStringExtra(EXTRA_CATEGORY)?.let { payload["category"] = it }
        intent.getStringExtra(EXTRA_METHOD)?.let { payload["method"] = it }
        intent.getStringExtra(EXTRA_DATE)?.let { payload["date"] = it }

        val pendingResult = goAsync()
        WidgetBridge.dispatchAction(context, payload, pendingResult)
    }

    companion object {
        const val EXTRA_ACTION = "widget_action"
        const val EXTRA_STAFF_ID = "widget_staff_id"
        const val EXTRA_ITEM_ID = "widget_item_id"
        const val EXTRA_TITLE = "widget_title"
        const val EXTRA_DUE = "widget_due"
        const val EXTRA_ROUTE = "widget_route"
        const val EXTRA_AMOUNT_PAISE = "widget_amount_paise"
        const val EXTRA_MERCHANT = "widget_merchant"
        const val EXTRA_CATEGORY = "widget_category"
        const val EXTRA_METHOD = "widget_method"
        const val EXTRA_DATE = "widget_date"
    }
}
