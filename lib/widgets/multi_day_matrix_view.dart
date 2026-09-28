import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../models/habit_item.dart';

// 3 display densities so every user gets their preferred readability level
enum MatrixDensity { compact, medium, comfortable }

extension _MatrixDensityValues on MatrixDensity {
  double get cellSize {
    switch (this) {
      case MatrixDensity.compact:
        return 32.0;
      case MatrixDensity.medium:
        return 40.0;
      case MatrixDensity.comfortable:
        return 48.0;
    }
  }

  double get habitLabelWidth {
    switch (this) {
      case MatrixDensity.compact:
        return 110.0;
      case MatrixDensity.medium:
        return 130.0;
      case MatrixDensity.comfortable:
        return 150.0;
    }
  }

  double get fontSize {
    switch (this) {
      case MatrixDensity.compact:
        return 11.0;
      case MatrixDensity.medium:
        return 12.5;
      case MatrixDensity.comfortable:
        return 13.5;
    }
  }

  double get iconSize {
    switch (this) {
      case MatrixDensity.compact:
        return 12.0;
      case MatrixDensity.medium:
        return 14.0;
      case MatrixDensity.comfortable:
        return 16.0;
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

// Weekly matrix showing all habits across 7 days with user-selectable density
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

    // Calculate if 7 days fit without horizontal scroll given current density
    final screenWidth = MediaQuery.of(context).size.width;
    final neededWidth = _density.habitLabelWidth + (_density.cellSize * 7) + 32; // 32 = card padding
    final fitsOnScreen = neededWidth <= screenWidth;

    return Column(
      children: [
        // Density size picker row
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.p16, AppSpacing.p12, AppSpacing.p16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'SIZE',
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(width: AppSpacing.p8),
              ...MatrixDensity.values.map((d) {
                final isSel = _density == d;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _density = d);
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.only(left: AppSpacing.p4),
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : (isDark ? AppColors.darkSurface : const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSel
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : Colors.transparent,
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        d.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isSel ? AppColors.primary : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.p8),

        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: AppSpacing.p16,
              right: AppSpacing.p16,
              bottom: 96 + navInset,
            ),
            child: Container(
              // Clip to card bounds so inner content never bleeds out
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                  width: 1,
                ),
              ),
              child: _buildMatrixContent(
                isDark: isDark,
                today: today,
                days: days,
                activeHabits: activeHabits,
                fitsOnScreen: fitsOnScreen,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMatrixContent({
    required bool isDark,
    required DateTime today,
    required List<DateTime> days,
    required List<HabitItem> activeHabits,
    required bool fitsOnScreen,
  }) {
    // Wraps in horizontal scroll only when compact mode still doesn't fit very long habit names
    Widget inner = Padding(
      padding: const EdgeInsets.all(AppSpacing.p12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              SizedBox(
                width: _density.habitLabelWidth,
                child: Text(
                  'HABIT',
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              ...days.map((dt) {
                final isToday = dt.year == today.year &&
                    dt.month == today.month &&
                    dt.day == today.day;
                return SizedBox(
                  width: _density.cellSize,
                  child: Column(
                    children: [
                      Text(
                        DateFormat('E').format(dt).substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: isToday ? AppColors.primary : AppColors.textMuted,
                        ),
                      ),
                      Text(
                        DateFormat('d').format(dt),
                        style: TextStyle(
                          fontSize: 10,
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

          const SizedBox(height: AppSpacing.p8),
          Divider(height: 1, color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
          const SizedBox(height: AppSpacing.p8),

          // Habit rows
          ...activeHabits.map((habit) {
            final habitColor = AppColors.getHabitColor(habit.colorValue);
            final rowSpacing = _density == MatrixDensity.compact ? 4.0 : 6.0;

            return Padding(
              padding: EdgeInsets.symmetric(vertical: rowSpacing),
              child: Row(
                children: [
                  SizedBox(
                    width: _density.habitLabelWidth,
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
                              color: isDark ? AppColors.textPrimary : AppColors.textDarkPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...days.map((dt) {
                    final isToday = dt.year == today.year &&
                        dt.month == today.month &&
                        dt.day == today.day;
                    final isDone = habit.isCompletedOn(dt);
                    final isScheduled = habit.scheduledDays.contains(dt.weekday);
                    final checkSize = (_density.cellSize * 0.6).clamp(18.0, 36.0);

                    return SizedBox(
                      width: _density.cellSize,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            final next = isDone ? 0 : habit.targetPerDay;
                            widget.onToggleCell(habit, dt, next);
                          },
                          child: Container(
                            width: checkSize,
                            height: checkSize,
                            decoration: BoxDecoration(
                              color: !isScheduled
                                  ? Colors.transparent
                                  : (isDone
                                      ? habitColor.withValues(alpha: isDark ? 0.30 : 0.85)
                                      : (isDark
                                          ? AppColors.darkSurface
                                          : const Color(0xFFEEF2F7))),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                // Always show a visible border so empty cells are clear
                                color: isToday
                                    ? habitColor
                                    : (!isScheduled
                                        ? (isDark
                                            ? AppColors.darkCardBorder.withValues(alpha: 0.5)
                                            : const Color(0xFFDDE3ED))
                                        : (isDone
                                            ? habitColor.withValues(alpha: 0.55)
                                            : (isDark
                                                ? AppColors.darkCardBorder
                                                : const Color(0xFFCBD5E1)))),
                                width: isToday ? 1.4 : 0.9,
                              ),
                            ),
                            child: isDone
                                ? Center(
                                    child: Icon(
                                      Icons.check_rounded,
                                      size: checkSize * 0.5,
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

    // Only wrap in horizontal scroller if content genuinely doesn't fit
    if (!fitsOnScreen) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: inner,
      );
    }
    return inner;
  }
}
