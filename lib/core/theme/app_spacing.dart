/// Strict 4/8pt spacing and radii scale per DEEN Section 8.
///
/// Use only these constants - no magic numbers in widgets. If a value is
/// missing, add it here with review.
abstract final class AppSpacing {
  // Spacing.
  static const double spaceXXS = 2.0;
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double space2XL = 48.0;
  static const double space3XL = 64.0;
  static const double space4XL = 80.0;

  // Radii.
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radius2XL = 32.0;
  static const double radiusFull = 999.0;

  // Content constraints.
  static const double maxContentWidth = 640.0;
  static const double bottomNavHeight = 80.0;
  static const double appBarHeight = 56.0;

  // Elevation / shadow blurs (soft, per design system).
  static const double elevationXS = 1.0;
  static const double elevationSM = 4.0;
  static const double elevationMD = 8.0;
  static const double elevationLG = 16.0;

  // Icon sizes.
  static const double iconSM = 18.0;
  static const double iconMD = 24.0;
  static const double iconLG = 28.0;

  // Tap targets (accessibility).
  static const double minTapTarget = 48.0;

  // Glass metrics - single source for blur and nav geometry per DEEN 8.1.
  static const double glassBlurSigma = 16;
  static const double glassBorderWidth = 0.8;
  static const double navFloatingMargin = 16;
  static const double navRadius = 28;
  static const double navHeight = 72;
  static const double scrollEdgeHard = 24;
  static const double scrollEdgeSoft = 32;
}
