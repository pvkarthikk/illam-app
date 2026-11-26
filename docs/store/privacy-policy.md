# Privacy Policy — Illam

Illam is a household management app built to run completely offline on your family’s phones.

## No Accounts & No App Servers

- There are **no user accounts**.
- **No Illam server** stores your household data.
- Your household data (lists, chores, meals, expenses, staff records, and settings) lives only in an encrypted database on the phones of your family members.

## Local Wi-Fi Sync

When family members pair phones and sync changes:

- Sync happens **directly between the family’s phones on the same home Wi-Fi network**.
- All sync traffic and pairing messages are **end-to-end encrypted**.
- No third-party or developer server relays or stores your synced data.

## Encrypted Backups

If you choose to turn on backups:

- Backups are **encrypted on your phone** with a password you choose before leaving the device.
- Encrypted backup archives are uploaded **only to the storage location you select**: Google Drive (hidden app folder), Microsoft OneDrive (Apps folder), Dropbox (Apps folder), pCloud (app folder), a WebDAV or Nextcloud server, an S3-compatible bucket, an SFTP server, or a local/external folder on your phone.
- **The developer never receives or has access to your backups, encryption password, or cloud sign-in tokens.**

## Remote Sync (Experimental — Bring Your Own Firebase)

Remote Sync is **off by default**. If you choose to turn it on and enter credentials for your own Firebase project:

- Updates are **compressed and end-to-end encrypted on your phone** with your home's shared key before leaving the device.
- Encrypted batches are sent **only to the Cloud Firestore project you configured** using Firebase Anonymous Authentication on your own Firebase account.
- **The developer has no access to your Firebase project, API key, or synced content.**

## Gmail Invoice Import (Experimental — Bring Your Own Google OAuth)

Gmail Invoice Import is **off by default**. If you choose to turn it on and configure your own Google Cloud Desktop App OAuth client:

- Illam signs in via PKCE loopback directly against Google and requests read-only Gmail access (`gmail.readonly`) using **your own OAuth client**.
- Emails and PDF attachments from Zepto, Blinkit, Amazon, and Flipkart are fetched directly to your phone and parsed **locally on-device** into unapproved Draft expenses.
- Nothing is added to your household ledger unless you review and tap **Account it**, and **the developer never has access to your emails, OAuth tokens, or client secret.**

## SMS Spend Import (Experimental — On-Device)

SMS Spend Import is **off by default**. If you choose to turn it on and grant Android SMS permissions (`READ_SMS`, and optionally `RECEIVE_SMS`):

- Bank, UPI, and card debit alerts are scanned and parsed **100% locally on-device** into unapproved Draft expenses stored encrypted on your phone.
- Personal numeric senders, OTPs, credits, refunds, and promotional SMS are ignored before staging, and raw SMS text is never uploaded or synced to family phones.
- Only expenses you explicitly review and tap **Account it** on are written to your household ledger.

## Household & Staff Details

- Information you enter inside your home, including house-help (staff) names, attendance, salary records, and **phone numbers**, is shared with the members of your home.

## What We Do Not Collect or Access

- **No analytics, tracking SDKs, or telemetry.**
- **No advertising.**
- **No access to call logs or notification listener services** (SMS permissions remain unused and disabled unless you opt into experimental SMS Spend Import).
- Android cloud auto-backup and device-to-device transfer of app data are disabled (`allowBackup="false"`).

## How to Delete Your Data

You remain in full control of your data at all times:

- **Remove from this phone:** Open **Profile → Remove from this phone** to wipe the app’s local database and keys from your device.
- **Leave a home:** Leave your shared home from **Home & members**.
- **Delete a home:** Admins can permanently delete a home for all members.
- **Delete backups:** Delete `.nmbak` backup files directly in the storage location you configured (Google Drive, OneDrive, Dropbox, pCloud, your server, or your folder).

## Contact

If you have any questions about privacy, contact: https://github.com/pvkarthikk/illam-app/issues
