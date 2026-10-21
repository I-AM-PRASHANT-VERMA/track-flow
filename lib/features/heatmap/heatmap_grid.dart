import 'dart:ui';

import '../../domain/day.dart';

/// Geometry and calendar of the 53-week canvas. Columns are ISO weeks
/// (Monday to Sunday, top to bottom) and the last column is the week of
/// [today], so a row always means the same weekday, as on GitHub.
final class HeatmapGrid {
  HeatmapGrid(this.today)
    : firstDay = today.startOfWeek.addDays(-(columns - 1) * 7);

  static const int columns = 53;
  static const int rows = 7;
  static const double cellSize = 11;
  static const double gap = 2;
  static const double stride = cellSize + gap;
  static const double labelHeight = 16;

  static const Size size = Size(
    columns * stride - gap,
    labelHeight + rows * stride - gap,
  );

  final Day today;
  final Day firstDay;

  Day dayAt(int column, int row) => firstDay.addDays(column * 7 + row);

  Rect rectAt(int column, int row) => Rect.fromLTWH(
    column * stride,
    labelHeight + row * stride,
    cellSize,
    cellSize,
  );

  /// The past or current day under [position]; null for labels, gaps between
  /// cells, positions outside the grid and days after [today].
  Day? dayAtPosition(Offset position) {
    final y = position.dy - labelHeight;
    if (position.dx < 0 || y < 0) return null;
    final column = position.dx ~/ stride;
    final row = y ~/ stride;
    if (column >= columns || row >= rows) return null;
    if (position.dx - column * stride > cellSize ||
        y - row * stride > cellSize) {
      return null;
    }
    final day = dayAt(column, row);
    return day.isAfter(today) ? null : day;
  }

  /// Columns that contain the 1st of a month, with that month (1-12).
  List<({int column, int month})> monthStarts() {
    return [
      for (var column = 0; column < columns; column++)
        for (var row = 0; row < rows; row++)
          if (dayAt(column, row) case final day
              when day.day == 1 && !day.isAfter(today))
            (column: column, month: day.month),
    ];
  }
}
