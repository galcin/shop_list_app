import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_list_app/core/theme/app_theme.dart';
import 'package:shop_list_app/core/theme/theme_simple.dart';
import 'package:shop_list_app/features/pantry/presentation/providers/pantry_providers.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  @override
  Widget build(BuildContext context) {
    final selectedTheme = ref.watch(appThemeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Appearance',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          SegmentedButton<AppThemeType>(
            segments: const [
              ButtonSegment<AppThemeType>(
                value: AppThemeType.dark,
                icon: Icon(Icons.dark_mode_outlined),
                label: Text('Dark'),
              ),
              ButtonSegment<AppThemeType>(
                value: AppThemeType.light,
                icon: Icon(Icons.light_mode_outlined),
                label: Text('Light'),
              ),
              ButtonSegment<AppThemeType>(
                value: AppThemeType.green,
                icon: Icon(Icons.eco_outlined),
                label: Text('Green'),
              ),
            ],
            selected: {selectedTheme},
            onSelectionChanged: (selection) {
              final themeType = selection.first;
              ref.read(appThemeProvider.notifier).setTheme(themeType);
            },
          ),
          const Divider(),
          const SizedBox(height: 8),
          // ── Catalogue ──────────────────────────────────────────────────
          const Text(
            'Catalogue',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.category_outlined),
            title: const Text('Product Categories'),
            subtitle: const Text('Manage categories and products'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/categories'),
          ),
          const Divider(),
          const SizedBox(height: 8),
          // ── Data management ─────────────────────────────────────────────
          const Text(
            'Data',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
            title: const Text('Clear Pantry'),
            subtitle: const Text('Remove all items from your pantry'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear Pantry'),
                  content: const Text(
                      'This will permanently delete all pantry items. This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              );
              if (confirm == true && mounted) {
                await ref.read(pantryItemsProvider.notifier).clearAll();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pantry cleared'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
          ),
          const Divider(),
          const SizedBox(height: 8),
          // ── Diagnostics ──────────────────────────────────────────────────
          const Text('Diagnostics',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.bug_report_outlined),
            title: const Text('View Logs'),
            subtitle: const Text('Application diagnostics and logs'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/diagnostics'),
          ),
        ],
      ),
    );
  }
}
