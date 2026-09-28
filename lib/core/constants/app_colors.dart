import 'package:flutter/material.dart';

// Color palette tuned for OLED screens with high-contrast accent glows
class AppColors {
  // Deep dark backgrounds
  static const Color darkBg = Color(0xFF080C14);
  static const Color darkCard = Color(0xFF0F172A);
  static const Color darkCardBorder = Color(0xFF1E293B);
  static const Color darkCardActive = Color(0xFF162036);
  static const Color darkSurface = Color(0xFF131D33);

  // Clean light backgrounds
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFE2E8F0);
  static const Color lightCardActive = Color(0xFFF1F5F9);
  static const Color lightSurface = Color(0xFFF1F5F9);

  // Typography tokens
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textDarkPrimary = Color(0xFF0F172A);
  static const Color textDarkSecondary = Color(0xFF475569);

  // Core brand accents
  static const Color primary = Color(0xFF10B981); // Emerald
  static const Color primaryVariant = Color(0xFF059669);
  static const Color secondary = Color(0xFF06B6D4); // Cyan
  static const Color streakOrange = Color(0xFFF59E0B); // Amber
  static const Color danger = Color(0xFFEF4444);

  // Curated habit accent options
  static const List<Color> habitPalettes = [
    Color(0xFF10B981), // Emerald
    Color(0xFF06B6D4), // Cyan
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Violet
    Color(0xFFF59E0B), // Amber
    Color(0xFFF43F5E), // Rose
    Color(0xFF14B8A6), // Teal
    Color(0xFFEC4899), // Pink
  ];

  // Quick fallback if color index is out of bounds
  static Color getHabitColor(int colorValue) {
    if (colorValue == 0) return habitPalettes.first;
    return Color(colorValue);
  }

  // Time of day badge tints
  static Color getTimeOfDayColor(String time) {
    switch (time.toLowerCase()) {
      case 'morning':
        return const Color(0xFFF59E0B);
      case 'afternoon':
        return const Color(0xFF38BDF8);
      case 'evening':
        return const Color(0xFFA855F7);
      default:
        return const Color(0xFF10B981);
    }
  }
}
