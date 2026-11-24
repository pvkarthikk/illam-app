# Illam: Offline-First Household Management & Local Wi-Fi Sync

*   **Author:** Karthik Venkatesh
*   **Status:** Approved
*   **Date:** 2026-11-22

--------------------------------------------------------------------------------

## Overview

Illam is an Android-first, offline-first household management application for Indian flats and nuclear families. Every household member holds a complete local copy of the flat's data on their own phone and synchronizes directly with other family phones over the home Wi-Fi network—with no cloud backend, no user accounts, and no recurring server hosting costs.

Version 1 covers five text-and-number household workflows in one app: assignable one-time and recurring todos, store- and app-grouped shopping lists, domestic help (maid) attendance and adjustable monthly salary calculation, manual household expenses with recurring bills, budgets, and splits, and a weekly meal planner backed by recipes and ingredients. Every member can independently export a passphrase-encrypted backup file through Android's system file picker to Google Drive, OneDrive, or local storage and restore it onto a replacement phone with deterministic bidirectional conflict resolution upon reconnecting to home Wi-Fi.

## The Problem

Running a shared household involves five tightly intertwined daily routines: tracking chores, assembling grocery orders split across quick-commerce apps (Zepto, Blinkit) and physical stores (DMart, Reliance Bazaar), logging domestic help entry/exit times and calculating accurate monthly salaries after leaves and advances, recording shared expenses and monthly bills, and planning meals with recipes.

Today, households scatter these workflows across WhatsApp chats, generic note apps, spreadsheets, and paper notebooks, or adopt cloud-hosted apps that require per-user accounts, expose sensitive personal data (maid phone numbers, home addresses, daily entry/exit presence logs, and household spending) to third-party servers, and fail when internet connectivity is poor.

Solving this purely on-device without a central server introduces four hard problems that naive local apps break on:
1. **Offline divergence:** Multiple family members edit shared lists, expenses, and attendance logs independently while offline and need deterministic convergence without silently dropping money entries or duplicating recurring bills.
2. **Untrusted shared Wi-Fi and Android background limits:** Apartment Wi-Fi networks are not private boundaries, consumer routers often block multicast discovery, and Android Doze/OEM battery killers terminate silent background sockets.
3. **Backup restore collisions:** Restoring an older cloud backup onto a replacement phone can silently drop newer writes, swallow counter increments, or resurrect deleted items across every family phone unless device identity, cursors, and tombstones are isolated from backups.
4. **Role administration without a server:** Restricting membership changes and maid salary edits to home owners must avoid zero-owner lockouts and stale offline role overwrites.

Illam solves these problems by combining a single local SQLite op-log and deterministic merge engine with owner-paired encrypted home Wi-Fi sync, centralized app-level role guards, and passphrase-encrypted portable backups via Android Storage Access Framework (SAF).

## Goals

*   **Zero-server, offline-first daily operation:** All five household modules (todos, shopping lists, maid attendance/payroll, expenses/bills/budgets/splits, and meal planner/recipes) work fully offline on Android with immediate local reads and writes (`< 100 ms` local UI updates) and no user accounts or cloud backend.
*   **Full-copy home replication over encrypted home Wi-Fi:** Pairing devices via owner-initiated QR (with manual Base32 token + `IP:port` fallback) creates an encrypted LAN sync channel (`NsdManager` with manual `IP:port` fallback) that converges all phones on the same Wi-Fi deterministically, with zero lost financial records and zero duplicate machine-generated recurring items.
*   **Safe bidirectional backup and restore:** Any member can export a passphrase-encrypted `.nmflat` archive via Android SAF (supporting Google Drive, OneDrive, Dropbox, Nextcloud, and local storage with zero cloud SDKs), restore it onto a replacement phone with a newly minted `device_id`, and merge bidirectionally on home Wi-Fi so the newest state wins without resurrecting tombstoned deletions.
*   **Accurate Indian household payroll and paise-exact finances:** Store all currency in integer paise (`₹1 = 100`, Indian grouping), compute monthly maid salary transparently from opt-in attendance logs, configurable paid-leave quotas, effective-dated base salary, and manual adjustments/advances, and keep expense totals and member splits mathematically exact (`sum(splits) == total`).
*   **Transparent sync UX and on-device debuggability:** Surface per-member "Last synced" freshness, clock-skew and discovery error prompts with recovery actions, a 1-tap plain-text "Share store list" export for away-from-home shopping, and a `kDebugMode`-only `/debug` diagnostics hub with sync session logs and state digests.
*   **Incremental, verified delivery:** Ship via six vertical milestones (`M0–M5`) backed by multi-node in-memory CRDT simulation tests, step-by-step Drift schema migration tests, and encrypted backup golden-file tests.

## Non-Goals

*   **Away-from-home cellular / mobile-network sync:** Deferred out of v1. Edits made outside home Wi-Fi queue locally and sync when devices reconnect on home Wi-Fi.
*   **Media and file attachments:** No photos, bill receipts, recipe images, or maid ID-proof scans in v1; all data is strictly text, numbers, and dates.
*   **iOS support:** Production v1 targets Android only (`io.github.pvkarthikk.illam`); iOS is deferred until user demand or funding justifies it.
*   **Cryptographic sync-layer RBAC:** v1 assumes cooperative family members and uses centralized app-level owner guards with stale-authority flagging rather than per-operation cryptographic signatures against rooted or malicious devices.
*   **Native cloud provider SDKs or live cloud sync:** No Google Drive API, Microsoft Graph/OneDrive SDK, OAuth app verification, or using personal cloud storage as a live sync relay.
*   **Multi-currency accounting or Splitwise-style debt-simplification graphs:** Expenses use INR (`₹`) with equal/custom splits and a monthly net summary, excluding settlement transfers from monthly spending budgets.

## Open Questions

*   **Bundling custom font assets (`.ttf`) [Escalated for author choice]:** `lib/core/design/nest_theme.dart` currently specifies `Hanken Grotesk` and `Young Serif` with system fallbacks (`Segoe UI`/`sans-serif`, `Iowan Old Style`/`Georgia`/`serif`), while `pubspec.yaml` does not bundle `.ttf` files. Milestone 0 proceeds with the existing `NestTheme` fallback configuration unless `.ttf` files are committed under `assets/fonts/` before M0 execution.

## Critical User Journeys (CUJs)

### CUJ 1: Create Home and Pair a Family Member Over Home Wi-Fi

*   **Given**: Two Android phones (`Phone A` and `Phone B`) are connected to the same home Wi-Fi network, and neither has an active home configured.
*   **When**: User A creates a home ("Flat 402"), becoming the first Owner, and opens "Invite member" to display a pairing QR code (with manual Base32 pairing token + `IP:port` fallback). User B selects "Join home", scans the QR code, and enters their member name.
*   **Then**: Both phones establish an authenticated encrypted LAN session using the exchanged 256-bit `home_sync_key`, Phone B receives a paginated full snapshot of the home data, both devices display each other as paired members with a fresh "Last synced" timestamp, and no Location permission prompt or plaintext LAN broadcast of sensitive home data occurs.

### CUJ 2: Concurrent Offline Shopping & Todo Edits Converging on Home Wi-Fi

*   **Given**: User A and User B have synced phones. Both go offline. On the same shopping item ("Milk", grouped under `Zepto`), User A changes the store group to `DMart` while User B marks `checked = true`. Separately, both phones cross midnight on a recurring daily todo ("Switch off geyser").
*   **When**: Both users return home and open Illam on home Wi-Fi (or tap "Sync now").
*   **Then**: Chunked transactional sync merges the shopping item via Field-LWW so both changes converge deterministically without overwriting unrelated fields, the recurring daily todo appears once (not duplicated) via deterministic occurrence keying, and both phones show identical canonical materialized state and matching state digests.

### CUJ 3: Maid Daily Attendance, Adjustable Monthly Salary, and Optional Expense Logging

*   **Given**: An Owner has added a maid with contact details, address, scheduled working days, effective-dated monthly base salary, paid-leave quota, and salary divisor (`fixed30` vs. `calendar_days`). Over the month, members log morning/evening entry/exit times and record a ₹500 salary advance offline.
*   **When**: At month end, the Owner opens the Maid Payroll view, inspects the live computed salary breakdown (base salary, unmarked days, excess-leave deductions, advances), applies a ₹200 festival bonus adjustment, and records the final salary payout with "Also add to expenses" enabled.
*   **Then**: An immutable payout ledger entry is recorded along with a decoupled Expense entry referencing it weakly; if another phone later syncs a missed absence from three days prior, the app preserves the payout history and surfaces a visible warning badge indicating late attendance arrived after settlement.

### CUJ 4: Manual Expense Entry, Splits, Typo Correction, and Budgets

*   **Given**: A monthly household budget is set for Groceries and Utilities, and a recurring monthly electricity bill template exists. User A logs a ₹5,000 grocery expense split equally across 3 members, then realizes the amount should be ₹500 while User B also spots the typo offline.
*   **When**: Both users edit the mistyped expense to ₹500 offline and later sync over home Wi-Fi.
*   **Then**: Each expense stores its total and paise-exact split allocation (`16667 + 16667 + 16666 = 50000` paise) atomically inside an immutable row, both offline typo fixes emit superseding snapshots under the same `entry_group_id` that converge to a single active ₹500 expense (never double-reversing to `-₹4,000`), and monthly budget totals reflect only active expenses (excluding member settlement transfers).

### CUJ 5: Meal Planning and One-Tap Recipe Ingredients to Shopping List

*   **Given**: User A has saved a "Paneer Bhurji" recipe with text instructions and ingredients, and planned Tuesday Dinner as "Paneer Bhurji" and Wednesday Lunch as free-text "Leftovers".
*   **When**: User A taps "Add ingredients to shopping list" on the planned meal, picks a target store group (or leaves as `Any store`), and later deletes the "Paneer Bhurji" recipe.
*   **Then**: Self-contained shopping item copies (with weak `source_ref` IDs) appear under the chosen store group immediately; deleting the recipe tombstones only the recipe without crashing or deleting the shopping items already added.

### CUJ 6: Encrypted Personal Backup via SAF and Bidirectional Restore Merge

*   **Given**: User A previously exported a passphrase-encrypted `.nmflat` backup file to personal Google Drive via Android SAF on Day 10. On Day 14, User A's phone breaks, while User B has deleted two shopping items and added three expenses on Days 11–14.
*   **When**: User A installs Illam on a replacement Android phone, selects "Restore from backup", picks the `.nmflat` file from Google Drive via SAF, enters the backup passphrase, and later syncs with User B on home Wi-Fi.
*   **Then**: Restore validates `home_id` and the AEAD tag, mints a new `device_id` (keeping User A's existing `member_id`), clears peer cursors, and merges with User B on Wi-Fi so User B's Day 11–14 expenses appear on User A's phone, User B's tombstoned deletions stay deleted (never resurrected), and any newer edits from the backup propagate cleanly to User B.

--------------------------------------------------------------------------------

## Technical Plan (Architecture)

### 1. System Architecture & Module Boundaries

The application follows a three-layer separation aligned with `AGENTS.md`: pure-Dart domain logic with zero Flutter/Drift imports (`lib/core/domain/`), a single SQLite/Drift persistence and sync engine (`lib/core/data/`), and feature UI/Riverpod controllers (`lib/features/`). All writes to synced tables pass exclusively through `ChangeWriter`; feature screens read reactive Drift `watch()` streams exposed via Riverpod `StreamProvider`s.

```text
+-------------------------------------------------------------------------------+
|  UI & Feature Controllers (lib/features/* — Riverpod 3 Notifier/Stream)       |
|  home_setup | todos | shopping | maid | expenses | meals | settings_backup    |
|  debug (kDebugMode only)                                                      |
+-----------------------------+-----------------------------+-------------------+
                              | writes (ChangeWriter)       | reads (watch())
                              v                             |
+-----------------------------------------------------+     |
|  Pure Domain Layer (lib/core/domain/ — zero Flutter)|     |
|  WritePolicyGate | Hlc | MergeEngine | Money (INR)  |     |
|  MaidSalaryCalculator | RecurrenceEngine | Splits   |     |
+-----------------------------+-----------------------+     |
                              | validated ops               |
                              v                             |
+-------------------------------------------------------------------------------+
|  Local Persistence & Sync Core (lib/core/data/ — Drift / SQLite WAL)          |
|  +-----------------------+    +--------------------------------------------+  |
|  | ChangeWriter          |--->| sync_ops (local_seq, op_id, hlc, ...)      |  |
|  | (single transaction)  |--->| field_clocks | pn_counters                 |  |
|  +-----------------------+    | materialized domain tables (5 modules)     |<-+
|                               +--------------------+-----------------------+  |
|                                                    |                          |
|        +-------------------------------------------+--------------+           |
|        v                                                          v           |
|  +--------------------------------------+   +-------------------------------+ |
|  | LanSyncService (Home Wi-Fi Only)     |   | BackupService (Android SAF)   | |
|  | - NsdManager + MulticastLock         |   | - Argon2id (Isolate.run)      | |
|  | - Manual IP:port / Base32 fallback   |   | - XChaCha20-Poly1305 (24B)    | |
|  | - Raw TCP + X25519 + ChaCha20 (12B)  |   | - Timestamped .nmflat file    | |
|  | - 250-op chunks + ACK cursors        |   | - New device_id on restore    | |
|  +--------------------------------------+   +-------------------------------+ |
+-------------------------------------------------------------------------------+
```

### 2. Identity Model (`home_id`, `member_id`, `device_id`)

Three distinct identifiers prevent phone replacements and backup restores from corrupting household state:

*   **`home_id` (UUIDv4):** Identifies the household. Generated once on "Create home" and validated on every LAN handshake and backup restore envelope.
*   **`member_id` (UUIDv4):** Identifies a human household member. Referenced by todo assignees, expense payers/splits, and owner roles. Survives phone loss and backup restore. Members transition `status` from `'active'` to `'removed'` rather than hard-deleting so historical financial and attendance records remain intact.
*   **`device_id` (UUIDv4):** Identifies one specific Android installation. Used strictly for HLC lexicographical tie-breaking, PN-Counter actor slots, and `peer_cursors`. Stored only in the local-only `device_identity` table, never exported as active identity in cloud backups, and **always rotated to a new UUID on backup restore or reinstall**.

### 3. Local Persistence & Unified Sync Storage (Drift / SQLite WAL)

SQLite runs in WAL mode (`PRAGMA journal_mode=WAL`, `PRAGMA busy_timeout=5000`). Hard SQL `FOREIGN KEY ... ON DELETE CASCADE` constraints are prohibited across synced tables so out-of-order sync arrival and permanent tombstones never trigger referential crashes; read queries handle missing or soft-deleted references safely.

#### Core Sync & Local-Only Tables

| Table | Scope | Purpose & Key Columns |
| --- | --- | --- |
| `sync_ops` | Synced / Backed up | Append-only local op log: `local_seq` (`INTEGER PRIMARY KEY AUTOINCREMENT`), `op_id` (`TEXT UNIQUE`), `home_id`, `table_name`, `row_id`, `op_type` (`set`/`inc`/`tombstone`/`append`), `field_name`, `payload_json`, `hlc`, `field_lamport_ver`, `origin_device_id`, `actor_member_id`, `role_epoch`, `schema_ver`, `received_from_device_id`, `applied` (`0`/`1`). |
| `field_clocks` | Materialized CRDT state | Tracks winning `(field_lamport_ver, hlc, origin_device_id)` per `(table_name, row_id, field_name)` for O(1) Field-LWW comparisons during merge. |
| `pn_counters` | Materialized CRDT state | Tracks per-actor `(p_val, n_val, frozen)` per `(table_name, row_id, field_name, actor_device_id)`. Merge takes element-wise `max(p_val)` and `max(n_val)`. |
| `quarantined_ops` | Local diagnostic / review | Stores incoming synced ops whose `role_epoch` or `actor_member_id` failed owner-authority validation at write time, surfaced for Owner review. |
| `device_identity` | Local-only (unsynced) | Holds current `device_id`, `member_id`, `home_id`, local HLC state (`last_hlc`), `hlc_clamp_count`, and `max_observed_skew_ms`. `home_sync_key` is stored separately in `flutter_secure_storage`. |
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
    *   Returns `ChangeResult(undoToken, emittedOps)` referencing the previous local state.
4.  Invoking **Undo** never deletes rows from `sync_ops`. Instead, it emits forward compensating ops inside a fresh transaction (restoring the previous Field-LWW value—including any stripped `notes`/`instructions` captured in the local `UndoToken`—or setting `deleted = false` at a higher `(field_lamport_ver, hlc)`, posting an inverse PN-Counter delta, or appending a superseding/void financial snapshot).
5.  **Cross-version forward compatibility:** If an incoming op references an unrecognized `table_name` or `field_name` from a newer app version, the ingest pipeline still stores it in `sync_ops` with `applied = 0` so the device relays it to other phones intact. On app upgrade, `AppDatabase.migration.beforeOpen` replays `SELECT * FROM sync_ops WHERE applied = 0 ORDER BY local_seq ASC` through `ChangeWriter.ingestRemoteBatch` to materialize newly supported rows automatically.

### 4. Domain Data Model & CRDT Classification Matrix

All currency values are stored as integer paise (`int`, `₹1 = 100`) and formatted with Indian grouping (`₹1,23,456`). Dates use local `YYYY-MM-DD` strings; instants use epoch milliseconds (`int`). SQL/wire/JSON identifiers use `snake_case`; Dart identifiers and method signatures use `camelCase`.

| Merge Class | Domain Tables / Fields | Merge & Domain Invariants |
| --- | --- | --- |
| **Field-LWW + Permanent Tombstone Row** | `homes`, `home_members`, `todo_templates`, `todos`, `shopping_stores`, `shopping_items` (`name`, `store_id`, `checked`, atomic `quantity_unit_json`, `notes`), `maids` (contact details), `maid_salary_rules` (effective-dated base salary, `working_days_mask`, `shift_slots_per_day`, paid leaves/month, `fixed30` vs. `calendar_days`), `maid_attendance` (deterministic `id = "$maidId:$date:$shiftSlot"` with atomic `status_times_json`), `expense_categories`, `budgets`, `recurring_bill_templates`, `recipes`, `recipe_ingredients`, `meal_plan_entries` (deterministic `id = "$date:$slot"`, `recipe_id` or `free_text`) | Winning write chosen by lexicographical max of `(field_lamport_ver, hlc, origin_device_id)`. Tightly coupled fields (maid `status + entry_time + exit_time`; shopping `quantity + unit`) are stored as single atomic JSON LWW fields so invalid hybrid states cannot occur. Rows are never hard-deleted (preventing old-backup resurrection); on `deleted = true`, heavy text columns (`notes` on `todos`/`shopping_items`/`expense_entries`/`maid_ledger_entries` and `instructions` on `recipes`) are cleared to bound SQLite growth. |
| **PN-Counter (Restricted)** | Reserved strictly for unitless relative `+1`/`-1` integer counters (if introduced for tally counters) | Stored in `pn_counters` per `actor_device_id`. Historical `device_id` slots from restored backups have `frozen = 1`; new deltas write only to the new `device_id`. Not used for mixed-unit shopping quantities or financial amounts. |
| **Append-Only Immutable (Superseding Snapshots)** | `expense_entries` (atomic `amount_paise`, `payer_member_id`, `splits_json`, `entry_kind: expense|settlement`, `entry_group_id`, `supersedes_id`, `void_key`), `maid_ledger_entries` (advances, bonuses, deductions, payouts, manual overrides with `entry_group_id`, `supersedes_id`, `void_key`, `attendance_watermark_hlc`) | Rows never mutate in place. Editing a mistyped expense or maid entry appends a new row referencing `supersedes_id` under the same `entry_group_id`; active totals read only the winning leaf revision per `entry_group_id` (max `(hlc, origin_device_id)` among non-voided leaves; concurrent fixes to ₹500 converge to ₹500). Deletions use a deterministic 1-to-1 `void_key` (`void:<entry_group_id>`), winning if its `hlc` exceeds the latest leaf `hlc`. Splits allocate remainder paise deterministically (`sum(splits) == amount_paise`). Settlements are excluded from monthly budgets. |
| **Read-Time Derived Projections (Unsynced)** | Upcoming recurring todos, upcoming recurring bills, live monthly maid salary owed, monthly budget remaining, monthly net split balances | Computed dynamically in `lib/core/domain/` from synced rules and ledger rows. Materializing a recurring occurrence (completing a chore or paying a bill) writes a row with deterministic ID `UUIDv5(kRecurrenceNamespaceUuid, "$templateId:$dateIso")` so offline peers never create duplicate occurrences. |

#### Cross-Module Decoupling Rules
*   **Recipes → Shopping Lists:** 1-tap "Add ingredients to shopping list" copies ingredient rows into `shopping_items` with an optional weak `source_ref` (`recipe:<id>`). Deleting the recipe never affects the shopping list.
*   **Shopping Lists → Expenses:** User-selectable 1-tap "Log as expense" after a store run creates a standalone `expense_entries` row referencing the store tag.
*   **Maid Payout → Expenses:** Recording a monthly salary payout offers a toggle (enabled by default) that writes both the `maid_ledger_entries` payout row and a decoupled `expense_entries` row with weak `source_ref` (`maid_payout:<id>`).
*   **Maid Override Warning & Opt-In Attendance:** Maid attendance is strictly **opt-in**: only dates with an explicit logged entry (`present` or `half_day`, with entry/exit timestamps) count as worked days alongside configured paid-leave allowances; any unlogged scheduled working days (derived from `maid_salary_rules.working_days_mask`) are highlighted as "Unmarked" in the monthly payroll view so the user can backfill or mark explicit absences before settlement. When an Owner records a manual salary override or payout, it captures `attendance_watermark_hlc` (max HLC across that maid's month attendance and ledger rows). If a synced attendance edit or advance for that month arrives later with a newer HLC, the UI preserves the historical payout and shows a visible reconciliation warning badge.

### 5. Owner Role Governance & Conflict Safety

*   **Centralized Policy Gate:** All owner-only actions (invite/remove member, promote/demote owner, edit `homes.name`, create/edit/delete `maids` and `maid_salary_rules`, record manual salary overrides and salary payouts) pass through `WritePolicyGate` inside `ChangeWriter`, never ad-hoc UI checks alone. All active members may manage todos, shopping items/stores, daily maid attendance, maid advances/bonuses/deductions, expenses, budgets, recurring bills, and meals/recipes.
*   **Deterministic Last-Owner Invariant:** Multiple owners are supported. If two offline owners mutually demote each other, the role resolver guarantees at least one active owner by deterministically preserving the owner with the earliest `promoted_at` (tie-broken by lexicographical `member_id`). If the sole owner's phone is permanently lost, remaining members recover ownership via the explicit "Start new home from backup (claim ownership)" restore option in `BackupService`.
*   **Stale-Authority Flagging:** Every owner-guarded op carries `role_epoch` (stored on `homes.role_epoch` and incremented on every membership role change). If an incoming op was written by a member whose role was demoted or under an older `role_epoch`, the merge engine records it in `quarantined_ops` and notifies owners to dismiss it or accept it (which re-emits a fresh Owner-authored op via `ChangeWriter`) without stalling sync convergence.
*   **Removed Member Boundary:** The LAN handshake rejects `member_id` values with `home_members.status == 'removed'`. Because v1 does not use cryptographic sync-layer RBAC, removing a member displays an explicit notice that rotating `home_sync_key` (re-pairing remaining phones via QR) is required to cut off an uncooperative device.

### 6. Home Wi-Fi Discovery & Encrypted Raw TCP Sync Protocol

#### Pairing Ceremony (Create / Join Home)
1.  "Create home" generates `home_id`, a 256-bit random `home_sync_key` (stored in `flutter_secure_storage`), `member_id` (`role = 'owner'`, `status = 'active'`), and `device_id`.
2.  "Invite member" starts the local TCP listener on an ephemeral port and displays a QR code—plus a copy-pasteable Base32-encoded pairing token fallback—encoding `{home_id, home_sync_key_b64, host_ip, port, pairing_nonce, expires_at_ms}` with a 5-minute TTL. `home_sync_key` is never broadcast over mDNS or sent in plaintext over Wi-Fi.
3.  The joining phone scans the QR code (or pastes the Base32 pairing token), validates `expires_at_ms`, saves `home_sync_key` in `flutter_secure_storage`, opens the encrypted TCP session, registers its new `member_id` + `device_id`, and pulls the initial paginated op stream.

#### Peer Discovery & Foreground Sync Trigger Model
*   **Discovery:** While the app is open on Wi-Fi, `LanSyncService` acquires a scoped `WifiManager.MulticastLock` and registers/browses `_illam._tcp` via Android `NsdManager`, placing only `h=<first 16 lowercase hex chars of SHA-256(home_id || "illam-mdns-v1")>` and `p=1` in TXT records (zero PII, zero SSID reads, zero Location permissions). If router AP isolation blocks multicast, users tap "Connect manually" and enter or scan a peer's `IP:port`.
*   **Sync Triggers:** Foreground opportunistic auto-sync whenever two home phones have the app open on Wi-Fi, plus a manual "Sync now" button showing an in-app progress banner while a transfer runs. No background daemon or Android `FOREGROUND_SERVICE_DATA_SYNC` service is used in v1 (avoiding `POST_NOTIFICATIONS` prompts and OEM Doze background failures).
*   **Glare Resolution:** If Device A and Device B discover each other simultaneously, the device with the lexicographically lower `device_id` acts as TCP initiator and the higher `device_id` acts as listener.

#### Wire Protocol (Raw TCP + X25519 + RFC 8439 ChaCha20-Poly1305 Frames)

```text
Initiator (lower device_id)                         Listener (higher device_id)
---------------------------                         ---------------------------
1. TCP Connect (ephemeral port, 5s timeout) ------> Accept
2. Frame 0x01 HELLO_INIT {proto_ver: 1,
   schema_ver, home_id, device_id, member_id,
   eph_x25519_pub_a, nonce_a, wall_clock_ms_a,
   sync_session_id,
   mac_a = HMAC-SHA256(home_sync_key, canon_a)} --> Verify home_id, member status == 'active',
                                                    mac_a, and |clock diff| <= kMaxClockSkewMs
3. <---- Frame 0x02 HELLO_RESP {proto_ver: 1,
   schema_ver, device_id, member_id,
   eph_x25519_pub_b, nonce_b, wall_clock_ms_b,
   peer_last_seq_b,
   mac_b = HMAC-SHA256(home_sync_key, canon_b)}
   [Derive directional 32-byte keys via HKDF-SHA256(ikm: X25519(A,B) || home_sync_key,
    salt: nonce_a || nonce_b, info: "illam-lan-v1-init-to-resp" / "illam-lan-v1-resp-to-init")]
4. Frame 0x03 OPS_BATCH (<= 250 ops,
   <= 1 MB uncompressed, local_seq > cursor) -----> Decrypt & verify 16-byte Poly1305 tag
                                                    BEGIN IMMEDIATE transaction:
                                                    - Dedup by op_id
                                                    - Merge via Field-LWW / PN / Ledger
                                                    - Bump local_seq ONLY if state changed
                                                    COMMIT
5. <---- Frame 0x04 OPS_ACK {acked_seq}
   Update peer_cursors.last_acked_local_seq_sent
6. Repeat 4-5 in reverse direction (Listener -> Initiator), then Frame 0x05 CLOSE_OK
```

*   **Frame format:** `[4-byte big-endian frame_len][1-byte frame_type][12-byte counter nonce (4 zero bytes + 8-byte big-endian monotonic counter)][ciphertext + 16-byte tag]` using RFC 8439 `ChaCha20-Poly1305` (`Chacha20.poly1305Aead()`). Plaintext handshake frames (`0x01 HELLO_INIT`, `0x02 HELLO_RESP`, `0x06 ERR_CLOCK_SKEW`, `0x07 ERR_AUTH`) carry zeroed nonce/tag fields and authenticate via `HMAC-SHA256` over canonical sorted-key UTF-8 JSON; post-handshake frames (`0x03 OPS_BATCH`, `0x04 OPS_ACK`, `0x05 CLOSE_OK`) are AEAD-encrypted with `frame_type` passed as AAD.
*   **Fixed protocol constants (`SyncConfig`):** `kMaxClockSkewMs = 300000` (5 minutes), `kOpsBatchSize = 250`, `kMaxUncompressedBatchBytes = 1048576` (1 MB), `kConnectTimeoutMs = 5000`, `kHandshakeTimeoutMs = 10000`, `kFrameReadTimeoutMs = 15000`, `kPairingTtlMs = 300000`.
*   **Clock skew handling:** Incoming wire HLCs are never rewritten. If `|wall_clock_ms_a - wall_clock_ms_b| > kMaxClockSkewMs`, the handshake returns `0x06 ERR_CLOCK_SKEW` and surfaces a banner instructing the user to enable Automatic Date & Time without modifying `peer_cursors`.
*   **Echo-loop prevention:** Outbound delta queries filter `WHERE local_seq > last_acked_sent AND (received_from_device_id IS NULL OR received_from_device_id != peer_device_id)`, and incoming no-op ops (where local state does not change) do not allocate a new `local_seq`.
*   **Away-from-home escape hatch:** Shopping screens display per-member "Last synced" freshness and provide a 1-tap plain-text "Share store list" export via Android `Intent.ACTION_SEND`.

### 7. Passphrase-Encrypted Portable Backup & Restore (Android SAF)

*   **Archive Format (`.nmflat`):**
    *   **Binary framing:** `[4-byte big-endian header_len][header_utf8_json (AAD)][XChaCha20-Poly1305 ciphertext][16-byte Poly1305 tag]`.
    *   **Plaintext authenticated header (AAD):** `{magic: "NMFLAT1", format_version: 1, app_schema_version, home_id, kdf: "argon2id", kdf_mem_kib: 65536, kdf_iters: 3, kdf_parallelism: 1, salt_b64 (16 bytes), nonce_b64 (24 bytes), created_at_ms, op_count}`.
    *   **AEAD ciphertext payload:** Gzipped JSONL containing `{home_sync_key_b64, sync_ops: [...]}` encrypted with the Argon2id-derived 32-byte key (computed inside `Isolate.run` so the UI thread stays responsive) using `XChaCha20-Poly1305` (`Xchacha20.poly1305Aead()`, 24-byte random nonce). Device-local state (`device_id`, `local_seq`, `peer_cursors`, `sync_events`) is excluded.
    *   **Key recovery:** Because the key derives from a user-chosen backup passphrase (or generated recovery code), backups remain decryptable on a replacement phone even if the old phone and its Android Keystore are lost. When the user enables the "Remember passphrase for quick export" setting (off by default), the derived key is cached in `flutter_secure_storage` purely for repeat exports.
*   **Export Flow:** Dart writes the encrypted `.nmflat` file to `getTemporaryDirectory()`, then invokes `io.github.pvkarthikk.illam/saf` (`exportFile`) so Kotlin opens `ACTION_CREATE_DOCUMENT` with timestamped filename `illam_YYYYMMDD_HHMMSS.nmflat` and streams bytes via `ContentResolver.openOutputStream` (64 KB buffer, avoiding Binder limits and OneDrive in-place overwrite truncation), then deletes the temp file.
*   **Restore Flow:** Kotlin opens `ACTION_OPEN_DOCUMENT` (`importFile`) and streams into a cache temp file. Dart validates header `magic`, `format_version`, and AEAD authentication tag; checks `home_id` (blocking accidental merge of a different household unless the user explicitly selects "Start new home from backup (claim ownership)" for sole-owner phone loss); creates a WAL-safe pre-restore snapshot via `VACUUM INTO '<snapshot_path>'`; mints a new `device_id` (preserving `member_id`), resets `peer_cursors`, marks restored `pn_counters.frozen = 1`, and ingests ops in 250-op transactions via `ChangeWriter.ingestRemoteBatch`; rolls back to the snapshot file on any failure, then deletes temp/snapshot files and displays a plain-English `RestoreMergeSummary` (inserted, updated, skipped, tombstones preserved).

### 8. On-Device Observability & `/debug` Diagnostics (`kDebugMode`)

Because there is no central server, diagnostics live locally behind `/debug` (compiled only when `kDebugMode` is true):
*   Identity & clock view: `device_id`, `member_id`, `home_id`, current HLC, wall-clock offset, `hlc_clamp_count`, `max_observed_skew_ms`.
*   Storage & cursor table: SQLite `schema_version`, per-table active/tombstone/`sync_ops` counts, `peer_cursors` rows, and `quarantined_ops` viewer.
*   Sync session log: live viewer and sanitized JSON export of the 1,000-row `sync_events` ring buffer keyed by `sync_session_id`.
*   Convergence check & backup validator: deterministic per-collection SHA-256 state digest (computed over sorted `(table_name, row_id)` canonical JSON of active + tombstoned synced domain columns excluding `local_seq` and local-only tables) and a dry-run `.nmflat` decrypt/merge simulator (wired in M3).

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
*   **Reason for Rejection:** Rejected by author: raw TCP with application-layer X25519 + HKDF + RFC 8439 `ChaCha20-Poly1305` length-prefixed frames avoids both X.509 cert-clock failures and Play Store cleartext/TrustManager flags.

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
*   **LAN Confidentiality & Integrity:** All home Wi-Fi sync traffic is encrypted and authenticated using ephemeral X25519 + 256-bit `home_sync_key` via HKDF-SHA256 and RFC 8439 `ChaCha20-Poly1305` (12-byte counter nonce). No maid PII, home names, or financial data appear in mDNS TXT records or cleartext packets.
*   **Backup Confidentiality & Key Independence:** `.nmflat` files are encrypted with Argon2id (64 MiB / 3 iters / 1 lane, run in `Isolate.run`) + `XChaCha20-Poly1305` (24-byte random nonce) derived from a user passphrase/recovery code, independent of Android Keystore. Plaintext headers act as AAD so tampering fails authentication before any database write.
*   **Android Auto Backup Disabled:** `android:allowBackup="false"`, `android:dataExtractionRules` (API 31+), and `android:fullBackupContent` (API 26–30) exclude SQLite databases and SharedPreferences so Android cloud restore never clones `device_id` across two devices.
*   **Zero Location Permissions:** Peer discovery uses `NsdManager` + `WifiManager.MulticastLock` without reading Wi-Fi SSIDs or requesting `ACCESS_FINE_LOCATION` or `NEARBY_WIFI_DEVICES`.

### Performance, Storage & Resource Budgets
*   **Local UI Responsiveness:** Local writes via `ChangeWriter` and reactive Drift `watch()` updates complete in `< 100 ms` on mid-range/budget Android devices (3–4 GB RAM).
*   **Memory & SQLite Lock Safety:** Sync batches are capped at 250 ops (`<= 1 MB` uncompressed per frame) and applied in one `BEGIN IMMEDIATE` transaction per chunk under SQLite WAL mode (`busy_timeout = 5000 ms`) to prevent OOM and `SQLITE_BUSY` UI stalls during multi-year initial sync or restore.
*   **Storage Footprint:** Text-only household usage (~50 ops/day ≈ 18,000 ops/year) occupies ~3–5 MB/year in SQLite; clearing non-essential text fields on tombstoned rows keeps 3–5 year household databases and gzipped `.nmflat` backups compact.
*   **Battery Discipline:** `WifiManager.MulticastLock` and TCP listeners run strictly while the app is foregrounded, avoiding continuous background wake locks or foreground service notifications.

### Rollout, Compatibility & Accessibility
*   **Staggered App Updates:** Additive-only SQLite migrations with committed `drift_schemas/` snapshots and `SchemaVerifier` step-by-step tests. Unknown `table_name` / `field_name` ops stay persisted in `sync_ops` (`applied = 0`) for pass-through relay and automatic materialization on upgrade via `beforeOpen`.
*   **Restore Rollback Safety:** Every backup restore writes a WAL-safe `VACUUM INTO` pre-restore snapshot first so a failed or aborted merge rolls back cleanly.
*   **Accessibility:** All icon-only controls provide `tooltip` or `Semantics(label:)`, touch targets are `>= 48 dp`, and all layouts wrap cleanly without clipping at font scale `2.0`.

--------------------------------------------------------------------------------

### Additional Resources

*   [concepts_brief.md](../../concepts_brief.md) — Synthesized multi-lens brainstorm brief and locked decisions `D1–D6`.
*   [AGENTS.md](../../AGENTS.md) — Project rules, Flutter/Dart stack constraints, and coding conventions.

### Future Improvements

*   **Away-from-home encrypted relay sync:** Optional zero-knowledge mailbox/relay or user-owned encrypted cloud sync folder so cellular edits (such as away-from-home Zepto/DMart updates) propagate without requiring simultaneous Wi-Fi presence.
*   **iOS support:** Add iOS Bonjour (`NSLocalNetworkUsageDescription`) discovery and Files-app backup integration once user demand or funding justifies cross-platform maintenance.
*   **Encrypted media attachments:** Content-addressed compressed photos for bill receipts, recipe dishes, and maid ID references synced separately from text `sync_ops`.
*   **Cryptographic sync-layer RBAC & automatic LAN key rotation:** Per-member Ed25519 signing keys and automated `home_sync_key` rotation on member removal for lower-trust flatmate households.

--------------------------------------------------------------------------------

## Detailed Implementation Plan

Implementation is partitioned into six incremental vertical milestones (`M0–M5`) inside one file list. Every milestone compiles cleanly and passes its exit gate before advancing.

### Complete Drift Table, JSON Sub-Schema, & Index Specification

All synced tables mix in `SyncedColumns`: `id TEXT PRIMARY KEY`, `home_id TEXT NOT NULL`, `deleted INTEGER NOT NULL DEFAULT 0`, `created_at INTEGER NOT NULL`, `created_by TEXT NOT NULL`, `updated_at INTEGER NOT NULL`, `updated_by TEXT NOT NULL`, `updated_hlc TEXT NOT NULL`. All other domain columns are nullable or have explicit defaults; no `FOREIGN KEY ... ON DELETE CASCADE` constraints are declared across synced tables.

| Schema | Table | Primary Key & Columns (beyond `SyncedColumns` for synced tables) | Indexes |
| --- | --- | --- | --- |
| `v1` (M1) | `sync_ops` | `local_seq INTEGER PRIMARY KEY AUTOINCREMENT`, `op_id TEXT NOT NULL UNIQUE`, `home_id TEXT NOT NULL`, `table_name TEXT NOT NULL`, `row_id TEXT NOT NULL`, `op_type TEXT NOT NULL`, `field_name TEXT NOT NULL`, `payload_json TEXT NOT NULL`, `hlc TEXT NOT NULL`, `field_lamport_ver INTEGER NOT NULL DEFAULT 0`, `origin_device_id TEXT NOT NULL`, `actor_member_id TEXT NOT NULL`, `role_epoch INTEGER NOT NULL DEFAULT 0`, `schema_ver INTEGER NOT NULL`, `received_from_device_id TEXT`, `applied INTEGER NOT NULL DEFAULT 1` | `idx_sync_ops_seq(local_seq)`, `idx_sync_ops_applied(applied, local_seq)`, `idx_sync_ops_row(table_name, row_id)` |
| `v1` (M1) | `field_clocks` | PK `(table_name, row_id, field_name)`: `table_name TEXT`, `row_id TEXT`, `field_name TEXT`, `field_lamport_ver INTEGER NOT NULL DEFAULT 0`, `hlc TEXT NOT NULL`, `origin_device_id TEXT NOT NULL` | PK index |
| `v1` (M1) | `pn_counters` | PK `(table_name, row_id, field_name, actor_device_id)`: `table_name TEXT`, `row_id TEXT`, `field_name TEXT`, `actor_device_id TEXT`, `p_val INTEGER NOT NULL DEFAULT 0`, `n_val INTEGER NOT NULL DEFAULT 0`, `frozen INTEGER NOT NULL DEFAULT 0` | `idx_pn_counters_field(table_name, row_id, field_name)` |
| `v1` (M1) | `quarantined_ops` | `op_id TEXT PRIMARY KEY`, `home_id TEXT NOT NULL`, `table_name TEXT NOT NULL`, `row_id TEXT NOT NULL`, `actor_member_id TEXT NOT NULL`, `op_role_epoch INTEGER NOT NULL`, `local_role_epoch INTEGER NOT NULL`, `payload_json TEXT NOT NULL`, `received_at_ms INTEGER NOT NULL`, `status TEXT NOT NULL DEFAULT 'pending'` (`pending`/`accepted`/`dismissed`) | `idx_quarantined_status(home_id, status)` |
| `v1` (M1) | `device_identity` | `singleton_id INTEGER PRIMARY KEY CHECK (singleton_id = 1)`, `device_id TEXT NOT NULL`, `member_id TEXT`, `home_id TEXT`, `last_hlc TEXT`, `hlc_clamp_count INTEGER NOT NULL DEFAULT 0`, `max_observed_skew_ms INTEGER NOT NULL DEFAULT 0` | PK index |
| `v1` (M1) | `peer_cursors` | `peer_device_id TEXT PRIMARY KEY`, `peer_member_id TEXT`, `last_acked_local_seq_sent INTEGER NOT NULL DEFAULT 0`, `last_remote_seq_received INTEGER NOT NULL DEFAULT 0`, `last_success_at_ms INTEGER`, `consecutive_failures INTEGER NOT NULL DEFAULT 0`, `last_error_code TEXT` | PK index |
| `v1` (M1) | `sync_events` | `id INTEGER PRIMARY KEY AUTOINCREMENT`, `sync_session_id TEXT NOT NULL`, `created_at_ms INTEGER NOT NULL`, `peer_device_id TEXT`, `event_type TEXT NOT NULL`, `ops_sent INTEGER NOT NULL DEFAULT 0`, `ops_received INTEGER NOT NULL DEFAULT 0`, `error_code TEXT`, `details_json TEXT` (pruned to latest 1,000 rows) | `idx_sync_events_time(created_at_ms)` |
| `v1` (M1) | `homes` (Synced) | `name TEXT NOT NULL DEFAULT ''`, `currency_code TEXT NOT NULL DEFAULT 'INR'`, `role_epoch INTEGER NOT NULL DEFAULT 1` | `idx_homes_active(home_id, deleted)` |
| `v1` (M1) | `home_members` (Synced) | `display_name TEXT NOT NULL DEFAULT ''`, `role TEXT NOT NULL DEFAULT 'member'` (`owner`/`member`), `status TEXT NOT NULL DEFAULT 'active'` (`active`/`removed`), `promoted_at INTEGER` | `idx_members_home(home_id, deleted, status)` |
| `v1` (M1) | `todo_templates` (Synced) | `title TEXT NOT NULL DEFAULT ''`, `notes TEXT`, `assignee_member_id TEXT`, `freq TEXT NOT NULL DEFAULT 'daily'` (`daily`/`weekly`/`monthly`), `interval_count INTEGER NOT NULL DEFAULT 1`, `days_of_week_mask INTEGER NOT NULL DEFAULT 127`, `day_of_month INTEGER`, `start_date TEXT NOT NULL DEFAULT ''`, `end_date TEXT` | `idx_todo_tpl_home(home_id, deleted)` |
| `v1` (M1) | `todos` (Synced) | `id` (UUIDv4 or deterministic `UUIDv5(kRecurrenceNamespaceUuid, "$templateId:$dateIso")`), `template_id TEXT`, `title TEXT NOT NULL DEFAULT ''`, `notes TEXT`, `assignee_member_id TEXT`, `due_date TEXT`, `status TEXT NOT NULL DEFAULT 'open'` (`open`/`done`/`skipped`), `completed_at INTEGER` | `idx_todos_home_due(home_id, deleted, due_date, status)` |
| `v1` (M1) | `shopping_stores` (Synced) | `name TEXT NOT NULL DEFAULT ''`, `normalized_name TEXT NOT NULL DEFAULT ''`, `channel_type TEXT NOT NULL DEFAULT 'offline'` (`online_app`/`offline_store`/`any`) | `idx_stores_home(home_id, deleted, normalized_name)` |
| `v1` (M1) | `shopping_items` (Synced) | `name TEXT NOT NULL DEFAULT ''`, `store_id TEXT`, `checked INTEGER NOT NULL DEFAULT 0`, `quantity_unit_json TEXT NOT NULL DEFAULT '{"qty":1,"unit":""}'`, `notes TEXT`, `source_ref TEXT` | `idx_shop_items_home(home_id, deleted, checked, store_id)` |
| `v2` (M4) | `maids` (Synced) | `name TEXT NOT NULL DEFAULT ''`, `phone TEXT`, `alt_phone TEXT`, `address TEXT`, `notes TEXT`, `active INTEGER NOT NULL DEFAULT 1` | `idx_maids_home(home_id, deleted, active)` |
| `v2` (M4) | `maid_salary_rules` (Synced) | `maid_id TEXT NOT NULL DEFAULT ''`, `effective_from TEXT NOT NULL DEFAULT ''` (`YYYY-MM-DD`), `base_salary_paise INTEGER NOT NULL DEFAULT 0`, `paid_leaves_per_month INTEGER NOT NULL DEFAULT 0`, `divisor_mode TEXT NOT NULL DEFAULT 'calendar_days'` (`fixed30`/`calendar_days`), `working_days_mask INTEGER NOT NULL DEFAULT 127` (7-bit Mon=1..Sun=64), `shift_slots_per_day INTEGER NOT NULL DEFAULT 1` | `idx_maid_rules(home_id, deleted, maid_id, effective_from)` |
| `v2` (M4) | `maid_attendance` (Synced) | `id` (deterministic `"$maidId:$dateIso:$shiftSlot"`), `maid_id TEXT NOT NULL DEFAULT ''`, `attendance_date TEXT NOT NULL DEFAULT ''`, `shift_slot TEXT NOT NULL DEFAULT 'default'` (`default`/`morning`/`evening`), `status_times_json TEXT NOT NULL DEFAULT '{"status":"present","entry_time":null,"exit_time":null}'` | `idx_maid_att(home_id, deleted, maid_id, attendance_date)` |
| `v2` (M4) | `maid_ledger_entries` (Synced) | `maid_id TEXT NOT NULL DEFAULT ''`, `month_key TEXT NOT NULL DEFAULT ''` (`YYYY-MM`), `entry_type TEXT NOT NULL DEFAULT 'advance'` (`advance`/`bonus`/`deduction`/`override`/`payout`/`void`), `amount_paise INTEGER NOT NULL DEFAULT 0`, `notes TEXT`, `entry_group_id TEXT NOT NULL DEFAULT ''`, `supersedes_id TEXT`, `void_key TEXT`, `attendance_watermark_hlc TEXT` | `idx_maid_ledger(home_id, deleted, maid_id, month_key, entry_group_id)` |
| `v2` (M4) | `expense_categories` (Synced) | `name TEXT NOT NULL DEFAULT ''`, `normalized_name TEXT NOT NULL DEFAULT ''` | `idx_exp_cat(home_id, deleted)` |
| `v2` (M4) | `budgets` (Synced) | `id` (deterministic `"$categoryId:$monthKey"`), `category_id TEXT NOT NULL DEFAULT ''`, `month_key TEXT NOT NULL DEFAULT ''`, `limit_paise INTEGER NOT NULL DEFAULT 0` | `idx_budgets(home_id, deleted, month_key)` |
| `v2` (M4) | `recurring_bill_templates` (Synced) | `title TEXT NOT NULL DEFAULT ''`, `category_id TEXT`, `expected_amount_paise INTEGER NOT NULL DEFAULT 0`, `payer_member_id TEXT`, `splits_json TEXT NOT NULL DEFAULT '[]'`, `day_of_month INTEGER NOT NULL DEFAULT 1`, `start_date TEXT NOT NULL DEFAULT ''`, `end_date TEXT` | `idx_rec_bills(home_id, deleted)` |
| `v2` (M4) | `expense_entries` (Synced) | `id` (UUIDv4 or `UUIDv5(kRecurrenceNamespaceUuid, "$billTemplateId:$dateIso")`), `title TEXT NOT NULL DEFAULT ''`, `category_id TEXT`, `expense_date TEXT NOT NULL DEFAULT ''`, `amount_paise INTEGER NOT NULL DEFAULT 0`, `payer_member_id TEXT NOT NULL DEFAULT ''`, `splits_json TEXT NOT NULL DEFAULT '[]'`, `entry_kind TEXT NOT NULL DEFAULT 'expense'` (`expense`/`settlement`/`void`), `notes TEXT`, `source_ref TEXT`, `entry_group_id TEXT NOT NULL DEFAULT ''`, `supersedes_id TEXT`, `void_key TEXT` | `idx_expenses_date(home_id, deleted, expense_date, entry_kind)`, `idx_expenses_group(home_id, entry_group_id)` |
| `v3` (M5) | `recipes` (Synced) | `title TEXT NOT NULL DEFAULT ''`, `instructions TEXT`, `servings INTEGER NOT NULL DEFAULT 2` | `idx_recipes_home(home_id, deleted)` |
| `v3` (M5) | `recipe_ingredients` (Synced) | `recipe_id TEXT NOT NULL DEFAULT ''`, `name TEXT NOT NULL DEFAULT ''`, `quantity_unit_json TEXT NOT NULL DEFAULT '{"qty":1,"unit":""}'`, `default_store_id TEXT` | `idx_recipe_ing(home_id, deleted, recipe_id)` |
| `v3` (M5) | `meal_plan_entries` (Synced) | `id` (deterministic `"$dateIso:$slot"`), `meal_date TEXT NOT NULL DEFAULT ''`, `slot TEXT NOT NULL DEFAULT 'lunch'` (`breakfast`/`lunch`/`snack`/`dinner`), `recipe_id TEXT`, `free_text TEXT` | `idx_meal_plan(home_id, deleted, meal_date)` |

*   **Atomic JSON Sub-Schemas:**
    *   `quantity_unit_json`: `{"qty": number, "unit": string}` (e.g., `{"qty": 2, "unit": "packs"}`).
    *   `status_times_json`: `{"status": "present"|"half_day"|"absent", "entry_time": "HH:mm"|null, "exit_time": "HH:mm"|null}`.
    *   `splits_json`: `[{"member_id": string, "paise": int}]` sorted ascending by `member_id`, with `sum(paise) == amount_paise`.

---

### Target Files to Create, Modify, or Delete

#### Milestone 0 (M0): Repo Housekeeping, Core Dependencies, Localization, Native Bridges, & Buildable App Shell

##### 1. `AGENTS.md` (Modify)
*   **Type / Scope:** Repository coding contract.
*   **Proposed Changes:** Fix line 17 to mandate `package:material_ui/material_ui.dart` (forbidding `package:flutter/material.dart`); update line 22 example from `listsAdded` to `shoppingAdded`; change line 24 currency from `£` to INR `₹` (`₹1 = 100`, `₹1,234`); fix line 32 missing closing backtick and document `appendLedger` + compensating forward undo; update line 33 to list `SyncedColumns (id, home_id, deleted, created_at, created_by, updated_at, updated_by, updated_hlc)` backed by `sync_ops`/`field_clocks`/`pn_counters`; update line 39 comment to `# after Drift table/database changes`; align title punctuation to `Illam`.

##### 2. `pubspec.yaml` (Modify), `l10n.yaml` (Create), `build.yaml` (Create)
*   **Type / Scope:** Package manifest, ARB localization config, and Drift migration build config.
*   **Proposed Changes:**
    *   `pubspec.yaml` (`Modify`): Add AGP 9 / `sqlite3 3.x` compatible version-constrained dependencies (`flutter_riverpod: ^3.0.0`, `go_router: ^18.0.0`, `drift: ^2.26.0`, `drift_flutter: ^0.3.0`, `shared_preferences: ^2.5.0`, `flutter_secure_storage: ^10.3.1`, `intl: ^0.20.2`, `path: ^1.9.1`, `path_provider: ^2.1.5`, `cryptography: ^2.7.0`, `uuid: ^4.5.1`, `qr_flutter: ^4.1.0`, `mobile_scanner: ^7.5.0`), add `flutter_localizations` via `flutter pub add flutter_localizations --sdk=flutter`, add dev dependencies (`drift_dev: ^2.26.0`, `build_runner: ^2.4.15`), and set `flutter: generate: true`. Keep existing `NestTheme` font families with system fallbacks unless `.ttf` files are resolved in Open Questions before M0.
    *   `l10n.yaml` (`Create`): Configure `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`, `output-localization-file: app_localizations.dart`, `nullable-getter: false`. Generated outputs: `lib/l10n/app_localizations*.dart` (generated).
    *   `build.yaml` (`Create`): Configure `drift_dev` `schema_dir: drift_schemas/` and `test_dir: test/generated_migrations/` for `dart run drift_dev make-migrations`.

##### 3. `android/app/build.gradle.kts` (Modify)
*   **Type / Scope:** Android Gradle configuration.
*   **Proposed Changes:** Change `namespace` and `applicationId` from `com.example.nm_flat` to `io.github.pvkarthikk.illam`; set `minSdk = 26` (Android 8.0+ baseline required by `flutter_secure_storage` v10 and `mobile_scanner` v7) and `targetSdk = maxOf(flutter.targetSdkVersion, 35)`.

##### 4. `android/app/src/main/AndroidManifest.xml` (Modify), `android/app/src/main/res/xml/data_extraction_rules.xml` (Create), `android/app/src/main/res/xml/backup_rules.xml` (Create)
*   **Type / Scope:** Android permissions and Auto Backup exclusion rules (API 26–35).
*   **Proposed Changes:**
    *   `AndroidManifest.xml` (`Modify`): Add `<uses-permission>` entries for `INTERNET`, `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE`, `CHANGE_WIFI_MULTICAST_STATE`, and `CAMERA` (QR pairing only; no Location, `NEARBY_WIFI_DEVICES`, or `FOREGROUND_SERVICE_DATA_SYNC`); set `android:allowBackup="false"`, `android:dataExtractionRules="@xml/data_extraction_rules"`, and `android:fullBackupContent="@xml/backup_rules"`.
    *   `data_extraction_rules.xml` (`Create`): Exclude `<exclude domain="database" path="." />` and `<exclude domain="sharedpref" path="." />` inside both `<cloud-backup>` and `<device-transfer>`.
    *   `backup_rules.xml` (`Create`): Mirror the same `database` and `sharedpref` exclusions for API 26–30.

##### 5. `android/app/src/main/kotlin/io/github/pvkarthikk/illam/MainActivity.kt` (Create), `android/app/src/main/kotlin/com/example/nm_flat/MainActivity.kt` (Delete)
*   **Type / Scope:** Android Kotlin platform bridge.
*   **Proposed Changes:** Move `MainActivity` to `package io.github.pvkarthikk.illam` and register three explicit platform channels:
    *   `MethodChannel("io.github.pvkarthikk.illam/lan_nsd")`: `startAdvertise({serviceName, port, homeHash, protocolVer}) -> void`, `stopAdvertise() -> void`, `startBrowse() -> void`, `stopBrowse() -> void` (acquiring/releasing `WifiManager.MulticastLock` while active); `EventChannel("io.github.pvkarthikk.illam/lan_nsd_events")` emitting `{event: "found"|"lost", host: String, port: Int, homeHash: String, protocolVer: Int}`.
    *   `MethodChannel("io.github.pvkarthikk.illam/saf")`: `exportFile({suggestedName: String, sourceTempPath: String}) -> bool` (`ACTION_CREATE_DOCUMENT`) and `importFile({destTempPath: String}) -> bool` (`ACTION_OPEN_DOCUMENT`), streaming via `ContentResolver` with 64 KB buffers to avoid Android Binder `TransactionTooLargeException` (errors: `ERR_CANCELLED`, `ERR_IO`).
    *   `MethodChannel("io.github.pvkarthikk.illam/share")`: `shareText({text: String, subject: String?}) -> void` via `Intent.createChooser(Intent(Intent.ACTION_SEND), ...)`.

##### 6. `lib/l10n/app_en.arb` (Create)
*   **Type / Scope:** English ARB localization catalog.
*   **Proposed Changes:** Initialize feature-prefix conventions (`common*`, `home*`, `sync*`, `todos*`, `shopping*`, `maid*`, `expenses*`, `meals*`, `settings*`, `backup*`, `debug*`) and define all M0 shell/theme/navigation strings (each subsequent milestone M1–M5 adds its own feature keys).

##### 7. `lib/core/design/components/nest_card.dart` (Create), `lib/core/design/components/nest_button.dart` (Create), `lib/core/design/components/nest_chip.dart` (Create), `lib/core/design/components/nest_empty_state.dart` (Create), `lib/core/design/components/nest_sync_badge.dart` (Create)
*   **Type / Scope:** Shared Material 3 / `NestColors` widget library.
*   **Proposed Changes:** Build reusable components reading exclusively from `context.nest` and `Theme.of(context).colorScheme`, enforcing `>= 48 dp` tap targets, `tooltip`/`Semantics(label:)` on icon-only controls, and wrapping layouts at font scale `2.0`.

##### 8. `lib/core/providers.dart` (Create), `lib/core/router.dart` (Create), `lib/main.dart` (Modify), `test/widget_test.dart` (Modify), `test/core/design/nest_theme_test.dart` (Modify)
*   **Type / Scope:** Buildable M0 Riverpod 3 / `GoRouter` shell and updated starter tests.
*   **Proposed Changes:**
    *   `lib/core/providers.dart` (`Create`): Define M0-only providers (`sharedPreferencesProvider`, `themeModeProvider`).
    *   `lib/core/router.dart` (`Create`): Define M0-only `GoRouter` with `/` (shell placeholder with Light/Dark theme switch) and `/settings` stub—zero forward references to M1–M5 classes.
    *   `lib/main.dart` (`Modify`): Remove template `MyHomePage`; await `SharedPreferences.getInstance()` in `main()` and wrap `MyApp({super.key, this.initialThemeMode})` in `ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)])`; wire `MaterialApp.router` with `AppLocalizations` and persisted `ThemeMode`.
    *   `test/widget_test.dart` (`Modify`) and `test/core/design/nest_theme_test.dart` (`Modify`): Update both tests to wrap `MyApp` in `ProviderScope` with in-memory `SharedPreferences.setMockInitialValues({})` and assert `Illam` branding + Light/Dark switching.
*   **M0 Exit Gate:** `flutter pub get`, `flutter gen-l10n`, `flutter analyze` (0 errors/warnings), `flutter test` (`widget_test.dart` + `nest_theme_test.dart` pass).

---

#### Milestone 1 (M1): Pure Domain Core, Drift Sync Engine, Todos, Shopping Lists, & `/debug`

##### 9. `lib/core/domain/money.dart` (Create)
*   **Type / Scope:** Pure Dart currency formatting and parsing.
*   **Proposed Changes:** Implement `Money.format(int paise)` using Indian grouping with `₹`, omitting `.00` when `paise % 100 == 0` (`₹1,23,456` / `₹1,234.50`), placing negative sign before symbol (`-₹1,234`), and `int? Money.tryParse(String input)` returning `null` on invalid input.

##### 10. `lib/core/domain/hlc.dart` (Create)
*   **Type / Scope:** Pure Dart Hybrid Logical Clock.
*   **Proposed Changes:** Define `Hlc(int physicalMs, int counter, String deviceId)` encoding as `<13-digit zero-padded decimal ms>-<5 lowercase hex digits>-<device_id>` (`0x00000..0xFFFFF`), `kMaxLocalDriftMs = 300000`, `tickLocal(int wallMs)` (clamping local regressions/jumps; on counter overflow `> 0xFFFFF` advance `physicalMs + 1` and reset counter to `0`), `observeRemote(Hlc remote, int wallMs)` (never mutating `remote`'s wire string), and `isWithinSkew(int remoteWallMs, int localWallMs, int maxSkewMs)`.

##### 11. `lib/core/domain/merge_engine.dart` (Create)
*   **Type / Scope:** Pure Dart CRDT merge rules.
*   **Proposed Changes:** Implement: (a) `mergeFieldLww` ordering by `(fieldLamportVer, hlc, originDeviceId)` returning `({bool changed, ...})`, (b) `mergePnCounter` taking element-wise `max(pVal)`/`max(nVal)` while preserving `frozen` slots read-only, (c) `resolveActiveRevision(List<LedgerEntry> entries)` picking max `(hlc, originDeviceId)` among non-voided leaves where a deterministic `void:<entry_group_id>` entry wins if its `hlc` exceeds the latest leaf `hlc`, and (d) per-table tombstone payload clearing (`notes` on `todos`/`shopping_items`/`expense_entries`/`maid_ledger_entries`, `instructions` on `recipes`).

##### 12. `lib/core/domain/write_policy_gate.dart` (Create)
*   **Type / Scope:** Pure Dart owner governance & role resolver.
*   **Proposed Changes:** Implement the Owner vs. Member permission matrix (`canInviteMember`, `canRemoveMember`, `canChangeRole`, `canEditHomeName`, `canEditMaidConfig`, `canSettleMaidPayroll` — all other household writes allowed for any `status == 'active'` member), deterministic last-owner tie-break (earliest `promoted_at`, then lexicographical `member_id`), and `evaluateRemoteAuthority(op, localMembers, localRoleEpoch) -> AuthorityDecision (apply | quarantine)`.

##### 13. `lib/core/domain/recurrence_engine.dart` (Create)
*   **Type / Scope:** Pure Dart deterministic recurring schedule projector.
*   **Proposed Changes:** Define fixed `kRecurrenceNamespaceUuid = 'd3f8a4c2-7b1e-4e9a-9c5d-2a1b3c4d5e6f'`, project occurrences over `[startDate, endDate]` for `freq` (`daily`/`weekly`/`monthly`) anchored on `start_date` with `day_of_month` clamped to month length (Feb 28/29, Apr 30), and generate deterministic occurrence IDs `UUIDv5(kRecurrenceNamespaceUuid, "$templateId:$dateIso")`.

##### 14. `lib/core/data/db/tables/synced_columns.dart` (Create), `lib/core/data/db/tables/sync_tables.dart` (Create), `lib/core/data/db/tables/home_tables.dart` (Create), `lib/core/data/db/tables/todo_tables.dart` (Create), `lib/core/data/db/tables/shopping_tables.dart` (Create)
*   **Type / Scope:** Drift `v1` SQLite table definitions.
*   **Proposed Changes:** Implement every `v1` table and index listed in the Complete Drift Table Specification above.

##### 15. `lib/core/data/db/app_database.dart` (Create), `lib/core/data/db/app_database.g.dart` (Create, generated), `lib/core/data/db/collection_registry.dart` (Create), `drift_schemas/drift_schema_v1.json` (Create), `test/generated_migrations/**` (Create, generated)
*   **Type / Scope:** Drift database (`schemaVersion = 1`), WAL setup, registry, and schema snapshots.
*   **Proposed Changes:** Configure `@DriftDatabase` using `path`/`path_provider` and `PRAGMA journal_mode=WAL; PRAGMA busy_timeout=5000`; wire `migration.beforeOpen` to replay `sync_ops WHERE applied = 0 ORDER BY local_seq ASC`; register all `v1` synced tables in `CollectionRegistry` (materializer, tombstone stripper, owner-guarded flag, canonical digest serializer).

##### 16. `lib/core/data/change_writer.dart` (Create)
*   **Type / Scope:** Single transactional write gateway and remote op ingestor.
*   **Proposed Changes:** Implement `Future<ChangeResult> bootstrapHome({required String homeName, required String ownerName})` (initializes `device_identity`, `homes`, `home_members`, and pre-seeds the `Any store` shopping store), `Future<ChangeResult> write(String label, void Function(ChangeBatch c) build)` (`ChangeBatch` methods: `create`, `set`, `inc`, `appendLedger`, `delete`), `Future<void> undo(UndoToken token)` (emitting compensating forward ops from local pre-write snapshots), `Future<IngestSummary> ingestRemoteBatch(List<SyncOp> ops, {String? fromPeerDeviceId})` (persisting unknown tables/fields with `applied = 0`, quarantining stale-authority ops, bumping `local_seq` only when `changed == true`), and `Future<Map<String, String>> computeStateDigests()`.

##### 17. `lib/features/home_setup/home_setup_screen.dart` (Create), `lib/features/home_setup/home_setup_controller.dart` (Create)
*   **Type / Scope:** Onboarding flow (Create home + disabled M2/M3 placeholders for Join home / Restore from backup).
*   **Proposed Changes:** Render welcome screen on `NestPatternBackground` (reading `NestColors.brandCanvas` via `context.nest`); implement Create home form calling `ChangeWriter.bootstrapHome`.

##### 18. `lib/features/shopping/shopping_screen.dart` (Create), `lib/features/shopping/shopping_controller.dart` (Create), `lib/features/shopping/shopping_parts.dart` (Create)
*   **Type / Scope:** Feature Module 1 — Online-app / offline-store grouped shopping lists.
*   **Proposed Changes:** Stream active `shopping_items` grouped by `shopping_stores` (`Any store` pre-seeded on Create home; user-creatable online apps/offline stores such as Zepto, DMart, Reliance Bazaar); quick-add with atomic `quantity_unit_json`, check-off vs. delete with snackbar undo, store-group filter chips, "Last synced" badge, and 1-tap "Share store list" invoking `io.github.pvkarthikk.illam/share`.

##### 19. `lib/features/todos/todos_screen.dart` (Create), `lib/features/todos/todos_controller.dart` (Create), `lib/features/todos/todos_parts.dart` (Create)
*   **Type / Scope:** Feature Module 2 — Assignable one-time and recurring todos.
*   **Proposed Changes:** Stream active `todos` combined with read-time projected occurrences from `todo_templates` via `RecurrenceEngine`; filter by assignee (`member_id`), due date, or status; completing/skipping a recurring occurrence materializes a deterministic-ID row via `ChangeWriter` with snackbar undo.

##### 20. `lib/features/debug/debug_screen.dart` (Create), `lib/features/debug/debug_controller.dart` (Create)
*   **Type / Scope:** `kDebugMode`-only on-device observability hub (`/debug`).
*   **Proposed Changes:** Display `device_id`, `member_id`, `home_id`, local HLC, `hlc_clamp_count`, `max_observed_skew_ms`, `schema_version`, per-table active/tombstone/`sync_ops` counts, `peer_cursors`, `quarantined_ops`, bounded `sync_events` viewer + sanitized JSON export, and per-collection SHA-256 state digests. (`.nmflat` dry-run validator added in M3.)

##### 21. M1 Wiring & Tests
*   **Files:** `lib/core/providers.dart` (`Modify`: add `appDatabaseProvider`, `changesProvider`, `currentHomeProvider`, `currentMemberProvider`), `lib/core/router.dart` (`Modify`: add `/setup`, `/shopping`, `/todos`, `kDebugMode`-gated `/debug`), `lib/l10n/app_en.arb` (`Modify`: add `home*`, `shopping*`, `todos*`, `debug*` keys), `test/core/domain/money_test.dart` (`Create`), `test/core/domain/hlc_test.dart` (`Create`), `test/core/domain/merge_engine_test.dart` (`Create`), `test/core/domain/write_policy_gate_test.dart` (`Create`), `test/core/domain/recurrence_engine_test.dart` (`Create`), `test/core/data/change_writer_test.dart` (`Create`), `test/core/data/db/schema_migration_test.dart` (`Create`), `test/features/home_setup/home_setup_screen_test.dart` (`Create`), `test/features/shopping/shopping_screen_test.dart` (`Create`), `test/features/todos/todos_screen_test.dart` (`Create`), `test/features/debug/debug_screen_test.dart` (`Create`).
*   **M1 Exit Gate:** `dart run build_runner build --delete-conflicting-outputs`, `dart run drift_dev make-migrations`, `flutter gen-l10n`, `flutter analyze` (0 issues), `flutter test` (all M0+M1 domain, `ChangeWriter`, migration, and widget tests pass).

---

#### Milestone 2 (M2): Encrypted Home Wi-Fi LAN Pairing & Raw TCP Sync

##### 22. `lib/core/data/sync/sync_config.dart` (Create)
*   **Type / Scope:** Protocol & timing constants.
*   **Proposed Changes:** Define `kProtocolVersion = 1`, `kMaxClockSkewMs = 300000`, `kOpsBatchSize = 250`, `kMaxUncompressedBatchBytes = 1048576`, `kConnectTimeoutMs = 5000`, `kHandshakeTimeoutMs = 10000`, `kFrameReadTimeoutMs = 15000`, `kPairingTtlMs = 300000`, and `FrameType` byte constants (`0x01`..`0x07`).

##### 23. `lib/core/data/sync/lan_crypto.dart` (Create), `lib/core/data/sync/lan_frame_codec.dart` (Create)
*   **Type / Scope:** X25519 + HKDF-SHA256 + RFC 8439 `ChaCha20-Poly1305` session crypto and binary framing.
*   **Proposed Changes:** Implement mutual `HELLO_INIT`/`HELLO_RESP` `HMAC-SHA256` verification over canonical sorted-key UTF-8 JSON, ephemeral X25519 key agreement, directional 32-byte `ChaCha20-Poly1305` (`Chacha20.poly1305Aead()`, 12-byte counter nonce) keys derived via HKDF-SHA256 (`illam-lan-v1-init-to-resp` / `illam-lan-v1-resp-to-init`), Base32 pairing token encoder/decoder, and `[4-byte length][1-byte type][12-byte nonce][ciphertext+16-byte tag]` framing enforcing `kMaxUncompressedBatchBytes` and read timeouts.

##### 24. `lib/core/data/sync/lan_discovery_service.dart` (Create)
*   **Type / Scope:** Android `NsdManager` + `MulticastLock` wrapper and manual `IP:port` targeting.
*   **Proposed Changes:** Wrap `io.github.pvkarthikk.illam/lan_nsd` and `io.github.pvkarthikk.illam/lan_nsd_events` advertising `h=<16-hex-char SHA-256(home_id || "illam-mdns-v1")>` and `p=1` only while foregrounded; stop/release lock on `AppLifecycleState.paused`; expose manual `IP:port` connect helper.

##### 25. `lib/core/data/sync/lan_sync_service.dart` (Create)
*   **Type / Scope:** Raw TCP sync engine (`dart:io` `ServerSocket`/`Socket`).
*   **Proposed Changes:** Coordinate QR/Base32 home pairing, glare resolution (lower `device_id` initiates), removed-member rejection, `ERR_CLOCK_SKEW` check, paginated 250-op delta queries (`WHERE local_seq > last_acked_sent AND (received_from_device_id IS NULL OR received_from_device_id != peer_device_id)`), transactional `ChangeWriter.ingestRemoteBatch`, explicit `OPS_ACK` cursor commit, and `sync_events` ring-buffer logging keyed by `sync_session_id`.

##### 26. `lib/features/home_setup/pairing_screen.dart` (Create), `lib/features/home_setup/pairing_controller.dart` (Create)
*   **Type / Scope:** Owner QR/Base32 invite, Join home scanner, member management, & Sync now UI.
*   **Proposed Changes:** Render 5-minute expiring QR + copyable Base32 pairing token for Owners; scan QR or paste token on joining phone; manage members (promote co-owner, remove member with LAN key-rotation notice, accept/dismiss `quarantined_ops`); provide "Sync now" with specific recovery prompts ("Not on Wi-Fi — connect to home Wi-Fi", "Peer app not open — open Illam on the other phone", "Router blocking discovery — tap Connect manually", "Device clock off — enable Automatic Date & Time").

##### 27. M2 Wiring & Tests
*   **Files:** `lib/features/home_setup/home_setup_screen.dart` (`Modify`: wire Join home), `lib/features/home_setup/home_setup_controller.dart` (`Modify`), `lib/core/providers.dart` (`Modify`: add `lanSyncServiceProvider`), `lib/core/router.dart` (`Modify`: add `/pairing`), `lib/l10n/app_en.arb` (`Modify`: add `sync*` keys), `test/core/data/sync/multi_node_sync_test.dart` (`Create`: 3+ in-memory Drift DBs under randomized drops, duplicates, reordering, transitive forwarding with no echo loops, unknown-field pass-through, delete undo, and restore with new `device_id` asserting identical canonical domain rows and SHA-256 digests), `test/core/data/sync/lan_crypto_frame_test.dart` (`Create`: handshake auth, tamper rejection, clock-skew rejection, Base32 pairing token expiry), `test/features/home_setup/pairing_screen_test.dart` (`Create`).
*   **M2 Exit Gate:** `flutter gen-l10n`, `flutter analyze`, `flutter test` (all M0–M2 tests pass) + physical two-phone Wi-Fi pairing & delta sync check.

---

#### Milestone 3 (M3): Passphrase-Encrypted Portable Backup & Restore (Android SAF)

##### 28. `lib/core/data/backup/backup_codec.dart` (Create)
*   **Type / Scope:** `.nmflat` archive codec, Argon2id KDF, and `XChaCha20-Poly1305` AEAD envelope.
*   **Proposed Changes:** Implement `[4-byte big-endian header_len][header_utf8_json][ciphertext][16-byte tag]` using Argon2id (`kdf_mem_kib: 65536`, `kdf_iters: 3`, `kdf_parallelism: 1`, 16-byte salt) inside `Isolate.run` and `Xchacha20.poly1305Aead()` (24-byte random nonce) over gzipped JSONL of `{home_sync_key_b64, sync_ops}` excluding local-only tables.

##### 29. `lib/core/data/backup/backup_service.dart` (Create)
*   **Type / Scope:** SAF export/import coordinator, `VACUUM INTO` snapshot/rollback, and `device_id` rotation.
*   **Proposed Changes:** Export `illam_YYYYMMDD_HHMMSS.nmflat` via cache temp file + `io.github.pvkarthikk.illam/saf` (`exportFile`), optionally caching the derived key in `flutter_secure_storage` only when the user enables "Remember passphrase for quick export" (off by default); on restore (`importFile`), verify header/AEAD/`home_id`, create a WAL-safe `VACUUM INTO` pre-restore snapshot, mint a new `device_id` (preserving `member_id`), clear `peer_cursors`, set restored `pn_counters.frozen = 1`, ingest via `ChangeWriter.ingestRemoteBatch` in 250-op transactions (rolling back to snapshot on error), and support explicit "Start new home from backup (claim ownership)" mode for sole-owner phone loss.

##### 30. `lib/features/settings_backup/settings_backup_screen.dart` (Create), `lib/features/settings_backup/settings_backup_controller.dart` (Create)
*   **Type / Scope:** Settings, Light/Dark theme switch, and Backup/Restore UI.
*   **Proposed Changes:** Persist Light/Dark `ThemeMode` in `shared_preferences`; guide backup passphrase/recovery-code setup, SAF export, and SAF restore with a pre-restore confirmation dialog explaining bidirectional merge semantics (no time-machine rollback, automatic rollback on error) and post-restore `RestoreMergeSummary`.

##### 31. M3 Wiring & Tests
*   **Files:** `lib/features/home_setup/home_setup_screen.dart` (`Modify`: wire Restore from backup), `lib/features/home_setup/home_setup_controller.dart` (`Modify`), `lib/features/debug/debug_screen.dart` (`Modify`: add dry-run `.nmflat` merge validator), `lib/core/providers.dart` (`Modify`: add `backupServiceProvider`), `lib/core/router.dart` (`Modify`: wire `/settings` to `SettingsBackupScreen`), `lib/l10n/app_en.arb` (`Modify`: add `settings*` and `backup*` keys), `test/core/data/backup/backup_codec_test.dart` (`Create`), `test/fixtures/backup_v1.nmflat` (`Create`: golden fixture with passphrase `"nest-test-passphrase-v1"`, `home_id: "00000000-0000-4000-8000-000000000001"`, and 10 seeded ops covering Field-LWW, tombstone, and expense rows), `test/features/settings_backup/settings_backup_screen_test.dart` (`Create`).
*   **M3 Exit Gate:** `flutter gen-l10n`, `flutter analyze`, `flutter test` (including golden `.nmflat` decrypt, wrong-passphrase rejection, AAD bit-flip rejection, and `VACUUM INTO` rollback tests).

---

#### Milestone 4 (M4): Maid Attendance & Payroll + Manual Expenses, Splits, Budgets, & Bills

##### 32. `lib/core/domain/maid_salary_calculator.dart` (Create)
*   **Type / Scope:** Pure Dart Indian household maid payroll calculator.
*   **Proposed Changes:** Compute monthly salary in integer paise from effective-dated `maid_salary_rules` (splitting mid-month rate changes into date sub-ranges prorated by each sub-range's days), opt-in `maid_attendance` (`present = 1.0`, `half_day = 0.5`, `absent = 0.0`, averaged across `shift_slots_per_day`), returning `unmarkedDates` for unlogged dates matching `working_days_mask`; compute `dailyRatePaise = (baseSalaryPaise / divisor).round()` (`30` for `fixed30`, days-in-month for `calendar_days`), `unpaidAbsences = max(0.0, scheduledDays - workedDays - paidLeavesPerMonth)`, `netPayablePaise = baseSalaryPaise - (unpaidAbsences * dailyRatePaise).round() + bonusesPaise - deductionsPaise - advancesPaise`; manual override replaces `netPayablePaise` and records `attendance_watermark_hlc`, flagging `hasLateAttendanceAfterSettlement` when any month attendance/ledger HLC exceeds the watermark.

##### 33. `lib/core/domain/expense_split_calculator.dart` (Create)
*   **Type / Scope:** Pure Dart paise-exact split allocator and monthly net balance calculator.
*   **Proposed Changes:** Allocate equal/custom splits in integer paise sorting participants ascending by `member_id` and assigning `+1` paise remainder to the first `amount % n` members (`sum(splits) == amount_paise`); compute monthly category spend excluding `entry_kind == 'settlement'`; compute per-member monthly net balance (`totalPaidPaise - totalOwedPaise`, sum == `0`).

##### 34. `lib/core/data/db/tables/maid_tables.dart` (Create), `lib/core/data/db/tables/expense_tables.dart` (Create), `lib/core/data/db/app_database.dart` (Modify), `lib/core/data/db/app_database.g.dart` (Modify, generated), `lib/core/data/db/collection_registry.dart` (Modify), `drift_schemas/drift_schema_v2.json` (Create), `test/generated_migrations/**` (Modify, generated)
*   **Type / Scope:** Drift `v2` tables and additive migration for Maid and Expenses.
*   **Proposed Changes:** Add the `v2` tables defined in the Complete Drift Table Specification above, raise `schemaVersion` to `2` with additive `onUpgrade` migration, regenerate Drift code and migration helpers, and register tables in `CollectionRegistry`.

##### 35. `lib/features/maid/maid_screen.dart` (Create), `lib/features/maid/maid_detail_screen.dart` (Create), `lib/features/maid/maid_controller.dart` (Create), `lib/features/maid/maid_parts.dart` (Create)
*   **Type / Scope:** Feature Module 3 — Maid directory, multi-shift entry/exit logging, and monthly salary settlement.
*   **Proposed Changes:** Owner-guarded CRUD for maid profiles and effective-dated salary rules; daily opt-in entry/exit logging per shift slot (`default`/`morning`/`evening`); monthly payroll breakdown highlighting unmarked working days, advances/bonuses/deductions/overrides, late-attendance warning badges, and salary payout action with an "Also add to expenses" toggle (enabled by default).

##### 36. `lib/features/expenses/expenses_screen.dart` (Create), `lib/features/expenses/expenses_controller.dart` (Create), `lib/features/expenses/expenses_parts.dart` (Create), `lib/features/shopping/shopping_screen.dart` (Modify)
*   **Type / Scope:** Feature Module 4 — Manual expenses, recurring bills, budgets, and splits.
*   **Proposed Changes:** Expense entry/edit/void flow backed by append-only superseding snapshots with a folded "Edited" history indicator; equal/custom split editor; monthly category budget bars; upcoming recurring bill projections materialized with editable actual amount on "Mark paid"; monthly member net summary + "Settle up" action; add user-selectable 1-tap "Log as expense" action in `shopping_screen.dart`.

##### 37. M4 Wiring & Tests
*   **Files:** `lib/core/providers.dart` (`Modify`), `lib/core/router.dart` (`Modify`: add `/maid`, `/maid/:id`, `/expenses`), `lib/l10n/app_en.arb` (`Modify`: add `maid*`, `expenses*` keys), `test/core/domain/maid_salary_calculator_test.dart` (`Create`), `test/core/domain/expense_split_calculator_test.dart` (`Create`), `test/core/data/db/schema_migration_test.dart` (`Modify`: add `v1 -> v2` `SchemaVerifier` test), `test/features/maid/maid_screen_test.dart` (`Create`), `test/features/maid/maid_detail_screen_test.dart` (`Create`), `test/features/expenses/expenses_screen_test.dart` (`Create`).
*   **M4 Exit Gate:** `dart run build_runner build --delete-conflicting-outputs`, `dart run drift_dev make-migrations`, `flutter gen-l10n`, `flutter analyze`, `flutter test` (all M0–M4 tests including `v1 -> v2` migration pass).

---

#### Milestone 5 (M5): Meal Planner & Recipes + Accessibility Sweep

##### 38. `lib/core/data/db/tables/meal_tables.dart` (Create), `lib/core/data/db/app_database.dart` (Modify), `lib/core/data/db/app_database.g.dart` (Modify, generated), `lib/core/data/db/collection_registry.dart` (Modify), `drift_schemas/drift_schema_v3.json` (Create), `test/generated_migrations/**` (Modify, generated)
*   **Type / Scope:** Drift `v3` tables and additive migration for Meals & Recipes.
*   **Proposed Changes:** Add `recipes`, `recipe_ingredients`, and `meal_plan_entries` as defined in the Complete Drift Table Specification, raise `schemaVersion` to `3` with additive `onUpgrade`, regenerate Drift code/migration helpers, and register tables in `CollectionRegistry`.

##### 39. `lib/features/meals/meals_screen.dart` (Create), `lib/features/meals/recipe_detail_screen.dart` (Create), `lib/features/meals/meals_controller.dart` (Create), `lib/features/meals/meals_parts.dart` (Create)
*   **Type / Scope:** Feature Module 5 — Weekly meal grid, recipe book, and 1-tap ingredient push.
*   **Proposed Changes:** Render 7-day meal grid supporting saved recipes or free-text entries ("Leftovers", "Ordering in"); recipe editor with text instructions and structured ingredients; 1-tap "Add ingredients to shopping list" copying self-contained rows into `shopping_items` with weak `source_ref` (`recipe:<id>`) and selectable target store group.

##### 40. M5 Wiring, Tests, & Accessibility Sweep
*   **Files:** `lib/core/providers.dart` (`Modify`), `lib/core/router.dart` (`Modify`: add `/meals`, `/meals/recipe/:id`), `lib/l10n/app_en.arb` (`Modify`: add `meals*` keys), `test/core/data/db/schema_migration_test.dart` (`Modify`: add `v2 -> v3` and `v1 -> v3` `SchemaVerifier` tests), `test/features/meals/meals_screen_test.dart` (`Create`), `test/features/meals/recipe_detail_screen_test.dart` (`Create`).
*   **Proposed Changes:** Verify loading/empty/error states, Owner role guard visibility, `>= 48 dp` touch targets, `tooltip`/`Semantics(label:)` on icon-only controls, and zero overflow at `TextScaler.linear(2.0)` across every screen in `test/features/*/*_screen_test.dart`.
*   **M5 Exit Gate:** Full Verification Plan passes with 0 analyzer issues and all tests green.

---

### Verification Plan

*   **Code Generation, Migrations, & Localization:** `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`, `dart run drift_dev make-migrations`, and `flutter gen-l10n` complete with exit code `0`.
*   **Static Analysis & Linting:** `flutter analyze` passes with `0` errors and `0` warnings (no `// ignore` suppressions or weakened lints).
*   **Automated Test & Line Coverage Gate:** `flutter test --coverage` passes across all pure domain tests, 3-node randomized CRDT/sync simulations, Drift `SchemaVerifier` (`v1 -> v2 -> v3`) migration tests, golden `.nmflat` crypto/restore tests, and font-scale `2.0` widget tests; filtering `coverage/lcov.info` to `lib/core/domain/` and `lib/core/data/sync/` confirms `>= 85%` line coverage.
*   **Android Release Build & Merged Manifest Check:** `flutter build apk --release` succeeds with `applicationId = io.github.pvkarthikk.illam`; inspecting `build/app/intermediates/merged_manifests/release/AndroidManifest.xml` confirms `android:allowBackup="false"`, no `android:usesCleartextTraffic="true"`, no Location permissions (`ACCESS_FINE_LOCATION`/`ACCESS_COARSE_LOCATION`), and no `NEARBY_WIFI_DEVICES`.
*   **Physical Android Device Verification Checklist (M2 & M3):** Run on two physical Android phones on home Wi-Fi: mDNS discovery, manual `IP:port` fallback, mid-batch Wi-Fi toggle recovery, airplane-mode divergence + reconnect, clock-skew error banner, and SAF `.nmflat` round-trip via Google Drive and local storage confirming identical `/debug` SHA-256 state digests.

--------------------------------------------------------------------------------

<!-- Provenance: Indicates initial structural drafting via EGM. -->

*Drafted with EGM*
