import 'package:flutter/material.dart';

// Strict 8-point spatial grid system and 48x48 dp accessibility hit targets
class AppSpacing {
  // 8-Point Scale
  static const double p4 = 4.0;
  static const double p8 = 8.0;
  static const double p12 = 12.0; // Half-step allowed for dense tables/chips
  static const double p16 = 16.0;
  static const double p24 = 24.0;
  static const double p32 = 32.0;
  static const double p40 = 40.0;
  static const double p48 = 48.0;

  // Minimum touch target sizes per Apple HIG (44pt) and Google Material (48dp)
  static const double minTouchTarget = 48.0;
}

// Invisible touch target wrapper guaranteeing 48x48 dp hit box around smaller visual widgets
class TouchTarget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double minWidth;
  final double minHeight;
  final BorderRadius? borderRadius;

  const TouchTarget({
    super.key,
    required this.child,
    this.onTap,
    this.minWidth = AppSpacing.minTouchTarget,
    this.minHeight = AppSpacing.minTouchTarget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minWidth,
        minHeight: minHeight,
      ),
      child: Center(child: child),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}
