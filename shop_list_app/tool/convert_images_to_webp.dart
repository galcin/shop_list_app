// ignore_for_file: avoid_print
//
// One-off / repeatable batch converter: JPEG & PNG -> WebP.
//
// Converts every raster image under:
//   - assets/images/recipes/
//   - assets/images/products_ai/
//   - assets/images/*.{jpg,jpeg,png} (the category "poster" images directly
//     under assets/images/, e.g. fruits_category.png)
//
// to lossy WebP, re-compressing to fit the project's 50KB-per-image budget
// (the same budget the generate_*_image*.dart scripts already enforce),
// then rewrites the matching path/filename references in:
//   - assets/data/recipes.json       (`imageUrl`)
//   - assets/data/products.json      (`image`)
//   - assets/data/product_categories.json (`imageName`)
//
// The original JPEG/PNG files are deleted after a successful conversion
// (nothing else in the repo depends on them — Flutter's Image.asset/
// Image.network decode by content, not by file extension).
//
// `assets/images/app_icon.png` and `app_icon.svg` are intentionally left
// untouched (consumed by flutter_launcher_icons, which expects PNG/SVG).
//
// Files that can't be decoded (e.g. AVIF/HEIF bytes saved with a `.jpg`
// extension) are reported at the end instead of failing the run — they
// need to be regenerated separately (see generate_recipe_image_flux.dart
// etc.) since this script only transcodes, it doesn't generate pixels.
//
// Conversion work (decode + encode) is spread across isolates (bounded by
// the number of CPU cores) since it's pure CPU work and embarrassingly
// parallel across hundreds of independent image files.
//
// Run from the project root:
//
//   dart run tool/convert_images_to_webp.dart
//   dart run tool/convert_images_to_webp.dart --dry-run
//   dart run tool/convert_images_to_webp.dart --quality 85 --budget-kb 50
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:image/image.dart' as img;

const List<String> _recipeDirs = ['assets/images/recipes'];
const List<String> _productDirs = ['assets/images/products_ai'];
const String _categoriesDir = 'assets/images';

const Set<String> _excludedRootFiles = {
  'app_icon.png',
  'app_icon.svg',
  '.gitkeep',
};

const String _recipesJsonPath = 'assets/data/recipes.json';
const String _productsJsonPath = 'assets/data/products.json';
const String _categoriesJsonPath = 'assets/data/product_categories.json';

Future<void> main(List<String> arguments) async {
  final args = _Args.parse(arguments);
  if (args.showHelp) {
    _printUsage();
    return;
  }

  final budgetBytes = args.budgetKb * 1024;
  final concurrency = Platform.numberOfProcessors.clamp(1, 16);

  // ── Gather candidate files ────────────────────────────────────────────
  final candidates = <File>[];
  for (final dir in [..._recipeDirs, ..._productDirs]) {
    final directory = Directory(dir);
    if (!directory.existsSync()) continue;
    candidates.addAll(
      directory
          .listSync()
          .whereType<File>()
          .where((f) => _isRasterImage(f.path)),
    );
  }
  final rootDir = Directory(_categoriesDir);
  if (rootDir.existsSync()) {
    candidates.addAll(
      rootDir.listSync().whereType<File>().where(
            (f) =>
                _isRasterImage(f.path) &&
                !_excludedRootFiles.contains(_basename(f.path)),
          ),
    );
  }
  candidates.sort((a, b) => a.path.compareTo(b.path));

  // Filter out files whose .webp target already exists (treated as "skip").
  var skipped = 0;
  final toProcess = <File>[];
  for (final file in candidates) {
    final newPath = _withWebpExtension(file.path);
    if (File(newPath).existsSync()) {
      stdout.writeln('Skip (target exists): $newPath');
      skipped++;
    } else {
      toProcess.add(file);
    }
  }

  stdout.writeln(
    'Found ${toProcess.length} image(s) to convert '
    '(skipping $skipped already-converted), using $concurrency worker(s)...\n',
  );

  // ── Convert concurrently, bounded by CPU count ────────────────────────
  var totalBefore = 0;
  var totalAfter = 0;
  var converted = 0;
  var failed = 0;
  final undecodable = <String>[];
  final renamed = <String, String>{};

  for (var i = 0; i < toProcess.length; i += concurrency) {
    final chunk = toProcess.skip(i).take(concurrency).toList();
    final results = await Future.wait(chunk.map((file) => Isolate.run(
          () => _convertWorker(
            _WorkerInput(
              path: file.path,
              quality: args.quality,
              budgetBytes: budgetBytes,
            ),
          ),
        )));

    for (final result in results) {
      if (!result.success) {
        if (result.undecodable) {
          undecodable.add(result.path);
        } else {
          stderr.writeln('Failed to convert ${result.path}: ${result.error}');
        }
        failed++;
        continue;
      }

      final newPath = _withWebpExtension(result.path);
      if (args.dryRun) {
        stdout.writeln(
          '[dry-run] would convert ${result.path} '
          '(${_formatBytes(result.beforeBytes)}) -> $newPath '
          '(${_formatBytes(result.webpBytes!.length)})',
        );
      } else {
        await File(newPath).writeAsBytes(result.webpBytes!);
        await File(result.path).delete();
        stdout.writeln(
          '${result.path} (${_formatBytes(result.beforeBytes)}) -> $newPath '
          '(${_formatBytes(result.webpBytes!.length)})',
        );
      }
      converted++;
      totalBefore += result.beforeBytes;
      totalAfter += result.webpBytes!.length;
      renamed[_normalize(result.path)] = _normalize(newPath);
    }
  }

  stdout.writeln(
    '\nConverted: $converted, skipped (already webp): $skipped, failed: $failed.',
  );
  if (converted > 0) {
    stdout.writeln(
      'Size: ${_formatBytes(totalBefore)} -> ${_formatBytes(totalAfter)} '
      '(${_percentSaved(totalBefore, totalAfter)} smaller).',
    );
  }
  if (undecodable.isNotEmpty) {
    stdout.writeln(
      '\n${undecodable.length} file(s) could not be decoded (likely AVIF/HEIF '
      'bytes saved with the wrong extension) and were left untouched — '
      'regenerate these via generate_recipe_image_flux.dart / '
      'generate_recipe_image.dart --force:',
    );
    for (final path in undecodable) {
      stdout.writeln('  - $path');
    }
  }

  if (args.dryRun) {
    stdout.writeln('\n[dry-run] JSON files were not modified.');
    return;
  }

  final recipesChanged =
      await _rewriteJsonField(_recipesJsonPath, 'imageUrl', renamed);
  final productsChanged =
      await _rewriteJsonField(_productsJsonPath, 'image', renamed);
  final categoriesChanged = await _rewriteJsonField(
    _categoriesJsonPath,
    'imageName',
    renamed,
    pathPrefix: 'assets/images/',
  );

  stdout.writeln(
    'Updated JSON references — recipes.json: $recipesChanged, '
    'products.json: $productsChanged, product_categories.json: '
    '$categoriesChanged.',
  );
}

bool _isRasterImage(String path) {
  final lower = path.toLowerCase();
  return lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.png');
}

String _basename(String path) => path.split(Platform.pathSeparator).last;

String _withWebpExtension(String path) {
  final dot = path.lastIndexOf('.');
  final withoutExt = dot == -1 ? path : path.substring(0, dot);
  return '$withoutExt.webp';
}

/// Normalizes a filesystem path to the forward-slash, project-root-relative
/// form used inside the JSON seed files (e.g.
/// `assets/images/recipes/egg-omelet.jpg`).
String _normalize(String path) {
  final cwd = Directory.current.path.replaceAll('\\', '/');
  var p = path.replaceAll('\\', '/');
  if (p.startsWith(cwd)) {
    p = p.substring(cwd.length);
    if (p.startsWith('/')) p = p.substring(1);
  }
  return p;
}

/// Input sent to the isolate running [_convertWorker]. Must only contain
/// simple, isolate-sendable values.
class _WorkerInput {
  _WorkerInput({
    required this.path,
    required this.quality,
    required this.budgetBytes,
  });

  final String path;
  final int quality;
  final int budgetBytes;
}

class _WorkerResult {
  _WorkerResult.ok(this.path, this.beforeBytes, this.webpBytes)
      : success = true,
        undecodable = false,
        error = null;

  _WorkerResult.decodeFailure(this.path)
      : success = false,
        undecodable = true,
        beforeBytes = 0,
        webpBytes = null,
        error = null;

  _WorkerResult.failure(this.path, this.error)
      : success = false,
        undecodable = false,
        beforeBytes = 0,
        webpBytes = null;

  final String path;
  final bool success;
  final bool undecodable;
  final int beforeBytes;
  final List<int>? webpBytes;
  final String? error;
}

/// Runs inside a spawned isolate: decodes [input.path] and re-encodes it as
/// lossy WebP under [input.budgetBytes]. Does not touch the original file
/// (reading only) so it's safe to run many of these concurrently.
Future<_WorkerResult> _convertWorker(_WorkerInput input) async {
  try {
    final file = File(input.path);
    final beforeBytes = await file.length();
    final rawBytes = await file.readAsBytes();
    final image = img.decodeImage(rawBytes);
    if (image == null) {
      return _WorkerResult.decodeFailure(input.path);
    }

    final capped = _capDimensions(image, maxDimension: 1024);
    final webpBytes = _compressToWebP(
      capped,
      maxBytes: input.budgetBytes,
      startQuality: input.quality,
    );
    return _WorkerResult.ok(input.path, beforeBytes, webpBytes);
  } catch (e) {
    return _WorkerResult.failure(input.path, e.toString());
  }
}

/// Downscales [image] so neither dimension exceeds [maxDimension],
/// preserving aspect ratio. Returns [image] unchanged if it already fits —
/// this is only meant to cap unnecessarily huge originals (e.g. multi-MB
/// stock photos) before the quality-based compression loop runs, since
/// none of these images are ever displayed larger than a few hundred
/// logical pixels in the app.
img.Image _capDimensions(img.Image image, {required int maxDimension}) {
  if (image.width <= maxDimension && image.height <= maxDimension) {
    return image;
  }
  if (image.width >= image.height) {
    return img.copyResize(image, width: maxDimension);
  }
  return img.copyResize(image, height: maxDimension);
}

/// Encodes [image] as lossy WebP, stepping down quality and (if that's not
/// enough) image dimensions until the result is at or under [maxBytes].
///
/// Uses WebP encoder `method: 4` (the library's default effort level)
/// rather than `6` — at the quality levels used here the size difference is
/// only a few percent, but method 6 is roughly twice as slow, which adds up
/// across hundreds of images.
List<int> _compressToWebP(
  img.Image image, {
  required int maxBytes,
  int startQuality = 82,
}) {
  final qualities = <int>{
    startQuality,
    78,
    65,
    50,
    35,
    20,
  }.where((q) => q > 0 && q <= 100).toList()
    ..sort((a, b) => b.compareTo(a));

  var current = image;

  for (var pass = 0; pass < 8; pass++) {
    for (final quality in qualities) {
      final bytes = img.encodeWebP(
        current,
        lossless: false,
        quality: quality,
        method: 4,
      );
      if (bytes.length <= maxBytes) {
        return bytes;
      }
    }

    final newWidth = (current.width * 0.8).round();
    final newHeight = (current.height * 0.8).round();
    if (newWidth < 80 || newHeight < 60) break;
    current = img.copyResize(current, width: newWidth, height: newHeight);
  }

  // Last resort: whatever we could produce at the smallest size/quality.
  return img.encodeWebP(current, lossless: false, quality: 10, method: 4);
}

/// Rewrites every occurrence of an old asset path with its new `.webp` path
/// inside [field] of every object in the JSON array at [jsonPath]. Returns
/// the number of entries changed.
///
/// Some fields (e.g. `product_categories.json`'s `imageName`) store a bare
/// filename rather than a full `assets/images/...` path; [pathPrefix] is
/// prepended before the [renamed] lookup and stripped back off the result
/// in that case.
Future<int> _rewriteJsonField(
  String jsonPath,
  String field,
  Map<String, String> renamed, {
  String pathPrefix = '',
}) async {
  if (renamed.isEmpty) return 0;
  final file = File(jsonPath);
  if (!file.existsSync()) return 0;

  final decoded = jsonDecode(await file.readAsString());
  if (decoded is! List) return 0;

  var changedCount = 0;
  for (final entry in decoded) {
    if (entry is! Map) continue;
    final map = entry.cast<String, dynamic>();
    final value = map[field] as String?;
    if (value == null) continue;
    final lookupKey = pathPrefix.isEmpty ? value : '$pathPrefix$value';
    final newValue = renamed[_normalize(lookupKey)];
    if (newValue == null) continue;
    final newField =
        pathPrefix.isEmpty ? newValue : newValue.replaceFirst(pathPrefix, '');
    if (newField != value) {
      map[field] = newField;
      changedCount++;
    }
  }

  if (changedCount > 0) {
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString('${encoder.convert(decoded)}\n');
  }
  return changedCount;
}

String _formatBytes(int bytes) => '${(bytes / 1024).toStringAsFixed(1)} KB';

String _percentSaved(int before, int after) {
  if (before <= 0) return '0%';
  final pct = (1 - (after / before)) * 100;
  return '${pct.toStringAsFixed(1)}%';
}

void _printUsage() {
  stdout.writeln('''
Batch image converter — JPEG/PNG -> WebP
-----------------------------------------
Converts every recipe, product and category image under assets/images/ from
JPEG/PNG to lossy WebP (re-compressed to fit the project's image budget) and
updates the matching references in assets/data/*.json. Deletes the original
files after a successful conversion.

Usage:
  dart run tool/convert_images_to_webp.dart [--quality N] [--budget-kb N] [--dry-run]

Options:
  --quality     Starting WebP quality to try, 0-100 (default: 82).
  --budget-kb   Maximum output file size in KB (default: 50).
  --dry-run     Show what would be converted without writing/deleting files
                or touching the JSON seed files.
  -h, --help    Show this help message.
''');
}

class _Args {
  _Args({
    this.quality = 82,
    this.budgetKb = 50,
    this.dryRun = false,
    this.showHelp = false,
  });

  final int quality;
  final int budgetKb;
  final bool dryRun;
  final bool showHelp;

  static _Args parse(List<String> arguments) {
    var quality = 82;
    var budgetKb = 50;
    var dryRun = false;
    var showHelp = false;

    var i = 0;
    while (i < arguments.length) {
      final arg = arguments[i];
      if (arg == '--quality' && i + 1 < arguments.length) {
        quality = int.tryParse(arguments[++i]) ?? quality;
      } else if (arg == '--budget-kb' && i + 1 < arguments.length) {
        budgetKb = int.tryParse(arguments[++i]) ?? budgetKb;
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
      quality: quality,
      budgetKb: budgetKb,
      dryRun: dryRun,
      showHelp: showHelp,
    );
  }
}
