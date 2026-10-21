import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/theme/app_colors.dart';
import 'data/habit_repository.dart';
import 'data/shared_prefs_habit_store.dart';
import 'domain/clock.dart';

/// Composition root: the only place that chooses concrete implementations.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  final repository = HabitRepository(SharedPrefsHabitStore(prefs, clock: systemClock));
  await repository.load();

  runApp(TrackFlowApp(repository: repository));
}
