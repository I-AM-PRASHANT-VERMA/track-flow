import 'day.dart';

enum HabitType { boolean, measurable }

enum HabitTimeOfDay { morning, afternoon, evening, anytime }

/// A tracked routine and its daily log. Immutable: every change returns a copy,
/// so a habit handed to the UI can never change underneath it.
final class Habit {
  Habit({
    required this.id,
    required this.title,
    required this.createdAt,
    this.category = 'General',
    this.iconKey = 'habit',
    this.colorValue = 0xFF1BB383,
    this.type = HabitType.boolean,
    this.timeOfDay = HabitTimeOfDay.anytime,
    int targetPerDay = 1,
    this.unit = 'times',
    Iterable<int>? scheduledDays,
    Map<String, int>? logs,
    this.isArchived = false,
  }) : targetPerDay = targetPerDay < 1 ? 1 : targetPerDay,
       scheduledDays = _normalizeDays(scheduledDays),
       logs = Map.unmodifiable(logs ?? const <String, int>{});

  static const List<int> everyDay = [1, 2, 3, 4, 5, 6, 7];

  final String id;
  final String title;
  final String category;
  final String iconKey;
  final int colorValue;
  final HabitType type;
  final HabitTimeOfDay timeOfDay;

  /// At least 1, so "zero progress" can never count as done.
  final int targetPerDay;
  final String unit;

  /// ISO weekdays (1 = Monday ... 7 = Sunday), sorted, never empty.
  final List<int> scheduledDays;

  /// Day key (`yyyy-MM-dd`) to the amount logged that day.
  final Map<String, int> logs;
  final DateTime createdAt;
  final bool isArchived;

  bool get isActive => !isArchived;

  bool isScheduledOn(Day day) => scheduledDays.contains(day.weekday);

  int progressOn(Day day) => logs[day.key] ?? 0;

  bool isCompletedOn(Day day) => progressOn(day) >= targetPerDay;

  /// A copy with [count] logged on [day]; zero or less removes the entry.
  Habit withProgress(Day day, int count) {
    final next = Map<String, int>.of(logs);
    if (count > 0) {
      next[day.key] = count;
    } else {
      next.remove(day.key);
    }
    return copyWith(logs: next);
  }

  Habit copyWith({
    String? title,
    String? category,
    String? iconKey,
    int? colorValue,
    HabitType? type,
    HabitTimeOfDay? timeOfDay,
    int? targetPerDay,
    String? unit,
    Iterable<int>? scheduledDays,
    Map<String, int>? logs,
    bool? isArchived,
  }) {
    return Habit(
      id: id,
      createdAt: createdAt,
      title: title ?? this.title,
      category: category ?? this.category,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
      type: type ?? this.type,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      targetPerDay: targetPerDay ?? this.targetPerDay,
      unit: unit ?? this.unit,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      logs: logs ?? this.logs,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  static List<int> _normalizeDays(Iterable<int>? days) {
    final valid =
        (days ?? everyDay).where((d) => d >= 1 && d <= 7).toSet().toList()
          ..sort();
    return List.unmodifiable(valid.isEmpty ? everyDay : valid);
  }
}
