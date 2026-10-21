import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_flow/app.dart';
import 'package:track_flow/data/habit_repository.dart';
import 'package:track_flow/domain/habit.dart';

import 'in_memory_habit_store.dart';

/// Wednesday, 18 March 2026, 10:00: every widget test runs on this fixed day.
final DateTime testNow = DateTime(2026, 3, 18, 10);

/// Pumps the whole app with in-memory storage and a fixed clock, on a phone-
/// sized screen. Returns the repository so tests can check what was stored.
Future<(HabitRepository, InMemoryHabitStore)> pumpTrackFlow(
  WidgetTester tester, {
  List<Habit> habits = const [],
  Size size = const Size(412, 892),
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  final store = InMemoryHabitStore(habits);
  final repository = HabitRepository(store);
  await repository.load();
  await tester.pumpWidget(
    TrackFlowApp(repository: repository, clock: () => testNow),
  );
  await tester.pumpAndSettle();
  return (repository, store);
}

Habit testHabit(
  String id, {
  HabitType type = HabitType.boolean,
  int target = 1,
  Map<String, int> logs = const {},
  List<int> days = Habit.everyDay,
  HabitTimeOfDay timeOfDay = HabitTimeOfDay.morning,
  bool archived = false,
  String? title,
}) {
  return Habit(
    id: id,
    title: title ?? id,
    createdAt: DateTime(2026),
    type: type,
    targetPerDay: target,
    unit: type == HabitType.measurable ? 'glasses' : 'times',
    logs: logs,
    scheduledDays: days,
    timeOfDay: timeOfDay,
    isArchived: archived,
  );
}
