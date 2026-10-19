import 'package:drift/drift.dart';

@TableIndex(name: 'idx_recipes_name', columns: {#name})
@TableIndex(name: 'idx_recipes_category', columns: {#category})
class Recipes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text().nullable()();

  /// Newline-separated cooking steps.
  TextColumn get instructions => text().nullable()();
  IntColumn get prepTime => integer().nullable()(); // minutes
  IntColumn get cookTime => integer().nullable()(); // minutes
  IntColumn get servings => integer().nullable()();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  TextColumn get imageUrl => text().nullable()();
  RealColumn get rating => real().nullable()();

  /// JSON-encoded List<String> of tag strings.
  TextColumn get tagsJson => text().nullable()();

  /// `true` for recipes shipped with the app. Editing one hands it over to
  /// the user (flag flips to `false`) so later seed updates leave it alone.
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();

  /// Stable identifier from the seed file, used to match built-in recipes
  /// across seed versions. Null for user-created recipes.
  TextColumn get seedKey => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
