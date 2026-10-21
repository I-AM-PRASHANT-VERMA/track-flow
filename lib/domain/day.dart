/// A local calendar date without a time of day.
///
/// Habit logs are keyed by calendar day. Stepping through days with
/// `DateTime.subtract(Duration(days: n))` breaks around daylight-saving changes,
/// because a local "day" can last 23 or 25 hours. All day arithmetic therefore
/// goes through this type, which computes on UTC dates where every day is 24 h.
final class Day implements Comparable<Day> {
  /// Normalises overflowing parts, e.g. `Day(2026, 3, 0)` is 2026-02-28.
  factory Day(int year, int month, int day) =>
      Day._fromUtc(DateTime.utc(year, month, day));

  /// The calendar day on which [moment] falls, in the moment's own time zone.
  factory Day.of(DateTime moment) => Day(moment.year, moment.month, moment.day);

  Day._fromUtc(DateTime utc)
    : year = utc.year,
      month = utc.month,
      day = utc.day;

  final int year;
  final int month;
  final int day;

  static final RegExp _keyPattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  /// Parses a `yyyy-MM-dd` storage key; returns null for anything else,
  /// including impossible dates such as `2026-02-30`.
  static Day? tryParseKey(String key) {
    final match = _keyPattern.firstMatch(key);
    if (match == null) return null;
    final year = int.parse(match[1]!);
    final month = int.parse(match[2]!);
    final day = int.parse(match[3]!);
    final parsed = Day(year, month, day);
    final isExact =
        parsed.year == year && parsed.month == month && parsed.day == day;
    return isExact ? parsed : null;
  }

  /// Storage key in the format used by every released data version.
  String get key =>
      '${year.toString().padLeft(4, '0')}-${_two(month)}-${_two(day)}';

  /// ISO weekday: 1 = Monday ... 7 = Sunday.
  int get weekday => _utc.weekday;

  Day addDays(int days) => Day._fromUtc(DateTime.utc(year, month, day + days));

  /// Whole days from [other] to this day (positive when this day is later).
  int daysSince(Day other) => _utc.difference(other._utc).inDays;

  /// Monday of the ISO week containing this day.
  Day get startOfWeek => addDays(1 - weekday);

  DateTime toLocalDateTime() => DateTime(year, month, day);

  bool isBefore(Day other) => compareTo(other) < 0;
  bool isAfter(Day other) => compareTo(other) > 0;

  DateTime get _utc => DateTime.utc(year, month, day);

  static String _two(int value) => value.toString().padLeft(2, '0');

  @override
  int compareTo(Day other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      other is Day &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => key;
}
