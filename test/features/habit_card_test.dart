import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_flow/core/theme/app_theme.dart';
import 'package:track_flow/domain/day.dart';
import 'package:track_flow/domain/habit.dart';
import 'package:track_flow/features/flow/habit_card.dart';

void main() {
  final today = Day(2026, 3, 18);
  final calls = <(Day, int)>[];

  Future<void> pumpCard(WidgetTester tester, Habit habit, {double width = 412, double textScale = 1}) async {
    calls.clear();
    tester.view.physicalSize = Size(width, 600);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: HabitCard(
              habit: habit,
              today: today,
              onProgress: (day, count) => calls.add((day, count)),
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      ),
    );
  }

  Habit measurable(int logged, {int target = 10}) => Habit(
    id: 'w',
    title: 'Water',
    createdAt: DateTime(2026, 1, 1),
    type: HabitType.measurable,
    targetPerDay: target,
    logs: {today.key: logged},
  );

  testWidgets('"-" lowers by one step from any value (35 of 10 goes to 34)', (tester) async {
    await pumpCard(tester, measurable(35));
    await tester.tap(find.bySemanticsLabel('Decrease Water by 1'));
    expect(calls.single, (today, 34));
  });

  testWidgets('"-" never goes below zero and is disabled at zero', (tester) async {
    await pumpCard(tester, measurable(0));
    await tester.tap(find.bySemanticsLabel('Decrease Water by 1'), warnIfMissed: false);
    expect(calls, isEmpty);
  });

  testWidgets('week cells announce their day and state and have a 44 dp tall hit area', (tester) async {
    final habit = Habit(
      id: 'r',
      title: 'Run',
      createdAt: DateTime(2026, 1, 1),
      scheduledDays: const [1, 2, 3, 4, 5],
      logs: {today.key: 1},
    );
    await pumpCard(tester, habit);

    expect(find.bySemanticsLabel('Wednesday 18, done'), findsOneWidget);
    expect(find.bySemanticsLabel('Sunday 15, rest day'), findsOneWidget);
    expect(find.bySemanticsLabel('Tuesday 17, not done'), findsOneWidget);
    expect(tester.getSize(find.bySemanticsLabel('Tuesday 17, not done')).height, greaterThanOrEqualTo(44));
  });

  testWidgets('tapping a past day toggles it', (tester) async {
    await pumpCard(tester, Habit(id: 'r', title: 'Run', createdAt: DateTime(2026, 1, 1)));
    await tester.tap(find.bySemanticsLabel('Tuesday 17, not done'));
    expect(calls.single, (today.addDays(-1), 1));
  });

  testWidgets('a habit not scheduled today says so on its toggle', (tester) async {
    await pumpCard(tester, Habit(id: 'r', title: 'Run', createdAt: DateTime(2026, 1, 1), scheduledDays: const [6, 7]));
    expect(find.text('Rest day · Tap to log anyway'), findsOneWidget);
  });

  testWidgets('fits a 320 dp screen at 1.3x text without overflow', (tester) async {
    await pumpCard(tester, measurable(3, target: 90), width: 320, textScale: 1.3);
    expect(tester.takeException(), isNull);
  });
}
