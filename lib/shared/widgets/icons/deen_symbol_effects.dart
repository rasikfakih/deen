import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/display_providers.dart';
import '../chrome/deen_gradient_icon.dart';

/// Symbol Effects runtime (Design v5).
///
/// One widget for every animated glyph. Effects are declarative and replay
/// via [replayKey]: when the key value changes, one-shot effects run again.
/// Looping effects (pulse, breathe) run continuously.
///
/// Restraint rule: effects are reserved for exactly seven moments —
/// nav selected (bounce), streak flame (pulse), tasbih orb (bounce),
/// bookmark (bounce), hasanat spark (shimmer), qibla needle (settle),
/// goal bar (drawOn on first paint). Nothing else animates glyphs.
///
/// Reduced Motion: when Elderly Mode is on, every effect resolves to
/// [DeenSymbolEffect.none] and the static glyph renders.
enum DeenSymbolEffect { none, pulse, bounce, breathe, shimmer, drawOn, settle }

class DeenAnimatedIcon extends ConsumerWidget {
  const DeenAnimatedIcon({
    super.key,
    this.asset = '',
    this.size = 20,
    this.color,
    this.gradient,
    this.effect = DeenSymbolEffect.none,
    this.replayKey,
    this.semanticLabel,
    this.child,
  });

  final String asset;
  final double size;
  final Color? color;
  final Gradient? gradient;
  final DeenSymbolEffect effect;
  final Object? replayKey;
  final String? semanticLabel;

  /// Optional prebuilt child (progress bar, needle, text). When provided,
  /// effects apply to it directly and the SVG fields are ignored. Used for
  /// the goal-bar drawOn, the qibla-needle settle, and text shimmer moments.
  final Widget? child;

  Widget _staticIcon() {
    if (child != null) return child!;
    if (gradient != null) {
      return DeenGradientIcon(asset: asset, size: size, gradient: gradient!);
    }
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Conservative default: render static until the preference resolves.
    // A null (still loading) elderly state must never start motion that a
    // post-frame rebuild would then tear down.
    final resolvedNonElderly =
        ref.watch(elderlyModeProvider).valueOrNull == false;
    final child = semanticLabel == null
        ? _staticIcon()
        : Semantics(label: semanticLabel, child: _staticIcon());
    if (!resolvedNonElderly || effect == DeenSymbolEffect.none) return child;

    switch (effect) {
      case DeenSymbolEffect.none:
        return child;
      case DeenSymbolEffect.pulse:
        return child
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.08, 1.08),
              duration: 1.6.seconds,
              curve: Curves.easeInOut,
            );
      case DeenSymbolEffect.bounce:
        return child
            .animate(key: ValueKey(replayKey))
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.05, 1.05),
              duration: 150.ms,
              curve: Curves.easeInOutQuint,
            )
            .then()
            .scale(
              begin: const Offset(1.05, 1.05),
              end: const Offset(1, 1),
              duration: 150.ms,
              curve: Curves.easeInOutQuint,
            );
      case DeenSymbolEffect.breathe:
        return child
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fade(begin: 0.7, end: 1.0, duration: 2.4.seconds);
      case DeenSymbolEffect.shimmer:
        return child
            .animate(key: ValueKey(replayKey))
            .shimmer(
              duration: 1.8.seconds,
              color: AppColors.hasanatSpark.withValues(alpha: 0.6),
            );
      case DeenSymbolEffect.drawOn:
        // Stroke/bar reveal mapped to the goal progress bar (the ring it
        // names is retained dead code). Generic ClipRect sweep, once.
        return TweenAnimationBuilder<double>(
          key: ValueKey(replayKey),
          tween: Tween(begin: 0.0, end: 1.0),
          duration: 900.ms,
          curve: Curves.easeInOutQuint,
          builder: (context, t, _) => ClipRect(
            child: Align(widthFactor: t, child: child),
          ),
        );
      case DeenSymbolEffect.settle:
        return child
            .animate(key: ValueKey(replayKey))
            .rotate(
              begin: -0.03,
              end: 0.0,
              duration: 400.ms,
              curve: Curves.easeInOutQuint,
            );
    }
  }
}
