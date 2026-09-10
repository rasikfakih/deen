import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Chrome scroll state (Design v6, DEEN 8.4).
///
/// True once any extended screen scrolls past 8px; drives the DeenAppBar
/// hairline. Screens feed it via `NotificationListener<ScrollNotification>`.
final deenChromeHairlineProvider = StateProvider<bool>((ref) => false);

/// Wraps a scrollable root and reports offsets past [threshold] to
/// [deenChromeHairlineProvider]. Place at the scroll roots of the six
/// `extendBodyBehindAppBar` screens (home, reader, prayer, family, settings,
/// support). Non-scrolling screens omit it; the hairline stays hidden.
class DeenChromeListener extends ConsumerWidget {
  const DeenChromeListener({
    super.key,
    required this.child,
    this.threshold = 8,
  });

  final Widget child;
  final double threshold;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        final past = n.metrics.pixels > threshold;
        if (ref.read(deenChromeHairlineProvider) != past) {
          ref.read(deenChromeHairlineProvider.notifier).state = past;
        }
        return false;
      },
      child: child,
    );
  }
}
