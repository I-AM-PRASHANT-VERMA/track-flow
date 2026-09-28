import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/habit_item.dart';

enum ViewMode { flow, matrix, heatmap }

// Executive summary header showing today's progress and view mode selector
class ExecutiveSummaryHeader extends StatelessWidget {
  final List<HabitItem> habits;
  final ViewMode activeViewMode;
  final ValueChanged<ViewMode> onViewModeChanged;
  final VoidCallback onOpenBackupSheet;

  const ExecutiveSummaryHeader({
    super.key,
    required this.habits,
    required this.activeViewMode,
    required this.onViewModeChanged,
    required this.onOpenBackupSheet,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate today's stats across scheduled habits
    final todayWeekday = DateTime.now().weekday;
    final scheduledToday = habits.where((h) => !h.isArchived && h.scheduledDays.contains(todayWeekday)).toList();
    final completedToday = scheduledToday.where((h) => h.isCompletedToday).length;
    final completionPct = scheduledToday.isEmpty ? 0.0 : (completedToday / scheduledToday.length);

    // Highest active streak among all habits
    final maxStreak = habits.isEmpty
        ? 0
        : habits.map((h) => h.currentStreak).fold(0, (max, val) => val > max ? val : max);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top bar: Logo, App Title, Offline Pro badge, Streak, and Backup button
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.bolt_rounded, size: 20, color: Colors.black),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'TrackFlow',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: isDark ? Colors.white : AppColors.textDarkPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            width: 0.8,
                          ),
                        ),
                        child: const Text(
                          'OFFLINE PRO',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Zero-bloat consistency engine',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textMuted : AppColors.textDarkSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Max Active Streak Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B2333) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.streakOrange.withValues(alpha: 0.35),
                    width: 0.9,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(
                      '$maxStreak d',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.streakOrange : const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),

              // Backup & Settings Button
              IconButton(
                icon: const Icon(Icons.tune_rounded, size: 18),
                color: isDark ? AppColors.textSecondary : AppColors.textDarkSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'Backup & Settings',
                onPressed: onOpenBackupSheet,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Consistency score & progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TODAY'S MOMENTUM",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: isDark ? AppColors.textMuted : Colors.black54,
                ),
              ),
              Text(
                '${(completionPct * 100).toInt()}% • $completedToday of ${scheduledToday.length} done',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: completionPct,
              minHeight: 6,
              backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),

          const SizedBox(height: 12),

          // View Switcher Bar
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBg : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _buildTabButton(
                  context,
                  title: "Today's Flow",
                  icon: Icons.view_agenda_outlined,
                  isSelected: activeViewMode == ViewMode.flow,
                  onTap: () => onViewModeChanged(ViewMode.flow),
                ),
                _buildTabButton(
                  context,
                  title: '7-Day Matrix',
                  icon: Icons.grid_view_rounded,
                  isSelected: activeViewMode == ViewMode.matrix,
                  onTap: () => onViewModeChanged(ViewMode.matrix),
                ),
                _buildTabButton(
                  context,
                  title: '365-Day Canvas',
                  icon: Icons.calendar_view_month_rounded,
                  isSelected: activeViewMode == ViewMode.heatmap,
                  onTap: () => onViewModeChanged(ViewMode.heatmap),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.darkCard : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.textMuted : Colors.black45),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? (isDark ? Colors.white : AppColors.textDarkPrimary)
                        : (isDark ? AppColors.textMuted : Colors.black54),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
