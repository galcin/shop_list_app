import 'dart:math' as math;

/// Numeric formatting helpers — especially for recipe quantities.
class NumberUtils {
  NumberUtils._();

  // Common fractions expressed as decimal → display string.
  static final _fractions = <double, String>{
    0.125: '⅛',
    0.25: '¼',
    0.333: '⅓',
    0.5: '½',
    0.667: '⅔',
    0.75: '¾',
  };

  // Tolerance for matching a decimal to a known fraction.
  static const _tolerance = 0.04;

  /// Formats [value] as a compact recipe quantity, e.g.:
  /// - `1.0`  → `"1"`
  /// - `0.5`  → `"½"`
  /// - `1.5`  → `"1½"`
  /// - `1.333` → `"1⅓"`
  /// - `2.6`  → `"2.6"`
  static String formatQuantity(double value) {
    if (value <= 0) return '0';

    final whole = value.floor();
    final decimal = value - whole;

    // Pure integer
    if (decimal < _tolerance) {
      return '$whole';
    }

    // Try to match to a known fraction symbol
    for (final entry in _fractions.entries) {
      if ((decimal - entry.key).abs() < _tolerance) {
        return whole == 0 ? entry.value : '$whole${entry.value}';
      }
    }

    // Fall back to 1 decimal place (strip trailing zero)
    final formatted = value.toStringAsFixed(1);
    return formatted.endsWith('.0')
        ? formatted.substring(0, formatted.length - 2)
        : formatted;
  }

  /// Formats [value] as a plain decimal, trimming unnecessary zeros.
  /// e.g. `1.0` → `"1"`, `1.50` → `"1.5"`, `1.23` → `"1.23"`.
  static String formatDecimal(double value, {int maxDecimals = 2}) {
    final factor = math.pow(10, maxDecimals).toDouble();
    final rounded = (value * factor).round() / factor;
    final str = rounded.toStringAsFixed(maxDecimals);
    // Remove trailing zeros after decimal point
    if (str.contains('.')) {
      return str.replaceAll(RegExp(r'\.?0+$'), '');
    }
    return str;
  }

  /// Clamps [value] to [min]..[max] and returns the result.
  static double clamp(double value, double min, double max) =>
      value.clamp(min, max);

  /// Rounds [value] to a given number of [decimalPlaces].
  static double roundTo(double value, int decimalPlaces) {
    final factor = math.pow(10, decimalPlaces).toDouble();
    return (value * factor).round() / factor;
  }
}
