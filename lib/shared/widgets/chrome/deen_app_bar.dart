import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import 'deen_chrome.dart';

/// Deen app bar (Design v6, DEEN 8.4). Opaque, zero blur.
///
/// Solid surface equal to the canvas top (cream light / #121212 dark),
/// no elevation. A 1px hairline (0x14000000) fades in only after the
/// screen scrolls past 8px, driven by [deenChromeHairlineProvider]
/// (fed by DeenChromeListener at scroll roots).
/// Use with Scaffold(extendBodyBehindAppBar: true) and CustomScrollView.
class DeenAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const DeenAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final past = ref.watch(deenChromeHairlineProvider);
    return AppBar(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.cream,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: Text(title),
      leading: leading,
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutQuint,
          opacity: past ? 1.0 : 0.0,
          child: Container(height: 1, color: const Color(0x14000000)),
        ),
      ),
    );
  }
}
