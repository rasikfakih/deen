import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deen/features/onboarding/providers/onboarding_providers.dart';
import 'package:deen/features/settings/providers/settings_providers.dart';
import 'package:deen/main.dart';
import 'package:deen/shared/database/deen_database.dart';
import 'package:deen/shared/widgets/chrome/deen_dock.dart';

/// Deen Dock suite (DEEN 8.4): blur is retired, so zero BackdropFilter
/// may exist anywhere in the shell or the five listed screens.
/// Provider-override pattern per the v5 drift-timer lesson: every pumped
/// scope overrides the db-backed streams it touches.
void main() {
  late DeenDatabase testDb;

  setUp(() {
    testDb = DeenDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await testDb.close();
  });

  List<Override> baseOverrides({bool elderly = false}) => [
    deenDatabaseProvider.overrideWithValue(testDb),
    elderlyModeProvider.overrideWith((ref) => Stream.value(elderly)),
    // The dock watches themeModeProvider (real drift stream). Override
    // it like elderly so disposal never leaves a pending drift timer.
    themeModeProvider.overrideWith((ref) => Stream.value(ThemeMode.light)),
    hasCompletedOnboardingProvider.overrideWith((ref) => Stream.value(true)),
  ];

  ProviderScope wrap(Widget child, {bool elderly = false}) {
    return ProviderScope(
      overrides: baseOverrides(elderly: elderly),
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  testWidgets('DeenDock contains zero BackdropFilter', (tester) async {
    await tester.pumpWidget(wrap(DeenDock(currentIndex: 0, onTap: (_) {})));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.byType(DeenDock), findsOneWidget);
  });

  testWidgets('DeenDock surface is fully opaque', (tester) async {
    await tester.pumpWidget(wrap(DeenDock(currentIndex: 0, onTap: (_) {})));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    bool matchesSurface(Widget w) {
      if (w is! Container) return false;
      final d = w.decoration;
      if (d is! BoxDecoration) return false;
      final c = d.color;
      if (c == null) return false;
      return c.a == 1.0 && c == Colors.white;
    }

    expect(find.byWidgetPredicate(matchesSurface), findsOneWidget);
  });

  testWidgets('DeenDock keeps definition via shadow, no blur needed', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(DeenDock(currentIndex: 1, onTap: (_) {})));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    bool matchesShadow(Widget w) {
      if (w is! Container) return false;
      final d = w.decoration;
      if (d is! BoxDecoration) return false;
      return d.boxShadow?.any(
            (s) =>
                s.blurRadius == 24 &&
                s.offset == const Offset(0, 8) &&
                s.color == const Color(0x29000000),
          ) ??
          false;
    }

    expect(find.byWidgetPredicate(matchesShadow), findsOneWidget);
    expect(find.byType(RepaintBoundary), findsWidgets);
  });

  testWidgets('AppShell simulation has zero BackdropFilter', (tester) async {
    // Simulate AppShell body without needing real GoRouterState.
    await tester.pumpWidget(
      ProviderScope(
        overrides: baseOverrides(elderly: true),
        child: MaterialApp(
          home: Scaffold(
            body: const Text('child'),
            bottomNavigationBar: DeenDock(currentIndex: 0, onTap: (_) {}),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.byType(DeenDock), findsOneWidget);
  });

  group('Screens contain zero BackdropFilter', () {
    Future<void> pumpApp(WidgetTester tester) async {
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
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('Home has zero BackdropFilter', (tester) async {
      await pumpApp(tester);
      expect(
        find.byType(BackdropFilter),
        findsNothing,
        reason: 'Home must be blur-free (DEEN 8.4)',
      );
    });

    testWidgets('Quran has zero BackdropFilter', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Quran'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.byType(BackdropFilter),
        findsNothing,
        reason: 'Quran must be blur-free (DEEN 8.4)',
      );
    });

    testWidgets('Qibla has zero BackdropFilter', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Qibla'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.byType(BackdropFilter),
        findsNothing,
        reason: 'Qibla must be blur-free (DEEN 8.4)',
      );
    });

    testWidgets('Tasbih has zero BackdropFilter', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Tasbih'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.byType(BackdropFilter),
        findsNothing,
        reason: 'Tasbih must be blur-free (DEEN 8.4)',
      );
    });

    testWidgets('Settings has zero BackdropFilter', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byTooltip('Settings'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.byType(BackdropFilter),
        findsNothing,
        reason: 'Settings must be blur-free (DEEN 8.4)',
      );
    });
  });
}
