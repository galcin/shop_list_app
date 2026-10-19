import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:shop_list_app/core/error/failures.dart';
import 'package:shop_list_app/features/backup/domain/entities/backup_summary.dart';
import 'package:shop_list_app/features/backup/domain/repositories/i_backup_repository.dart';

/// Reads a backup file and merges it into the database.
class ImportBackupUseCase {
  ImportBackupUseCase(this._repository);
  final IBackupRepository _repository;

  Future<Either<Failure, ImportSummary>> call(String filePath) async {
    Map<String, dynamic> document;
    try {
      final text = await File(filePath).readAsString();
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        return const Left(ValidationFailure('The file is not a backup.'));
      }
      document = decoded;
    } on FormatException {
      return const Left(ValidationFailure('The file is not valid JSON.'));
    } catch (e) {
      return Left(DatabaseFailure('Could not read file: $e'));
    }
    try {
      return Right(await _repository.importData(document));
    } on FormatException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Import failed: $e'));
    }
  }
}
