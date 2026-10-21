import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/habit_repository.dart';
import 'data/shared_prefs_habit_store.dart';
import 'domain/clock.dart';

/// Composition root: the only place that chooses concrete implementations.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final repository = HabitRepository(
    SharedPrefsHabitStore(prefs, clock: systemClock),
  );
  await repository.load();

  runApp(TrackFlowApp(repository: repository));
}
