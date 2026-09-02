import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:deen/core/utils/deen_icons.dart';

void main() {
  group('DeenIcons registry completeness', () {
    test('all constants are unique and well-formed', () {
      final all = DeenIcons.all;
      expect(all.length, 41, reason: 'registry must contain 41 ic_* entries');
      expect(all.toSet().length, all.length, reason: 'no duplicate paths');
      for (final p in all) {
        expect(
          p.startsWith('assets/icons/ic_'),
          isTrue,
          reason: '$p must start with assets/icons/ic_',
        );
        expect(p.endsWith('.svg'), isTrue, reason: '$p must end with .svg');
      }
    });

    test('every DeenIcons constant resolves to existing asset file', () {
      for (final path in DeenIcons.all) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: 'missing asset $path');
      }
    });

    test(
      'every file in assets/icons/ is registered in DeenIcons (no orphans)',
      () {
        final dir = Directory('assets/icons');
        expect(dir.existsSync(), isTrue, reason: 'assets/icons must exist');
        final files = dir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.svg'))
            .map((f) => f.path.replaceAll('\\', '/'))
            .toList();
        // Normalize to assets/icons/... form
        final normalized = files.map((p) {
          final idx = p.indexOf('assets/icons/');
          return idx >= 0 ? p.substring(idx) : p;
        }).toSet();

        final registered = DeenIcons.all.toSet();
        final orphanFiles = normalized.difference(registered);
        final missingRegistrations = registered.difference(normalized);

        expect(
          orphanFiles,
          isEmpty,
          reason: 'orphan files not in registry: $orphanFiles',
        );
        expect(
          missingRegistrations,
          isEmpty,
          reason: 'registry entries missing file: $missingRegistrations',
        );
      },
    );

    test('ic_home, ic_quran, ic_qibla, ic_tasbih present for nav', () {
      expect(DeenIcons.all, contains(DeenIcons.ic_home));
      expect(DeenIcons.all, contains(DeenIcons.ic_quran));
      expect(DeenIcons.all, contains(DeenIcons.ic_qibla));
      expect(DeenIcons.all, contains(DeenIcons.ic_tasbih));
    });

    test(
      'stroke spec: placeholder SVGs contain stroke currentColor and width 1.8',
      () {
        for (final path in DeenIcons.all.take(5)) {
          final content = File(path).readAsStringSync();
          expect(
            content.contains('stroke="currentColor"'),
            isTrue,
            reason: '$path missing currentColor',
          );
          expect(
            content.contains('stroke-width="1.8"'),
            isTrue,
            reason: '$path missing 1.8',
          );
          expect(
            content.contains('viewBox="0 0 24 24"'),
            isTrue,
            reason: '$path missing viewBox',
          );
        }
      },
    );
  });
}
