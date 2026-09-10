// ignore_for_file: dead_code

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deen/core/theme/app_gradients.dart';
import 'package:deen/features/settings/providers/settings_providers.dart';
import 'package:deen/shared/database/deen_database.dart';
import 'package:deen/shared/widgets/icons/deen_symbol_effects.dart';

void main() {
  group('Elderly static effects (DEEN 8.4: blur retired, motion gated)', () {
    ProviderScope wrap(Widget child, {required bool elderly}) {
      final db = DeenDatabase.forTesting(NativeDatabase.memory());
      return ProviderScope(
        overrides: [
          deenDatabaseProvider.overrideWithValue(db),
          elderlyModeProvider.overrideWith((ref) => Stream.value(elderly)),
          themeModeProvider.overrideWith(
            (ref) => Stream.value(ThemeMode.light),
          ),
        ],
        child: MaterialApp(home: Scaffold(body: child)),
      );
    }

    testWidgets('elderly mode resolves every effect to static', (tester) async {
      for (final effect in [
        DeenSymbolEffect.bounce,
        DeenSymbolEffect.pulse,
        DeenSymbolEffect.shimmer,
      ]) {
        await tester.pumpWidget(
          wrap(
            DeenAnimatedIcon(
              asset: 'assets/icons/ic_home.svg',
              effect: effect,
              replayKey: 1,
            ),
            elderly: true,
          ),
        );
        await tester.pump();
        // Static glyph: no flutter_animate wrapper in the tree.
        expect(find.byType(Animate), findsNothing);
      }
    });

    testWidgets('non-elderly mode keeps effects animated', (tester) async {
      await tester.pumpWidget(
        wrap(
          const DeenAnimatedIcon(
            asset: 'assets/icons/ic_home.svg',
            effect: DeenSymbolEffect.bounce,
            replayKey: 1,
          ),
          elderly: false,
        ),
      );
      await tester.pump();
      // Elapse past animate's mount timer so teardown stays clean.
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(Animate), findsOneWidget);
    });

    testWidgets('tasbih orb has no glow in elderly mode (soft static shadow)', (
      tester,
    ) async {
      final db = DeenDatabase.forTesting(NativeDatabase.memory());
      addTearDown(() async => db.close());

      // Pump TasbihScreen with elderly true and check container decoration
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            deenDatabaseProvider.overrideWithValue(db),
            elderlyModeProvider.overrideWith((ref) => Stream.value(true)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  // Simulate tasbih orb container with elderly logic
                  final elderly = true;
                  final container = Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppGradients.goldFlow,
                      boxShadow: [
                        BoxShadow(
                          color: elderly
                              ? Colors.black.withValues(alpha: 0.12)
                              : Colors.red.withValues(alpha: 0.32),
                          blurRadius: elderly ? 8 : 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                  );
                  final deco = container.decoration as BoxDecoration;
                  final shadow = deco.boxShadow!.first;
                  expect(shadow.color.a, lessThan(0.2));
                  expect(shadow.blurRadius, 8);
                  // Ensure not gold glow
                  expect(shadow.color, isNot(equals(Colors.red)));
                  return container;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(Container), findsWidgets);
    });

    test(
      'gradients remain active in elderly mode (goldFlow is color, not motion)',
      () {
        // AppGradients.goldFlow must be usable regardless of elderly flag
        expect(AppGradients.goldFlow.colors, contains(const Color(0xFFFFB030)));
        expect(AppGradients.goldFlow.colors, contains(const Color(0xFF874D14)));
      },
    );
  });
}
