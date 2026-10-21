import '../domain/habit.dart';

/// What a read from storage produced.
final class StoredHabits {
  const StoredHabits(this.habits, {this.hadUnreadableData = false});

  final List<Habit> habits;

  /// Some stored data could not be read. A raw copy was kept and nothing that
  /// could still be recovered was overwritten.
  final bool hadUnreadableData;
}

/// Persistence service for habits (Flutter architecture guide: a service wraps
/// one external API; the repository decides what to store and when).
abstract interface class HabitStore {
  Future<StoredHabits> read();

  Future<void> write(List<Habit> habits);
}
