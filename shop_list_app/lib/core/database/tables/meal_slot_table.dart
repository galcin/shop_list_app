import 'package:drift/drift.dart';
import 'package:shop_list_app/core/database/tables/meal_plan_table.dart';
import 'package:shop_list_app/core/database/tables/recipe_table.dart';

/// Meal types for a given day.
enum MealType {
  breakfast,
  lunch,
  dinner,
}

/// Stores individual meal slots (breakfast/lunch/dinner) for each day in a plan.
class MealSlots extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Foreign key to MealPlans.
  IntColumn get planId =>
      integer().references(MealPlans, #id, onDelete: KeyAction.cascade)();

  /// The specific date for this meal slot.
  DateTimeColumn get date => dateTime()();

  /// Meal type: breakfast, lunch, or dinner.
  IntColumn get mealType => intEnum<MealType>()();

  /// Optional foreign key to Recipes.
  IntColumn get recipeId => integer()
      .nullable()
      .references(Recipes, #id, onDelete: KeyAction.setNull)();

  /// Optional custom name (if no recipe is assigned).
  TextColumn get customName => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
