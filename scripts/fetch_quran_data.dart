import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

// Fetches verified Quran text (Uthmani) and Sahih International translation
// from the most reliable open sources (fawazahmed0/quran-api CDN mirrors
// tanzil + quranenc) and writes bundled assets with SHA-256 checksums.
//
// Religious content is preserved VERBATIM -- no rewriting, translation, or
// modification. See DEEN_AI_CONTEXT.md section 3.

const _arUrls = <String>[
  // Primary: jsDelivr CDN (version-pinned @1)
  'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/editions/ara-quranuthmanihaf.json',
  // Fallbacks: raw GitHub
  'https://raw.githubusercontent.com/fawazahmed0/quran-api/1/editions/ara-quranuthmanihaf.json',
  'https://raw.githubusercontent.com/fawazahmed0/quran-api/master/editions/ara-quranuthmanihaf.json',
];

const _enUrls = <String>[
  // Sahih International is authored by Umm Muhammad in this dataset.
  'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/editions/eng-ummmuhammad.json',
  'https://raw.githubusercontent.com/fawazahmed0/quran-api/1/editions/eng-ummmuhammad.json',
  'https://raw.githubusercontent.com/fawazahmed0/quran-api/master/editions/eng-ummmuhammad.json',
];

const _arOut = 'assets/data/raw/quran_ar.json';
const _enOut = 'assets/data/raw/quran_en.json';
const _checksumsOut = 'assets/data/checksums.sha256';

Future<void> main() async {
  stdout.writeln('Deen: fetching Quran data...');
  stdout.writeln('  Arabic candidates: $_arUrls');
  stdout.writeln('  English candidates: $_enUrls');

  final arBytes = await _fetchWithFallback(
    _arUrls,
    label: 'Arabic Uthmani (ara-quranuthmanihaf)',
  );
  final enBytes = await _fetchWithFallback(
    _enUrls,
    label: 'English Sahih International (eng-ummmuhammad)',
  );

  // Validate JSON and count verses.
  final arCount = _validateAndCount(arBytes, label: 'Arabic');
  final enCount = _validateAndCount(enBytes, label: 'English');
  stdout.writeln('Validated: Arabic verses=$arCount, English verses=$enCount');
  if (arCount != 6236) {
    stderr.writeln(
      'Warning: Arabic verse count is $arCount, expected 6236. '
      'Source may bundle Basmala differently; proceeding verbatim.',
    );
  }
  if (enCount != 6236) {
    stderr.writeln(
      'Warning: English verse count is $enCount, expected 6236. '
      'Proceeding verbatim.',
    );
  }

  // Ensure directories exist.
  await Directory('assets/data/raw').create(recursive: true);
  await Directory('assets/data').create(recursive: true);

  // Write verbatim bytes.
  await File(_arOut).writeAsBytes(arBytes);
  await File(_enOut).writeAsBytes(enBytes);
  stdout.writeln('Wrote $_arOut (${arBytes.length} bytes)');
  stdout.writeln('Wrote $_enOut (${enBytes.length} bytes)');

  // Compute SHA-256.
  final arHash = sha256.convert(arBytes).toString();
  final enHash = sha256.convert(enBytes).toString();
  stdout.writeln('SHA-256 quran_ar.json: $arHash');
  stdout.writeln('SHA-256 quran_en.json: $enHash');

  // Write checksums file in sha256sum-compatible format.
  // Uses relative paths so verification can resolve correctly.
  final checksumContent = '$arHash  $_arOut\n$enHash  $_enOut\n';
  await File(_checksumsOut).writeAsString(checksumContent);
  stdout.writeln('Wrote $_checksumsOut');
  stdout.writeln(
    'Fetch complete. Run: dart run scripts/verify_quran_integrity.dart',
  );
}

Future<List<int>> _fetchWithFallback(
  List<String> urls, {
  required String label,
}) async {
  Object? lastError;
  for (final url in urls) {
    try {
      stdout.writeln('Fetching $label from $url ...');
      final uri = Uri.parse(url);
      final response = await http
          .get(
            uri,
            headers: {
              'User-Agent': 'Deen/1.0 (+https://github.com/rasikfakih/deen)',
            },
          )
          .timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        if (bytes.isEmpty) {
          throw HttpException('Empty response from $url');
        }
        // Quick JSON sanity.
        final decoded = jsonDecode(utf8.decode(bytes));
        if (decoded is! Map || !decoded.containsKey('quran')) {
          throw FormatException('Unexpected JSON structure from $url');
        }
        stdout.writeln('  OK: ${bytes.length} bytes from $url');
        return bytes;
      } else {
        stderr.writeln('  HTTP ${response.statusCode} from $url');
        lastError = HttpException('HTTP ${response.statusCode} from $url');
      }
    } catch (e) {
      stderr.writeln('  Failed $url: $e');
      lastError = e;
    }
  }
  stderr.writeln('All candidates failed for $label');
  throw StateError('Failed to fetch $label: $lastError');
}

int _validateAndCount(List<int> bytes, {required String label}) {
  final text = utf8.decode(bytes);
  final decoded = jsonDecode(text) as Map<String, dynamic>;
  final quran = decoded['quran'];
  if (quran is! List) {
    throw FormatException('Invalid $label JSON: missing quran array');
  }
  return quran.length;
}
