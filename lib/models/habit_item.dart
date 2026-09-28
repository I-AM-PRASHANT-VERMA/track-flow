import 'package:intl/intl.dart';

enum HabitType { boolean, measurable }

enum HabitTimeOfDay { morning, afternoon, evening, anytime }

// Core entity representing a tracked daily routine or habit
class HabitItem {
  final String id;
  final String title;
  final String category;
  final String iconCode;
  final int colorValue;
  final HabitType type;
  final HabitTimeOfDay timeOfDay;
  final int targetPerDay;
  final String unit;
  final List<int> scheduledDays; // 1 = Mon, 7 = Sun
  final Map<String, int> logs;   // 'yyyy-MM-dd' -> count
  final DateTime createdAt;
  final bool isArchived;

  HabitItem({
    required this.id,
    required this.title,
    this.category = 'General',
    this.iconCode = '⚡',
    this.colorValue = 0xFF10B981,
    this.type = HabitType.boolean,
    this.timeOfDay = HabitTimeOfDay.anytime,
    this.targetPerDay = 1,
    this.unit = 'times',
    List<int>? scheduledDays,
    Map<String, int>? logs,
    DateTime? createdAt,
    this.isArchived = false,
  })  : scheduledDays = scheduledDays ?? const [1, 2, 3, 4, 5, 6, 7],
        logs = logs ?? const {},
        createdAt = createdAt ?? DateTime.now();

  // Helper date key formatter
  static String dateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Value logged on a specific date
  int progressOn(DateTime date) {
    return logs[dateKey(date)] ?? 0;
  }

  // Check if target was met on a given date
  bool isCompletedOn(DateTime date) {
    return progressOn(date) >= targetPerDay;
  }

  // Today's progress helpers
  int get progressToday => progressOn(DateTime.now());
  bool get isCompletedToday => isCompletedOn(DateTime.now());

  // Calculates current active unbroken streak
  int get currentStreak {
    final now = DateTime.now();
    var checkDate = DateTime(now.year, now.month, now.day);
    var streak = 0;

    // If today is scheduled and completed, start counting from today
    // If today is not completed yet, the streak is still alive if yesterday was completed
    if (scheduledDays.contains(checkDate.weekday)) {
      if (isCompletedOn(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        // Today is pending, step back to yesterday to see if streak is continuing
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    } else {
      // Today is an off-day, check previous days
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    // Walk backwards in time
    while (true) {
      if (scheduledDays.contains(checkDate.weekday)) {
        if (isCompletedOn(checkDate)) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          // Missed a scheduled day, streak breaks
          break;
        }
      } else {
        // Non-scheduled day does not break streak
        checkDate = checkDate.subtract(const Duration(days: 1));
      }

      // Safeguard against infinite loop if created very far back
      if (checkDate.isBefore(createdAt.subtract(const Duration(days: 30)))) {
        break;
      }
    }

    return streak;
  }

  // Computes historical best streak
  int get bestStreak {
    if (logs.isEmpty) return currentStreak;

    final sortedKeys = logs.keys.toList()..sort();
    var best = 0;
    var running = 0;
    DateTime? lastDate;

    for (final key in sortedKeys) {
      if ((logs[key] ?? 0) < targetPerDay) continue;

      final parts = key.split('-').map(int.parse).toList();
      final dt = DateTime(parts[0], parts[1], parts[2]);

      if (lastDate == null) {
        running = 1;
      } else {
        final diff = dt.difference(lastDate).inDays;
        if (diff == 1) {
          running++;
        } else if (diff > 1) {
          running = 1;
        }
      }
      lastDate = dt;
      if (running > best) best = running;
    }

    final curr = currentStreak;
    return curr > best ? curr : best;
  }

  // Completion rate percentage over last 30 scheduled days
  double get completionRateLast30Days {
    final now = DateTime.now();
    var completedCount = 0;
    var scheduledCount = 0;

    for (var i = 0; i < 30; i++) {
      final dt = now.subtract(Duration(days: i));
      if (scheduledDays.contains(dt.weekday)) {
        scheduledCount++;
        if (isCompletedOn(dt)) {
          completedCount++;
        }
      }
    }

    if (scheduledCount == 0) return 0.0;
    return completedCount / scheduledCount;
  }

  // Last 7 days sequence ending with today
  static List<DateTime> get last7Days {
    final now = DateTime.now();
    return List.generate(7, (i) {
      return now.subtract(Duration(days: 6 - i));
    });
  }

  // Copy with updated properties
  HabitItem copyWith({
    String? id,
    String? title,
    String? category,
    String? iconCode,
    int? colorValue,
    HabitType? type,
    HabitTimeOfDay? timeOfDay,
    int? targetPerDay,
    String? unit,
    List<int>? scheduledDays,
    Map<String, int>? logs,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return HabitItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      type: type ?? this.type,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      targetPerDay: targetPerDay ?? this.targetPerDay,
      unit: unit ?? this.unit,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      logs: logs ?? this.logs,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  // Serialization for offline local persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'iconCode': iconCode,
      'colorValue': colorValue,
      'type': type.index,
      'timeOfDay': timeOfDay.index,
      'targetPerDay': targetPerDay,
      'unit': unit,
      'scheduledDays': scheduledDays,
      'logs': logs,
      'createdAt': createdAt.toIso8601String(),
      'isArchived': isArchived,
    };
  }

  factory HabitItem.fromJson(Map<String, dynamic> json) {
    return HabitItem(
      id: json['id'] as String,
      title: json['title'] as String,
      category: (json['category'] as String?) ?? 'General',
      iconCode: (json['iconCode'] as String?) ?? '⚡',
      colorValue: (json['colorValue'] as int?) ?? 0xFF10B981,
      type: HabitType.values[(json['type'] as int?) ?? 0],
      timeOfDay: HabitTimeOfDay.values[(json['timeOfDay'] as int?) ?? 3],
      targetPerDay: (json['targetPerDay'] as int?) ?? 1,
      unit: (json['unit'] as String?) ?? 'times',
      scheduledDays: (json['scheduledDays'] as List<dynamic>?)?.map((e) => e as int).toList() ??
          const [1, 2, 3, 4, 5, 6, 7],
      logs: (json['logs'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as int),
          ) ??
          const {},
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isArchived: (json['isArchived'] as bool?) ?? false,
    );
  }
}
