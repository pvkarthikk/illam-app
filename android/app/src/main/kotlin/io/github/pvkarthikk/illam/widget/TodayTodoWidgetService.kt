package io.github.pvkarthikk.illam.widget

import android.content.Context
import android.content.Intent
import android.os.Binder
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import io.github.pvkarthikk.illam.R

class TodayTodoWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory =
        TodayTodoWidgetFactory(applicationContext)
}

private class TodayTodoWidgetFactory(
    private val context: Context,
) : RemoteViewsService.RemoteViewsFactory {
    private var items: List<TodoRowData> = emptyList()

    override fun onCreate() {}

    override fun onDataSetChanged() {
        val token = Binder.clearCallingIdentity()
        try {
            items = WidgetStore.readTodos(context).items
        } finally {
            Binder.restoreCallingIdentity(token)
        }
    }

    override fun onDestroy() {
        items = emptyList()
    }

    override fun getCount(): Int = items.size

    override fun getViewAt(position: Int): RemoteViews? {
        val row = items.getOrNull(position) ?: return null
        val views = RemoteViews(context.packageName, R.layout.widget_todo_row)

        views.setTextViewText(R.id.todo_item_title, row.title)
        views.setTextViewText(R.id.todo_item_meta, row.meta)
        views.setTextColor(
            R.id.todo_item_meta,
            context.getColor(
                if (row.overdue) R.color.widget_danger else R.color.widget_ink3,
            ),
        )

        val checkFill = Intent().apply {
            putExtra(
                WidgetActionReceiver.EXTRA_ACTION,
                if (row.kind == "routine") "complete_routine" else "complete_todo",
            )
            putExtra(WidgetActionReceiver.EXTRA_ITEM_ID, row.id)
        }
        views.setOnClickFillInIntent(R.id.todo_check_target, checkFill)

        val rowFill = Intent().apply {
            putExtra(WidgetActionReceiver.EXTRA_ACTION, "open_route")
            putExtra(
                WidgetActionReceiver.EXTRA_ROUTE,
                if (row.kind == "routine") "/tasks?tab=routines" else "/tasks?tab=todos",
            )
        }
        views.setOnClickFillInIntent(R.id.todo_text_target, rowFill)

        return views
    }

    override fun getLoadingView(): RemoteViews? = null
    override fun getViewTypeCount(): Int = 1
    override fun getItemId(position: Int): Long = items.getOrNull(position)?.id?.hashCode()?.toLong() ?: position.toLong()
    override fun hasStableIds(): Boolean = true
}
