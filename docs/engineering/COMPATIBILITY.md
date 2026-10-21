# Compatibility contract

TrackFlow has no network API. Its public contracts are the data it stores and the backup it exports. Users keep these across app updates, restores and (during a staged rollout or rollback) across two app versions running on different phones/installs. Breaking them silently destroys user data.

## Contract 1: persisted habits (SharedPreferences)
Current format (v1, as shipped): key `track_flow_habits_v1` holds a bare JSON list of habit objects. Enums are stored by integer index. There is no version field.

Rules, in force from the first change after this document:
1. **Readers accept every released version.** `fromJson` must load v1 forever. Unknown or missing fields use defaults; unknown extra fields are ignored; one bad habit never discards the whole list (skip the entry, keep a copy of the raw text).
2. **Never lose data on a parse failure.** Raw payload is kept under a recovery key (`..._recovery`), the user is told, and nothing is overwritten until the user decides.
3. **Expand / migrate / contract.** A new version writes to a NEW key (`track_flow_habits_v2`, payload `{ "schemaVersion": 2, "habits": [...] }`) and leaves the old key untouched for one full release. A halted rollout or an older binary then still finds valid data. The old key is deleted at the earliest in the release after next, never in the same release that introduced the new key.
4. **Additive only.** Never reuse a field name for a different meaning; never change a field's type; removing a field needs a deprecation release first. Enums are stored by NAME with an explicit fallback value for unknown names (reordering or adding a value must be safe).
5. **Migrations are a chain** (`v1 -> v2 -> v3`), each a pure function with its own test.

## Contract 2: backup JSON (clipboard export / import)
Shape today: `{ "app": "TrackFlow", "version": "1.0.0", "exportedAt": ..., "habits": [...] }` (the `version` here is the app version, not a schema version).
- Add `"schemaVersion": <int>`; a file without it is schema 1.
- Import accepts every schema it knows; a newer major schema is rejected with a clear message and changes nothing.
- Import is validated first (non-empty habit list unless the user confirms an empty restore, unique ids, titles non-empty, targets >= 1), takes an automatic snapshot, and asks for confirmation showing the habit count.

## Contract 3: internal interfaces
`HabitRepository`, `HabitController`, `HabitStats` are additive-only: new optional parameters and new members are fine; renames and removals need the deprecation steps below.

## Golden fixtures (the enforcement)
- `test/fixtures/habits_v1.json` and `test/fixtures/backup_v1.json` are generated from the format shipped today and committed. A test loads each and asserts the exact domain objects. **These files are frozen: they may be added to, never edited.** Every future format adds its own `..._v2.json` fixture in the PR that introduces it.
- CI fails if a fixture stops loading identically, which is how an incompatible change is caught before it ships.

## Deprecation steps
Mark `@Deprecated` with the replacement -> keep working for one release -> remove in the next, with the release note.
