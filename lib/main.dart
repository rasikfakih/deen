import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/providers/settings_providers.dart';
import 'features/social/providers/social_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://placeholder.supabase.co',
  );
  const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'placeholder-anon-key',
  );

  if (supabaseUrl != 'https://placeholder.supabase.co' &&
      supabaseAnonKey != 'placeholder-anon-key') {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: supabaseAnonKey,
      ).timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint(
        'Supabase init skipped or failed, continuing in guest mode: $e',
      );
    }
  } else {
    debugPrint('Supabase placeholder config, running in guest mode');
  }

  runApp(const ProviderScope(child: DeenApp()));
}

class DeenApp extends ConsumerWidget {
  const DeenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Activate auto-sync on auth upgrade (Guest -> Email)
    ref.watch(autoSyncProvider);
    final themeModeAsync = ref.watch(themeModeProvider);
    final elderlyAsync = ref.watch(elderlyModeProvider);
    final router = ref.watch(appRouterProvider);

    final themeMode = themeModeAsync.valueOrNull ?? ThemeMode.system;
    final isElderly = elderlyAsync.valueOrNull ?? false;
    final textScale = isElderly ? 1.2 : 1.0;

    return MaterialApp.router(
      title: 'Deen',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        );
      },
    );
  }
}
