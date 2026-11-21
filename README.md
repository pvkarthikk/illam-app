# Nest Mojo - Flat

Android-first, offline-first household management app (Dart package: `nm_flat`, target Android application ID: `app.nestmojo`). Every household member keeps a full local copy of the flat's data on their phone and synchronizes directly over home Wi-Fi with no central cloud backend or user accounts.

## Planned v1 Features

1. **Todos:** Assignable one-time and recurring household tasks.
2. **Shopping Lists:** Items grouped by online apps (e.g., Zepto) and offline stores (e.g., DMart, Reliance Bazaar), with a 1-tap plain-text store list share.
3. **Maid / House-Help Tracking:** Contact details, opt-in daily multi-shift entry/exit attendance, effective-dated monthly salary rules, and adjustable monthly salary calculation (advances, bonuses, deductions, overrides).
4. **Manual Expenses:** Household ledger in integer paise (`₹`), atomic equal/custom member splits, monthly category budgets, and recurring bills.
5. **Meal Planner & Recipes:** 7-day meal schedule supporting saved recipes or free-text entries, with 1-tap ingredient push to Shopping Lists.

## Sync, Roles & Backups

- **Home Wi-Fi Sync Only (v1):** Owner-initiated QR/PIN pairing exchanging a 256-bit `home_sync_key`, Android `NsdManager` discovery (with manual `IP:port` fallback), and raw TCP with X25519 + HKDF-SHA256 + AEAD length-prefixed frames.
- **Local Persistence & Merge Engine:** Unified `sync_ops` op-log and CRDT metadata materialized into Drift/SQLite WAL tables (drift-clamped HLC + `device_id` tie-break, `local_seq` ACK cursors, atomic Field-LWW, append-only superseding financial rows, deterministic recurring IDs, and permanent tombstone retention).
- **Roles:** Multi-owner model with centralized app-level write guards (`WritePolicyGate`), deterministic last-owner invariant, and stale-authority flagging.
- **Portable Backups:** Passphrase-encrypted `.nmflat` archives (Argon2id + XChaCha20-Poly1305) exported and restored via Android Storage Access Framework (SAF) across Google Drive, OneDrive, or local storage with zero cloud SDKs.

## Out of Scope for v1

- Away-from-home cellular/mobile-network sync
- Media, photo, receipt, or ID-proof attachments
- iOS support
- Cryptographic sync-layer RBAC

## Current Repository Status

- Implemented: Visual design tokens (`lib/core/design/nest_colors.dart`, `nest_theme.dart`, `nest_background.dart`), Light/Dark theme switching, and initial branding (`Nest Mojo - Flat`).
- Planned: Milestones `M0–M5` (Foundation/Housekeeping, Sync Core + Shopping/Todos, Encrypted Home Wi-Fi Sync, SAF Encrypted Backup/Restore, Maid Payroll & Expenses, Meal Planner & Recipes).

## Documentation

- [Design Document (v1)](./docs/designs/nest_mojo_flat_v1.md) — Full architecture, sync/backup protocols, alternatives considered, and milestone implementation plan.
- [Concepts Brief](./concepts_brief.md) — Synthesized multi-lens brainstorm findings and locked product/architecture decisions.
- [AGENTS.md](./AGENTS.md) — Coding conventions, stack rules, and workflow commands.

## Development Commands

```bash
flutter pub get
flutter analyze
flutter test
```
