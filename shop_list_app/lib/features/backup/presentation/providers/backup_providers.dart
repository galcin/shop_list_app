import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/core/providers/core_providers.dart';
import 'package:shop_list_app/features/backup/data/repositories/backup_repository.dart';
import 'package:shop_list_app/features/backup/domain/repositories/i_backup_repository.dart';
import 'package:shop_list_app/features/backup/domain/usecases/export_backup_use_case.dart';
import 'package:shop_list_app/features/backup/domain/usecases/import_backup_use_case.dart';

final backupRepositoryProvider = Provider<IBackupRepository>((ref) {
  return BackupRepository(ref.watch(databaseProvider));
});

final exportBackupUseCaseProvider = Provider<ExportBackupUseCase>((ref) {
  return ExportBackupUseCase(ref.watch(backupRepositoryProvider));
});

final importBackupUseCaseProvider = Provider<ImportBackupUseCase>((ref) {
  return ImportBackupUseCase(ref.watch(backupRepositoryProvider));
});
