package io.github.pvkarthikk.illam.widget

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.time.LocalDate
import java.util.Date
import java.util.Locale
import java.util.UUID

data class StaffRowData(
    val id: String,
    val name: String,
    val initial: String,
    val colorHex: String,
    val status: String,
    val subtitle: String,
    val action: String,
    val actionLabel: String,
)

data class StaffSnapData(
    val hasHome: Boolean,
    val homeName: String,
    val date: String,
    val items: List<StaffRowData>,
)

data class TodoRowData(
    val id: String,
    val kind: String,
    val title: String,
    val meta: String,
    val overdue: Boolean,
)

data class TodoSnapData(
    val hasHome: Boolean,
    val homeName: String,
    val date: String,
    val totalCount: Int,
    val items: List<TodoRowData>,
)

object WidgetStore {
    private const val PREFS_NAME = "illam_widgets"
    private const val KEY_STAFF_JSON = "staff_json"
    private const val KEY_TODOS_JSON = "todos_json"
    private const val KEY_PENDING_ACTIONS = "pending_actions"

    private val lock = Any()

    private fun prefs(context: Context) =
        context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun saveSnapshots(context: Context, staffJson: String?, todosJson: String?) {
        synchronized(lock) {
            val edit = prefs(context).edit()
            if (staffJson != null) edit.putString(KEY_STAFF_JSON, staffJson)
            if (todosJson != null) edit.putString(KEY_TODOS_JSON, todosJson)
            edit.commit()
        }
    }

    fun hasHome(context: Context): Boolean =
        readStaff(context).hasHome || readTodos(context).hasHome

    fun readStaff(context: Context): StaffSnapData {
        val raw = synchronized(lock) { prefs(context).getString(KEY_STAFF_JSON, null) }
            ?: return StaffSnapData(hasHome = false, homeName = "", date = "", items = emptyList())
        return try {
            val obj = JSONObject(raw)
            val arr = obj.optJSONArray("items") ?: JSONArray()
            val items = ArrayList<StaffRowData>(arr.length())
            for (i in 0 until arr.length()) {
                val it = arr.getJSONObject(i)
                items.add(
                    StaffRowData(
                        id = it.optString("id"),
                        name = it.optString("name"),
                        initial = it.optString("initial", "?"),
                        colorHex = it.optString("colorHex", "#23503A"),
                        status = it.optString("status", "expected"),
                        subtitle = it.optString("subtitle"),
                        action = it.optString("action", "mark_in"),
                        actionLabel = it.optString("actionLabel", "Mark in"),
                    ),
                )
            }
            StaffSnapData(
                hasHome = obj.optBoolean("hasHome", false),
                homeName = obj.optString("homeName"),
                date = obj.optString("date"),
                items = items,
            )
        } catch (_: Exception) {
            StaffSnapData(hasHome = false, homeName = "", date = "", items = emptyList())
        }
    }

    fun readTodos(context: Context): TodoSnapData {
        val raw = synchronized(lock) { prefs(context).getString(KEY_TODOS_JSON, null) }
            ?: return TodoSnapData(hasHome = false, homeName = "", date = "", totalCount = 0, items = emptyList())
        return try {
            val obj = JSONObject(raw)
            val arr = obj.optJSONArray("items") ?: JSONArray()
            val items = ArrayList<TodoRowData>(arr.length())
            for (i in 0 until arr.length()) {
                val it = arr.getJSONObject(i)
                items.add(
                    TodoRowData(
                        id = it.optString("id"),
                        kind = it.optString("kind", "todo"),
                        title = it.optString("title"),
                        meta = it.optString("meta"),
                        overdue = it.optBoolean("overdue", false),
                    ),
                )
            }
            TodoSnapData(
                hasHome = obj.optBoolean("hasHome", false),
                homeName = obj.optString("homeName"),
                date = obj.optString("date"),
                totalCount = obj.optInt("totalCount", items.size),
                items = items,
            )
        } catch (_: Exception) {
            TodoSnapData(hasHome = false, homeName = "", date = "", totalCount = 0, items = emptyList())
        }
    }

    fun enqueueAction(context: Context, action: Map<String, Any?>) {
        synchronized(lock) {
            val p = prefs(context)
            val arr = try {
                JSONArray(p.getString(KEY_PENDING_ACTIONS, "[]"))
            } catch (_: Exception) {
                JSONArray()
            }
            val obj = JSONObject()
            for ((k, v) in action) {
                if (v != null) obj.put(k, v)
            }
            if (!obj.has("id") || obj.optString("id").isEmpty()) {
                obj.put("id", UUID.randomUUID().toString())
            }
            arr.put(obj)
            p.edit().putString(KEY_PENDING_ACTIONS, arr.toString()).commit()
        }
    }

    fun peekPendingActions(context: Context): List<Map<String, Any?>> {
        val raw = synchronized(lock) { prefs(context).getString(KEY_PENDING_ACTIONS, "[]") } ?: "[]"
        return try {
            val arr = JSONArray(raw)
            val out = ArrayList<Map<String, Any?>>(arr.length())
            for (i in 0 until arr.length()) {
                val obj = arr.getJSONObject(i)
                val map = HashMap<String, Any?>()
                val keys = obj.keys()
                while (keys.hasNext()) {
                    val key = keys.next()
                    val value = obj.get(key)
                    map[key] = if (value == JSONObject.NULL) null else value
                }
                out.add(map)
            }
            out
        } catch (_: Exception) {
            emptyList()
        }
    }

    fun ackPendingActions(context: Context, ids: List<String>) {
        if (ids.isEmpty()) return
        val idSet = ids.toSet()
        synchronized(lock) {
            val p = prefs(context)
            val arr = try {
                JSONArray(p.getString(KEY_PENDING_ACTIONS, "[]"))
            } catch (_: Exception) {
                JSONArray()
            }
            val next = JSONArray()
            for (i in 0 until arr.length()) {
                val obj = arr.getJSONObject(i)
                if (!idSet.contains(obj.optString("id"))) {
                    next.put(obj)
                }
            }
            p.edit().putString(KEY_PENDING_ACTIONS, next.toString()).commit()
        }
    }

    fun applyOptimisticAction(context: Context, action: Map<String, Any?>) {
        val kind = action["action"] as? String ?: return
        synchronized(lock) {
            when (kind) {
                "staff_mark_in", "staff_mark_out" -> {
                    val staffId = action["staffId"] as? String ?: return
                    val raw = prefs(context).getString(KEY_STAFF_JSON, null) ?: return
                    try {
                        val root = JSONObject(raw)
                        val arr = root.optJSONArray("items") ?: return
                        val nowStr = SimpleDateFormat("h:mm a", Locale.ENGLISH).format(Date())
                        for (i in 0 until arr.length()) {
                            val item = arr.getJSONObject(i)
                            if (item.optString("id") == staffId) {
                                if (kind == "staff_mark_in") {
                                    item.put("status", "in")
                                    item.put("subtitle", "In since $nowStr")
                                    item.put("action", "mark_out")
                                    item.put("actionLabel", "Mark out")
                                } else {
                                    item.put("status", "done")
                                    item.put("subtitle", "Out at $nowStr")
                                    item.put("action", "mark_in")
                                    item.put("actionLabel", "+ Visit")
                                }
                                break
                            }
                        }
                        prefs(context).edit().putString(KEY_STAFF_JSON, root.toString()).commit()
                    } catch (_: Exception) {
                    }
                }

                "complete_todo", "complete_routine" -> {
                    val itemId = action["itemId"] as? String ?: return
                    val expectedKind = if (kind == "complete_routine") "routine" else "todo"
                    val raw = prefs(context).getString(KEY_TODOS_JSON, null) ?: return
                    try {
                        val root = JSONObject(raw)
                        val arr = root.optJSONArray("items") ?: return
                        val next = JSONArray()
                        var removed = false
                        for (i in 0 until arr.length()) {
                            val item = arr.getJSONObject(i)
                            if (!removed &&
                                item.optString("id") == itemId &&
                                item.optString("kind") == expectedKind
                            ) {
                                removed = true
                            } else {
                                next.put(item)
                            }
                        }
                        if (removed) {
                            root.put("items", next)
                            val count = (root.optInt("totalCount", next.length()) - 1).coerceAtLeast(0)
                            root.put("totalCount", count)
                            prefs(context).edit().putString(KEY_TODOS_JSON, root.toString()).commit()
                        }
                    } catch (_: Exception) {
                    }
                }

                "add_todo" -> {
                    val rawTitle = (action["title"] as? String)?.trim() ?: ""
                    if (rawTitle.isEmpty()) return
                    val due = action["due"] as? String ?: ""
                    val todayIso = LocalDate.now().toString()
                    if (due.isNotEmpty() && due != todayIso) return
                    val title = rawTitle.replaceFirstChar {
                        if (it.isLowerCase()) it.titlecase(Locale.getDefault()) else it.toString()
                    }
                    val raw = prefs(context).getString(KEY_TODOS_JSON, null) ?: return
                    try {
                        val root = JSONObject(raw)
                        if (!root.optBoolean("hasHome", false)) return
                        val arr = root.optJSONArray("items") ?: JSONArray()
                        val next = JSONArray()
                        val added = JSONObject().apply {
                            put("id", "opt_${System.currentTimeMillis()}")
                            put("kind", "todo")
                            put("title", title)
                            put("meta", "Due today · You")
                            put("overdue", false)
                        }
                        var inserted = false
                        for (i in 0 until arr.length()) {
                            val item = arr.getJSONObject(i)
                            if (!inserted && item.optString("kind") == "todo" && !item.optBoolean("overdue", false)) {
                                next.put(added)
                                inserted = true
                            }
                            next.put(item)
                        }
                        if (!inserted) {
                            // Insert before routines if any exist, otherwise append.
                            val withNew = JSONArray()
                            var placed = false
                            for (i in 0 until arr.length()) {
                                val item = arr.getJSONObject(i)
                                if (!placed && item.optString("kind") != "todo") {
                                    withNew.put(added)
                                    placed = true
                                }
                                withNew.put(item)
                            }
                            if (!placed) withNew.put(added)
                            root.put("items", withNew)
                        } else {
                            root.put("items", next)
                        }
                        val count = root.optInt("totalCount", arr.length()) + 1
                        root.put("totalCount", count)
                        prefs(context).edit().putString(KEY_TODOS_JSON, root.toString()).commit()
                    } catch (_: Exception) {
                    }
                }
            }
        }
    }
}
