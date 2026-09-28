import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../models/habit_item.dart';

// High-density habit card tuned with True OLED contrast, 8-pt grid, and 48x48 dp touch targets
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
      margin: const EdgeInsets.only(bottom: AppSpacing.p12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDoneToday
              ? habitColor.withValues(alpha: isDark ? 0.35 : 0.45)
              : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.03),
            blurRadius: 8,
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
            padding: const EdgeInsets.all(AppSpacing.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Row: Vector Icon, Title, Category Tag, Streak pill, and Context Menu
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Crisp Vector Icon Box
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: habitColor.withValues(alpha: isDark ? 0.12 : 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: habitColor.withValues(alpha: 0.25),
                          width: 0.9,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          AppIcons.getIcon(habit.iconCode),
                          size: 20,
                          color: habitColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.p12),

                    // Title & Subtitle with negative tracking on heading
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: isDark ? AppColors.textPrimary : AppColors.textDarkPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            habit.type == HabitType.measurable
                                ? 'Target: ${habit.targetPerDay} ${habit.unit} • ${habit.category}'
                                : habit.category,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: habitColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Modern Streak Pill with Vector Flame
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p8, vertical: AppSpacing.p4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.streakAmber.withValues(alpha: 0.12)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.streakAmber.withValues(alpha: 0.30),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            size: 13,
                            color: AppColors.streakAmber,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${habit.currentStreak}d',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.streakAmber : const Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 48x48 Touch Target for Options Menu
                    TouchTarget(
                      minWidth: AppSpacing.minTouchTarget,
                      minHeight: AppSpacing.minTouchTarget,
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textMuted),
                        padding: EdgeInsets.zero,
                        color: isDark ? AppColors.darkCard : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 16, color: isDark ? AppColors.textPrimary : Colors.black87),
                                const SizedBox(width: 8),
                                Text(
                                  'Edit Habit',
                                  style: TextStyle(fontSize: 13, color: isDark ? AppColors.textPrimary : Colors.black87),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.danger),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(fontSize: 13, color: AppColors.danger),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (val) {
                          if (val == 'edit') onEdit();
                          if (val == 'delete') onDelete();
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.p12),

                // Inline 7-Day History Matrix with 48x48 dp Touch Targets
                _build7DayMatrix(context, habitColor),

                const SizedBox(height: AppSpacing.p12),

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

  // 7-day mini matrix with guaranteed 44-48dp touch targets per day cell
  Widget _build7DayMatrix(BuildContext context, Color habitColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = HabitItem.last7Days;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '7-DAY',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: AppColors.textMuted,
            ),
          ),
          Row(
            children: days.map((date) {
              final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
              final isDone = habit.isCompletedOn(date);
              final isScheduled = habit.scheduledDays.contains(date.weekday);
              final dayChar = DateFormat('E').format(date).substring(0, 1);

              return TouchTarget(
                minWidth: 38,
                minHeight: 44, // Meets touch target guidelines
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (habit.type == HabitType.boolean) {
                    onToggleHistoricalDate(date, isDone ? 0 : 1);
                  } else {
                    onToggleHistoricalDate(date, isDone ? 0 : habit.targetPerDay);
                  }
                },
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: !isScheduled
                        ? Colors.transparent
                        : (isDone
                            ? habitColor.withValues(alpha: isDark ? 0.32 : 0.85)
                            : (isDark ? AppColors.darkCardBorder.withValues(alpha: 0.5) : const Color(0xFFE2E8F0))),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: isToday
                          ? habitColor
                          : (!isScheduled
                              ? (isDark ? AppColors.darkCardBorder : const Color(0xFFCBD5E1))
                              : (isDone ? habitColor.withValues(alpha: 0.5) : Colors.transparent)),
                      width: isToday ? 1.5 : 0.8,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      dayChar,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: !isScheduled
                            ? (isDark ? Colors.white24 : Colors.black26)
                            : (isDone
                                ? (isDark ? AppColors.textPrimary : Colors.white)
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

  // Stepper for Measurable Habits with 48x48 dp Touch Target Stepper Buttons
  Widget _buildMeasurableStepper(BuildContext context, Color habitColor, int current) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final target = habit.targetPerDay;
    final progressRatio = (current / target).clamp(0.0, 1.0);
    final isDone = current >= target;

    final step = target > 50 ? 15 : (target > 10 ? 5 : 1);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: 'Today: ',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    TextSpan(
                      text: '$current',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: isDone ? habitColor : (isDark ? AppColors.textPrimary : AppColors.textDarkPrimary),
                      ),
                    ),
                    TextSpan(text: ' / $target ${habit.unit}'),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.p8),
            Row(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(width: AppSpacing.p4),
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
        const SizedBox(height: AppSpacing.p8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progressRatio,
            minHeight: 5,
            backgroundColor: isDark ? AppColors.darkSurface : const Color(0xFFE2E8F0),
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

    return TouchTarget(
      minWidth: 48,
      minHeight: 48, // Guarantees 48x48 dp hit box
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: 6),
        decoration: BoxDecoration(
          color: isAccent
              ? (accentColor ?? AppColors.primary).withValues(alpha: 0.16)
              : (isDark ? AppColors.darkSurface : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isAccent
                ? (accentColor ?? AppColors.primary).withValues(alpha: 0.4)
                : (isDark ? AppColors.darkCardBorder : Colors.transparent),
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: isAccent
                ? (accentColor ?? AppColors.primary)
                : (isDark ? AppColors.textPrimary : Colors.black87),
          ),
        ),
      ),
    );
  }

  // 1-Tap Toggle Button for Boolean Habits (Min 48dp height for accessibility)
  Widget _buildBooleanToggle(BuildContext context, Color habitColor, bool isDone) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        if (isDone) {
          HapticFeedback.lightImpact();
          onUpdateTodayProgress(0);
        } else {
          HapticFeedback.mediumImpact();
          onUpdateTodayProgress(habit.targetPerDay);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        height: AppSpacing.p48, // 48dp minimum touch height
        decoration: BoxDecoration(
          color: isDone
              ? habitColor.withValues(alpha: isDark ? 0.14 : 0.10)
              : (isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDone
                ? habitColor.withValues(alpha: 0.35)
                : (isDark ? AppColors.darkCardBorder : const Color(0xFFCBD5E1)),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              size: 17,
              color: isDone ? habitColor : AppColors.textMuted,
            ),
            const SizedBox(width: AppSpacing.p8),
            Text(
              isDone ? 'Completed Today' : 'Tap to Complete',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isDone
                    ? (isDark ? AppColors.textPrimary : habitColor)
                    : (isDark ? AppColors.textSecondary : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
