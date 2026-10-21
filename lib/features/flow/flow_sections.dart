import '../../domain/habit.dart';

/// Active habits that share a time of day, in Today's Flow order.
final class FlowSection {
  const FlowSection(this.timeOfDay, this.habits);

  final HabitTimeOfDay timeOfDay;
  final List<Habit> habits;
}

/// Groups active habits by time of day in one pass; empty groups are left out
/// and the order inside each group is the repository order (newest first).
List<FlowSection> buildFlowSections(Iterable<Habit> habits) {
  final groups = {for (final time in HabitTimeOfDay.values) time: <Habit>[]};
  for (final habit in habits) {
    if (habit.isActive) groups[habit.timeOfDay]!.add(habit);
  }
  return [
    for (final time in HabitTimeOfDay.values)
      if (groups[time]!.isNotEmpty) FlowSection(time, groups[time]!),
  ];
}
