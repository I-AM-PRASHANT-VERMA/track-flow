import 'package:flutter_test/flutter_test.dart';
import 'package:track_flow/domain/day.dart';
import 'package:track_flow/domain/habit.dart';
import 'package:track_flow/domain/habit_stats.dart';

void main() {
  final today = Day(2026, 3, 18); // a Wednesday

  Habit habit(
    String id, {
    Map<String, int> logs = const {},
    List<int> days = Habit.everyDay,
    bool archived = false,
    DateTime? created,
  }) {
    return Habit(
      id: id,
      title: id,
      createdAt: created ?? DateTime(2026),
      scheduledDays: days,
      logs: logs,
      isArchived: archived,
    );
  }

  group('today', () {
    test('counts only active habits scheduled today', () {
      final summary = HabitStats.today([
        habit('done', logs: {today.key: 1}),
        habit('pending'),
        habit('weekend', days: [6, 7]),
        habit('archived', archived: true, logs: {today.key: 1}),
      ], today);
      expect(summary.scheduled, 2);
      expect(summary.completed, 1);
      expect(summary.ratio, 0.5);
    });

    test('longest streak ignores archived habits', () {
      final streak20 = {for (var i = 0; i < 20; i++) today.addDays(-i).key: 1};
      final summary = HabitStats.today([
        habit('active', logs: {today.key: 1, today.addDays(-1).key: 1}),
        habit('archived', archived: true, logs: streak20),
      ], today);
      expect(summary.longestCurrentStreak, 2);
    });
  });

  group('month', () {
    test('a habit created mid-month is not charged for earlier days', () {
      final created = DateTime(2026, 3, 16);
      final summary = HabitStats.month([
        habit(
          'new',
          created: created,
          logs: {
            Day(2026, 3, 16).key: 1,
            Day(2026, 3, 17).key: 1,
            today.key: 1,
          },
        ),
      ], today);
      expect(summary.monthToDate.scheduled, 3);
      expect(summary.monthToDate.completed, 3);
      expect(summary.perfectDays, 3);
      expect(summary.elapsedDays, 18);
      expect(summary.daysInMonth, 31);
    });

    test('best streak is the longest run, not the current one', () {
      final oldRun = {
        for (var i = 0; i < 5; i++) Day(2026, 3, 1).addDays(i).key: 1,
      };
      final summary = HabitStats.month([habit('h', logs: oldRun)], today);
      expect(summary.bestStreak, 5);
    });

    test('rolling 30 days pools scheduled days across habits', () {
      final summary = HabitStats.month([
        habit('daily', created: DateTime(2026, 3, 17), logs: {today.key: 1}),
        habit('weekly', days: [3], created: DateTime(2026, 3, 18)),
      ], today);
      // daily: 17th missed, 18th done; weekly: 18th (Wed) missed.
      expect(summary.rolling30.scheduled, 3);
      expect(summary.rolling30.completed, 1);
    });
  });

  group('year', () {
    test('active days, peak weekday and totals', () {
      final logs = {
        Day(2026, 3, 16).key: 1,
        Day(2026, 3, 9).key: 1,
      }; // two Mondays
      final summary = HabitStats.year([
        habit('h', logs: logs, created: DateTime(2026, 3, 9)),
      ], today);
      expect(summary.activeDays, 2);
      expect(summary.peakWeekday, DateTime.monday);
      expect(summary.peakWeekdayRatio, 1.0);
      expect(summary.total.scheduled, 10); // 9th..18th
      expect(summary.habitCount, 1);
    });

    test('no habits gives an empty summary', () {
      final summary = HabitStats.year(const [], today);
      expect(summary.total.scheduled, 0);
      expect(summary.peakWeekday, isNull);
    });
  });
}
