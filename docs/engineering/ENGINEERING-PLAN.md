# TrackFlow engineering plan: architecture, tests, merge gate, rollout, compatibility

Status date: 2026-10-19. This file says what exists, what is planned, and what is unverified. Nothing here has been pushed or enabled on GitHub yet.

## Honest scope
- TrackFlow is a single-package, offline Android/Flutter app with no server and no network API. "Backward-compatible APIs" therefore means the two contracts it really has: the **persisted data format** and the **backup JSON format**, plus the internal Dart interfaces between layers (see COMPATIBILITY.md).
- "Google/Meta practices" are applied where they scale down to one developer: small reviewed changes, presubmit = CI, code owners, hermetic tests, flags, staged rollouts with halt criteria, expand/contract migrations. Not applicable at this size: Bazel/Buck monorepo builds, custom test-impact analysis, internal review tools.

## 1. Modular architecture (layered, feature-first, enforced by a test)
Target layout (from audit A7, deliberately small, no state-management package, no database):
```
lib/
  domain/          pure Dart, NO Flutter imports: HabitItem, HabitStats (scheduled-on-date, month stats, streaks), Clock
  data/            HabitRepository (interface) + LocalHabitRepository (SharedPreferences), schema versions, migrations
  application/     HabitController (ChangeNotifier): single owner of state, applies change in memory first, serialised persistence
  presentation/    screens/ and widgets/ split by feature (flow, matrix, heatmap, backup, add_edit, header)
  core/            constants, flags (dart-define), utils
```
Dependency rule: `domain` imports nothing from the other layers; `data` imports `domain`; `application` imports `domain` + `data` interfaces; `presentation` imports `application` + `domain`. Enforced by `test/architecture_test.dart` (scans imports; the build fails on a violation). Separate pub packages are NOT created yet: at ~5k lines that adds cost without benefit; the rule above makes a later split mechanical.

## 2. Automated tests (pyramid)
| Layer | What | Where |
|---|---|---|
| Unit (fast, fixed dates, injected clock) | streaks, rates, month stats, validation, migrations | test/domain, test/data |
| Contract | frozen fixtures of every released data/backup format must load identically | test/fixtures + test/compat |
| Repository | fake SharedPreferences: corrupt payload kept, serialised writes, import snapshot | test/data |
| Widget | cards, sheet, matrix, header at 320dp and text scale 1.3-2.0, semantics | test/widgets |
| Architecture | layer import rules | test/architecture_test.dart |
| Device smoke (manual per release, later automated) | run on the phone, screenshots | docs/engineering/RELEASE.md |
Today: 6 tests, 55.8% line coverage (measured locally 2026-10-19). Ratchet: `tool/coverage_threshold.txt` (starts at 55) may only go up; target 80% for `domain` and `data`.
Rules: failing test first, no `skip:`, tests never depend on today's date, each test under 30 s.

## 3. Merge gate (CI)
`.github/workflows/ci.yml` (written, not yet run on GitHub). Jobs and required check names: `quality` (format, analyze, tests, coverage ratchet), `build-android` (debug APK compiles), `secret-scan` (gitleaks), `dependency-review` (PRs). Triggers: pull_request, push to main, merge_group. Actions pinned to commit SHAs, Flutter pinned to 3.47.5, Dependabot proposes bumps weekly.
Blocking is real only after a **branch ruleset** on `main` requires those checks (PR required, no force-push, linear history, enforced for admins). That is a GitHub setting I will not change without your explicit yes (see OWNER-TODO).
Local equivalent: `pwsh -File scripts\presubmit.ps1 -Strict`.
Known gap: the code base is not `dart format` clean (all 15 files differ). The format step is marked temporary `continue-on-error` and becomes blocking in the one-shot format commit that lands after the fix waves are merged.

## 4. Staged rollouts
See RELEASE.md. Summary: internal testing -> closed testing -> production at 1% -> 5% -> 20% -> 50% -> 100% on Google Play, with written halt criteria and an expand/contract rule for data changes so a halted or rolled-back release never strands user data. In-app dark launches use compile-time `--dart-define` flags (no remote config: the app promises zero network). Blocked on owner: real release signing (release currently signed with the debug key) and Play Console access.

## 5. Backward compatibility from day one
See COMPATIBILITY.md. Summary: versioned payloads, readers accept every older version, unknown fields ignored, enums stored by name with safe fallback, old storage key left untouched for one full release, golden fixtures of released formats are frozen and tested in CI.

## 6. Sequencing (why this order)
| Phase | Content | Conflicts with running work? |
|---|---|---|
| 0 (done now) | CI workflow, coverage gate, presubmit, PR template, CODEOWNERS, Dependabot, these docs | No: only new files |
| 1 Waves A-D | fixes + architecture (FIX-PLAN.md); Wave B builds repository, controller, schema versioning, fixtures; Wave D adds architecture test, stricter lints, tests for every untested behaviour | This is the work itself |
| 2 | One-shot `dart format` commit, make format check blocking, raise coverage ratchet, enable stricter lints | Only after Phase 1 is merged (it touches every file) |
| 3 (owner yes needed) | push branch, open PR, see CI green, enable `main` ruleset, signing + Play pipeline, internal -> staged rollout | Outward-facing |
