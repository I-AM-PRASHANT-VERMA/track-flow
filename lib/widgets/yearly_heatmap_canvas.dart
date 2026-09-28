import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../core/constants/app_colors.dart';
import '../models/habit_item.dart';

// High-performance 365-day contribution density canvas with Radix colors and vector icons
class YearlyHeatmapCanvas extends StatefulWidget {
  final List<HabitItem> habits;
  final HabitItem? selectedHabitFilter;
  final ValueChanged<HabitItem?> onFilterChanged;

  const YearlyHeatmapCanvas({
    super.key,
    required this.habits,
    required this.selectedHabitFilter,
    required this.onFilterChanged,
  });

  @override
  State<YearlyHeatmapCanvas> createState() => _YearlyHeatmapCanvasState();
}

class _YearlyHeatmapCanvasState extends State<YearlyHeatmapCanvas> {
  DateTime? _selectedDate;
  int _selectedCount = 0;
  int _selectedTotal = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeHabits = widget.habits.where((h) => !h.isArchived).toList();
    final navInset = MediaQuery.of(context).viewPadding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 96 + navInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter pills (All Habits or individual habit)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Overall Consistency',
                  icon: Icons.auto_awesome_rounded,
                  isSelected: widget.selectedHabitFilter == null,
                  onTap: () => widget.onFilterChanged(null),
                  color: AppColors.primary,
                ),
                ...activeHabits.map((h) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: _buildFilterChip(
                      label: h.title,
                      icon: AppIcons.getIcon(h.iconCode),
                      isSelected: widget.selectedHabitFilter?.id == h.id,
                      onTap: () => widget.onFilterChanged(h),
                      color: AppColors.getHabitColor(h.colorValue),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Heatmap Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '365-DAY CONTRIBUTION CANVAS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.selectedHabitFilter != null
                              ? widget.selectedHabitFilter!.title
                              : 'Daily completion across all rituals',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textPrimary : AppColors.textDarkPrimary,
                          ),
                        ),
                      ],
                    ),

                    // Legend Scale
                    Row(
                      children: [
                        const Text(
                          'Less',
                          style: TextStyle(fontSize: 9.5, color: AppColors.textMuted),
                        ),
                        const SizedBox(width: 4),
                        _buildLegendBox(isDark ? AppColors.darkSurface : const Color(0xFFE2E8F0)),
                        _buildLegendBox(AppColors.primary.withValues(alpha: 0.25)),
                        _buildLegendBox(AppColors.primary.withValues(alpha: 0.50)),
                        _buildLegendBox(AppColors.primary.withValues(alpha: 0.75)),
                        _buildLegendBox(AppColors.primary),
                        const SizedBox(width: 4),
                        const Text(
                          'More',
                          style: TextStyle(fontSize: 9.5, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Canvas Container (Horizontally Scrollable 53 weeks)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true, // Auto-scroll to current week on right
                  child: GestureDetector(
                    onTapUp: (details) => _handleCanvasTap(details.localPosition, activeHabits),
                    child: CustomPaint(
                      size: const Size(53 * 13.0, 16 + (7 * 13.0)),
                      painter: _HeatmapPainter(
                        habits: widget.habits,
                        selectedHabit: widget.selectedHabitFilter,
                        isDark: isDark,
                        selectedDate: _selectedDate,
                      ),
                    ),
                  ),
                ),

                // Inspector info row for tapped date
                if (_selectedDate != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('EEEE, d MMMM yyyy').format(_selectedDate!),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textPrimary : AppColors.textDarkPrimary,
                          ),
                        ),
                        Text(
                          '$_selectedCount of $_selectedTotal completed',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _selectedCount > 0 ? AppColors.primary : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleCanvasTap(Offset position, List<HabitItem> activeHabits) {
    const cellSize = 11.0;
    const cellGap = 2.0;
    const stride = cellSize + cellGap;

    final weekIdx = (position.dx / stride).floor();
    final dayIdx = ((position.dy - 16) / stride).floor();

    if (weekIdx >= 0 && weekIdx < 53 && dayIdx >= 0 && dayIdx < 7) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final daysAgo = ((52 - weekIdx) * 7) + (6 - dayIdx);
      final tappedDate = today.subtract(Duration(days: daysAgo));

      final scheduled = activeHabits.where((h) => h.scheduledDays.contains(tappedDate.weekday)).toList();
      final done = scheduled.where((h) => h.isCompletedOn(tappedDate)).length;

      setState(() {
        _selectedDate = tappedDate;
        _selectedCount = done;
        _selectedTotal = scheduled.length;
      });
    }
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: isDark ? 0.20 : 0.14)
              : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.5)
                : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
            width: isSelected ? 1.0 : 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? color : AppColors.textMuted,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? AppColors.textPrimary : color)
                    : (isDark ? AppColors.textMuted : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendBox(Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }
}

// Custom painter that maps past 365 days into a 53-column x 7-row matrix
class _HeatmapPainter extends CustomPainter {
  final List<HabitItem> habits;
  final HabitItem? selectedHabit;
  final bool isDark;
  final DateTime? selectedDate;

  _HeatmapPainter({
    required this.habits,
    required this.selectedHabit,
    required this.isDark,
    required this.selectedDate,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const cellSize = 11.0;
    const cellGap = 2.0;
    const stride = cellSize + cellGap;

    final emptyPaint = Paint()
      ..color = isDark ? AppColors.darkSurface : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final monthFormat = DateFormat('MMM');
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    var lastRenderedMonth = -1;

    for (var col = 0; col < 53; col++) {
      final weekDaysAgo = (52 - col) * 7;
      final weekStartDate = today.subtract(Duration(days: weekDaysAgo));

      if (weekStartDate.month != lastRenderedMonth && weekStartDate.day <= 14) {
        lastRenderedMonth = weekStartDate.month;
        textPainter.text = TextSpan(
          text: monthFormat.format(weekStartDate).toUpperCase(),
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textMuted : Colors.black45,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(col * stride, 0));
      }

      for (var row = 0; row < 7; row++) {
        final daysAgo = weekDaysAgo + (6 - row);
        final date = today.subtract(Duration(days: daysAgo));

        if (date.isAfter(today)) continue;

        final isSelected = selectedDate != null &&
            selectedDate!.year == date.year &&
            selectedDate!.month == date.month &&
            selectedDate!.day == date.day;

        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(col * stride, 16 + (row * stride), cellSize, cellSize),
          const Radius.circular(2.5),
        );

        Paint cellPaint;

        if (selectedHabit != null) {
          final isDone = selectedHabit!.isCompletedOn(date);
          final habitColor = AppColors.getHabitColor(selectedHabit!.colorValue);
          cellPaint = Paint()
            ..color = isDone ? habitColor.withValues(alpha: isDark ? 0.8 : 0.9) : emptyPaint.color
            ..style = PaintingStyle.fill;
        } else {
          final scheduled = habits.where((h) => h.scheduledDays.contains(date.weekday)).toList();
          if (scheduled.isEmpty) {
            cellPaint = emptyPaint;
          } else {
            final completedCount = scheduled.where((h) => h.isCompletedOn(date)).length;
            final ratio = completedCount / scheduled.length;

            if (ratio == 0) {
              cellPaint = emptyPaint;
            } else {
              final alpha = (0.25 + (ratio * 0.70)).clamp(0.0, 0.95);
              cellPaint = Paint()
                ..color = AppColors.primary.withValues(alpha: alpha)
                ..style = PaintingStyle.fill;
            }
          }
        }

        canvas.drawRRect(rect, cellPaint);

        if (isSelected) {
          final ringPaint = Paint()
            ..color = isDark ? Colors.white : Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2;
          canvas.drawRRect(rect, ringPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter oldDelegate) {
    return oldDelegate.habits != habits ||
        oldDelegate.selectedHabit != selectedHabit ||
        oldDelegate.isDark != isDark ||
        oldDelegate.selectedDate != selectedDate;
  }
}
