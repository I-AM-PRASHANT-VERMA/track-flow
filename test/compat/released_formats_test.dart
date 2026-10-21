// Contract test: every data format that has shipped must keep loading, forever.
// Fixtures under test/fixtures are FROZEN (docs/engineering/COMPATIBILITY.md):
// add a new file for a new format, never edit an existing one.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_flow/data/backup_codec.dart';
import 'package:track_flow/data/habit_json.dart';
import 'package:track_flow/data/shared_prefs_habit_store.dart';
import 'package:track_flow/domain/day.dart';
import 'package:track_flow/domain/habit.dart';

String _fixture(String name) => File('test/fixtures/$name').readAsStringSync();

/// The same three habits are stored in every fixture; each format must decode to them.
void _expectFixtureHabits(List<Habit> habits) {
  expect(habits.map((h) => h.id), [
    'fixture_habit_1',
    'fixture_habit_2',
    'fixture_habit_3',
  ]);

  final run = habits[0];
  expect(run.type, HabitType.boolean);
  expect(run.timeOfDay, HabitTimeOfDay.morning);
  expect(run.iconKey, 'fitness');
  expect(run.colorValue, 4279739713);

  final water = habits[1];
  expect(water.type, HabitType.measurable);
  expect(water.timeOfDay, HabitTimeOfDay.afternoon);
  expect(water.targetPerDay, 8);
  expect(water.unit, 'glasses');
  expect(water.progressOn(Day(2026, 3, 9)), 6);
  expect(water.logs, {'2026-03-08': 8, '2026-03-09': 6});

  final reading = habits[2];
  expect(reading.timeOfDay, HabitTimeOfDay.anytime);
  expect(reading.scheduledDays, [1, 2, 3, 4, 5]);
  expect(reading.isArchived, isTrue);
  expect(reading.createdAt, DateTime(2025, 11, 20, 21, 15));
}

void main() {
  final now = DateTime(2026, 10, 21);

  Future<List<Habit>> readStored(Map<String, Object> prefs) async {
    SharedPreferences.setMockInitialValues(prefs);
    final store = SharedPrefsHabitStore(
      await SharedPreferences.getInstance(),
      clock: () => now,
    );
    final stored = await store.read();
    expect(stored.hadUnreadableData, isFalse);
    return stored.habits;
  }

  group('stored habits', () {
    test('schema 1 (app 1.0.0, key track_flow_habits_v1)', () async {
      _expectFixtureHabits(
        await readStored({
          SharedPrefsHabitStore.legacyKey: _fixture('habits_v1.json'),
        }),
      );
    });

    test('schema 2 (key track_flow_habits_v2)', () async {
      _expectFixtureHabits(
        await readStored({
          SharedPrefsHabitStore.currentKey: _fixture('habits_v2.json'),
        }),
      );
    });

    test(
      'the current encoder still writes exactly the frozen schema 2 shape',
      () {
        final frozen =
            jsonDecode(_fixture('habits_v2.json')) as Map<String, Object?>;
        for (final entry in frozen['habits']! as List<Object?>) {
          final habit = HabitJson.decode(entry, fallbackCreatedAt: now)!;
          expect(HabitJson.encode(habit), entry);
        }
      },
    );
  });

  group('backups', () {
    test('exported by app 1.0.0', () {
      _expectFixtureHabits(
        BackupCodec.parse(_fixture('backup_v1.json'), now: now).habits,
      );
    });

    test('schema 2', () {
      _expectFixtureHabits(
        BackupCodec.parse(_fixture('backup_v2.json'), now: now).habits,
      );
    });
  });
}
