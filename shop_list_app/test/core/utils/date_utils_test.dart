import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/core/utils/date_utils.dart';

void main() {
  // ── formatDate ─────────────────────────────────────────────────────────────

  group('AppDateUtils.formatDate', () {
    test('formats a specific date correctly', () {
      final date = DateTime(2026, 3, 2);
      expect(AppDateUtils.formatDate(date), 'Mar 2, 2026');
    });

    test('formats a two-digit day', () {
      final date = DateTime(2026, 12, 25);
      expect(AppDateUtils.formatDate(date), 'Dec 25, 2026');
    });
  });

  // ── formatDateTime ─────────────────────────────────────────────────────────

  group('AppDateUtils.formatDateTime', () {
    test('includes date and time', () {
      final date = DateTime(2026, 3, 2, 15, 45);
      final result = AppDateUtils.formatDateTime(date);
      expect(result, contains('Mar 2, 2026'));
      expect(result, contains('45'));
    });
  });

  // ── formatRelative ─────────────────────────────────────────────────────────

  group('AppDateUtils.formatRelative', () {
    test('returns "Today" for today', () {
      expect(AppDateUtils.formatRelative(DateTime.now()), 'Today');
    });

    test('returns "Yesterday" for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(AppDateUtils.formatRelative(yesterday), 'Yesterday');
    });

    test('returns "Tomorrow" for tomorrow', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(AppDateUtils.formatRelative(tomorrow), 'Tomorrow');
    });

    test('returns short date for same year, more than 1 day away', () {
      final date = DateTime(DateTime.now().year, 6, 15);
      final result = AppDateUtils.formatRelative(date);
      // Should NOT contain the year
      expect(result, isNot(contains(DateTime.now().year.toString())));
    });

    test('returns full date for a different year', () {
      final date = DateTime(2020, 1, 1);
      expect(AppDateUtils.formatRelative(date), 'Jan 1, 2020');
    });
  });

  // ── formatDuration ─────────────────────────────────────────────────────────

  group('AppDateUtils.formatDuration', () {
    test('minutes only', () {
      expect(AppDateUtils.formatDuration(const Duration(minutes: 5)), '5 min');
    });

    test('exactly 1 hour', () {
      expect(
        AppDateUtils.formatDuration(const Duration(hours: 1)),
        '1 hr',
      );
    });

    test('multiple hours', () {
      expect(
        AppDateUtils.formatDuration(const Duration(hours: 2)),
        '2 hrs',
      );
    });

    test('hours and minutes', () {
      expect(
        AppDateUtils.formatDuration(const Duration(hours: 1, minutes: 30)),
        '1 hr 30 min',
      );
    });
  });

  // ── startOfWeek ────────────────────────────────────────────────────────────

  group('AppDateUtils.startOfWeek', () {
    test('Monday returns same day', () {
      final monday = DateTime(2026, 3, 2); // Monday
      expect(AppDateUtils.startOfWeek(monday), DateTime(2026, 3, 2));
    });

    test('Wednesday returns the Monday of that week', () {
      final wednesday = DateTime(2026, 3, 4); // Wednesday
      expect(AppDateUtils.startOfWeek(wednesday), DateTime(2026, 3, 2));
    });

    test('Sunday returns the Monday 6 days earlier', () {
      final sunday = DateTime(2026, 3, 8); // Sunday
      expect(AppDateUtils.startOfWeek(sunday), DateTime(2026, 3, 2));
    });
  });

  // ── isSameDay ─────────────────────────────────────────────────────────────

  group('AppDateUtils.isSameDay', () {
    test('same date returns true', () {
      final a = DateTime(2026, 3, 2, 10, 0);
      final b = DateTime(2026, 3, 2, 22, 59);
      expect(AppDateUtils.isSameDay(a, b), isTrue);
    });

    test('different date returns false', () {
      final a = DateTime(2026, 3, 2);
      final b = DateTime(2026, 3, 3);
      expect(AppDateUtils.isSameDay(a, b), isFalse);
    });
  });

  // ── daysFromNow ───────────────────────────────────────────────────────────

  group('AppDateUtils.daysFromNow', () {
    test('today returns 0', () {
      expect(AppDateUtils.daysFromNow(DateTime.now()), 0);
    });

    test('tomorrow returns 1', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(AppDateUtils.daysFromNow(tomorrow), 1);
    });

    test('yesterday returns -1', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(AppDateUtils.daysFromNow(yesterday), -1);
    });
  });

  // ── DateTimeX extension ────────────────────────────────────────────────────

  group('DateTimeX extension', () {
    test('isToday returns true for now', () {
      expect(DateTime.now().isToday, isTrue);
    });

    test('isPast returns true for past dates', () {
      expect(DateTime(2000).isPast, isTrue);
    });

    test('toDateString uses MMM d, yyyy format', () {
      final date = DateTime(2026, 3, 2);
      expect(date.toDateString(), 'Mar 2, 2026');
    });

    test('toRelativeString returns "Today" for now', () {
      expect(DateTime.now().toRelativeString(), 'Today');
    });
  });
}
