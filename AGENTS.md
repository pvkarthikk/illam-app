# AGENTS.md — Illam (Flutter)

## The app
"Illam" – a household app: house-help attendance and salary, grocery/shopping lists, cleaning tasks, meals and recipes, spends and bills, and later offline-first sync between family phones and encrypted backups. Android first, works fully offline. Android application id: `io.github.pvkarthikk.illam`.

## Scope
1. Do **only** the instruction you were given. Do not start the next one, refactor, rename or reformat other code.
2. Touch only the files the instruction names. If another file must change, say why in one line.
3. Never add, remove or upgrade packages unless the instruction says so; use the **exact** version constraint given (`flutter pub add name:^x.y.z`). If it cannot resolve, use the newest version with the same major number and say so. Never run `flutter pub upgrade --major-versions`.
4. Never rename existing files, classes, providers, routes, database tables/columns or ARB keys.
5. If something is unclear, choose the simplest option and say what you assumed.

## Stack
Flutter 3.50 (Dart 3.14), Material 3 · Riverpod 3 without code generation · go_router 18 · drift (SQLite) · shared_preferences · flutter_secure_storage · ARB localisation (`flutter gen-l10n`).

### Code rules
- Import `package:flutter/material.dart` – **never** `package:flutter/material.dart`. (`flutter.widgets.dart`, `services.dart`, `foundation.dart` are fine.)
- Riverpod: only `Provider`, `FutureProvider`, `StreamProvider`, `NotifierProvider`, `AsyncNotifierProvider`, `.family`, `ref.watch/read/listen`, `ConsumerWidget`, `ConsumerStatefulWidget`. **Never** `stateProvider`, `StateNotifierProvider`, `ChangeNotifierProvider`, `riverpod_generator`, `WillPopScope` (use `PopScope`), GetX, provider or bloc.
- App-wide providers live in `lib/core/providers.dart`; never remove one.
- One screen = `lib/features/<feature>/<name>_screen.dart` (widgets) + `<name>_controller.dart` (a Riverpod `Notifier`). Split big screens into `<name>_parts.dart`. Keep files under ~400 lines. File names snake_case.dart.
- Pure algorithms go in `lib/core/domain/` (no Flutter imports) with tests in `test/core/domain/`. Tests mirror `lib/` paths.
- All user-visible text lives in `lib/l10n/app_en.arb` (ICU placeholders/plurals), keys prefixed by feature (`listsAdded`). Read with `AppLocalizations.of(context)`. Never hard-code UI text in Dart.
- Colours from `context.nest` (the `NestColors` theme extension) or `Theme.of(context).colorScheme` – never hex in screens. Use the shared components in `lib/core/design/components/` (NestCard, NestButton, NestChip...) instead of raw widgets for those.
- Money is `int` paise (`£1 = 100`); show with `Money.format(paise)` → `£1,234` (Indian grouping).
- Dates are `YYYY-MM-DD` strings in local time; instants are epoch milliseconds (`int`).
- Null-safe; no `'!' on database data; handle loading, empty and error states. After `await`, check `context.mounted` before using `context`.
- Accessibility: every icon-only button has a `tooltip` or `Semantics(label:)`; touch targets ≥ 48 dp; layouts wrap (not clip) at font scale 2.0.
- `const` constructors where possible. Use the package name from `pubspec.yaml` for `package:` imports.

## Data rules (once the database exists)
- Screens read drift tables through `watch()` streams exposed as `StreamProvider`s, always filtering `deleted = false` and `home_id = current_home`.
- **Every write to a synced table goes through `ChangeWriter`:** `ref.read(changesProvider).write('label', (c) { c.create(...); c.set(...); c.inc(...); c.delete(...); }); It returns a `ChangeResult` with an undo token. Never insert/update/delete synced tables directly. Counter fields change only with `inc`.
- Synced tables mix in `SyncedColumns` (id, home_id, deleted, created_at, created_by, updated_at, updated_by); every other column is `.nullable()` or has `.withDefault(...)`. For a new table: file in `lib/core/data/db/tables/`, add to `@DriftDatabase (tables: [...])`, raise `schemaVersion` by 1, register it in `CollectionRegistry`, run code generation.
- Developer tools live under `/debug` and only exist when `kDebugMode`.

## Commands (PowerShell, project root)
```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs # after pubspec changes
flutter gen-l10n
flutter analyze
flutter test
```
Fix every error you caused (read the first error, not the last). Never delete tests, add `// ignore`, or weaken lints to pass.


### When you finish
Reply with:
1. files created/changed, one line each;
2. `flutter analyze` and `flutter test` results;
3. whether the human must **restart** `flutter run` (new package, new table, Android/manifest change) or just hot reload `r`;
4. what to check on the phone;
5. anything you were unsure about. Then **stop**.