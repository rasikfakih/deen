import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deen/core/router/app_router.dart';
import 'package:deen/main.dart';

void main() {
  setUp(() {
    // Reset global router between tests (singleton retains location).
    appRouter.go('/home');
  });

  testWidgets('App loads shell with bottom nav and navigates', (tester) async {
    appRouter.go('/home');
    await tester.pumpWidget(const ProviderScope(child: DeenApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Home is initial location - premium dashboard (CustomScrollView).
    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

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
    appRouter.go('/home');
    await tester.pumpWidget(const ProviderScope(child: DeenApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);
  });
}
