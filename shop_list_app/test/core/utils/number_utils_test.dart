import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/core/utils/number_utils.dart';

void main() {
  // ── formatQuantity ────────────────────────────────────────────────────────

  group('NumberUtils.formatQuantity', () {
    test('integer value displays without decimal', () {
      expect(NumberUtils.formatQuantity(1.0), '1');
      expect(NumberUtils.formatQuantity(3.0), '3');
    });

    test('0.5 displays as ½', () {
      expect(NumberUtils.formatQuantity(0.5), '½');
    });

    test('0.25 displays as ¼', () {
      expect(NumberUtils.formatQuantity(0.25), '¼');
    });

    test('0.75 displays as ¾', () {
      expect(NumberUtils.formatQuantity(0.75), '¾');
    });

    test('1.5 displays as 1½', () {
      expect(NumberUtils.formatQuantity(1.5), '1½');
    });

    test('2.333 displays as 2⅓', () {
      expect(NumberUtils.formatQuantity(2.333), '2⅓');
    });

    test('value with no known fraction falls back to decimal', () {
      expect(NumberUtils.formatQuantity(2.6), '2.6');
    });

    test('zero returns "0"', () {
      expect(NumberUtils.formatQuantity(0), '0');
    });

    test('negative returns "0"', () {
      expect(NumberUtils.formatQuantity(-1), '0');
    });
  });

  // ── formatDecimal ─────────────────────────────────────────────────────────

  group('NumberUtils.formatDecimal', () {
    test('integer strips trailing zeros', () {
      expect(NumberUtils.formatDecimal(1.0), '1');
    });

    test('single decimal place', () {
      expect(NumberUtils.formatDecimal(1.5), '1.5');
    });

    test('two decimal places', () {
      expect(NumberUtils.formatDecimal(1.23), '1.23');
    });

    test('trailing zero stripped', () {
      expect(NumberUtils.formatDecimal(1.10), '1.1');
    });
  });

  // ── clamp ─────────────────────────────────────────────────────────────────

  group('NumberUtils.clamp', () {
    test('value within range is unchanged', () {
      expect(NumberUtils.clamp(5.0, 0.0, 10.0), 5.0);
    });

    test('value below min is clamped to min', () {
      expect(NumberUtils.clamp(-1.0, 0.0, 10.0), 0.0);
    });

    test('value above max is clamped to max', () {
      expect(NumberUtils.clamp(11.0, 0.0, 10.0), 10.0);
    });
  });

  // ── roundTo ───────────────────────────────────────────────────────────────

  group('NumberUtils.roundTo', () {
    test('rounds to 2 decimal places', () {
      expect(NumberUtils.roundTo(3.14159, 2), 3.14);
    });

    test('rounds to 0 decimal places', () {
      expect(NumberUtils.roundTo(3.7, 0), 4.0);
    });

    test('already exact is unchanged', () {
      expect(NumberUtils.roundTo(2.5, 1), 2.5);
    });
  });
}
