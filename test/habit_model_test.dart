import 'package:flutter_test/flutter_test.dart';
import 'package:track_flow/models/habit_item.dart';

void main() {
  group('HabitItem Model & Streak Calculations', () {
    test('Calculates current streak correctly for daily consecutive completions', () {
      final now = DateTime.now();
      final todayKey = HabitItem.dateKey(now);
      final yesterdayKey = HabitItem.dateKey(now.subtract(const Duration(days: 1)));
      final twoDaysAgoKey = HabitItem.dateKey(now.subtract(const Duration(days: 2)));

      final habit = HabitItem(
        id: 'test_1',
        title: 'Morning Workout',
        targetPerDay: 1,
        logs: {
          twoDaysAgoKey: 1,
          yesterdayKey: 1,
          todayKey: 1,
        },
      );

      expect(habit.isCompletedToday, isTrue);
      expect(habit.currentStreak, 3);
    });

    test('Streak stays alive today even if today is not completed yet', () {
      final now = DateTime.now();
      final yesterdayKey = HabitItem.dateKey(now.subtract(const Duration(days: 1)));
      final twoDaysAgoKey = HabitItem.dateKey(now.subtract(const Duration(days: 2)));

      final habit = HabitItem(
        id: 'test_2',
        title: 'Read Non-Fiction',
        targetPerDay: 20,
        logs: {
          twoDaysAgoKey: 20,
          yesterdayKey: 20,
          // Today not logged yet
        },
      );

      expect(habit.isCompletedToday, isFalse);
      expect(habit.currentStreak, 2);
    });

    test('Streak resets to 0 if yesterday was missed on a scheduled day', () {
      final now = DateTime.now();
      final threeDaysAgoKey = HabitItem.dateKey(now.subtract(const Duration(days: 3)));

      final habit = HabitItem(
        id: 'test_3',
        title: 'Mindfulness',
        targetPerDay: 1,
        logs: {
          threeDaysAgoKey: 1,
          // Missed 2 days ago and yesterday
        },
      );

      expect(habit.currentStreak, 0);
    });

    test('Measurable habit checks progress against target', () {
      final now = DateTime.now();
      final todayKey = HabitItem.dateKey(now);

      final habit = HabitItem(
        id: 'test_4',
        title: 'Hydration',
        type: HabitType.measurable,
        targetPerDay: 8,
        unit: 'glasses',
        logs: {
          todayKey: 6, // 6 of 8 glasses
        },
      );

      expect(habit.progressToday, 6);
      expect(habit.isCompletedToday, isFalse);

      final completedHabit = habit.copyWith(
        logs: {todayKey: 8},
      );
      expect(completedHabit.isCompletedToday, isTrue);
    });

    test('Serializes to JSON and restores without data loss', () {
      final habit = HabitItem(
        id: 'h_100',
        title: 'Deep Coding',
        category: 'Focus',
        iconCode: '💻',
        colorValue: 0xFF6366F1,
        type: HabitType.measurable,
        timeOfDay: HabitTimeOfDay.afternoon,
        targetPerDay: 90,
        unit: 'mins',
        scheduledDays: [1, 2, 3, 4, 5],
        logs: {'2026-09-28': 90},
      );

      final json = habit.toJson();
      final restored = HabitItem.fromJson(json);

      expect(restored.id, habit.id);
      expect(restored.title, habit.title);
      expect(restored.category, habit.category);
      expect(restored.type, habit.type);
      expect(restored.timeOfDay, habit.timeOfDay);
      expect(restored.targetPerDay, 90);
      expect(restored.unit, 'mins');
      expect(restored.scheduledDays, [1, 2, 3, 4, 5]);
      expect(restored.logs['2026-09-28'], 90);
    });
  });
}
