package io.github.pvkarthikk.illam.widget

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.view.inputmethod.EditorInfo
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.TextView
import io.github.pvkarthikk.illam.R
import java.time.LocalDate

class WidgetAddSpendActivity : Activity() {
    private lateinit var amountInput: EditText
    private lateinit var merchantInput: EditText
    private lateinit var categoriesRow: LinearLayout
    private lateinit var methodsRow: LinearLayout
    private lateinit var todayChip: TextView
    private lateinit var yesterdayChip: TextView

    private val categoryViews = mutableListOf<Pair<String, TextView>>()
    private val methodViews = mutableListOf<Pair<String, TextView>>()

    private var selectedCategory: String = "Groceries"
    private var selectedMethod: String = "upi"
    private var selectedDateIso: String = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (!WidgetStore.hasHome(this)) {
            WidgetBridge.openRoute(this, "/today")
            finish()
            return
        }

        val snap = WidgetStore.readMoney(this)
        selectedDateIso = LocalDate.now().toString()

        setContentView(R.layout.activity_widget_add_spend)
        window.setLayout(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
        )

        amountInput = findViewById(R.id.add_spend_amount)
        merchantInput = findViewById(R.id.add_spend_merchant)
        categoriesRow = findViewById(R.id.add_spend_categories_row)
        methodsRow = findViewById(R.id.add_spend_methods_row)
        todayChip = findViewById(R.id.add_spend_chip_today)
        yesterdayChip = findViewById(R.id.add_spend_chip_yesterday)

        findViewById<View>(R.id.add_spend_backdrop).setOnClickListener { finish() }
        findViewById<View>(R.id.add_spend_card).setOnClickListener { }
        findViewById<View>(R.id.add_spend_btn_cancel).setOnClickListener { finish() }
        findViewById<View>(R.id.add_spend_btn_submit).setOnClickListener { submit() }

        populateRecentMerchants(snap.recentMerchants)
        populateCategories(snap.categories)
        populateMethods()

        todayChip.setOnClickListener {
            selectedDateIso = LocalDate.now().toString()
            syncDateChips(isToday = true)
        }
        yesterdayChip.setOnClickListener {
            selectedDateIso = LocalDate.now().minusDays(1).toString()
            syncDateChips(isToday = false)
        }
        syncDateChips(isToday = true)

        merchantInput.setOnEditorActionListener { _, actionId, _ ->
            if (actionId == EditorInfo.IME_ACTION_DONE) {
                submit()
                true
            } else {
                false
            }
        }
        amountInput.requestFocus()
    }

    private fun populateRecentMerchants(merchants: List<String>) {
        if (merchants.isEmpty()) return
        val scroll = findViewById<View>(R.id.add_spend_merchants_scroll)
        val row = findViewById<LinearLayout>(R.id.add_spend_merchants_row)
        scroll.visibility = View.VISIBLE
        for (name in merchants) {
            val chip = makeChip(name, selected = false) {
                merchantInput.setText(name)
                merchantInput.setSelection(name.length)
            }
            row.addView(chip)
        }
    }

    private fun populateCategories(options: List<MoneyCategoryOption>) {
        val list = if (options.isNotEmpty()) {
            options
        } else {
            listOf(
                MoneyCategoryOption("Groceries", getString(R.string.widget_cat_groceries)),
                MoneyCategoryOption("Eating out", getString(R.string.widget_cat_eating_out)),
                MoneyCategoryOption("Shopping", getString(R.string.widget_cat_shopping)),
                MoneyCategoryOption("Utilities", getString(R.string.widget_cat_utilities)),
                MoneyCategoryOption("Home care", getString(R.string.widget_cat_home_care)),
                MoneyCategoryOption("Other", getString(R.string.widget_cat_other)),
            )
        }
        selectedCategory = list.first().id
        for (opt in list) {
            lateinit var chipView: TextView
            chipView = makeChip(opt.label, selected = opt.id == selectedCategory) {
                selectedCategory = opt.id
                syncCategoryChips()
            }
            categoryViews.add(opt.id to chipView)
            categoriesRow.addView(chipView)
        }
    }

    private fun populateMethods() {
        val methods = listOf(
            "upi" to getString(R.string.widget_method_upi),
            "cash" to getString(R.string.widget_method_cash),
            "card" to getString(R.string.widget_method_card),
            "bank" to getString(R.string.widget_method_bank),
        )
        for ((id, label) in methods) {
            val chip = makeChip(label, selected = id == selectedMethod) {
                selectedMethod = id
                syncMethodChips()
            }
            methodViews.add(id to chip)
            methodsRow.addView(chip)
        }
    }

    private fun makeChip(label: String, selected: Boolean, onClick: () -> Unit): TextView {
        val density = resources.displayMetrics.density
        val padH = (12 * density).toInt()
        val marginEnd = (8 * density).toInt()
        return TextView(this).apply {
            text = label
            gravity = Gravity.CENTER
            minHeight = (36 * density).toInt()
            setPadding(padH, 0, padH, 0)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
            setTypeface(typeface, android.graphics.Typeface.BOLD)
            isClickable = true
            isFocusable = true
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                (36 * density).toInt(),
            ).apply {
                setMargins(0, 0, marginEnd, 0)
            }
            applyChipStyle(this, selected)
            setOnClickListener { onClick() }
        }
    }

    private fun applyChipStyle(view: TextView, selected: Boolean) {
        view.setBackgroundResource(
            if (selected) R.drawable.widget_btn_primary else R.drawable.widget_btn_ghost,
        )
        view.setTextColor(
            getColor(if (selected) R.color.widget_on_primary else R.color.widget_ink),
        )
    }

    private fun syncCategoryChips() {
        for ((id, view) in categoryViews) {
            applyChipStyle(view, id == selectedCategory)
        }
    }

    private fun syncMethodChips() {
        for ((id, view) in methodViews) {
            applyChipStyle(view, id == selectedMethod)
        }
    }

    private fun syncDateChips(isToday: Boolean) {
        applyChipStyle(todayChip, isToday)
        applyChipStyle(yesterdayChip, !isToday)
    }

    private fun parseRupeesToPaise(raw: String): Int? {
        val cleaned = raw.trim().replace(",", "").replace("₹", "")
        if (!Regex("""^\d{1,7}(\.\d{1,2})?$""").matches(cleaned)) return null
        val dot = cleaned.indexOf('.')
        val paise: Long = if (dot < 0) {
            (cleaned.toLongOrNull() ?: return null) * 100L
        } else {
            val whole = cleaned.substring(0, dot).toLongOrNull() ?: return null
            val frac = cleaned.substring(dot + 1).padEnd(2, '0').toLongOrNull() ?: return null
            whole * 100L + frac
        }
        if (paise <= 0L || paise > 100000000L) return null
        return paise.toInt()
    }

    private fun submit() {
        val amountPaise = parseRupeesToPaise(amountInput.text?.toString() ?: "")
        if (amountPaise == null) {
            amountInput.requestFocus()
            return
        }
        val merchant = merchantInput.text?.toString()?.trim()?.ifEmpty { null } ?: selectedCategory

        if (WidgetBridge.hasForegroundEngine()) {
            WidgetBridge.dispatchAction(
                this,
                mapOf(
                    "action" to "add_spend",
                    "amountPaise" to amountPaise,
                    "merchant" to merchant,
                    "category" to selectedCategory,
                    "method" to selectedMethod,
                    "date" to selectedDateIso,
                ),
                null,
            )
        } else {
            val broadcast = Intent(this, WidgetActionReceiver::class.java).apply {
                putExtra(WidgetActionReceiver.EXTRA_ACTION, "add_spend")
                putExtra(WidgetActionReceiver.EXTRA_AMOUNT_PAISE, amountPaise)
                putExtra(WidgetActionReceiver.EXTRA_MERCHANT, merchant)
                putExtra(WidgetActionReceiver.EXTRA_CATEGORY, selectedCategory)
                putExtra(WidgetActionReceiver.EXTRA_METHOD, selectedMethod)
                putExtra(WidgetActionReceiver.EXTRA_DATE, selectedDateIso)
            }
            sendBroadcast(broadcast)
        }
        finish()
    }
}
