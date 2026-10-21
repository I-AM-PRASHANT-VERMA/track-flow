import 'day.dart';
import 'habit.dart';
import 'habit_rules.dart';

/// Header numbers for today.
final class TodaySummary {
  const TodaySummary({
    required this.scheduled,
    required this.completed,
    required this.longestCurrentStreak,
  });

  final int scheduled;
  final int completed;
  final int longestCurrentStreak;

  double get ratio => scheduled == 0 ? 0 : completed / scheduled;
}

/// Month-to-date and rolling numbers for the matrix view.
final class MonthSummary {
  const MonthSummary({
    required this.monthToDate,
    required this.perfectDays,
    required this.elapsedDays,
    required this.daysInMonth,
    required this.rolling30,
    required this.bestStreak,
  });

  final Tally monthToDate;
  final int perfectDays;
  final int elapsedDays;
  final int daysInMonth;
  final Tally rolling30;
  final int bestStreak;
}

/// Past-365-days numbers for the heatmap view.
final class YearSummary {
  const YearSummary({
    required this.total,
    required this.activeDays,
    required this.peakWeekday,
    required this.peakWeekdayRatio,
    required this.bestStreak,
    required this.habitCount,
  });

  final Tally total;
  final int activeDays;

  /// ISO weekday with the best completion ratio, or null when nothing was scheduled.
  final int? peakWeekday;
  final double peakWeekdayRatio;
  final int bestStreak;
  final int habitCount;
}

/// Aggregates across habits. Every function ignores archived habits and counts
/// a habit only from its start day, so all screens agree on the same numbers.
abstract final class HabitStats {
  static List<Habit> active(Iterable<Habit> habits) =>
      habits.where((h) => h.isActive).toList(growable: false);

  static TodaySummary today(Iterable<Habit> habits, Day today) {
    var scheduled = 0;
    var completed = 0;
    var longest = 0;
    for (final habit in active(habits)) {
      if (habit.isScheduledOn(today)) {
        scheduled++;
        if (habit.isCompletedOn(today)) completed++;
      }
      final streak = HabitRules.currentStreak(habit, today);
      if (streak > longest) longest = streak;
    }
    return TodaySummary(
      scheduled: scheduled,
      completed: completed,
      longestCurrentStreak: longest,
    );
  }

  static MonthSummary month(Iterable<Habit> habits, Day today) {
    final tracked = _Tracked(active(habits));
    final firstOfMonth = Day(today.year, today.month, 1);

    var monthToDate = Tally.zero;
    var perfectDays = 0;
    for (var day = firstOfMonth; !day.isAfter(today); day = day.addDays(1)) {
      final dayTally = tracked.tallyOn(day);
      monthToDate += dayTally;
      if (dayTally.scheduled > 0 && dayTally.completed == dayTally.scheduled) perfectDays++;
    }

    var rolling30 = Tally.zero;
    var bestStreak = 0;
    for (final habit in tracked.habits) {
      rolling30 += HabitRules.tally(habit, today, days: 30);
      final best = HabitRules.bestStreak(habit, today);
      if (best > bestStreak) bestStreak = best;
    }

    return MonthSummary(
      monthToDate: monthToDate,
      perfectDays: perfectDays,
      elapsedDays: today.day,
      daysInMonth: Day(today.year, today.month + 1, 0).day,
      rolling30: rolling30,
      bestStreak: bestStreak,
    );
  }

  static YearSummary year(Iterable<Habit> habits, Day today) {
    final tracked = _Tracked(active(habits));
    var total = Tally.zero;
    var activeDays = 0;
    final byWeekday = List<Tally>.filled(8, Tally.zero);

    for (var offset = 0; offset < 365; offset++) {
      final day = today.addDays(-offset);
      final dayTally = tracked.tallyOn(day);
      total += dayTally;
      if (dayTally.completed > 0) activeDays++;
      byWeekday[day.weekday] += dayTally;
    }

    int? peakWeekday;
    var peakRatio = 0.0;
    for (var weekday = 1; weekday <= 7; weekday++) {
      final tally = byWeekday[weekday];
      if (tally.scheduled > 0 && (peakWeekday == null || tally.ratio > peakRatio)) {
        peakWeekday = weekday;
        peakRatio = tally.ratio;
      }
    }

    var bestStreak = 0;
    for (final habit in tracked.habits) {
      final best = HabitRules.bestStreak(habit, today);
      if (best > bestStreak) bestStreak = best;
    }

    return YearSummary(
      total: total,
      activeDays: activeDays,
      peakWeekday: peakWeekday,
      peakWeekdayRatio: peakRatio,
      bestStreak: bestStreak,
      habitCount: tracked.habits.length,
    );
  }

  /// Scheduled and completed counts on [day] across active, already started habits.
  static Tally onDay(Iterable<Habit> habits, Day day) => _Tracked(active(habits)).tallyOn(day);
}

/// Habits with their start days computed once, for loops over many days.
final class _Tracked {
  _Tracked(this.habits) : _starts = [for (final h in habits) HabitRules.startDay(h)];

  final List<Habit> habits;
  final List<Day> _starts;

  Tally tallyOn(Day day) {
    var scheduled = 0;
    var completed = 0;
    for (var i = 0; i < habits.length; i++) {
      final habit = habits[i];
      if (day.isBefore(_starts[i]) || !habit.isScheduledOn(day)) continue;
      scheduled++;
      if (habit.isCompletedOn(day)) completed++;
    }
    return Tally(scheduled: scheduled, completed: completed);
  }
}
