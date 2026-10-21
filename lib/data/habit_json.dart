import '../domain/day.dart';
import '../domain/habit.dart';

/// JSON mapping for [Habit], shared by local storage and backups.
///
/// Schema versions (docs/engineering/COMPATIBILITY.md):
/// - 1 (app 1.0.0): enums stored by index.
/// - 2: enums stored by name, so reordering or adding an enum value is safe.
/// Decoding accepts both versions; encoding always writes [currentSchema].
abstract final class HabitJson {
  static const int currentSchema = 2;

  static Map<String, Object?> encode(Habit habit) => {
    'id': habit.id,
    'title': habit.title,
    'category': habit.category,
    'iconCode': habit.iconKey,
    'colorValue': habit.colorValue,
    'type': habit.type.name,
    'timeOfDay': habit.timeOfDay.name,
    'targetPerDay': habit.targetPerDay,
    'unit': habit.unit,
    'scheduledDays': habit.scheduledDays,
    'logs': habit.logs,
    'createdAt': habit.createdAt.toIso8601String(),
    'isArchived': habit.isArchived,
  };

  /// Returns null when [json] cannot be a habit (no id or title). Optional
  /// fields that are missing or malformed fall back to the 1.0.0 defaults, and
  /// log entries with a bad day key or a non-positive count are dropped.
  static Habit? decode(Object? json, {required DateTime fallbackCreatedAt}) {
    if (json is! Map<String, Object?>) return null;
    final id = json['id'];
    final title = json['title'];
    if (id is! String || id.isEmpty || title is! String) return null;

    return Habit(
      id: id,
      title: title,
      category: _string(json['category']) ?? 'General',
      iconKey: _string(json['iconCode']) ?? '⚡',
      colorValue: _int(json['colorValue']) ?? 0xFF10B981,
      type: _enum(HabitType.values, json['type'], HabitType.boolean),
      timeOfDay: _enum(
        HabitTimeOfDay.values,
        json['timeOfDay'],
        HabitTimeOfDay.anytime,
      ),
      targetPerDay: _int(json['targetPerDay']) ?? 1,
      unit: _string(json['unit']) ?? 'times',
      scheduledDays: _days(json['scheduledDays']),
      logs: _logs(json['logs']),
      createdAt: _date(json['createdAt']) ?? fallbackCreatedAt,
      isArchived: json['isArchived'] == true,
    );
  }

  static String? _string(Object? value) => value is String ? value : null;

  static int? _int(Object? value) => value is num ? value.toInt() : null;

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;

  /// Accepts the enum's index (schema 1) or name (schema 2).
  static T _enum<T extends Enum>(List<T> values, Object? raw, T fallback) {
    if (raw is int && raw >= 0 && raw < values.length) return values[raw];
    if (raw is String) {
      for (final value in values) {
        if (value.name == raw) return value;
      }
    }
    return fallback;
  }

  static List<int>? _days(Object? raw) {
    if (raw is! List<Object?>) return null;
    return [
      for (final day in raw)
        if (day is int) day,
    ];
  }

  static Map<String, int> _logs(Object? raw) {
    if (raw is! Map<String, Object?>) return const {};
    return {
      for (final entry in raw.entries)
        if (Day.tryParseKey(entry.key) != null &&
            entry.value is num &&
            (entry.value! as num) > 0)
          entry.key: (entry.value! as num).toInt(),
    };
  }
}
