import 'package:flutter/material.dart';

// Systematic color tokens based on Radix UI Colors and Tailwind CSS Slate scales.
// Strict rules: No pure black (#000000), no pure white (#FFFFFF), HSL saturation 45-65%.
class AppColors {
  // Radix Dark Slate Scale (2-3% indigo tint for a cohesive, soothing tone)
  static const Color darkBg = Color(0xFF0B0F17);          // Step 1: Deep canvas
  static const Color darkCard = Color(0xFF131926);        // Step 2/3: Card surface
  static const Color darkCardBorder = Color(0xFF20293A);  // Step 6: Crisp subtle border
  static const Color darkCardActive = Color(0xFF1A2234);  // Step 4/5: Active / Pressed state
  static const Color darkSurface = Color(0xFF182030);     // Step 3: Interactive elements

  // Light Mode Scale (Tailwind Slate)
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFE2E8F0);
  static const Color lightCardActive = Color(0xFFF1F5F9);
  static const Color lightSurface = Color(0xFFF1F5F9);

  // Typography tokens - soothing contrast to prevent eye fatigue
  static const Color textPrimary = Color(0xFFF1F5F9);     // Tailwind slate-100 (never pure #FFFFFF)
  static const Color textSecondary = Color(0xFF94A3B8);   // Tailwind slate-400
  static const Color textMuted = Color(0xFF64748B);       // Tailwind slate-500
  static const Color textDarkPrimary = Color(0xFF0F172A);
  static const Color textDarkSecondary = Color(0xFF475569);

  // Brand Accents (Tamed HSL saturation 55-65%, avoiding eye-straining neons)
  static const Color primary = Color(0xFF10B981);         // Radix Emerald / Tailwind 500
  static const Color primaryMuted = Color(0xFF059669);
  static const Color secondary = Color(0xFF0EA5E9);       // Sky Blue
  static const Color streakAmber = Color(0xFFF59E0B);     // Warm Amber
  static const Color danger = Color(0xFFF43F5E);          // Rose Red

  // Curated 8-Color Palette for Habits (Earth-toned, balanced lightness & saturation)
  static const List<Color> habitPalettes = [
    Color(0xFF10B981), // Emerald (Health / Wellness)
    Color(0xFF0EA5E9), // Sky (Hydration / Water)
    Color(0xFF6366F1), // Indigo (Focus / Deep Work)
    Color(0xFFA855F7), // Purple (Evening / Mindset)
    Color(0xFFF59E0B), // Amber (Energy / Fitness)
    Color(0xFFF43F5E), // Rose (Habit Cutoff / Cardio)
    Color(0xFF14B8A6), // Teal (Routine / Balance)
    Color(0xFF3B82F6), // Blue (Discipline / Learning)
  ];

  static Color getHabitColor(int colorValue) {
    if (colorValue == 0) return habitPalettes.first;
    return Color(colorValue);
  }

  // Time of day semantic colors
  static Color getTimeOfDayColor(String time) {
    switch (time.toLowerCase()) {
      case 'morning':
        return const Color(0xFFF59E0B); // Amber
      case 'afternoon':
        return const Color(0xFF0EA5E9); // Sky
      case 'evening':
        return const Color(0xFFA855F7); // Purple
      default:
        return const Color(0xFF10B981); // Emerald
    }
  }
}

// Crisp vector icon mapper replacing cheap emojis
class AppIcons {
  static IconData getIcon(String code) {
    switch (code.toLowerCase()) {
      case 'water':
      case 'hydration':
      case '💧':
        return Icons.water_drop_rounded;
      case 'fitness':
      case 'run':
      case 'cardio':
      case 'workout':
      case '🏃':
        return Icons.directions_run_rounded;
      case 'code':
      case 'coding':
      case 'laptop':
      case 'dev':
      case '💻':
        return Icons.terminal_rounded;
      case 'book':
      case 'read':
      case 'reading':
      case 'books':
      case '📚':
        return Icons.auto_stories_rounded;
      case 'sleep':
      case 'moon':
      case 'night':
      case 'cutoff':
      case '📵':
        return Icons.bedtime_rounded;
      case 'mind':
      case 'meditate':
      case 'meditation':
      case 'breathe':
      case 'zen':
      case '🧘':
        return Icons.spa_rounded;
      case 'gym':
      case 'weights':
      case 'dumbbell':
        return Icons.fitness_center_rounded;
      case 'timer':
      case 'time':
      case 'focus':
        return Icons.timer_rounded;
      case 'art':
      case 'creative':
      case 'design':
        return Icons.palette_rounded;
      case 'walk':
      case 'hiking':
        return Icons.hiking_rounded;
      case 'music':
      case 'audio':
        return Icons.music_note_rounded;
      default:
        return Icons.bolt_rounded;
    }
  }

  // Pre-curated vector icon options for habit creator sheet
  static const List<Map<String, dynamic>> availableIcons = [
    {'key': 'water', 'label': 'Hydration', 'icon': Icons.water_drop_rounded},
    {'key': 'fitness', 'label': 'Cardio / Run', 'icon': Icons.directions_run_rounded},
    {'key': 'gym', 'label': 'Workout', 'icon': Icons.fitness_center_rounded},
    {'key': 'code', 'label': 'Coding', 'icon': Icons.terminal_rounded},
    {'key': 'book', 'label': 'Reading', 'icon': Icons.auto_stories_rounded},
    {'key': 'mind', 'label': 'Meditation', 'icon': Icons.spa_rounded},
    {'key': 'sleep', 'label': 'Wind Down', 'icon': Icons.bedtime_rounded},
    {'key': 'timer', 'label': 'Deep Work', 'icon': Icons.timer_rounded},
    {'key': 'art', 'label': 'Creativity', 'icon': Icons.palette_rounded},
    {'key': 'walk', 'label': 'Walking', 'icon': Icons.hiking_rounded},
  ];
}
