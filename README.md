# Illam

**Local-first household management for everyday peace of mind.**

*Illam* (இல்லம் — "home") is an open-source, local-first Android app designed to keep daily household routines organized without cloud accounts, subscriptions, or external servers. All data lives directly on your devices and synchronizes peer-to-peer over your home Wi-Fi network.

---

## Core Modules

- **Shared Todos:** Track household chores, maintenance tasks, and daily reminders. Assign one-time or recurring routines to family members or household helpers, surface due items automatically on the Today screen, and receive timely local notifications.
- **Grouped Shopping Lists:** Organize groceries and household supplies by category or store. Quickly capture items with smart quantity/type detection, group purchases across online apps and local stores, and share clean store-specific checklists in one tap.
- **Household Expenses:** Log daily spending cleanly without bank-linking bloat. Record cash, UPI, or card spends in integer paise (`₹`), split shared expenses equally or by custom amounts among home members, monitor monthly category budgets, and track recurring bills.
- **Meal Planning:** Plan weekly meals effortlessly so daily cooking decisions stay stress-free. Manage a library of recipes with scalable servings and push missing recipe ingredients directly onto your shopping list in a single tap.
- **Staff Attendance & Payroll:** Track daily attendance and calculate monthly payouts accurately. Log daily check-ins, leaves, effective-dated monthly or hourly pay rules, advances, bonuses, and deductions, then settle transparent monthly pay slips with linked expense entries.

---

## Why Illam?

- **Local-First Architecture:** Full offline capability with zero dependency on external cloud servers. Every household member keeps a complete local copy stored inside an encrypted SQLite database (`SQLite3MultipleCiphers`) secured by hardware-backed device keys (`Android Keystore`), so every screen works instantaneously in airplane mode or poor connectivity.
- **Peer-to-Peer Wi-Fi Sync:** Devices synchronize directly over your local network. Pair family phones on home Wi-Fi using a QR code or passphrase, exchange a shared home sync key, and reconcile edits automatically via deterministic CRDT / Hybrid Logical Clock merge rules over end-to-end encrypted connections.
- **Portable Encrypted Backups:** Protect your home against lost phones without giving up control. Create passphrase-encrypted `.nmbak` snapshots on a schedule and store them in a destination you control — Android folders/USB storage, Google Drive (`appDataFolder`), Microsoft OneDrive, Dropbox, pCloud, Nextcloud, WebDAV, S3-compatible storage, or SFTP.
- **Built for Peace of Mind:** Simple, distraction-free workflows designed for everyday family use — with no user accounts, no analytics or tracking SDKs, no ads, and `allowBackup="false"` enforced in Android.

---

## Tech Stack

- **Framework:** Flutter (Material 3)
- **State Management & Routing:** Riverpod + `go_router`
- **Database & Migrations:** Drift + SQLite (`SQLite3MultipleCiphers`) with versioned step-by-step schema migrations
- **Security & Sync:** `cryptography`, `pointycastle`, `flutter_secure_storage`, mDNS (`bonsoir`), WorkManager background sync & backups
- **Android Application ID:** `io.github.pvkarthikk.illam` (`dev` flavor) / `io.github.pvkarthikk.illam.peer2` (`peer2` flavor)

---

## Getting Started

```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter run --flavor dev
```

For dual-device local Wi-Fi sync testing on Android, install both flavors side by side:

```bash
flutter run --flavor dev -d <device-1>
flutter run --flavor peer2 -d <device-2>
```

---

## Documentation

- [Privacy Policy](docs/store/privacy-policy.md)
- [Google Play Data Safety Notes](docs/store/data-safety.md)
- [Data Deletion Guide](docs/store/data-deletion.md)
- [Design Document (v1)](docs/designs/nest_mojo_flat_v1.md) — Sync, merge rules, cryptography, and storage design notes.
- [AGENTS.md](AGENTS.md) — Coding standards, project structure, and verification commands.

---

## License

Licensed under the **Apache License, Version 2.0**. See [LICENSE](LICENSE) for the full license text.
