import 'package:shop_list_app/features/backup/domain/entities/backup_summary.dart';

abstract class IBackupRepository {
  /// Serialises all user data (and the catalogue rows it references) into a
  /// JSON document. Built-in recipes are referenced by seed key, not copied.
  Future<Map<String, dynamic>> exportData();

  /// Merges a document produced by [exportData] into the database.
  /// Existing rows are matched by name / seed key; nothing is deleted.
  Future<ImportSummary> importData(Map<String, dynamic> document);
}
