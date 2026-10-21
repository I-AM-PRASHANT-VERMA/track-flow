import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_flow/data/backup_codec.dart';
import 'package:track_flow/domain/habit.dart';

void main() {
  final now = DateTime(2026, 3, 9, 12);

  Matcher throwsProblem(BackupProblem problem) => throwsA(
    isA<BackupException>().having((e) => e.problem, 'problem', problem),
  );

  test('export then parse returns the same habits', () {
    final habits = [
      Habit(id: 'a', title: 'A', createdAt: now, logs: const {'2026-03-09': 1}),
      Habit(
        id: 'b',
        title: 'B',
        createdAt: now,
        type: HabitType.measurable,
        targetPerDay: 8,
      ),
    ];
    final text = BackupCodec.export(habits, now: now);
    final json = jsonDecode(text) as Map<String, Object?>;
    expect(json['app'], 'TrackFlow');
    expect(json['schemaVersion'], 2);

    final parsed = BackupCodec.parse(text, now: now);
    expect(parsed.habits.map((h) => h.id), ['a', 'b']);
    expect(parsed.habits[1].targetPerDay, 8);
  });

  test('a backup exported by app 1.0.0 is accepted', () {
    final raw = File('test/fixtures/backup_v1.json').readAsStringSync();
    expect(BackupCodec.parse(raw, now: now).habits, hasLength(3));
  });

  test('a bare 1.0.0 storage list is accepted', () {
    final raw = File('test/fixtures/habits_v1.json').readAsStringSync();
    expect(BackupCodec.parse(raw, now: now).habits, hasLength(3));
  });

  test('an empty backup is valid (the UI asks before replacing habits)', () {
    expect(BackupCodec.parse('{"habits": []}', now: now).habits, isEmpty);
  });

  test('rejects text that is not a backup', () {
    expect(
      () => BackupCodec.parse('hello', now: now),
      throwsProblem(BackupProblem.notABackup),
    );
    expect(
      () => BackupCodec.parse('{"habits": 3}', now: now),
      throwsProblem(BackupProblem.notABackup),
    );
    expect(
      () => BackupCodec.parse('{"schemaVersion": "2", "habits": []}', now: now),
      throwsProblem(BackupProblem.notABackup),
    );
  });

  test('rejects a backup from a newer app version', () {
    expect(
      () => BackupCodec.parse('{"schemaVersion": 3, "habits": []}', now: now),
      throwsProblem(BackupProblem.newerVersion),
    );
  });

  test('rejects the whole backup if one habit is unreadable or duplicated', () {
    expect(
      () => BackupCodec.parse(
        '{"habits": [{"id": "a", "title": "A"}, {"title": "x"}]}',
        now: now,
      ),
      throwsProblem(BackupProblem.unreadableHabit),
    );
    expect(
      () => BackupCodec.parse(
        '{"habits": [{"id": "a", "title": "A"}, {"id": "a", "title": "B"}]}',
        now: now,
      ),
      throwsProblem(BackupProblem.duplicateHabit),
    );
  });
}
