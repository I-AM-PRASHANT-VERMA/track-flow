import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_flow/data/habit_repository.dart';
import 'package:track_flow/domain/day.dart';
import 'package:track_flow/domain/habit.dart';

import '../support/in_memory_habit_store.dart';

void main() {
  final today = Day(2026, 3, 9);
  Habit habit(String id) =>
      Habit(id: id, title: id, createdAt: DateTime(2026), targetPerDay: 8);

  Future<(HabitRepository, InMemoryHabitStore)> loaded(
    List<Habit> habits,
  ) async {
    final store = InMemoryHabitStore(habits);
    final repository = HabitRepository(store);
    await repository.load();
    return (repository, store);
  }

  test('two quick taps before any write finishes are both kept', () async {
    final (repository, store) = await loaded([habit('water')]);
    store.gate = Completer<void>();

    repository.setProgress(
      'water',
      today,
      repository.find('water')!.progressOn(today) + 1,
    );
    repository.setProgress(
      'water',
      today,
      repository.find('water')!.progressOn(today) + 1,
    );
    expect(repository.find('water')!.progressOn(today), 2);

    store.gate!.complete();
    await repository.flush();
    expect(store.saved.single.progressOn(today), 2);
  });

  test(
    'a burst of changes while a write is running costs only one more write',
    () async {
      final (repository, store) = await loaded([habit('water')]);
      store.gate = Completer<void>();

      for (var count = 1; count <= 5; count++) {
        repository.setProgress('water', today, count);
      }
      store.gate!.complete();
      await repository.flush();

      expect(store.writes, 2);
      expect(store.saved.single.progressOn(today), 5);
    },
  );

  test('changes to different habits do not overwrite each other', () async {
    final (repository, store) = await loaded([habit('a'), habit('b')]);
    repository.setProgress('a', today, 3);
    repository.setProgress('b', today, 4);
    await repository.flush();
    expect(store.saved.map((h) => h.progressOn(today)), [3, 4]);
  });

  test('remove then restore puts the habit back at its position', () async {
    final (repository, store) = await loaded([
      habit('a'),
      habit('b'),
      habit('c'),
    ]);
    final removed = repository.remove('b')!;
    expect(repository.habits.map((h) => h.id), ['a', 'c']);

    repository.restore(removed);
    await repository.flush();
    expect(repository.habits.map((h) => h.id), ['a', 'b', 'c']);
    expect(store.saved.map((h) => h.id), ['a', 'b', 'c']);
  });

  test(
    'add puts the new habit first; replaceAll returns the previous list',
    () async {
      final (repository, _) = await loaded([habit('a')]);
      repository.add(habit('new'));
      expect(repository.habits.first.id, 'new');

      final previous = repository.replaceAll([habit('z')]);
      expect(previous.map((h) => h.id), ['new', 'a']);
      expect(repository.habits.single.id, 'z');
    },
  );

  test('updating a habit that no longer exists changes nothing', () async {
    final (repository, store) = await loaded([habit('a')]);
    repository.update(habit('ghost'));
    repository.setProgress('ghost', today, 1);
    await repository.flush();
    expect(store.writes, 0);
    expect(repository.habits.single.id, 'a');
  });

  test('a failed write is reported and the next change retries with the newest state', () async {
    final (repository, store) = await loaded([habit('a')]);
    final reported = <FlutterErrorDetails>[];
    final previousHandler = FlutterError.onError;
    FlutterError.onError = reported.add;
    addTearDown(() => FlutterError.onError = previousHandler);

    store.failNextWrite = StateError('disk full');
    repository.setProgress('a', today, 1);
    await repository.flush();
    expect(repository.lastWriteError, isA<StateError>());
    expect(reported, hasLength(1));

    repository.setProgress('a', today, 2);
    await repository.flush();
    expect(repository.lastWriteError, isNull);
    expect(store.saved.single.progressOn(today), 2);
  });

  test('listeners hear about every change immediately', () async {
    final (repository, _) = await loaded([habit('a')]);
    var notifications = 0;
    repository.addListener(() => notifications++);
    repository.setProgress('a', today, 1);
    repository.remove('a');
    expect(notifications, 2);
  });

  test('load reports unreadable stored data', () async {
    final repository = HabitRepository(InMemoryHabitStore(const [], true));
    await repository.load();
    expect(repository.hadUnreadableData, isTrue);
  });
}
