/// 4/8-point spacing scale and minimum touch target sizes.
abstract final class AppSpacing {
  static const double p4 = 4;
  static const double p8 = 8;
  static const double p12 = 12;
  static const double p16 = 16;
  static const double p24 = 24;

  /// Material's 48 dp minimum interactive size.
  static const double minTouchTarget = 48;

  /// Space kept free under scrolling content so the floating button never hides
  /// the last item.
  static const double fabClearance = 128;
}
