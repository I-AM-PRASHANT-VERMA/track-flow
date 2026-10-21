import 'dart:async';

import 'package:flutter/services.dart';

/// Tactile feedback. Fire-and-forget on purpose: a vibration that fails or is
/// turned off must never delay or break the tap that triggered it.
abstract final class Haptics {
  static void selection() => unawaited(HapticFeedback.selectionClick());

  static void light() => unawaited(HapticFeedback.lightImpact());

  static void medium() => unawaited(HapticFeedback.mediumImpact());

  static void heavy() => unawaited(HapticFeedback.heavyImpact());
}
