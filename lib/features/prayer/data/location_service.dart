import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Never-crash location service — offline-first, privacy respecting.
///
/// Returns a valid coordinate always. If permission denied or service
/// disabled, returns the spiritual fallback — Mecca (Kaaba).
/// No network call, computed on-device only (DEEN 76, 12).
class AppLocation {
  const AppLocation(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  @override
  String toString() => 'AppLocation($latitude, $longitude)';

  @override
  bool operator ==(Object other) =>
      other is AppLocation &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

class LocationService {
  /// Spiritual fallback — Kaaba, Mecca.
  static const AppLocation fallbackMecca = AppLocation(21.3891, 39.8579);

  /// Checks permission via permission_handler, then fetches via geolocator.
  /// Never throws — always returns a location.
  Future<AppLocation> getCurrentLocation() async {
    try {
      // Permission check — permission_handler is source of truth for UI prompt.
      final status = await Permission.locationWhenInUse.status;
      if (status.isDenied || status.isRestricted) {
        final requested = await Permission.locationWhenInUse.request();
        if (!requested.isGranted && !requested.isLimited) {
          return fallbackMecca;
        }
      } else if (status.isPermanentlyDenied) {
        return fallbackMecca;
      }

      // Geolocator service check.
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return fallbackMecca;
      }

      // Geolocator permission sync (covers cases where permission_handler
      // and geolocator disagree on platform).
      var geoPermission = await Geolocator.checkPermission();
      if (geoPermission == LocationPermission.denied) {
        geoPermission = await Geolocator.requestPermission();
        if (geoPermission == LocationPermission.denied ||
            geoPermission == LocationPermission.deniedForever) {
          return fallbackMecca;
        }
      }
      if (geoPermission == LocationPermission.deniedForever) {
        return fallbackMecca;
      }

      // Try last known first (fast, no GPS fix needed).
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        // Still attempt fresh fix, but lastKnown is immediate fallback if fetch times out.
        try {
          final fresh = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
              timeLimit: Duration(seconds: 8),
            ),
          );
          return AppLocation(fresh.latitude, fresh.longitude);
        } catch (_) {
          return AppLocation(lastKnown.latitude, lastKnown.longitude);
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return AppLocation(position.latitude, position.longitude);
    } catch (_) {
      // Absolute never-crash guarantee.
      return fallbackMecca;
    }
  }
}
