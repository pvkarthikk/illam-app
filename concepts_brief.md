# Nest Mojo - Flat: Offline-First Household Management & Local Wi-Fi Sync

* **Author:** Karthik Venkatesh
* **Date:** 2026-11-21

## Overview

Nest Mojo - Flat is an Android-first, offline-first household management app where every member of a home keeps a full local copy of the household's data on their phone and synchronizes directly with other family phones over the same home Wi-Fi network. No central cloud server or user account is required.

The planned v1 covers five text-and-number household modules:

1. **Todos:** One-time and recurring tasks assignable to household members.
2. **Shopping Lists:** Items grouped by online ordering apps (such as Zepto) and offline stores (such as DMart or Reliance Bazaar).
3. **Maid / House-Help Tracking:** Contact and personal details (phone, alternate phone, address, base salary), daily entry/exit attendance logs, and automated monthly salary calculation with manual adjustment controls (advances, deductions, bonuses, overrides).
4. **Manual Expenses:** Household expense ledger with recurring bills, monthly budgets, and member splits.
5. **Meal Planner & Recipes:** Weekly meal schedule linked with recipes (instructions and ingredients).

Home membership uses an owner role model (the home creator is the first owner and can promote other members to owner) with app-level guards restricting membership changes and sensitive maid edits among trusted family devices. Each member can independently back up the full home dataset to personal cloud storage (such as Google Drive or OneDrive) strictly as a portable backup, with bidirectional conflict-resolving merge when restoring onto a replacement phone and reconnecting on home Wi-Fi.

## Analysis

Seven independent Goldfish reviews (`egm-design`, `egm-codebase-details`, `egm-zoom-out`, `egm-comprehension`, `egm-implementation-readiness`, `egm-structural`, and `egm-inventive-catalyst`) inspected the concept and the live workspace (`/home/karthik/flutter_projects/nm_flat`). Their deduplicated findings expose nine core contradictions and risks that need decisions before formal design drafting (`/egm-draft`).

### 1. Backup Restore Breaks `local_seq` Cursors and PN-Counters

* **Contradiction:** Using a persistent `deviceId` and a monotonic `local_seq` delta cursor keeps sync queries simple, but restoring an older cloud backup onto a replacement phone breaks both mechanisms. If the restored phone reuses its backed-up `deviceId` at `local_seq = 500` while another family phone already holds an ACK watermark of `800` for that device, the peer silently skips all new writes `501..800`. Likewise, if a PN-Counter slot `P[deviceId]` rolls back from `8` to `5`, the next three `+1` taps (`6, 7, 8`) are silently swallowed by `max(8, 6)` on sync.
* **Transitive Echo Loop Risk:** Bumping `local_seq` on every incoming row (including no-op duplicates) triggers infinite A↔B sync loops in 3+ phone households.
* **Resolution Pattern (Cheap Dispensables + Segmentation):**
  * Never restore `deviceId`, `local_seq`, or `peer_cursors` from a backup; separate portable domain tables from local-only operational tables.
  * Separate `memberId` (person, used for assignees, payers, and owner roles) from `deviceId` (Android install, used for HLC tie-breaks, PN-Counter slots, and cursors).
  * Mint a fresh `deviceId` on every reinstall or restore, freeze historical `deviceId` slots in PN-Counters as read-only, and feed restored records through the same idempotent CRDT ingest pipeline used by Wi-Fi sync.
  * Advance `local_seq` only when an incoming op actually changes local state (or tag ops with `(origin_replica_id, origin_seq)` and exchange compact version vectors during handshake).
* **Secondary Trade-off:** Every phone replacement adds a new inert `deviceId` entry to PN-Counter maps and peer history, requiring eventual compaction or snapshot reset if a household replaces dozens of devices over many years.

### 2. Cloud Backup Encryption Key Loss vs. Multi-Cloud SDK Bloat

* **Contradiction:** Storing plaintext backups in personal Google Drive/OneDrive leaks maid PII, addresses, daily home presence logs, and household finances. Encrypting backups with a key kept only in `flutter_secure_storage` (Android Keystore) binds the key to the old phone's hardware, making backups unreadable when a phone is lost or broken. Separately, integrating native Google Drive and OneDrive SDKs adds OAuth consent/verification reviews, API quotas, token refresh bugs, and heavy dependencies to an offline-first app.
* **Resolution Pattern (OS-Delegated Cloud + Independent Passphrase):**
  * Define a self-describing encrypted archive format (`.nmflat`) with an authenticated plaintext header (`format_version`, `schema_version`, `home_id`, KDF parameters, salt, nonce) and AEAD-encrypted (XChaCha20-Poly1305 or AES-256-GCM) gzipped JSONL of `sync_ops`—not a raw SQLite `.db` file.
  * Derive the backup key from a user-chosen backup passphrase or generated recovery code via Argon2id (independent of Android Keystore), with optional local caching in `flutter_secure_storage` purely for export convenience.
  * Validate `home_id` before merge and take an automatic local pre-restore SQLite snapshot.
  * Transport backups in v1 via **Android Storage Access Framework (SAF)** (`ACTION_CREATE_DOCUMENT` / `ACTION_OPEN_DOCUMENT`) using new timestamped filenames (avoiding OneDrive SAF in-place overwrite corruption). SAF works with Google Drive, OneDrive, Dropbox, Nextcloud, and local storage with zero cloud SDKs or OAuth maintenance.
* **Secondary Trade-off:** SAF supports manual or reminder-driven backups rather than silent scheduled background uploads, and users must retain their backup passphrase/recovery code to recover after total device loss.

### 3. Offline Recurring Generation and Cross-Field Financial Invariants

* **Contradiction:** Three modules depend on schedules (recurring todos, recurring bills, monthly maid salaries). If two offline phones cross a billing or date boundary and insert rows with random UUIDs, Wi-Fi sync merges permanent duplicate rent bills, duplicate chores, and conflicting salary records. In addition:
  * Storing expense totals and member splits in separate synced rows lets concurrent edits or partial sync break `sum(splits) == total`.
  * Fixing a mistyped ₹5,000 expense to ₹500 using an append-only numeric delta (`-₹4,500`) corrupts the ledger to `-₹4,000` if two members fix the same typo offline.
  * Storing automated monthly maid salary as a static synced scalar silently goes stale when late attendance marks or advances arrive over Wi-Fi.
* **Resolution Pattern (Inversion + Segmentation):**
  * Keep recurring rules and attendance logs as input facts; compute upcoming recurring bills, recurring todo occurrences, and live monthly maid salary owed as deterministic read-time projections.
  * Materialize an occurrence only on explicit human action (such as "Mark Paid" or "Complete") or using deterministic composite IDs (`hash(template_id, YYYY-MM-DD)`) so concurrent offline creation converges on one row.
  * Store an expense total and its full split allocation map atomically inside a single immutable ledger row (integer paise with deterministic remainder allocation).
  * Handle financial typo edits and undo via append-only **superseding snapshots** (`supersedes_id` under a shared `entry_group_id`) with 1-to-1 idempotent void/reversal keys so concurrent fixes to ₹500 converge to ₹500 instead of double-reversing.
  * Support Indian flat maid payroll details explicitly: multi-shift daily keys `(maid_id, date, shift_slot)`, configurable paid-leave quota and divisor (30 days vs. calendar days), effective-dated base salary changes (so raises never rewrite past months), and explicit warning flags when late attendance or advances arrive after a manual salary override.
* **Secondary Trade-off:** Read queries for dashboards, budgets, and monthly balances must aggregate winning leaf revisions and union virtual recurring schedules, and atomic split maps trade away simultaneous editing of two different people's shares on the same expense.

### 4. Permanent Tombstones, Field-LWW Boundaries, and PN-Counter Limits

* **Contradiction:**
  * Irreversible permanent tombstones on natural composite keys (like `(maid_id, YYYY-MM-DD)`) permanently block that date if accidentally deleted, and conflict with `ChangeWriter` delete Undo tokens and weekly re-buying of staple groceries.
  * Applying Field-LWW independently to tightly coupled columns creates invalid states (for example, maid `status = 'absent'` merged with `exit_time = '11:30'`, or a shopping item marked bought at DMart when it was checked off under Zepto).
  * PN-Counters only work for unitless relative `+1`/`-1` deltas. They break when users type exact quantities ("set to 3" on two phones becomes 4), change units ("2 packets" to "500 g"), decrement concurrently below zero (`1 - 1 - 1 = -1`, making the next `+1` display `0`), or tap `+1` offline while a partner checks off/deletes the item.
* **Resolution Pattern:**
  * Distinguish **permanent row retention** (never hard-delete rows, stripping heavy text payload fields on tombstoned rows to limit growth) from **Field-LWW `deleted` / row `epoch` semantics** so delete-Undo emits a newer compensating op at a higher HLC while older backups still lose to the deletion.
  * Group tightly coupled columns into atomic single-LWW values (e.g., maid `(status, entry_time, exit_time)` per shift; shopping item `quantity + unit` as Field-LWW if freeform units are allowed, restricting PN-Counters strictly to unitless relative counters or epoch-scoped check-off counters).
  * Separate shopping item "checked off / bought" state from "permanently deleted" (tombstoned), and store online-app/offline-store channels as soft-referenced tags with an "Any store / Unassigned" default.
* **Secondary Trade-off:** Stripping tombstoned payloads keeps SQLite small, while giving up PN-Counters on mixed-unit shopping quantities means simultaneous edits to the same item's quantity resolve via LWW instead of summing.

### 5. Drift-Clamped HLC Convergence and Clock-Skew Lockout

* **Contradiction:** Rewriting or clamping an *incoming* peer's future HLC breaks CRDT commutativity across 3+ phones (different peers store different timestamps for the same op). Conversely, hard-rejecting skewed packets stalls sync until the clock is fixed, and an unclamped fast phone can "future-lock" fields so normal-clock phones lose subsequent intentional edits.
* **Resolution Pattern:**
  * Never mutate an accepted peer op's wire HLC. Clamp only local wall-clock jumps before stamping new local writes, reject sync handshakes exceeding a fixed skew threshold (such as ±5–15 minutes) with an actionable UI prompt ("Check device date and time"), and consider ordering Field-LWW on `(field_lamport_version, hlc, deviceId)` so intentional sequential "see-then-edit" writes win even under minor clock offset.
  * Track `hlcClampCount` and `maxObservedSkewMs` in `/debug` so clock issues are visible instead of silent.
* **Secondary Trade-off:** Adding a per-field Lamport version adds one integer column per tracked field clock; simultaneous offline edits at the same version still rely on wall-clock HLC + `deviceId`.

### 6. LAN Transport Security, Android Doze, and Router Discovery Failures

* **Contradiction:**
  * Plaintext LAN sync exposes maid phone numbers, home addresses, daily home presence logs, and household spending on shared apartment Wi-Fi, and violates Android 9+ cleartext restrictions.
  * Users assume "home Wi-Fi sync" runs silently in the background, but Android Doze and Xiaomi/Samsung/OnePlus battery killers terminate background sockets, and consumer routers (JioFiber, Airtel Xstream, dual-band mesh) frequently block mDNS multicast or isolate 2.4GHz and 5GHz clients.
  * Checking Wi-Fi SSIDs on Android 10+ triggers fine Location permission prompts.
* **Resolution Pattern:**
  * Pair devices via an Owner-displayed QR code or short PIN that exchanges a 256-bit `home_sync_key` out of band (never sent in plaintext over Wi-Fi), and encrypt/authenticate all LAN sync traffic using that key. Advertise only an opaque salted hash of `home_id` over mDNS (`NsdManager` + scoped `WifiManager.MulticastLock`)—avoiding SSID checks and Location permissions entirely—and include a manual `IP:port` / QR direct-connect fallback when multicast fails.
  * Set an explicit foreground-first sync contract: auto-sync whenever two apps are open on the same Wi-Fi, show a per-member "Last synced" freshness indicator, provide a "Sync Now" action (with an optional short-lived sync notification), and add a 1-tap plain-text "Share store list" button as a zero-infrastructure bridge for away-from-home shopping.
* **Secondary Trade-off:** Family members need both apps open on Wi-Fi (or one phone in brief Sync Mode) for updates to exchange, and away-from-home shopping lists remain point-in-time snapshots until returning home.

### 7. App-Level Owner Role Guards: Lockout, Stale Edits, and Eviction

* **Contradiction:** Without cryptographic sync-layer RBAC, UI-only owner checks leave three gaps: (a) two offline owners can mutually demote each other leaving zero owners; (b) losing the sole owner's phone permanently locks out household administration; and (c) a demoted member or restored older backup can emit owner-only edits that Field-LWW blindly applies, while a removed member who keeps `home_sync_key` can still read LAN sync.
* **Resolution Pattern:**
  * Centralize permission checks in one domain write-policy gate (not scattered across UI widgets) and enforce a deterministic last-owner invariant (multi-owner support + tie-break on mutual demotion by oldest-owner / `memberId`, plus a documented recovery path if the sole owner's phone is lost).
  * Tag governance/owner-guarded writes with a `role_epoch` tied to the membership table and flag/quarantine stale-authority synced edits for owner review instead of silently breaking convergence or hiding changes.
  * Reject handshakes from members marked removed in `home_members`, and explicitly inform the owner on member removal that rotating the home LAN key (re-pairing remaining phones) is required to cut off an uncooperative device.
* **Secondary Trade-off:** App-level enforcement prevents accidental stale-state overrides among cooperative family members, not malicious tampering by someone with root access to SQLite.

### 8. Scope Size, Cross-Version Compatibility, and Storage Architecture

* **Contradiction:** Shipping all 5 modules, a multi-primitive CRDT sync engine, and encrypted multi-cloud backups from a greenfield repo creates high delivery risk. Furthermore, family phones update app versions on different days; if an older phone drops unknown columns during sync or backup, newer data disappears across the household. Unpaginated initial sync over 3–5 years of permanent tombstones can also cause OOM/GC jank or `SQLITE_BUSY` lock contention on budget 3–4 GB Android phones.
* **Resolution Pattern:**
  * Use a unified `sync_ops` op-log (`local_seq`, `op_id`, `home_id`, `table_name`, `row_id`, `op_type`, `field_name`, `payload_json`, `hlc`, `device_id`, `schema_ver`) plus CRDT metadata tables (`field_clocks`, `pn_counters`) materialized synchronously into Drift domain tables inside SQLite WAL transactions.
  * Persist unknown `table_name` / `field_name` ops durably in `sync_ops` (with a deferred/unapplied flag) so older app versions relay them intact and materialize them upon upgrade.
  * Ban SQL `FOREIGN KEY ... ON DELETE CASCADE` across synced tables (to prevent out-of-order sync crashes and tombstone breakage); keep modules decoupled via value copies and weak optional `source_ref` IDs.
  * Paginate all Wi-Fi sync transfers into fixed chunks (e.g., 200–500 ops, <= 1 MB uncompressed per chunk), committing one SQLite transaction per chunk with explicit ACK checkpoints.
  * Deliver in vertical slices: validate `ChangeWriter` + sync engine + LAN pairing on 1–2 pilot modules (Shopping Lists / Todos) across two real Android phones before layering Maid Payroll, Expenses, Meal Planner, and SAF Backups.

### 9. Live Codebase & `AGENTS.md` Discrepancies Found

Direct inspection of `/home/karthik/flutter_projects/nm_flat` uncovered concrete blockers to resolve in Slice 0:

* **Greenfield state:** Only `lib/main.dart`, `lib/core/design/{nest_colors,nest_theme,nest_background}.dart`, `test/widget_test.dart`, and `test/core/design/nest_theme_test.dart` exist. `pubspec.yaml` contains only `material_ui: ^1.1.0`, `cupertino_icons`, and `flutter_lints`—none of Riverpod 3, `go_router` 18, Drift, `shared_preferences`, `flutter_secure_storage`, `l10n`, LAN discovery, or crypto libraries are installed yet.
* **`AGENTS.md` typos:** Line 17 reads `Import package:flutter/material.dart – never package:flutter/material.dart` (actual codebase imports `package:material_ui/material_ui.dart`), and line 24 uses GBP `£` (`£1 = 100`, `£1,234`) alongside paise and Indian grouping (should be INR `₹`).
* **`AGENTS.md` `SyncedColumns` gap:** The documented row-level `SyncedColumns` lacks `sync_ops`, per-field HLC clocks, `local_seq`, and PN-Counter storage, and `ChangeWriter` undo semantics must align with append-only financial entries and permanent tombstones.
* **Android manifest & Gradle gaps:** `android/app/build.gradle.kts` still uses `com.example.nm_flat` instead of `app.nestmojo` (and `MainActivity.kt` is in `com.example.nm_flat`). `android/app/src/main/AndroidManifest.xml` has zero `<uses-permission>` entries (`INTERNET` exists only in `debug/` and `profile/`), lacks `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE`, and `CHANGE_WIFI_MULTICAST_STATE`, and omits `android:allowBackup="false"` (which lets Android Auto Backup clone `deviceId` across phones and corrupt CRDT cursors/counters).
* **Unbundled fonts & title punctuation:** `NestTheme` references `'Hanken Grotesk'` and `'Young Serif'`, but no `.ttf` files are registered in `pubspec.yaml`; `AGENTS.md` uses `Nest Mojo : Flat` while app manifests/code use `Nest Mojo - Flat`.
* **On-device observability:** Because there is no central server, a bounded local sync ring-buffer log (keyed by `syncSessionId`), per-peer cursor status, deterministic state digests, and the `kDebugMode`-only `/debug` hub must be built alongside the sync core.

### Ideal Final Result (IFR)

Every family member uses Nest Mojo - Flat offline on Android across all five household routines without waiting for network connectivity or paying for backend hosting. Whenever two or more family phones are open on home Wi-Fi, encrypted chunked sync converges all devices deterministically—preserving concurrent edits, never duplicating recurring bills or chores, never losing money corrections, and surfacing clear freshness and clock warnings. Any member can export a passphrase-encrypted backup through Android's native picker to Google Drive, OneDrive, or local storage, restore it onto a replacement phone with a fresh `deviceId`, and rejoin home Wi-Fi so the newest state wins across the household without resurrecting deleted items.

## Goals vs. Non-Goals

* **In-Scope Goals:**
  * Android-first, offline-first household app (`app.nestmojo`, display name `Nest Mojo - Flat`) with full local data copy per member.
  * Five text-and-number modules: assignable one-time/recurring todos; store/app-grouped shopping lists; maid details, daily entry/exit attendance, and automated/adjustable monthly salary calculation; manual expenses with recurring bills, budgets, and member splits; meal planner with recipes and ingredients.
  * Owner role model (creator as first owner, owner promotion) with centralized app-level write guards for membership and sensitive maid edits, plus a deterministic last-owner invariant.
  * Authenticated, encrypted home Wi-Fi LAN sync using a unified `sync_ops` + Drift materialized-table merge engine (drift-clamped HLC with `deviceId` tie-break, `local_seq` / version-vector delta cursors with transactional ACK batches, atomic/field-level LWW, append-only superseding financial rows, deterministic recurring keys, and permanent tombstone retention).
  * Per-member encrypted portable backup and bidirectional restore merge (minting a fresh `deviceId` on restore), plus `/debug` on-device sync diagnostics (`kDebugMode`).
  * Multi-node in-memory CRDT simulation tests, Drift step-by-step schema migration tests, and encrypted backup golden-file tests.
* **Out-of-Scope Non-Goals:**
  * Away-from-home / cellular mobile-network sync in v1 (deferred to post-v1).
  * Media, photo, bill receipt, or ID-proof attachments in v1 (text and structured data only).
  * iOS build and App Store release in v1 (deferred until user demand/funding).
  * Cryptographic sync-layer RBAC and adversarial threat models against rooted/malicious household devices.
  * Live cloud backend, user accounts, or using Google Drive/OneDrive as a real-time sync server.
  * Multi-currency accounting or Splitwise-style multi-hop debt-simplification graphs.

## Alternatives Weighed

* **Away-from-home WebRTC P2P sync in v1** — Rejected by author: direct cellular P2P behind Indian carrier CGNAT still requires public signaling and TURN relay servers plus simultaneous phone wakefulness (failing under Android Doze). Deferred out of v1 in favor of home Wi-Fi sync first.
* **OR-Sets / LWW-Element-Sets for collections** — Rejected by author: adds per-element tag bookkeeping that is unnecessary for 2–5 person households; normalized child rows with tombstones converge with less complexity.
* **Retention-window tombstone garbage collection** — Rejected by author: purging tombstones after a retention window causes older personal cloud backups to resurrect deleted records on bidirectional restore. Permanent tombstone retention (with optional payload stripping) is viable for text-only household volumes.
* **Using raw HLC as the delta-sync cursor** — Rejected by author: misses late-arriving older-HLC writes across 3+ peers. Replaced by local monotonic receive sequence (`local_seq`) / version vectors for cursor paging while keeping HLC for causal merge ordering.
* **Cryptographic sync-layer RBAC** — Rejected by author: adds key-rotation and per-op signature overhead unnecessary for trusted family households in v1; replaced by centralized app-level owner guards and stale-authority flagging.
* **Native Google Drive & OneDrive OAuth SDKs** — Rejected by author: native cloud SDKs add Google restricted-scope OAuth verification, API quotas, token refresh failures, and multi-vendor maintenance for a backup-only feature. Replaced with Android Storage Access Framework (SAF) writing timestamped passphrase-encrypted `.nmflat` files, which works across Google Drive, OneDrive, Dropbox, Nextcloud, and local storage with zero cloud SDKs.
* **Shipping all 5 modules in one unvalidated build** — Rejected by author: building all five modules before validating multi-phone Wi-Fi sync creates high rewrite risk. Replaced with incremental vertical milestones that prove the sync core and LAN pairing on physical Android phones with pilot modules first.
* **PN-Counters on mixed-unit shopping quantities** — Rejected by author: PN-Counters mishandle direct quantity entry, unit changes (`2 packs` vs. `500 g`), negative underflow, and check-off races. Replaced with atomic Field-LWW for freeform `quantity + unit` fields, restricting PN-Counters strictly to unitless relative integer counters (if used).
* **Plaintext LAN sync & SSID-based home checks** — Rejected by author: exposes maid PII, home presence logs, and household finances on shared apartment Wi-Fi, violates Android 9+ cleartext restrictions, and triggers Android Location permission prompts for SSID reads. Replaced with QR/PIN pairing exchanging a 256-bit `home_sync_key`, encrypted LAN transport, opaque salted `home_id` mDNS advertisement, and manual `IP:port` / QR fallback.
* **Numeric delta reversals for expense typos & separate synced split rows** — Rejected by author: concurrent offline typo fixes double-reverse balances, and separate split rows break `sum(splits) == total`. Replaced with append-only superseding snapshots (`supersedes_id` under `entry_group_id`) with 1-to-1 idempotent void keys and atomic embedded split maps.

## Key Decisions & Staging for Next Steps

All open decisions from the Goldfish review are locked for `/egm-draft`:

1. **Backup transport & encryption (D1 — Locked):** Use **Android Storage Access Framework (SAF)** with timestamped passphrase-encrypted `.nmflat` archives (Argon2id + AEAD over gzipped JSONL of `sync_ops`, authenticated `home_id` header, automatic pre-restore local snapshot). Every restore mints a fresh `deviceId` (preserving `memberId`), clears `peer_cursors`, freezes historical PN-Counter slots, and runs restored ops through the standard CRDT merge pipeline.
2. **Sync storage & CRDT boundaries (D2 — Locked):** Adopt a unified `sync_ops` op-log (`local_seq`, `op_id`, `home_id`, `table_name`, `row_id`, `op_type`, `field_name`, `payload_json`, `hlc`, `device_id`, `schema_ver`) plus CRDT metadata tables (`field_clocks`, `pn_counters`) materialized synchronously into Drift domain tables in SQLite WAL transactions. Preserve unrecognized tables/fields in `sync_ops` across staggered app updates, ban `ON DELETE CASCADE` foreign keys across synced tables, strip heavy payload text on permanently retained tombstones, and use atomic Field-LWW for coupled fields and `quantity + unit` shopping values (restricting PN-Counters strictly to unitless relative counters). Never rewrite incoming peer HLCs; clamp only local clock jumps and order sequential edits via `(field_lamport_version, hlc, deviceId)` with visible clock-skew warnings.
3. **LAN security & foreground sync UX (D3 — Locked):** Mandate Owner-initiated QR/PIN pairing exchanging a 256-bit `home_sync_key` for encrypted/authenticated LAN transport, `NsdManager` + scoped `MulticastLock` advertising only an opaque salted `home_id` hash, and manual `IP:port` / QR fallback. Commit to foreground opportunistic Wi-Fi sync (auto-sync when open on Wi-Fi, chunked 200–500 op batches with explicit ACK watermarks, per-member "Last synced" badge, manual "Sync Now" with optional short-lived sync notification) plus a 1-tap plain-text "Share store list" export for away-from-home shopping.
4. **Financial, recurring, & maid payroll rules (D4 — Locked):** Use append-only superseding snapshots (`supersedes_id`) for expense/maid-ledger corrections and undo, embed integer-paise split maps atomically inside each expense row, compute recurring schedules and live monthly maid salary at read time (materializing instances on human action or deterministic composite IDs `hash(template_id, YYYY-MM-DD)`), key maid attendance by `(maid_id, date, shift_slot)` with atomic `(status, entry_time, exit_time)`, support configurable paid-leave quotas and 30-day vs. calendar-day divisors with effective-dated salary rates, flag late attendance/advances arriving after a manual override, and provide an optional toggle (default ON, linked by weak reference) to log a maid salary payout in Expenses.
5. **Roles, cross-module handoffs, & module scope (D5 — Locked):** Centralize app-level owner guards in one domain write-policy gate with a deterministic last-owner invariant, `role_epoch` tagging to flag stale-authority synced edits, and an owner warning on member removal that LAN key rotation/re-pairing is required for uncooperative devices. Support 1-tap Recipes → Shopping List ingredient push (value copies with optional weak `source_ref`), 1-tap Shopping List → Expenses logging, free-text meal slots alongside structured recipes, and simple equal/custom expense splits with monthly net summary (excluding settlements from monthly budgets).
6. **Delivery sequencing, diagnostics, & Slice 0 housekeeping (D6 — Locked):** Fix [AGENTS.md](file:///home/karthik/flutter_projects/nm_flat/AGENTS.md) (`package:material_ui/material_ui.dart`, INR `₹`, updated `SyncedColumns` / `ChangeWriter` sync contract), rename Android `applicationId`/`namespace`/`MainActivity.kt` to `app.nestmojo`, add required Wi-Fi/network permissions and `android:allowBackup="false"` in `AndroidManifest.xml`, decide final `.ttf` font bundling for `Hanken Grotesk` and `Young Serif`, build `/debug` diagnostics (bounded `syncSessionId` ring-buffer, peer cursors, state digests, clock-skew counters) alongside the sync core, and roll out in vertical slices (M0 Foundation → M1 Core CRDT + Shopping/Todos → M2 Encrypted Wi-Fi Sync verified on two real Android phones → M3 Encrypted SAF Backup/Restore → M4 Maid Payroll & Expenses → M5 Meal Planner & Polish).
