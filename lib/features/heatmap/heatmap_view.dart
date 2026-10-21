import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/habit_icons.dart';
import '../../core/widgets/section_card.dart';
import '../../domain/day.dart';
import '../../domain/habit.dart';
import '../../domain/habit_stats.dart';
import 'heatmap_cells.dart';
import 'heatmap_grid.dart';
import 'heatmap_painter.dart';
import 'year_summary_card.dart';

/// 365-day contribution canvas for all habits or one selected habit.
class HeatmapView extends StatefulWidget {
  const HeatmapView({super.key, required this.habits, required this.today});

  final List<Habit> habits;
  final Day today;

  @override
  State<HeatmapView> createState() => _HeatmapViewState();
}

class _HeatmapViewState extends State<HeatmapView> {
  /// Filter by id, not by object, so an edited habit keeps its filter and a
  /// deleted or archived one simply falls back to "all habits".
  String? _filterId;
  Day? _selected;

  late List<Habit> _active;
  late Habit? _filtered;
  late HeatmapGrid _grid;
  late List<HeatCell> _cells;
  late YearSummary _year;

  @override
  void initState() {
    super.initState();
    _recompute();
  }

  @override
  void didUpdateWidget(HeatmapView old) {
    super.didUpdateWidget(old);
    if (!identical(old.habits, widget.habits) || old.today != widget.today) _recompute();
  }

  void _recompute() {
    _active = HabitStats.active(widget.habits);
    _filtered = _active.where((h) => h.id == _filterId).firstOrNull;
    final shown = _filtered == null ? _active : [_filtered!];
    _grid = HeatmapGrid(widget.today);
    _cells = buildHeatCells(_grid, shown);
    _year = HabitStats.year(shown, widget.today);
  }

  void _setFilter(String? id) {
    setState(() {
      _filterId = id;
      _selected = null;
      _recompute();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final accent = filtered == null ? AppColors.primary : AppColors.habitColor(filtered.colorValue);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return ListView(
      key: const PageStorageKey('heatmap'),
      padding: EdgeInsets.fromLTRB(AppSpacing.p16, 6, AppSpacing.p16, AppSpacing.fabClearance + bottomInset),
      children: [
        _filters(),
        const SizedBox(height: AppSpacing.p12),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CanvasTitle(subtitle: filtered?.title ?? 'Daily completion across all habits', accent: accent),
              const SizedBox(height: AppSpacing.p16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true, // opens on the current week
                child: GestureDetector(
                  onTapUp: (details) {
                    final day = _grid.dayAtPosition(details.localPosition);
                    if (day != null) setState(() => _selected = day == _selected ? null : day);
                  },
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: HeatmapGrid.size,
                      painter: HeatmapPainter(grid: _grid, cells: _cells, accent: accent, selected: _selected),
                    ),
                  ),
                ),
              ),
              if (_selected case final day?) ...[
                const SizedBox(height: 14),
                _Inspector(day: day, text: _describe(day)),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.p12),
        YearSummaryCard(summary: _year, isFiltered: filtered != null),
      ],
    );
  }

  Widget _filters() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'Overall Consistency',
            icon: Icons.auto_awesome_rounded,
            color: AppColors.primary,
            selected: _filtered == null,
            onTap: () => _setFilter(null),
          ),
          for (final habit in _active) ...[
            const SizedBox(width: 6),
            _FilterChip(
              label: habit.title,
              icon: HabitIcons.of(habit.iconKey),
              color: AppColors.habitColor(habit.colorValue),
              selected: _filtered?.id == habit.id,
              onTap: () => _setFilter(habit.id),
            ),
          ],
        ],
      ),
    );
  }

  /// Inspector line for [day], counting the same habits as the cell colour.
  String _describe(Day day) {
    final habit = _filtered;
    if (habit == null) {
      final tally = HabitStats.onDay(_active, day);
      return tally.scheduled == 0 ? 'Rest day' : '${tally.completed} of ${tally.scheduled} done';
    }
    if (!habit.isScheduledOn(day) && habit.progressOn(day) == 0) return 'Rest day';
    if (habit.type == HabitType.measurable) {
      return '${habit.progressOn(day)} / ${habit.targetPerDay} ${habit.unit}';
    }
    return habit.isCompletedOn(day) ? 'Done' : 'Not done';
  }
}

class _CanvasTitle extends StatelessWidget {
  const _CanvasTitle({required this.subtitle, required this.accent});

  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '365-DAY CONTRIBUTION CANVAS',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: AppColors.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _Legend(accent: accent),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    Widget box(Color fill, {Color? border}) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(2.5),
        border: border == null ? null : Border.all(color: border),
      ),
    );
    const caption = TextStyle(fontSize: 9.5, color: AppColors.textMuted);

    return ExcludeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Less', style: caption),
              const SizedBox(width: 4),
              box(AppColors.surface),
              for (final alpha in [0.42, 0.60, 0.78, 0.95]) box(accent.withValues(alpha: alpha)),
              const SizedBox(width: 4),
              const Text('More', style: caption),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [box(Colors.transparent, border: AppColors.cellRestBorder), const Text(' Rest day', style: caption)],
          ),
        ],
      ),
    );
  }
}

class _Inspector extends StatelessWidget {
  const _Inspector({required this.day, required this.text});

  final Day day;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder, width: 0.8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                DateFormat('EEE, d MMM yyyy').format(day.toLocalDateTime()),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? color.withValues(alpha: 0.20) : AppColors.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? color.withValues(alpha: 0.5) : AppColors.cardBorder,
                width: selected ? 1.0 : 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 13, color: selected ? color : AppColors.textMuted),
                const SizedBox(width: 5),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected ? AppColors.textPrimary : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
