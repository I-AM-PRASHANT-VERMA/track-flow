import '../../domain/habit.dart';
import '../../domain/habit_rules.dart';
import 'heatmap_grid.dart';

enum HeatKind {
  /// After today: not drawn.
  future,

  /// No habit existed yet: drawn as a faint empty cell, like GitHub's empty days.
  none,

  /// Habits existed but none was scheduled (a rest day): drawn hollow.
  rest,

  /// Scheduled but nothing done: drawn as an empty filled cell.
  missed,

  /// Something done; [HeatCell.intensity] says how much.
  done,
}

final class HeatCell {
  const HeatCell(this.kind, [this.intensity = 0]);

  static const HeatCell future = HeatCell(HeatKind.future);
  static const HeatCell none = HeatCell(HeatKind.none);
  static const HeatCell rest = HeatCell(HeatKind.rest);
  static const HeatCell missed = HeatCell(HeatKind.missed);

  final HeatKind kind;

  /// 0..1 share of the day's goal reached.
  final double intensity;
}

/// One cell per grid position, column by column. Built once per data change so
/// painting never loops over habits.
///
/// With several habits a day's intensity is the share of scheduled habits that
/// were completed. For a single measurable habit it is the share of its daily
/// target, so 6 of 8 glasses shows as a lighter cell instead of an empty one.
List<HeatCell> buildHeatCells(HeatmapGrid grid, List<Habit> habits) {
  final starts = [for (final habit in habits) HabitRules.startDay(habit)];
  final single = habits.length == 1 ? habits.single : null;
  final cells = <HeatCell>[];

  for (var column = 0; column < HeatmapGrid.columns; column++) {
    for (var row = 0; row < HeatmapGrid.rows; row++) {
      final day = grid.dayAt(column, row);
      if (day.isAfter(grid.today)) {
        cells.add(HeatCell.future);
        continue;
      }

      var started = 0;
      var scheduled = 0;
      var completed = 0;
      for (var i = 0; i < habits.length; i++) {
        final habit = habits[i];
        if (day.isBefore(starts[i])) continue;
        started++;
        if (!habit.isScheduledOn(day)) continue;
        scheduled++;
        if (habit.isCompletedOn(day)) completed++;
      }

      if (started == 0) {
        cells.add(HeatCell.none);
        continue;
      }
      if (scheduled == 0) {
        cells.add(HeatCell.rest);
        continue;
      }
      final intensity = single != null && single.type == HabitType.measurable
          ? (single.progressOn(day) / single.targetPerDay).clamp(0.0, 1.0)
          : completed / scheduled;
      cells.add(
        intensity == 0 ? HeatCell.missed : HeatCell(HeatKind.done, intensity),
      );
    }
  }
  return cells;
}
