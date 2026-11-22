# Google Play Data Safety Notes — Nest Mojo : Flat

Use these notes when completing the **Data safety** form in Google Play Console.

## Summary of Data Flow

Nest Mojo : Flat operates with **no developer backend server** and **no analytics or advertising SDKs**.

### Data That May Leave the Phone

Only the following data ever leaves the device, and only on your local network or to destinations you explicitly configure:

1. **Direct Wi-Fi Sync Frames** — Household data changes (lists, tasks, meals, spends, staff records) sent **directly to paired family phones on the same home Wi-Fi**. End-to-end encrypted between member devices; never routed through developer servers.
2. **Pairing (PAKE) Messages** — Ephemeral cryptographic key-exchange messages sent on the local Wi-Fi network when adding a family phone to a home.
3. **Encrypted Backups** — Password-encrypted household snapshots uploaded **only to a storage provider you choose** (Google Drive app folder, OneDrive app folder, Dropbox app folder, pCloud app folder, WebDAV/Nextcloud, S3-compatible storage, or SFTP).

## Collection, Sharing, Encryption, and Deletion

- **Data collected by developer:** None. The developer has no server, collects no personal or usage data, and cannot read backups or OAuth tokens.
- **Data shared with third parties:** None by the developer. Data sent to a user-chosen backup provider is sent solely at the user's explicit request under the user's own account and encrypted on-device before upload.
- **Is data encrypted in transit?** Yes — TLS (`https://`) or SSH for cloud/server backups, and authenticated end-to-end encryption over local Wi-Fi for device-to-device sync.
- **Can users request data deletion?** Users can delete all data directly inside the app (**Profile → Remove from this phone**, leave home, delete home) and remove backups from their own storage accounts.

Read Google’s current Data safety help before submitting; when unsure, declare more, not less.
