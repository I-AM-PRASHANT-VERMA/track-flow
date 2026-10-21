import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/section_card.dart';
import '../../core/widgets/stat_tile.dart';
import '../../domain/habit_stats.dart';

/// Past-365-days numbers under the canvas.
class YearSummaryCard extends StatelessWidget {
  const YearSummaryCard({
    super.key,
    required this.summary,
    required this.isFiltered,
  });

  final YearSummary summary;
  final bool isFiltered;

  static const _weekdays = [
    '',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    final total = summary.total;
    final peak = summary.peakWeekday;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded, size: 15, color: AppColors.primary),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'ANNUAL CONSISTENCY',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.sectionLabel,
                ),
              ),
              Text(
                'PAST 365 DAYS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  value: '${(total.ratio * 100).round()}%',
                  title: 'Annual Rate',
                  caption: '${total.completed} / ${total.scheduled} completed',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  value: '${summary.activeDays}',
                  title: 'Active Days',
                  caption: 'Days with at least one done',
                  valueColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total.ratio,
              minHeight: 6,
              backgroundColor: AppColors.track,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatPill(
                  value: peak == null ? '–' : _weekdays[peak],
                  label: peak == null
                      ? 'Peak Day'
                      : 'Peak Day (${(summary.peakWeekdayRatio * 100).round()}%)',
                  valueColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: StatPill(
                  value: '${summary.bestStreak} d',
                  label: 'Best Streak',
                  valueColor: AppColors.streakAmber,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: StatPill(
                  value: '${summary.habitCount}',
                  label: isFiltered ? 'Filtered' : 'Tracked Habits',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
