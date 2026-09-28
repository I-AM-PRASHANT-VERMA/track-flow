import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/habit_item.dart';

enum ViewMode { flow, matrix, heatmap }

// Executive summary header with adaptive landscape/portrait layout and soothing Radix colors
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
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    // Calculate today's stats across scheduled habits
    final todayWeekday = DateTime.now().weekday;
    final scheduledToday = habits.where((h) => !h.isArchived && h.scheduledDays.contains(todayWeekday)).toList();
    final completedToday = scheduledToday.where((h) => h.isCompletedToday).length;
    final completionPct = scheduledToday.isEmpty ? 0.0 : (completedToday / scheduledToday.length);

    // Highest active streak
    final maxStreak = habits.isEmpty
        ? 0
        : habits.map((h) => h.currentStreak).fold(0, (max, val) => val > max ? val : max);

    if (isLandscape) {
      return _buildLandscapeHeader(context, isDark, completionPct, completedToday, scheduledToday.length, maxStreak);
    }

    return _buildPortraitHeader(context, isDark, completionPct, completedToday, scheduledToday.length, maxStreak);
  }

  // Portrait Header: Stacked executive layout
  Widget _buildPortraitHeader(
    BuildContext context,
    bool isDark,
    double completionPct,
    int completedToday,
    int totalToday,
    int maxStreak,
  ) {
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
          // Top Row: Logo, Title, Streak pill, and Settings/Backup
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    width: 0.9,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.bolt_rounded, size: 18, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TrackFlow',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: isDark ? AppColors.textPrimary : AppColors.textDarkPrimary,
                    ),
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

              // Sleek streak pill with vector flame
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.streakAmber.withValues(alpha: 0.12)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.streakAmber.withValues(alpha: 0.25),
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
                    const SizedBox(width: 4),
                    Text(
                      '$maxStreak d',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.streakAmber : const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),

              // Backup & Settings
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

          const SizedBox(height: 10),

          // Momentum row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "TODAY'S MOMENTUM",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                '${(completionPct * 100).toInt()}% • $completedToday of $totalToday done',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: completionPct,
              minHeight: 4,
              backgroundColor: isDark ? AppColors.darkSurface : const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),

          const SizedBox(height: 10),

          // View Switcher Bar
          _buildViewSwitcherBar(context, isDark),
        ],
      ),
    );
  }

  // Landscape Header: Ultra-compact single horizontal bar to maximize screen real estate
  Widget _buildLandscapeHeader(
    BuildContext context,
    bool isDark,
    double completionPct,
    int completedToday,
    int totalToday,
    int maxStreak,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo & Brand
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 0.8),
            ),
            child: const Center(
              child: Icon(Icons.bolt_rounded, size: 16, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'TrackFlow',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: isDark ? AppColors.textPrimary : AppColors.textDarkPrimary,
            ),
          ),
          const SizedBox(width: 16),

          // View Switcher in the center
          Expanded(
            child: _buildViewSwitcherBar(context, isDark),
          ),
          const SizedBox(width: 16),

          // Streak Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.streakAmber.withValues(alpha: 0.12)
                  : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.streakAmber.withValues(alpha: 0.25),
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
                const SizedBox(width: 4),
                Text(
                  '$maxStreak d',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.streakAmber : const Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Backup & Settings
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
    );
  }

  Widget _buildViewSwitcherBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFE2E8F0),
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
          padding: const EdgeInsets.symmetric(vertical: 5.5),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.darkCard : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(
                    color: isDark ? AppColors.darkCardBorder : const Color(0xFFCBD5E1),
                    width: 0.8,
                  )
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
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? (isDark ? AppColors.textPrimary : AppColors.textDarkPrimary)
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
