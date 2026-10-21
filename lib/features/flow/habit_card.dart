import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/habit_icons.dart';
import '../../domain/day.dart';
import '../../domain/habit.dart';
import '../../domain/habit_rules.dart';
import 'today_controls.dart';
import 'week_strip.dart';

/// One habit in Today's Flow: title, streak, the last seven days and today's
/// controls (a one-tap toggle or a stepper for measurable habits).
class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.today,
    required this.onProgress,
    required this.onEdit,
    required this.onDelete,
  });

  final Habit habit;
  final Day today;
  final void Function(Day day, int count) onProgress;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.habitColor(habit.colorValue);
    final doneToday = habit.isCompletedOn(today);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: doneToday
              ? color.withValues(alpha: 0.35)
              : AppColors.cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                habit: habit,
                color: color,
                streak: HabitRules.currentStreak(habit, today),
                onEdit: onEdit,
                onDelete: onDelete,
              ),
              const SizedBox(height: 7),
              WeekStrip(
                habit: habit,
                today: today,
                color: color,
                onProgress: onProgress,
              ),
              const SizedBox(height: 7),
              TodayControls(
                habit: habit,
                today: today,
                color: color,
                onProgress: onProgress,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.habit,
    required this.color,
    required this.streak,
    required this.onEdit,
    required this.onDelete,
  });

  final Habit habit;
  final Color color;
  final int streak;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final subtitle = habit.type == HabitType.measurable
        ? 'Target: ${habit.targetPerDay} ${habit.unit} • ${habit.category}'
        : habit.category;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
              width: 0.9,
            ),
          ),
          child: Icon(HabitIcons.of(habit.iconKey), size: 17, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                habit.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        Semantics(
          label: 'Streak: $streak days',
          excludeSemantics: true,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.streakAmber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
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
                  size: 12,
                  color: AppColors.streakAmber,
                ),
                const SizedBox(width: 2),
                Text(
                  '${streak}d',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.streakAmber,
                  ),
                ),
              ],
            ),
          ),
        ),
        PopupMenuButton<_MenuAction>(
          tooltip: 'Options for ${habit.title}',
          icon: const Icon(
            Icons.more_vert_rounded,
            size: 18,
            color: AppColors.textMuted,
          ),
          color: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.cardBorder),
          ),
          onSelected: (action) => switch (action) {
            _MenuAction.edit => onEdit(),
            _MenuAction.delete => onDelete(),
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: _MenuAction.edit,
              child: _MenuRow(
                Icons.edit_outlined,
                'Edit Habit',
                AppColors.textPrimary,
              ),
            ),
            PopupMenuItem(
              value: _MenuAction.delete,
              child: _MenuRow(
                Icons.delete_outline_rounded,
                'Delete',
                AppColors.danger,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

enum _MenuAction { edit, delete }

class _MenuRow extends StatelessWidget {
  const _MenuRow(this.icon, this.label, this.color);

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 13, color: color)),
      ],
    );
  }
}
