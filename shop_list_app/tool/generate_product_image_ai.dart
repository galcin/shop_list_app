// ignore_for_file: avoid_print
//
// Product AI image generator.
//
// Mirrors tool/generate_recipe_image_ai.dart but targets the default
// products that are seeded with an emoji "icon" (the `photo` field in
// lib/core/database/seeder/product_seeder.dart) instead of a real photo.
// Requests an AI-generated product photo for each one from Pollinations.ai
// (https://pollinations.ai) — a free, no-API-key-required text-to-image
// HTTP endpoint — then compresses the result to fit the project's 50KB
// image budget before saving it to disk under assets/images/products_ai/.
//
// This script does not modify any product data (the seeder's `photo`
// emoji field is left untouched) — it only generates image files.
//
// Requires internet access. If a request fails (no network, service down,
// rate limited past retries, etc.) the script reports the error for that
// product and continues with the rest.
//
// Run from the project root:
//
//   dart run tool/generate_product_image_ai.dart --all
//   dart run tool/generate_product_image_ai.dart --name "Apples" --category "Fruits"
//
// Use --help for full usage details.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Hard size budget every generated product image must respect.
const int _maxBytes = 50 * 1024;

const int _requestSize = 768;

const String _imagesDir = 'assets/images/products_ai';

/// The default products seeded in lib/core/database/seeder/product_seeder.dart
/// that currently only have an emoji "icon" (no real photo). Kept in sync
/// manually with that file's `name` / `productCategoryId` (mapped to the
/// category name for prompt context) pairs.
const List<Map<String, String>> _defaultProducts = [
  {'name': 'Apples', 'category': 'Fruits'},
  {'name': 'Bananas', 'category': 'Fruits'},
  {'name': 'Carrots', 'category': 'Vegetables'},
  {'name': 'Tomatoes', 'category': 'Vegetables'},
  {'name': 'Milk', 'category': 'Dairy'},
  {'name': 'Cheese', 'category': 'Dairy'},
  {'name': 'Bread', 'category': 'Bakery'},
  {'name': 'Chicken Breast', 'category': 'Meat'},
  {'name': 'Orange Juice', 'category': 'Beverages'},
  {'name': 'Potato Chips', 'category': 'Snacks'},
  {'name': 'Eggs', 'category': 'Dairy'},
  {'name': 'Butter', 'category': 'Dairy'},
  {'name': 'Sour Cream', 'category': 'Dairy'},
  {'name': 'Cooking Cream', 'category': 'Dairy'},
  {'name': 'Fresh Mozzarella', 'category': 'Dairy'},
  {'name': 'Parmesan', 'category': 'Dairy'},
  {'name': 'Minced Beef', 'category': 'Meat'},
  {'name': 'Bacon', 'category': 'Meat'},
  {'name': 'Turkey Breast', 'category': 'Meat'},
  {'name': 'Pressed Ham', 'category': 'Meat'},
  {'name': 'Onion', 'category': 'Vegetables'},
  {'name': 'Garlic', 'category': 'Vegetables'},
  {'name': 'Celery', 'category': 'Vegetables'},
  {'name': 'Zucchini', 'category': 'Vegetables'},
  {'name': 'Potatoes', 'category': 'Vegetables'},
  {'name': 'Bell Peppers', 'category': 'Vegetables'},
  {'name': 'Broccoli', 'category': 'Vegetables'},
  {'name': 'Lettuce', 'category': 'Vegetables'},
  {'name': 'Cucumber', 'category': 'Vegetables'},
  {'name': 'Cherry Tomatoes', 'category': 'Vegetables'},
  {'name': 'Mushrooms', 'category': 'Vegetables'},
  {'name': 'Frozen Vegetables', 'category': 'Vegetables'},
  {'name': 'Lemon', 'category': 'Fruits'},
  {'name': 'Flatbread', 'category': 'Bakery'},
  {'name': 'Puff Pastry Dough', 'category': 'Bakery'},
  {'name': 'Spaghetti', 'category': 'Snacks'},
  {'name': 'Pasta', 'category': 'Snacks'},
  {'name': 'Noodles', 'category': 'Snacks'},
  {'name': 'Rice', 'category': 'Snacks'},
  {'name': 'Flour', 'category': 'Snacks'},
  {'name': 'Rolled Oats', 'category': 'Snacks'},
  {'name': 'Honey', 'category': 'Snacks'},
  {'name': 'Olive Oil', 'category': 'Snacks'},
  {'name': 'Vegetable Oil', 'category': 'Snacks'},
  {'name': 'Soy Sauce', 'category': 'Snacks'},
  {'name': 'Oyster Sauce', 'category': 'Snacks'},
  {'name': 'Tomato Sauce', 'category': 'Snacks'},
  {'name': 'Tomato Paste', 'category': 'Snacks'},
  {'name': 'Crushed Tomatoes', 'category': 'Snacks'},
  {'name': 'Vegetable Broth', 'category': 'Snacks'},
  {'name': 'Canned Tuna', 'category': 'Snacks'},
  {'name': 'Canned Corn', 'category': 'Snacks'},
  {'name': 'Canned Mushrooms', 'category': 'Snacks'},
  {'name': 'Olives', 'category': 'Snacks'},
];

Future<void> main(List<String> arguments) async {
  final args = _Args.parse(arguments);

  if (args.showHelp) {
    _printUsage();
    return;
  }

  if (args.processAll) {
    await _processAllProducts(
      force: args.force,
      dryRun: args.dryRun,
      imagesDir: args.dir ?? _imagesDir,
    );
    return;
  }

  if (args.name == null || args.name!.trim().isEmpty) {
    stderr.writeln('Error: --name is required unless --all is used.\n');
    _printUsage();
    exitCode = 64;
    return;
  }

  final name = args.name!;
  final slug = _slugify(name);
  final outPath = args.out ?? '${args.dir ?? _imagesDir}/$slug.jpg';

  try {
    final bytes = await _generateProductImageBytes(
      name: name,
      category: args.category ?? '',
    );

    final file = File(outPath);
    await file.create(recursive: true);
    await file.writeAsBytes(bytes);

    stdout.writeln(
      'Generated ${file.path} (${_formatBytes(bytes.length)}, budget ${_formatBytes(_maxBytes)})',
    );
  } catch (e) {
    stderr.writeln('Error generating image for "$name": $e');
    exitCode = 1;
  }
}

/// Generates an AI image for every entry in [_defaultProducts] whose output
/// file doesn't exist yet under [imagesDir] (or for all products when
/// [force] is true).
Future<void> _processAllProducts({
  required bool force,
  required bool dryRun,
  String imagesDir = _imagesDir,
}) async {
  await Directory(imagesDir).create(recursive: true);

  var generatedCount = 0;
  var skippedCount = 0;
  var failedCount = 0;
  var isFirstRequest = true;

  for (final entry in _defaultProducts) {
    final name = entry['name']!;
    final category = entry['category'] ?? '';
    final slug = _slugify(name);
    final imageUrl = '$imagesDir/$slug.jpg';

    final imageFile = File(imageUrl);
    if (imageFile.existsSync() && !force) {
      skippedCount++;
      continue;
    }

    if (dryRun) {
      stdout.writeln('[dry-run] would generate $imageUrl for "$name"');
      generatedCount++;
      continue;
    }

    // Anonymous Pollinations.ai requests are rate-limited to roughly one
    // per 15 seconds; space requests out to avoid tripping that limit.
    if (!isFirstRequest) {
      await Future<void>.delayed(const Duration(seconds: 16));
    }
    isFirstRequest = false;

    try {
      final bytes = await _generateProductImageBytes(
        name: name,
        category: category,
      );
      await imageFile.create(recursive: true);
      await imageFile.writeAsBytes(bytes);
      generatedCount++;
      stdout.writeln(
        'Generated $imageUrl (${_formatBytes(bytes.length)}) for "$name"',
      );
    } catch (e) {
      failedCount++;
      stderr.writeln('Failed to generate image for "$name": $e');
    }
  }

  stdout.writeln(
    'Done. Generated: $generatedCount, skipped (already existed): '
    '$skippedCount, failed: $failedCount.',
  );
}

/// Requests an AI-generated product photo for [name]/[category] from
/// Pollinations.ai and compresses it to fit [_maxBytes].
Future<List<int>> _generateProductImageBytes({
  required String name,
  required String category,
}) async {
  final prompt = _buildPrompt(name: name, category: category);
  final rawBytes = await _fetchImage(prompt: prompt, seed: _hash(name).abs());

  final image = img.decodeImage(Uint8List.fromList(rawBytes));
  if (image == null) {
    throw StateError('Could not decode image returned by the AI service.');
  }

  return _compressToBudget(image);
}

/// Builds a clean product-photography style prompt describing the item.
String _buildPrompt({required String name, required String category}) {
  final buffer = StringBuffer(
    'professional product photography of $name grocery item, '
    'isolated on a clean white background, studio lighting',
  );
  if (category.trim().isNotEmpty) {
    buffer.write(', ${category.trim()} category');
  }
  buffer.write(
    ', centered composition, high detail, 4k, no text, no watermark',
  );
  return buffer.toString();
}

/// Fetches an image from the Pollinations.ai text-to-image endpoint.
/// No API key is required. Throws on network/HTTP errors.
Future<List<int>> _fetchImage({
  required String prompt,
  required int seed,
}) async {
  final encodedPrompt = Uri.encodeComponent(prompt);
  // Note: `nologo=true` is intentionally omitted — Pollinations.ai now
  // requires a registered/paid account for that flag and responds with
  // HTTP 402 (Payment Required) for anonymous requests that include it.
  final uri = Uri.parse(
    'https://image.pollinations.ai/prompt/$encodedPrompt'
    '?width=$_requestSize&height=$_requestSize&seed=$seed',
  );

  const maxAttempts = 4;
  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 30);
    try {
      final request = await client.getUrl(uri);
      final response = await request.close().timeout(
            const Duration(seconds: 90),
          );

      if (response.statusCode != 200) {
        // Drain the response body so the connection can be reused/closed.
        await response.drain<void>();
        final retryable = response.statusCode == 402 ||
            response.statusCode == 429 ||
            response.statusCode >= 500;
        if (retryable && attempt < maxAttempts) {
          final backoff = Duration(seconds: 5 * attempt);
          stdout.writeln(
            '  (status ${response.statusCode}, retrying in '
            '${backoff.inSeconds}s, attempt $attempt/$maxAttempts)',
          );
          await Future<void>.delayed(backoff);
          continue;
        }
        throw HttpException(
          'Request failed with status ${response.statusCode}',
          uri: uri,
        );
      }

      final bytes = <int>[];
      await for (final chunk in response) {
        bytes.addAll(chunk);
      }
      if (bytes.isEmpty) {
        throw StateError('Received an empty response body.');
      }
      return bytes;
    } finally {
      client.close(force: true);
    }
  }

  // Unreachable: the loop above always returns or throws.
  throw StateError('Failed to fetch image after $maxAttempts attempts.');
}

/// Encodes [image] as JPEG, stepping down quality and (if that's not
/// enough) image dimensions until the result is at or under [maxBytes].
List<int> _compressToBudget(img.Image image, {int maxBytes = _maxBytes}) {
  const qualities = [92, 85, 78, 70, 62, 54, 46, 38, 30, 22, 15];
  var current = image;

  for (var pass = 0; pass < 5; pass++) {
    for (final quality in qualities) {
      final bytes = img.encodeJpg(current, quality: quality);
      if (bytes.length <= maxBytes) {
        return bytes;
      }
    }

    final newWidth = (current.width * 0.8).round();
    final newHeight = (current.height * 0.8).round();
    if (newWidth < 120 || newHeight < 90) break;
    current = img.copyResize(current, width: newWidth, height: newHeight);
  }

  // Last resort: whatever we could produce at the smallest size/quality.
  return img.encodeJpg(current, quality: 12);
}

/// Simple string hash (djb2-like) used to deterministically seed the
/// image request so re-runs for the same product tend to produce a
/// consistent-ish result.
int _hash(String s) {
  var h = 0;
  for (final codeUnit in s.codeUnits) {
    h = 0x1fffffff & (h + codeUnit);
    h = 0x1fffffff & (h + ((0x0007ffff & h) << 10));
    h ^= (h >> 6);
  }
  h = 0x1fffffff & (h + ((0x03ffffff & h) << 3));
  h ^= (h >> 11);
  h = 0x1fffffff & (h + ((0x00003fff & h) << 15));
  return h;
}

/// Converts a product name into the lowercase, hyphen-separated filename
/// convention used throughout `assets/images/` (e.g. "Chicken Breast" ->
/// "chicken-breast").
String _slugify(String input) {
  final lower = input.toLowerCase().trim();
  final replaced = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  final collapsed = replaced.replaceAll(RegExp(r'-+'), '-');
  return collapsed.replaceAll(RegExp(r'^-|-$'), '');
}

String _formatBytes(int bytes) => '${(bytes / 1024).toStringAsFixed(1)} KB';

void _printUsage() {
  stdout.writeln('''
Product AI image generator
---------------------------
Requests a real AI-generated product photo for each default seeded product
that currently only has an emoji icon, from Pollinations.ai (free, no API
key needed), and compresses it to fit the project's 50KB image budget.
Requires internet access. Run from the project root.

Usage:
  dart run tool/generate_product_image_ai.dart --all [--dir path] [--force] [--dry-run]
      Generate an AI image for every product in the built-in list whose
      output file is missing (or all of them with --force).

  dart run tool/generate_product_image_ai.dart --name "Product Name" [--category "Category"] [--dir path] [--out path]
      Generate a single AI image for the given product. Defaults to
      assets/images/products_ai/<slug>.jpg if --out/--dir are omitted.

Options:
  --all           Process every product in the built-in list.
  --force         Regenerate images even if a file already exists (with --all).
  --dry-run       Show what would be generated without writing files (with --all).
  --dir           Output directory for generated images (default: assets/images/products_ai).
  --name          Product name (required unless --all is given).
  --category      Product category, used to steer the prompt.
  --out           Output file path (single-product mode only).
  -h, --help      Show this help message.
''');
}

class _Args {
  _Args({
    this.name,
    this.category,
    this.out,
    this.dir,
    this.processAll = false,
    this.force = false,
    this.dryRun = false,
    this.showHelp = false,
  });

  final String? name;
  final String? category;
  final String? out;
  final String? dir;
  final bool processAll;
  final bool force;
  final bool dryRun;
  final bool showHelp;

  static _Args parse(List<String> arguments) {
    String? name;
    String? category;
    String? out;
    String? dir;
    var processAll = false;
    var force = false;
    var dryRun = false;
    var showHelp = false;

    var i = 0;
    while (i < arguments.length) {
      final arg = arguments[i];
      if (arg == '--name' && i + 1 < arguments.length) {
        name = arguments[++i];
      } else if (arg == '--category' && i + 1 < arguments.length) {
        category = arguments[++i];
      } else if (arg == '--out' && i + 1 < arguments.length) {
        out = arguments[++i];
      } else if (arg == '--dir' && i + 1 < arguments.length) {
        dir = arguments[++i];
      } else if (arg == '--all') {
        processAll = true;
      } else if (arg == '--force') {
        force = true;
      } else if (arg == '--dry-run') {
        dryRun = true;
      } else if (arg == '--help' || arg == '-h') {
        showHelp = true;
      } else {
        stderr.writeln('Warning: unrecognized argument "$arg" ignored.');
      }
      i++;
    }

    return _Args(
      name: name,
      category: category,
      out: out,
      dir: dir,
      processAll: processAll,
      force: force,
      dryRun: dryRun,
      showHelp: showHelp,
    );
  }
}
