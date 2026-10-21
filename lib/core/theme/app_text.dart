import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// Text styles used in more than one feature.
abstract final class AppText {
  /// Small all-caps section label, e.g. "MORNING RITUALS".
  static const TextStyle sectionLabel = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.6,
    color: AppColors.textMuted,
  );

  /// Smaller caption label inside cards, e.g. "CHOOSE ICON".
  static const TextStyle fieldLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.6,
    color: AppColors.textMuted,
  );

  static const TextStyle sheetTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 12,
    color: AppColors.textMuted,
  );
}
