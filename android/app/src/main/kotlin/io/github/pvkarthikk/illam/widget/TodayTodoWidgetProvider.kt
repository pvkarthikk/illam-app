package io.github.pvkarthikk.illam.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import io.github.pvkarthikk.illam.MainActivity
import io.github.pvkarthikk.illam.R
import java.time.LocalDate

class TodayTodoWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val snap = WidgetStore.readTodos(context)
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
            val ids = mgr.getAppWidgetIds(ComponentName(context, TodayTodoWidgetProvider::class.java))
            if (ids.isEmpty()) return
            val snap = WidgetStore.readTodos(context)
            for (id in ids) {
                updateWidget(context, mgr, id, snap)
            }
            @Suppress("DEPRECATION")
            mgr.notifyAppWidgetViewDataChanged(ids, R.id.todo_list)
        }

        private fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
            snap: TodoSnapData,
        ) {
            val views = RemoteViews(context.packageName, R.layout.widget_todo)
            if (snap.hasHome && snap.totalCount > 0) {
                views.setViewVisibility(R.id.todo_count_badge, View.VISIBLE)
                views.setTextViewText(R.id.todo_count_badge, snap.totalCount.toString())
            } else {
                views.setViewVisibility(R.id.todo_count_badge, View.GONE)
            }
            views.setTextViewText(
                R.id.todo_empty,
                context.getString(
                    if (snap.hasHome) R.string.widget_todo_empty
                    else R.string.widget_todo_empty_no_home,
                ),
            )

            val headerIntent = Intent(context, MainActivity::class.java).apply {
                addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP,
                )
                putExtra(WidgetBridge.EXTRA_WIDGET_ROUTE, "/tasks?tab=todos")
            }
            val headerPi = PendingIntent.getActivity(
                context,
                2001,
                headerIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.todo_header_main, headerPi)
            views.setOnClickPendingIntent(R.id.todo_empty, headerPi)

            val addIntent = Intent(context, WidgetAddTodoActivity::class.java).apply {
                addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP,
                )
            }
            val addPi = PendingIntent.getActivity(
                context,
                2002,
                addIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.todo_add_btn, addPi)

            val serviceIntent = Intent(context, TodayTodoWidgetService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
            }
            @Suppress("DEPRECATION")
            views.setRemoteAdapter(R.id.todo_list, serviceIntent)
            views.setEmptyView(R.id.todo_list, R.id.todo_empty)

            val templateIntent = Intent(context, WidgetActionReceiver::class.java)
            val templatePi = PendingIntent.getBroadcast(
                context,
                2003,
                templateIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE,
            )
            views.setPendingIntentTemplate(R.id.todo_list, templatePi)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
