# Google Play Data Safety Notes — Illam

Use these notes when completing the **Data safety** form in Google Play Console.

## Summary of Data Flow

Illam operates with **no developer backend server** and **no analytics or advertising SDKs**.

### Data That May Leave the Phone

Only the following data ever leaves the device, and only on your local network or to destinations you explicitly configure:

1. **Direct Wi-Fi Sync Frames** — Household data changes (lists, tasks, meals, spends, staff records) sent **directly to paired family phones on the same home Wi-Fi**. End-to-end encrypted between member devices; never routed through developer servers.
2. **Pairing (PAKE) Messages** — Ephemeral cryptographic key-exchange messages sent on the local Wi-Fi network when adding a family phone to a home.
3. **Encrypted Backups** — Password-encrypted household snapshots uploaded **only to a storage provider you choose** (Google Drive app folder, OneDrive app folder, Dropbox app folder, pCloud app folder, WebDAV/Nextcloud, S3-compatible storage, or SFTP).
4. **Remote Sync (Experimental — Bring Your Own Firebase, Optional)** — Off by default. If you explicitly turn on Remote Sync and configure your own Firebase project, end-to-end encrypted household update batches are relayed through your own Cloud Firestore project using Anonymous Authentication.
5. **Gmail Invoice Import (Experimental — Bring Your Own Google OAuth, Optional)** — Off by default. If you explicitly turn on Gmail Invoice Import and configure your own Google Cloud Desktop App OAuth client, Illam connects directly over HTTPS from your phone to Google's Gmail API (`gmail.readonly`) to scan store order emails and PDF invoices locally on-device into unapproved Draft expenses. OAuth credentials, tokens, and drafts remain encrypted in local secure storage and are never sent to any developer server.
6. **SMS Spend Import (Experimental — On-Device Only, Optional)** — Off by default. If you explicitly turn on SMS Spend Import and grant Android SMS permissions, Illam parses bank, UPI, and card transaction SMS locally on your phone (ignoring OTPs and non-bank numbers) into unapproved Draft expenses encrypted in local secure storage. Raw SMS text never leaves the device and is not synced to family phones; only approved expenses you tap **Account it** on enter the household ledger.

## Collection, Sharing, Encryption, and Deletion

- **Data collected by developer:** None. The developer has no server, collects no personal or usage data, and cannot read backups, Firebase credentials, or OAuth tokens.
- **Data shared with third parties:** None by the developer. Data sent to a user-chosen backup provider or user-owned Firebase project is sent solely at the user's explicit request under the user's own account and encrypted on-device before upload.
- **Is data encrypted in transit?** Yes — TLS (`https://`) or SSH for cloud/server backups and Firebase REST calls, plus authenticated end-to-end encryption for both local Wi-Fi sync and remote encrypted batches.
- **Can users request data deletion?** Users can delete all data directly inside the app (**Profile → Remove from this phone**, leave home, delete home) and remove backups or Firebase Firestore data from their own accounts.

Read Google’s current Data safety help before submitting; when unsure, declare more, not less.
