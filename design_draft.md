# Illam: Offline-First Household Management & Local Wi-Fi Sync

*   **Author:** Karthik Venkatesh
*   **Status:** Draft
*   **Date:** 2026-11-22

--------------------------------------------------------------------------------

## Overview

Illam is an Android-first, offline-first household management application for Indian flats and nuclear families. Every household member holds a complete local copy of the flat's data on their own phone and synchronizes directly with other family phones over the home Wi-Fi network—with no cloud backend, no user accounts, and no recurring server hosting costs.

Version 1 covers five text-and-number household workflows in one unified app: assignable one-time and recurring todos, store- and app-grouped shopping lists, domestic help (maid) attendance and adjustable monthly salary calculation, manual household expenses with recurring bills, budgets, and splits, and a weekly meal planner backed by recipes and ingredients. Every member can independently export a passphrase-encrypted backup file through Android's system file picker to Google Drive, OneDrive, or local storage and restore it onto a replacement phone with deterministic bidirectional conflict resolution upon reconnecting to home Wi-Fi.

## The Problem

Running a shared household involves five tightly intertwined daily routines: tracking chores, assembling grocery orders split across quick-commerce apps (Zepto, Blinkit) and physical stores (DMart, Reliance Bazaar), logging domestic help entry/exit times and calculating accurate monthly salaries after leaves and advances, recording shared expenses and monthly bills, and planning meals with recipes.

Today, households scatter these workflows across WhatsApp chats, generic note apps, spreadsheets, and paper notebooks, or adopt cloud-hosted apps that require per-user accounts, expose sensitive personal data (maid phone numbers, home addresses, daily entry/exit presence logs, and household spending) to third-party servers, and fail when internet connectivity is poor.

Solving this purely on-device without a central server introduces four hard problems that naive local apps break on:
1. **Offline divergence:** Multiple family members edit shared lists, expenses, and attendance logs independently while offline and need deterministic convergence without silently dropping money entries or duplicating recurring bills.
2. **Untrusted shared Wi-Fi and Android background limits:** Apartment Wi-Fi networks are not private boundaries, consumer routers often block multicast discovery, and Android Doze/OEM battery killers terminate silent background sockets.
3. **Backup restore collisions:** Restoring an older cloud backup onto a replacement phone can silently drop newer writes, swallow counter increments, or resurrect deleted items across every family phone unless device identity, cursors, and tombstones are isolated from backups.
4. **Role administration without a server:** Restricting membership changes and maid salary edits to home owners must avoid zero-owner lockouts and stale offline role overwrites.

Illam solves these problems by combining a unified local SQLite op-log and deterministic merge engine with owner-paired encrypted home Wi-Fi sync, centralized app-level role guards, and passphrase-encrypted portable backups via Android Storage Access Framework (SAF).

## Goals

*   **Zero-server, offline-first daily operation:** All five household modules (todos, shopping lists, maid attendance/payroll, expenses/bills/budgets/splits, and meal planner/recipes) work fully offline on Android with immediate local reads and writes (`< 100 ms` local UI updates) and no user accounts or cloud backend.
*   **Full-copy home replication over encrypted home Wi-Fi:** Pairing devices via owner-initiated QR/PIN creates an encrypted LAN sync channel (`NsdManager` with manual `IP:port` fallback) that converges all phones on the same Wi-Fi deterministically, with zero lost financial records and zero duplicate machine-generated recurring items.
*   **Safe bidirectional backup and restore:** Any member can export a passphrase-encrypted `.nmflat` archive via Android SAF (supporting Google Drive, OneDrive, Dropbox, Nextcloud, and local storage with zero cloud SDKs), restore it onto a replacement phone with a freshly minted `deviceId`, and merge bidirectionally on home Wi-Fi so the newest state wins without resurrecting tombstoned deletions.
*   **Accurate Indian household payroll and paise-exact finances:** Store all currency in integer paise (`₹1 = 100`, Indian grouping), compute monthly maid salary transparently from attendance logs, configurable paid-leave quotas, effective-dated base salary, and manual adjustments/advances, and keep expense totals and member splits mathematically exact (`sum(splits) == total`).
*   **Transparent sync UX and on-device debuggability:** Surface per-member "Last synced" freshness, actionable clock-skew and discovery warnings, a 1-tap plain-text "Share store list" export for away-from-home shopping, and a `kDebugMode`-only `/debug` diagnostics hub with sync session logs and state digests.
*   **Incremental, verified delivery:** Ship via six vertical milestones (`M0–M5`) backed by multi-node in-memory CRDT simulation tests, step-by-step Drift schema migration tests, and encrypted backup golden-file tests.

## Non-Goals

*   **Away-from-home cellular / mobile-network sync:** Deferred out of v1. Edits made outside home Wi-Fi queue locally and sync when devices reconnect on home Wi-Fi.
*   **Media and file attachments:** No photos, bill receipts, recipe images, or maid ID-proof scans in v1; all data is strictly text, numbers, and dates.
*   **iOS support:** Production v1 targets Android only (`io.github.pvkarthikk.illam`); iOS is deferred until user demand or funding justifies it.
*   **Cryptographic sync-layer RBAC:** v1 assumes cooperative family members and uses centralized app-level owner guards with stale-authority flagging rather than per-operation cryptographic signatures against rooted or malicious devices.
*   **Native cloud provider SDKs or live cloud sync:** No Google Drive API, Microsoft Graph/OneDrive SDK, OAuth app verification, or using personal cloud storage as a live sync relay.
*   **Multi-currency accounting or Splitwise-style debt-simplification graphs:** Expenses use INR (`₹`) with equal/custom splits and a monthly net summary, excluding settlement transfers from monthly spending budgets.

## Open Questions

*   **Bundling custom font assets (`.ttf`):** `lib/core/design/nest_theme.dart` currently specifies `Hanken Grotesk` and `Young Serif` with system fallbacks (`Segoe UI` / `sans-serif`, `Iowan Old Style` / `Georgia` / `serif`), while `pubspec.yaml` does not bundle `.ttf` files yet. Decide before Milestone 0 whether to commit `.ttf` assets under `assets/fonts/` or retain platform fallback rendering.
*   **HLC clock-skew warning/rejection threshold:** Confirm the exact physical clock divergence limit (default `±5 minutes`, configurable constant in `SyncConfig`) at which LAN sync rejects a session with a "Check device date & time" prompt.

## Critical User Journeys (CUJs)

### CUJ 1: Create Home and Pair a Family Member Over Home Wi-Fi

*   **Given**: Two Android phones (`Phone A` and `Phone B`) are connected to the same home Wi-Fi network, and neither has an active home configured.
*   **When**: User A creates a home ("Flat 402"), becoming the first Owner, and opens "Invite Member" to display a pairing QR code (with manual `IP:port` + PIN fallback). User B selects "Join Home", scans the QR code, and enters their member name.
*   **Then**: Both phones establish an authenticated encrypted LAN session using the exchanged 256-bit `home_sync_key`, Phone B receives a paginated full snapshot of the home data, both devices display each other as paired members with a fresh "Last synced" timestamp, and no Location permission prompt or plaintext LAN broadcast of sensitive home data occurs.

### CUJ 2: Concurrent Offline Shopping & Todo Edits Converging on Home Wi-Fi

*   **Given**: User A and User B have synced phones. Both go offline. On the same shopping item ("Milk", grouped under `Zepto`), User A changes the store group to `DMart` while User B marks `checked = true`. Separately, both phones cross midnight on a recurring daily todo ("Switch off geyser").
*   **When**: Both users return home and open Illam on home Wi-Fi (or tap "Sync Now").
*   **Then**: Chunked transactional sync merges the shopping item via Field-LWW so both changes converge deterministically without overwriting unrelated fields, the recurring daily todo appears once (not duplicated) via deterministic occurrence keying, and both phones show identical materialized state and matching state digests.

### CUJ 3: Maid Daily Attendance, Adjustable Monthly Salary, and Optional Expense Logging

*   **Given**: An Owner has added a maid with contact details, address, effective-dated monthly base salary, paid-leave quota, and salary divisor (30-day vs. calendar-day). Over the month, members log morning/evening entry and exit times and record a ₹500 salary advance offline.
*   **When**: At month end, the Owner opens the Maid Payroll view, inspects the live computed salary breakdown (base salary, excess-leave deductions, advances), applies a ₹200 festival bonus adjustment, and records the final salary payout with "Also add to Expenses" enabled.
*   **Then**: An immutable payout ledger entry is recorded along with a decoupled Expense entry referencing it weakly; if another phone later syncs a missed absence from three days prior, the app preserves the payout history and surfaces a visible warning badge indicating late attendance arrived after settlement.

### CUJ 4: Manual Expense Entry, Splits, Typo Correction, and Budgets

*   **Given**: A monthly household budget is set for Groceries and Utilities, and a recurring monthly electricity bill template exists. User A logs a ₹5,000 grocery expense split equally across 3 members, then realizes the amount should be ₹500 while User B also spots the typo offline.
*   **When**: Both users edit the mistyped expense to ₹500 offline and later sync over home Wi-Fi.
*   **Then**: Each expense stores its total and paise-exact split allocation (`16667 + 16667 + 16666 = 50000` paise) atomically inside an immutable row, both offline typo fixes emit superseding snapshots under the same `entry_group_id` that converge to a single active ₹500 expense (never double-reversing to `-₹4,000`), and monthly budget totals reflect only active expenses (excluding member settlement transfers).

### CUJ 5: Meal Planning and One-Tap Recipe Ingredients to Shopping List

*   **Given**: User A has saved a "Paneer Bhurji" recipe with text instructions and ingredients, and planned Tuesday Dinner as "Paneer Bhurji" and Wednesday Lunch as free-text "Leftovers".
*   **When**: User A taps "Add ingredients to Shopping List" on the planned meal, picks a target store group (or leaves as `Any store`), and later deletes the "Paneer Bhurji" recipe.
*   **Then**: Self-contained shopping item copies (with weak `source_ref` IDs) appear under the chosen store group immediately; deleting the recipe tombstones only the recipe without crashing or deleting the shopping items already added.

### CUJ 6: Encrypted Personal Backup via SAF and Bidirectional Restore Merge

*   **Given**: User A previously exported a passphrase-encrypted `.nmflat` backup file to personal Google Drive via Android SAF on Day 10. On Day 14, User A's phone breaks, while User B has deleted two shopping items and added three expenses on Days 11–14.
*   **When**: User A installs Illam on a replacement Android phone, selects "Restore from Backup", picks the `.nmflat` file from Google Drive via SAF, enters the backup passphrase, and later syncs with User B on home Wi-Fi.
*   **Then**: Restore validates `home_id` and the AEAD tag, mints a brand-new `deviceId` (keeping User A's existing `memberId`), clears peer cursors, and merges with User B on Wi-Fi so User B's Day 11–14 expenses appear on User A's phone, User B's tombstoned deletions stay deleted (never resurrected), and any newer edits from the backup propagate cleanly to User B.

--------------------------------------------------------------------------------

## Technical Plan (Architecture)

### 1. System Architecture & Module Boundaries

The application follows a strict three-layer separation aligned with `AGENTS.md`: pure-Dart domain logic with zero Flutter/Drift imports (`lib/core/domain/`), a single SQLite/Drift persistence and sync engine (`lib/core/data/`), and feature UI/Riverpod controllers (`lib/features/`). All writes to synced tables pass exclusively through `ChangeWriter`; feature screens read reactive Drift `watch()` streams exposed via Riverpod `StreamProvider`s.

```text
+-----------------------------------------------------------------------------+
|  UI & Feature Controllers (lib/features/* — Riverpod 3 Notifier/Stream)     |
|  home_setup | todos | shopping | maid | expenses | meals | backup | /debug  |
+-----------------------------+-----------------------------+-----------------+
                              | writes (ChangeWriter)       | reads (watch())
                              v                             |
+-----------------------------------------------------+     |
|  Pure Domain Layer (lib/core/domain/ — zero Flutter)|     |
|  WritePolicyGate | Hlc | MergeEngine | Money (INR)  |     |
|  MaidSalaryCalculator | RecurrenceEngine | Splits   |     |
+-----------------------------+-----------------------+     |
                              | validated ops               |
                              v                             |
+-----------------------------------------------------------------------------+
|  Local Persistence & Sync Core (lib/core/data/ — Drift / SQLite WAL)        |
|  +-----------------------+    +------------------------------------------+  |
|  | ChangeWriter          |--->| sync_ops (local_seq, op_id, hlc, ...)    |  |
|  | (single transaction)  |--->| field_clocks | pn_counters               |  |
|  +-----------------------+    | materialized domain tables (5 modules)   |<-+
|                               +--------------------+---------------------+  |
|                                                    |                        |
|        +-------------------------------------------+------------+           |
|        v                                                        v           |
|  +------------------------------------+   +------------------------------+  |
|  | LanSyncService (Home Wi-Fi Only)   |   | BackupService (Android SAF)  |  |
|  | - NsdManager + MulticastLock       |   | - Argon2id + XChaCha20-Poly  |  |
|  | - Manual IP:port / QR fallback     |   | - Timestamped .nmflat file   |  |
|  | - Raw TCP + X25519 + AEAD frames   |   | - Fresh device_id on restore |  |
|  | - 200-500 op chunks + ACK cursors  |   | - Same CRDT ingest pipeline  |  |
|  +------------------------------------+   +------------------------------+  |
+-----------------------------------------------------------------------------+
```

### 2. Identity Model (`home_id`, `member_id`, `device_id`)

Three distinct identifiers prevent phone replacements and backup restores from corrupting household state:

*   **`home_id` (UUIDv4):** Identifies the household. Generated once on "Create Home" and validated on every LAN handshake and backup restore envelope.
*   **`member_id` (UUIDv4):** Identifies a human household member. Referenced by todo assignees, expense payers/splits, and owner roles. Survives phone loss and backup restore. Members are soft-deactivated (`active = false`), never hard-deleted, so historical financial and attendance records remain intact.
*   **`device_id` (UUIDv4):** Identifies one specific Android installation. Used strictly for HLC lexicographical tie-breaking, PN-Counter actor slots, and `peer_cursors`. Stored only in the local-only `device_identity` table, never exported as active identity in cloud backups, and **always rotated to a freshly minted UUID on backup restore or reinstall**.

### 3. Local Persistence & Unified Sync Storage (Drift / SQLite WAL)

SQLite runs in WAL mode (`PRAGMA journal_mode=WAL`, `PRAGMA busy_timeout=5000`). Hard SQL `FOREIGN KEY ... ON DELETE CASCADE` constraints are prohibited across synced tables so out-of-order sync arrival and permanent tombstones never trigger referential crashes; read queries handle missing or soft-deleted references safely.

#### Core Sync & Local-Only Tables

| Table | Scope | Purpose & Key Columns |
| --- | --- | --- |
| `sync_ops` | Synced / Backed up | Append-only local op log: `local_seq` (`INTEGER PRIMARY KEY AUTOINCREMENT`), `op_id` (`TEXT UNIQUE`), `home_id`, `table_name`, `row_id`, `op_type` (`set`/`inc`/`tombstone`/`append`), `field_name`, `payload_json`, `hlc`, `field_lamport_ver`, `origin_device_id`, `actor_member_id`, `role_epoch`, `schema_ver`, `received_from_device_id`, `applied` (`0`/`1`). |
| `field_clocks` | Materialized CRDT state | Tracks winning `(field_lamport_ver, hlc, origin_device_id)` per `(table_name, row_id, field_name)` for O(1) Field-LWW comparisons during merge. |
| `pn_counters` | Materialized CRDT state | Tracks per-actor `(p_val, n_val)` per `(table_name, row_id, field_name, actor_device_id)`. Merge takes element-wise `max(p_val)` and `max(n_val)`. |
| `quarantined_ops` | Local diagnostic / review | Stores incoming synced ops whose `role_epoch` or `actor_member_id` failed owner-authority validation at write time, surfaced for Owner review. |
| `device_identity` | Local-only (unsynced) | Holds current `device_id`, `member_id`, `home_id`, local HLC state, and `hlc_clamp_count`. `home_sync_key` is stored separately in `flutter_secure_storage`. |
| `peer_cursors` | Local-only (unsynced) | Tracks per-peer `peer_device_id`, `last_acked_local_seq_sent`, `last_remote_seq_received`, `last_success_at_ms`, `consecutive_failures`, and `last_error_code`. |
| `sync_events` | Local-only (unsynced) | Bounded 1,000-row ring buffer of sanitized sync diagnostics keyed by `sync_session_id` (no financial amounts or PII). |

#### `ChangeWriter` Write & Undo Mechanics

1.  Feature controllers call `ChangeWriter.write(label, builder)` with intent actions (`create`, `set`, `inc`, `appendLedger`, `delete`).
2.  `WritePolicyGate` validates local permissions (owner-only actions check current member role).
3.  Inside a single `BEGIN IMMEDIATE` SQLite transaction, `ChangeWriter`:
    *   Advances the local HLC (clamping local physical-clock regressions/jumps without ever mutating peer timestamps),
    *   Increments `field_lamport_ver` for modified Field-LWW fields,
    *   Appends atomic op rows into `sync_ops` (assigning monotonic `local_seq`),
    *   Updates `field_clocks` / `pn_counters` and materializes the new state into the target Drift domain table,
    *   Returns `ChangeResult(undoToken)` referencing the previous state.
4.  Invoking **Undo** never deletes rows from `sync_ops`. Instead, it emits forward compensating ops inside a fresh transaction (restoring the previous Field-LWW value or setting `deleted = false` at a higher `(field_lamport_ver, hlc)`, posting an inverse PN-Counter delta, or appending a superseding/void financial snapshot).
5.  **Cross-version forward compatibility:** If an incoming op references an unrecognized `table_name` or `field_name` from a newer app version, the ingest pipeline still stores it in `sync_ops` with `applied = 0` so the device relays it to other phones intact and materializes it automatically after the app upgrades.

### 4. Domain Data Model & CRDT Classification Matrix

All currency values are stored as integer paise (`int`, `₹1 = 100`) and formatted with Indian grouping (`₹1,23,456`). Dates use local `YYYY-MM-DD` strings; instants use epoch milliseconds (`int`).

| Merge Class | Domain Tables / Fields | Merge & Domain Invariants |
| --- | --- | --- |
| **Field-LWW + Permanent Tombstone Row** | `homes`, `home_members`, `todo_templates`, `todos`, `shopping_stores`, `shopping_items` (`name`, `store_id`, `checked`, atomic `quantity_unit_json`, `notes`), `maids` (contact details), `maid_salary_rules` (effective-dated base salary, paid leaves/month, `fixed30` vs. `calendar_days`), `maid_attendance` (keyed by `(maid_id, date, shift_slot)` with atomic `status_times_json`), `expense_categories`, `budgets`, `recurring_bill_templates`, `recipes`, `recipe_ingredients`, `meal_plan_entries` (`date`, `slot`, `recipe_id` or `free_text`) | Winning write chosen by lexicographical max of `(field_lamport_ver, hlc, origin_device_id)`. Tightly coupled fields (maid `status + entry_time + exit_time`; shopping `quantity + unit`) are stored as single atomic JSON LWW fields so invalid hybrid states cannot occur. Rows are never hard-deleted (preventing old-backup resurrection); on `deleted = true`, non-essential text fields (`notes`, `instructions`) are cleared to bound SQLite growth. |
| **PN-Counter (Restricted)** | Reserved strictly for unitless relative `+1`/`-1` integer counters (if introduced for tally counters) | Stored in `pn_counters` per `actor_device_id`. Historical `device_id` slots from restored backups are frozen read-only; new deltas write only to the freshly minted `device_id`. Not used for mixed-unit shopping quantities or financial amounts. |
| **Append-Only Immutable (Superseding Snapshots)** | `expense_entries` (atomic `amount_paise`, `payer_member_id`, `splits_json`, `entry_kind: expense|settlement`, `entry_group_id`, `supersedes_id`, `void_key`), `maid_ledger_entries` (advances, bonuses, deductions, payouts, manual overrides with `entry_group_id`, `supersedes_id`, `void_key`, `attendance_watermark_hlc`) | Rows never mutate in place. Editing a mistyped expense or maid entry appends a new row referencing `supersedes_id` under the same `entry_group_id`; active totals read only the winning leaf revision per `entry_group_id` (concurrent fixes to ₹500 converge to ₹500). Deletions use a deterministic 1-to-1 `void_key` (`void:<entry_group_id>`) so concurrent voids collapse to one. Splits allocate remainder paise deterministically (`sum(splits) == amount_paise`). Settlements are excluded from monthly budgets. |
| **Read-Time Derived Projections (Unsynced)** | Upcoming recurring todos, upcoming recurring bills, live monthly maid salary owed, monthly budget remaining, monthly net split balances | Computed dynamically in `lib/core/domain/` from synced rules and ledger rows. Materializing a recurring occurrence (completing a chore or paying a bill) writes a row with deterministic ID `UUIDv5(namespace, "$templateId:$YYYY_MM_DD")` so offline peers never create duplicate occurrences. |

#### Cross-Module Decoupling Rules
*   **Recipes → Shopping Lists:** 1-tap "Add ingredients" copies ingredient rows into `shopping_items` with an optional weak `source_ref` (`recipe:<id>`). Deleting the recipe never affects the shopping list.
*   **Shopping Lists → Expenses:** Optional 1-tap "Log as Expense" after a store run creates a standalone `expense_entries` row referencing the store tag.
*   **Maid Payout → Expenses:** Recording a monthly salary payout offers an optional toggle (default ON) that writes both the `maid_ledger_entries` payout row and a decoupled `expense_entries` row with weak `source_ref` (`maid_payout:<id>`).
*   **Maid Override Warning & Opt-In Attendance:** Maid attendance is strictly **opt-in**: only dates with an explicit logged entry (`present` or `half_day`, with entry/exit timestamps) count as worked days alongside configured paid-leave allowances; any unlogged scheduled working days are highlighted as "Unmarked" in the monthly payroll view so the user can backfill or mark explicit absences before settlement. When an Owner records a manual salary override or payout, it captures `attendance_watermark_hlc`. If a synced attendance edit or advance for that month arrives later with a newer HLC, the UI preserves the historical payout and shows a visible reconciliation warning badge.

### 5. Owner Role Governance & Conflict Safety

*   **Centralized Policy Gate:** All owner-only actions (invite/remove member, promote/demote owner, edit maid contact/salary rules/settlements) pass through `WritePolicyGate` inside `ChangeWriter`, never ad-hoc UI checks alone.
*   **Deterministic Last-Owner Invariant:** Multiple owners are supported. If two offline owners mutually demote each other, the role resolver guarantees at least one active owner by deterministically preserving the owner with the earliest `promoted_at` (tie-broken by lexicographical `member_id`). If the sole owner's phone is permanently lost, remaining members can recover ownership via an explicit documented "Reset Home via Backup Export & New Home" path (or by having a second family member promoted to co-owner during setup).
*   **Stale-Authority Flagging:** Every owner-guarded op carries `role_epoch` (incremented whenever `home_members.role` changes). If an incoming op was written by a member whose role was demoted or under an older `role_epoch`, the merge engine records it in `quarantined_ops` and notifies owners to accept or dismiss it without stalling sync convergence.
*   **Removed Member Boundary:** The LAN handshake rejects `member_id` values marked removed in `home_members`. Because v1 does not use cryptographic sync-layer RBAC, removing a member displays an explicit notice that rotating `home_sync_key` (re-pairing remaining phones via QR) is required to cut off an uncooperative device.

### 6. Home Wi-Fi Discovery & Encrypted Raw TCP Sync Protocol

#### Pairing Ceremony (Create / Join Home)
1.  "Create Home" generates `home_id`, a 256-bit random `home_sync_key` (stored in `flutter_secure_storage`), `member_id` (role `owner`), and `device_id`.
2.  "Invite Member" starts the local TCP listener on an ephemeral port and displays a QR code (plus manual `IP:port` + 6-digit PIN fallback) encoding `{home_id, home_sync_key, host_ip, port, pairing_nonce, expires_at}`. `home_sync_key` is never broadcast over mDNS or sent in plaintext over Wi-Fi.
3.  The joining phone scans the QR code, saves `home_sync_key` in `flutter_secure_storage`, opens the encrypted TCP session, registers its new `member_id` + `device_id`, and pulls the initial paginated op stream.

#### Peer Discovery & Foreground Sync Trigger Model
*   **Discovery:** While the app is open on Wi-Fi, `LanSyncService` acquires a scoped `WifiManager.MulticastLock` and registers/browses `_illam._tcp` via Android `NsdManager`, placing only `h=<truncated_sha256(home_id || "illam-mdns-v1")>` and `p=<protocol_ver>` in TXT records (zero PII, zero SSID reads, zero Location permissions). If router AP isolation blocks multicast, users can tap "Connect Manually" and enter or scan a peer's `IP:port`.
*   **Sync Triggers:** Foreground opportunistic auto-sync whenever two home phones have the app open on Wi-Fi, plus a manual "Sync Now" button (which optionally holds a short-lived Android `dataSync` foreground notification while an active transfer is in progress). No silent Doze-killed background daemon is promised in v1.
*   **Glare Resolution:** If Device A and Device B discover each other simultaneously, the device with the lexicographically lower `device_id` acts as TCP initiator and the higher `device_id` acts as listener.

#### Wire Protocol (Raw TCP + X25519 + AEAD Length-Prefixed Frames)

```text
Initiator (lower device_id)                         Listener (higher device_id)
---------------------------                         ---------------------------
1. TCP Connect (ephemeral port) ------------------> Accept
2. HELLO_INIT {proto_ver, schema_ver, home_id,
   device_id, member_id, eph_x25519_pub_A,
   nonce_A, wall_clock_ms_A, sync_session_id,
   mac_A = HMAC(home_sync_key, transcript_A)} ----> Verify home_id, member not removed,
                                                    mac_A, and clock skew threshold
3. <---- HELLO_RESP {proto_ver, schema_ver,
   device_id, member_id, eph_x25519_pub_B,
   nonce_B, wall_clock_ms_B, peer_last_seq_B,
   mac_B = HMAC(home_sync_key, transcript_B)}
   [Both sides derive directional AEAD keys via HKDF-SHA256(X25519(A,B) || home_sync_key)]
4. Encrypted Frame: OPS_BATCH (200-500 ops,
   <= 1 MB uncompressed, local_seq > cursor) -----> Decrypt & verify AEAD tag
                                                    BEGIN IMMEDIATE transaction:
                                                    - Dedup by op_id
                                                    - Merge via Field-LWW / PN / Ledger
                                                    - Bump local_seq ONLY if state changed
                                                    COMMIT
5. <---- Encrypted Frame: OPS_ACK {acked_seq}
   Update peer_cursors.last_acked_local_seq_sent
6. Repeat 4-5 in reverse direction (Listener -> Initiator), then CLOSE_OK
```

*   **Frame format:** `[4-byte big-endian frame_len][1-byte frame_type][12-byte counter nonce][AEAD ciphertext + 16-byte tag]` using `XChaCha20-Poly1305` (or `AES-256-GCM`) with monotonic per-direction frame counters to prevent replay/reordering.
*   **Clock skew handling:** Incoming wire HLCs are never rewritten. If `|wall_clock_ms_A - wall_clock_ms_B|` exceeds the configured skew limit (tracked in Open Questions), the handshake returns `ERR_CLOCK_SKEW` and surfaces an actionable banner prompting the user to enable Automatic Date & Time without corrupting `peer_cursors`.
*   **Echo-loop prevention:** Outbound delta queries filter `WHERE local_seq > last_acked_sent AND (received_from_device_id IS NULL OR received_from_device_id != peer_device_id)`, and incoming no-op ops (where local state does not change) do not allocate a new `local_seq`.
*   **Away-from-home escape hatch:** Shopping screens display per-member "Last synced" freshness and provide a 1-tap plain-text "Share store list" export (WhatsApp/SMS).

### 7. Passphrase-Encrypted Portable Backup & Restore (Android SAF)

*   **Archive Format (`.nmflat`):**
    *   **Plaintext authenticated header (AAD):** `{magic: "NMFLAT1", format_version: 1, app_schema_version, home_id, kdf: "argon2id", kdf_mem_kib, kdf_iters, kdf_parallelism, salt_b64, nonce_b64, created_at_ms, op_count}`.
    *   **AEAD ciphertext payload:** Gzipped JSONL containing `{home_sync_key, sync_ops: [...]}` encrypted with the Argon2id-derived key using `XChaCha20-Poly1305`. Device-local state (`device_id`, `local_seq`, `peer_cursors`, `sync_events`) is strictly excluded.
    *   **Key recovery:** Because the key derives from a user-chosen backup passphrase (or generated recovery code), backups remain decryptable on a brand-new phone even if the old phone and its Android Keystore are completely lost. The derived key may optionally be cached in `flutter_secure_storage` purely to avoid re-typing on routine exports.
*   **Export Flow:** Uses Android SAF (`ACTION_CREATE_DOCUMENT`) writing a new timestamped filename (`illam_YYYYMMDD_HHMMSS.nmflat`) so cloud providers like OneDrive never suffer in-place overwrite truncation.
*   **Restore Flow:** Uses Android SAF (`ACTION_OPEN_DOCUMENT`). Validates header `magic`, `format_version`, and AEAD authentication tag; checks `home_id` (blocking accidental merge of a different household's backup into an active home); takes an automatic local pre-restore SQLite snapshot; mints a **brand-new `device_id`** (preserving the user's `member_id`), resets `peer_cursors`, freezes historical `device_id` PN-Counter slots, and runs every restored op through the standard CRDT ingest pipeline in chunked transactions; displays a plain-English merge summary (inserted, updated, skipped, tombstones preserved).

### 8. On-Device Observability & `/debug` Diagnostics (`kDebugMode`)

Because there is no central server, diagnostics live locally behind `/debug` (compiled only when `kDebugMode` is true):
*   Identity & clock view: `device_id`, `member_id`, `home_id`, current HLC, wall-clock offset, `hlc_clamp_count`, `max_observed_skew_ms`.
*   Storage & cursor table: SQLite `schemaVersion`, per-table active/tombstone/`sync_ops` counts, `peer_cursors` rows, and `quarantined_ops` viewer.
*   Sync session log: live viewer and sanitized JSON export of the 1,000-row `sync_events` ring buffer keyed by `sync_session_id`.
*   Convergence check & backup validator: deterministic per-collection SHA-256 state digest (for comparing two phones side by side) and a dry-run `.nmflat` decrypt/merge simulator.

--------------------------------------------------------------------------------

## Alternatives Considered

### Alternative A: Away-from-Home WebRTC Peer-to-Peer Sync in v1

*   **Pros:** Allows real-time updates when one member is outside on cellular data (for example, adding a Zepto item from work while a spouse orders from home).
*   **Cons:** Cellular phones behind Indian carrier CGNAT (Jio, Airtel, Vi) still require a public signaling server and frequently a TURN relay server, reintroducing backend hosting and bandwidth costs. WebRTC also requires both phones to be awake simultaneously, which fails when one phone is locked in Android Doze mode.
*   **Reason for Rejection:** Rejected by author: contradicts v1's zero-server constraint and adds signaling/TURN/Doze reliability complexity before home Wi-Fi sync is proven. Deferred to post-v1.

### Alternative B: Direct Native Google Drive & OneDrive OAuth SDKs for Backups

*   **Pros:** Enables in-app one-tap cloud backup flows and optional background uploads to a dedicated app folder without opening Android's file picker.
*   **Cons:** Requires Google Play restricted-scope OAuth app verification, Microsoft Azure/MSAL registration, per-provider API quota management, token refresh edge cases, and heavy third-party SDK dependencies—purely for a portable backup feature that is never a live backend.
*   **Reason for Rejection:** Rejected by author: Android Storage Access Framework (SAF) supports Google Drive, OneDrive, Dropbox, Nextcloud, and local storage with zero cloud SDKs, zero OAuth verification overhead, and zero API quotas.

### Alternative C: Local HTTPS (`HttpServer.bindSecure`) or Local HTTP with `network_security_config`

*   **Pros:** Standard HTTP routing, headers, and timeouts avoid writing a custom length-prefixed binary TCP frame parser.
*   **Cons:** Local HTTPS requires generating/storing X.509 certificates on Android, pinning fingerprints inside `badCertificateCallback` (scrutinized by Play Store security checks), and breaks when a skewed phone clock falls outside a cert's validity window. Local HTTP cannot exempt arbitrary LAN IP subnets (`192.168.*`) via Android `network_security_config.xml` `<domain>` entries without enabling global `cleartextTrafficPermitted="true"`, which triggers Play Store automated cleartext warnings.
*   **Reason for Rejection:** Rejected by author: raw TCP with application-layer X25519 + HKDF + AEAD length-prefixed frames avoids both X.509 cert-clock failures and Play Store cleartext/TrustManager flags.

### Alternative D: OR-Sets / LWW-Element-Sets, Tombstone GC, & Raw HLC Sync Cursors

*   **Pros:** Standard academic CRDT toolkit for large distributed systems; retention-window tombstone garbage collection bounds table row count over many years.
*   **Cons:** OR-Sets add per-element tag bookkeeping unnecessary for 2–5 person households; retention-window tombstone GC causes older personal cloud backups to resurrect deleted items across every family phone on bidirectional restore; using raw HLC as the delta-sync cursor silently skips late-arriving older-HLC records across 3+ peers.
*   **Reason for Rejection:** Rejected by author: replaced with normalized child rows, permanent tombstone retention (with heavy text payload stripping), and monotonic local receive sequences (`local_seq`) for delta cursors while keeping HLC strictly for merge ordering.

### Alternative E: PN-Counters on Shopping Quantities & Numeric Delta Reversals for Expenses

*   **Pros:** Simple additive merge math without custom revision chains.
*   **Cons:** PN-Counters break on direct quantity entry ("set to 3" on two phones becomes 4), unit changes (`2 packs` vs. `500 g`), negative underflow below zero, and check-off vs. `+1` races. Numeric delta reversals (`-₹4,500`) double-reverse balances if two offline members fix the same typo (`-₹4,000` net), and separate synced split rows break `sum(splits) == total`.
*   **Reason for Rejection:** Rejected by author: replaced with atomic Field-LWW for freeform `quantity + unit` shopping values (restricting PN-Counters strictly to unitless relative counters), atomic embedded split maps inside immutable expense rows, and append-only superseding snapshots (`supersedes_id`) with 1-to-1 idempotent void keys.

### Alternative F: Cryptographic Sync-Layer RBAC

*   **Pros:** Prevents a rooted or compromised family device from forging owner-only writes (membership changes, maid salary edits) during LAN sync.
*   **Cons:** Requires per-member asymmetric keypairs, signed op envelopes, offline revocation certificates, and key-rotation protocols across intermittently connected phones.
*   **Reason for Rejection:** Rejected by author: v1 targets cooperative household/family devices; centralized app-level owner guards (`WritePolicyGate`), deterministic last-owner resolution, and `role_epoch` stale-authority flagging cover honest offline races without cryptographic RBAC complexity.

### Alternative G: Shipping All Five Modules in One Unvalidated Release

*   **Pros:** Delivers the complete feature checklist in a single initial build.
*   **Cons:** Building five domain modules on top of an unproven local CRDT and LAN transport layer risks rewriting schemas and controllers across every module when real-device Wi-Fi edge cases surface.
*   **Reason for Rejection:** Rejected by author: replaced with incremental vertical milestones (`M0–M5`) that validate the Drift sync core and encrypted Wi-Fi sync on physical Android phones with Shopping/Todos first before building Maid, Expenses, Meals, and SAF Backup.

--------------------------------------------------------------------------------

## Non-Functional Requirements

### Security & Privacy
*   **LAN Confidentiality & Integrity:** All home Wi-Fi sync traffic is encrypted and authenticated using ephemeral X25519 + 256-bit `home_sync_key` via HKDF-SHA256 and AEAD (`XChaCha20-Poly1305` / `AES-256-GCM`). No maid PII, home names, or financial data appear in mDNS TXT records or cleartext packets.
*   **Backup Confidentiality & Key Independence:** `.nmflat` files are encrypted with Argon2id + AEAD derived from a user passphrase/recovery code, independent of Android Keystore. Plaintext headers act as AAD so tampering fails authentication before any database write.
*   **Android Auto Backup Disabled:** `android:allowBackup="false"` (and Android 12+ `dataExtractionRules` excluding DB and preferences) prevents Android cloud restore from cloning `device_id` across two devices.
*   **Zero Location Permissions:** Peer discovery uses `NsdManager` + `WifiManager.MulticastLock` without reading Wi-Fi SSIDs or requesting `ACCESS_FINE_LOCATION` or `NEARBY_WIFI_DEVICES`.

### Performance, Storage & Resource Budgets
*   **Local UI Responsiveness:** Local writes via `ChangeWriter` and reactive Drift `watch()` updates complete in `< 100 ms` on mid-range/budget Android devices (3–4 GB RAM).
*   **Memory & SQLite Lock Safety:** Sync batches are strictly capped at 200–500 ops (`<= 1 MB` uncompressed per frame) and applied in one `BEGIN IMMEDIATE` transaction per chunk under SQLite WAL mode (`busy_timeout = 5000 ms`) to prevent OOM and `SQLITE_BUSY` UI stalls during multi-year initial sync or restore.
*   **Storage Footprint:** Text-only household usage (~50 ops/day ≈ 18,000 ops/year) occupies ~3–5 MB/year in SQLite; clearing non-essential text fields on tombstoned rows keeps 3–5 year household databases and gzipped `.nmflat` backups compact.
*   **Battery Discipline:** `WifiManager.MulticastLock` and TCP listeners run strictly while the app is foregrounded (or during a bounded manual Sync Now transfer), avoiding continuous background wake locks.

### Rollout, Compatibility & Accessibility
*   **Staggered App Updates:** Additive-only SQLite migrations with committed `drift_schemas/` snapshots and `SchemaVerifier` step-by-step tests. Unknown `table_name` / `field_name` ops stay persisted in `sync_ops` (`applied = 0`) for pass-through relay and automatic materialization on upgrade.
*   **Restore Rollback Safety:** Every backup restore writes a pre-restore local SQLite snapshot first so a failed or aborted merge never leaves the local database half-applied.
*   **Accessibility:** All icon-only controls provide `tooltip` or `Semantics(label:)`, touch targets are `>= 48 dp`, and all layouts wrap cleanly without clipping at font scale `2.0`.

--------------------------------------------------------------------------------

### Additional Resources

*   [concepts_brief.md](./concepts_brief.md) — Synthesized multi-lens brainstorm brief and locked decisions `D1–D6`.
*   [AGENTS.md](./AGENTS.md) — Project rules, Flutter/Dart stack constraints, and coding conventions.

### Future Improvements

*   **Away-from-home encrypted relay sync:** Optional zero-knowledge mailbox/relay or user-owned encrypted cloud sync folder so cellular edits (such as away-from-home Zepto/DMart updates) propagate without requiring simultaneous Wi-Fi presence.
*   **iOS support:** Add iOS Bonjour (`NSLocalNetworkUsageDescription`) discovery and Files-app backup integration once user demand or funding justifies cross-platform maintenance.
*   **Encrypted media attachments:** Content-addressed compressed photos for bill receipts, recipe dishes, and maid ID references synced separately from text `sync_ops`.
*   **Cryptographic sync-layer RBAC & automatic LAN key rotation:** Per-member Ed25519 signing keys and automated `home_sync_key` rotation on member removal for lower-trust flatmate households.

--------------------------------------------------------------------------------

## Detailed Implementation Plan

Implementation is organized into six incremental vertical milestones (`M0–M5`) inside one unified file list so every touched file, rationale, and verification gate is explicit before coding begins.

### Target Files to Create/Modify

#### Milestone 0 (M0): Repo Housekeeping, Core Dependencies, Localization, & Shared Design Shell

##### 1. `AGENTS.md` (Modify)
*   **Type / Scope:** Repository conventions and coding contract.
*   **Proposed Changes:** Fix the duplicate Material import typo on line 17 to mandate `package:material_ui/material_ui.dart` (forbidding `package:flutter/material.dart`); change currency notation on line 24 from `£` to INR `₹` (`₹1 = 100` paise, Indian grouping `₹1,234`); update the `SyncedColumns` and `ChangeWriter` data rules to match the `sync_ops` + `field_clocks` + `pn_counters` + compensating-undo design; align app display title punctuation (`Illam`).

##### 2. `pubspec.yaml` and `l10n.yaml` (Modify / Create)
*   **Type / Scope:** Package manifest and Flutter ARB localization configuration.
*   **Proposed Changes:** Add pinned dependencies (`flutter_riverpod: ^3.0.0`, `go_router: ^18.0.0`, `drift: ^2.26.0`, `drift_flutter: ^0.2.4`, `shared_preferences: ^2.5.0`, `flutter_secure_storage: ^9.2.4`, `flutter_localizations` SDK, `intl: ^0.20.0`, `cryptography: ^2.7.0`, `uuid: ^4.5.1`, `qr_flutter: ^4.1.0`, `mobile_scanner: ^6.0.0`) and dev dependencies (`drift_dev: ^2.26.0`, `build_runner: ^2.4.15`) using `flutter pub add`; enable `flutter: generate: true`; create `l10n.yaml` pointing to `lib/l10n/app_en.arb` and generating `AppLocalizations`. (If custom `.ttf` bundling is chosen from Open Questions, register `Hanken Grotesk` and `Young Serif` under `flutter: fonts:`.)

##### 3. `android/app/build.gradle.kts` (Modify)
*   **Type / Scope:** Android Gradle build configuration.
*   **Proposed Changes:** Change `namespace` and `applicationId` from `com.example.nm_flat` to `io.github.pvkarthikk.illam`; set `minSdk = 26` and `targetSdk = 35` so `NsdManager`, SAF document pickers, and modern Android Keystore APIs are guaranteed.

##### 4. `android/app/src/main/AndroidManifest.xml` and `android/app/src/main/res/xml/data_extraction_rules.xml` (Modify / Create)
*   **Type / Scope:** Android manifest permissions and backup-exclusion rules.
*   **Proposed Changes:** Add `<uses-permission>` entries for `INTERNET`, `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE`, `CHANGE_WIFI_MULTICAST_STATE`, and `CAMERA` (for QR pairing only — explicitly omitting Location and `NEARBY_WIFI_DEVICES`); set `android:allowBackup="false"` and `android:dataExtractionRules="@xml/data_extraction_rules"` excluding SQLite databases and SharedPreferences so Android Auto Backup never clones `device_id` across phones; declare optional `FOREGROUND_SERVICE_DATA_SYNC` for bounded manual Sync Now transfers.

##### 5. `android/app/src/main/kotlin/io/github/pvkarthikk/illam/MainActivity.kt` (Create; Delete `android/app/src/main/kotlin/com/example/nm_flat/MainActivity.kt`)
*   **Type / Scope:** Android Kotlin platform bridge.
*   **Proposed Changes:** Move `MainActivity` to `package io.github.pvkarthikk.illam` matching the updated namespace; register lightweight `MethodChannel` handlers for: (a) acquiring/releasing `WifiManager.MulticastLock` + running `NsdManager` service registration/discovery (`_illam._tcp` TXT records), and (b) launching Android SAF `ACTION_CREATE_DOCUMENT` / `ACTION_OPEN_DOCUMENT` intents and streaming bytes to/from `.nmflat` document URIs without third-party cloud SDKs.

##### 6. `lib/l10n/app_en.arb` (Create)
*   **Type / Scope:** Application localization strings (ICU placeholders and plurals).
*   **Proposed Changes:** Define all user-visible strings prefixed by feature (`common*`, `home*`, `sync*`, `todos*`, `shopping*`, `maid*`, `expenses*`, `meals*`, `backup*`, `debug*`) so zero UI text is hardcoded in Dart.

##### 7. `lib/core/design/components/nest_card.dart`, `nest_button.dart`, `nest_chip.dart`, `nest_empty_state.dart`, `nest_sync_badge.dart` (Create)
*   **Type / Scope:** Shared Material 3 / `NestColors` UI component library.
*   **Proposed Changes:** Build reusable components reading exclusively from `context.nest` and `Theme.of(context).colorScheme` (`NestCard`, `NestButton`, `NestChip`, `NestEmptyState`, `NestSyncBadge` showing per-member "Last synced" freshness and clock-skew warnings), enforcing `>= 48 dp` touch targets, `tooltip`/`Semantics(label:)` on icon-only controls, and wrapping layouts at font scale `2.0`.

##### 8. `lib/core/providers.dart`, `lib/core/router.dart`, and `lib/main.dart` (Create / Modify)
*   **Type / Scope:** Application bootstrap, Riverpod 3 provider registry, and `go_router` 18 navigation shell.
*   **Proposed Changes:** Define app-wide providers in `lib/core/providers.dart` (`appDatabaseProvider`, `changesProvider`, `currentHomeProvider`, `currentMemberProvider`, `themeModeProvider`, `lanSyncControllerProvider`, `backupServiceProvider`); configure `GoRouter` in `lib/core/router.dart` with bottom-navigation shell routes (`/shopping`, `/todos`, `/maid`, `/expenses`, `/meals`), onboarding (`/setup`), settings/backup (`/settings`), and `kDebugMode`-gated `/debug`; update `lib/main.dart` to wrap `MyApp` in `ProviderScope` with `MaterialApp.router`, `AppLocalizations`, and persisted Light/Dark `ThemeMode` while preserving the `MyApp` class name.

---

#### Milestone 1 (M1): Pure Domain Core, Drift Sync Engine, Todos, & Shopping Lists

##### 9. `lib/core/domain/money.dart` (Create)
*   **Type / Scope:** Pure Dart currency formatting & paise math.
*   **Proposed Changes:** Implement `Money.format(int paise)` producing Indian grouping with `₹` (`₹1,23,456` / `₹1,234.50`), sign handling for adjustments, and safe string-to-paise parsing without floating-point drift.

##### 10. `lib/core/domain/hlc.dart` (Create)
*   **Type / Scope:** Pure Dart Hybrid Logical Clock.
*   **Proposed Changes:** Define immutable `Hlc(int physicalMs, int counter, String deviceId)` with fixed-width sortable wire encoding (`<13-digit-ms>-<5-hex-counter>-<device_id>`, 20-bit counter to prevent bulk-write overflow), total ordering (`compareTo`), local wall-clock jump/regression clamping (`tickLocal`, `observeRemote` without ever rewriting accepted wire HLCs), and skew check (`isWithinSkew(remoteWallMs, localWallMs, maxSkewMs)`).

##### 11. `lib/core/domain/merge_engine.dart` (Create)
*   **Type / Scope:** Pure Dart deterministic CRDT merge rules.
*   **Proposed Changes:** Implement pure merge functions for: (a) Field-LWW ordering by `(fieldLamportVer, hlc, originDeviceId)` with tombstone payload-stripping spec, (b) PN-Counter element-wise `max(pVal)`/`max(nVal)` merge with read-only frozen slots for restored `device_id`s, (c) append-only superseding financial leaf resolution (`resolveActiveRevision(entriesByGroupId)` + 1-to-1 `void_key` deduplication), and (d) deterministic no-op detection (returns `changed: bool` so `local_seq` only increments when state actually mutates).

##### 12. `lib/core/domain/write_policy_gate.dart` (Create)
*   **Type / Scope:** Pure Dart centralized governance & role resolver.
*   **Proposed Changes:** Define exact Owner vs. Member permission matrix (`canInviteMember`, `canRemoveMember`, `canChangeRole`, `canEditMaidConfig`, `canSettleMaidPayroll`), deterministic last-owner resolution on concurrent mutual demotions (earliest `promotedAt`, tie-broken by lexicographical `memberId`), and `role_epoch` stale-authority detection returning `Apply | Quarantine`.

##### 13. `lib/core/domain/recurrence_engine.dart` (Create)
*   **Type / Scope:** Pure Dart deterministic recurring schedule projector.
*   **Proposed Changes:** Project upcoming occurrences over a `[startDate, endDate]` window from structured recurrence rules (`freq: daily|weekly|monthly|custom_days`, `interval`, `daysOfWeek`, `dayOfMonth`, `endDate`), and compute deterministic occurrence IDs via `UUIDv5(namespace, "$templateId:$YYYY_MM_DD")` so concurrent offline completion/payment on multiple phones converges onto one row.

##### 14. `lib/core/data/db/tables/synced_columns.dart`, `sync_tables.dart`, `home_tables.dart`, `todo_tables.dart`, `shopping_tables.dart` (Create)
*   **Type / Scope:** Drift SQLite table definitions (`schemaVersion = 1`).
*   **Proposed Changes:** Define `SyncedColumns` mixin (`id`, `homeId`, `deleted`, `createdAt`, `createdBy`, `updatedAt`, `updatedBy`, `updatedHlc`) with all non-key columns nullable or defaulted and zero `ON DELETE CASCADE` foreign keys; define `sync_ops`, `field_clocks`, `pn_counters`, `quarantined_ops`, `device_identity`, `peer_cursors`, `sync_events`, `homes`, `home_members`, `todo_templates`, `todos`, `shopping_stores`, and `shopping_items` (with atomic `quantity_unit_json` and `checked` separate from `deleted`), plus composite indexes on `(home_id, deleted, ...)`.

##### 15. `lib/core/data/db/app_database.dart`, `collection_registry.dart`, and `drift_schemas/drift_schema_v1.json` (Create)
*   **Type / Scope:** Drift database configuration, WAL setup, registry, and schema snapshot.
*   **Proposed Changes:** Configure `@DriftDatabase` with WAL mode (`PRAGMA journal_mode=WAL; PRAGMA busy_timeout=5000`), register all synced tables in `CollectionRegistry` (mapping table names to row materializers, tombstoned payload strippers, and owner-guarded flags), and export committed Drift schema snapshot for `SchemaVerifier` migration tests.

##### 16. `lib/core/data/change_writer.dart` (Create)
*   **Type / Scope:** Single transactional write gateway for all synced tables.
*   **Proposed Changes:** Expose `Future<ChangeResult> write(String label, void Function(ChangeBatch c) build)` enforcing `WritePolicyGate`, advancing local HLC, inserting into `sync_ops`, updating `field_clocks`/`pn_counters`, materializing domain rows inside one `BEGIN IMMEDIATE` transaction, and returning `ChangeResult(undoToken)` plus `Future<void> undo(UndoToken token)` emitting compensating forward ops (never deleting from `sync_ops`). Also expose `ingestRemoteBatch(List<SyncOp> ops, String? fromPeerDeviceId)` shared identically by LAN sync and SAF backup restore, persisting unknown `table_name`/`field_name` ops with `applied = 0`.

##### 17. `lib/features/home_setup/home_setup_screen.dart` and `home_setup_controller.dart` (Create)
*   **Type / Scope:** Onboarding flow (Create Home, Join Home, Restore from Backup).
*   **Proposed Changes:** Implement the welcome screen on `NestPatternBackground` (`#12201A` radial-dotted canvas), Create Home form (generating `home_id`, `home_sync_key`, first Owner `member_id`, `device_id`), and entry points to QR/PIN Join Home (wired in M2) and SAF Restore (wired in M3).

##### 18. `lib/features/shopping/shopping_screen.dart`, `shopping_controller.dart`, `shopping_parts.dart` (Create)
*   **Type / Scope:** Pilot Feature Module 1 — Online-app / offline-store grouped shopping lists.
*   **Proposed Changes:** Stream active `shopping_items` grouped by `shopping_stores` (with default `Any store` plus customizable online apps like Zepto and offline stores like DMart/Reliance Bazaar); quick-add with atomic `quantity + unit`, check-off vs. delete with snackbar Undo, store-group filter chips, "Last synced" freshness badge, and 1-tap plain-text "Share store list" export.

##### 19. `lib/features/todos/todos_screen.dart`, `todos_controller.dart`, `todos_parts.dart` (Create)
*   **Type / Scope:** Pilot Feature Module 2 — Assignable one-time and recurring todos.
*   **Proposed Changes:** Stream active `todos` + read-time projected occurrences from `todo_templates` via `RecurrenceEngine`; filter by assignee (`member_id`), due date, or status; completing/skipping a recurring occurrence materializes a deterministic-ID row via `ChangeWriter` with Undo support.

##### 20. `lib/features/debug/debug_screen.dart` and `debug_controller.dart` (Create)
*   **Type / Scope:** `kDebugMode`-only on-device observability hub (`/debug`).
*   **Proposed Changes:** Display `device_id`, `member_id`, `home_id`, local HLC, `hlc_clamp_count`/`max_observed_skew_ms`, `schemaVersion`, table active/tombstone/`sync_ops` counts, `peer_cursors`, `quarantined_ops`, bounded `sync_events` ring-buffer viewer + sanitized JSON export, per-collection SHA-256 state digests, and a dry-run `.nmflat` merge validator.

---

#### Milestone 2 (M2): Encrypted Home Wi-Fi LAN Pairing & Raw TCP Sync

##### 21. `lib/core/data/sync/lan_crypto.dart` and `lan_frame_codec.dart` (Create)
*   **Type / Scope:** X25519 + HKDF-SHA256 + AEAD session crypto and length-prefixed binary framing.
*   **Proposed Changes:** Implement mutual `HELLO_INIT`/`HELLO_RESP` transcript HMAC verification over `home_sync_key`, ephemeral X25519 key agreement, directional `XChaCha20-Poly1305` (or `AES-256-GCM`) session keys, monotonic frame counter nonces, and `[4-byte length][1-byte type][12-byte nonce][ciphertext+tag]` framing with strict `<= 1 MB` uncompressed chunk cap and socket timeouts.

##### 22. `lib/core/data/sync/lan_discovery_service.dart` (Create)
*   **Type / Scope:** Android `NsdManager` + `MulticastLock` bridge and manual `IP:port` fallback.
*   **Proposed Changes:** Wrap the Kotlin `MethodChannel` to advertise/browse `_illam._tcp` using only `h=<truncated_sha256(home_id || "illam-mdns-v1")>` and `p=<protocol_ver>` while foregrounded, releasing `MulticastLock` immediately on pause/background; expose manual `IP:port` + QR peer targeting when multicast is blocked by router AP isolation.

##### 23. `lib/core/data/sync/lan_sync_service.dart` (Create)
*   **Type / Scope:** Raw TCP sync state machine (`dart:io` `ServerSocket`/`Socket`).
*   **Proposed Changes:** Orchestrate QR/PIN home pairing handshake, glare resolution (lower `device_id` initiates), removed-member rejection, clock-skew check (`ERR_CLOCK_SKEW`), paginated outbound delta queries (`200–500` ops, `WHERE local_seq > last_acked_sent AND (received_from_device_id IS NULL OR received_from_device_id != peer_device_id)`), transactional `ChangeWriter.ingestRemoteBatch`, explicit `OPS_ACK` cursor commit, and structured `sync_events` logging keyed by `sync_session_id`.

##### 24. `lib/features/home_setup/pairing_screen.dart` and `pairing_controller.dart` (Create)
*   **Type / Scope:** Owner QR/PIN Invite, Join Home scanner, Member Management, & Sync Status UI.
*   **Proposed Changes:** Render expiring pairing QR + manual `IP:port`/PIN fallback for Owners; scan QR on joining device; manage member list (promote co-owner, remove member with explicit LAN key-rotation notice, review `quarantined_ops`); provide manual "Sync Now" action with actionable error states ("Not on Wi-Fi", "Peer app not open", "Router blocking discovery", "Clock skew detected").

---

#### Milestone 3 (M3): Passphrase-Encrypted Portable Backup & Restore (Android SAF)

##### 25. `lib/core/data/backup/backup_codec.dart` (Create)
*   **Type / Scope:** `.nmflat` archive serializer, Argon2id KDF, and AEAD envelope codec.
*   **Proposed Changes:** Encode/decode the plaintext authenticated header (`magic`, `format_version`, `app_schema_version`, `home_id`, Argon2id params, `salt`, `nonce`, `created_at_ms`, `op_count`) as AAD and encrypt/decrypt the gzipped JSONL payload (`home_sync_key` + `sync_ops` excluding all local-only tables) via `XChaCha20-Poly1305`.

##### 26. `lib/core/data/backup/backup_service.dart` (Create)
*   **Type / Scope:** SAF export/import coordinator with pre-restore snapshot and `device_id` rotation.
*   **Proposed Changes:** Export timestamped `illam_YYYYMMDD_HHMMSS.nmflat` files through the `MainActivity.kt` SAF channel (optionally caching derived export key in `flutter_secure_storage`); on restore, validate header/AEAD/`home_id`, copy local SQLite to a pre-restore safety snapshot, mint a brand-new `device_id` (preserving `member_id`), clear `peer_cursors`, mark restored PN-Counter slots read-only, ingest ops in chunked transactions through `ChangeWriter.ingestRemoteBatch`, and return a structured `RestoreMergeSummary`.

##### 27. `lib/features/settings_backup/settings_backup_screen.dart` and `settings_backup_controller.dart` (Create)
*   **Type / Scope:** Settings, Light/Dark theme switch, and Backup/Restore UI.
*   **Proposed Changes:** Persist Light/Dark `ThemeMode` in `shared_preferences`; guide backup passphrase/recovery-code setup, SAF export to Google Drive/OneDrive/local storage, and SAF restore with explicit merge-vs-rollback confirmation dialog and post-restore merge summary.

---

#### Milestone 4 (M4): Maid Attendance & Payroll + Manual Expenses, Splits, Budgets, & Bills

##### 28. `lib/core/domain/maid_salary_calculator.dart` (Create)
*   **Type / Scope:** Pure Dart Indian household maid payroll calculator.
*   **Proposed Changes:** Compute monthly salary breakdown in integer paise from effective-dated `maid_salary_rules` (`base_salary_paise`, `paid_leaves_per_month`, `fixed30` vs. `calendar_days` divisor), opt-in `maid_attendance` records keyed by `(maid_id, date, shift_slot)` (flagging any unlogged scheduled working days as "Unmarked"), and active `maid_ledger_entries` (advances, bonuses, deductions, manual overrides); compute deterministic `hasLateAttendanceAfterSettlement` warning flag by comparing `attendance_watermark_hlc`.

##### 29. `lib/core/domain/expense_split_calculator.dart` (Create)
*   **Type / Scope:** Pure Dart paise-exact split allocator & monthly net balance calculator.
*   **Proposed Changes:** Compute equal and custom member split allocations in integer paise with deterministic remainder assignment (`sum(splits) == amount_paise`), monthly category budget spend (strictly excluding `entry_kind == settlement`), and monthly "who owes whom" net summary per member.

##### 30. `lib/core/data/db/tables/maid_tables.dart` and `expense_tables.dart` (Create; Update `app_database.dart` to `schemaVersion = 2` + `drift_schemas/drift_schema_v2.json`)
*   **Type / Scope:** Drift tables and additive migration for Maid and Expenses modules.
*   **Proposed Changes:** Add `maids`, `maid_salary_rules`, `maid_attendance`, `maid_ledger_entries`, `expense_categories`, `budgets`, `recurring_bill_templates`, and `expense_entries` (embedding atomic `splits_json`, `entry_group_id`, `supersedes_id`, `void_key`, `entry_kind`, optional weak `source_ref`); add additive migration step in `AppDatabase.migration` and register tables in `CollectionRegistry`.

##### 31. `lib/features/maid/maid_screen.dart`, `maid_detail_screen.dart`, `maid_controller.dart`, `maid_parts.dart` (Create)
*   **Type / Scope:** Feature Module 3 — Maid directory, multi-shift entry/exit logging, and monthly salary settlement.
*   **Proposed Changes:** Owner-guarded CRUD for maid profiles and effective-dated salary rules; daily opt-in check-in/check-out per shift slot (`default` / `morning` / `evening`); monthly payroll breakdown highlighting unmarked working days, advances/bonuses/deductions/overrides, late-attendance warning badges, and settlement payout action with default-ON toggle to also create a decoupled Expense entry.

##### 32. `lib/features/expenses/expenses_screen.dart`, `expenses_controller.dart`, `expenses_parts.dart` (Create)
*   **Type / Scope:** Feature Module 4 — Manual expenses, recurring bills, budgets, and splits.
*   **Proposed Changes:** Expense entry/edit/void flow backed by append-only superseding snapshots (showing clean folded "Edited" history indicator instead of raw reversing math); equal/custom split editor; monthly category budget progress bars; upcoming recurring bill projections (materialized with editable actual amount on "Mark Paid"); monthly member net summary + "Settle up" action; wire optional 1-tap "Log as Expense" handoff from `shopping_screen.dart`.

---

#### Milestone 5 (M5): Meal Planner & Recipes + Polish

##### 33. `lib/core/data/db/tables/meal_tables.dart` (Create; Update `app_database.dart` to `schemaVersion = 3` + `drift_schemas/drift_schema_v3.json`)
*   **Type / Scope:** Drift tables and additive migration for Meals & Recipes module.
*   **Proposed Changes:** Add `recipes` (title, instructions, servings), `recipe_ingredients` (name, quantity_unit_json, optional default_store_id), and `meal_plan_entries` (`date`, `slot: breakfast|lunch|snack|dinner`, nullable `recipe_id`, nullable `free_text`); add additive migration step in `AppDatabase.migration` and register in `CollectionRegistry`.

##### 34. `lib/features/meals/meals_screen.dart`, `recipe_detail_screen.dart`, `meals_controller.dart`, `meals_parts.dart` (Create)
*   **Type / Scope:** Feature Module 5 — Weekly meal grid, recipe book, and 1-tap ingredient push to Shopping Lists.
*   **Proposed Changes:** Render 7-day meal grid accepting either saved recipes or free-text entries ("Leftovers", "Ordering in"); recipe editor with text instructions and structured ingredients; 1-tap "Add ingredients to Shopping List" copying self-contained rows into `shopping_items` with weak `source_ref` (`recipe:<id>`) and selectable target store group.

---

#### Automated Test Suite (Mirrors `lib/` Paths)

##### 35. `test/core/domain/money_test.dart`, `hlc_test.dart`, `merge_engine_test.dart`, `write_policy_gate_test.dart`, `recurrence_engine_test.dart`, `maid_salary_calculator_test.dart`, `expense_split_calculator_test.dart` (Create)
*   **Type / Scope:** Pure Dart domain unit tests (zero Flutter dependencies).
*   **Proposed Changes:** Verify Indian paise formatting, HLC clamping/sorting/counter overflow, Field-LWW + PN-Counter + superseding financial snapshot convergence, last-owner tie-breaking and `role_epoch` quarantine, deterministic `UUIDv5` recurrence IDs, opt-in maid salary math (unmarked days, paid leaves, fixed30 vs. calendar days, effective-dated raises, late-attendance watermark warnings), and paise-exact split remainder sums.

##### 36. `test/core/data/sync/multi_node_sync_test.dart`, `lan_crypto_frame_test.dart`, `schema_migration_test.dart`, and `test/core/data/backup/backup_codec_test.dart` + `test/fixtures/backup_v1.nmflat` (Create)
*   **Type / Scope:** Multi-node CRDT simulation, wire crypto/framing, Drift migration, and golden backup tests.
*   **Proposed Changes:** Simulate 3+ in-memory Drift databases under randomized packet drop, duplication, out-of-order delivery, transitive forwarding (no echo loops), unknown-field pass-through across mixed app versions, delete Undo, and restore-with-fresh-`device_id` asserting bit-for-bit identical materialized state and SHA-256 digests; verify X25519/AEAD framing tamper rejection and clock-skew rejection; run Drift `SchemaVerifier` across `v1 -> v2 -> v3`; commit golden `backup_v1.nmflat` fixture verifying decryption, wrong-passphrase rejection, bit-flip AAD tamper rejection, and bidirectional merge.

##### 37. `test/features/*_screen_test.dart` and `test/widget_test.dart` (Create / Modify)
*   **Type / Scope:** Flutter widget and accessibility tests.
*   **Proposed Changes:** Update `test/widget_test.dart` for the `ProviderScope` + `GoRouter` shell; add widget tests for each feature screen verifying loading/empty/error states, Owner role guard visibility, Light/Dark theme switching, `>= 48 dp` tap targets, and zero layout overflow at `textScaler: TextScaler.linear(2.0)`.

### Verification Plan

*   **Code Generation & Localization:** `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`, and `flutter gen-l10n` complete with exit code `0`.
*   **Static Analysis & Linting:** `flutter analyze` passes with `0` errors and `0` warnings (no `// ignore` suppressions or weakened lints).
*   **Unit, CRDT Simulation, Migration, & Widget Tests:** `flutter test` passes across all pure domain tests, 3-node randomized CRDT/sync simulations, Drift `SchemaVerifier` (`v1 -> v2 -> v3`) migration tests, golden `.nmflat` crypto/restore tests, and font-scale `2.0` widget tests (`>= 85%` line/branch coverage on `lib/core/domain/` and `lib/core/data/sync/`).
*   **Android Release Build Check:** `flutter build apk --release` succeeds with `applicationId = io.github.pvkarthikk.illam`, `android:allowBackup="false"`, and zero Location/cleartext permissions.
*   **Physical Android Device Soak Checklist (M2 & M3):** Run on two physical Android phones on home Wi-Fi (testing mDNS discovery, manual `IP:port` fallback, mid-batch Wi-Fi toggle recovery, airplane-mode divergence + reconnect, clock-skew banner, and SAF `.nmflat` round-trip via Google Drive and local storage verifying identical `/debug` state digests).

--------------------------------------------------------------------------------

<!-- Provenance: Indicates initial structural drafting via EGM. -->

*Drafted with EGM*


