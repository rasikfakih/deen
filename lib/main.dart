import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Offline-first: do not fetch fonts at runtime (DEEN Section 6/8).
  // Poppins/Tajawal will be bundled as assets in Session 3; google_fonts
  // will then resolve locally. System fallback is acceptable until then.
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const ProviderScope(child: DeenApp()));
}

class DeenApp extends StatelessWidget {
  const DeenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Deen',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
