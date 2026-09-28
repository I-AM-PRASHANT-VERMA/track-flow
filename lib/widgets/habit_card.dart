import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../models/habit_item.dart';

// High-density habit card with inline 7-day history matrix and zero-modal stepper
class HabitCard extends StatelessWidget {
  final HabitItem habit;
  final ValueChanged<int> onUpdateTodayProgress;
  final void Function(DateTime date, int count) onToggleHistoricalDate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onUpdateTodayProgress,
    required this.onToggleHistoricalDate,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final habitColor = AppColors.getHabitColor(habit.colorValue);
    final isDoneToday = habit.isCompletedToday;
    final todayProgress = habit.progressToday;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDoneToday
              ? habitColor.withValues(alpha: isDark ? 0.45 : 0.6)
              : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
          width: isDoneToday ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          if (isDoneToday)
            BoxShadow(
              color: habitColor.withValues(alpha: isDark ? 0.12 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onLongPress: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Row: Icon, Title, Category Tag, Streak pill, and Context Menu
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon Box
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: habitColor.withValues(alpha: isDark ? 0.18 : 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: habitColor.withValues(alpha: 0.35),
                          width: 0.8,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          habit.iconCode,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Title & Target / Category
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.textDarkPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                habit.type == HabitType.measurable
                                    ? 'Target: ${habit.targetPerDay} ${habit.unit}'
                                    : habit.category,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: habitColor,
                                ),
                              ),
                              if (habit.type == HabitType.measurable) ...[
                                Text(
                                  ' • ${habit.category}',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: isDark ? AppColors.textMuted : Colors.black45,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Streak Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1B2333) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.streakOrange.withValues(alpha: 0.35),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 10)),
                          const SizedBox(width: 3),
                          Text(
                            '${habit.currentStreak}d',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.streakOrange : const Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Options menu
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, size: 16, color: AppColors.textMuted),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 15),
                              SizedBox(width: 8),
                              Text('Edit Habit', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, size: 15, color: Colors.redAccent),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (val) {
                        if (val == 'edit') onEdit();
                        if (val == 'delete') onDelete();
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Inline 7-Day History Matrix
                _build7DayMatrix(context, habitColor),

                const SizedBox(height: 10),

                // Action Area: Stepper for Measurable OR 1-Tap Toggle for Boolean
                if (habit.type == HabitType.measurable) ...[
                  _buildMeasurableStepper(context, habitColor, todayProgress),
                ] else ...[
                  _buildBooleanToggle(context, habitColor, isDoneToday),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Renders the 7-day mini matrix across Mon to Sun
  Widget _build7DayMatrix(BuildContext context, Color habitColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = HabitItem.last7Days;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF090E17) : const Color(0xFFF1F5F9),
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
            '7-DAY',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: isDark ? AppColors.textMuted : Colors.black45,
            ),
          ),
          Row(
            children: days.map((date) {
              final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
              final isDone = habit.isCompletedOn(date);
              final isScheduled = habit.scheduledDays.contains(date.weekday);
              final dayChar = DateFormat('E').format(date).substring(0, 1);

              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (habit.type == HabitType.boolean) {
                    onToggleHistoricalDate(date, isDone ? 0 : 1);
                  } else {
                    onToggleHistoricalDate(date, isDone ? 0 : habit.targetPerDay);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: !isScheduled
                        ? Colors.transparent
                        : (isDone
                            ? habitColor
                            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0))),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isToday
                          ? habitColor
                          : (!isScheduled
                              ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1))
                              : Colors.transparent),
                      width: isToday ? 1.5 : 0.8,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      dayChar,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: !isScheduled
                            ? (isDark ? Colors.white24 : Colors.black26)
                            : (isDone
                                ? Colors.black
                                : (isDark ? AppColors.textMuted : Colors.black54)),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Stepper for Measurable Habits (Drink water, read pages, focus minutes)
  Widget _buildMeasurableStepper(BuildContext context, Color habitColor, int current) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final target = habit.targetPerDay;
    final progressRatio = (current / target).clamp(0.0, 1.0);
    final isDone = current >= target;

    // Step size based on target size
    final step = target > 50 ? 15 : (target > 10 ? 5 : 1);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text.rich(
              TextSpan(
                text: 'Today: ',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textMuted : Colors.black54,
                ),
                children: [
                  TextSpan(
                    text: '$current',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: isDone ? habitColor : (isDark ? Colors.white : AppColors.textDarkPrimary),
                    ),
                  ),
                  TextSpan(text: ' / $target ${habit.unit}'),
                ],
              ),
            ),
            Row(
              children: [
                _buildStepperButton(
                  context,
                  label: '-$step',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    final next = (current - step).clamp(0, target * 3);
                    onUpdateTodayProgress(next);
                  },
                ),
                const SizedBox(width: 4),
                _buildStepperButton(
                  context,
                  label: '+$step',
                  isAccent: true,
                  accentColor: habitColor,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    final next = current + step;
                    onUpdateTodayProgress(next);
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progressRatio,
            minHeight: 4,
            backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(habitColor),
          ),
        ),
      ],
    );
  }

  Widget _buildStepperButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    bool isAccent = false,
    Color? accentColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isAccent
                ? (accentColor ?? AppColors.primary)
                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: isAccent ? Colors.black : (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  // 1-Tap Toggle Button for Boolean Habits
  Widget _buildBooleanToggle(BuildContext context, Color habitColor, bool isDone) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        if (isDone) {
          HapticFeedback.lightImpact();
          onUpdateTodayProgress(0);
        } else {
          HapticFeedback.heavyImpact();
          onUpdateTodayProgress(habit.targetPerDay);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isDone
              ? habitColor
              : (isDark ? const Color(0xFF131D2E) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDone
                ? habitColor
                : (isDark ? AppColors.darkCardBorder : const Color(0xFFCBD5E1)),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              size: 15,
              color: isDone ? Colors.black : (isDark ? AppColors.textMuted : Colors.black45),
            ),
            const SizedBox(width: 6),
            Text(
              isDone ? 'Completed Today' : 'Tap to Mark Done',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: isDone ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
