package io.github.pvkarthikk.illam.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews
import io.github.pvkarthikk.illam.MainActivity
import io.github.pvkarthikk.illam.R
import java.time.LocalDate

class MoneySpendWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val snap = WidgetStore.readMoney(context)
        val todayIso = LocalDate.now().toString()
        if (snap.date != todayIso) {
            WidgetBridge.dispatchAction(context, mapOf("action" to "refresh"), null)
        }
        for (widgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, widgetId, snap)
        }
    }

    companion object {
        fun updateAll(context: Context) {
            val mgr = AppWidgetManager.getInstance(context)
            val ids = mgr.getAppWidgetIds(
                ComponentName(context, MoneySpendWidgetProvider::class.java),
            )
            if (ids.isEmpty()) return
            val snap = WidgetStore.readMoney(context)
            for (id in ids) {
                updateWidget(context, mgr, id, snap)
            }
        }

        private fun openRouteIntent(
            context: Context,
            requestCode: Int,
            route: String,
        ): PendingIntent {
            val intent = Intent(context, MainActivity::class.java).apply {
                addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP,
                )
                putExtra(WidgetBridge.EXTRA_WIDGET_ROUTE, route)
            }
            return PendingIntent.getActivity(
                context,
                requestCode,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }

        private fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
            snap: MoneySnapData,
        ) {
            val views = RemoteViews(context.packageName, R.layout.widget_money)

            views.setTextViewText(
                R.id.money_title,
                snap.headerTitle.ifEmpty { context.getString(R.string.widget_money_header) },
            )
            views.setTextViewText(R.id.money_total, snap.monthSpentText.ifEmpty { "₹0" })

            if (snap.hasHome && snap.budgetSubtitle.isNotEmpty()) {
                views.setViewVisibility(R.id.money_budget, View.VISIBLE)
                views.setTextViewText(R.id.money_budget, snap.budgetSubtitle)
            } else {
                views.setViewVisibility(R.id.money_budget, View.GONE)
            }

            if (snap.hasHome && snap.recentItems.isNotEmpty()) {
                views.setViewVisibility(R.id.money_empty, View.GONE)
                val r1 = snap.recentItems[0]
                views.setViewVisibility(R.id.money_recent_1, View.VISIBLE)
                views.setTextViewText(R.id.money_recent_1_name, r1.merchant)
                views.setTextViewText(R.id.money_recent_1_amt, r1.amountText)

                if (snap.recentItems.size >= 2) {
                    val r2 = snap.recentItems[1]
                    views.setViewVisibility(R.id.money_recent_2, View.VISIBLE)
                    views.setTextViewText(R.id.money_recent_2_name, r2.merchant)
                    views.setTextViewText(R.id.money_recent_2_amt, r2.amountText)
                } else {
                    views.setViewVisibility(R.id.money_recent_2, View.GONE)
                }
            } else {
                views.setViewVisibility(R.id.money_recent_1, View.GONE)
                views.setViewVisibility(R.id.money_recent_2, View.GONE)
                views.setViewVisibility(R.id.money_empty, View.VISIBLE)
                val emptyMsg = snap.emptyText.ifEmpty {
                    context.getString(
                        if (snap.hasHome) R.string.widget_money_empty
                        else R.string.widget_money_empty_no_home,
                    )
                }
                views.setTextViewText(R.id.money_empty, emptyMsg)
            }

            val openMoneyPi = openRouteIntent(
                context,
                3001,
                if (snap.hasHome) "/money" else "/today",
            )
            views.setOnClickPendingIntent(R.id.money_header_main, openMoneyPi)
            views.setOnClickPendingIntent(R.id.money_recent_box, openMoneyPi)

            val scanPi = openRouteIntent(
                context,
                3003,
                if (snap.hasHome) "/money?scan=1" else "/today",
            )
            views.setOnClickPendingIntent(R.id.money_scan_btn, scanPi)

            val addIntent = Intent(context, WidgetAddSpendActivity::class.java).apply {
                addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP,
                )
            }
            val addPi = PendingIntent.getActivity(
                context,
                3002,
                addIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.money_add_btn, addPi)

            if (snap.scanLabel.isNotEmpty()) {
                views.setContentDescription(R.id.money_scan_btn, snap.scanLabel)
            }
            if (snap.addLabel.isNotEmpty()) {
                views.setContentDescription(R.id.money_add_btn, snap.addLabel)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
