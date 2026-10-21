import 'dart:async';

import 'package:track_flow/data/habit_store.dart';
import 'package:track_flow/domain/habit.dart';

/// Test double for [HabitStore]: records writes and can hold a write open
/// ([gate]) or fail the next one ([failNextWrite]).
final class InMemoryHabitStore implements HabitStore {
  InMemoryHabitStore([List<Habit> initial = const [], this.hadUnreadableData = false])
    : saved = List.of(initial);

  List<Habit> saved;
  bool hadUnreadableData;
  int writes = 0;
  Completer<void>? gate;
  Object? failNextWrite;

  @override
  Future<StoredHabits> read() async =>
      StoredHabits(List.of(saved), hadUnreadableData: hadUnreadableData);

  @override
  Future<void> write(List<Habit> habits) async {
    writes++;
    final pending = gate;
    if (pending != null) await pending.future;
    final failure = failNextWrite;
    if (failure != null) {
      failNextWrite = null;
      throw failure;
    }
    saved = List.of(habits);
  }
}
