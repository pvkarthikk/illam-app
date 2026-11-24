# Goldfish Annotated Review Report

* **Status:** resolved
* **Target:** `docs/designs/nest_mojo_flat_v1.md` (`Lines 338-530`, with linked updates in `Lines 47-51`, `101`, `197`, `233`, `241`, `306`)

## Prioritized Findings & AI Suggestions

### [Issue 1] [`egm-codebase-details`] - Severity: Blocker (`ir-1-1`)
*   **Affected Scope:** [Lines 350-352](docs/designs/nest_mojo_flat_v1.md#L350-L352) (M0 Item 2: `pubspec.yaml`)
*   **Discrepancy Description:** `flutter_secure_storage: ^9.2.4` and `mobile_scanner: ^6.0.0` fail Gradle builds under this workspace's live AGP `9.3.1` / built-in Kotlin (`android/settings.gradle.kts`), and `drift_flutter: ^0.2.4` pulls obsolete `sqlite3_flutter_libs` (`0.6.0+eol`) instead of `sqlite3` `3.x` native build hooks.
*   **Rationale:** `AGENTS.md` forbids running `flutter pub upgrade --major-versions`, so pinning incompatible ceilings traps the implementer in a broken Android build.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** Verified directly against `android/settings.gradle.kts` (`9.3.1`). Raising constraints to AGP 9 / `sqlite3 3.x` compatible versions eliminates the build failure before coding starts.
*   ***Proposed Edit:***
    *   Location: M0 Item 2 (`pubspec.yaml`)
    *   Change: Update constraints to `flutter_secure_storage: ^10.3.1`, `mobile_scanner: ^7.5.0`, `drift_flutter: ^0.3.0`, and `intl: ^0.20.2`.

### [Issue 2] [`egm-implementation-readiness`, `egm-codebase-details`, `egm-style`] - Severity: Blocker (`ir-1-2`)
*   **Affected Scope:** [Lines 197, 207-235, 241-242, 434-457](docs/designs/nest_mojo_flat_v1.md#L434-L457) (Technical Plan §6–7 & M2–M3 Crypto/Wire Specs)
*   **Discrepancy Description:** Specifies `XChaCha20-Poly1305 (or AES-256-GCM)` with a 12-byte counter nonce (`Xchacha20.poly1305Aead()` strictly requires a 24-byte nonce and throws `ArgumentError` on 12 bytes). Also omits the 6-digit PIN key-exchange protocol, wire `frame_type` byte codes, canonical HMAC transcript, HKDF labels, fixed batch limit, socket timeouts, mDNS hash length, `.nmflat` binary header framing, and Argon2id parameters + isolate execution.
*   **Rationale:** Undecided ciphers and a nonce-size bug break runtime cryptography and deterministic wire interoperability.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** All three reviewers caught the 12-byte vs. 24-byte nonce bug and missing wire/backup constants. Locking one cipher per layer and replacing the unauthenticated 6-digit PIN fallback with a copy-pasteable Base32 pairing token removes all cryptographic ambiguity.
*   ***Proposed Edit:***
    *   Location: Section 6, Section 7, M2 Items 21–24, M3 Item 25
    *   Change: Lock LAN TCP frames to RFC 8439 `ChaCha20-Poly1305` (`Chacha20.poly1305Aead()`, 12-byte counter nonce: 4 zero bytes + 8-byte big-endian counter) and `.nmflat` backups to `XChaCha20-Poly1305` (`Xchacha20.poly1305Aead()`, 24-byte random nonce). Replace 6-digit PIN fallback with manual copy/paste of a Base32-encoded pairing token (`{home_id, home_sync_key, host_ip, port, pairing_nonce, expires_at_ms}`, 5-minute TTL). Specify `frame_type` byte codes (`0x01 HELLO_INIT`, `0x02 HELLO_RESP`, `0x03 OPS_BATCH`, `0x04 OPS_ACK`, `0x05 CLOSE_OK`, `0x06 ERR_CLOCK_SKEW`, `0x07 ERR_AUTH`), canonical sorted-key UTF-8 JSON HMAC transcripts, HKDF `info` labels (`illam-lan-v1-init-to-resp` / `illam-lan-v1-resp-to-init`), batch size `250`, timeouts (`connect 5s`, `handshake 10s`, `frameRead 15s`), mDNS `h=` first 16 lowercase hex chars of SHA-256 + `p=1`, `.nmflat` binary framing `[4-byte big-endian header_len][header_utf8_json][ciphertext][16-byte tag]`, and Argon2id params (`kdf_mem_kib: 65536`, `kdf_iters: 3`, `kdf_parallelism: 1`, 16-byte salt, run via `Isolate.run`).

### [Issue 3] [`egm-implementation-readiness`, `egm-style`] - Severity: Blocker (`ir-1-3`)
*   **Affected Scope:** [Lines 146-154, 173-178, 402-405, 472-497](docs/designs/nest_mojo_flat_v1.md#L402-L497) (Drift Table Schemas, JSON Sub-Schemas, Indexes)
*   **Discrepancy Description:** All 21 Drift tables omit exact columns, SQLite/Drift types, PKs, defaults, and indexes; `maids`/`maid_salary_rules` lack a scheduled working-days column required by opt-in unmarked-day flagging; composite-key mapping to `SyncedColumns.id` is undefined; JSON schemas for `quantity_unit_json`, `status_times_json`, `splits_json` are missing; `pn_counters.frozen` and `device_identity.max_observed_skew_ms` are omitted; `home_members` mixes `active` and `removed`.
*   **Rationale:** Violates the Zero-Decision Rule; an implementer cannot author Drift table classes without inventing columns, types, and indexes.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** Adding a compact, explicit Drift DDL/column reference table and JSON sub-schemas directly inside the Detailed Implementation Plan locks every table across `v1`, `v2`, and `v3`.
*   ***Proposed Edit:***
    *   Location: Detailed Implementation Plan (before M1 table files and within M1/M4/M5 table items)
    *   Change: Add complete column/type/PK/default/index specification for all 21 tables, standardize `home_members.status` (`'active' | 'removed'`), add `maid_salary_rules.working_days_mask` (7-bit Mon–Sun bitmask, default `127` = all days), add `pn_counters.frozen` (`INTEGER DEFAULT 0`) and `device_identity.max_observed_skew_ms` (`INTEGER DEFAULT 0`), define deterministic composite `id` strings (`"$maidId:$date:$shiftSlot"`, `"$date:$slot"`), and define exact JSON schemas for `quantity_unit_json` (`{"qty": double, "unit": string}`), `status_times_json` (`{"status": "present"|"half_day"|"absent", "entry_time": "HH:mm"?, "exit_time": "HH:mm"?}`), and `splits_json` (`[{"member_id": string, "paise": int}]`).

### [Issue 4] [`egm-codebase-details`] - Severity: Blocker (`ir-1-4`)
*   **Affected Scope:** [Lines 374-376, 514-516](docs/designs/nest_mojo_flat_v1.md#L374-L376) (M0 `lib/main.dart` & Test Updates)
*   **Discrepancy Description:** Rewiring `lib/main.dart` in M0 immediately breaks `test/widget_test.dart` (deferred to Item 37) and `test/core/design/nest_theme_test.dart` (omitted from Target Files), and leaves the fate of `MyHomePage` and `MyApp.initialThemeMode` unspecified.
*   **Rationale:** M0 fails `flutter test` unless both existing test files are in M0's write allowlist and `MyHomePage` / `MyApp` changes are stated explicitly.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** Verified directly in `test/core/design/nest_theme_test.dart` lines 60–94.
*   ***Proposed Edit:***
    *   Location: M0 Item 8 (`lib/main.dart`) and M0 Test Checkpoint
    *   Change: Specify removing the template `MyHomePage` widget from `lib/main.dart`, keeping `MyApp({super.key, this.initialThemeMode})` wrapped in `ProviderScope` inside `main()`, and adding `test/widget_test.dart` (`Modify`) and `test/core/design/nest_theme_test.dart` (`Modify`) directly to M0 so M0 exits with all tests green.

### [Issue 5] [`egm-implementation-readiness`, `egm-codebase-details`] - Severity: Blocker (`ir-1-5`)
*   **Affected Scope:** [Lines 350-352, 364-368, 406-408, 420, 460, 510-520](docs/designs/nest_mojo_flat_v1.md#L350-L352) (Missing Packages, `build.yaml`, & Generated Outputs)
*   **Discrepancy Description:** `path` and `path_provider` are omitted from `pubspec.yaml` (violating `depend_on_referenced_packages` and `AGENTS.md` package lock); 1-tap "Share store list" has neither `share_plus` nor a Kotlin `ACTION_SEND` handler; `build.yaml`, generated outputs (`app_database.g.dart`, `lib/l10n/app_localizations*.dart`, `test/generated_migrations/**`), and `dart run drift_dev make-migrations` are missing.
*   **Rationale:** Implementation fails static analysis and Drift migration tooling without these explicit files and dependencies.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** Adding direct `path: ^1.9.1` and `path_provider: ^2.1.5`, adding `shareText` to `MainActivity.kt` (zero extra share dependency), adding `build.yaml` (`Create`), listing generated outputs explicitly, and adding `dart run drift_dev make-migrations` to the Verification Plan makes every build step executable.
*   ***Proposed Edit:***
    *   Location: M0 Items 2, 5, 6; M1 Item 15; Verification Plan
    *   Change: Add `path: ^1.9.1` and `path_provider: ^2.1.5` to `pubspec.yaml`, add `build.yaml` (`Create`) configuring Drift schema directory `drift_schemas/`, add `io.github.pvkarthikk.illam/share` (`shareText`) to `MainActivity.kt`, explicitly list generated outputs (`lib/core/data/db/app_database.g.dart`, `lib/l10n/app_localizations*.dart`, `test/generated_migrations/**`), and add `dart run drift_dev make-migrations` to Verification Plan.

### [Issue 6] [`egm-implementation-readiness`, `egm-codebase-details`, `egm-style`] - Severity: Blocker (`ir-1-6`)
*   **Affected Scope:** [Lines 202, 358-365, 438-460](docs/designs/nest_mojo_flat_v1.md#L358-L365) (Android `MainActivity.kt` Channels, SAF Binder Limit, & Foreground Service)
*   **Discrepancy Description:** Omits channel/method/event names and error codes for NSD and SAF; passing raw `.nmflat` bytes over `MethodChannel` risks Android Binder `TransactionTooLargeException` (> 1 MB); `declare optional FOREGROUND_SERVICE_DATA_SYNC` is undecided and incomplete for Android 14+ (missing `FOREGROUND_SERVICE`, `POST_NOTIFICATIONS`, `<service>` manifest tag, and Kotlin `Service` class).
*   **Rationale:** Implementers in M0/M2/M3 would invent incompatible channel contracts or hit runtime `TransactionTooLargeException` / `SecurityException`.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** Specifying exact channel signatures, temp-file path handoff for SAF, and dropping `FOREGROUND_SERVICE_DATA_SYNC` in v1 (keeping sync purely foreground-while-open with zero `POST_NOTIFICATIONS` prompt or extra Kotlin `Service`) eliminates both runtime crash classes and reduces manifest complexity.
*   ***Proposed Edit:***
    *   Location: Section 6, M0 Items 4–5, M2 Item 22, M3 Item 26
    *   Change: Remove `FOREGROUND_SERVICE_DATA_SYNC` from v1 (sync runs while app is open in foreground, using an in-app progress banner during Sync Now). Define exact native contracts in `MainActivity.kt`:
        *   `MethodChannel('io.github.pvkarthikk.illam/lan_nsd')`: `startAdvertise({serviceName, port, homeHash, protocolVer})`, `stopAdvertise()`, `startBrowse()`, `stopBrowse()`; `EventChannel('io.github.pvkarthikk.illam/lan_nsd_events')` emitting `{event: "found"|"lost", host, port, homeHash, protocolVer}`.
        *   `MethodChannel('io.github.pvkarthikk.illam/saf')`: `exportFile({suggestedName, sourceTempPath}) -> bool` and `importFile({destTempPath}) -> bool` (Dart writes/reads `.nmflat` via `getTemporaryDirectory()`, Kotlin copies via `ContentResolver.openOutputStream`/`openInputStream` with 64 KB buffers, avoiding Binder limits).
        *   `MethodChannel('io.github.pvkarthikk.illam/share')`: `shareText({text, subject}) -> void` via `Intent.ACTION_SEND`.

### [Issue 7] [`egm-implementation-readiness`, `egm-codebase-details`, `egm-style`] - Severity: Blocker (`ir-1-7`)
*   **Affected Scope:** [Lines 374-377, 428](docs/designs/nest_mojo_flat_v1.md#L374-L377) (M0 & M1 Forward References)
*   **Discrepancy Description:** M0 wires M1–M5 providers and routes in `providers.dart`/`router.dart` before those classes exist, and M1 `debug_screen.dart` includes a dry-run `.nmflat` validator before M3 creates `backup_codec.dart`.
*   **Rationale:** Violates the Phasing & Checkpoints rule that each milestone leaves the codebase buildable and testable.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** Staging `providers.dart`, `router.dart`, `app_en.arb`, `collection_registry.dart`, and `debug_screen.dart` incrementally per milestone guarantees every milestone compiles and passes tests independently.
*   ***Proposed Edit:***
    *   Location: M0 Item 8, M1 Item 20, and M1–M5 milestone lists
    *   Change: In M0, `providers.dart` defines only `sharedPreferencesProvider` and `themeModeProvider`, and `router.dart` defines only `/` (placeholder shell) and `/settings` (theme toggle stub). Each subsequent milestone (`M1–M5`) explicitly lists `(Modify)` for `providers.dart`, `router.dart`, and `app_en.arb` to register its own providers/routes/strings. Defer the `.nmflat` dry-run validator in `debug_screen.dart` to M3 `(Modify)`.

### [Issue 8] [`egm-implementation-readiness`, `egm-codebase-details`, `egm-style`] - Severity: Blocker (`ir-1-8`)
*   **Affected Scope:** [Lines 49-50, 234, 352, 388, 444](docs/designs/nest_mojo_flat_v1.md#L49-L50) (Open Questions Inside Plan & Missing `SyncConfig`)
*   **Discrepancy Description:** Two Open Questions remain unresolved inside M0/M2: (a) whether to bundle `Hanken Grotesk` and `Young Serif` `.ttf` assets under `assets/fonts/` vs. keep platform fallbacks, and (b) the HLC clock-skew threshold plus missing `SyncConfig` file in Target Files.
*   **Rationale:** The Zero-Decision Rule forbids conditional implementation instructions (`If custom .ttf bundling is chosen...`).
*   ***AI Suggestion:*** ESCALATE
*   ***Justification:*** `SyncConfig` (`lib/core/data/sync/sync_config.dart`, locking `kMaxClockSkewMs = 300000` / 5 minutes, `kOpsBatchSize = 250`, and socket timeouts) can be locked directly, **but** whether you want to download and commit `Hanken Grotesk` + `Young Serif` `.ttf` font files into `assets/fonts/` in M0 or keep the configured system font fallbacks for v1 is an author product/asset decision not recorded in any workspace file.
*   ***Proposed Edit:***
    *   Location: Open Questions (lines 47–51), M0 Item 2, and M2 new file `lib/core/data/sync/sync_config.dart` (`Create`)
    *   Change: Add `lib/core/data/sync/sync_config.dart` (`Create`) locking `kMaxClockSkewMs = 300000` (5 minutes), and resolve font `.ttf` bundling per your answer below so **Open Questions** is empty before implementation.

### [Issue 9] [`egm-implementation-readiness`, `egm-codebase-details`, `egm-style`] - Severity: Blocker (`ir-1-9`)
*   **Affected Scope:** [Lines 342-517](docs/designs/nest_mojo_flat_v1.md#L342-L517) (File Boundary Allowlist & Mirrored Test Paths)
*   **Discrepancy Description:** Uses illegal handwritten wildcard `test/features/*_screen_test.dart`, misplaces `schema_migration_test.dart` under `test/core/data/sync/` instead of `test/core/data/db/`, omits `test/core/data/change_writer_test.dart`, and omits cross-milestone `(Modify)` listings (`home_setup_screen.dart`, `shopping_screen.dart`, `debug_screen.dart`, `collection_registry.dart`, etc.).
*   **Rationale:** Violates the Implementation Readiness Standard's explicit Phase 5 write allowlist and `AGENTS.md` mirrored test paths.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** Replacing the wildcard with exact repo-relative paths and listing every cross-milestone edit makes the write allowlist deterministic.
*   ***Proposed Edit:***
    *   Location: Detailed Implementation Plan (M0–M5 & Automated Test Suite)
    *   Change: Expand every test file path explicitly (`test/features/home_setup/home_setup_screen_test.dart`, `test/features/home_setup/pairing_screen_test.dart`, `test/features/shopping/shopping_screen_test.dart`, `test/features/todos/todos_screen_test.dart`, `test/features/maid/maid_screen_test.dart`, `test/features/maid/maid_detail_screen_test.dart`, `test/features/expenses/expenses_screen_test.dart`, `test/features/meals/meals_screen_test.dart`, `test/features/meals/recipe_detail_screen_test.dart`, `test/features/settings_backup/settings_backup_screen_test.dart`, `test/features/debug/debug_screen_test.dart`), move `schema_migration_test.dart` to `test/core/data/db/schema_migration_test.dart`, add `test/core/data/change_writer_test.dart`, and list all cross-milestone `(Modify)` files under the milestones that edit them.

### [Issue 10] [`egm-style`, `egm-codebase-details`] - Severity: Blocker (`ir-1-10`)
*   **Affected Scope:** [Lines 101, 368, 376, 442-448, 462](docs/designs/nest_mojo_flat_v1.md#L376) (Dangling Provider & Module Naming)
*   **Discrepancy Description:** `providers.dart` registers `lanSyncControllerProvider`, but no `LanSyncController` class/file exists in the plan; settings/backup is named `backup` (diagram), `/settings` (route), `settings_backup` (directory), and `backup*` (ARB).
*   **Rationale:** Dangling provider symbols and mismatched module names cause compile/naming ambiguity.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** Aligning provider names to actual planned classes and using consistent feature naming removes ambiguity.
*   ***Proposed Edit:***
    *   Location: Lines 101, 368, 376, 442, 462
    *   Change: Rename `lanSyncControllerProvider` to `lanSyncServiceProvider` (backed by `LanSyncService` in `lib/core/data/sync/lan_sync_service.dart`), label the module `settings_backup` consistently in the architecture diagram, and include both `settings*` and `backup*` ARB key prefixes.

---

### [Issue 11] [`egm-implementation-readiness`, `egm-style`] - Severity: Major (`ir-1-11`)
*   **Affected Scope:** [Lines 382-400, 470-476](docs/designs/nest_mojo_flat_v1.md#L382-L400) (Pure-Domain Algorithms & Edge Cases)
*   **Discrepancy Description:** Concrete formulas, tie-breakers, and constants are missing across all 7 pure-domain modules (`money.dart`, `hlc.dart`, `merge_engine.dart`, `write_policy_gate.dart`, `recurrence_engine.dart`, `maid_salary_calculator.dart`, `expense_split_calculator.dart`).
*   **Rationale:** Implementers must not invent financial rounding, fork tie-breakers, or permission rules.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** Adding exact mathematical formulas, constants, and tie-breakers locks all pure-domain behavior for unit testing.
*   ***Proposed Edit:***
    *   Location: M1 Items 9–13 and M4 Items 28–29
    *   Change: Specify:
        *   `money.dart`: omit `.00` when `paise % 100 == 0`; negative prefix before symbol (`-₹1,234`); `int? tryParse(String input)` returning `null` on invalid input.
        *   `hlc.dart`: zero-padded 13-digit decimal ms + lowercase 5-hex-digit counter (`0x00000..0xFFFFF`), `kMaxLocalDriftMs = 300000`, on counter overflow advance `physicalMs + 1` and reset counter to `0`.
        *   `merge_engine.dart`: `resolveActiveRevision` picks max `(hlc, origin_device_id)` among non-voided leaves; a deterministic `void:<entry_group_id>` entry wins if its `hlc` > latest leaf `hlc` (otherwise newer superseding snapshot wins); tombstoning clears `notes` (`todos`, `shopping_items`, `expense_entries`, `maid_ledger_entries`) and `instructions` (`recipes`), while Delete-Undo restores pre-delete values from local `UndoToken` snapshot via fresh compensating ops.
        *   `write_policy_gate.dart`: complete permission table (Owner-only: invite/remove member, promote/demote owner, edit `homes.name`, create/edit/delete `maids`, `maid_salary_rules`, record/override/settle maid salary payouts; All active members: todos, shopping, daily maid attendance, maid advances/bonuses/deductions, expenses, budgets, recurring bills, meals/recipes); `role_epoch` stored on `homes.role_epoch` incremented on role mutation; accepting a `quarantined_ops` item re-emits a fresh Owner-authored op via `ChangeWriter`.
        *   `recurrence_engine.dart`: fixed `UUIDv5` namespace `6ba7b810-9dad-11d1-80b4-00c04fd430c8` (or app-specific `d3f8a4c2-7b1e-4e9a-9c5d-2a1b3c4d5e6f`), clamp `dayOfMonth = 31` to last day of month (Feb 28/29, Apr 30), anchor `interval > 1` on `start_date`, drop redundant `custom_days` (covered by `freq: daily` + `interval`).
        *   `maid_salary_calculator.dart`: `present = 1.0`, `half_day = 0.5`, `absent = 0.0`, multi-shift day weight = average across configured shift count (`shift_slots_per_day`), unmarked scheduled days count as `0.0` (unworked) and are returned in `List<String> unmarkedDates` so UI prompts backfill before payout; `divisor = 30` (`fixed30`) or days-in-month (`calendar_days`), `dailyRatePaise = (baseSalaryPaise / divisor).round()`, unpaid absences = `max(0.0, scheduledDays - workedDays - paidLeavesPerMonth)`, `netPayablePaise = baseSalaryPaise - (unpaidAbsences * dailyRatePaise).round() + bonusesPaise - deductionsPaise - advancesPaise`; mid-month effective-dated salary splits the month into date ranges prorated by each range's days; manual override replaces `netPayablePaise` directly and records `attendance_watermark_hlc` = max HLC across that maid's month attendance + ledger rows.
        *   `expense_split_calculator.dart`: sort participants ascending by `member_id` and assign `+1` paise remainder to the first `amount % n` members; monthly net summary outputs per-member net balance (`totalPaidPaise - totalOwedPaise`, sum across all members == `0`).

### [Issue 12] [`egm-implementation-readiness`, `egm-style`] - Severity: Major (`ir-1-12`)
*   **Affected Scope:** [Lines 167, 189, 253, 408-412, 428, 460-464, 512](docs/designs/nest_mojo_flat_v1.md#L408-L464) (`ChangeWriter`, WAL-Safe Snapshot, Upgrade Replay, Digest, Owner Recovery)
*   **Discrepancy Description:** Missing Dart signatures for `ChangeBatch`/`ChangeResult`/`UndoToken`/`SyncOp` and Create-Home bootstrap; missing replay trigger for deferred `applied = 0` ops; raw file copy of SQLite is WAL-unsafe; canonical SHA-256 digest algorithm is undefined; line 464 mentions "merge-vs-rollback confirmation dialog" while line 460 does merge-only; sole-owner recovery has no M3 task.
*   **Rationale:** Leaves core persistence, recovery, and verification mechanics undefined.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** Every one of these mechanics has a single clean engineering specification.
*   ***Proposed Edit:***
    *   Location: M1 Items 15–16, M3 Items 26–27
    *   Change: Define `ChangeBatch` (`create`, `set`, `inc`, `appendLedger`, `delete`), `ChangeResult(String undoToken, List<SyncOp> emittedOps)`, and `bootstrapHome(...)` for initial Create Home; trigger deferred op replay in `AppDatabase.migration.beforeOpen` (`SELECT * FROM sync_ops WHERE applied = 0 ORDER BY local_seq ASC`); mandate `VACUUM INTO '<snapshot_path>'` for the pre-restore snapshot and restoring from that file if chunked ingest throws; define canonical state digest as SHA-256 over sorted `(table_name, row_id)` canonical JSON of active + tombstoned synced domain columns excluding `local_seq` and local-only tables; reword line 464 to "pre-restore confirmation dialog explaining merge semantics (no time-machine rollback) and post-failure automatic rollback"; and add an explicit "Start New Home from Backup (Claim Ownership)" restore mode in `backup_service.dart` that mints a new `home_id`, `home_sync_key`, and promotes the restoring member to Owner when the sole owner's phone is permanently lost.

### [Issue 13] [`egm-implementation-readiness`, `egm-codebase-details`] - Severity: Major (`ir-1-13`)
*   **Affected Scope:** [Lines 352, 360, 376](docs/designs/nest_mojo_flat_v1.md#L352-L376) (`l10n.yaml`, Backup XML, `ProviderScope` Bootstrap)
*   **Discrepancy Description:** Missing `l10n.yaml` keys (`nullable-getter: false`, `output-localization-file`), missing exact `data_extraction_rules.xml` elements + `android:fullBackupContent` for API 26–30, and unclear `SharedPreferences` + `ProviderScope` startup order in `lib/main.dart`.
*   **Rationale:** Ambiguous config files lead to nullable `AppLocalizations` friction, incomplete API 26–30 Auto Backup exclusion, and theme flicker on launch.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** Pinning these exact config lines takes ~5 lines in the plan and removes all startup/config guesswork.
*   ***Proposed Edit:***
    *   Location: M0 Items 2, 4, 8
    *   Change: Specify `l10n.yaml` (`arb-dir: lib/l10n`, `template-arb-file: app_en.arb`, `output-localization-file: app_localizations.dart`, `nullable-getter: false`); add `android/app/src/main/res/xml/backup_rules.xml` (`Create`, referenced via `android:fullBackupContent="@xml/backup_rules"` for API 26–30) alongside `data_extraction_rules.xml` excluding `<exclude domain="database" path="." />` and `<exclude domain="sharedpref" path="." />`; specify awaiting `SharedPreferences.getInstance()` in `main()` and injecting it via `ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)], child: const MyApp())`.

### [Issue 14] [`egm-codebase-details`, `egm-style`] - Severity: Major (`ir-1-14`)
*   **Affected Scope:** [Line 356](docs/designs/nest_mojo_flat_v1.md#L356) (M0 Item 3: `build.gradle.kts`)
*   **Discrepancy Description:** Hardcodes `targetSdk = 35` (risking downgrading Flutter 3.50's default) and misattributes `minSdk = 26` to `NsdManager` (API 16) and SAF (API 19).
*   **Rationale:** Gradle config should preserve `flutter.targetSdkVersion` (with floor 35) and state the real API 26 driver.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** Verified against live `android/app/build.gradle.kts` line 23 (`targetSdk = flutter.targetSdkVersion`).
*   ***Proposed Edit:***
    *   Location: M0 Item 3
    *   Change: Specify `minSdk = 26` (Android 8.0+ baseline for `flutter_secure_storage` v10 and `mobile_scanner` v7) and `targetSdk = maxOf(flutter.targetSdkVersion, 35)`.

### [Issue 15] [`egm-style`] - Severity: Major (`ir-1-15`)
*   **Affected Scope:** [Line 416](docs/designs/nest_mojo_flat_v1.md#L416) (M1 Item 17: `home_setup_screen.dart`)
*   **Discrepancy Description:** References raw hex `#12201A` directly under a screen file spec, conflicting with `AGENTS.md` line 23.
*   **Rationale:** Screens must reference `NestColors` (`context.nest.brandCanvas`), never raw hex.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** Clean 1-line fix matching `AGENTS.md`.
*   ***Proposed Edit:***
    *   Location: M1 Item 17
    *   Change: Replace `(#12201A radial-dotted canvas)` with `(reading NestColors.brandCanvas via context.nest)`.

### [Issue 16] [`egm-style`] - Severity: Major (`ir-1-16`)
*   **Affected Scope:** [Lines 352, 360, 460, 488](docs/designs/nest_mojo_flat_v1.md#L460-L488) (Ambiguous "optional" phrasing)
*   **Discrepancy Description:** Blurs build-time optionality with user-selectable runtime actions (`optionally caching derived export key`, `optional 1-tap "Log as Expense"`).
*   **Rationale:** Every build requirement must be binary (in or out); runtime choices should be phrased as user-selectable controls.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** Removes scope ambiguity across M0, M3, and M4.
*   ***Proposed Edit:***
    *   Location: M3 Item 26, M4 Item 32
    *   Change: State explicitly: cache derived export key in `flutter_secure_storage` when the user enables "Remember passphrase for quick export" (off by default); implement the user-selectable 1-tap "Log as expense" action in `shopping_screen.dart`.

### [Issue 17] [`egm-implementation-readiness`, `egm-codebase-details`, `egm-style`] - Severity: Major (`ir-1-17`)
*   **Affected Scope:** [Lines 504-525](docs/designs/nest_mojo_flat_v1.md#L504-L525) (Test Plan & Verification Plan)
*   **Discrepancy Description:** `flutter test --coverage` emits line coverage only (not branch coverage); line 512 claims `bit-for-bit identical materialized state`; line 523 calls cleartext attributes "cleartext permissions" and omits merged-manifest verification; line 524 calls one-shot checks a "Soak Checklist"; tests lack per-milestone binding and golden fixture `backup_v1.nmflat` lacks exact test inputs/assertions.
*   **Rationale:** Verification gates must be accurate and executable with the named tools.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** Calibrating each verification gate and binding test files directly to `M0–M5` exit gates makes verification unambiguous.
*   ***Proposed Edit:***
    *   Location: Automated Test Suite & Verification Plan
    *   Change: Bind each test file to its milestone exit gate (`M0`–`M5`); specify `backup_v1.nmflat` fixture parameters (`passphrase: "nest-test-passphrase-v1"`, `home_id: "00000000-0000-4000-8000-000000000001"`, 10 seeded ops covering Field-LWW, tombstone, and expense rows); change line 512 to "identical canonical materialized domain rows and per-collection SHA-256 digests"; change line 522 to "`>= 85%` line coverage on `lib/core/domain/` and `lib/core/data/sync/` verified via `flutter test --coverage` + filtered `lcov.info`"; add merged-manifest verification (`aapt2 dump xmltree` / `build/app/intermediates/merged_manifests/release/AndroidManifest.xml` confirming `allowBackup=false`, no `usesCleartextTraffic=true`, and no Location permissions); rename line 524 to "Physical Android Device Verification Checklist (M2 & M3)".

### [Issue 18] [`egm-style`] - Severity: Major (`ir-1-18`)
*   **Affected Scope:** [Lines 368, 492](docs/designs/nest_mojo_flat_v1.md#L368) (M0 `app_en.arb` Scope & M5 "+ Polish")
*   **Discrepancy Description:** M0 claims to define all M0–M5 ARB strings up front, and M5 includes `+ Polish` with no listed polish tasks.
*   **Rationale:** Keep each milestone's scope exact.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** Clarifies M0 ARB scope and lists concrete M5 polish checks.
*   ***Proposed Edit:***
    *   Location: M0 Item 6 & M5 heading
    *   Change: State M0 initializes `app_en.arb` with prefix conventions and M0 shell strings (with each milestone M1–M5 adding its own keys), and add an explicit M5 accessibility & font-scale `2.0` audit step across all five modules.

### [Issue 19] [`egm-style`] - Severity: Major (`ir-1-19`)
*   **Affected Scope:** [Lines 33, 88, 241, 388-508](docs/designs/nest_mojo_flat_v1.md#L388-L508) (Identifier Casing & Domain Terminology)
*   **Discrepancy Description:** Mixes `snake_case` and `camelCase` (`deviceId`/`device_id`, `memberId`/`member_id`, `promotedAt`/`promoted_at`), mismatches backup header field names between lines 241 and 456, and alternates between `entry/exit logging` and `check-in/check-out`.
*   **Rationale:** Consistent naming avoids schema vs. Dart field mismatches.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** Standardizing on `snake_case` for SQL/JSON/wire fields, `camelCase` strictly for Dart symbols/signatures, matching header names (`kdf`, `kdf_mem_kib`, `kdf_iters`, `kdf_parallelism`, `salt_b64`, `nonce_b64`), and using `entry/exit logging` throughout resolves all inconsistencies.
*   ***Proposed Edit:***
    *   Location: Throughout `docs/designs/nest_mojo_flat_v1.md`
    *   Change: Normalize SQL/wire identifiers to `snake_case`, Dart identifiers to `camelCase`, align M3 Item 25 header keys with Section 7 line 241, and replace `check-in/check-out` with `entry/exit logging`.

### [Issue 20] [`egm-style`, `egm-codebase-details`] - Severity: Major (`ir-1-20`)
*   **Affected Scope:** [Line 352](docs/designs/nest_mojo_flat_v1.md#L352) (M0 Item 2: `pubspec.yaml` Phrasing)
*   **Discrepancy Description:** Calls caret ranges "pinned dependencies" and groups `flutter_localizations` SDK under plain `flutter pub add`.
*   **Rationale:** Accurate CLI wording avoids `flutter pub add` errors.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** Straightforward accuracy fix.
*   ***Proposed Edit:***
    *   Location: M0 Item 2
    *   Change: Replace "pinned dependencies" with "version-constrained dependencies" and specify `flutter pub add flutter_localizations --sdk=flutter`.

### [Issue 21] [`egm-implementation-readiness`, `egm-codebase-details`, `egm-style`] - Severity: Major (`ir-1-21`)
*   **Affected Scope:** [Lines 350-514](docs/designs/nest_mojo_flat_v1.md#L350-L514) (Shorthand Basenames & Combined Create/Modify Tags)
*   **Discrepancy Description:** Multiple multi-file headings drop directory prefixes after the first file and combine `(Create / Modify)` without labeling each file.
*   **Rationale:** Explicit repo-relative paths with per-file action tags are required for a clean write allowlist.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** Mechanical formatting improvement that directly eliminates allowlist ambiguity.
*   ***Proposed Edit:***
    *   Location: All multi-file headings in Target Files (`M0–M5`)
    *   Change: Expand every file to a full repo-relative path with its own `(Create)`, `(Modify)`, or `(Delete)` tag.

### [Issue 22] [`egm-style`] - Severity: Major (`ir-1-22`)
*   **Affected Scope:** [Line 340](docs/designs/nest_mojo_flat_v1.md#L340) (Uncalibrated Intro Sentence)
*   **Discrepancy Description:** Claims every touched file has a rationale and verification gate while headings only have `Type / Scope` and `Proposed Changes`.
*   **Rationale:** Align structure with the intro statement.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** Adding an explicit **Exit Gate** bullet at the end of each milestone (`M0–M5`) and a concise **Rationale** line (or explicit `What & Why` inside Proposed Changes) fulfills both the intro and the Phasing & Checkpoints standard.
*   ***Proposed Edit:***
    *   Location: M0–M5 milestone sections
    *   Change: Add a concrete **Milestone Exit Gate** bullet at the end of each milestone (`M0`–`M5`) listing the exact commands and tests that must pass before advancing.

---

### [Issue 23] [`egm-implementation-readiness`, `egm-codebase-details`] - Severity: Nit (`ir-1-23`)
*   **Affected Scope:** [Lines 346-348](docs/designs/nest_mojo_flat_v1.md#L346-L348) (M0 Item 1: `AGENTS.md`)
*   **Discrepancy Description:** Does not quote exact replacement wording for `AGENTS.md` lines 22, 32–33, and 39 (`listsAdded` prefix example, missing closing backtick on line 32, `updatedHlc` on `SyncedColumns`, and `# after pubspec changes` comment on line 39).
*   **Rationale:** Quoting exact target updates prevents ad-hoc rewrites of `AGENTS.md`.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** Worth fixing in the same batch for precision.
*   ***Proposed Edit:***
    *   Location: M0 Item 1
    *   Change: Specify exact updates for `AGENTS.md` lines 17, 22 (`shoppingAdded` example), 24 (`₹`), 32 (fix missing closing backtick + document compensating undo & `appendLedger`), 33 (document `sync_ops` + `SyncedColumns` including `updated_hlc`), and 39 (`# after Drift table/database changes`).

### [Issue 24] [`egm-style`] - Severity: Nit (`ir-1-24`)
*   **Affected Scope:** [Lines 340, 364, 392, 396, 412, 444, 448, 460, 472, 476, 488](docs/designs/nest_mojo_flat_v1.md#L340-L488) (Filler Phrasing)
*   **Discrepancy Description:** Minor filler/redundant words (`one unified`, `lightweight`, `shared identically`, `Orchestrate`, `brand-new`, `pre-restore safety`, `strictly excluding`, `clean folded`, `actionable error states`).
*   **Rationale:** Tighter technical prose improves clarity.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** Easy to tighten while editing those exact paragraphs.
*   ***Proposed Edit:***
    *   Location: Detailed Implementation Plan prose
    *   Change: Trim redundant adjectives/adverbs and pair error states on line 448 with explicit user recovery instructions (e.g., "Not on Wi-Fi — connect to home Wi-Fi", "Router blocking discovery — use manual IP:port").

### [Issue 25] [`egm-style`] - Severity: Nit (`ir-1-25`)
*   **Affected Scope:** [Lines 400, 420, 478, 484, 494-500](docs/designs/nest_mojo_flat_v1.md#L400-L500) (Minor Formatting & UI Label Casing)
*   **Discrepancy Description:** Missing backticks and `recipe_id` on `recipe_ingredients` (line 496), mixed Dart interpolation `"$templateId:$YYYY_MM_DD"` (line 400), ambiguity on pre-seeded vs. example stores (line 420), informal `default-ON` (line 484), and mixed UI label capitalization.
*   **Rationale:** Consistent notation prevents small UI/schema mismatches.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** Quick cleanup in the same pass.
*   ***Proposed Edit:***
    *   Location: M1 Items 13, 18; M4 Item 31; M5 Items 33–34
    *   Change: Add `recipe_id` and backticks on `recipe_ingredients`, write `"$templateId:$dateIso"`, state that `Any store` is pre-seeded on Create Home while Zepto/DMart/Reliance Bazaar are user-created examples (or optional starter chips), change `default-ON` to `enabled by default`, and use Sentence case for UI button/action labels.
