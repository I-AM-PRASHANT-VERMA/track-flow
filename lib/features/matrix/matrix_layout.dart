import 'dart:math' as math;

/// Row density the user can pick for the matrix (S / M / L).
enum MatrixDensity {
  compact(
    'S',
    rowHeight: 36,
    titleWidth: 105,
    fontSize: 11,
    iconSize: 13,
    boxSize: 20,
  ),
  medium(
    'M',
    rowHeight: 44,
    titleWidth: 115,
    fontSize: 12,
    iconSize: 15,
    boxSize: 24,
  ),
  comfortable(
    'L',
    rowHeight: 52,
    titleWidth: 125,
    fontSize: 13,
    iconSize: 17,
    boxSize: 28,
  );

  const MatrixDensity(
    this.label, {
    required this.rowHeight,
    required this.titleWidth,
    required this.fontSize,
    required this.iconSize,
    required this.boxSize,
  });

  final String label;
  final double rowHeight;
  final double titleWidth;
  final double fontSize;
  final double iconSize;
  final double boxSize;
}

/// Column geometry for one available width. The seven day columns always fit:
/// on narrow screens the name column gives up space first, then the boxes shrink.
final class MatrixLayout {
  factory MatrixLayout(double width, MatrixDensity density) {
    final titleWidth = (width * 0.36).clamp(72.0, density.titleWidth);
    final dayWidth = (width - titleWidth) / 7;
    final boxSize = math.min(density.boxSize, math.max(12.0, dayWidth - 4));
    return MatrixLayout._(titleWidth, dayWidth, boxSize);
  }

  const MatrixLayout._(this.titleWidth, this.dayWidth, this.boxSize);

  final double titleWidth;
  final double dayWidth;
  final double boxSize;
}
