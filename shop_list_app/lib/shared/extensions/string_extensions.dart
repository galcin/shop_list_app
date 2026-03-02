/// Convenience extensions on [String].
extension StringExtensions on String {
  // ── Casing ────────────────────────────────────────────────────────────────

  /// Returns the string with its first character uppercased.
  /// e.g. `"hello"` → `"Hello"`.
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Returns title-case: the first letter of every word is uppercased.
  /// e.g. `"chicken tikka masala"` → `"Chicken Tikka Masala"`.
  String toTitleCase() => split(' ')
      .map((word) => word.isEmpty ? word : word.capitalize())
      .join(' ');

  // ── Checks ────────────────────────────────────────────────────────────────

  /// Returns `true` when the string (after trimming) is empty.
  bool get isBlank => trim().isEmpty;

  /// Returns `true` when the string is **not** blank.
  bool get isNotBlank => !isBlank;

  /// Returns `true` when the string can be parsed as a `double`.
  bool get isNumeric => double.tryParse(this) != null;

  // ── Transformations ───────────────────────────────────────────────────────

  /// Returns `null` if the string is blank, otherwise the trimmed string.
  String? get nullIfBlank => isBlank ? null : trim();

  /// Truncates the string to [maxLength] characters, appending [ellipsis]
  /// if it was longer than [maxLength].
  String truncate(int maxLength, {String ellipsis = '…'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$ellipsis';
  }

  /// Removes all whitespace from the string.
  String get stripped => replaceAll(RegExp(r'\s+'), '');

  /// Converts a snake_case or kebab-case string to human-readable form.
  /// e.g. `"prep_time_minutes"` → `"Prep time minutes"`.
  String toHumanReadable() => replaceAll(RegExp(r'[_\-]'), ' ').capitalize();
}

/// Nullable [String] extensions.
extension NullableStringExtensions on String? {
  /// Returns `true` when this is `null` or blank.
  bool get isNullOrBlank => this == null || this!.isBlank;

  /// Returns [fallback] when this is `null` or blank.
  String orDefault(String fallback) => isNullOrBlank ? fallback : this!.trim();
}
