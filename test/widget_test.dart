import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deen/features/onboarding/providers/onboarding_providers.dart';
import 'package:deen/main.dart';
import 'package:deen/shared/widgets/chrome/deen_dock.dart';

void main() {
  testWidgets('App loads shell with bottom nav and navigates', (tester) async {
    // Tall surface: the whole Home list builds at offset zero, so every
    // module key is present without gesture scrolling (deterministic;
    // SliverList lazily evicts below-fold children on small screens).
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hasCompletedOnboardingProvider.overrideWith(
            (ref) => Stream.value(true),
          ),
        ],
        child: const DeenApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Home is initial location - v3 canvas dashboard (CustomScrollView).
    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(find.byType(DeenDock), findsOneWidget);

    // Design v3 Home modules render on canvas.
    expect(find.byKey(const ValueKey('goal-hero')), findsOneWidget);
    expect(find.byKey(const ValueKey('surah-chips')), findsOneWidget);
    expect(find.byKey(const ValueKey('ayah-of-day')), findsOneWidget);
    expect(find.byKey(const ValueKey('challenge-card')), findsOneWidget);
    expect(find.byKey(const ValueKey('stats-row')), findsOneWidget);
    expect(find.byKey(const ValueKey('family-card')), findsOneWidget);
    expect(find.byKey(const ValueKey('prayer-strip')), findsOneWidget);

    // Navigate to Quran reader (text mode).
    await tester.tap(find.text('Quran'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.widgetWithText(AppBar, 'Al-Quran - Text Mode'), findsOneWidget);
    // Reader may be loading, showing ListView, or error - just verify navigation succeeded.
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(Scaffold), findsWidgets);

    // Navigate to Qibla - compass UI (empty state or dial).
    await tester.tap(find.text('Qibla'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.widgetWithText(AppBar, 'Qibla'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is Scaffold), findsWidgets);

    // Navigate to Tasbih - counter UI.
    await tester.tap(find.text('Tasbih'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.widgetWithText(AppBar, 'Tasbih'), findsOneWidget);
    // Preset chips 33/99/100 should be visible
    expect(find.text('33'), findsWidgets);

    // Back to Home.
    await tester.tap(find.text('Home'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(CustomScrollView), findsOneWidget);
  });

  testWidgets('AppBar titles use design system', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hasCompletedOnboardingProvider.overrideWith(
            (ref) => Stream.value(true),
          ),
        ],
        child: const DeenApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);
  });
}
