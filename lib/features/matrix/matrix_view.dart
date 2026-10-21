import 'package:flutter/material.dart';

import '../../core/feedback/haptics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/habit_icons.dart';
import '../../domain/day.dart';
import '../../domain/habit.dart';
import '../../domain/habit_stats.dart';
import 'matrix_layout.dart';
import 'month_summary_card.dart';

/// Spreadsheet-style view of the last seven days for every active habit, with
/// the month-to-date summary below.
class MatrixView extends StatefulWidget {
  const MatrixView({
    super.key,
    required this.habits,
    required this.today,
    required this.onProgress,
  });

  final List<Habit> habits;
  final Day today;
  final void Function(Habit habit, Day day, int count) onProgress;

  @override
  State<MatrixView> createState() => _MatrixViewState();
}

class _MatrixViewState extends State<MatrixView> {
  MatrixDensity _density = MatrixDensity.medium;

  // Recomputed only when the habits or the day change, not on density taps.
  late List<Habit> _active;
  late MonthSummary _month;

  @override
  void initState() {
    super.initState();
    _recompute();
  }

  @override
  void didUpdateWidget(MatrixView old) {
    super.didUpdateWidget(old);
    if (!identical(old.habits, widget.habits) || old.today != widget.today) {
      _recompute();
    }
  }

  void _recompute() {
    _active = HabitStats.active(widget.habits);
    _month = HabitStats.month(_active, widget.today);
  }

  @override
  Widget build(BuildContext context) {
    final days = [
      for (var offset = 6; offset >= 0; offset--) widget.today.addDays(-offset),
    ];
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return ListView(
      key: const PageStorageKey('matrix'),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.p16,
        6,
        AppSpacing.p16,
        AppSpacing.fabClearance + bottomInset,
      ),
      children: [
        _toolbar(),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final layout = MatrixLayout(constraints.maxWidth, _density);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DayHeaderRow(
                    days: days,
                    today: widget.today,
                    layout: layout,
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, color: AppColors.cardBorder),
                  const SizedBox(height: 4),
                  if (_active.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text('No habits yet', style: AppText.body),
                      ),
                    )
                  else
                    RepaintBoundary(
                      child: Column(
                        children: [
                          for (final habit in _active)
                            _HabitRow(
                              key: ValueKey(habit.id),
                              habit: habit,
                              days: days,
                              today: widget.today,
                              layout: layout,
                              density: _density,
                              onProgress: widget.onProgress,
                            ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.p16),
        MonthSummaryCard(summary: _month, today: widget.today),
      ],
    );
  }

  Widget _toolbar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Expanded(
            child: Text('7-DAY PERFORMANCE', style: AppText.sectionLabel),
          ),
          for (final density in MatrixDensity.values)
            Semantics(
              button: true,
              selected: density == _density,
              label: 'Row size ${density.label}',
              excludeSemantics: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Haptics.selection();
                  setState(() => _density = density);
                },
                child: SizedBox(
                  width: 36,
                  height: 40,
                  child: Center(
                    child: _DensityChip(
                      density: density,
                      selected: density == _density,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DensityChip extends StatelessWidget {
  const _DensityChip({required this.density, required this.selected});

  final MatrixDensity density;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.22)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: selected ? AppColors.primary : Colors.transparent,
          width: 1.1,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        density.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          color: selected ? AppColors.primary : AppColors.textMuted,
        ),
      ),
    );
  }
}

class _DayHeaderRow extends StatelessWidget {
  const _DayHeaderRow({
    required this.days,
    required this.today,
    required this.layout,
  });

  final List<Day> days;
  final Day today;
  final MatrixLayout layout;

  static const _letters = ['', 'M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: layout.titleWidth,
          child: const Text(
            'HABIT / RITUAL',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: AppColors.textMuted,
            ),
          ),
        ),
        for (final day in days)
          SizedBox(
            width: layout.dayWidth,
            child: Column(
              children: [
                Text(
                  _letters[day.weekday],
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: day == today
                        ? AppColors.primary
                        : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: day == today
                        ? FontWeight.w900
                        : FontWeight.w600,
                    color: day == today
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _HabitRow extends StatelessWidget {
  const _HabitRow({
    super.key,
    required this.habit,
    required this.days,
    required this.today,
    required this.layout,
    required this.density,
    required this.onProgress,
  });

  final Habit habit;
  final List<Day> days;
  final Day today;
  final MatrixLayout layout;
  final MatrixDensity density;
  final void Function(Habit habit, Day day, int count) onProgress;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.habitColor(habit.colorValue);
    return SizedBox(
      height: density.rowHeight,
      child: Row(
        children: [
          SizedBox(
            width: layout.titleWidth,
            child: Tooltip(
              message: habit.title,
              child: Row(
                children: [
                  Icon(
                    HabitIcons.of(habit.iconKey),
                    size: density.iconSize,
                    color: color,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      habit.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: density.fontSize,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          for (final day in days) _cell(day, color),
        ],
      ),
    );
  }

  Widget _cell(Day day, Color color) {
    final isToday = day == today;
    final done = habit.isCompletedOn(day);
    final scheduled = habit.isScheduledOn(day);

    final Color border;
    if (done) {
      border = isToday ? color : color.withValues(alpha: 0.6);
    } else if (!scheduled) {
      border = AppColors.cellRestBorder;
    } else {
      border = isToday ? color : AppColors.cellBorder;
    }
    final fill = done
        ? color.withValues(alpha: 0.35)
        : (scheduled ? AppColors.cellEmpty : Colors.transparent);
    final box = layout.boxSize;
    final state = done ? 'done' : (scheduled ? 'not done' : 'rest day');

    return Semantics(
      button: true,
      label: '${habit.title}, ${day.day}/${day.month}, $state',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Haptics.light();
          onProgress(habit, day, done ? 0 : habit.targetPerDay);
        },
        child: SizedBox(
          width: layout.dayWidth,
          height: density.rowHeight,
          child: Center(
            child: Container(
              width: box,
              height: box,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: border,
                  width: isToday && scheduled ? 1.4 : 1.0,
                ),
              ),
              child: done
                  ? Icon(Icons.check_rounded, size: box * 0.58, color: color)
                  // A short dash marks a rest day so it never reads as a missed day.
                  : (scheduled
                        ? null
                        : Center(
                            child: Container(
                              width: box * 0.3,
                              height: 1.5,
                              color: AppColors.cellRestBorder,
                            ),
                          )),
            ),
          ),
        ),
      ),
    );
  }
}
