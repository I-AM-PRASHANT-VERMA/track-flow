import 'package:flutter_test/flutter_test.dart';
import 'package:track_flow/domain/day.dart';
import 'package:track_flow/domain/habit.dart';
import 'package:track_flow/features/heatmap/heatmap_cells.dart';
import 'package:track_flow/features/heatmap/heatmap_grid.dart';

void main() {
  final today = Day(2026, 10, 21); // Wednesday
  final grid = HeatmapGrid(today);

  HeatCell cellFor(List<HeatCell> cells, Day day) {
    final offset = day.daysSince(grid.firstDay);
    return cells[(offset ~/ 7) * HeatmapGrid.rows + offset % 7];
  }

  group('HeatmapGrid', () {
    test('rows are fixed weekdays: row 0 is always Monday', () {
      for (final day in [today, today.addDays(1), today.addDays(5)]) {
        final g = HeatmapGrid(day);
        for (var column = 0; column < HeatmapGrid.columns; column++) {
          expect(g.dayAt(column, 0).weekday, DateTime.monday);
        }
      }
    });

    test('the last column is the current week and the grid spans 53 weeks', () {
      expect(grid.dayAt(HeatmapGrid.columns - 1, 2), today);
      expect(grid.firstDay, Day(2025, 10, 20));
    });

    test('taps on a cell find its day; gaps, labels, outside and future find nothing', () {
      Offset centre(int column, int row) => grid.rectAt(column, row).center;

      expect(grid.dayAtPosition(centre(52, 2)), today);
      expect(grid.dayAtPosition(centre(0, 0)), grid.firstDay);
      expect(grid.dayAtPosition(centre(52, 3)), isNull, reason: 'tomorrow');
      expect(grid.dayAtPosition(const Offset(10 * HeatmapGrid.stride + 12, 30)), isNull, reason: 'gap');
      expect(grid.dayAtPosition(const Offset(5, 5)), isNull, reason: 'label row');
      expect(grid.dayAtPosition(const Offset(-1, 30)), isNull);
      expect(grid.dayAtPosition(const Offset(5000, 30)), isNull);
    });

    test('month labels sit on the column that contains the 1st', () {
      final starts = grid.monthStarts();
      expect(starts.map((s) => s.month), containsAllInOrder([11, 12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]));
      for (final start in starts) {
        final week = [for (var row = 0; row < 7; row++) grid.dayAt(start.column, row)];
        expect(week.any((d) => d.day == 1 && d.month == start.month), isTrue);
      }
    });
  });

  group('buildHeatCells', () {
    Habit habit({Map<String, int> logs = const {}, List<int> days = Habit.everyDay, HabitType type = HabitType.boolean, int target = 1}) {
      return Habit(
        id: 'h',
        title: 'h',
        createdAt: DateTime(2026, 10, 1),
        scheduledDays: days,
        logs: logs,
        type: type,
        targetPerDay: target,
      );
    }

    test('rest days, missed days, done days and future days are different', () {
      final cells = buildHeatCells(grid, [habit(days: const [1, 2, 3, 4, 5], logs: {today.key: 1})]);
      expect(cellFor(cells, today).kind, HeatKind.done);
      expect(cellFor(cells, Day(2026, 10, 20)).kind, HeatKind.missed);
      expect(cellFor(cells, Day(2026, 10, 18)).kind, HeatKind.rest, reason: 'Sunday is not scheduled');
      expect(cellFor(cells, Day(2026, 9, 15)).kind, HeatKind.rest, reason: 'before the habit existed');
      expect(cellFor(cells, today.addDays(1)).kind, HeatKind.future);
    });

    test('one measurable habit shows partial progress', () {
      final cells = buildHeatCells(grid, [habit(type: HabitType.measurable, target: 8, logs: {today.key: 6})]);
      final cell = cellFor(cells, today);
      expect(cell.kind, HeatKind.done);
      expect(cell.intensity, 0.75);
    });

    test('several habits: share of scheduled habits completed', () {
      final a = habit(logs: {today.key: 1});
      final b = Habit(id: 'b', title: 'b', createdAt: DateTime(2026, 10, 1));
      expect(cellFor(buildHeatCells(grid, [a, b]), today).intensity, 0.5);
    });

    test('one cell per grid position', () {
      expect(buildHeatCells(grid, const []), hasLength(HeatmapGrid.columns * HeatmapGrid.rows));
    });
  });
}
