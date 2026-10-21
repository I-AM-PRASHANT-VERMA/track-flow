import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_flow/data/shared_prefs_habit_store.dart';
import 'package:track_flow/domain/habit.dart';

void main() {
  final now = DateTime(2026, 3, 9, 12);
  final legacyFixture = File('test/fixtures/habits_v1.json').readAsStringSync();

  Future<(SharedPrefsHabitStore, SharedPreferences)> storeWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    final prefs = await SharedPreferences.getInstance();
    return (SharedPrefsHabitStore(prefs, clock: () => now), prefs);
  }

  Iterable<String> recoveryKeys(SharedPreferences prefs) =>
      prefs.getKeys().where((k) => k.startsWith(SharedPrefsHabitStore.recoveryKeyPrefix));

  test('a fresh install starts empty, with no invented demo data', () async {
    final (store, _) = await storeWith({});
    final stored = await store.read();
    expect(stored.habits, isEmpty);
    expect(stored.hadUnreadableData, isFalse);
  });

  test('1.0.0 data is migrated on read and the 1.0.0 key is never modified', () async {
    final (store, prefs) = await storeWith({SharedPrefsHabitStore.legacyKey: legacyFixture});

    final stored = await store.read();
    expect(stored.habits.map((h) => h.id), ['fixture_habit_1', 'fixture_habit_2', 'fixture_habit_3']);
    await store.write(stored.habits);

    expect(prefs.getString(SharedPrefsHabitStore.legacyKey), legacyFixture);
    final current = jsonDecode(prefs.getString(SharedPrefsHabitStore.currentKey)!) as Map<String, Object?>;
    expect(current['schemaVersion'], 2);
    expect((current['habits']! as List<Object?>).length, 3);
  });

  test('current data wins over 1.0.0 data', () async {
    final (store, _) = await storeWith({
      SharedPrefsHabitStore.legacyKey: legacyFixture,
      SharedPrefsHabitStore.currentKey: jsonEncode({'schemaVersion': 2, 'habits': <Object?>[]}),
    });
    expect((await store.read()).habits, isEmpty);
  });

  test('a corrupt current payload is copied aside, never overwritten, and 1.0.0 data is used', () async {
    final (store, prefs) = await storeWith({
      SharedPrefsHabitStore.legacyKey: legacyFixture,
      SharedPrefsHabitStore.currentKey: '{not json',
    });

    final stored = await store.read();
    expect(stored.hadUnreadableData, isTrue);
    expect(stored.habits, hasLength(3));
    final copies = recoveryKeys(prefs).toList();
    expect(copies, hasLength(1));
    expect(prefs.getString(copies.single), '{not json');
  });

  test('one unreadable habit does not discard the others; a copy is kept', () async {
    final (store, prefs) = await storeWith({
      SharedPrefsHabitStore.currentKey: jsonEncode({
        'schemaVersion': 2,
        'habits': [
          {'id': 'ok', 'title': 'Fine'},
          {'title': 'no id'},
        ],
      }),
    });
    final stored = await store.read();
    expect(stored.habits.map((h) => h.id), ['ok']);
    expect(stored.hadUnreadableData, isTrue);
    expect(recoveryKeys(prefs), hasLength(1));
  });

  test('duplicate ids keep the first habit', () async {
    final (store, _) = await storeWith({
      SharedPrefsHabitStore.currentKey: jsonEncode({
        'schemaVersion': 2,
        'habits': [
          {'id': 'a', 'title': 'First'},
          {'id': 'a', 'title': 'Second'},
        ],
      }),
    });
    final stored = await store.read();
    expect(stored.habits.single.title, 'First');
    expect(stored.hadUnreadableData, isTrue);
  });

  test('data from a newer schema is treated as unreadable and kept', () async {
    const newer = '{"schemaVersion": 3, "habits": []}';
    final (store, prefs) = await storeWith({SharedPrefsHabitStore.currentKey: newer});
    final stored = await store.read();
    expect(stored.hadUnreadableData, isTrue);
    expect(recoveryKeys(prefs).map(prefs.getString), contains(newer));
  });

  test('corrupt 1.0.0 data is reported and left in place', () async {
    final (store, prefs) = await storeWith({SharedPrefsHabitStore.legacyKey: '[{broken'});
    final stored = await store.read();
    expect(stored.habits, isEmpty);
    expect(stored.hadUnreadableData, isTrue);
    expect(prefs.getString(SharedPrefsHabitStore.legacyKey), '[{broken');
  });

  test('write then read returns the same habits', () async {
    final (store, _) = await storeWith({});
    final habit = Habit(
      id: 'x',
      title: 'Walk',
      createdAt: now,
      type: HabitType.measurable,
      targetPerDay: 5,
      logs: const {'2026-03-09': 3},
    );
    await store.write([habit]);
    final read = (await store.read()).habits.single;
    expect(read.id, 'x');
    expect(read.type, HabitType.measurable);
    expect(read.logs, {'2026-03-09': 3});
  });
}
