// Contract test: every data format that has shipped must keep loading, forever.
// The fixtures under test/fixtures are FROZEN (see docs/engineering/COMPATIBILITY.md): add new files, never edit these.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_flow/core/services/habit_storage.dart';
import 'package:track_flow/models/habit_item.dart';

List<dynamic> _readList(String path) =>
    jsonDecode(File(path).readAsStringSync()) as List<dynamic>;

void main() {
  group('v1 stored habits (bare JSON list, enums by index)', () {
    final raw = _readList('test/fixtures/habits_v1.json');

    test('every habit loads with the expected values', () {
      final habits = raw
          .map((e) => HabitItem.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(habits.map((h) => h.id), [
        'fixture_habit_1',
        'fixture_habit_2',
        'fixture_habit_3',
      ]);
      expect(habits[0].type, HabitType.boolean);
      expect(habits[0].timeOfDay, HabitTimeOfDay.morning);
      expect(habits[1].type, HabitType.measurable);
      expect(habits[1].timeOfDay, HabitTimeOfDay.afternoon);
      expect(habits[1].targetPerDay, 8);
      expect(habits[1].progressOn(DateTime(2026, 3, 9)), 6);
      expect(habits[2].scheduledDays, [1, 2, 3, 4, 5]);
      expect(habits[2].isArchived, isTrue);
      expect(habits[2].createdAt, DateTime(2025, 11, 20, 21, 15));
    });

    test('toJson of a loaded habit equals the stored JSON (no field is lost or renamed)', () {
      for (final entry in raw) {
        final map = entry as Map<String, dynamic>;
        expect(HabitItem.fromJson(map).toJson(), map);
      }
    });
  });

  group('v1 backup file', () {
    test(
      'importBackupJson restores all habits from the frozen backup',
      () async {
        SharedPreferences.setMockInitialValues({});
        final backup = File('test/fixtures/backup_v1.json').readAsStringSync();

        final ok = await HabitStorage.importBackupJson(backup);
        final restored = await HabitStorage.loadHabits();

        expect(ok, isTrue);
        expect(restored.map((h) => h.id), [
          'fixture_habit_1',
          'fixture_habit_2',
          'fixture_habit_3',
        ]);
        expect(restored[1].logs, {'2026-03-08': 8, '2026-03-09': 6});
      },
    );
  });
}
