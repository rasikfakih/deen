import 'package:flutter/material.dart';

/// Material 3 NavigationBar — heavily themed via [AppTheme.navigationBarTheme].
///
/// Gold indicator, surface background, proper text styles.
/// This wrapper exists to keep routing logic out of [AppShell] and to
/// provide a single place for analytics / accessibility hooks later.
class DeenBottomNav extends StatelessWidget {
  const DeenBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    // NavigationBar is themed globally in AppTheme.lightTheme/darkTheme.
    // Here we only supply destinations and selection state.
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
          tooltip: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book),
          label: 'Quran',
          tooltip: 'Quran',
        ),
        NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore),
          label: 'Qibla',
          tooltip: 'Qibla',
        ),
        NavigationDestination(
          icon: Icon(Icons.circle_outlined),
          selectedIcon: Icon(Icons.circle),
          label: 'Tasbih',
          tooltip: 'Tasbih',
        ),
      ],
    );
  }
}
