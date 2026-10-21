# How TrackFlow's files should be organised

Status: PROPOSAL, nothing moved yet. It replaces the layer sketch in ENGINEERING-PLAN.md section 1 where they differ. Evidence: docs/research/notes (only documents that were actually read are cited; everything else is my own judgement and marked as such).

## What the evidence says (and what it does not)
1. **Two layers, then components by responsibility.** Flutter's official guide splits an app into a UI layer and a data layer; each feature is one view plus one view model, backed by repositories (source of truth) and optional services; an optional domain layer holds use cases. Views hold no business logic. (notes/flutter-architecture-guide.md)
2. **Split by hidden decision, not by size or by processing step.** Parnas 1972: each module hides one design decision. The library checklist adds that file size is a thermometer, not the disease (its claim rests on El Emam 1999 and Chowdhury 2022, which I have NOT read yet). (notes/parnas-1972-decomposing-into-modules.md)
3. **Immutable models, one-way data flow, grow in small steps.** Meta's iOS write-up: no up-front grand design; reliability improved after moving away from mutable models and bidirectional flow. (notes/meta-2023-facebook-ios-architecture.md)
4. **Small changes.** Google: one self-contained change with its tests; about 100 lines is typical, 1000 is too large. (notes/google-small-cls.md)
5. **Boundaries are enforced by a tool.** Shopify built Packwerk, "a static analysis tool used to enforce boundaries" (from its own description). I have read only its opening sentence; our equivalent is a test that fails on a forbidden import.
What I could not verify: how Apple or Amazon organise app code (the library has no document on it). I will not claim what they do.

## Target layout (feature-first, small on purpose)
```
lib/
  main.dart                      app start, composition root (the ONLY place that wires concrete classes together)
  core/                          theme (colors, spacing), flags (dart-define), shared tiny widgets (TouchTarget)
  domain/                        pure Dart, no Flutter, no storage
    habit.dart                   the immutable entity (today's HabitItem, minus JSON)
    habit_rules.dart             streaks, completion, scheduled-on-date (takes a Clock; the one place these rules live)
    habit_stats.dart             day / month / year aggregates used by every view
    clock.dart
  data/                          hides HOW habits are stored
    habit_repository.dart        interface: the single source of truth, notifies listeners
    local_habit_repository.dart  SharedPreferences implementation, serialised writes, recovery copy
    habit_json.dart              mapping Habit <-> JSON, schema versions and migrations (compat contract lives here)
    backup_codec.dart            export / import format + validation
  features/                      one folder per user-facing feature: view + view model together
    home/                        home_screen.dart, home_view_model.dart (tab, filter by habit id)
    flow/                        flow_view.dart, habit_card.dart
    matrix/                      matrix_view.dart, matrix_view_model.dart
    heatmap/                     heatmap_view.dart, heatmap_painter.dart, heatmap_view_model.dart
    summary/                     summary_header.dart
    habit_editor/                add_edit_sheet.dart, habit_form_model.dart (validation)
    backup/                      backup_sheet.dart
test/                            mirrors lib/; test/compat and test/fixtures hold the frozen released formats
```
Import rule (enforced by test/architecture_test.dart): `domain` imports nothing else from lib; `data` imports `domain`; `features` import `domain` and the `data` INTERFACE only; only `main.dart` knows `local_habit_repository.dart`; no feature imports another feature's internals.

## Where today's files go (hidden decision in each)
| Today | Becomes | Decision it hides |
|---|---|---|
| models/habit_item.dart | domain/habit.dart + habit_rules.dart; JSON moves to data/habit_json.dart | what a habit is / how a streak is defined / how it is stored |
| core/services/habit_storage.dart (static) | data/ repository interface + local implementation + backup_codec | storage medium and format |
| screens/track_flow_home_screen.dart | features/home/ (screen + view model) | which tab is shown, filter state |
| widgets/habit_card.dart | features/flow/habit_card.dart | how one habit is drawn and tapped |
| widgets/multi_day_matrix_view.dart | features/matrix/ view + view model (month stats leave the widget) | matrix layout vs matrix numbers |
| widgets/yearly_heatmap_canvas.dart | features/heatmap/ view + painter + view model | calendar math vs drawing vs interaction |
| widgets/executive_summary_header.dart | features/summary/ (stats come from domain/habit_stats) | header layout |
| widgets/add_edit_habit_sheet.dart | features/habit_editor/ sheet + form model | form validation vs form layout |
| widgets/backup_sheet.dart | features/backup/ | backup UI (format rules move to data/backup_codec) |
| core/constants | core/ (unchanged) | visual tokens |

## Changes this makes to the existing plan
1. The single `HabitController` proposed in audit A7 is replaced by the official vocabulary: **HabitRepository** is the source of truth; each feature gets its own **view model**. One controller for everything would become a new god object.
2. FIX-PLAN Wave D "split every file over 450 lines" is replaced by "split along the hidden decisions in the table above". Line count is only an alarm that tells us to look.
3. Wave B is too big to review. It is cut into small steps, each mergeable and revertible alone (about 100-300 changed lines plus tests): (a) Clock + domain rules, (b) repository interface + local implementation behind it, (c) JSON mapping + schema v2 + migration + fixtures, (d) move home screen to the repository, (e) delete confirmation with undo, (f) import validation + snapshot.
4. Worker jobs get a size limit (about 300 changed lines). The Wave A job TF-G3B (about 1,260 changed lines) is held until I have read it line by line; if it cannot be verified it is re-split.
5. Performance work (Wave C) needs a before and after measurement for every claimed gain (Knuth/measure-first item in the checklist), not the auditors' static estimates.

## Not doing (deliberately)
No state-management package, no database, no separate pub packages yet, no code generation, no monorepo tooling: none of the documents read justify them for a 5,000-line single-developer app.
