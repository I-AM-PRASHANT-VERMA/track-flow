import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_flow/domain/day.dart';
import 'package:track_flow/domain/habit.dart';
import 'package:track_flow/features/home/summary_header.dart';

import '../support/test_app.dart';

void main() {
  final today = Day.of(testNow);

  testWidgets(
    'a fresh install shows the empty state, not invented demo habits',
    (tester) async {
      await pumpTrackFlow(tester);
      expect(find.text('No habits tracked yet'), findsOneWidget);
      expect(find.textContaining('0 of 0 done'), findsOneWidget);
    },
  );

  testWidgets('creating a habit adds a card and stores it', (tester) async {
    final (repository, store) = await pumpTrackFlow(tester);

    await tester.tap(find.text('New Habit'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Habit name'),
      'Evening walk',
    );
    await tester.tap(find.text('Create Habit'));
    await tester.pumpAndSettle();

    expect(find.text('Evening walk'), findsOneWidget);
    await repository.flush();
    expect(store.saved.single.title, 'Evening walk');
  });

  testWidgets('every tab starts at the top: short content is not centred', (
    tester,
  ) async {
    await pumpTrackFlow(tester, habits: [testHabit('Run')]);
    final headerBottom = tester.getBottomLeft(find.byType(SummaryHeader)).dy;

    await tester.tap(find.text('365-Day Canvas'));
    await tester.pumpAndSettle();
    final chipTop = tester.getTopLeft(find.text('Overall Consistency')).dy;
    expect(chipTop - headerBottom, lessThan(40));

    await tester.tap(find.text('7-Day Matrix'));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('7-DAY PERFORMANCE')).dy - headerBottom,
      lessThan(40),
    );
  });

  testWidgets('deleting asks for nothing but can be undone', (tester) async {
    final (repository, _) = await pumpTrackFlow(
      tester,
      habits: [testHabit('Run'), testHabit('Read')],
    );

    await tester.tap(find.byTooltip('Options for Run'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Run'), findsNothing);
    expect(repository.habits.map((h) => h.id), ['Read']);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(repository.habits.map((h) => h.id), ['Run', 'Read']);
    expect(find.text('Run'), findsOneWidget);
  });

  testWidgets('quick successive taps on +1 are all counted and stored', (
    tester,
  ) async {
    final (repository, store) = await pumpTrackFlow(
      tester,
      habits: [testHabit('Water', type: HabitType.measurable, target: 8)],
    );

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.bySemanticsLabel('Increase Water by 1'));
      await tester.pump();
    }
    expect(repository.find('Water')!.progressOn(today), 3);
    expect(find.textContaining('3'), findsWidgets);
    await repository.flush();
    expect(store.saved.single.progressOn(today), 3);
  });

  testWidgets('the header counts only active habits scheduled today', (
    tester,
  ) async {
    await pumpTrackFlow(
      tester,
      habits: [
        testHabit('Done', logs: {today.key: 1}),
        testHabit('Pending'),
        testHabit('Weekend', days: const [6, 7]),
        testHabit('Archived', archived: true, logs: {today.key: 1}),
      ],
    );
    expect(find.text('50% • 1 of 2 done'), findsOneWidget);
  });

  testWidgets(
    'narrow screen with large text renders every tab without overflow',
    (tester) async {
      await pumpTrackFlow(
        tester,
        size: const Size(320, 640),
        textScale: 1.3,
        habits: [
          testHabit(
            'A very long habit name that will not fit',
            type: HabitType.measurable,
            target: 90,
          ),
          testHabit('Rest days', days: const [1, 2, 3, 4, 5]),
        ],
      );
      expect(tester.takeException(), isNull);

      for (final tab in ['7-Day Matrix', '365-Day Canvas']) {
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: tab);
      }
    },
  );
}
