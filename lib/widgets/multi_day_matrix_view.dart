import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../models/habit_item.dart';

// Display density levels adjusting row height and visual scale
enum MatrixDensity { compact, medium, comfortable }

extension _MatrixDensityValues on MatrixDensity {
  double get rowHeight {
    switch (this) {
      case MatrixDensity.compact:
        return 36.0;
      case MatrixDensity.medium:
        return 44.0;
      case MatrixDensity.comfortable:
        return 52.0;
    }
  }

  double get titleWidth {
    switch (this) {
      case MatrixDensity.compact:
        return 105.0;
      case MatrixDensity.medium:
        return 115.0;
      case MatrixDensity.comfortable:
        return 125.0;
    }
  }

  double get fontSize {
    switch (this) {
      case MatrixDensity.compact:
        return 11.0;
      case MatrixDensity.medium:
        return 12.0;
      case MatrixDensity.comfortable:
        return 13.0;
    }
  }

  double get iconSize {
    switch (this) {
      case MatrixDensity.compact:
        return 13.0;
      case MatrixDensity.medium:
        return 15.0;
      case MatrixDensity.comfortable:
        return 17.0;
    }
  }

  double get boxSize {
    switch (this) {
      case MatrixDensity.compact:
        return 20.0;
      case MatrixDensity.medium:
        return 24.0;
      case MatrixDensity.comfortable:
        return 28.0;
    }
  }

  String get label {
    switch (this) {
      case MatrixDensity.compact:
        return 'S';
      case MatrixDensity.medium:
        return 'M';
      case MatrixDensity.comfortable:
        return 'L';
    }
  }
}

// 7-Day matrix view that stretches cleanly to fit screen width with zero dead space
class MultiDayMatrixView extends StatefulWidget {
  final List<HabitItem> habits;
  final void Function(HabitItem habit, DateTime date, int count) onToggleCell;

  const MultiDayMatrixView({
    super.key,
    required this.habits,
    required this.onToggleCell,
  });

  @override
  State<MultiDayMatrixView> createState() => _MultiDayMatrixViewState();
}

class _MultiDayMatrixViewState extends State<MultiDayMatrixView> {
  MatrixDensity _density = MatrixDensity.medium;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = HabitItem.last7Days;
    final activeHabits = widget.habits.where((h) => !h.isArchived).toList();
    final navInset = MediaQuery.of(context).viewPadding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: AppSpacing.p16,
        right: AppSpacing.p16,
        top: AppSpacing.p12,
        bottom: 96 + navInset,
      ),
      child: Column(
        children: [
          // Top bar with density toggle
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.p8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '7-DAY PERFORMANCE',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: isDark ? AppColors.textMuted : Colors.black54,
                  ),
                ),
                Row(
                  children: MatrixDensity.values.map((d) {
                    final isSel = _density == d;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _density = d);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 26,
                        height: 26,
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          color: isSel
                              ? AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.14)
                              : (isDark ? AppColors.darkSurface : const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSel ? AppColors.primary : Colors.transparent,
                            width: 1.1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            d.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                              color: isSel
                                  ? AppColors.primary
                                  : (isDark ? AppColors.textMuted : Colors.black54),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Main Card Container fitting edge to edge
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                width: 1,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth;
                const innerPadding = 12.0;
                final availableWidth = cardWidth - (innerPadding * 2);

                final titleColWidth = _density.titleWidth;
                final remainingWidth = availableWidth - titleColWidth;
                final dayColWidth = (remainingWidth / 7.0).clamp(24.0, 60.0);

                return Padding(
                  padding: const EdgeInsets.all(innerPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          SizedBox(
                            width: titleColWidth,
                            child: Text(
                              'HABIT / RITUAL',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: isDark ? AppColors.textMuted : Colors.black54,
                              ),
                            ),
                          ),
                          ...days.map((dt) {
                            final isToday = dt.year == today.year &&
                                dt.month == today.month &&
                                dt.day == today.day;
                            return SizedBox(
                              width: dayColWidth,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    DateFormat('E').format(dt).substring(0, 1).toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: isToday
                                          ? AppColors.primary
                                          : (isDark ? AppColors.textMuted : Colors.black45),
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    DateFormat('d').format(dt),
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                                      color: isToday
                                          ? AppColors.primary
                                          : (isDark ? AppColors.textSecondary : Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),

                      const SizedBox(height: 8),
                      Divider(
                        height: 1,
                        color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                      ),
                      const SizedBox(height: 4),

                      // Habits Rows
                      if (activeHabits.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No habits scheduled',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textMuted : Colors.black45,
                              ),
                            ),
                          ),
                        )
                      else
                        ...activeHabits.map((habit) {
                          final habitColor = AppColors.getHabitColor(habit.colorValue);

                          return SizedBox(
                            height: _density.rowHeight,
                            child: Row(
                              children: [
                                // Title and icon
                                SizedBox(
                                  width: titleColWidth,
                                  child: Row(
                                    children: [
                                      Icon(
                                        AppIcons.getIcon(habit.iconCode),
                                        size: _density.iconSize,
                                        color: habitColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          habit.title,
                                          style: TextStyle(
                                            fontSize: _density.fontSize,
                                            fontWeight: FontWeight.w700,
                                            color: isDark
                                                ? AppColors.textPrimary
                                                : AppColors.textDarkPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // 7 Day cells
                                ...days.map((dt) {
                                  final isToday = dt.year == today.year &&
                                      dt.month == today.month &&
                                      dt.day == today.day;
                                  final isDone = habit.isCompletedOn(dt);
                                  final isScheduled = habit.scheduledDays.contains(dt.weekday);
                                  final box = _density.boxSize;

                                  // Clearly visible border even on empty/uncompleted cells
                                  final Color borderColor;
                                  if (isToday) {
                                    borderColor = habitColor;
                                  } else if (isDone) {
                                    borderColor = habitColor.withValues(alpha: 0.6);
                                  } else if (isScheduled) {
                                    borderColor = isDark
                                        ? const Color(0xFF333338)
                                        : const Color(0xFFCBD5E1);
                                  } else {
                                    borderColor = isDark
                                        ? const Color(0xFF222226)
                                        : const Color(0xFFE2E8F0);
                                  }

                                  final Color fillColor;
                                  if (!isScheduled) {
                                    fillColor = Colors.transparent;
                                  } else if (isDone) {
                                    fillColor = habitColor.withValues(alpha: isDark ? 0.35 : 0.85);
                                  } else {
                                    fillColor = isDark
                                        ? const Color(0xFF161619)
                                        : const Color(0xFFF1F5F9);
                                  }

                                  return SizedBox(
                                    width: dayColWidth,
                                    child: Center(
                                      child: GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          final next = isDone ? 0 : habit.targetPerDay;
                                          widget.onToggleCell(habit, dt, next);
                                        },
                                        behavior: HitTestBehavior.opaque,
                                        child: Container(
                                          width: box,
                                          height: box,
                                          decoration: BoxDecoration(
                                            color: fillColor,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: borderColor,
                                              width: isToday ? 1.4 : 1.0,
                                            ),
                                          ),
                                          child: isDone
                                              ? Center(
                                                  child: Icon(
                                                    Icons.check_rounded,
                                                    size: box * 0.58,
                                                    color: isDark ? habitColor : Colors.white,
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
