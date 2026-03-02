/// Form-field and domain-level validators used in Use Cases and UI forms.
///
/// Every method follows the Flutter form-field convention: returns `null` when
/// the value is valid, or an error message string when it is not.
class Validators {
  Validators._();

  // ── Text ──────────────────────────────────────────────────────────────────

  /// Returns an error message if [value] is null or blank, otherwise `null`.
  static String? validateNonEmpty(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty';
    }
    return null;
  }

  /// Returns an error message if [value] is not a well-formed email address.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email cannot be empty';
    }
    // Simple RFC-5321-ish check; rejects obvious non-emails.
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Returns an error message when [value] is too short.
  static String? validateMinLength(
    String? value,
    int min, {
    String fieldName = 'Field',
  }) {
    final base = validateNonEmpty(value, fieldName: fieldName);
    if (base != null) return base;
    if (value!.trim().length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  // ── Numbers ───────────────────────────────────────────────────────────────

  /// Returns an error message if [value] is null or not strictly positive.
  static String? validatePositive(double? value, {String fieldName = 'Value'}) {
    if (value == null || value <= 0) {
      return '$fieldName must be greater than 0';
    }
    return null;
  }

  /// Returns an error message if [value] is negative.
  static String? validateNonNegative(
    double? value, {
    String fieldName = 'Value',
  }) {
    if (value == null || value < 0) {
      return '$fieldName cannot be negative';
    }
    return null;
  }

  /// Returns an error message if [value] is not parseable as a positive
  /// number. Useful for text form fields accepting numeric input.
  static String? validatePositiveString(
    String? value, {
    String fieldName = 'Value',
  }) {
    final base = validateNonEmpty(value, fieldName: fieldName);
    if (base != null) return base;
    final parsed = double.tryParse(value!.trim());
    return validatePositive(parsed, fieldName: fieldName);
  }

  // ── Boooleans (raw checks, not UI-message form) ────────────────────────────

  /// Returns `true` when [value] is non-null and not blank.
  static bool isNotEmpty(String? value) =>
      value != null && value.trim().isNotEmpty;

  /// Returns `true` when [value] is non-null and strictly positive.
  static bool isPositiveNumber(num? value) => value != null && value > 0;

  /// Returns `true` when [date] is non-null.
  static bool isValidDate(DateTime? date) => date != null;
}
