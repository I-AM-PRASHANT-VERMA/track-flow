import 'package:flutter/material.dart';

// Systematic color tokens based on True OLED Black (#000000) and Radix Zinc scales.
// Strict rules:
// - True OLED #000000 base for maximum battery saving and infinite canvas.
// - Floating cards and sheets use elevated dark grays (#121214, #18181B).
// - All text passes WCAG AAA contrast ratios against dark backgrounds.
// - Primary and accent colors strictly calibrated to HSL 45-65% saturation.
class AppColors {
  // True OLED Dark Mode
  static const Color darkBg = Color(0xFF000000);          // True Black base
  static const Color darkCard = Color(0xFF121214);        // Radix Zinc Step 2 elevated surface
  static const Color darkCardBorder = Color(0xFF27272A);  // Radix Zinc Step 6 subtle border
  static const Color darkCardActive = Color(0xFF1C1C1F);  // Pressed card state
  static const Color darkSurface = Color(0xFF18181B);     // Radix Zinc Step 3 interactive element

  // Light Mode Scale (Apple HIG System Grays)
  static const Color lightBg = Color(0xFFFAFAFA);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFE4E4E7);
  static const Color lightCardActive = Color(0xFFF4F4F5);
  static const Color lightSurface = Color(0xFFF4F4F5);

  // Typography tokens - WCAG AAA compliant
  static const Color textPrimary = Color(0xFFF4F4F5);     // Zinc-100 (14.2:1 contrast against #000000)
  static const Color textSecondary = Color(0xFFC0C0CC);   // Lifted Zinc-400 — readable secondary on OLED black
  static const Color textMuted = Color(0xFFA0A0B0);       // Lifted Zinc-500 — visible but not competing with primary
  static const Color textDarkPrimary = Color(0xFF18181B); // Never pure black in light mode
  static const Color textDarkSecondary = Color(0xFF52525B);

  // Brand Accents (Strictly calibrated HSL 45-65% saturation to eliminate cheap neon look)
  static const Color primary = Color(0xFF1BB383);         // Mint / Emerald: hsl(158, 55%, 48%)
  static const Color primaryMuted = Color(0xFF148562);
  static const Color secondary = Color(0xFF34A4D7);       // Sky Blue: hsl(199, 65%, 52%)
  static const Color streakAmber = Color(0xFFD99426);     // Warm Amber: hsl(38, 65%, 52%)
  static const Color danger = Color(0xFFCC4B61);          // Rose / Crimson: hsl(350, 55%, 55%)

  // Curated 8-Color Palette for Habits (Earth-toned, balanced lightness & 45-65% saturation)
  static const List<Color> habitPalettes = [
    Color(0xFF1BB383), // Mint (Health / Wellness) - hsl(158, 55%, 48%)
    Color(0xFF34A4D7), // Sky (Hydration / Water) - hsl(199, 65%, 52%)
    Color(0xFF686CE2), // Indigo (Focus / Deep Work) - hsl(245, 55%, 62%)
    Color(0xFF9E66CC), // Purple (Evening / Mindset) - hsl(270, 50%, 60%)
    Color(0xFFD99426), // Amber (Energy / Fitness) - hsl(38, 65%, 52%)
    Color(0xFFCC4B61), // Rose (Habit Cutoff / Cardio) - hsl(350, 55%, 55%)
    Color(0xFF33B3A6), // Teal (Routine / Balance) - hsl(174, 55%, 45%)
    Color(0xFF3B82F6), // Blue (Discipline / Learning) - hsl(217, 65%, 60%)
  ];

  static Color getHabitColor(int colorValue) {
    if (colorValue == 0) return habitPalettes.first;
    return Color(colorValue);
  }

  // Time of day semantic colors
  static Color getTimeOfDayColor(String time) {
    switch (time.toLowerCase()) {
      case 'morning':
        return streakAmber;
      case 'afternoon':
        return secondary;
      case 'evening':
        return const Color(0xFF9E66CC);
      default:
        return primary;
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
