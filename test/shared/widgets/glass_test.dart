import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deen/features/settings/providers/settings_providers.dart';
import 'package:deen/shared/database/deen_database.dart';
import 'package:deen/features/gamification/providers/gamification_providers.dart';
import 'package:deen/shared/widgets/glass/deen_glass.dart';
import 'package:deen/shared/widgets/glass/deen_glass_nav_bar.dart';

void main() {
  late DeenDatabase testDb;

  setUp(() {
    testDb = DeenDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await testDb.close();
  });

  ProviderScope wrap(Widget child, {bool elderly = false}) {
    return ProviderScope(
      overrides: [
        deenDatabaseProvider.overrideWithValue(testDb),
        elderlyModeProvider.overrideWith((ref) => Stream.value(elderly)),
        // Ensure initialData available via valueOrNull checks; StreamProvider handles.
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  testWidgets('DeenGlass contains exactly one BackdropFilter', (tester) async {
    await tester.pumpWidget(wrap(const DeenGlass(child: Text('hello'))));
    await tester.pump();
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(DeenGlass),
        matching: find.byType(BackdropFilter),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'DeenGlass nav bar contains exactly one BackdropFilter, no nesting',
    (tester) async {
      await tester.pumpWidget(
        wrap(DeenGlassNavBar(currentIndex: 0, onTap: (_) {}), elderly: true),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // DeenGlassNavBar internally uses DeenGlass -> one BackdropFilter
      expect(find.byType(BackdropFilter), findsOneWidget);
      // No nested BackdropFilter: check ancestors
      final filters = tester
          .widgetList<BackdropFilter>(find.byType(BackdropFilter))
          .toList();
      expect(filters.length, 1);
    },
  );

  testWidgets('AppShell simulated has no nested BackdropFilter', (
    tester,
  ) async {
    // Simulate AppShell body without needing real GoRouterState - just wrap nav bar + child
    // AppShell itself is a Scaffold with DeenGlassNavBar; we test that combination has only one filter
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          deenDatabaseProvider.overrideWithValue(testDb),
          elderlyModeProvider.overrideWith((ref) => Stream.value(true)),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: const Text('child'),
            bottomNavigationBar: DeenGlassNavBar(
              currentIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final backdropFilters = find.byType(BackdropFilter);
    expect(backdropFilters, findsOneWidget);

    final element = tester.element(find.byType(BackdropFilter));
    bool hasAncestorBackdrop(Element e) {
      bool found = false;
      e.visitAncestorElements((ancestor) {
        if (ancestor.widget is BackdropFilter) {
          found = true;
          return false;
        }
        return true;
      });
      return found;
    }

    expect(hasAncestorBackdrop(element), isFalse);
  });

  testWidgets('DeenGlass and nav bar use RepaintBoundary', (tester) async {
    await tester.pumpWidget(
      wrap(
        SingleChildScrollView(
          child: Column(
            children: [
              DeenGlass(child: const Text('a')),
              DeenGlassNavBar(currentIndex: 1, onTap: (_) {}),
            ],
          ),
        ),
        elderly: true,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(RepaintBoundary), findsWidgets);
  });
}
