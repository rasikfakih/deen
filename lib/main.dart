import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_constants.dart';
import 'shared/providers/display_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  tz_data.initializeTimeZones();
  unawaited(
    FlutterTimezone.getLocalTimezone()
        .then((info) {
          try {
            tz.setLocalLocation(tz.getLocation(info.identifier));
          } catch (_) {}
        })
        .timeout(const Duration(milliseconds: 500), onTimeout: () {}),
  );

  // Guest-first: empty (default) means offline mode, no Supabase.
  // Inject at build: flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  const supabaseUrl = AppConstants.supabaseUrl;
  const supabaseAnonKey = AppConstants.supabaseAnonKey;

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
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
    debugPrint('Supabase not configured, running in guest (offline) mode');
  }

  runApp(const ProviderScope(child: DeenApp()));
}

class DeenApp extends ConsumerWidget {
  const DeenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(themeModeProvider);
    final elderlyAsync = ref.watch(elderlyModeProvider);
    final router = ref.watch(appRouterProvider);

    final themeMode = themeModeAsync.valueOrNull ?? ThemeMode.system;
    final isElderly = elderlyAsync.valueOrNull ?? false;
    // Temporary clamp: device text scaler capped at 1.3 until the overflow
    // matrix passes at 1.5 (see DEEN follow-ups). Elderly 1.2 unaffected.
    final deviceScale = MediaQuery.textScalerOf(context).scale(1.0);
    final textScale = (isElderly ? 1.2 : deviceScale).clamp(1.0, 1.3);

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
