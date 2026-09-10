import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deen/features/gamification/providers/gamification_providers.dart';
import 'package:deen/features/home/providers/home_stats_providers.dart';
import 'package:deen/features/home/widgets/stats_row.dart';
import 'package:deen/features/onboarding/providers/onboarding_providers.dart';
import 'package:deen/features/quran/data/quran_repository.dart';
import 'package:deen/features/quran/providers/quran_providers.dart';
import 'package:deen/features/quran/screens/quran_reader_screen.dart';
import 'package:deen/features/settings/providers/settings_providers.dart';
import 'package:deen/main.dart';
import 'package:deen/shared/database/deen_database.dart';
import 'package:deen/shared/widgets/chrome/deen_dock.dart';

/// Design v5 adaptation matrix (top-leak rule + overflow).
/// Cross-screen by design: Home and Tasbih share the shell.
/// Targets are ValueKeys (deterministic); product Semantics stay for users.
void main() {
  Future<void> pumpAt(
    WidgetTester tester,
    Size size,
    Future<void> Function() body,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await body();
  }

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

  group('Top leak (Design v5 3.1)', () {
    testWidgets('Home first content clears the app bar at 320x480', (
      tester,
    ) async {
      await pumpAt(tester, const Size(320, 480), () => pumpApp(tester));
      final appBarBottom = tester.getBottomLeft(find.byType(AppBar)).dy;
      final headerTop = tester
          .getTopLeft(find.byKey(const ValueKey('home-header')))
          .dy;
      expect(headerTop, greaterThanOrEqualTo(appBarBottom - 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Home first content clears the app bar at 1280x800', (
      tester,
    ) async {
      await pumpAt(tester, const Size(1280, 800), () => pumpApp(tester));
      final appBarBottom = tester.getBottomLeft(find.byType(AppBar)).dy;
      final headerTop = tester
          .getTopLeft(find.byKey(const ValueKey('home-header')))
          .dy;
      expect(headerTop, greaterThanOrEqualTo(appBarBottom - 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Tasbih counter clears the app bar at 320x480', (tester) async {
      await pumpAt(tester, const Size(320, 480), () => pumpApp(tester));
      await tester.tap(find.text('Tasbih'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final appBarBottom = tester.getBottomLeft(find.byType(AppBar)).dy;
      final counterTop = tester
          .getTopLeft(find.byKey(const ValueKey('tasbih-counter')))
          .dy;
      expect(counterTop, greaterThanOrEqualTo(appBarBottom - 1));
      expect(tester.takeException(), isNull);
    });
  });

  group('Overflow matrix (Design v5 3.2)', () {
    testWidgets('Tasbih fits 1280x800 with no overflow', (tester) async {
      await pumpAt(tester, const Size(1280, 800), () => pumpApp(tester));
      await tester.tap(find.text('Tasbih'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const ValueKey('tasbih-counter')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Tasbih fits landscape 800x360 with no overflow', (
      tester,
    ) async {
      await pumpAt(tester, const Size(800, 360), () => pumpApp(tester));
      await tester.tap(find.text('Tasbih'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const ValueKey('tasbih-counter')), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Qibla fits landscape 800x360 with no overflow', (
      tester,
    ) async {
      await pumpAt(tester, const Size(800, 360), () => pumpApp(tester));
      await tester.tap(find.text('Qibla'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });
  });

  group('Stats empty state (Design v5 3.4)', () {
    testWidgets('Stats cards show 0, never dash, when empty', (tester) async {
      // Plain-value overrides: no drift streams open, so disposal stays
      // timer-free (same pattern as glass_test provider overrides).
      const zeros = DayTotals(minutes: 0, ayahs: 0, hasanat: 0);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todayProgressProvider.overrideWith(
              (ref) => Stream<DailyRead?>.value(null),
            ),
            weekStatsProvider.overrideWith((ref) => Future.value(zeros)),
            allStatsProvider.overrideWith((ref) => Future.value(zeros)),
          ],
          child: const MaterialApp(home: Scaffold(body: StatsRow())),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('–'), findsNothing);
      expect(find.text('0'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('Shell intact', () {
    testWidgets('Nav bar present at 320x480', (tester) async {
      await pumpAt(tester, const Size(320, 480), () => pumpApp(tester));
      expect(find.byType(DeenDock), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Header truncation (Design v6)', () {
    testWidgets('Greeting ellipsizes to one line at 320x480', (tester) async {
      await pumpAt(tester, const Size(320, 480), () => pumpApp(tester));
      final greeting = tester.widget<Text>(
        find.byKey(const ValueKey('home-greeting')),
      );
      expect(greeting.maxLines, 1);
      expect(greeting.overflow, TextOverflow.ellipsis);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Subline never truncates at 360x800', (tester) async {
      await pumpAt(tester, const Size(360, 800), () => pumpApp(tester));
      final subline = tester.widget<Text>(
        find.byKey(const ValueKey('home-subline')),
      );
      expect(subline.maxLines, isNull);
      expect(subline.overflow, TextOverflow.visible);
      expect(tester.takeException(), isNull);
    });
  });

  group('Reader Prev button (Design v6)', () {
    testWidgets('Prev label paints on a single line', (tester) async {
      final db = DeenDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      const fakeAyahs = [
        QuranAyah(
          surahId: 1,
          ayahId: 1,
          arabic: 'test-ar-1',
          english: 'test-en-1',
        ),
        QuranAyah(
          surahId: 1,
          ayahId: 2,
          arabic: 'test-ar-2',
          english: 'test-en-2',
        ),
      ];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            deenDatabaseProvider.overrideWithValue(db),
            elderlyModeProvider.overrideWith((ref) => Stream.value(false)),
            quranDataProvider.overrideWith((ref) async => fakeAyahs),
            bookmarksProvider.overrideWith((ref) => Stream.value(const [])),
            lastReadProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: const MaterialApp(home: QuranReaderScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final label = find.text('Prev');
      expect(label, findsOneWidget);
      final text = tester.widget<Text>(label);
      final height = tester.getSize(label).height;
      expect(height, lessThanOrEqualTo((text.style?.fontSize ?? 14) * 1.5));
      expect(tester.takeException(), isNull);
    });
  });
}
