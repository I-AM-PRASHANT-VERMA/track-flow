import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Gives a small visual a hit area of at least [minWidth] x [minHeight]
/// (48 dp by default, Material's minimum) without changing how it looks.
class TouchTarget extends StatelessWidget {
  const TouchTarget({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.minWidth = AppSpacing.minTouchTarget,
    this.minHeight = AppSpacing.minTouchTarget,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final double minWidth;
  final double minHeight;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final content = ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth, minHeight: minHeight),
      child: Center(child: child),
    );
    if (onTap == null) return content;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(borderRadius: borderRadius, onTap: onTap, child: content),
      ),
    );
  }
}
