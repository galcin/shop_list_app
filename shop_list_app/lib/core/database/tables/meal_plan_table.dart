import 'package:drift/drift.dart';

/// Stores weekly meal plans.
class MealPlans extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Start date of the week (e.g., Monday).
  DateTimeColumn get weekStartDate => dateTime()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
