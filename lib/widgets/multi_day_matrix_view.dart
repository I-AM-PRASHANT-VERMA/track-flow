import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../models/habit_item.dart';

// Spreadsheet-like dense weekly matrix view showing all habits across Mon through Sun with Radix colors
class MultiDayMatrixView extends StatelessWidget {
  final List<HabitItem> habits;
  final void Function(HabitItem habit, DateTime date, int count) onToggleCell;

  const MultiDayMatrixView({
    super.key,
    required this.habits,
    required this.onToggleCell,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = HabitItem.last7Days;
    final activeHabits = habits.where((h) => !h.isArchived).toList();
    final navInset = MediaQuery.of(context).viewPadding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 96 + navInset),
      child: Container(
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
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: Habit title and 7 days
                Row(
                  children: [
                    const SizedBox(
                      width: 155,
                      child: Text(
                        'HABIT / RITUAL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    ...days.map((dt) {
                      final isToday = dt.year == today.year && dt.month == today.month && dt.day == today.day;
                      final dayName = DateFormat('E').format(dt);
                      final dayNum = DateFormat('d').format(dt);

                      return Container(
                        width: 44,
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Text(
                              dayName.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: isToday ? AppColors.primary : AppColors.textMuted,
                              ),
                            ),
                            Text(
                              dayNum,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                                color: isToday ? AppColors.primary : (isDark ? AppColors.textPrimary : Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 8),
                Container(
                  height: 1,
                  width: 155 + (44.0 * 7),
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                ),
                const SizedBox(height: 8),

                // Habit rows
                ...activeHabits.map((habit) {
                  final habitColor = AppColors.getHabitColor(habit.colorValue);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        // Habit Name & Vector Icon
                        SizedBox(
                          width: 155,
                          child: Row(
                            children: [
                              Icon(
                                AppIcons.getIcon(habit.iconCode),
                                size: 16,
                                color: habitColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  habit.title,
                                  style: TextStyle(
                                    fontSize: 12.5,
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

                        // 7 Check-in cells with soothing Radix state
                        ...days.map((dt) {
                          final isToday = dt.year == today.year && dt.month == today.month && dt.day == today.day;
                          final isDone = habit.isCompletedOn(dt);
                          final isScheduled = habit.scheduledDays.contains(dt.weekday);

                          return SizedBox(
                            width: 44,
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  final next = isDone ? 0 : habit.targetPerDay;
                                  onToggleCell(habit, dt, next);
                                },
                                child: Container(
                                  width: 27,
                                  height: 27,
                                  decoration: BoxDecoration(
                                    color: !isScheduled
                                        ? Colors.transparent
                                        : (isDone
                                            ? habitColor.withValues(alpha: isDark ? 0.28 : 0.85)
                                            : (isDark ? AppColors.darkSurface : const Color(0xFFE2E8F0))),
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(
                                      color: isToday
                                          ? habitColor
                                          : (!isScheduled
                                              ? (isDark ? AppColors.darkCardBorder : const Color(0xFFCBD5E1))
                                              : (isDone ? habitColor.withValues(alpha: 0.5) : Colors.transparent)),
                                      width: isToday ? 1.4 : 0.8,
                                    ),
                                  ),
                                  child: isDone
                                      ? Center(
                                          child: Icon(
                                            Icons.check_rounded,
                                            size: 14,
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
          ),
        ),
      ),
    );
  }
}
