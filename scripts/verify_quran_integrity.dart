import 'dart:io';

import 'package:crypto/crypto.dart';

// Verifies SHA-256 checksums for bundled Quran data.
// Fails the build (exit 1) on any mismatch, prints
// "Quran Data Integrity Verified" on success.

const _checksumsPath = 'assets/data/checksums.sha256';

Future<void> main() async {
  final checksumsFile = File(_checksumsPath);
  if (!await checksumsFile.exists()) {
    stderr.writeln('Missing checksums file: $_checksumsPath');
    stderr.writeln('Run: dart run scripts/fetch_quran_data.dart');
    exit(1);
  }

  final lines = await checksumsFile.readAsLines();
  if (lines.isEmpty) {
    stderr.writeln('Empty checksums file: $_checksumsPath');
    exit(1);
  }

  var allOk = true;
  for (final rawLine in lines) {
    final line = rawLine.trim();
    if (line.isEmpty || line.startsWith('#')) continue;

    // Format: "<hash>  <path>" (sha256sum compat). Also tolerates single space.
    final parts = line.split(RegExp(r'\s+'));
    if (parts.length < 2) {
      stderr.writeln('Malformed line in $_checksumsPath: $rawLine');
      allOk = false;
      continue;
    }
    final expectedHash = parts[0].toLowerCase();
    // Path may contain spaces; re-join from index 1.
    final filePath = parts.sublist(1).join(' ').trim();
    // Tolerate both "assets/data/raw/quran_ar.json" and bare "quran_ar.json"
    final resolvedPath = await _resolvePath(filePath);

    final file = File(resolvedPath);
    if (!await file.exists()) {
      stderr.writeln('Missing data file: $resolvedPath (from $_checksumsPath)');
      allOk = false;
      continue;
    }

    final bytes = await file.readAsBytes();
    final actualHash = sha256.convert(bytes).toString().toLowerCase();

    if (actualHash != expectedHash) {
      stderr.writeln('Checksum MISMATCH for $resolvedPath');
      stderr.writeln('  expected: $expectedHash');
      stderr.writeln('  actual:   $actualHash');
      allOk = false;
    } else {
      stdout.writeln('Verified $resolvedPath : $actualHash');
    }
  }

  // Also ensure expected files exist even if not listed.
  for (final required in [
    'assets/data/raw/quran_ar.json',
    'assets/data/raw/quran_en.json',
  ]) {
    if (!await File(required).exists()) {
      stderr.writeln('Required data file missing: $required');
      allOk = false;
    }
  }

  if (!allOk) {
    stderr.writeln('Quran Data Integrity FAILED');
    exit(1);
  }

  stdout.writeln('Quran Data Integrity Verified');
}

Future<String> _resolvePath(String path) async {
  // If path is already correct, return it.
  if (await File(path).exists()) return path;
  // Try bare filename under assets/data/raw/
  final bare = path.split('/').last.split('\\').last;
  final candidate = 'assets/data/raw/$bare';
  if (await File(candidate).exists()) return candidate;
  // Also try assets/data/<bare>
  final candidate2 = 'assets/data/$bare';
  if (await File(candidate2).exists()) return candidate2;
  // Fallback to original path for error reporting.
  return path;
}
