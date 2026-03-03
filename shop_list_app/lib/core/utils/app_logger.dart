import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Singleton logger that writes timestamped entries to
/// `<documents>/shop_list_logs/app.log`.
///
/// Usage:
/// ```dart
/// AppLogger.instance.info('Database opened');
/// AppLogger.instance.error('Migration failed', error: e, stackTrace: st);
/// ```
///
/// The log file path is exposed via [AppLogger.logFilePath] so it can be
/// displayed or shared from a settings screen.
class AppLogger {
  AppLogger._();

  static final AppLogger instance = AppLogger._();

  File? _logFile;
  bool _ready = false;

  /// Absolute path of the current log file. Available after [init] completes.
  String? get logFilePath => _logFile?.path;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  /// Must be called once before the app starts (e.g. in [main]).
  Future<void> init() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final logDir = Directory(p.join(dir.path, 'shop_list_logs'));
      if (!logDir.existsSync()) logDir.createSync(recursive: true);
      _logFile = File(p.join(logDir.path, 'app.log'));
      _ready = true;
      await _write('INFO', 'Logger initialised — log file: ${_logFile!.path}');
    } catch (e) {
      debugPrint('[AppLogger] Failed to initialise log file: $e');
    }
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  void info(String message) {
    _write('INFO', message);
    debugPrint('[INFO] $message');
  }

  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    final body = _format(message, error, stackTrace);
    _write('WARN', body);
    debugPrint('[WARN] $body');
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    final body = _format(message, error, stackTrace);
    _write('ERROR', body);
    debugPrint('[ERROR] $body');
  }

  /// Reads the entire log file and returns it as a string.
  /// Returns an empty string if the file has not been created yet.
  Future<String> readAll() async {
    if (_logFile == null || !_logFile!.existsSync()) return '';
    return _logFile!.readAsString();
  }

  /// Deletes the log file and creates a fresh one.
  Future<void> clear() async {
    if (_logFile != null && _logFile!.existsSync()) {
      await _logFile!.writeAsString('');
    }
    await _write('INFO', 'Log cleared');
  }

  // ── Internals ──────────────────────────────────────────────────────────────

  String _format(String message, Object? error, StackTrace? stackTrace) {
    final buf = StringBuffer(message);
    if (error != null) buf.write('\n  error: $error');
    if (stackTrace != null) buf.write('\n  stack: $stackTrace');
    return buf.toString();
  }

  Future<void> _write(String level, String body) async {
    if (!_ready || _logFile == null) return;
    try {
      final now = DateTime.now().toIso8601String();
      final line = '[$now][$level] $body\n';
      await _logFile!.writeAsString(line, mode: FileMode.append, flush: true);
    } catch (_) {
      // Never crash the app because of a logging failure.
    }
  }
}
