import 'package:drift/drift.dart';

class ProductCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get photo => text().nullable()();
  TextColumn get colorHex => text().nullable()();
  TextColumn get iconName => text().nullable()();

  /// Asset image filename for this category, e.g. 'fruits_category.png'.
  /// When set, the UI shows the image instead of the emoji/icon.
  TextColumn get imageName => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
