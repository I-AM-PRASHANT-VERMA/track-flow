import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_flow/data/backup_codec.dart';

import '../support/test_app.dart';

void main() {
  Future<void> openRestore(WidgetTester tester) async {
    await tester.tap(find.bySemanticsLabel('Backup and restore'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restore from Backup'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'the sheet offers only real, offline backup (no fake cloud sync)',
    (tester) async {
      await pumpTrackFlow(tester);
      await tester.tap(find.bySemanticsLabel('Backup and restore'));
      await tester.pumpAndSettle();
      expect(find.text('Backup & Restore'), findsOneWidget);
      expect(find.textContaining('Google'), findsNothing);
      expect(find.textContaining('Sync'), findsNothing);
    },
  );

  testWidgets('copying a backup puts valid backup text on the clipboard', (
    tester,
  ) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map<Object?, Object?>)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await pumpTrackFlow(tester, habits: [testHabit('Run'), testHabit('Read')]);
    await tester.tap(find.bySemanticsLabel('Backup and restore'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copy Backup'));
    await tester.pumpAndSettle();

    expect(BackupCodec.parse(copied!, now: testNow).habits.map((h) => h.id), [
      'Run',
      'Read',
    ]);
    expect(find.textContaining('Backup of 2 habits copied'), findsOneWidget);
  });

  testWidgets(
    'invalid text is refused with a clear message and nothing changes',
    (tester) async {
      final (repository, _) = await pumpTrackFlow(
        tester,
        habits: [testHabit('Run')],
      );
      await openRestore(tester);
      await tester.enterText(find.byType(TextField), 'not a backup');
      await tester.tap(find.text('Restore Habits'));
      await tester.pumpAndSettle();

      expect(find.text(BackupProblem.notABackup.message), findsOneWidget);
      expect(repository.habits.single.id, 'Run');
    },
  );

  testWidgets('restoring asks first, replaces the habits, and can be undone', (
    tester,
  ) async {
    final (repository, _) = await pumpTrackFlow(
      tester,
      habits: [testHabit('Run')],
    );
    final backup = BackupCodec.export([
      testHabit('Swim'),
      testHabit('Yoga'),
    ], now: testNow);

    await openRestore(tester);
    await tester.enterText(find.byType(TextField), backup);
    await tester.tap(find.text('Restore Habits'));
    await tester.pumpAndSettle();
    expect(find.text('Replace your habits?'), findsOneWidget);

    await tester.tap(find.text('Replace'));
    await tester.pumpAndSettle();
    expect(repository.habits.map((h) => h.id), ['Swim', 'Yoga']);
    expect(find.text('Restored 2 habits from the backup'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(repository.habits.map((h) => h.id), ['Run']);
  });

  testWidgets('cancelling the confirmation changes nothing', (tester) async {
    final (repository, _) = await pumpTrackFlow(
      tester,
      habits: [testHabit('Run')],
    );
    await openRestore(tester);
    await tester.enterText(find.byType(TextField), '{"habits": []}');
    await tester.tap(find.text('Restore Habits'));
    await tester.pumpAndSettle();
    expect(find.textContaining('removes all 1 of your habits'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repository.habits.single.id, 'Run');
  });
}
