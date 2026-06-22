import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/features/pantry/domain/entities/pantry_item.dart';

void main() {
  group('PantryItem Entity', () {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final nextWeek = now.add(const Duration(days: 7));
    final yesterday = now.subtract(const Duration(days: 1));

    test('isExpired returns true for past dates', () {
      final item = PantryItem(
        name: 'Milk',
        quantity: 1.0,
        unit: 'L',
        categoryId: 1,
        expiryDate: yesterday,
        purchasedDate: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(item.isExpired, true);
    });

    test('isExpired returns false for future dates', () {
      final item = PantryItem(
        name: 'Milk',
        quantity: 1.0,
        unit: 'L',
        categoryId: 1,
        expiryDate: tomorrow,
        purchasedDate: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(item.isExpired, false);
    });

    test('daysUntilExpiry returns correct value', () {
      final item = PantryItem(
        name: 'Milk',
        quantity: 1.0,
        unit: 'L',
        categoryId: 1,
        expiryDate: nextWeek,
        purchasedDate: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(item.daysUntilExpiry, 7);
    });

    test('daysUntilExpiry returns null for no expiry date', () {
      final item = PantryItem(
        name: 'Honey',
        quantity: 500.0,
        unit: 'g',
        categoryId: 1,
        purchasedDate: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(item.daysUntilExpiry, null);
    });

    test('expiryStatus returns "expiring-soon" for < 3 days', () {
      final twoGaysFromNow = now.add(const Duration(days: 2));
      final item = PantryItem(
        name: 'Milk',
        quantity: 1.0,
        unit: 'L',
        categoryId: 1,
        expiryDate: twoGaysFromNow,
        purchasedDate: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(item.expiryStatus, 'expiring-soon');
    });

    test('expiryStatus returns "fresh" for >= 3 days', () {
      final item = PantryItem(
        name: 'Milk',
        quantity: 1.0,
        unit: 'L',
        categoryId: 1,
        expiryDate: nextWeek,
        purchasedDate: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(item.expiryStatus, 'fresh');
    });

    test('expiryStatus returns "expired" for past dates', () {
      final item = PantryItem(
        name: 'Milk',
        quantity: 1.0,
        unit: 'L',
        categoryId: 1,
        expiryDate: yesterday,
        purchasedDate: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(item.expiryStatus, 'expired');
    });

    test('isOutOfStock returns true for quantity <= 0', () {
      final item = PantryItem(
        name: 'Milk',
        quantity: 0,
        unit: 'L',
        categoryId: 1,
        purchasedDate: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(item.isOutOfStock, true);
    });

    test('isOutOfStock returns false for quantity > 0', () {
      final item = PantryItem(
        name: 'Milk',
        quantity: 1.0,
        unit: 'L',
        categoryId: 1,
        purchasedDate: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(item.isOutOfStock, false);
    });

    test('copyWith updates fields correctly', () {
      final item = PantryItem(
        id: 1,
        name: 'Milk',
        quantity: 1.0,
        unit: 'L',
        categoryId: 1,
        purchasedDate: now,
        createdAt: now,
        updatedAt: now,
      );

      final updated = item.copyWith(quantity: 2.0, name: 'Yogurt');

      expect(updated.id, 1);
      expect(updated.quantity, 2.0);
      expect(updated.name, 'Yogurt');
      expect(updated.unit, 'L');
    });

    test('toMap and fromMap roundtrip correctly', () {
      final item = PantryItem(
        id: 1,
        name: 'Milk',
        quantity: 1.5,
        unit: 'L',
        categoryId: 1,
        expiryDate: tomorrow,
        purchasedDate: now,
        createdAt: now,
        updatedAt: now,
      );

      final map = item.toMap();
      final restored = PantryItem.fromMap(map);

      expect(restored.id, item.id);
      expect(restored.name, item.name);
      expect(restored.quantity, item.quantity);
    });
  });
}
