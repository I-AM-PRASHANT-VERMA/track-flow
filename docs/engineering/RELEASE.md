# Release and staged rollout

## Signing (set up 2026-10-22)

- Upload key: `.secrets/trackflow-upload.jks`, alias `upload`, store password = key password. `.secrets/` is git-ignored and stays inside the project folder. A backup of the keystore is in Google Drive: `Apps/TrackFlow/1 - Signing key/`. The password is only in `.secrets/key.properties` and in Bitwarden, never in Drive, git or chat.
- `android/key.properties` (git-ignored) is a copy of `.secrets/key.properties`; Gradle reads it (`android/app/build.gradle.kts`). Without it, release builds fall back to the debug key, which Google Play rejects.
- Upload key fingerprints: SHA-1 `DF:66:7D:46:C4:05:0E:64:18:2C:0C:3A:7F:9C:D4:05:68:0C:D0:BB`, SHA-256 `31:E9:4F:99:19:57:E5:37:8E:57:D3:F0:A3:9B:A4:58:30:92:31:8B:50:70:45:80:B7:52:EF:0F:44:0D:1E:8E`.
- Play App Signing: accept it on the first upload; Google holds the app signing key.

## Build a Play bundle

1. Raise the number after `+` in `pubspec.yaml` (`version: 1.0.0+1` -> `1.0.0+2`); Play rejects a reused code.
2. `pwsh -File scripts/presubmit.ps1 -Strict` must pass.
3. `flutter build appbundle --release` -> `build/app/outputs/bundle/release/app-release.aab`.
4. Check the signer: `keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab` must show the SHA-1 above.
5. Copy it to Drive as `Apps/TrackFlow/2 - Play Store builds/trackflow-<version>.aab` and note it in `4 - Docs/BUILD-NOTES.txt`.

## Store listing material

Text and forms: `docs/store/` (listing, Play Console answers, privacy policy, terms of use, closed-testing plan). Graphics are generated from the real icon and real screenshots: `tool/store/make_graphics.py`; sample data for screenshots on an emulator: `tool/store/make_demo_seed.py`.

## Promotion ladder (Google Play Console)

1. **Closed testing** (required first for new personal accounts: 12+ testers opted in for 14 days; see `docs/store/closed-testing.md`).
2. **Production, staged**: 1% -> 5% -> 20% -> 50% -> 100%. Hold each step at least 24 hours (48 hours at 1%). Move up only when every halt criterion is clear.

## Halt criteria (stop the rollout, do not promote)

- Any report of lost or wrong habit data (the only P0 for this app).
- User-perceived crash rate above 1.09% or ANR rate above 0.47% in Play Console vitals (Google's published bad-behaviour thresholds), or any crash that is new in this release.
- A rating drop or review text pointing at the new release.
Play cannot roll a binary back. "Rollback" = halt the rollout, ship a fixed build with a higher version code, and rely on the expand/migrate/contract rule (COMPATIBILITY.md) so the older install still reads its data.

## Dark launches (feature flags)

No remote config (the app has no network access). Flags are compile-time: `const bool.fromEnvironment('FEATURE_X', defaultValue: false)`; a flagged feature ships off, is turned on in a later build, then the flag and the old path are deleted.

## Device checklist (before each promotion)

Cold start; add, edit, delete and undo a habit; tap +1 five times quickly and confirm the count; rotate; text size at maximum; all three tabs; copy a backup and restore it; upgrade over the previous release with existing data and confirm nothing changed.
