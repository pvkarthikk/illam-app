# Publishing Illam on F-Droid

Everything the F-Droid team reads from this repository:

| File | Purpose |
| --- | --- |
| `fastlane/metadata/android/en-US/` | Title, descriptions, icon and changelog (`changelogs/<versionCode>.txt`) shown in the F-Droid client |
| `docs/fdroid/io.github.pvkarthikk.illam.yml` | Build recipe to submit to fdroiddata |
| `android/app/build.gradle.kts` | `dependenciesInfo` blob disabled; release stays unsigned when `android/key.properties` is absent |

## Before you submit

1. Version code is `major * 1000000 + minor * 1000 + patch`, so `v1.3.1` is `1003001`. Add `changelogs/<code>.txt` for every release.
2. Replace `AllowedAPKSigningKeys` in the recipe with the SHA-256 of your release certificate:
   `keytool -list -v -keystore <your>.jks | grep SHA256` (lowercase, no colons).
3. Tag and push `v1.3.1` (`git tag v1.3.1 && git push origin v1.3.1`) after pushing this commit so GitHub Actions builds and publishes `illam-v1.3.1.apk` for reproducible verification.
4. Optionally add real screenshots as `fastlane/metadata/android/en-US/images/phoneScreenshots/1.png`, `2.png`, ... (the `generate-screenshots` workflow produces them).
5. Check locally with the F-Droid tools:
   `fdroid readmeta && fdroid rewritemeta io.github.pvkarthikk.illam && fdroid lint io.github.pvkarthikk.illam && fdroid build -v -l io.github.pvkarthikk.illam`

## Submit

1. Fork <https://gitlab.com/fdroid/fdroiddata>, copy the recipe to `metadata/io.github.pvkarthikk.illam.yml`.
2. Open a merge request using the "App inclusion" template and tick the checklist.
3. After inclusion, every new `vX.Y.Z` tag is picked up by `AutoUpdateMode`.

## Notes for reviewers

- No Google Play Services, ML Kit, Firebase SDK or other proprietary library is bundled. QR scanning uses ZXing; Google Drive backup signs in through a browser OAuth flow (`flutter_appauth`).
- Cloud backup, remote sync and Gmail import are opt-in and use the user's own accounts/projects. Declare `NonFreeNet` only if the reviewers ask; the default features work fully offline.
- Dropbox/OneDrive/Google/pCloud backup needs OAuth client IDs in `lib/core/backup/cloud/cloud_ids.dart`; they are empty in the source tree, so those providers show "not configured" until filled.
