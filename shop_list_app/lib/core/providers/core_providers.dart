import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/core/database/app_database.dart';

/// Provides the singleton [AppDatabase] instance.
/// Disposed automatically when the provider scope is destroyed.
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase.instance;
  ref.onDispose(() => database.close());
  return database;
});
