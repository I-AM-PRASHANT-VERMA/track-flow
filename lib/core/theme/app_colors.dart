import 'package:flutter/painting.dart';

/// Colour tokens for the true-black OLED theme (the app has no light mode).
abstract final class AppColors {
  // Surfaces
  static const Color background = Color(0xFF000000);
  static const Color card = Color(0xFF121214);
  static const Color cardBorder = Color(0xFF27272A);
  static const Color surface = Color(0xFF18181B);
  static const Color track = Color(0xFF1E1E22);

  // Grid cells (matrix and heatmap)
  static const Color cellEmpty = Color(0xFF161619);
  static const Color cellBorder = Color(0xFF333338);
  static const Color cellRestBorder = Color(0xFF26262B);

  // Text
  static const Color textPrimary = Color(0xFFF4F4F5);
  static const Color textSecondary = Color(0xFFC0C0CC);
  static const Color textMuted = Color(0xFFA0A0B0);
  static const Color textFaint = Color(0x3DFFFFFF);

  // Accents
  static const Color primary = Color(0xFF1BB383);
  static const Color onPrimary = Color(0xFF0B0F17);
  static const Color secondary = Color(0xFF34A4D7);
  static const Color evening = Color(0xFF9E66CC);
  static const Color streakAmber = Color(0xFFD99426);
  static const Color danger = Color(0xFFCC4B61);

  /// Colours a user can pick for a habit.
  static const List<Color> habitPalette = [
    Color(0xFF1BB383), // mint
    Color(0xFF34A4D7), // sky
    Color(0xFF686CE2), // indigo
    Color(0xFF9E66CC), // purple
    Color(0xFFD99426), // amber
    Color(0xFFCC4B61), // rose
    Color(0xFF33B3A6), // teal
    Color(0xFF3B82F6), // blue
  ];

  static Color habitColor(int value) => value == 0 ? habitPalette.first : Color(value);
}
