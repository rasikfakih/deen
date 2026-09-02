import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'deen_glass.dart';
import 'deen_scroll_edge_fade.dart';

/// Reusable glass app bar with scroll edge fade integration.
/// Use with Scaffold(extendBodyBehindAppBar: true) and CustomScrollView.
class DeenGlassAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const DeenGlassAppBar({
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
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: Text(title),
      leading: leading,
      actions: actions,
      flexibleSpace: const DeenGlass(
        variant: DeenGlassVariant.regular,
        borderRadius: 0,
        child: SizedBox.expand(),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: DeenScrollEdgeFade(hard: true, height: 1),
      ),
    );
  }
}

/// Helper to add scroll edge fade under glass bars.
/// Wrap scrollable content with this to get fade.
class DeenGlassScrollWrapper extends StatelessWidget {
  const DeenGlassScrollWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        const Positioned(
          top: kToolbarHeight,
          left: 0,
          right: 0,
          child: DeenScrollEdgeFade(isTop: true),
        ),
      ],
    );
  }
}
