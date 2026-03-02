import 'package:intl/intl.dart';

/// Static date/time formatting and comparison utilities used across the app.
class AppDateUtils {
  AppDateUtils._();

  static final _dateFormatter = DateFormat('MMM d, yyyy');
  static final _dateTimeFormatter = DateFormat('MMM d, yyyy h:mm a');
  static final _timeFormatter = DateFormat('h:mm a');
  static final _shortDateFormatter = DateFormat('MMM d');

  /// Returns a human-readable date string, e.g. "Mar 2, 2026".
  static String formatDate(DateTime date) => _dateFormatter.format(date);

  /// Returns a human-readable date + time string, e.g. "Mar 2, 2026 3:45 PM".
  static String formatDateTime(DateTime date) =>
      _dateTimeFormatter.format(date);

  /// Returns a time-only string, e.g. "3:45 PM".
  static String formatTime(DateTime date) => _timeFormatter.format(date);

  /// Returns a relative label:
  /// - "Today", "Yesterday", "Tomorrow" within ±1 day,
  /// - Short date within the current year, e.g. "Mar 2",
  /// - Full date otherwise, e.g. "Mar 2, 2025".
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    if (isSameDay(date, now)) return 'Today';
    if (isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    if (isSameDay(date, now.add(const Duration(days: 1)))) return 'Tomorrow';

    if (date.year == now.year) return _shortDateFormatter.format(date);
    return formatDate(date);
  }

  /// Formats a [Duration] as a human-readable string, e.g.:
  /// - "5 min", "1 hr", "1 hr 30 min".
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours == 0) return '$minutes min';
    if (minutes == 0) return '${hours > 1 ? '$hours hrs' : '1 hr'}';
    return '${hours > 1 ? '$hours hrs' : '1 hr'} $minutes min';
  }

  /// Returns the Monday that starts the ISO week containing [date].
  static DateTime startOfWeek(DateTime date) {
    // weekday: 1 = Monday … 7 = Sunday
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: date.weekday - 1));
  }

  /// Returns true when [a] and [b] fall on the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Returns true when [date] is today.
  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());

  /// Returns the number of whole days from today to [date].
  /// Positive = future, negative = past, 0 = today.
  static int daysFromNow(DateTime date) {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final target = DateTime(date.year, date.month, date.day);
    return target.difference(today).inDays;
  }
}

// ---------------------------------------------------------------------------
// DateTime convenience extension (keeps the original API surface available)
// ---------------------------------------------------------------------------

extension DateTimeX on DateTime {
  /// Returns true if this date is today.
  bool get isToday => AppDateUtils.isToday(this);

  /// Returns true if this date is in the past.
  bool get isPast => isBefore(DateTime.now());

  /// Formats as "MMM d, yyyy", e.g. "Mar 2, 2026".
  String toDateString() => AppDateUtils.formatDate(this);

  /// Formats as relative label (Today / Yesterday / …).
  String toRelativeString() => AppDateUtils.formatRelative(this);
}
