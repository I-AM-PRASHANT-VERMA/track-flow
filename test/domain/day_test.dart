import 'package:flutter_test/flutter_test.dart';
import 'package:track_flow/domain/day.dart';

void main() {
  group('Day', () {
    test('key is zero-padded yyyy-MM-dd and round-trips', () {
      final day = Day(2026, 3, 9);
      expect(day.key, '2026-03-09');
      expect(Day.tryParseKey('2026-03-09'), day);
    });

    test('tryParseKey rejects malformed and impossible dates', () {
      expect(Day.tryParseKey('garbage'), isNull);
      expect(Day.tryParseKey('2026-3-9'), isNull);
      expect(Day.tryParseKey('2026-02-30'), isNull);
      expect(Day.tryParseKey('2026-03-09T10:00:00'), isNull);
    });

    test('addDays crosses month, year and leap-day boundaries', () {
      expect(Day(2026, 1, 1).addDays(-1), Day(2025, 12, 31));
      expect(Day(2028, 2, 28).addDays(1), Day(2028, 2, 29));
      expect(Day(2026, 3, 31).addDays(1), Day(2026, 4, 1));
    });

    test(
      'stepping across daylight-saving dates yields distinct consecutive days',
      () {
        // 2026-03-08 and 2026-11-01 are DST changes in the US; 2026-03-29 and
        // 2026-10-25 in Europe. Day math must not depend on the host time zone.
        for (final pivot in [
          Day(2026, 3, 8),
          Day(2026, 3, 29),
          Day(2026, 10, 25),
          Day(2026, 11, 1),
        ]) {
          final keys = {for (var i = -3; i <= 3; i++) pivot.addDays(i).key};
          expect(keys, hasLength(7), reason: 'around $pivot');
          expect(pivot.addDays(1).daysSince(pivot), 1);
        }
      },
    );

    test('weekday and startOfWeek follow ISO (Monday = 1)', () {
      final wednesday = Day(2026, 10, 21);
      expect(wednesday.weekday, DateTime.wednesday);
      expect(wednesday.startOfWeek, Day(2026, 10, 19));
      expect(Day(2026, 10, 19).startOfWeek, Day(2026, 10, 19));
      expect(Day(2026, 10, 25).startOfWeek, Day(2026, 10, 19));
    });

    test('of() takes the calendar day of a local moment', () {
      expect(Day.of(DateTime(2026, 10, 21, 23, 59)), Day(2026, 10, 21));
      expect(Day.of(DateTime(2026, 10, 22, 0, 0, 1)), Day(2026, 10, 22));
    });
  });
}
