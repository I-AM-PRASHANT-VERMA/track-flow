import 'package:flutter/foundation.dart';

import '../domain/day.dart';
import '../domain/habit.dart';
import 'habit_store.dart';

/// A habit removed by [HabitRepository.remove], kept so the removal can be undone.
final class RemovedHabit {
  const RemovedHabit(this.habit, this.index);

  final Habit habit;
  final int index;
}

/// Single source of truth for habits (Flutter architecture guide: views read
/// from repositories; repositories talk to services).
///
/// Every change is applied in memory first and listeners are notified at once.
/// Persistence follows in the background, one write at a time, and each write
/// stores the newest state, so quick successive taps can never overwrite each
/// other and a burst of taps costs one or two writes, not one per tap.
final class HabitRepository extends ChangeNotifier {
  HabitRepository(this._store);

  final HabitStore _store;

  List<Habit> _habits = const [];
  bool _hadUnreadableData = false;
  Object? _lastWriteError;
  Future<void>? _writing;
  bool _dirty = false;

  /// Unmodifiable, newest first.
  List<Habit> get habits => _habits;

  /// Loading found data it could not read (a raw copy was kept).
  bool get hadUnreadableData => _hadUnreadableData;

  /// The error of the last failed write, cleared by the next successful one.
  Object? get lastWriteError => _lastWriteError;

  Future<void> load() async {
    final stored = await _store.read();
    _habits = List.unmodifiable(stored.habits);
    _hadUnreadableData = stored.hadUnreadableData;
    notifyListeners();
  }

  Habit? find(String id) {
    for (final habit in _habits) {
      if (habit.id == id) return habit;
    }
    return null;
  }

  void add(Habit habit) => _commit([habit, ..._habits]);

  /// Replaces the habit with the same id; does nothing if it no longer exists.
  void update(Habit habit) {
    final index = _indexOf(habit.id);
    if (index < 0) return;
    _commit([..._habits]..[index] = habit);
  }

  void setProgress(String id, Day day, int count) {
    final habit = find(id);
    if (habit != null) update(habit.withProgress(day, count));
  }

  RemovedHabit? remove(String id) {
    final index = _indexOf(id);
    if (index < 0) return null;
    final removed = RemovedHabit(_habits[index], index);
    _commit([..._habits]..removeAt(index));
    return removed;
  }

  void restore(RemovedHabit removed) {
    if (_indexOf(removed.habit.id) >= 0) return;
    final index = removed.index.clamp(0, _habits.length);
    _commit([..._habits]..insert(index, removed.habit));
  }

  /// Replaces every habit (backup restore) and returns the previous list for undo.
  List<Habit> replaceAll(List<Habit> habits) {
    final previous = _habits;
    _commit(habits);
    return previous;
  }

  /// Completes when everything changed so far has been written.
  Future<void> flush() async {
    while (_writing != null) {
      await _writing;
    }
  }

  int _indexOf(String id) => _habits.indexWhere((h) => h.id == id);

  void _commit(List<Habit> next) {
    _habits = List.unmodifiable(next);
    notifyListeners();
    _dirty = true;
    _writing ??= _drainWrites();
  }

  Future<void> _drainWrites() async {
    try {
      while (_dirty) {
        _dirty = false;
        try {
          await _store.write(_habits);
          _lastWriteError = null;
        } catch (error, stack) {
          _lastWriteError = error;
          FlutterError.reportError(
            FlutterErrorDetails(exception: error, stack: stack, library: 'habit repository'),
          );
        }
      }
    } finally {
      _writing = null;
    }
  }
}
