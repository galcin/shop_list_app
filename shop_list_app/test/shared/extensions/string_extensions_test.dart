import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/shared/extensions/string_extensions.dart';

void main() {
  // ── capitalize ────────────────────────────────────────────────────────────

  group('StringExtensions.capitalize', () {
    test('lower-case word', () => expect('hello'.capitalize(), 'Hello'));
    test('already capitalised', () => expect('Hello'.capitalize(), 'Hello'));
    test('empty string', () => expect(''.capitalize(), ''));
    test('single char', () => expect('a'.capitalize(), 'A'));
  });

  // ── toTitleCase ───────────────────────────────────────────────────────────

  group('StringExtensions.toTitleCase', () {
    test('multiple words', () {
      expect('chicken tikka masala'.toTitleCase(), 'Chicken Tikka Masala');
    });

    test('already title case', () {
      expect('Hello World'.toTitleCase(), 'Hello World');
    });

    test('single word', () {
      expect('hello'.toTitleCase(), 'Hello');
    });

    test('empty string', () {
      expect(''.toTitleCase(), '');
    });
  });

  // ── isBlank / isNotBlank ──────────────────────────────────────────────────

  group('StringExtensions.isBlank', () {
    test('empty string is blank', () => expect(''.isBlank, isTrue));
    test('whitespace string is blank', () => expect('  '.isBlank, isTrue));
    test('non-empty is not blank', () => expect('a'.isBlank, isFalse));
  });

  group('StringExtensions.isNotBlank', () {
    test('non-empty is not blank', () => expect('hello'.isNotBlank, isTrue));
    test('empty is blank', () => expect(''.isNotBlank, isFalse));
  });

  // ── isNumeric ─────────────────────────────────────────────────────────────

  group('StringExtensions.isNumeric', () {
    test('integer string is numeric', () => expect('42'.isNumeric, isTrue));
    test('decimal string is numeric', () => expect('3.14'.isNumeric, isTrue));
    test('negative is numeric', () => expect('-5'.isNumeric, isTrue));
    test('alpha is not numeric', () => expect('abc'.isNumeric, isFalse));
    test('empty is not numeric', () => expect(''.isNumeric, isFalse));
  });

  // ── nullIfBlank ───────────────────────────────────────────────────────────

  group('StringExtensions.nullIfBlank', () {
    test('blank returns null', () => expect('  '.nullIfBlank, isNull));
    test('non-blank returns trimmed string', () {
      expect('  hello  '.nullIfBlank, 'hello');
    });
  });

  // ── truncate ──────────────────────────────────────────────────────────────

  group('StringExtensions.truncate', () {
    test('short string unaffected', () {
      expect('hello'.truncate(10), 'hello');
    });

    test('exactly at limit is unaffected', () {
      expect('hello'.truncate(5), 'hello');
    });

    test('long string truncated with ellipsis', () {
      expect('hello world'.truncate(5), 'hello…');
    });

    test('custom ellipsis', () {
      expect('hello world'.truncate(5, ellipsis: '...'), 'hello...');
    });
  });

  // ── stripped ─────────────────────────────────────────────────────────────

  group('StringExtensions.stripped', () {
    test('removes all spaces', () => expect('h e l l o'.stripped, 'hello'));
    test('removes tabs and newlines', () {
      expect('a\tb\nc'.stripped, 'abc');
    });
  });

  // ── toHumanReadable ───────────────────────────────────────────────────────

  group('StringExtensions.toHumanReadable', () {
    test('snake_case', () {
      expect('prep_time_minutes'.toHumanReadable(), 'Prep time minutes');
    });

    test('kebab-case', () {
      expect('meal-plan'.toHumanReadable(), 'Meal plan');
    });
  });

  // ── NullableStringExtensions ──────────────────────────────────────────────

  group('NullableStringExtensions.isNullOrBlank', () {
    test('null is null-or-blank', () {
      String? s;
      expect(s.isNullOrBlank, isTrue);
    });

    test('blank is null-or-blank', () {
      expect('  '.isNullOrBlank, isTrue);
    });

    test('non-blank is not null-or-blank', () {
      expect('hello'.isNullOrBlank, isFalse);
    });
  });

  group('NullableStringExtensions.orDefault', () {
    test('null returns fallback', () {
      String? s;
      expect(s.orDefault('default'), 'default');
    });

    test('blank returns fallback', () {
      expect('  '.orDefault('default'), 'default');
    });

    test('non-blank returns trimmed value', () {
      expect('  hello  '.orDefault('default'), 'hello');
    });
  });
}
