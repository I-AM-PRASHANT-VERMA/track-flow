import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../core/constants/app_colors.dart';
import '../models/habit_item.dart';

// High-performance 365-day GitHub-style contribution density canvas
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
                  isSelected: widget.selectedHabitFilter == null,
                  onTap: () => widget.onFilterChanged(null),
                  color: AppColors.primary,
                ),
                ...activeHabits.map((h) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: _buildFilterChip(
                      label: '${h.iconCode} ${h.title}',
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
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
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
                        Text(
                          '365-DAY CONTRIBUTION CANVAS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: isDark ? AppColors.textMuted : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.selectedHabitFilter == null
                              ? 'Daily completion across all rituals'
                              : 'Consistency for ${widget.selectedHabitFilter!.title}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.textDarkPrimary,
                          ),
                        ),
                      ],
                    ),

                    // Legend (Less -> More)
                    Row(
                      children: [
                        Text(
                          'Less',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: isDark ? AppColors.textMuted : Colors.black45,
                          ),
                        ),
                        const SizedBox(width: 4),
                        _buildLegendBox(const Color(0xFF1E293B)),
                        _buildLegendBox(AppColors.primary.withValues(alpha: 0.25)),
                        _buildLegendBox(AppColors.primary.withValues(alpha: 0.50)),
                        _buildLegendBox(AppColors.primary.withValues(alpha: 0.75)),
                        _buildLegendBox(AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          'More',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: isDark ? AppColors.textMuted : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Canvas Grid with horizontal scrolling
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true, // Scroll to recent dates by default
                  child: GestureDetector(
                    onTapUp: (details) {
                      _handleCanvasTap(details.localPosition, activeHabits);
                    },
                    child: CustomPaint(
                      size: const Size(53 * 13.0, 7 * 13.0 + 20),
                      painter: _HeatmapPainter(
                        habits: activeHabits,
                        selectedHabit: widget.selectedHabitFilter,
                        isDark: isDark,
                        selectedDate: _selectedDate,
                      ),
                    ),
                  ),
                ),

                if (_selectedDate != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF090E17) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate!),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          '$_selectedCount of $_selectedTotal completed',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
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
              ? color.withValues(alpha: isDark ? 0.22 : 0.15)
              : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
            width: isSelected ? 1.2 : 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? (isDark ? Colors.white : color)
                : (isDark ? AppColors.textMuted : Colors.black54),
          ),
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
        borderRadius: BorderRadius.circular(2),
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
      ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final monthFormat = DateFormat('MMM');
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    var lastRenderedMonth = -1;

    for (var col = 0; col < 53; col++) {
      // Calculate date of the first day in this column
      final weekDaysAgo = (52 - col) * 7;
      final weekStartDate = today.subtract(Duration(days: weekDaysAgo));

      // Draw Month header label when month transitions
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

        // Skip future dates if any
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
            ..color = isDone ? habitColor : emptyPaint.color
            ..style = PaintingStyle.fill;
        } else {
          // Aggregate across all active habits
          final scheduled = habits.where((h) => h.scheduledDays.contains(date.weekday)).toList();
          if (scheduled.isEmpty) {
            cellPaint = emptyPaint;
          } else {
            final completedCount = scheduled.where((h) => h.isCompletedOn(date)).length;
            final ratio = completedCount / scheduled.length;

            if (ratio == 0) {
              cellPaint = emptyPaint;
            } else {
              final alpha = (0.25 + (ratio * 0.75)).clamp(0.0, 1.0);
              cellPaint = Paint()
                ..color = AppColors.primary.withValues(alpha: alpha)
                ..style = PaintingStyle.fill;
            }
          }
        }

        canvas.drawRRect(rect, cellPaint);

        if (isSelected) {
          final ringPaint = Paint()
            ..color = Colors.white
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
