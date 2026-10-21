import 'package:flutter_test/flutter_test.dart';
import 'package:track_flow/data/habit_json.dart';
import 'package:track_flow/domain/habit.dart';

void main() {
  final fallback = DateTime(2026);

  Habit? decode(Object? json) =>
      HabitJson.decode(json, fallbackCreatedAt: fallback);

  test('reads schema 1 enums by index and schema 2 enums by name', () {
    final v1 = decode({'id': 'a', 'title': 'A', 'type': 1, 'timeOfDay': 2});
    final v2 = decode({
      'id': 'a',
      'title': 'A',
      'type': 'measurable',
      'timeOfDay': 'evening',
    });
    for (final habit in [v1!, v2!]) {
      expect(habit.type, HabitType.measurable);
      expect(habit.timeOfDay, HabitTimeOfDay.evening);
    }
  });

  test(
    'unknown enum values fall back to the 1.0.0 defaults instead of throwing',
    () {
      final habit = decode({
        'id': 'a',
        'title': 'A',
        'type': 99,
        'timeOfDay': 'midnight',
      })!;
      expect(habit.type, HabitType.boolean);
      expect(habit.timeOfDay, HabitTimeOfDay.anytime);
    },
  );

  test('drops log entries with bad keys or non-positive counts', () {
    final habit = decode({
      'id': 'a',
      'title': 'A',
      'logs': {
        '2026-03-09': 2,
        'garbage': 1,
        '2026-03-10': 0,
        '2026-03-11': -3,
        '2026-02-30': 1,
      },
    })!;
    expect(habit.logs, {'2026-03-09': 2});
  });

  test(
    'missing optional fields use defaults; missing createdAt uses the fallback',
    () {
      final habit = decode({'id': 'a', 'title': 'A'})!;
      expect(habit.targetPerDay, 1);
      expect(habit.scheduledDays, Habit.everyDay);
      expect(habit.unit, 'times');
      expect(habit.createdAt, fallback);
      expect(habit.isArchived, isFalse);
    },
  );

  test(
    'entries without an id or title, or that are not objects, are rejected',
    () {
      expect(decode({'title': 'A'}), isNull);
      expect(decode({'id': '', 'title': 'A'}), isNull);
      expect(decode({'id': 'a'}), isNull);
      expect(decode('a string'), isNull);
      expect(decode(null), isNull);
    },
  );

  test('encode writes enum names and decode restores every field', () {
    final original = Habit(
      id: 'h1',
      title: 'Deep Coding',
      category: 'Focus',
      iconKey: 'code',
      colorValue: 0xFF686CE2,
      type: HabitType.measurable,
      timeOfDay: HabitTimeOfDay.afternoon,
      targetPerDay: 90,
      unit: 'mins',
      scheduledDays: const [1, 2, 3, 4, 5],
      logs: const {'2026-09-28': 90},
      createdAt: DateTime(2026, 9, 1, 7, 30),
      isArchived: true,
    );
    final json = HabitJson.encode(original);
    expect(json['type'], 'measurable');
    expect(json['timeOfDay'], 'afternoon');

    final restored = decode(json)!;
    expect(HabitJson.encode(restored), json);
  });
}
