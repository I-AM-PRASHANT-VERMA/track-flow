import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_flow/core/theme/app_theme.dart';
import 'package:track_flow/domain/habit.dart';
import 'package:track_flow/features/habit_editor/habit_editor_sheet.dart';
import 'package:track_flow/features/habit_editor/habit_form.dart';

void main() {
  final now = DateTime(2026, 3, 18, 10);

  /// Opens the editor from a button and returns a getter for the popped result.
  Future<Habit? Function()> openEditor(
    WidgetTester tester, {
    Habit? initial,
  }) async {
    Habit? result;
    tester.view.physicalSize = const Size(412, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showModalBottomSheet<Habit>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) =>
                      HabitEditorSheet(initial: initial, clock: () => now),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return () => result;
  }

  Finder field(String label) => find.widgetWithText(TextField, label);

  testWidgets(
    'an empty name shows an error instead of silently doing nothing',
    (tester) async {
      final result = await openEditor(tester);
      await tester.tap(find.text('Create Habit'));
      await tester.pumpAndSettle();
      expect(find.text('Give the habit a name'), findsOneWidget);
      expect(result(), isNull);
    },
  );

  testWidgets('an out-of-range target is rejected with a message', (
    tester,
  ) async {
    final result = await openEditor(tester);
    await tester.enterText(field('Habit name'), 'Water');
    await tester.tap(find.text('Measurable Target'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Daily target'), '0');
    await tester.tap(find.text('Create Habit'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a number from 1 to 9999'), findsOneWidget);
    expect(result(), isNull);
  });

  testWidgets('a custom category typed but not confirmed is still saved', (
    tester,
  ) async {
    final result = await openEditor(tester);
    await tester.enterText(field('Habit name'), 'Breathe');
    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Category name'), 'Meditation');
    await tester.tap(find.text('Create Habit'));
    await tester.pumpAndSettle();
    expect(result()!.category, 'Meditation');
    expect(result()!.createdAt, now);
  });

  testWidgets('repeat days can be chosen', (tester) async {
    final result = await openEditor(tester);
    await tester.enterText(field('Habit name'), 'Gym');
    await tester.tap(find.bySemanticsLabel('Saturday'));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Sunday'));
    await tester.pump();
    await tester.tap(find.text('Create Habit'));
    await tester.pumpAndSettle();
    expect(result()!.scheduledDays, [1, 2, 3, 4, 5]);
  });

  testWidgets('editing keeps id, creation date, history and archive state', (
    tester,
  ) async {
    final original = Habit(
      id: 'keep',
      title: 'Old name',
      createdAt: DateTime(2025, 6),
      logs: const {'2026-03-01': 1},
      isArchived: true,
    );
    final result = await openEditor(tester, initial: original);
    await tester.enterText(field('Habit name'), 'New name');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    final saved = result()!;
    expect(saved.id, 'keep');
    expect(saved.title, 'New name');
    expect(saved.createdAt, DateTime(2025, 6));
    expect(saved.logs, {'2026-03-01': 1});
    expect(saved.isArchived, isTrue);
  });

  testWidgets('the tracking type is locked once progress exists', (
    tester,
  ) async {
    final original = Habit(
      id: 'h',
      title: 'Run',
      createdAt: DateTime(2025, 6),
      logs: const {'2026-03-01': 1},
    );
    final result = await openEditor(tester, initial: original);
    expect(
      find.text('The tracking type is fixed once progress has been logged.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Measurable Target'), warnIfMissed: false);
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    expect(result()!.type, HabitType.boolean);
  });

  group('HabitForm', () {
    test('title rules', () {
      expect(HabitForm.validateTitle('  '), isNotNull);
      expect(HabitForm.validateTitle('F'), isNull);
      expect(HabitForm.validateTitle('x' * 41), isNotNull);
    });

    test('target rules', () {
      expect(HabitForm.validateTarget('1'), isNull);
      expect(HabitForm.validateTarget('9999'), isNull);
      for (final bad in ['', '0', '-3', '10000', 'abc']) {
        expect(HabitForm.validateTarget(bad), isNotNull, reason: bad);
      }
    });

    test('empty unit falls back to "times"', () {
      expect(HabitForm.unitOrDefault('  '), 'times');
      expect(HabitForm.unitOrDefault(' pages '), 'pages');
    });
  });
}
