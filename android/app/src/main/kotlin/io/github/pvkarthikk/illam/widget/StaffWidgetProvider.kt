package io.github.pvkarthikk.illam.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import io.github.pvkarthikk.illam.MainActivity
import io.github.pvkarthikk.illam.R
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.util.Locale

class StaffWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val snap = WidgetStore.readStaff(context)
        val todayIso = LocalDate.now().toString()
        if (snap.date != todayIso) {
            WidgetBridge.dispatchAction(context, mapOf("action" to "refresh"), null)
        }
        for (widgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, widgetId, snap)
        }
    }

    companion object {
        private val dateFormat = DateTimeFormatter.ofPattern("EEE, d MMM", Locale.ENGLISH)

        fun updateAll(context: Context) {
            val mgr = AppWidgetManager.getInstance(context)
            val ids = mgr.getAppWidgetIds(ComponentName(context, StaffWidgetProvider::class.java))
            if (ids.isEmpty()) return
            val snap = WidgetStore.readStaff(context)
            for (id in ids) {
                updateWidget(context, mgr, id, snap)
            }
            @Suppress("DEPRECATION")
            mgr.notifyAppWidgetViewDataChanged(ids, R.id.staff_list)
        }

        private fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
            snap: StaffSnapData,
        ) {
            val views = RemoteViews(context.packageName, R.layout.widget_staff)
            views.setTextViewText(R.id.staff_date, LocalDate.now().format(dateFormat))
            views.setTextViewText(
                R.id.staff_empty,
                context.getString(
                    if (snap.hasHome) R.string.widget_staff_empty
                    else R.string.widget_staff_empty_no_home,
                ),
            )

            val headerIntent = Intent(context, MainActivity::class.java).apply {
                addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP,
                )
                putExtra(WidgetBridge.EXTRA_WIDGET_ROUTE, "/today")
            }
            val headerPi = PendingIntent.getActivity(
                context,
                1001,
                headerIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.staff_header, headerPi)
            views.setOnClickPendingIntent(R.id.staff_empty, headerPi)

            val serviceIntent = Intent(context, StaffWidgetService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
            }
            @Suppress("DEPRECATION")
            views.setRemoteAdapter(R.id.staff_list, serviceIntent)
            views.setEmptyView(R.id.staff_list, R.id.staff_empty)

            val templateIntent = Intent(context, WidgetActionReceiver::class.java)
            val templatePi = PendingIntent.getBroadcast(
                context,
                1002,
                templateIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE,
            )
            views.setPendingIntentTemplate(R.id.staff_list, templatePi)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
