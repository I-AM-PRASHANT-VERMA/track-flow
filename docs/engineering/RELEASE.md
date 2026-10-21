# Release and staged rollout

Status: process documented; the automated pipeline is NOT built because it needs owner-held secrets and a signing change in protected files (android/app/build.gradle.kts currently signs release builds with the debug key, so a release AAB cannot be uploaded to Google Play yet).

## Versioning
`version: x.y.z+N` in pubspec.yaml. N (versionCode) only ever increases, one per uploaded build. User-facing notes are one line per fix, written in plain words.

## Promotion ladder (Google Play Console)
1. **Internal testing** (up to 100 testers, instant): install on the owner's phone, run the device checklist below.
2. **Closed testing** (a small trusted group): at least 3 days.
3. **Production, staged**: 1% -> 5% -> 20% -> 50% -> 100%. Hold each step at least 24 hours (48 hours at 1%). Move up only when every halt criterion is clear.

## Halt criteria (stop the rollout, do not promote)
- Any report of lost or wrong habit data (this is the only P0 for this app).
- User-perceived crash rate above 1.09% or ANR rate above 0.47% in Play Console vitals (Google's published bad-behaviour thresholds), or any crash that is new in this release.
- A rating drop or review text pointing at the new release.
Play cannot roll a binary back. "Rollback" = halt the rollout, ship a fixed build with a higher versionCode, and rely on the expand/migrate/contract rule (COMPATIBILITY.md) so the older install still reads its data.

## Dark launches (feature flags)
No remote config (the app promises zero network). Flags are compile-time: `const bool.fromEnvironment('FEATURE_X', defaultValue: false)` in `lib/core/flags.dart`; a flagged feature ships off, is turned on in a later build for internal testing, then the flag and the old path are deleted. Every flag has an owner and a removal release written in its comment.

## Device checklist (before promoting past internal)
Cold start; add, edit, delete and undo a habit; tap +1 five times quickly and confirm the count; rotate; text size at maximum; 3 tabs; export then import on a fresh install; upgrade over the previous release with existing data and confirm nothing changed.

## Owner-held prerequisites (not done)
Upload keystore and signing config (protected files), Play Console app + service account, GitHub environment secrets for a manual `workflow_dispatch` release workflow. I will not create or touch any of these without your explicit yes.
