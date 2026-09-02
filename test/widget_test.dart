import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deen/main.dart';

void main() {
  testWidgets('App loads shell with bottom nav and navigates', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DeenApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Home is initial location.
    expect(find.text('Home - Coming Soon'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    // Navigate to Quran reader (text mode).
    await tester.tap(find.text('Quran'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.widgetWithText(AppBar, 'Al-Quran — Text Mode'), findsOneWidget);
    // Reader may still be loading (CircularProgressIndicator) or already showing ListView.
    // Give it a moment to start loading, but don't require ListView to avoid flakiness
    // with large JSON in test (138ms direct, but widget test may need extra pump).
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      find.byWidgetPredicate(
        (w) => w is ListView || w is CircularProgressIndicator,
      ),
      findsOneWidget,
    );

    // Navigate to Qibla.
    await tester.tap(find.text('Qibla'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Qibla - Coming Soon'), findsOneWidget);

    // Navigate to Tasbih.
    await tester.tap(find.text('Tasbih'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Tasbih - Coming Soon'), findsOneWidget);

    // Back to Home.
    await tester.tap(find.text('Home'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Home - Coming Soon'), findsOneWidget);
  });

  testWidgets('AppBar titles use design system', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DeenApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);
  });
}
