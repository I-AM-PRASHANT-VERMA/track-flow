import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/touch_target.dart';
import '../../domain/habit_stats.dart';
import 'home_tab.dart';

/// App bar area: brand, today's momentum, longest streak and the view switcher.
/// Portrait stacks it; landscape packs it into one row to keep vertical space.
class SummaryHeader extends StatelessWidget {
  const SummaryHeader({
    super.key,
    required this.summary,
    required this.tab,
    required this.onTabSelected,
    required this.onOpenBackup,
  });

  final TodaySummary summary;
  final HomeTab tab;
  final ValueChanged<HomeTab> onTabSelected;
  final VoidCallback onOpenBackup;

  @override
  Widget build(BuildContext context) {
    final landscape = MediaQuery.orientationOf(context) == Orientation.landscape;
    final switcher = _ViewSwitcher(selected: tab, onSelected: onTabSelected);
    final streak = _StreakPill(days: summary.longestCurrentStreak);
    final settings = TouchTarget(
      onTap: onOpenBackup,
      semanticLabel: 'Backup and restore',
      child: const Icon(Icons.tune_rounded, size: 20, color: AppColors.textSecondary),
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.p16,
          vertical: landscape ? AppSpacing.p8 : AppSpacing.p12,
        ),
        child: landscape
            ? Row(
                children: [
                  const _Brand(logoSize: 28),
                  const SizedBox(width: AppSpacing.p16),
                  Expanded(child: switcher),
                  const SizedBox(width: AppSpacing.p16),
                  streak,
                  settings,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Expanded(child: _Brand(logoSize: 32)),
                      streak,
                      const SizedBox(width: AppSpacing.p4),
                      settings,
                    ],
                  ),
                  const SizedBox(height: AppSpacing.p8),
                  _Momentum(summary: summary),
                  const SizedBox(height: AppSpacing.p8),
                  switcher,
                ],
              ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.logoSize});

  final double logoSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/images/app_logo.png', width: logoSize, height: logoSize, fit: BoxFit.cover),
        ),
        const SizedBox(width: AppSpacing.p8),
        const Flexible(
          child: Text(
            'TrackFlow',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _StreakPill extends StatelessWidget {
  const _StreakPill({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Longest active streak: $days days',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p8, vertical: AppSpacing.p4),
        decoration: BoxDecoration(
          color: AppColors.streakAmber.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.streakAmber.withValues(alpha: 0.25), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_fire_department_rounded, size: 13, color: AppColors.streakAmber),
            const SizedBox(width: AppSpacing.p4),
            Text(
              '$days d',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.streakAmber),
            ),
          ],
        ),
      ),
    );
  }
}

class _Momentum extends StatelessWidget {
  const _Momentum({required this.summary});

  final TodaySummary summary;

  @override
  Widget build(BuildContext context) {
    final percent = (summary.ratio * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                "TODAY'S MOMENTUM",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.p8),
            Flexible(
              child: Text(
                '$percent% • ${summary.completed} of ${summary.scheduled} done',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.p4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: summary.ratio,
            minHeight: 4,
            backgroundColor: AppColors.surface,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _ViewSwitcher extends StatelessWidget {
  const _ViewSwitcher({required this.selected, required this.onSelected});

  final HomeTab selected;
  final ValueChanged<HomeTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          for (final tab in HomeTab.values)
            Expanded(
              child: Semantics(
                selected: tab == selected,
                button: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelected(tab),
                  child: _TabLabel(tab: tab, isSelected: tab == selected),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({required this.tab, required this.isSelected});

  final HomeTab tab;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.card : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: AppColors.cardBorder, width: 0.8) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(tab.icon, size: 13, color: isSelected ? AppColors.primary : AppColors.textMuted),
          const SizedBox(width: AppSpacing.p4),
          Flexible(
            child: Text(
              tab.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
