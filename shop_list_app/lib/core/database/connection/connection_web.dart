import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:shop_list_app/core/utils/app_logger.dart';

QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'shop_list_db',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.dart.js'),
    );

    if (result.missingFeatures.isNotEmpty) {
      AppLogger.instance.info(
        'Database using ${result.chosenImplementation} '
        'due to missing features: ${result.missingFeatures}',
      );
    }

    return result.resolvedExecutor;
  });
}
