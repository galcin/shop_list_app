/// Meal types for a given day (breakfast, lunch, dinner).
///
/// Defined in the domain layer because it is a business concept owned by the
/// meal-planning feature. The Drift table (`core/database/tables/meal_slot_table.dart`)
/// imports this enum for persistence rather than the domain depending on a
/// database-table file, keeping the dependency direction Data → Domain.
enum MealType {
  breakfast,
  lunch,
  dinner,
}
