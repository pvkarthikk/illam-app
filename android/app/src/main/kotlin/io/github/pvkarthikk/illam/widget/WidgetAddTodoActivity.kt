package io.github.pvkarthikk.illam.widget

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.view.WindowManager
import android.view.inputmethod.EditorInfo
import android.widget.EditText
import android.widget.TextView
import io.github.pvkarthikk.illam.R
import java.time.LocalDate

class WidgetAddTodoActivity : Activity() {
    private var dueIso: String = ""
    private lateinit var input: EditText
    private lateinit var todayChip: TextView
    private lateinit var tomorrowChip: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (!WidgetStore.hasHome(this)) {
            WidgetBridge.openRoute(this, "/today")
            finish()
            return
        }

        dueIso = LocalDate.now().toString()
        setContentView(R.layout.activity_widget_add_todo)
        window.setLayout(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
        )

        input = findViewById(R.id.add_input)
        todayChip = findViewById(R.id.add_chip_today)
        tomorrowChip = findViewById(R.id.add_chip_tomorrow)

        findViewById<View>(R.id.add_backdrop).setOnClickListener { finish() }
        findViewById<View>(R.id.add_dialog_card).setOnClickListener { }
        findViewById<View>(R.id.add_btn_cancel).setOnClickListener { finish() }
        findViewById<View>(R.id.add_btn_submit).setOnClickListener { submit() }

        todayChip.setOnClickListener {
            dueIso = LocalDate.now().toString()
            syncDueChips(isToday = true)
        }
        tomorrowChip.setOnClickListener {
            dueIso = LocalDate.now().plusDays(1).toString()
            syncDueChips(isToday = false)
        }
        syncDueChips(isToday = true)

        input.setOnEditorActionListener { _, actionId, _ ->
            if (actionId == EditorInfo.IME_ACTION_DONE) {
                submit()
                true
            } else {
                false
            }
        }
        input.requestFocus()
    }

    private fun syncDueChips(isToday: Boolean) {
        val activeBg = R.drawable.widget_btn_primary
        val inactiveBg = R.drawable.widget_btn_ghost
        val activeInk = getColor(R.color.widget_on_primary)
        val inactiveInk = getColor(R.color.widget_ink)

        todayChip.setBackgroundResource(if (isToday) activeBg else inactiveBg)
        todayChip.setTextColor(if (isToday) activeInk else inactiveInk)
        tomorrowChip.setBackgroundResource(if (isToday) inactiveBg else activeBg)
        tomorrowChip.setTextColor(if (isToday) inactiveInk else activeInk)
    }

    private fun submit() {
        val title = input.text?.toString()?.trim() ?: ""
        if (title.isEmpty()) {
            input.requestFocus()
            return
        }

        if (WidgetBridge.hasForegroundEngine()) {
            WidgetBridge.dispatchAction(
                this,
                mapOf("action" to "add_todo", "title" to title, "due" to dueIso),
                null,
            )
        } else {
            val broadcast = Intent(this, WidgetActionReceiver::class.java).apply {
                putExtra(WidgetActionReceiver.EXTRA_ACTION, "add_todo")
                putExtra(WidgetActionReceiver.EXTRA_TITLE, title)
                putExtra(WidgetActionReceiver.EXTRA_DUE, dueIso)
            }
            sendBroadcast(broadcast)
        }
        finish()
    }
}
