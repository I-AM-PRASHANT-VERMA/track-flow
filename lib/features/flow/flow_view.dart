import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../domain/day.dart';
import '../../domain/habit.dart';
import 'flow_sections.dart';
import 'habit_card.dart';

/// Today's Flow: active habits grouped by time of day. Two columns in landscape.
class FlowView extends StatelessWidget {
  const FlowView({
    super.key,
    required this.habits,
    required this.today,
    required this.onProgress,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Habit> habits;
  final Day today;
  final void Function(Habit habit, Day day, int count) onProgress;
  final ValueChanged<Habit> onEdit;
  final ValueChanged<Habit> onDelete;

  @override
  Widget build(BuildContext context) {
    final sections = buildFlowSections(habits);
    if (sections.isEmpty) return const _EmptyFlow();

    final columns = MediaQuery.orientationOf(context) == Orientation.landscape ? 2 : 1;
    final rows = _rows(sections, columns);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return ListView.builder(
      key: const PageStorageKey('flow'),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.p16,
        AppSpacing.p12,
        AppSpacing.p16,
        AppSpacing.fabClearance + bottomInset,
      ),
      itemCount: rows.length,
      itemBuilder: (context, index) => switch (rows[index]) {
        _HeaderRow(:final section) => _SectionHeader(section: section),
        _CardRow(:final cards) => _cardRow(cards, columns),
      },
    );
  }

  Widget _cardRow(List<Habit> cards, int columns) {
    Widget card(Habit habit) => HabitCard(
      key: ValueKey(habit.id),
      habit: habit,
      today: today,
      onProgress: (day, count) => onProgress(habit, day, count),
      onEdit: () => onEdit(habit),
      onDelete: () => onDelete(habit),
    );
    if (columns == 1) return card(cards.single);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < columns; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.p12),
          Expanded(child: i < cards.length ? card(cards[i]) : const SizedBox.shrink()),
        ],
      ],
    );
  }

  static List<_Row> _rows(List<FlowSection> sections, int columns) {
    return [
      for (final section in sections) ...[
        _HeaderRow(section),
        for (var i = 0; i < section.habits.length; i += columns)
          _CardRow(section.habits.sublist(i, (i + columns).clamp(0, section.habits.length))),
      ],
    ];
  }
}

sealed class _Row {
  const _Row();
}

final class _HeaderRow extends _Row {
  const _HeaderRow(this.section);

  final FlowSection section;
}

final class _CardRow extends _Row {
  const _CardRow(this.cards);

  final List<Habit> cards;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.section});

  final FlowSection section;

  static const _titles = {
    HabitTimeOfDay.morning: ('MORNING RITUALS', Icons.wb_twilight_rounded, AppColors.streakAmber),
    HabitTimeOfDay.afternoon: ('DEEP WORK & MASTERY', Icons.wb_sunny_rounded, AppColors.secondary),
    HabitTimeOfDay.evening: ('EVENING WIND-DOWN', Icons.nightlight_round, AppColors.evening),
    HabitTimeOfDay.anytime: ('ANYTIME RITUALS', Icons.all_inclusive_rounded, AppColors.primary),
  };

  @override
  Widget build(BuildContext context) {
    final (title, icon, color) = _titles[section.timeOfDay]!;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Semantics(
        header: true,
        child: Row(
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 7),
            Flexible(
              child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.sectionLabel),
            ),
            const SizedBox(width: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(6)),
              child: Text(
                '${section.habits.length}',
                style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFlow extends StatelessWidget {
  const _EmptyFlow();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.p24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_outlined, size: 44, color: AppColors.textMuted),
            SizedBox(height: 12),
            Text(
              'No habits tracked yet',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            SizedBox(height: 6),
            Text(
              'Tap "New Habit" to build your first routine.',
              textAlign: TextAlign.center,
              style: AppText.body,
            ),
          ],
        ),
      ),
    );
  }
}
