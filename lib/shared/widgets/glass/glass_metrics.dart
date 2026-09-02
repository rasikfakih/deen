/// Central helper for elderly-aware blur values per DEEN 8.1.
///
/// Single source so no scattered elderly ? 10 : 18 literals.
/// Base 18 (nav) becomes 10.8 when elderly, base 16 (glass) becomes 9.6.
abstract final class GlassMetrics {
  static const double _elderlyMultiplier = 0.6;

  static double effectiveSigma(double base, bool isElderly) =>
      isElderly ? base * _elderlyMultiplier : base;
}
