import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/day.dart';
import 'heatmap_cells.dart';
import 'heatmap_grid.dart';

/// Draws precomputed [cells]; no habit logic runs while painting.
class HeatmapPainter extends CustomPainter {
  HeatmapPainter({
    required this.grid,
    required this.cells,
    required this.accent,
    required this.selected,
  });

  final HeatmapGrid grid;
  final List<HeatCell> cells;
  final Color accent;
  final Day? selected;

  static const _radius = Radius.circular(2.5);
  static const _monthNames = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];

  // Text layout is the expensive part of painting; month labels never change,
  // so they are laid out once for the life of the app.
  static final List<TextPainter> _monthLabels = [
    for (final name in _monthNames)
      TextPainter(
        text: TextSpan(
          text: name,
          style: const TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w800,
            color: AppColors.textMuted,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(),
  ];

  static final Paint _nonePaint = Paint()..color = AppColors.cellNone;
  static final Paint _missedPaint = Paint()..color = AppColors.cellMissed;
  static final Paint _restPaint = Paint()
    ..color = AppColors.cellRestBorder
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  static final Paint _todayPaint = Paint()
    ..color = AppColors.textMuted
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  static final Paint _selectedPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4;

  @override
  void paint(Canvas canvas, Size size) {
    for (final start in grid.monthStarts()) {
      _monthLabels[start.month - 1].paint(
        canvas,
        Offset(start.column * HeatmapGrid.stride, 0),
      );
    }

    final donePaint = Paint();
    var index = 0;
    for (var column = 0; column < HeatmapGrid.columns; column++) {
      for (var row = 0; row < HeatmapGrid.rows; row++) {
        final cell = cells[index++];
        if (cell.kind == HeatKind.future) continue;

        final rect = RRect.fromRectAndRadius(grid.rectAt(column, row), _radius);
        switch (cell.kind) {
          case HeatKind.none:
            canvas.drawRRect(rect, _nonePaint);
          case HeatKind.rest:
            canvas.drawRRect(rect.deflate(0.5), _restPaint);
          case HeatKind.missed:
            canvas.drawRRect(rect, _missedPaint);
          case HeatKind.done:
            donePaint.color = accent.withValues(
              alpha: 0.25 + cell.intensity * 0.70,
            );
            canvas.drawRRect(rect, donePaint);
          case HeatKind.future:
            break;
        }

        final day = grid.dayAt(column, row);
        if (day == selected) {
          canvas.drawRRect(rect.inflate(0.5), _selectedPaint);
        } else if (day == grid.today) {
          canvas.drawRRect(rect.inflate(0.5), _todayPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(HeatmapPainter old) =>
      !identical(old.cells, cells) ||
      old.selected != selected ||
      old.accent != accent ||
      old.grid.today != grid.today;
}
