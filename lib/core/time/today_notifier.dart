import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../domain/clock.dart';
import '../../domain/day.dart';

/// Publishes the current calendar day. It changes at midnight and is re-checked
/// whenever the app returns to the foreground, so "today" on screen never stays
/// on yesterday while the app is left open.
final class TodayNotifier extends ChangeNotifier with WidgetsBindingObserver {
  TodayNotifier({Clock clock = systemClock}) : _clock = clock, _today = Day.of(clock()) {
    WidgetsBinding.instance.addObserver(this);
    _scheduleNextMidnight();
  }

  final Clock _clock;
  Day _today;
  Timer? _midnight;

  Day get today => _today;

  /// Re-reads the clock; listeners are notified only when the day changed.
  void refresh() {
    final now = Day.of(_clock());
    if (now != _today) {
      _today = now;
      notifyListeners();
    }
    _scheduleNextMidnight();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }

  void _scheduleNextMidnight() {
    _midnight?.cancel();
    final now = _clock();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _midnight = Timer(nextMidnight.difference(now) + const Duration(seconds: 1), refresh);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _midnight?.cancel();
    super.dispose();
  }
}
