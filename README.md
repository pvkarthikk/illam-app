# Illam

**Local-first household management for everyday peace of mind.**

*Illam* (இல்லம் — "home") is an open-source, local-first Android app designed to keep daily household routines organized without cloud accounts, subscriptions, or external servers. All data lives directly on your devices and synchronizes peer-to-peer over your home Wi-Fi network.

<p align="left">
  <a href="https://apps.obtainium.imranr.dev/redirect?r=obtainium://app/%7B%22id%22%3A%22io.github.pvkarthikk.illam%22%2C%22url%22%3A%22https%3A%2F%2Fgithub.com%2Fpvkarthikk%2Fillam-app%22%2C%22author%22%3A%22pvkarthikk%22%2C%22name%22%3A%22Illam%22%7D"><img src="assets/badges/badge_obtainium.png" alt="Get it on Obtainium" height="54"></a>
  <a href="https://f-droid.org/packages/io.github.pvkarthikk.illam/"><img src="assets/badges/badge_fdroid.png" alt="Get it on F-Droid" height="54"></a>
  <a href="https://play.google.com/store/apps/details?id=io.github.pvkarthikk.illam"><img src="assets/badges/badge_google_play.png" alt="Get it on Google Play" height="54"></a>
</p>

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

## Install & Releases

Signed APKs are published on the [GitHub Releases](https://github.com/pvkarthikk/illam-app/releases) page. To install and receive updates with [Obtainium](https://github.com/ImranR98/Obtainium), add this repository URL as an app source:

```text
https://github.com/pvkarthikk/illam-app
```

To cut a release, push a tag of the form `vMAJOR.MINOR.PATCH` that is higher than the previous release:

```bash
git tag v1.0.1
git push origin v1.0.1
```

The [Release workflow](.github/workflows/release.yml) takes the version from the tag (`v1.0.1` becomes version name `1.0.1` and version code `1000001`), so `pubspec.yaml` does not need a bump. It runs the tests, builds the `dev` flavor signed with the release key, and attaches `illam-v<version>.apk` to a new GitHub release. It needs these repository secrets: `KEYSTORE_BASE64` (the keystore file, base64-encoded), `KEYSTORE_PASSWORD`, `KEY_ALIAS`, and `KEY_PASSWORD`. Every release must be signed with the same keystore, otherwise installed copies cannot update.


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
