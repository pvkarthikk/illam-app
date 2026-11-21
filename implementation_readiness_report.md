# Implementation Readiness Report (Stage 9 — Round 1)

* **Target Document:** [docs/designs/nest_mojo_flat_v1.md](./docs/designs/nest_mojo_flat_v1.md) (`DetailedRange`: lines `338..530`)
* **Standard:** `implementation-readiness-standard.md`
* **Goldfish Context:** [concepts_brief.md](./concepts_brief.md), [AGENTS.md](./AGENTS.md)
* **Date:** 2026-11-22
* **Verdict:** **NOT CLEAN (FAIL)** — 10 deduplicated Blockers, 12 Majors, and 5 Nits remain before an engineer can execute `M0–M5` without guessing or breaking the build.

## Reviewer Status

| Reviewer | Status | Raw Findings |
| --- | --- | --- |
| `egm-implementation-readiness` | completed | 7 Blockers, 4 Majors, 2 Nits |
| `egm-codebase-details` | completed | 4 Blockers, 6 Majors, 3 Nits |
| `egm-style` | completed | 2 Blockers, 12 Majors, 2 Nits |

---

## Consolidated Findings

### 🔴 Blockers

#### `ir-1-1` — Pinned package constraints break Android builds on the live AGP `9.3.1` workspace (`egm-codebase-details`)
* **Scope:** `docs/designs/nest_mojo_flat_v1.md` lines 350–352 (Item #2); live `android/settings.gradle.kts` lines 22–23 (`com.android.application` `9.3.1`, Kotlin `2.4.20`).
* **Discrepancy:** `flutter_secure_storage: ^9.2.4` and `mobile_scanner: ^6.0.0` fail Gradle builds under AGP 9 built-in Kotlin (requiring `^10.3.1` and `^7.5.0`), and `drift_flutter: ^0.2.4` pulls obsolete `sqlite3_flutter_libs` (`0.6.0+eol`) instead of `drift_flutter: ^0.3.0` (`sqlite3` `3.x` native build hooks). Because `AGENTS.md` forbids major-version bumps during execution, these ceilings trap the implementer in a broken build.

#### `ir-1-2` — `XChaCha20-Poly1305` 24-byte nonce bug, undecided cipher, and missing wire/backup crypto specs (`egm-implementation-readiness`, `egm-codebase-details`, `egm-style`)
* **Scope:** `docs/designs/nest_mojo_flat_v1.md` lines 197, 201, 207–235, 241–242, 434–449, 454–457.
* **Discrepancy:**
  * Lines 233 and 436 specify `XChaCha20-Poly1305 (or AES-256-GCM)` with a `[12-byte counter nonce]`. In `package:cryptography`, `Xchacha20.poly1305Aead()` strictly requires a **24-byte** nonce and throws `ArgumentError` on 12 bytes (only RFC 8439 `Chacha20.poly1305Aead()` and `AesGcm.with256bits()` use 12-byte nonces). Leaving two ciphers open also violates the Zero-Decision Rule.
  * The `IP:port + 6-digit PIN` pairing fallback has no PAKE/key-exchange protocol to transfer the 256-bit `home_sync_key` without cleartext transmission (and QR encoding/expiry TTL are omitted).
  * Missing wire byte codes (`frame_type`), canonical HMAC transcript layout, HKDF `salt`/`info` strings, fixed batch size (`200–500` is a range), socket timeouts, mDNS hash truncation length, `.nmflat` binary framing (header length prefix separating AAD from ciphertext+tag), and Argon2id constants + `Isolate.run` offloading.

#### `ir-1-3` — Missing exact Drift/SQLite schemas, JSON sub-schemas, composite PK rules, working-day column, and indexes (`egm-implementation-readiness`, `egm-style`)
* **Scope:** `docs/designs/nest_mojo_flat_v1.md` lines 146–154, 173–178, 402–405, 472, 478–481, 484, 494–497.
* **Discrepancy:**
  * None of the 21 Drift tables specify exact column lists, types, nullability/defaults, or primary keys.
  * `maid_salary_calculator.dart` (line 472) and `maid_screen.dart` (line 484) flag unlogged "scheduled working days" as `Unmarked`, yet neither `maids` nor `maid_salary_rules` defines a working-day schedule or weekly-off column.
  * Unresolved composite-key mapping between `SyncedColumns.id` and natural keys (`maid_attendance`, `meal_plan_entries`); missing JSON schemas for `quantity_unit_json`, `status_times_json`, `splits_json`; missing `frozen` column on `pn_counters` and `max_observed_skew_ms` on `device_identity`; `home_members` mixes `active` (line 137) and `removed` (line 191); line 404 uses a wildcard ellipsis `composite indexes on (home_id, deleted, ...)`.

#### `ir-1-4` — Existing `test/core/design/nest_theme_test.dart` breaks in M0 and is omitted from Target Files (`egm-codebase-details`)
* **Scope:** `docs/designs/nest_mojo_flat_v1.md` lines 374–376, 514–516; live `lib/main.dart` and `test/core/design/nest_theme_test.dart`.
* **Discrepancy:** Rewiring `lib/main.dart` to `ProviderScope` + `MaterialApp.router` in M0 immediately breaks both `test/widget_test.dart` (not updated until Item #37) and `test/core/design/nest_theme_test.dart` (which pumps `const MyApp()` directly without `ProviderScope` and expects `MyHomePage` Light/Dark buttons), and `nest_theme_test.dart` is absent from Target Files. Fate of `MyHomePage` and `MyApp.initialThemeMode` is unspecified.

#### `ir-1-5` — Missing required direct packages (`path`, `path_provider`, share mechanism) and Drift/l10n build/generated files (`egm-implementation-readiness`, `egm-codebase-details`)
* **Scope:** `docs/designs/nest_mojo_flat_v1.md` lines 350–352, 364, 366–368, 406–408, 420, 460, 510–512, 520.
* **Discrepancy:**
  * `path` and `path_provider` are required by Drift file resolution and pre-restore SQLite snapshots/SAF temp files but omitted from `pubspec.yaml` (importing transitive `path` triggers `depend_on_referenced_packages` under `flutter_lints: ^6.0.0`).
  * 1-tap "Share store list" (line 420) has neither `share_plus` in `pubspec.yaml` nor an Android `ACTION_SEND` `MethodChannel` in `MainActivity.kt`.
  * Missing `build.yaml` (required by `drift_dev make-migrations`), generated file targets (`lib/core/data/db/app_database.g.dart`, `lib/l10n/app_localizations*.dart`, `test/generated_migrations/**`), and `dart run drift_dev make-migrations` in Verification Plan.

#### `ir-1-6` — Missing Android `MethodChannel` / `EventChannel` contracts, SAF Binder-limit handoff, and Android 14+ Foreground Service spec (`egm-implementation-readiness`, `egm-codebase-details`, `egm-style`)
* **Scope:** `docs/designs/nest_mojo_flat_v1.md` lines 202, 358–365, 438–440, 458–460.
* **Discrepancy:**
  * `MainActivity.kt` omits channel names, method/event names, argument/return schemas, and error codes for NSD/MulticastLock and SAF.
  * Streaming `.nmflat` bytes directly over `MethodChannel` risks Android Binder `TransactionTooLargeException` (> 1 MB); plan must specify temp-file path handoff via Kotlin `ContentResolver.openOutputStream`/`openInputStream`.
  * Line 360 says `declare optional FOREGROUND_SERVICE_DATA_SYNC`, which is undecided and incomplete for Android 14+ (`targetSdk >= 34` requires `FOREGROUND_SERVICE`, `POST_NOTIFICATIONS`, a `<service android:foregroundServiceType="dataSync">` tag, and a Kotlin `Service` class—none of which exist in the plan).

#### `ir-1-7` — Broken M0/M1 milestone buildability due to forward references (`egm-implementation-readiness`, `egm-codebase-details`, `egm-style`)
* **Scope:** `docs/designs/nest_mojo_flat_v1.md` lines 374–377, 428, 514–516.
* **Discrepancy:**
  * M0 wires providers (`appDatabaseProvider`, `changesProvider`, `lanSyncControllerProvider`, `backupServiceProvider`) and routes (`/shopping`..`/debug`) referencing M1–M5 classes/screens that do not exist yet, without stubs or per-milestone staging.
  * M1 Item #20 (`debug_screen.dart`) includes a dry-run `.nmflat` merge validator before M3 creates `backup_codec.dart`/`backup_service.dart`.

#### `ir-1-8` — Unresolved Open Questions left inside the Implementation Plan (`egm-implementation-readiness`, `egm-codebase-details`, `egm-style`)
* **Scope:** `docs/designs/nest_mojo_flat_v1.md` lines 49–50, 234, 352, 388, 444.
* **Discrepancy:** Font `.ttf` bundling (`If custom .ttf bundling is chosen...`) and HLC clock-skew rejection threshold remain unresolved inside M0/M2, and line 50 references a `SyncConfig` class omitted from Target Files.

#### `ir-1-9` — Target Scope & File Boundary violations (`test/features/*_screen_test.dart` wildcard, broken `lib/` mirror, missing cross-milestone edits) (`egm-implementation-readiness`, `egm-codebase-details`, `egm-style`)
* **Scope:** `docs/designs/nest_mojo_flat_v1.md` lines 342–517.
* **Discrepancy:**
  * `test/features/*_screen_test.dart` uses an illegal wildcard for handwritten tests and fails `AGENTS.md` mirrored subdirectory paths (`test/features/<feature>/<name>_screen_test.dart`).
  * `schema_migration_test.dart` is placed under `test/core/data/sync/` instead of `test/core/data/db/`; `test/core/data/change_writer_test.dart` is missing; and cross-milestone edits (`home_setup_screen.dart`, `shopping_screen.dart`, `debug_screen.dart`, `providers.dart`, `router.dart`, `app_en.arb`, `collection_registry.dart`) are not listed as `(Modify)` in later milestones.

#### `ir-1-10` — Dangling `lanSyncControllerProvider` and inconsistent module naming (`egm-style`, `egm-codebase-details`)
* **Scope:** `docs/designs/nest_mojo_flat_v1.md` lines 101, 368, 376, 442–448, 462.
* **Discrepancy:** `lib/core/providers.dart` registers `lanSyncControllerProvider`, but no `LanSyncController` class or `lan_sync_controller.dart` file exists in the plan (Item #23 creates `lan_sync_service.dart`; Item #24 creates `pairing_controller.dart`). Settings/backup uses four inconsistent names (`backup` in diagram, `/settings` route, `settings_backup` folder, `backup*` ARB prefix without `settings*`).

---

### 🟡 Majors

#### `ir-1-11` — Underspecified pure-domain algorithms, constants, and edge cases (`egm-implementation-readiness`, `egm-style`)
* **Scope:** `docs/designs/nest_mojo_flat_v1.md` lines 382–400, 470–476.
* **Discrepancy:** Missing concrete rules/formulas for: `maid_salary_calculator.dart` (half-day weight, multi-shift aggregation, opt-in unmarked-day math, `fixed30` vs. `calendar_days` rounding, mid-month effective-dated proration, override scope), `merge_engine.dart` (concurrent fork tie-break in `resolveActiveRevision`, void-vs-edit precedence, per-table tombstoned columns stripped and undo recovery), `write_policy_gate.dart` (full permission table, `role_epoch` concurrent increment, quarantine accept behavior), `recurrence_engine.dart` (fixed `UUIDv5` namespace UUID, month-end `31` clamping, `custom_days` vs. `daily`+`interval`), `hlc.dart` (`maxLocalDriftMs`, zero-padding/hex casing, 20-bit counter overflow), `expense_split_calculator.dart` (remainder paise tie-break order and net balance definition), and `money.dart` (`.00` omission, negative sign placement, parse error return type).

#### `ir-1-12` — Unspecified `ChangeWriter` APIs, WAL-safe restore snapshot (`VACUUM INTO`), upgrade replay hook, canonical state digest, and owner-recovery flow (`egm-implementation-readiness`, `egm-style`)
* **Scope:** `docs/designs/nest_mojo_flat_v1.md` lines 167, 189, 253, 408, 412, 428, 460, 464, 512.
* **Discrepancy:** Missing exact Dart method signatures for `ChangeBatch`/`ChangeResult`/`UndoToken`/`SyncOp` and Create-Home bootstrap; missing upgrade replay trigger for `applied = 0` ops (`AppDatabase.migration.beforeOpen`); raw SQLite file copy is WAL-unsafe (must use `VACUUM INTO` or `PRAGMA wal_checkpoint(TRUNCATE)` with explicit rollback); canonical SHA-256 digest algorithm is undefined; line 464's "merge-vs-rollback confirmation dialog" and line 189's sole-owner recovery flow do not match `backup_service.dart` (line 460).

#### `ir-1-13` — Underspecified `l10n.yaml`, `data_extraction_rules.xml`, API 26–30 `fullBackupContent`, and `ProviderScope`/`SharedPreferences` startup (`egm-implementation-readiness`, `egm-codebase-details`)
* **Scope:** `docs/designs/nest_mojo_flat_v1.md` lines 352, 360, 376.
* **Discrepancy:** Missing `l10n.yaml` keys (`arb-dir`, `template-arb-file`, `output-localization-file`, `nullable-getter: false`), missing exact XML tags for `data_extraction_rules.xml` plus `android:fullBackupContent` for API 26–30 (`minSdk = 26`), and unclear `ProviderScope` + `SharedPreferences` bootstrap in `lib/main.dart`.

#### `ir-1-14` — Hardcoded `targetSdk = 35` may downgrade Flutter 3.50's default (`egm-codebase-details`)
* **Scope:** `docs/designs/nest_mojo_flat_v1.md` line 356; live `android/app/build.gradle.kts` line 23.
* **Discrepancy:** Use `maxOf(flutter.targetSdkVersion, 35)` (or keep `flutter.targetSdkVersion`) instead of hardcoding `35`. Also calibrate rationale on line 356 (`NsdManager` is API 16 and SAF is API 19; API 26 is driven by Android 8.0+ baseline / `flutter_secure_storage` / `mobile_scanner`).

#### `ir-1-15` — Raw hex color `#12201A` cited in `home_setup_screen.dart` spec (`egm-style`)
* **Scope:** `docs/designs/nest_mojo_flat_v1.md` line 416; `AGENTS.md` line 23.
* **Discrepancy:** References `#12201A` directly under `home_setup_screen.dart`; replace with the `NestColors.brandCanvas` (`context.nest.brandCanvas`) token.

#### `ir-1-16` — Ambiguous "optional" wording across M0, M3, M4 (`egm-style`)
* **Scope:** `docs/designs/nest_mojo_flat_v1.md` lines 352, 360, 460, 488.
* **Discrepancy:** Distinguish build-time scope (decided in/out) from user-selectable runtime actions (`optionally caching derived export key`, `optional 1-tap "Log as Expense"`).

#### `ir-1-17` — Uncalibrated verification plan & missing per-milestone test binding (`egm-implementation-readiness`, `egm-codebase-details`, `egm-style`)
* **Scope:** `docs/designs/nest_mojo_flat_v1.md` lines 504–525.
* **Discrepancy:**
  * `flutter test --coverage` emits LCOV **line** coverage only, not branch coverage (calibrate line 522 to `>= 85% line coverage` with exact `lcov` filter command).
  * Line 512 claims `bit-for-bit identical materialized state` (calibrate to identical canonical materialized domain rows and SHA-256 digests).
  * Line 523 calls Android cleartext attributes "cleartext permissions" and assumes `flutter build apk --release` validates the merged manifest without a manifest inspection step.
  * Line 524 labels one-shot functional scenarios a "Soak Checklist" without duration/stability criteria.
  * Tests (Items 35–37) should bind explicitly to milestone checkpoints `M0–M5`, and `test/fixtures/backup_v1.nmflat` needs its exact test passphrase, `home_id`, ops, and expected assertions.

#### `ir-1-18` — Unbounded M0 `app_en.arb` scope and M5 "+ Polish" label (`egm-style`)
* **Scope:** `docs/designs/nest_mojo_flat_v1.md` lines 368, 492.
* **Discrepancy:** Clarify M0 initializes `app_en.arb` with naming conventions + M0 shell strings (feature keys added in M1–M5), and either list concrete M5 polish tasks (accessibility sweep, font-scale `2.0` audit) or drop `+ Polish`.

#### `ir-1-19` — Inconsistent identifier casing & domain terminology across sections (`egm-style`)
* **Scope:** `docs/designs/nest_mojo_flat_v1.md` lines 33, 88, 241, 388, 392, 396, 404, 428, 456, 472, 483–484, 508.
* **Discrepancy:** Mixes `snake_case` and `camelCase` within the same sentences (`deviceId`/`device_id`, `memberId`/`member_id`, `promotedAt`/`promoted_at`, `schemaVersion`/`hlc_clamp_count`), mismatches backup header names between lines 241 and 456, and alternates between `entry/exit logging` and `check-in/check-out`.

#### `ir-1-20` — Inaccurate `flutter pub add` / "pinned dependencies" phrasing (`egm-style`, `egm-codebase-details`)
* **Scope:** `docs/designs/nest_mojo_flat_v1.md` line 352.
* **Discrepancy:** Caret ranges are "version-constrained" (not pinned), `flutter_localizations` requires `--sdk=flutter`, and `intl` floor in `pubspec.lock` is `^0.20.2` (not `^0.20.0`).

#### `ir-1-21` — Shorthand basenames and combined `Create / Modify` headings (`egm-implementation-readiness`, `egm-codebase-details`, `egm-style`)
* **Scope:** `docs/designs/nest_mojo_flat_v1.md` lines 350, 358, 370, 374, 402, 406, 418, 422, 446, 478, 482, 486, 494, 498, 506, 510.
* **Discrepancy:** Expand every target file to a full repository-relative path with an explicit per-file `(Create)` / `(Modify)` / `(Delete)` tag.

#### `ir-1-22` — Uncalibrated line 340 completeness claim (`egm-style`)
* **Scope:** `docs/designs/nest_mojo_flat_v1.md` line 340.
* **Discrepancy:** Claims per-file rationales and verification gates are explicit, while file headings only list `Type / Scope` and `Proposed Changes`; add explicit per-milestone exit gates and keep per-file rationale explicit.

---

### 🟢 Nits

#### `ir-1-23` — Exact replacement wording for `AGENTS.md` updates (`egm-implementation-readiness`, `egm-codebase-details`)
* **Scope:** `docs/designs/nest_mojo_flat_v1.md` lines 346–348; live `AGENTS.md` lines 22, 32–33, 39.
* **Discrepancy:** Quote exact updated `SyncedColumns` (including `updatedHlc`) and `ChangeWriter` lines for `AGENTS.md` L32–33, align `listsAdded` example with `shopping*`, fix L32's missing closing backtick, and update L39's `# after pubspec changes` comment to mention Drift tables.

#### `ir-1-24` — Filler phrasing and mild buzzwords (`egm-style`)
* **Scope:** `docs/designs/nest_mojo_flat_v1.md` lines 340, 364, 392, 396, 412, 444, 448, 460, 472, 476, 488.
* **Discrepancy:** Trim redundant/subjective wording (`one unified`, `lightweight`, `shared identically`, `Orchestrate`, `brand-new`, `pre-restore safety`, `strictly excluding`, `clean folded`, `actionable error states` without actions).

#### `ir-1-25` — Minor table/column formatting & UI-label capitalization (`egm-style`)
* **Scope:** `docs/designs/nest_mojo_flat_v1.md` lines 400, 420, 478, 484, 494, 496, 500.
* **Discrepancy:** Standardize backticks and `nullable` vs. `optional` on line 496 (and include `recipe_id` on `recipe_ingredients`), replace `"$templateId:$YYYY_MM_DD"` with `"$templateId:$dateIso"`, clarify whether Zepto/DMart/Reliance Bazaar are pre-seeded on Create Home or user-created examples, change `default-ON` to `enabled by default`, and standardize UI label casing (Sentence case).
