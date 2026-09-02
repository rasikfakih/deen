import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deen/features/quran/data/quran_repository.dart';
import 'package:deen/features/quran/providers/quran_providers.dart';
import 'package:deen/features/quran/screens/quran_reader_screen.dart';
import 'package:deen/features/settings/providers/settings_providers.dart';
import 'package:deen/shared/database/deen_database.dart';
import 'package:deen/features/gamification/providers/gamification_providers.dart';
import 'package:deen/shared/widgets/glass/deen_glass_app_bar.dart';

void main() {
  group('Sacred calm - Quran reader has no BackdropFilter in ayah list', () {
    late DeenDatabase testDb;

    setUp(() {
      testDb = DeenDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await testDb.close();
    });

    testWidgets(
      'QuranReaderScreen - app bar has one BackdropFilter, list has zero',
      (tester) async {
        final fakeAyahs = [
          const QuranAyah(
            surahId: 1,
            ayahId: 1,
            arabic: 'بِسْمِ',
            english: 'In the name',
          ),
          const QuranAyah(
            surahId: 1,
            ayahId: 2,
            arabic: 'الْحَمْدُ',
            english: 'Praise',
          ),
          const QuranAyah(
            surahId: 2,
            ayahId: 1,
            arabic: 'الم',
            english: 'Alif Lam Mim',
          ),
        ];

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              deenDatabaseProvider.overrideWithValue(testDb),
              elderlyModeProvider.overrideWith((ref) => Stream.value(false)),
              quranDataProvider.overrideWith((ref) async => fakeAyahs),
              bookmarksProvider.overrideWith((ref) => Stream.value(const [])),
              lastReadProvider.overrideWith((ref) => Stream.value(null)),
              // stub gamification repo via provider override not needed; timer is disabled in test via runtimeType check
            ],
            child: const MaterialApp(home: QuranReaderScreen()),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Overall screen should have exactly one BackdropFilter from DeenGlassAppBar
        expect(find.byType(BackdropFilter), findsOneWidget);
        expect(find.byType(DeenGlassAppBar), findsOneWidget);

        // Find the Expanded ListView for ayahs
        final listViewFinder = find.byType(ListView);
        expect(listViewFinder, findsWidgets);

        // Ensure no BackdropFilter is descendant of any ListView
        final listViews = tester.widgetList<ListView>(listViewFinder).toList();
        for (final _ in listViews) {
          // Check descendants of this ListView
        }
        // Check that no BackdropFilter is under ListView
        final allFilters = find.byType(BackdropFilter);
        expect(allFilters, findsOneWidget);

        // Ensure that one BackdropFilter is ancestor of AppBar, not ListView
        final filterElement = tester.element(find.byType(BackdropFilter));
        bool isInListView = false;
        filterElement.visitAncestorElements((ancestor) {
          if (ancestor.widget is ListView) {
            isInListView = true;
            return false;
          }
          return true;
        });
        expect(
          isInListView,
          isFalse,
          reason: 'BackdropFilter must not be inside ListView',
        );

        // Also ensure ayah list body (Expanded) has zero BackdropFilter descendants
        final expandedFinder = find.byType(Expanded);
        expect(expandedFinder, findsWidgets);
        // For each Expanded, check no BackdropFilter descendant
        for (final expElement in tester.elementList(expandedFinder)) {
          final descendants = find.descendant(
            of: find.byWidget(expElement.widget),
            matching: find.byType(BackdropFilter),
          );
          // Expanded that contains ListView should have zero filters
          final hasListViewDescendant = find
              .descendant(
                of: find.byWidget(expElement.widget),
                matching: find.byType(ListView),
              )
              .evaluate()
              .isNotEmpty;
          if (hasListViewDescendant) {
            expect(
              descendants,
              findsNothing,
              reason: 'Ayah list Expanded must have zero BackdropFilter',
            );
          }
        }
      },
    );
  });
}
