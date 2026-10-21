import 'day.dart';
import 'habit.dart';

/// Scheduled vs. completed day counts. Pooled across habits by adding tallies,
/// which weighs every scheduled day equally (averaging per-habit percentages
/// would let a habit scheduled once a week count as much as a daily one).
final class Tally {
  const Tally({this.scheduled = 0, this.completed = 0});

  static const Tally zero = Tally();

  final int scheduled;
  final int completed;

  /// 0..1; zero when nothing was scheduled.
  double get ratio => scheduled == 0 ? 0 : completed / scheduled;

  Tally operator +(Tally other) => Tally(
    scheduled: scheduled + other.scheduled,
    completed: completed + other.completed,
  );
}

/// Streak and consistency rules for a single habit. Pure functions of the habit
/// and "today", so results never go stale across midnight and every rule can be
/// tested at a fixed date.
abstract final class HabitRules {
  /// First day the habit is judged on: the earlier of its creation day and its
  /// earliest logged day (imported or pre-filled histories start before creation).
  static Day startDay(Habit habit) {
    final created = Day.of(habit.createdAt);
    final earliestLog = earliestLoggedDay(habit);
    return earliestLog != null && earliestLog.isBefore(created)
        ? earliestLog
        : created;
  }

  /// Earliest day with a positive log, or null when nothing was ever logged.
  static Day? earliestLoggedDay(Habit habit) {
    Day? earliest;
    for (final entry in habit.logs.entries) {
      if (entry.value <= 0) continue;
      final day = Day.tryParseKey(entry.key);
      if (day != null && (earliest == null || day.isBefore(earliest))) {
        earliest = day;
      }
    }
    return earliest;
  }

  /// Consecutive completed scheduled days ending today. Today counts once it is
  /// done; until then yesterday's streak stays alive. Days the habit is not
  /// scheduled on neither count nor break the streak.
  static int currentStreak(Habit habit, Day today) {
    final earliest = earliestLoggedDay(habit);
    if (earliest == null) return 0;

    var streak = habit.isScheduledOn(today) && habit.isCompletedOn(today)
        ? 1
        : 0;
    for (
      var day = today.addDays(-1);
      !day.isBefore(earliest);
      day = day.addDays(-1)
    ) {
      if (!habit.isScheduledOn(day)) continue;
      if (!habit.isCompletedOn(day)) break;
      streak++;
    }
    return streak;
  }

  /// Longest run of completed scheduled days up to today, using the same rules
  /// as [currentStreak]; never smaller than it.
  static int bestStreak(Habit habit, Day today) {
    final earliest = earliestLoggedDay(habit);
    if (earliest == null) return 0;

    var best = 0;
    var run = 0;
    for (var day = earliest; !day.isAfter(today); day = day.addDays(1)) {
      if (!habit.isScheduledOn(day)) continue;
      if (habit.isCompletedOn(day)) {
        run++;
        if (run > best) best = run;
      } else {
        run = 0;
      }
    }
    final current = currentStreak(habit, today);
    return best > current ? best : current;
  }

  /// Scheduled and completed days among the [days] days ending today, counting
  /// only days on or after [startDay] (a new habit is not penalised for the
  /// days before it existed).
  static Tally tally(Habit habit, Day today, {required int days}) {
    final start = startDay(habit);
    var scheduled = 0;
    var completed = 0;
    for (var offset = 0; offset < days; offset++) {
      final day = today.addDays(-offset);
      if (day.isBefore(start)) break;
      if (!habit.isScheduledOn(day)) continue;
      scheduled++;
      if (habit.isCompletedOn(day)) completed++;
    }
    return Tally(scheduled: scheduled, completed: completed);
  }
}
