import 'package:flutter/material.dart';

import '../../core/feedback/haptics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../domain/day.dart';
import '../../domain/habit.dart';

/// Today's input: a one-tap toggle for yes/no habits, a stepper for measurable ones.
class TodayControls extends StatelessWidget {
  const TodayControls({
    super.key,
    required this.habit,
    required this.today,
    required this.color,
    required this.onProgress,
  });

  final Habit habit;
  final Day today;
  final Color color;
  final void Function(Day day, int count) onProgress;

  @override
  Widget build(BuildContext context) {
    return habit.type == HabitType.measurable
        ? _Stepper(
            habit: habit,
            today: today,
            color: color,
            onProgress: onProgress,
          )
        : _Toggle(
            habit: habit,
            today: today,
            color: color,
            onProgress: onProgress,
          );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.habit,
    required this.today,
    required this.color,
    required this.onProgress,
  });

  final Habit habit;
  final Day today;
  final Color color;
  final void Function(Day day, int count) onProgress;

  @override
  Widget build(BuildContext context) {
    final done = habit.isCompletedOn(today);
    final label = done
        ? 'Completed Today'
        : (habit.isScheduledOn(today)
              ? 'Tap to Complete'
              : 'Rest day · Tap to log anyway');

    return Semantics(
      button: true,
      toggled: done,
      label: '${habit.title}: $label',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () {
          done ? Haptics.light() : Haptics.medium();
          onProgress(today, done ? 0 : habit.targetPerDay);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: 44,
          decoration: BoxDecoration(
            color: done ? color.withValues(alpha: 0.14) : AppColors.surface,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: done
                  ? color.withValues(alpha: 0.35)
                  : AppColors.cardBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                done
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 16,
                color: done ? color : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: done
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.habit,
    required this.today,
    required this.color,
    required this.onProgress,
  });

  final Habit habit;
  final Day today;
  final Color color;
  final void Function(Day day, int count) onProgress;

  /// Bigger steps for bigger targets (90 minutes moves in 15s, 20 pages in 5s).
  int get _step =>
      habit.targetPerDay > 50 ? 15 : (habit.targetPerDay > 10 ? 5 : 1);

  @override
  Widget build(BuildContext context) {
    final current = habit.progressOn(today);
    final target = habit.targetPerDay;
    final done = current >= target;
    final step = _step;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: 'Today: ',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    TextSpan(
                      text: '$current',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: done ? color : AppColors.textPrimary,
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
            _StepButton(
              label: '-$step',
              semanticLabel: 'Decrease ${habit.title} by $step',
              onTap: current == 0
                  ? null
                  : () {
                      Haptics.light();
                      onProgress(
                        today,
                        current - step < 0 ? 0 : current - step,
                      );
                    },
            ),
            const SizedBox(width: AppSpacing.p4),
            _StepButton(
              label: '+$step',
              semanticLabel: 'Increase ${habit.title} by $step',
              accent: color,
              onTap: () {
                Haptics.medium();
                onProgress(today, current + step);
              },
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: (current / target).clamp(0.0, 1.0),
            minHeight: 4,
            backgroundColor: AppColors.surface,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.label,
    required this.semanticLabel,
    required this.onTap,
    this.accent,
  });

  final String label;
  final String semanticLabel;
  final VoidCallback? onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final tint = accent;
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        // 44 x 44 hit area around the compact visual button.
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: tint == null
                    ? AppColors.surface
                    : tint.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: tint == null
                      ? AppColors.cardBorder
                      : tint.withValues(alpha: 0.4),
                  width: 0.8,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: !enabled
                      ? AppColors.textFaint
                      : (tint ?? AppColors.textPrimary),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
