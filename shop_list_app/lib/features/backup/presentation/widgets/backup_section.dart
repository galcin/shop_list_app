import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shop_list_app/features/backup/presentation/providers/backup_providers.dart';
import 'package:shop_list_app/features/meal_planning/presentation/providers/meal_plan_providers.dart';
import 'package:shop_list_app/features/pantry/presentation/providers/pantry_providers.dart';
import 'package:shop_list_app/features/product_category/presentation/providers/product_category_providers.dart';
import 'package:shop_list_app/features/products/presentation/providers/product_providers.dart';
import 'package:shop_list_app/features/recipes/presentation/providers/recipe_providers.dart';
import 'package:shop_list_app/shared/extensions/context_extensions.dart';

/// "Backup" rows for the settings page: export to a shareable JSON file and
/// import from one. Lives in its own widget so the settings page stays short.
class BackupSection extends ConsumerStatefulWidget {
  const BackupSection({super.key});

  @override
  ConsumerState<BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends ConsumerState<BackupSection> {
  bool _busy = false;

  Future<void> _export() async {
    setState(() => _busy = true);
    final result = await ref.read(exportBackupUseCaseProvider).call();
    if (!mounted) return;
    setState(() => _busy = false);

    await result.fold(
      (f) async => context.showSnackBar(f.message, isError: true),
      (export) async {
        await Share.shareXFiles(
          [XFile(export.filePath, mimeType: 'application/json')],
          subject: 'Shop List backup',
          text: 'Shop List backup: ${export.recipes} recipes, '
              '${export.shoppingLists} lists, ${export.pantryItems} pantry items.',
        );
      },
    );
  }

  Future<void> _import() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      dialogTitle: 'Choose a Shop List backup',
    );
    final path = picked?.files.single.path;
    if (path == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Import backup',
            style:
                TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: const Text(
          'Recipes, lists, pantry items and meal plans from the file will be '
          'added to your data. Nothing you already have is deleted.',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Import', style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    final result = await ref.read(importBackupUseCaseProvider).call(path);
    if (!mounted) return;
    setState(() => _busy = false);

    result.fold(
      (f) => context.showSnackBar(f.message, isError: true),
      (summary) {
        // Everything may have changed: refresh every list the app shows.
        ref.invalidate(recipeListProvider);
        ref.invalidate(recipeCategoriesProvider);
        ref.invalidate(productListProvider);
        ref.invalidate(productCategoryListProvider);
        ref.invalidate(pantryItemsProvider);
        ref.invalidate(weeklyMealPlanProvider);
        context.showSnackBar(summary.describe());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Backup',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        ListTile(
          contentPadding: EdgeInsets.zero,
          enabled: !_busy,
          leading: Icon(Icons.upload_file_outlined, color: colors.primary),
          title: const Text('Export data'),
          subtitle: const Text(
              'Save your recipes, lists, pantry and meal plans to a file'),
          trailing: _busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.chevron_right),
          onTap: _export,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          enabled: !_busy,
          leading: Icon(Icons.download_outlined, color: colors.primary),
          title: const Text('Import data'),
          subtitle: const Text('Restore from a previously exported file'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _import,
        ),
      ],
    );
  }
}
