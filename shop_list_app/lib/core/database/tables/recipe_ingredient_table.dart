import 'package:drift/drift.dart';

import 'product_table.dart';
import 'recipe_table.dart';

/// One ingredient line of a recipe.
///
/// [productId] links the line to the product catalogue so pantry matching and
/// shopping list generation can work on ids instead of fuzzy names. It is
/// nullable because users may type an ingredient that has no catalogue entry.
@TableIndex(name: 'idx_recipe_ingredients_recipe', columns: {#recipeId})
@TableIndex(name: 'idx_recipe_ingredients_product', columns: {#productId})
class RecipeIngredients extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get recipeId =>
      integer().references(Recipes, #id, onDelete: KeyAction.cascade)();
  IntColumn get productId => integer()
      .nullable()
      .references(Products, #id, onDelete: KeyAction.setNull)();

  /// Display name, e.g. "Garlic (whole head)". Defaults to the product name.
  TextColumn get name => text()();

  /// Null for ingredients without a measurable amount ("to taste").
  RealColumn get quantity => real().nullable()();

  /// Canonical unit code from `Units`. Empty string when there is no unit.
  TextColumn get unit => text().withDefault(const Constant(''))();

  /// Free text such as "to taste", "for garnish", "finely chopped".
  TextColumn get note => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}
