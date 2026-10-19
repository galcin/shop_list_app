import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/backup/domain/entities/backup_summary.dart';
import 'package:shop_list_app/features/backup/domain/repositories/i_backup_repository.dart';

/// Writes a JSON backup of the user's data to a temporary file and returns
/// its location so the UI can hand it to the system share sheet.
class ExportBackupUseCase {
  ExportBackupUseCase(this._repository, {Future<Directory> Function()? tempDir})
      : _tempDir = tempDir ?? getTemporaryDirectory;

  final IBackupRepository _repository;
  final Future<Directory> Function() _tempDir;

  Future<Either<Failure, ExportResult>> call() async {
    try {
      final document = await _repository.exportData();
      final now = DateTime.now();
      final stamp = '${now.year}-${_two(now.month)}-${_two(now.day)}_'
          '${_two(now.hour)}${_two(now.minute)}';
      final fileName = 'shop_list_backup_$stamp.json';
      final dir = await _tempDir();
      final file = File(p.join(dir.path, fileName));
      await file.writeAsString(
          const JsonEncoder.withIndent('  ').convert(document));
      return Right(ExportResult(
        filePath: file.path,
        fileName: fileName,
        recipes: (document['recipes'] as List).length,
        shoppingLists: (document['shoppingLists'] as List).length,
        pantryItems: (document['pantryItems'] as List).length,
        mealPlans: (document['mealPlans'] as List).length,
      ));
    } catch (e) {
      return Left(DatabaseFailure('Export failed: $e'));
    }
  }

  String _two(int v) => v.toString().padLeft(2, '0');
}
