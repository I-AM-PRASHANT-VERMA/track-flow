import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/time/today_notifier.dart';
import '../../data/habit_repository.dart';
import '../../domain/clock.dart';
import '../../domain/day.dart';
import '../../domain/habit.dart';
import '../../domain/habit_stats.dart';
import '../backup/backup_sheet.dart';
import '../flow/flow_view.dart';
import '../habit_editor/habit_editor_sheet.dart';
import '../heatmap/heatmap_view.dart';
import '../matrix/matrix_view.dart';
import 'home_tab.dart';
import 'summary_header.dart';

/// The single screen: header, the three views and the "New Habit" button.
/// It rebuilds from the repository and the current day; it owns only UI state
/// (selected tab, whether the button is expanded).
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repository,
    required this.today,
    this.clock = systemClock,
  });

  final HabitRepository repository;
  final TodayNotifier today;
  final Clock clock;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeTab _tab = HomeTab.flow;
  bool _fabExtended = true;
  late final Listenable _changes = Listenable.merge([
    widget.repository,
    widget.today,
  ]);

  HabitRepository get _repository => widget.repository;

  @override
  void initState() {
    super.initState();
    if (_repository.hadUnreadableData) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _snack(
          'Some saved data could not be read. A copy was kept and nothing was overwritten.',
        ),
      );
    }
  }

  void _selectTab(HomeTab tab) {
    if (tab == _tab) return;
    setState(() {
      _tab = tab;
      _fabExtended = true;
    });
  }

  bool _onScroll(ScrollUpdateNotification notification) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return false;
    }
    final extended = notification.metrics.pixels < 24;
    if (extended != _fabExtended) setState(() => _fabExtended = extended);
    return false;
  }

  void _setProgress(Habit habit, Day day, int count) =>
      _repository.setProgress(habit.id, day, count);

  Future<void> _openEditor([Habit? habit]) async {
    final result = await showModalBottomSheet<Habit>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HabitEditorSheet(initial: habit, clock: widget.clock),
    );
    if (result == null) return;
    habit == null ? _repository.add(result) : _repository.update(result);
  }

  void _delete(Habit habit) {
    final removed = _repository.remove(habit.id);
    if (removed == null) return;
    _snack(
      'Deleted "${habit.title}"',
      undo: () => _repository.restore(removed),
    );
  }

  Future<void> _openBackup() async {
    final replaced = await showModalBottomSheet<List<Habit>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BackupSheet(repository: _repository, clock: widget.clock),
    );
    if (replaced == null || !mounted) return;
    _snack(
      'Restored ${_repository.habits.length} habits from the backup',
      undo: () => _repository.replaceAll(replaced),
    );
  }

  void _snack(String message, {VoidCallback? undo}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: undo == null
              ? null
              : SnackBarAction(label: 'Undo', onPressed: undo),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: _changes,
          builder: (context, _) {
            final habits = _repository.habits;
            final today = widget.today.today;
            return Column(
              children: [
                SummaryHeader(
                  summary: HabitStats.today(habits, today),
                  tab: _tab,
                  onTabSelected: _selectTab,
                  onOpenBackup: _openBackup,
                ),
                Expanded(
                  child: NotificationListener<ScrollUpdateNotification>(
                    onNotification: _onScroll,
                    // IndexedStack keeps every view alive (scroll position, filters)
                    // and gives each one the full height, so short content starts at
                    // the top instead of being centred.
                    child: IndexedStack(
                      index: _tab.index,
                      sizing: StackFit.expand,
                      children: [
                        FlowView(
                          habits: habits,
                          today: today,
                          onProgress: _setProgress,
                          onEdit: _openEditor,
                          onDelete: _delete,
                        ),
                        MatrixView(
                          habits: habits,
                          today: today,
                          onProgress: _setProgress,
                        ),
                        HeatmapView(habits: habits, today: today),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        isExtended: _fabExtended,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 2.5,
        tooltip: 'New habit',
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          'New Habit',
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
        ),
        onPressed: _openEditor,
      ),
    );
  }
}
