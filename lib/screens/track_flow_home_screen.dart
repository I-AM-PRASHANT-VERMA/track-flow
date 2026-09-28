import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/services/habit_storage.dart';
import '../models/habit_item.dart';
import '../widgets/add_edit_habit_sheet.dart';
import '../widgets/backup_sheet.dart';
import '../widgets/executive_summary_header.dart';
import '../widgets/habit_card.dart';
import '../widgets/multi_day_matrix_view.dart';
import '../widgets/yearly_heatmap_canvas.dart';

// Primary home screen for TrackFlow with responsive landscape/portrait support and Radix UI aesthetics
class TrackFlowHomeScreen extends StatefulWidget {
  const TrackFlowHomeScreen({super.key});

  @override
  State<TrackFlowHomeScreen> createState() => _TrackFlowHomeScreenState();
}

class _TrackFlowHomeScreenState extends State<TrackFlowHomeScreen> {
  List<HabitItem> _habits = [];
  bool _isLoading = true;
  ViewMode _viewMode = ViewMode.flow;
  HabitItem? _heatmapFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loaded = await HabitStorage.loadHabits();
    setState(() {
      _habits = loaded;
      _isLoading = false;
    });
  }

  Future<void> _saveAndRefresh(List<HabitItem> updated) async {
    await HabitStorage.saveHabits(updated);
    setState(() {
      _habits = updated;
    });
  }

  // Updates today's logged count for a habit
  void _updateTodayProgress(HabitItem habit, int count) {
    final todayKey = HabitItem.dateKey(DateTime.now());
    final newLogs = Map<String, int>.from(habit.logs);
    newLogs[todayKey] = count;

    final updated = habit.copyWith(logs: newLogs);
    _updateHabit(updated);
  }

  // Updates historical date logged count for a habit
  void _toggleHistoricalDate(HabitItem habit, DateTime date, int count) {
    final dateKey = HabitItem.dateKey(date);
    final newLogs = Map<String, int>.from(habit.logs);
    newLogs[dateKey] = count;

    final updated = habit.copyWith(logs: newLogs);
    _updateHabit(updated);
  }

  void _updateHabit(HabitItem updated) {
    final idx = _habits.indexWhere((h) => h.id == updated.id);
    if (idx != -1) {
      final list = List<HabitItem>.from(_habits);
      list[idx] = updated;
      _saveAndRefresh(list);
    }
  }

  void _addNewHabit(HabitItem habit) {
    final list = [habit, ..._habits];
    _saveAndRefresh(list);
  }

  void _deleteHabit(HabitItem habit) {
    final list = _habits.where((h) => h.id != habit.id).toList();
    _saveAndRefresh(list);
  }

  void _openAddSheet([HabitItem? habitToEdit]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditHabitSheet(
        initialHabit: habitToEdit,
        onSave: (habit) {
          if (habitToEdit != null) {
            _updateHabit(habit);
          } else {
            _addNewHabit(habit);
          }
        },
      ),
    );
  }

  void _openBackupSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackupSheet(
        habits: _habits,
        onHabitsReloaded: (reloaded) {
          setState(() => _habits = reloaded);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navInset = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Top Executive Header (Adaptive Landscape/Portrait)
                  ExecutiveSummaryHeader(
                    habits: _habits,
                    activeViewMode: _viewMode,
                    onViewModeChanged: (mode) => setState(() => _viewMode = mode),
                    onOpenBackupSheet: _openBackupSheet,
                  ),

                  // Main View Content
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _buildCurrentView(),
                    ),
                  ),
                ],
              ),
      ),
      // Safe FAB placement clear of Android navigation bar
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: navInset > 0 ? (navInset + 8) : 16,
          right: 4,
        ),
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          foregroundColor: const Color(0xFF0B0F17),
          elevation: 3,
          icon: const Icon(Icons.add_rounded, size: 20, color: Color(0xFF0B0F17)),
          label: const Text(
            'New Habit',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.2),
          ),
          onPressed: () => _openAddSheet(),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_viewMode) {
      case ViewMode.matrix:
        return MultiDayMatrixView(
          key: const ValueKey('matrix_view'),
          habits: _habits,
          onToggleCell: (habit, date, count) => _toggleHistoricalDate(habit, date, count),
        );
      case ViewMode.heatmap:
        return YearlyHeatmapCanvas(
          key: const ValueKey('heatmap_view'),
          habits: _habits,
          selectedHabitFilter: _heatmapFilter,
          onFilterChanged: (filter) => setState(() => _heatmapFilter = filter),
        );
      case ViewMode.flow:
        return _buildFlowList();
    }
  }

  // Flow View: Grouped by ritual times (Morning, Afternoon, Evening, Anytime)
  Widget _buildFlowList() {
    final active = _habits.where((h) => !h.isArchived).toList();
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final navInset = MediaQuery.of(context).viewPadding.bottom;

    if (active.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.flag_outlined, size: 44, color: AppColors.textMuted),
            const SizedBox(height: 12),
            const Text(
              'No habits tracked yet',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap + below to build your first routine',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    final morningHabits = active.where((h) => h.timeOfDay == HabitTimeOfDay.morning).toList();
    final afternoonHabits = active.where((h) => h.timeOfDay == HabitTimeOfDay.afternoon).toList();
    final eveningHabits = active.where((h) => h.timeOfDay == HabitTimeOfDay.evening).toList();
    final anytimeHabits = active.where((h) => h.timeOfDay == HabitTimeOfDay.anytime).toList();

    return ListView(
      key: const ValueKey('flow_view'),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 96 + navInset,
      ),
      children: [
        if (morningHabits.isNotEmpty) ...[
          _buildSectionHeader('MORNING RITUALS', Icons.wb_twilight_rounded, morningHabits.length, const Color(0xFFF59E0B)),
          _buildHabitsGroup(morningHabits, isLandscape),
          const SizedBox(height: 12),
        ],
        if (afternoonHabits.isNotEmpty) ...[
          _buildSectionHeader('DEEP WORK & MASTERY', Icons.wb_sunny_rounded, afternoonHabits.length, const Color(0xFF0EA5E9)),
          _buildHabitsGroup(afternoonHabits, isLandscape),
          const SizedBox(height: 12),
        ],
        if (eveningHabits.isNotEmpty) ...[
          _buildSectionHeader('EVENING WIND-DOWN', Icons.nightlight_round, eveningHabits.length, const Color(0xFFA855F7)),
          _buildHabitsGroup(eveningHabits, isLandscape),
          const SizedBox(height: 12),
        ],
        if (anytimeHabits.isNotEmpty) ...[
          _buildSectionHeader('ANYTIME RITUALS', Icons.all_inclusive_rounded, anytimeHabits.length, AppColors.primary),
          _buildHabitsGroup(anytimeHabits, isLandscape),
        ],
      ],
    );
  }

  // Multi-column responsive layout in Landscape, standard single column in Portrait
  Widget _buildHabitsGroup(List<HabitItem> habits, bool isLandscape) {
    if (isLandscape) {
      final width = MediaQuery.of(context).size.width;
      final cardWidth = (width - 44) / 2; // 2 balanced columns with padding

      return Wrap(
        spacing: 12,
        runSpacing: 4,
        children: habits.map((h) {
          return SizedBox(
            width: cardWidth,
            child: _buildHabitCard(h),
          );
        }).toList(),
      );
    } else {
      return Column(
        children: habits.map(_buildHabitCard).toList(),
      );
    }
  }

  Widget _buildSectionHeader(String title, IconData icon, int count, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 7),
          Text(
            title,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: isDark ? AppColors.textMuted : Colors.black54,
            ),
          ),
          const SizedBox(width: 7),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textSecondary : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitCard(HabitItem habit) {
    return HabitCard(
      key: ValueKey(habit.id),
      habit: habit,
      onUpdateTodayProgress: (val) => _updateTodayProgress(habit, val),
      onToggleHistoricalDate: (dt, val) => _toggleHistoricalDate(habit, dt, val),
      onEdit: () => _openAddSheet(habit),
      onDelete: () => _deleteHabit(habit),
    );
  }
}
