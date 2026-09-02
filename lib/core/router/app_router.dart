import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/screens/home_screen.dart';
import '../../features/onboarding/providers/onboarding_providers.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/prayer/screens/prayer_times_screen.dart';
import '../../features/qibla/screens/qibla_screen.dart';
import '../../features/quran/screens/quran_reader_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/tasbih/screens/tasbih_screen.dart';
import '../../shared/widgets/deen_bottom_nav.dart';

/// Central router - ShellRoute with Material 3 NavigationBar.
///
/// Bottom navigation: Home, Quran, Qibla, Tasbih (per DEEN Section 9).
/// Profile/Settings via top bar. Uses go_router 18.
/// Onboarding and Settings/PrayerTimes are outside ShellRoute (full-screen push).

final appRouterProvider = Provider<GoRouter>((ref) {
  final hasOnboardedAsync = ref.watch(hasCompletedOnboardingProvider);
  final hasOnboarded = hasOnboardedAsync.valueOrNull ?? false;
  final isLoading = hasOnboardedAsync.isLoading;

  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      if (isLoading) return null;
      final goingToOnboarding = state.matchedLocation == '/onboarding';
      if (!hasOnboarded && !goingToOnboarding) return '/onboarding';
      if (hasOnboarded && goingToOnboarding) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(state: state, child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/quran',
            name: 'quran',
            builder: (context, state) => const QuranReaderScreen(),
          ),
          GoRoute(
            path: '/qibla',
            name: 'qibla',
            builder: (context, state) => const QiblaScreen(),
          ),
          GoRoute(
            path: '/tasbih',
            name: 'tasbih',
            builder: (context, state) => const TasbihScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/prayer-times',
        name: 'prayerTimes',
        builder: (context, state) => const PrayerTimesScreen(),
      ),
      // Redirect root to home.
      GoRoute(path: '/', redirect: (context, state) => '/home'),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Deen')),
      body: Center(
        child: Text(
          'Page not found: ${state.uri}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    ),
  );
});

/// Legacy global router for tests that directly import appRouter.
/// In production, use ref.watch(appRouterProvider).
final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(state: state, child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/quran',
          name: 'quran',
          builder: (context, state) => const QuranReaderScreen(),
        ),
        GoRoute(
          path: '/qibla',
          name: 'qibla',
          builder: (context, state) => const QiblaScreen(),
        ),
        GoRoute(
          path: '/tasbih',
          name: 'tasbih',
          builder: (context, state) => const TasbihScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/prayer-times',
      name: 'prayerTimes',
      builder: (context, state) => const PrayerTimesScreen(),
    ),
    GoRoute(path: '/', redirect: (context, state) => '/home'),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Deen')),
    body: Center(
      child: Text(
        'Page not found: ${state.uri}',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    ),
  ),
);

/// Shell that hosts the bottom NavigationBar.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.state, required this.child});

  final GoRouterState state;
  final Widget child;

  static const _tabs = ['/home', '/quran', '/qibla', '/tasbih'];

  int _currentIndex(String location) {
    final loc = location;
    for (var i = 0; i < _tabs.length; i++) {
      if (loc == _tabs[i] || loc.startsWith('${_tabs[i]}/')) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = state.matchedLocation.isEmpty
        ? state.uri.toString()
        : state.matchedLocation;
    final index = _currentIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: DeenBottomNav(
        currentIndex: index,
        onTap: (tapped) {
          if (tapped == index) return;
          switch (tapped) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/quran');
              break;
            case 2:
              context.go('/qibla');
              break;
            case 3:
              context.go('/tasbih');
              break;
          }
        },
      ),
    );
  }
}
