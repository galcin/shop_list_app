import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shop_list_app/core/utils/app_logger.dart';

class SettingsView extends StatefulWidget {
  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  String? _logPath;
  String? _logContent;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _logPath = AppLogger.instance.logFilePath;
    // Auto-load log content as soon as the page opens.
    _viewLog();
  }

  Future<void> _viewLog() async {
    setState(() => _loading = true);
    final content = await AppLogger.instance.readAll();
    setState(() {
      _logContent = content.isEmpty
          ? '(log is empty — make sure the app was fully restarted, not just hot-reloaded)'
          : content;
      _loading = false;
    });
  }

  Future<void> _clearLog() async {
    await AppLogger.instance.clear();
    setState(() => _logContent = '(log cleared)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Diagnostics',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Log file path'),
            subtitle: Text(
              _logPath ?? '(not yet initialised — perform a full restart)',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: _logPath != null
                ? IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy path',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _logPath!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Path copied to clipboard')),
                      );
                    },
                  )
                : null,
          ),
          Row(
            children: [
              FilledButton.icon(
                onPressed: _loading ? null : _viewLog,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _clearLog,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear Log'),
              ),
            ],
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_logContent != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _logContent!,
                style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Colors.greenAccent),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
