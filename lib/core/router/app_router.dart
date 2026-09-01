import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/screens/home_screen.dart';
import '../../features/qibla/screens/qibla_screen.dart';
import '../../features/quran/screens/quran_screen.dart';
import '../../features/tasbih/screens/tasbih_screen.dart';
import '../../shared/widgets/deen_bottom_nav.dart';

/// Central router — ShellRoute with Material 3 NavigationBar.
///
/// Bottom navigation: Home, Quran, Qibla, Tasbih (per DEEN Section 9).
/// Profile/Settings via top bar (future). Uses go_router 14+ / 18.
final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
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
          builder: (context, state) => const QuranScreen(),
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

/// Shell that hosts the bottom NavigationBar.
/// Separated so theming stays in AppTheme and routing stays testable.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.state, required this.child});

  final GoRouterState state;
  final Widget child;

  static const _tabs = ['/home', '/quran', '/qibla', '/tasbih'];

  int _currentIndex(String location) {
    // Use matchedLocation for nested routes, fallback to uri path.
    final loc = location;
    for (var i = 0; i < _tabs.length; i++) {
      if (loc == _tabs[i] || loc.startsWith('${_tabs[i]}/')) {
        return i;
      }
    }
    // Default to home for '/' or unknown.
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
