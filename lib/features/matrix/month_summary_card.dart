import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/section_card.dart';
import '../../core/widgets/stat_tile.dart';
import '../../domain/day.dart';
import '../../domain/habit_stats.dart';

/// Month-to-date consistency, the rolling 30 days and the best streak.
class MonthSummaryCard extends StatelessWidget {
  const MonthSummaryCard({
    super.key,
    required this.summary,
    required this.today,
  });

  final MonthSummary summary;
  final Day today;

  @override
  Widget build(BuildContext context) {
    final monthToDate = summary.monthToDate;
    final elapsedPercent = (summary.elapsedDays / summary.daysInMonth * 100)
        .round();

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insights_rounded,
                size: 15,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'MONTHLY CONSISTENCY',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.sectionLabel,
                ),
              ),
              Text(
                DateFormat('MMMM yyyy')
                    .format(today.toLocalDateTime())
                    .toUpperCase(),
                style: const TextStyle(
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
                  value: '${(monthToDate.ratio * 100).round()}%',
                  title: 'Month-to-Date',
                  caption:
                      'Day 1 - ${summary.elapsedDays} ($elapsedPercent% elapsed)',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  value: '${(summary.rolling30.ratio * 100).round()}%',
                  title: '30-Day Rolling',
                  caption: 'Last 30 days',
                  valueColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: monthToDate.ratio,
              minHeight: 6,
              backgroundColor: AppColors.track,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Counts completed habits against the days they were scheduled, from the 1st (or the day a habit '
            'was added) through today.',
            style: TextStyle(
              fontSize: 10,
              height: 1.3,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatPill(
                  value: '${summary.perfectDays}',
                  label: 'Perfect Days',
                  valueColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: StatPill(
                  value: '${monthToDate.completed} / ${monthToDate.scheduled}',
                  label: 'Checks Done',
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
            ],
          ),
        ],
      ),
    );
  }
}
