import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/core/constants/units.dart';

void main() {
  group('Units.normalize', () {
    test('maps plurals and synonyms to canonical codes', () {
      expect(Units.normalize('cups'), Units.cup);
      expect(Units.normalize('Cup'), Units.cup);
      expect(Units.normalize('cloves'), Units.clove);
      expect(Units.normalize('tablespoons'), Units.tbsp);
      expect(Units.normalize('Tbsp.'), Units.tbsp);
      expect(Units.normalize('teaspoon'), Units.tsp);
      expect(Units.normalize('liters'), Units.l);
      expect(Units.normalize('mL'), Units.ml);
      expect(Units.normalize('pieces'), Units.pcs);
      expect(Units.normalize('sprigs'), Units.sprig);
      expect(Units.normalize('stalks'), Units.stalk);
      expect(Units.normalize('tin'), Units.can);
    });

    test('keeps canonical codes unchanged', () {
      for (final code in Units.all) {
        expect(Units.normalize(code), code, reason: code);
      }
    });

    test('empty or null means no unit, unknown falls back to pcs', () {
      expect(Units.normalize(null), Units.none);
      expect(Units.normalize('   '), Units.none);
      expect(Units.normalize('lemon'), Units.pcs);
      expect(Units.normalize('gizmo'), Units.pcs);
      expect(Units.isKnown('gizmo'), isFalse);
      expect(Units.isKnown('cups'), isTrue);
    });
  });

  group('Units.label', () {
    test('pluralises countable units', () {
      expect(Units.label(Units.clove, 1), 'clove');
      expect(Units.label(Units.clove, 2), 'cloves');
      expect(Units.label(Units.cup, 0.5), 'cups');
      expect(Units.label(Units.g, 250), 'g');
      expect(Units.label(Units.none, 3), '');
    });
  });
}
