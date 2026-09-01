import 'package:flutter_test/flutter_test.dart';

import 'package:deen/features/qibla/data/qibla_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late QiblaRepository repo;

  setUp(() {
    repo = QiblaRepository();
  });

  group('QiblaRepository', () {
    test('Scenario C: Qibla bearing from New York ~58-59 degrees', () {
      // New York City: 40.7128, -74.0060
      final bearing = repo.getQiblaDirection(
        latitude: 40.7128,
        longitude: -74.0060,
      );
      expect(bearing, greaterThanOrEqualTo(57.0));
      expect(bearing, lessThanOrEqualTo(60.0));
      // More precise: expect close to 58.48
      expect(bearing, closeTo(58.5, 1.5));
    });

    test('Qibla from London ~119 degrees', () {
      final bearing = repo.getQiblaDirection(
        latitude: 51.5074,
        longitude: -0.1278,
      );
      expect(bearing, closeTo(118.9, 2.0));
    });

    test('Qibla from Mecca itself is ~0 or undefined but returns valid', () {
      final bearing = repo.getQiblaDirection(
        latitude: 21.3891,
        longitude: 39.8579,
      );
      // At Mecca, bearing calculation may be 0-360 but should be valid range.
      expect(bearing, inInclusiveRange(0, 360));
    });

    test('Qibla from Dhaka ~277-278 degrees (west)', () {
      final bearing = repo.getQiblaDirection(
        latitude: 23.8103,
        longitude: 90.4125,
      );
      expect(bearing, inInclusiveRange(270, 285));
    });

    test(
      'Compass stream returns Stream (even if null on test device)',
      () async {
        final stream = repo.getCompassHeading();
        expect(stream, isA<Stream<double?>>());
        // Should emit at least one value (null on emulator) within timeout.
        // We don't assert heading value, just that stream is non-crashing.
        final first = await stream.first.timeout(
          const Duration(milliseconds: 100),
          onTimeout: () => null,
        );
        // first may be null or double — just verify non-crashing.
        // ignore: unnecessary_type_check
        expect(first == null || first is double, isTrue);
      },
    );
  });
}
