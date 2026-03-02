extension StringUtils on String {
  /// Returns the string with its first character capitalised.
  String get capitalised =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Returns true if the string is null or contains only whitespace.
  bool get isBlank => trim().isEmpty;
}
