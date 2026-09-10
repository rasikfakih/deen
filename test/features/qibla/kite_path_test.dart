import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deen/features/qibla/screens/qibla_screen.dart' show kitePath;

void main() {
  group('kitePath needle geometry (single closed path)', () {
    test('returns one closed kite inside the box', () {
      const size = Size(100, 100);
      final path = kitePath(size);
      final bounds = path.getBounds();

      // Finite, nonzero, contained within the box.
      expect(bounds.isFinite, isTrue);
      expect(bounds.width, greaterThan(0));
      expect(bounds.height, greaterThan(0));
      expect(bounds.left, greaterThanOrEqualTo(0));
      expect(bounds.top, greaterThanOrEqualTo(0));
      expect(bounds.right, lessThanOrEqualTo(size.width));
      expect(bounds.bottom, lessThanOrEqualTo(size.height));
    });

    test('bounds contain the tip and the tail notch', () {
      const size = Size(100, 100);
      final bounds = kitePath(size).getBounds();

      // Tip at top-center, notch pulled up from the bottom edge.
      expect(bounds.top, 0.0);
      expect(bounds.left, lessThan(50.0));
      expect(bounds.right, greaterThan(50.0));
      expect(bounds.bottom, lessThan(size.height));
      expect(bounds.bottom, greaterThan(size.height / 2));
    });

    test('scales with the input size', () {
      final small = kitePath(const Size(50, 50)).getBounds();
      final big = kitePath(const Size(200, 200)).getBounds();
      expect(big.width, closeTo(small.width * 4, 0.001));
      expect(big.height, closeTo(small.height * 4, 0.001));
    });
  });
}
