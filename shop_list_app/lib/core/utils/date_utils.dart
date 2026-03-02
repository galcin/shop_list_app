extension AppDateUtils on DateTime {
  /// Returns true if this date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns true if this date is in the past.
  bool get isPast => isBefore(DateTime.now());

  /// Formats as yyyy-MM-dd.
  String toDateString() =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}
