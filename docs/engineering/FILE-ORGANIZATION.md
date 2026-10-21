# How TrackFlow's files are organised

Status: IMPLEMENTED on branch `refactor/architecture` (2026-10-21). Enforced by `test/architecture_test.dart`. Evidence: docs/research/notes (only documents that were actually read are cited; everything else is judgement and marked as such).

## What the evidence says (and what it does not)
1. **Two layers, then components by responsibility.** Flutter's official guide splits an app into a UI layer and a data layer; repositories are the source of truth, services wrap external APIs, an optional domain layer holds business rules, and views hold no business logic. (notes/flutter-architecture-guide.md)
2. **Split by hidden decision, not by size or by processing step.** Parnas 1972: each module hides one design decision. The library checklist adds that file size is a thermometer, not the disease (its claim rests on El Emam 1999 and Chowdhury 2022, which I have NOT read). (notes/parnas-1972-decomposing-into-modules.md)
3. **Immutable models, one-way data flow, grow in small steps.** Meta's iOS write-up: reliability improved after moving away from mutable models and bidirectional flow. (notes/meta-2023-facebook-ios-architecture.md)
4. **Small changes.** Google: one self-contained change with its tests. (notes/google-small-cls.md) The restructure itself is split into commits by layer; the UI commit is still large because every widget moved at once.
5. **Boundaries are enforced by a tool.** Shopify's Packwerk is the model; ours is a test that fails on a forbidden import.
What I could not verify: how Apple or Amazon organise app code (the library has no document on it).

## Layout
```
lib/
  main.dart                    composition root: the only file that picks concrete classes
  app.dart                     MaterialApp, owns the "today" notifier
  domain/                      pure Dart: no Flutter, no packages, no other layer
    day.dart                   calendar date; all day math on UTC dates (no DST bugs)
    clock.dart                 injectable "now"
    habit.dart                 immutable entity and its invariants
    habit_rules.dart           streaks, start day, tallies for one habit
    habit_stats.dart           today / month / year aggregates across habits
  data/                        hides HOW and WHERE habits are stored
    habit_repository.dart      single source of truth; memory first, ordered background writes
    habit_store.dart           storage service interface
    shared_prefs_habit_store.dart  SharedPreferences implementation, versioned keys, recovery copies
    habit_json.dart            JSON mapping, schema 1 and 2
    backup_codec.dart          backup text format and validation
  core/                        shared, feature-independent UI
    theme/                     colours, spacing, text styles, ThemeData, habit icons
    time/today_notifier.dart   current day; changes at midnight and on resume
    widgets/                   TouchTarget, SheetFrame, SectionCard, StatTile/StatPill
  features/                    one folder per screen area
    home/                      home screen, header, tab enum (composes the other features)
    flow/                      Today's Flow, habit card, week strip, today's controls
    matrix/                    7-day matrix, its layout maths, month summary card
    heatmap/                   365-day canvas: grid maths, cell model, painter, year card
    habit_editor/              editor sheet, pickers, form validation
    backup/                    backup and restore sheet
test/                          mirrors lib/; test/compat + test/fixtures freeze released data formats
```

## Rules (each one is checked by test/architecture_test.dart)
- `domain` imports only `dart:` libraries and other domain files.
- `data` imports `domain`, Flutter foundation and the storage package only.
- `core` never imports `data` or `features`.
- `features` reach storage only through `habit_repository.dart` and `backup_codec.dart`.
- A feature never imports another feature, except `home`, which composes them.
- Only `main.dart` knows `shared_prefs_habit_store.dart`.

## Decisions and their reasons
- **No separate view-model classes.** The guide's view models exist to turn repository data into UI state. Here that work is pure domain functions (`HabitStats`, `buildHeatCells`, `buildFlowSections`) that views call once per data change (matrix and heatmap memoise the result). Same separation, fewer classes, all of it unit-tested. Revisit if a screen grows real UI logic.
- **No state-management package, no database, no code generation, one package.** Nothing in the documents read justifies them for a ~4,000-line single-developer offline app.
- **Dark theme only.** The previous code carried a full light theme that the app never displayed (`ThemeMode.dark` was forced); it was removed instead of maintained.
