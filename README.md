# TrackFlow

> A fast, offline habit tracker: one-tap check-ins, a 7-day matrix and a 365-day canvas.
> No account, no analytics, no network calls: your habits stay on your phone.

## What it does

- **Today's Flow**: habits grouped by time of day (morning, deep work, evening, anytime). Yes/no habits complete with one tap; measurable habits (glasses, pages, minutes) use an inline stepper with a progress bar. Each card shows the last seven days, and any past day can be toggled.
- **7-Day Matrix**: every habit against the last seven days, with month-to-date consistency, a rolling 30-day rate, perfect days and the best streak.
- **365-Day Canvas**: a 53-week heatmap (weeks start on Monday) for all habits or one habit, with rest days drawn differently from missed days and a tap-to-inspect day detail.
- **Schedules and streaks**: habits can repeat on chosen weekdays; rest days neither count toward nor break a streak.
- **Backup and restore**: copy a backup of all habits as text and paste it back to restore. Restore is validated, asks for confirmation and can be undone. Deleting a habit can be undone too.

## Privacy

Data is stored in the app's private storage on the device (Android SharedPreferences). It is **not encrypted** by the app. Release builds declare no network permission and the app makes no network requests. Android's own device backup may include app data if it is enabled on the phone.

## Architecture

Layered, feature-first, following the Flutter team's architecture guide. The full rationale and the evidence behind it are in [docs/engineering/FILE-ORGANIZATION.md](docs/engineering/FILE-ORGANIZATION.md).

```
lib/
  domain/     pure Dart: Habit, Day (calendar math without DST bugs), streak and statistics rules
  data/       HabitRepository (single source of truth), versioned storage, backup format
  core/       theme, "today" notifier, shared widgets
  features/   home, flow, matrix, heatmap, habit_editor, backup (views hold no business logic)
  app.dart, main.dart (the only place that picks concrete implementations)
```

The layer rules are enforced by `test/architecture_test.dart`. Stored data and backups are versioned; every released format has a frozen fixture that must keep loading (`test/compat`, [docs/engineering/COMPATIBILITY.md](docs/engineering/COMPATIBILITY.md)).

## Development

Requirements: Flutter 3.47.5 (pinned in CI), Android SDK.

```bash
flutter pub get
flutter run
```

Debug builds install as **TrackFlow Dev** (`com.trackflow.app.track_flow.dev`) next to the release app, so testing on a phone never touches real data.

Before pushing, run the same checks as CI (format, analyze, tests, coverage ratchet):

```bash
pwsh -File scripts/presubmit.ps1 -Strict
```

Release process and staged rollout: [docs/engineering/RELEASE.md](docs/engineering/RELEASE.md).

## License

MIT License.
