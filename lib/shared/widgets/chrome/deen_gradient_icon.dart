import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_gradients.dart';

/// ShaderMask + LinearGradient wrapper for SvgPicture to render gradient icons.
/// BlendMode srcIn preserves alpha.
class DeenGradientIcon extends StatelessWidget {
  const DeenGradientIcon({
    super.key,
    required this.asset,
    this.size = 24,
    this.gradient = AppGradients.goldFlow,
  });

  final String asset;
  final double size;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: SvgPicture.asset(
        asset,
        width: size,
        height: size,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
    );
  }
}
