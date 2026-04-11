import 'dart:math';
import 'sensor_service.dart';

/// Represents the phone's orientation derived from gravity calibration.
/// gravityVector is the normalized gravity direction in phone coordinates.
class CalibrationResult {
  /// Normalized gravity vector in phone frame (unit vector pointing "down")
  final List<double> gravityVector;

  /// Rotation matrix from phone frame to world frame (3x3 stored flat)
  final List<double> rotationMatrix;

  CalibrationResult({required this.gravityVector, required this.rotationMatrix});
}

class CalibrationService {
  final List<AccelerometerReading> _samples = [];

  void addSample(AccelerometerReading reading) {
    _samples.add(reading);
  }

  int get sampleCount => _samples.length;

  /// Compute calibration from collected gravity samples.
  /// Averages all accelerometer readings to find the gravity vector,
  /// then builds a rotation matrix to decompose acceleration into
  /// vertical (gravity-aligned) and horizontal components.
  CalibrationResult? compute() {
    if (_samples.isEmpty) return null;

    // Average accelerometer readings to get gravity direction
    double gx = 0, gy = 0, gz = 0;
    for (final s in _samples) {
      gx += s.x;
      gy += s.y;
      gz += s.z;
    }
    gx /= _samples.length;
    gy /= _samples.length;
    gz /= _samples.length;

    final mag = sqrt(gx * gx + gy * gy + gz * gz);
    if (mag < 0.1) return null; // something wrong

    // Normalized gravity vector in phone frame
    final gNorm = [gx / mag, gy / mag, gz / mag];

    // Build rotation matrix: world Z = gravity direction (down)
    // We need to find two perpendicular axes in the horizontal plane.
    // Pick an arbitrary vector not parallel to gravity to form the basis.
    List<double> arbitrary;
    if (gNorm[0].abs() < 0.9) {
      arbitrary = [1, 0, 0];
    } else {
      arbitrary = [0, 1, 0];
    }

    // world X = arbitrary cross gravity (normalized) — one horizontal axis
    final wx = _cross(arbitrary, gNorm);
    final wxMag = _vecMag(wx);
    final worldX = [wx[0] / wxMag, wx[1] / wxMag, wx[2] / wxMag];

    // world Y = gravity cross worldX — the other horizontal axis
    final wy = _cross(gNorm, worldX);
    final wyMag = _vecMag(wy);
    final worldY = [wy[0] / wyMag, wy[1] / wyMag, wy[2] / wyMag];

    // Rotation matrix: rows are worldX, worldY, gNorm (gravity = Z down)
    // To transform phone-frame vector to world frame: multiply by this matrix
    final rotationMatrix = [
      worldX[0], worldX[1], worldX[2],
      worldY[0], worldY[1], worldY[2],
      gNorm[0], gNorm[1], gNorm[2],
    ];

    return CalibrationResult(
      gravityVector: gNorm,
      rotationMatrix: rotationMatrix,
    );
  }

  void reset() => _samples.clear();

  List<double> _cross(List<double> a, List<double> b) {
    return [
      a[1] * b[2] - a[2] * b[1],
      a[2] * b[0] - a[0] * b[2],
      a[0] * b[1] - a[1] * b[0],
    ];
  }

  double _vecMag(List<double> v) => sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
}

/// Decomposes a raw accelerometer reading into world-frame components
/// using the calibration rotation matrix.
class AccelerationDecomposer {
  final CalibrationResult calibration;

  /// GPS heading in radians (0 = north, clockwise).
  /// When set, horizontal axes are rotated so X = forward along heading.
  double? gpsHeadingRad;

  AccelerationDecomposer(this.calibration);

  /// Returns [forward, lateral, vertical] acceleration in m/s².
  /// Forward is along GPS heading if available, otherwise along world X.
  /// Gravity is subtracted (vertical component reduced by ~9.81).
  List<double> decompose(double ax, double ay, double az) {
    final r = calibration.rotationMatrix;

    // Transform to world frame
    double wx = r[0] * ax + r[1] * ay + r[2] * az;
    double wy = r[3] * ax + r[4] * ay + r[5] * az;
    double wz = r[6] * ax + r[7] * ay + r[8] * az;

    // Subtract gravity from vertical axis (Z is gravity-aligned)
    wz -= 9.81;

    // If GPS heading is available, rotate horizontal plane so X = forward
    if (gpsHeadingRad != null) {
      final h = gpsHeadingRad!;
      final cosH = cos(h);
      final sinH = sin(h);
      final forward = wx * cosH + wy * sinH;
      final lateral = -wx * sinH + wy * cosH;
      return [forward, lateral, wz];
    }

    return [wx, wy, wz];
  }
}
