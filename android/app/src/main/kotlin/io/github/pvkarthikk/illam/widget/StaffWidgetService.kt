package io.github.pvkarthikk.illam.widget

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.Typeface
import android.os.Binder
import android.text.SpannableString
import android.text.Spanned
import android.text.style.StyleSpan
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import io.github.pvkarthikk.illam.R

class StaffWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory =
        StaffWidgetFactory(applicationContext)
}

private class StaffWidgetFactory(
    private val context: Context,
) : RemoteViewsService.RemoteViewsFactory {
    private var items: List<StaffRowData> = emptyList()

    override fun onCreate() {}

    override fun onDataSetChanged() {
        val token = Binder.clearCallingIdentity()
        try {
            items = WidgetStore.readStaff(context).items
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
        val views = RemoteViews(context.packageName, R.layout.widget_staff_row)

        val avatarColor = try {
            Color.parseColor(row.colorHex)
        } catch (_: Exception) {
            context.getColor(R.color.widget_primary)
        }
        views.setInt(R.id.staff_avatar_bg, "setColorFilter", avatarColor)
        views.setTextViewText(R.id.staff_avatar_text, row.initial)
        views.setTextViewText(R.id.staff_name, row.name)

        if (row.status == "in") {
            val styled = SpannableString(row.subtitle).apply {
                setSpan(StyleSpan(Typeface.BOLD), 0, length, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
            }
            views.setTextViewText(R.id.staff_status, styled)
            views.setTextColor(R.id.staff_status, context.getColor(R.color.widget_ok))
        } else {
            views.setTextViewText(R.id.staff_status, row.subtitle)
            views.setTextColor(R.id.staff_status, context.getColor(R.color.widget_ink2))
        }

        views.setTextViewText(R.id.staff_action_btn, row.actionLabel)
        when {
            row.status == "in" -> {
                views.setInt(R.id.staff_action_btn, "setBackgroundResource", R.drawable.widget_btn_accent)
                views.setTextColor(R.id.staff_action_btn, context.getColor(R.color.widget_on_accent))
            }
            row.status == "done" -> {
                views.setInt(R.id.staff_action_btn, "setBackgroundResource", R.drawable.widget_btn_ghost)
                views.setTextColor(R.id.staff_action_btn, context.getColor(R.color.widget_ink))
            }
            else -> {
                views.setInt(R.id.staff_action_btn, "setBackgroundResource", R.drawable.widget_btn_primary)
                views.setTextColor(R.id.staff_action_btn, context.getColor(R.color.widget_on_primary))
            }
        }

        val actionFill = Intent().apply {
            putExtra(
                WidgetActionReceiver.EXTRA_ACTION,
                if (row.action == "mark_out") "staff_mark_out" else "staff_mark_in",
            )
            putExtra(WidgetActionReceiver.EXTRA_STAFF_ID, row.id)
        }
        views.setOnClickFillInIntent(R.id.staff_action_btn, actionFill)

        val rowFill = Intent().apply {
            putExtra(WidgetActionReceiver.EXTRA_ACTION, "open_route")
            putExtra(WidgetActionReceiver.EXTRA_ROUTE, "/staff/${row.id}")
        }
        views.setOnClickFillInIntent(R.id.staff_row_main, rowFill)

        return views
    }

    override fun getLoadingView(): RemoteViews? = null
    override fun getViewTypeCount(): Int = 1
    override fun getItemId(position: Int): Long = items.getOrNull(position)?.id?.hashCode()?.toLong() ?: position.toLong()
    override fun hasStableIds(): Boolean = true
}
