import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/core/utils/validators.dart';

void main() {
  // ── validateNonEmpty ──────────────────────────────────────────────────────

  group('Validators.validateNonEmpty', () {
    test('null returns error', () {
      expect(Validators.validateNonEmpty(null), isNotNull);
    });

    test('empty string returns error', () {
      expect(Validators.validateNonEmpty(''), isNotNull);
    });

    test('blank string returns error', () {
      expect(Validators.validateNonEmpty('   '), isNotNull);
    });

    test('non-empty string returns null', () {
      expect(Validators.validateNonEmpty('hello'), isNull);
    });

    test('error message includes fieldName when provided', () {
      final msg = Validators.validateNonEmpty('', fieldName: 'Title');
      expect(msg, contains('Title'));
    });
  });

  // ── validateEmail ─────────────────────────────────────────────────────────

  group('Validators.validateEmail', () {
    test('null returns error', () {
      expect(Validators.validateEmail(null), isNotNull);
    });

    test('empty returns error', () {
      expect(Validators.validateEmail(''), isNotNull);
    });

    test('missing @ returns error', () {
      expect(Validators.validateEmail('notanemail'), isNotNull);
    });

    test('missing TLD returns error', () {
      expect(Validators.validateEmail('user@domain'), isNotNull);
    });

    test('valid email returns null', () {
      expect(Validators.validateEmail('user@example.com'), isNull);
    });

    test('email with subdomain returns null', () {
      expect(Validators.validateEmail('user@mail.example.co.uk'), isNull);
    });
  });

  // ── validateMinLength ─────────────────────────────────────────────────────

  group('Validators.validateMinLength', () {
    test('shorter than min returns error', () {
      expect(Validators.validateMinLength('ab', 3), isNotNull);
    });

    test('exactly min returns null', () {
      expect(Validators.validateMinLength('abc', 3), isNull);
    });

    test('longer than min returns null', () {
      expect(Validators.validateMinLength('abcdef', 3), isNull);
    });

    test('blank string returns error', () {
      expect(Validators.validateMinLength('  ', 1), isNotNull);
    });
  });

  // ── validatePositive ─────────────────────────────────────────────────────

  group('Validators.validatePositive', () {
    test('null returns error', () {
      expect(Validators.validatePositive(null), isNotNull);
    });

    test('zero returns error', () {
      expect(Validators.validatePositive(0), isNotNull);
    });

    test('negative returns error', () {
      expect(Validators.validatePositive(-1), isNotNull);
    });

    test('positive value returns null', () {
      expect(Validators.validatePositive(1.5), isNull);
    });

    test('fractional positive returns null', () {
      expect(Validators.validatePositive(0.001), isNull);
    });

    test('error message includes fieldName', () {
      final msg = Validators.validatePositive(-1, fieldName: 'Quantity');
      expect(msg, contains('Quantity'));
    });
  });

  // ── validateNonNegative ───────────────────────────────────────────────────

  group('Validators.validateNonNegative', () {
    test('negative returns error', () {
      expect(Validators.validateNonNegative(-0.1), isNotNull);
    });

    test('zero returns null', () {
      expect(Validators.validateNonNegative(0), isNull);
    });

    test('positive returns null', () {
      expect(Validators.validateNonNegative(5), isNull);
    });
  });

  // ── validatePositiveString ────────────────────────────────────────────────

  group('Validators.validatePositiveString', () {
    test('empty string returns error', () {
      expect(Validators.validatePositiveString(''), isNotNull);
    });

    test('non-numeric string returns error', () {
      expect(Validators.validatePositiveString('abc'), isNotNull);
    });

    test('zero string returns error', () {
      expect(Validators.validatePositiveString('0'), isNotNull);
    });

    test('valid positive string returns null', () {
      expect(Validators.validatePositiveString('2.5'), isNull);
    });
  });

  // ── boolean helpers ───────────────────────────────────────────────────────

  group('Validators boolean helpers', () {
    test('isNotEmpty: null is false', () {
      expect(Validators.isNotEmpty(null), isFalse);
    });

    test('isNotEmpty: blank is false', () {
      expect(Validators.isNotEmpty('  '), isFalse);
    });

    test('isNotEmpty: non-empty is true', () {
      expect(Validators.isNotEmpty('hello'), isTrue);
    });

    test('isPositiveNumber: null is false', () {
      expect(Validators.isPositiveNumber(null), isFalse);
    });

    test('isPositiveNumber: zero is false', () {
      expect(Validators.isPositiveNumber(0), isFalse);
    });

    test('isPositiveNumber: positive is true', () {
      expect(Validators.isPositiveNumber(3), isTrue);
    });

    test('isValidDate: null is false', () {
      expect(Validators.isValidDate(null), isFalse);
    });

    test('isValidDate: non-null is true', () {
      expect(Validators.isValidDate(DateTime.now()), isTrue);
    });
  });
}
