import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deen/main.dart';

void main() {
  testWidgets('App loads shell with bottom nav and navigates', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DeenApp()));
    await tester.pumpAndSettle();

    // Home is initial location.
    expect(find.text('Home - Coming Soon'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    // Navigate to Quran.
    await tester.tap(find.text('Quran'));
    await tester.pumpAndSettle();
    expect(find.text('Quran - Coming Soon'), findsOneWidget);

    // Navigate to Qibla.
    await tester.tap(find.text('Qibla'));
    await tester.pumpAndSettle();
    expect(find.text('Qibla - Coming Soon'), findsOneWidget);

    // Navigate to Tasbih.
    await tester.tap(find.text('Tasbih'));
    await tester.pumpAndSettle();
    expect(find.text('Tasbih - Coming Soon'), findsOneWidget);

    // Back to Home.
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Home - Coming Soon'), findsOneWidget);
  });

  testWidgets('AppBar titles use design system', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DeenApp()));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);
  });
}
