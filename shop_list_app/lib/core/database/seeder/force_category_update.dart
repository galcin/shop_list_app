import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:shop_list_app/core/database/app_database.dart';

/// Temporary helper to force update all recipe categories
/// Call this once to populate categories without full app restart
class ForceCategoryUpdate {
  static Future<void> updateAllCategories(AppDatabase database) async {
    debugPrint('[ForceUpdate] ========== Starting category update ==========');

    final categoryMapping = {
      'Egg Omelet': 'Breakfast',
      'Chicken Soup': 'Soups',
      'Spaghetti Bolognese': 'Main Courses',
      'Tomato Basil Soup': 'Soups',
      'Banana Pancakes': 'Breakfast',
      'Grilled Cheese Sandwich': 'Breakfast',
      'Chicken Stir-Fry': 'Main Courses',
      'Apple Cinnamon Oatmeal': 'Breakfast',
      'Vegetable Stew': 'Soups',
      'Caprese Salad': 'Salads',
      'Pasta Carbonara': 'Main Courses',
      'Pasta with Tomato and Mushroom Sauce': 'Main Courses',
      'Green Salad with Tuna and Corn': 'Salads',
      'Cheese and Herb Omelet': 'Breakfast',
      'Asian-Style Rice with Chicken': 'Main Courses',
      'Turkey Breast on a Bed of Vegetables': 'Main Courses',
      'Cream of Mushroom Soup': 'Soups',
      'Chicken and Cheese Puff Pastry Braid': 'Main Courses',
      'Flatbread Pizza': 'Main Courses',
      'Chicken Skewers in a Pan': 'Main Courses',
      'Crispy Sandwich': 'Breakfast',
      'French Potato Pudding': 'Side Dishes',
      'Rice with Mexican Vegetables': 'Side Dishes',
      'Chicken with Mushrooms in Cream Sauce': 'Main Courses',
      'Pork and Potato Stew': 'Main Courses',
      'Oven-Baked Chicken with Potatoes': 'Main Courses',
      'Penne Quattro Formaggi': 'Main Courses',
      'Pasta Arrabiata': 'Main Courses',
      'Pasta with Chicken and Pesto': 'Main Courses',
      'Pasta with Shrimp': 'Main Courses',
      'Pasta with Garlic and Hot Pepper': 'Main Courses',
      'Baked Salmon with Asparagus': 'Main Courses',
      'Baked Salmon with Vegetables': 'Main Courses',
      'Classic Beef Soup': 'Soups',
      'Sour Beef Soup': 'Soups',
      'Transylvanian Veal Soup with Sour Cream': 'Soups',
      'Country-Style Beef Soup': 'Soups',
      'Classic Tomato Soup': 'Soups',
      'Tomato Soup with Homemade Noodles': 'Soups',
      'Tomato Soup with Semolina Dumplings': 'Soups',
      'Cream of Tomato Soup': 'Soups',
      'Tomato Soup with Garlic': 'Soups',
      'Gazpacho': 'Soups',
      'Turkish Tomato Soup': 'Soups',
    };

    debugPrint('[ForceUpdate] Will update ${categoryMapping.length} recipes');

    int updated = 0;
    int failed = 0;
    for (final entry in categoryMapping.entries) {
      try {
        await database.customStatement(
          'UPDATE recipes SET category = ? WHERE name = ?',
          [entry.value, entry.key],
        );
        updated++;
        if (updated <= 3) {
          debugPrint(
              '[ForceUpdate] ✓ Updated "${entry.key}" → "${entry.value}"');
        }
      } catch (e) {
        failed++;
        debugPrint('[ForceUpdate] ✗ Failed to update ${entry.key}: $e');
      }
    }

    debugPrint('[ForceUpdate] Completed: $updated updated, $failed failed');

    // Verify update by checking a few recipes
    final samples = await database
        .customSelect(
          'SELECT name, category FROM recipes LIMIT 5',
        )
        .get();

    debugPrint('[ForceUpdate] Sample recipes after update:');
    for (final row in samples) {
      debugPrint(
          '  - ${row.read<String>('name')}: "${row.read<String?>('category') ?? 'NULL'}"');
    }

    debugPrint('[ForceUpdate] ========== Complete ==========');
  }
}
