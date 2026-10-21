import 'dart:convert';

import '../domain/habit.dart';
import 'habit_json.dart';

/// Why a backup cannot be restored; [message] is shown to the user as-is.
enum BackupProblem {
  notABackup('This text is not a TrackFlow backup.'),
  newerVersion(
    'This backup was made by a newer version of TrackFlow. Update the app first.',
  ),
  unreadableHabit(
    'Some habits in this backup could not be read. Nothing was changed.',
  ),
  duplicateHabit(
    'This backup lists the same habit twice. Nothing was changed.',
  );

  const BackupProblem(this.message);

  final String message;
}

final class BackupException implements Exception {
  const BackupException(this.problem);

  final BackupProblem problem;

  @override
  String toString() => 'BackupException: ${problem.message}';
}

/// A backup that passed validation and is safe to restore.
final class ParsedBackup {
  const ParsedBackup(this.habits);

  final List<Habit> habits;
}

/// Export and import format for user backups (clipboard text).
///
/// Shape: `{"app": "TrackFlow", "schemaVersion": 2, "exportedAt": ..., "habits": [...]}`.
/// Backups written by app 1.0.0 have no schemaVersion and are read as schema 1.
/// A backup is validated completely before anything is restored.
abstract final class BackupCodec {
  static String export(List<Habit> habits, {required DateTime now}) {
    return jsonEncode({
      'app': 'TrackFlow',
      'schemaVersion': HabitJson.currentSchema,
      'exportedAt': now.toIso8601String(),
      'habits': [for (final habit in habits) HabitJson.encode(habit)],
    });
  }

  /// Throws [BackupException] when [raw] is not a complete, valid backup.
  static ParsedBackup parse(String raw, {required DateTime now}) {
    final Object? decoded;
    try {
      decoded = jsonDecode(raw.trim());
    } on FormatException {
      throw const BackupException(BackupProblem.notABackup);
    }

    final Object? entries;
    if (decoded is Map<String, Object?>) {
      final schema = decoded['schemaVersion'] ?? 1;
      if (schema is! int) throw const BackupException(BackupProblem.notABackup);
      if (schema > HabitJson.currentSchema) {
        throw const BackupException(BackupProblem.newerVersion);
      }
      entries = decoded['habits'];
    } else {
      entries = decoded; // a raw 1.0.0 storage dump is a bare list
    }
    if (entries is! List<Object?>) {
      throw const BackupException(BackupProblem.notABackup);
    }

    final ids = <String>{};
    final habits = <Habit>[];
    for (final entry in entries) {
      final habit = HabitJson.decode(entry, fallbackCreatedAt: now);
      if (habit == null) {
        throw const BackupException(BackupProblem.unreadableHabit);
      }
      if (!ids.add(habit.id)) {
        throw const BackupException(BackupProblem.duplicateHabit);
      }
      habits.add(habit);
    }
    return ParsedBackup(habits);
  }
}
