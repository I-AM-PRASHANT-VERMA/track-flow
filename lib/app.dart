import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/time/today_notifier.dart';
import 'data/habit_repository.dart';
import 'domain/clock.dart';
import 'features/home/home_screen.dart';

class TrackFlowApp extends StatefulWidget {
  const TrackFlowApp({super.key, required this.repository, this.clock = systemClock});

  final HabitRepository repository;
  final Clock clock;

  @override
  State<TrackFlowApp> createState() => _TrackFlowAppState();
}

class _TrackFlowAppState extends State<TrackFlowApp> {
  late final TodayNotifier _today = TodayNotifier(clock: widget.clock);

  @override
  void dispose() {
    _today.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: HomeScreen(repository: widget.repository, today: _today, clock: widget.clock),
    );
  }
}
