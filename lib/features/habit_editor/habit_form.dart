/// Validation rules of the habit editor, kept free of widgets so they can be
/// unit-tested. Each returns the message to show, or null when the input is fine.
abstract final class HabitForm {
  static const int maxTitleLength = 40;
  static const int maxTarget = 9999;
  static const int maxCategoryLength = 24;

  static String? validateTitle(String raw) {
    final title = raw.trim();
    if (title.isEmpty) return 'Give the habit a name';
    if (title.length > maxTitleLength) {
      return 'Keep the name under $maxTitleLength characters';
    }
    return null;
  }

  static String? validateTarget(String raw) {
    final target = int.tryParse(raw.trim());
    if (target == null || target < 1 || target > maxTarget) {
      return 'Enter a number from 1 to $maxTarget';
    }
    return null;
  }

  /// Empty means "use the default unit".
  static String unitOrDefault(String raw) {
    final unit = raw.trim();
    return unit.isEmpty ? 'times' : unit;
  }
}
