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
      padding: EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 130 + navInset),
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
                    child: RepaintBoundary(
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

          const SizedBox(height: 12),

          // Annual Insights & Consistency Analytics
          _buildAnnualInsights(context, activeHabits, isDark),
        ],
      ),
    );
  }

  // Annual consistency insights across past 365 days
  Widget _buildAnnualInsights(
    BuildContext context,
    List<HabitItem> activeHabits,
    bool isDark,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetHabits = widget.selectedHabitFilter != null
        ? [widget.selectedHabitFilter!]
        : activeHabits;

    int totalCompletions365 = 0;
    int totalScheduled365 = 0;
    int activeDaysCount = 0;
    final weekdayCompletions = List<int>.filled(7, 0);
    final weekdayScheduled = List<int>.filled(7, 0);

    for (var i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      int dayCompleted = 0;
      final weekdayIdx = date.weekday - 1;

      for (final habit in targetHabits) {
        if (habit.scheduledDays.contains(date.weekday)) {
          totalScheduled365++;
          weekdayScheduled[weekdayIdx]++;
          if (habit.isCompletedOn(date)) {
            dayCompleted++;
            totalCompletions365++;
            weekdayCompletions[weekdayIdx]++;
          }
        }
      }

      if (dayCompleted > 0) {
        activeDaysCount++;
      }
    }

    final double annualRate = totalScheduled365 > 0 ? (totalCompletions365 / totalScheduled365) : 0.0;
    final int annualPercent = (annualRate * 100).round();

    // Find highest performing weekday
    int bestWeekdayIdx = 0;
    double bestWeekdayRate = 0.0;
    const weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (var d = 0; d < 7; d++) {
      if (weekdayScheduled[d] > 0) {
        final rate = weekdayCompletions[d] / weekdayScheduled[d];
        if (rate > bestWeekdayRate) {
          bestWeekdayRate = rate;
          bestWeekdayIdx = d;
        }
      }
    }
    final bestDayName = weekdayNames[bestWeekdayIdx];
    final int bestDayPercent = (bestWeekdayRate * 100).round();

    int maxStreak = 0;
    for (final h in targetHabits) {
      if (h.bestStreak > maxStreak) {
        maxStreak = h.bestStreak;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.bar_chart_rounded, size: 15, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'ANNUAL CONSISTENCY & IMPACT',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: isDark ? AppColors.textMuted : Colors.black54,
                    ),
                  ),
                ],
              ),
              Text(
                'PAST 365 DAYS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textMuted : Colors.black45,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0),
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$annualPercent%',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.textDarkPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Annual Rate',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textSecondary : Colors.black87,
                        ),
                      ),
                      Text(
                        '$totalCompletions365 / $totalScheduled365 completed',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.textMuted : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0),
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$activeDaysCount',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Active Days',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textSecondary : Colors.black87,
                        ),
                      ),
                      Text(
                        'Out of 365 calendar days',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.textMuted : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: annualRate.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: isDark ? const Color(0xFF1E1E22) : const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        bestDayName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Peak Day ($bestDayPercent%)',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textMuted : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$maxStreak d',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.streakAmber,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Best Streak',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textMuted : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${targetHabits.length}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimary : AppColors.textDarkPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.selectedHabitFilter != null ? 'Filtered' : 'Tracked Habits',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textMuted : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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

  static const _monthAbbr = ['', 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];

  @override
  void paint(Canvas canvas, Size size) {
    const cellSize = 11.0;
    const cellGap = 2.0;
    const stride = cellSize + cellGap;

    final emptyColor = isDark ? AppColors.darkSurface : const Color(0xFFE2E8F0);
    final emptyPaint = Paint()
      ..color = emptyColor
      ..style = PaintingStyle.fill;

    final cellPaint = Paint()..style = PaintingStyle.fill;
    final ringPaint = Paint()
      ..color = isDark ? Colors.white : Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    var lastRenderedMonth = -1;

    for (var col = 0; col < 53; col++) {
      final weekDaysAgo = (52 - col) * 7;
      final weekStartDate = today.subtract(Duration(days: weekDaysAgo));

      if (weekStartDate.month != lastRenderedMonth && weekStartDate.day <= 14) {
        lastRenderedMonth = weekStartDate.month;
        textPainter.text = TextSpan(
          text: _monthAbbr[weekStartDate.month],
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

        if (selectedHabit != null) {
          final isDone = selectedHabit!.isCompletedOn(date);
          if (isDone) {
            final habitColor = AppColors.getHabitColor(selectedHabit!.colorValue);
            cellPaint.color = habitColor.withValues(alpha: isDark ? 0.8 : 0.9);
            canvas.drawRRect(rect, cellPaint);
          } else {
            canvas.drawRRect(rect, emptyPaint);
          }
        } else {
          int scheduledCount = 0;
          int completedCount = 0;
          final weekday = date.weekday;
          final len = habits.length;

          for (var i = 0; i < len; i++) {
            final h = habits[i];
            if (h.scheduledDays.contains(weekday)) {
              scheduledCount++;
              if (h.isCompletedOn(date)) {
                completedCount++;
              }
            }
          }

          if (scheduledCount == 0 || completedCount == 0) {
            canvas.drawRRect(rect, emptyPaint);
          } else {
            final ratio = completedCount / scheduledCount;
            final alpha = (0.25 + (ratio * 0.70)).clamp(0.0, 0.95);
            cellPaint.color = AppColors.primary.withValues(alpha: alpha);
            canvas.drawRRect(rect, cellPaint);
          }
        }

        if (isSelected) {
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
