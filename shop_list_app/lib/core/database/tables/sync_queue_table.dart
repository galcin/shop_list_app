import 'package:drift/drift.dart';

/// Tracks pending mutations that need to be synced to the remote backend.
/// Used by the Post-MVP cloud sync engine (Epic E15).
@DataClassName('SyncQueueEntry')
class SyncQueue extends Table {
  /// Unique identifier for the sync queue entry (UUID).
  TextColumn get id => text()();

  /// The entity type being synced, e.g. 'recipe', 'shopping_list', 'meal_plan'.
  TextColumn get entityType => text()();

  /// The ID of the entity instance being synced.
  TextColumn get entityId => text()();

  /// The operation to sync: 'create', 'update', or 'delete'.
  TextColumn get operation => text()();

  /// JSON-encoded payload of the entity at the time of mutation.
  TextColumn get data => text()();

  /// Timestamp when this entry was added to the queue.
  DateTimeColumn get createdAt => dateTime()();

  /// Number of sync attempts already made (used for exponential back-off).
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  /// Last error message, populated when a sync attempt fails.
  TextColumn get error => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
