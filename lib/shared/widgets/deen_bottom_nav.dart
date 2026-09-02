import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';

/// Material 3 NavigationBar - heavily themed via [AppTheme.navigationBarTheme].
///
/// Gold indicator, surface background, proper text styles.
/// Uses minimalist geometric SVG icons instead of Material Icons.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedColor = isDark
        ? const Color(0xFF9E9589)
        : AppColors.textMuted;
    final selectedColor = isDark ? AppColors.textDark : AppColors.textDark;

    // NavigationBar is themed globally in AppTheme.lightTheme/darkTheme.
    // Here we only supply destinations and selection state.
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: [
        NavigationDestination(
          icon: SvgPicture.asset(
            'assets/icons/home.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(unselectedColor, BlendMode.srcIn),
          ),
          selectedIcon: SvgPicture.asset(
            'assets/icons/home.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(selectedColor, BlendMode.srcIn),
          ),
          label: 'Home',
          tooltip: 'Home',
        ),
        NavigationDestination(
          icon: SvgPicture.asset(
            'assets/icons/quran.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(unselectedColor, BlendMode.srcIn),
          ),
          selectedIcon: SvgPicture.asset(
            'assets/icons/quran.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(selectedColor, BlendMode.srcIn),
          ),
          label: 'Quran',
          tooltip: 'Quran',
        ),
        NavigationDestination(
          icon: SvgPicture.asset(
            'assets/icons/qibla.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(unselectedColor, BlendMode.srcIn),
          ),
          selectedIcon: SvgPicture.asset(
            'assets/icons/qibla.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(selectedColor, BlendMode.srcIn),
          ),
          label: 'Qibla',
          tooltip: 'Qibla',
        ),
        NavigationDestination(
          icon: SvgPicture.asset(
            'assets/icons/tasbih.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(unselectedColor, BlendMode.srcIn),
          ),
          selectedIcon: SvgPicture.asset(
            'assets/icons/tasbih.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(selectedColor, BlendMode.srcIn),
          ),
          label: 'Tasbih',
          tooltip: 'Tasbih',
        ),
      ],
    );
  }
}
