import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/clock.dart';
import '../domain/habit.dart';
import 'habit_json.dart';
import 'habit_store.dart';

/// [HabitStore] on SharedPreferences, following the expand/contract rule in
/// docs/engineering/COMPATIBILITY.md:
/// - reads the current key, and the 1.0.0 key when there is no current data;
/// - writes only the current key, so the 1.0.0 key stays intact for a rollback;
/// - never overwrites data it could not read: a raw copy goes to a recovery key.
final class SharedPrefsHabitStore implements HabitStore {
  SharedPrefsHabitStore(this._prefs, {required Clock clock}) : _clock = clock;

  /// Released 1.0.0 key: a bare JSON list (schema 1). Read once for migration,
  /// never written or deleted.
  static const String legacyKey = 'track_flow_habits_v1';

  /// Current key: `{"schemaVersion": 2, "habits": [...]}`.
  static const String currentKey = 'track_flow_habits_v2';

  static const String recoveryKeyPrefix = 'track_flow_recovery_';

  final SharedPreferences _prefs;
  final Clock _clock;

  @override
  Future<StoredHabits> read() async {
    final current = _prefs.getString(currentKey);
    if (current != null) {
      final parsed = _parse(current, expectEnvelope: true);
      if (parsed != null && !parsed.lostEntries) return StoredHabits(parsed.habits);

      // The next write would replace this payload, so keep it first.
      await _keepRecoveryCopy(current);
      if (parsed != null) return StoredHabits(parsed.habits, hadUnreadableData: true);
      final fallback = _readLegacy();
      return StoredHabits(fallback?.habits ?? const [], hadUnreadableData: true);
    }

    final legacy = _readLegacy();
    if (legacy == null) {
      final hasLegacy = _prefs.getString(legacyKey) != null;
      return StoredHabits(const [], hadUnreadableData: hasLegacy);
    }
    // The legacy key itself is never overwritten, so it is the recovery copy.
    return StoredHabits(legacy.habits, hadUnreadableData: legacy.lostEntries);
  }

  @override
  Future<void> write(List<Habit> habits) async {
    final payload = jsonEncode({
      'schemaVersion': HabitJson.currentSchema,
      'habits': [for (final habit in habits) HabitJson.encode(habit)],
    });
    final saved = await _prefs.setString(currentKey, payload);
    if (!saved) throw StateError('Saving habits failed.');
  }

  _Parsed? _readLegacy() {
    final raw = _prefs.getString(legacyKey);
    return raw == null ? null : _parse(raw, expectEnvelope: false);
  }

  /// Null when the payload as a whole is unusable.
  _Parsed? _parse(String raw, {required bool expectEnvelope}) {
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return null;
    }

    final Object? entries;
    if (expectEnvelope) {
      if (decoded is! Map<String, Object?>) return null;
      final schema = decoded['schemaVersion'];
      if (schema is! int || schema > HabitJson.currentSchema) return null;
      entries = decoded['habits'];
    } else {
      entries = decoded;
    }
    if (entries is! List<Object?>) return null;

    final fallbackCreatedAt = _clock();
    final seenIds = <String>{};
    final habits = <Habit>[];
    var lost = false;
    for (final entry in entries) {
      final habit = HabitJson.decode(entry, fallbackCreatedAt: fallbackCreatedAt);
      if (habit == null || !seenIds.add(habit.id)) {
        lost = true;
        continue;
      }
      habits.add(habit);
    }
    return _Parsed(habits, lostEntries: lost);
  }

  Future<void> _keepRecoveryCopy(String raw) async {
    await _prefs.setString('$recoveryKeyPrefix${_clock().millisecondsSinceEpoch}', raw);
  }
}

final class _Parsed {
  const _Parsed(this.habits, {required this.lostEntries});

  final List<Habit> habits;
  final bool lostEntries;
}
