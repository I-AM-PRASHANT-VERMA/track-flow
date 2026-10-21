import 'package:flutter/material.dart';

/// One icon a user can pick for a habit.
final class HabitIconChoice {
  const HabitIconChoice(this.key, this.label, this.icon);

  /// Stored in the habit; never rename an existing key.
  final String key;
  final String label;
  final IconData icon;
}

/// Maps stored icon keys (including emoji keys written by app 1.0.0) to icons.
abstract final class HabitIcons {
  static const List<HabitIconChoice> choices = [
    HabitIconChoice('habit', 'General Habit', Icons.check_circle_rounded),
    HabitIconChoice('target', 'Target / Goal', Icons.track_changes_rounded),
    HabitIconChoice('star', 'Priority', Icons.star_rounded),
    HabitIconChoice('timer', 'Deep Work', Icons.timer_rounded),
    HabitIconChoice('code', 'Coding', Icons.terminal_rounded),
    HabitIconChoice('book', 'Reading', Icons.auto_stories_rounded),
    HabitIconChoice('fitness', 'Cardio / Run', Icons.directions_run_rounded),
    HabitIconChoice('gym', 'Workout', Icons.fitness_center_rounded),
    HabitIconChoice('water', 'Hydration', Icons.water_drop_rounded),
    HabitIconChoice('mind', 'Meditation', Icons.spa_rounded),
    HabitIconChoice('sleep', 'Wind Down', Icons.bedtime_rounded),
    HabitIconChoice('art', 'Creativity', Icons.palette_rounded),
    HabitIconChoice('walk', 'Walking', Icons.hiking_rounded),
  ];

  static const Map<String, IconData> _aliases = {
    'check': Icons.check_circle_rounded,
    'task': Icons.check_circle_rounded,
    'done': Icons.check_circle_rounded,
    'goal': Icons.track_changes_rounded,
    'bolt': Icons.bolt_rounded,
    'lightning': Icons.bolt_rounded,
    'energy': Icons.bolt_rounded,
    'hydration': Icons.water_drop_rounded,
    '💧': Icons.water_drop_rounded,
    'run': Icons.directions_run_rounded,
    'cardio': Icons.directions_run_rounded,
    'workout': Icons.directions_run_rounded,
    '🏃': Icons.directions_run_rounded,
    'coding': Icons.terminal_rounded,
    'laptop': Icons.terminal_rounded,
    'dev': Icons.terminal_rounded,
    '💻': Icons.terminal_rounded,
    'read': Icons.auto_stories_rounded,
    'reading': Icons.auto_stories_rounded,
    'books': Icons.auto_stories_rounded,
    '📚': Icons.auto_stories_rounded,
    'moon': Icons.bedtime_rounded,
    'night': Icons.bedtime_rounded,
    'cutoff': Icons.bedtime_rounded,
    '📵': Icons.bedtime_rounded,
    'meditate': Icons.spa_rounded,
    'meditation': Icons.spa_rounded,
    'breathe': Icons.spa_rounded,
    'zen': Icons.spa_rounded,
    '🧘': Icons.spa_rounded,
    'weights': Icons.fitness_center_rounded,
    'dumbbell': Icons.fitness_center_rounded,
    'time': Icons.timer_rounded,
    'focus': Icons.timer_rounded,
    'creative': Icons.palette_rounded,
    'design': Icons.palette_rounded,
    'hiking': Icons.hiking_rounded,
    'music': Icons.music_note_rounded,
    'audio': Icons.music_note_rounded,
  };

  static IconData of(String key) {
    final normalized = key.toLowerCase();
    for (final choice in choices) {
      if (choice.key == normalized) return choice.icon;
    }
    return _aliases[normalized] ?? Icons.check_circle_rounded;
  }
}
