import 'package:flutter_test/flutter_test.dart';
import 'package:track_flow/domain/day.dart';
import 'package:track_flow/domain/habit.dart';
import 'package:track_flow/domain/habit_rules.dart';

Habit _habit({
  Map<String, int> logs = const {},
  List<int> days = Habit.everyDay,
  int target = 1,
  DateTime? createdAt,
}) {
  return Habit(
    id: 'h',
    title: 'Habit',
    createdAt: createdAt ?? DateTime(2026),
    targetPerDay: target,
    scheduledDays: days,
    logs: logs,
  );
}

Map<String, int> _daily(Day last, int count, {int value = 1}) => {
  for (var i = 0; i < count; i++) last.addDays(-i).key: value,
};

void main() {
  final today = Day(2026, 3, 9); // a Monday

  group('currentStreak', () {
    test('counts consecutive completed days ending today', () {
      expect(
        HabitRules.currentStreak(_habit(logs: _daily(today, 3)), today),
        3,
      );
    });

    test('stays alive while today is still pending', () {
      final habit = _habit(logs: _daily(today.addDays(-1), 2));
      expect(HabitRules.currentStreak(habit, today), 2);
    });

    test('a missed scheduled day breaks it', () {
      final habit = _habit(logs: {today.addDays(-3).key: 1});
      expect(HabitRules.currentStreak(habit, today), 0);
    });

    test('rest days neither count nor break (Mon-Fri, done Fri and Mon)', () {
      final habit = _habit(
        days: [1, 2, 3, 4, 5],
        logs: {Day(2026, 3, 6).key: 1, Day(2026, 3, 9).key: 1},
      );
      expect(HabitRules.currentStreak(habit, today), 2);
    });

    test('is not capped by the creation date (40 days, created today)', () {
      final habit = _habit(
        logs: _daily(today, 40),
        createdAt: today.toLocalDateTime(),
      );
      expect(HabitRules.currentStreak(habit, today), 40);
    });

    test(
      'recomputes for a new day: same habit, next day pending, then missed',
      () {
        final habit = _habit(logs: _daily(today, 5));
        expect(HabitRules.currentStreak(habit, today), 5);
        expect(HabitRules.currentStreak(habit, today.addDays(1)), 5);
        expect(HabitRules.currentStreak(habit, today.addDays(2)), 0);
      },
    );

    test('measurable habit needs the full target', () {
      final habit = _habit(
        target: 8,
        logs: {today.key: 8, today.addDays(-1).key: 6},
      );
      expect(HabitRules.currentStreak(habit, today), 1);
    });
  });

  group('bestStreak', () {
    test('uses the same rest-day rule as currentStreak', () {
      final habit = _habit(
        days: [1, 2, 3, 4, 5],
        logs: {Day(2026, 3, 6).key: 1, Day(2026, 3, 9).key: 1},
      );
      expect(HabitRules.bestStreak(habit, today), 2);
    });

    test('finds an older, longer run', () {
      final habit = _habit(
        logs: {..._daily(Day(2026, 2, 20), 5), today.key: 1},
      );
      expect(HabitRules.bestStreak(habit, today), 5);
      expect(HabitRules.currentStreak(habit, today), 1);
    });

    test('runs straight through daylight-saving dates', () {
      final habit = _habit(
        logs: _daily(Day(2026, 3, 9), 5),
      ); // spans 2026-03-08
      expect(HabitRules.bestStreak(habit, today), 5);
    });

    test('ignores unparseable log keys instead of throwing', () {
      final habit = _habit(logs: {'garbage': 1, today.key: 1});
      expect(HabitRules.bestStreak(habit, today), 1);
      expect(HabitRules.currentStreak(habit, today), 1);
    });

    test('is zero with no logs', () {
      expect(HabitRules.bestStreak(_habit(), today), 0);
    });
  });

  group('startDay and tally', () {
    test('start is the earlier of creation and first log', () {
      final habit = _habit(
        logs: {Day(2026, 2, 1).key: 1},
        createdAt: DateTime(2026, 3),
      );
      expect(HabitRules.startDay(habit), Day(2026, 2, 1));
      expect(
        HabitRules.startDay(_habit(createdAt: DateTime(2026, 3, 5, 18))),
        Day(2026, 3, 5),
      );
    });

    test('days before the habit started are not counted as missed', () {
      final habit = _habit(
        createdAt: DateTime(2026, 3, 8),
        logs: {today.key: 1},
      );
      final tally = HabitRules.tally(habit, today, days: 30);
      expect(tally.scheduled, 2);
      expect(tally.completed, 1);
    });
  });

  group('Habit invariants', () {
    test('target below 1 is raised to 1, so zero progress is never done', () {
      final habit = _habit(target: 0);
      expect(habit.targetPerDay, 1);
      expect(habit.isCompletedOn(today), isFalse);
    });

    test('scheduled days are cleaned, sorted and never empty', () {
      expect(_habit(days: [5, 1, 9, 1]).scheduledDays, [1, 5]);
      expect(_habit(days: []).scheduledDays, Habit.everyDay);
    });

    test(
      'withProgress removes the entry at zero and keeps the original untouched',
      () {
        final original = _habit(logs: {today.key: 3});
        final cleared = original.withProgress(today, 0);
        expect(cleared.logs.containsKey(today.key), isFalse);
        expect(original.logs[today.key], 3);
      },
    );
  });
}
