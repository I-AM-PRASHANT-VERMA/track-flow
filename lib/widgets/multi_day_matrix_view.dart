import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../models/habit_item.dart';

// Spreadsheet-like dense weekly matrix view showing all habits across Mon through Sun
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                    SizedBox(
                      width: 150,
                      child: Text(
                        'HABIT / RITUAL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: isDark ? AppColors.textMuted : Colors.black54,
                        ),
                      ),
                    ),
                    ...days.map((dt) {
                      final isToday = dt.year == today.year && dt.month == today.month && dt.day == today.day;
                      final dayName = DateFormat('E').format(dt);
                      final dayNum = DateFormat('d').format(dt);

                      return Container(
                        width: 42,
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Text(
                              dayName.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: isToday ? AppColors.primary : (isDark ? AppColors.textMuted : Colors.black54),
                              ),
                            ),
                            Text(
                              dayNum,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                                color: isToday ? AppColors.primary : (isDark ? Colors.white : Colors.black87),
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
                  width: 150 + (42.0 * 7),
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
                        // Habit Name & Icon
                        SizedBox(
                          width: 150,
                          child: Row(
                            children: [
                              Text(habit.iconCode, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  habit.title,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : AppColors.textDarkPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 7 Check-in cells
                        ...days.map((dt) {
                          final isToday = dt.year == today.year && dt.month == today.month && dt.day == today.day;
                          final isDone = habit.isCompletedOn(dt);
                          final isScheduled = habit.scheduledDays.contains(dt.weekday);

                          return SizedBox(
                            width: 42,
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  final next = isDone ? 0 : habit.targetPerDay;
                                  onToggleCell(habit, dt, next);
                                },
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: !isScheduled
                                        ? Colors.transparent
                                        : (isDone
                                            ? habitColor
                                            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0))),
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(
                                      color: isToday
                                          ? habitColor
                                          : (!isScheduled
                                              ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1))
                                              : Colors.transparent),
                                      width: isToday ? 1.5 : 0.8,
                                    ),
                                  ),
                                  child: isDone
                                      ? const Center(
                                          child: Icon(Icons.check_rounded, size: 14, color: Colors.black),
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
