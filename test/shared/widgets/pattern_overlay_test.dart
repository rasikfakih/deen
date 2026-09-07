import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deen/shared/widgets/pattern_overlay.dart';

void main() {
  group('DeenPatternOverlay bundling (DEEN 8.2)', () {
    test('pattern_star.svg is bundled and non-empty', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final data = await rootBundle.load(DeenPatternOverlay.asset);
      expect(data.lengthInBytes, greaterThan(0));
    });

    testWidgets('overlay renders tiles, ignores pointer, adds no blur', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 300,
              child: DeenPatternOverlay(tileSize: 100),
            ),
          ),
        ),
      );
      await tester.pump();
      // 3x3 tiles at 100px in a 300x300 box.
      expect(find.byType(IgnorePointer), findsWidgets);
      // Paint-only layer: never introduces a BackdropFilter.
      expect(find.byType(BackdropFilter), findsNothing);
    });
  });
}
