import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Design v3 canvas pattern (DEEN 8.2): a static eight-pointed star
/// girih tile behind content. Paint-only: no blur, no animation,
/// wrapped in a RepaintBoundary so scrolling never repaints it.
/// Opacity 0.04 light / 0.06 dark. Excluded from semantics.
class DeenPatternOverlay extends StatelessWidget {
  const DeenPatternOverlay({super.key, this.tileSize = 72});

  static const String asset = 'assets/patterns/pattern_star.svg';

  final double tileSize;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = (constraints.maxWidth / tileSize).ceil().clamp(1, 32);
        final rows =
            (constraints.maxHeight.isFinite
                    ? (constraints.maxHeight / tileSize).ceil()
                    : 12)
                .clamp(1, 64);
        return IgnorePointer(
          child: RepaintBoundary(
            child: Opacity(
              opacity: isDark ? 0.06 : 0.04,
              child: Semantics(
                excludeSemantics: true,
                child: SizedBox.expand(
                  child: Wrap(
                    children: List.generate(
                      cols * rows,
                      (_) => SizedBox(
                        width: tileSize,
                        height: tileSize,
                        child: SvgPicture.asset(
                          asset,
                          width: tileSize,
                          height: tileSize,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
