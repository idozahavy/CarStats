import 'dart:math';
import 'sensor_service.dart';

/// Represents the phone's orientation derived from gravity calibration.
/// gravityVector is the normalized gravity direction in phone coordinates.
class CalibrationResult {
  /// Normalized gravity vector in phone frame (unit vector pointing "down")
  final List<double> gravityVector;

  /// Rotation matrix from phone frame to world frame (3x3 stored flat)
  final List<double> rotationMatrix;

  CalibrationResult({
    required this.gravityVector,
    required this.rotationMatrix,
  });
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
      worldX[0],
      worldX[1],
      worldX[2],
      worldY[0],
      worldY[1],
      worldY[2],
      gNorm[0],
      gNorm[1],
      gNorm[2],
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

  double _vecMag(List<double> v) =>
      sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
}

/// Determines the angular offset between the arbitrary world-frame horizontal
/// axes and geographic north by correlating horizontal acceleration direction
/// with GPS heading during periods of clear acceleration/braking.
///
/// Uses a circular mean for initial lock (first [_minSamples] samples),
/// then an exponential moving average for continuous refinement.
class HeadingCalibrator {
  double _sinSum = 0;
  double _cosSum = 0;
  int _sampleCount = 0;
  double? _offset;

  bool get isCalibrated => _offset != null;
  double? get offset => _offset;

  /// Minimum qualifying samples before declaring calibrated.
  static const int _minSamples = 8;

  /// Horizontal accel must exceed this to be a useful heading signal.
  static const double _minHorizontalAccel = 1.0; // m/s²

  /// GPS speed must change by at least this between ticks.
  static const double _minSpeedChange = 0.3; // m/s

  /// After initial lock, blend new corrections with this weight.
  static const double _refineAlpha = 0.05;

  /// Offer a heading sample from current horizontal accel and GPS data.
  /// [wx], [wy]: horizontal acceleration in world frame (from decompose).
  /// [gpsHeadingRad]: GPS heading in radians (0 = north, CW).
  /// [speedDelta]: change in GPS speed since last tick (m/s), positive = accelerating.
  void addSample({
    required double wx,
    required double wy,
    required double gpsHeadingRad,
    required double speedDelta,
  }) {
    final horizMag = sqrt(wx * wx + wy * wy);
    if (horizMag < _minHorizontalAccel) return;
    if (speedDelta.abs() < _minSpeedChange) return;

    // Accel angle in our arbitrary world frame
    double accelAngle = atan2(wy, wx);
    // When braking, accel points opposite to heading — flip to align
    if (speedDelta < 0) accelAngle += pi;

    // The offset from our worldX to geographic north
    final sampleOffset = gpsHeadingRad - accelAngle;

    if (!isCalibrated) {
      // Accumulate for circular mean
      _sinSum += sin(sampleOffset);
      _cosSum += cos(sampleOffset);
      _sampleCount++;
      if (_sampleCount >= _minSamples) {
        _offset = atan2(_sinSum / _sampleCount, _cosSum / _sampleCount);
      }
    } else {
      // Refine with EMA on the angular difference
      double diff = sampleOffset - _offset!;
      // Normalize to [-π, π]
      while (diff > pi) {
        diff -= 2 * pi;
      }
      while (diff < -pi) {
        diff += 2 * pi;
      }
      _offset = _offset! + _refineAlpha * diff;
    }
  }
}

/// Decomposes a raw accelerometer reading into world-frame components.
/// Orientation is tracked continuously via a complementary filter:
///   - Gyroscope integration (Rodrigues) for responsive, short-term tracking.
///   - Accelerometer gravity correction (small alpha blend) applied only when
///     the accel magnitude is close to 9.81 m/s² (i.e. low dynamic motion),
///     preventing car acceleration from corrupting the gravity estimate.
class AccelerationDecomposer {
  final CalibrationResult calibration;

  /// Mutable rotation matrix, updated by gyroscope + complementary correction.
  late List<double> _rotationMatrix;

  /// GPS heading in radians (0 = north, clockwise).
  /// When set, horizontal axes are rotated so X = forward along heading.
  double? gpsHeadingRad;

  /// Complementary filter blend factor. Small value = slow correction, stable.
  /// At 50 Hz with alpha 0.02, the time constant is ~1 s (converges in ~3-5 s).
  static const double _alpha = 0.02;

  /// Max deviation from 9.81 to trust accel as a gravity measurement.
  static const double _gravityTolerance = 2.0; // m/s²

  AccelerationDecomposer(this.calibration)
    : _rotationMatrix = List<double>.from(calibration.rotationMatrix);

  /// Heading auto-calibrator — learns the offset between worldX and north.
  final HeadingCalibrator _headingCalibrator = HeadingCalibrator();

  /// Whether the heading offset has been auto-calibrated.
  bool get isHeadingCalibrated => _headingCalibrator.isCalibrated;

  // Last horizontal world-frame accel (for heading calibration correlation)
  double _lastWx = 0;
  double _lastWy = 0;

  /// Call on each GPS update with the speed change since the last tick.
  /// Used to correlate horizontal accel direction with GPS heading.
  void onGpsUpdate(double headingRad, double speedDeltaMps) {
    _headingCalibrator.addSample(
      wx: _lastWx,
      wy: _lastWy,
      gpsHeadingRad: headingRad,
      speedDelta: speedDeltaMps,
    );
  }

  /// Apply a complementary-filter gravity correction from a raw accel sample.
  /// Only corrects when the phone is under low dynamic acceleration — when
  /// the magnitude is close to 9.81, the reading is mostly gravity.
  void correctWithAccel(double ax, double ay, double az) {
    final mag = sqrt(ax * ax + ay * ay + az * az);
    if ((mag - 9.81).abs() > _gravityTolerance || mag < 0.5) return;

    // Measured gravity direction in phone frame
    final measGrav = [ax / mag, ay / mag, az / mag];

    // Current estimated gravity direction (Z row of rotation matrix)
    final estGrav = [
      _rotationMatrix[6],
      _rotationMatrix[7],
      _rotationMatrix[8],
    ];

    // Blend: corrected = normalize(estGrav + alpha * (measGrav - estGrav))
    final corrGrav = [
      estGrav[0] + _alpha * (measGrav[0] - estGrav[0]),
      estGrav[1] + _alpha * (measGrav[1] - estGrav[1]),
      estGrav[2] + _alpha * (measGrav[2] - estGrav[2]),
    ];
    final corrMag = sqrt(
      corrGrav[0] * corrGrav[0] +
          corrGrav[1] * corrGrav[1] +
          corrGrav[2] * corrGrav[2],
    );
    if (corrMag < 0.1) return;
    corrGrav[0] /= corrMag;
    corrGrav[1] /= corrMag;
    corrGrav[2] /= corrMag;

    // Re-orthogonalise X: remove gravity component so it stays horizontal.
    final curX = [_rotationMatrix[0], _rotationMatrix[1], _rotationMatrix[2]];
    final dot =
        curX[0] * corrGrav[0] + curX[1] * corrGrav[1] + curX[2] * corrGrav[2];
    final newX = [
      curX[0] - dot * corrGrav[0],
      curX[1] - dot * corrGrav[1],
      curX[2] - dot * corrGrav[2],
    ];
    final xMag = sqrt(
      newX[0] * newX[0] + newX[1] * newX[1] + newX[2] * newX[2],
    );
    if (xMag < 0.01) return;
    newX[0] /= xMag;
    newX[1] /= xMag;
    newX[2] /= xMag;

    // Y = corrGrav × newX (completes right-handed basis)
    final newY = [
      corrGrav[1] * newX[2] - corrGrav[2] * newX[1],
      corrGrav[2] * newX[0] - corrGrav[0] * newX[2],
      corrGrav[0] * newX[1] - corrGrav[1] * newX[0],
    ];
    final yMag = sqrt(
      newY[0] * newY[0] + newY[1] * newY[1] + newY[2] * newY[2],
    );
    if (yMag < 0.01) return;
    newY[0] /= yMag;
    newY[1] /= yMag;
    newY[2] /= yMag;

    _rotationMatrix = [
      newX[0],
      newX[1],
      newX[2],
      newY[0],
      newY[1],
      newY[2],
      corrGrav[0],
      corrGrav[1],
      corrGrav[2],
    ];
  }

  /// Integrate gyroscope angular velocity [gx, gy, gz] (rad/s, phone frame)
  /// over [dtSec] seconds to rotate the world-frame mapping.
  ///
  /// Uses the Rodrigues rotation formula applied as:
  ///   R_new = R_old * Rodrigues(-omega * dt)
  /// (negative sign because the world axes move opposite to the phone).
  void updateWithGyro(double gx, double gy, double gz, double dtSec) {
    final tx = gx * dtSec;
    final ty = gy * dtSec;
    final tz = gz * dtSec;
    final angle = sqrt(tx * tx + ty * ty + tz * tz);
    if (angle < 1e-9) return;

    final sinA = sin(angle);
    final cosA = cos(angle);
    final oneMinusCosA = 1.0 - cosA;
    final nx = tx / angle;
    final ny = ty / angle;
    final nz = tz / angle;

    // Rodrigues rotation matrix for this small step
    final dR = [
      cosA + nx * nx * oneMinusCosA,
      nx * ny * oneMinusCosA - nz * sinA,
      nx * nz * oneMinusCosA + ny * sinA,
      ny * nx * oneMinusCosA + nz * sinA,
      cosA + ny * ny * oneMinusCosA,
      ny * nz * oneMinusCosA - nx * sinA,
      nz * nx * oneMinusCosA - ny * sinA,
      nz * ny * oneMinusCosA + nx * sinA,
      cosA + nz * nz * oneMinusCosA,
    ];

    // R_new = R_old * dR  (3×3 matrix multiply)
    final r = List<double>.filled(9, 0.0);
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        for (int k = 0; k < 3; k++) {
          r[i * 3 + j] += _rotationMatrix[i * 3 + k] * dR[k * 3 + j];
        }
      }
    }
    _rotationMatrix = r;
  }

  /// Returns [forward, lateral, vertical] acceleration in m/s².
  /// Forward is along GPS heading if available, otherwise along world X.
  /// Gravity is subtracted (vertical component reduced by ~9.81).
  List<double> decompose(double ax, double ay, double az) {
    final r = _rotationMatrix;

    // Transform to world frame
    double wx = r[0] * ax + r[1] * ay + r[2] * az;
    double wy = r[3] * ax + r[4] * ay + r[5] * az;
    double wz = r[6] * ax + r[7] * ay + r[8] * az;

    // Subtract gravity from vertical axis (Z is gravity-aligned)
    wz -= 9.81;

    // Cache horizontal accel for heading calibration
    _lastWx = wx;
    _lastWy = wy;

    // If GPS heading is available, rotate horizontal plane so X = forward.
    // Subtract the auto-calibrated offset (0 before calibration converges).
    if (gpsHeadingRad != null) {
      final offset = _headingCalibrator.offset ?? 0.0;
      final h = gpsHeadingRad! - offset;
      final cosH = cos(h);
      final sinH = sin(h);
      final forward = wx * cosH + wy * sinH;
      final lateral = -wx * sinH + wy * cosH;
      return [forward, lateral, wz];
    }

    return [wx, wy, wz];
  }

  /// Returns the current estimated gravity direction in phone frame
  /// as [pitch, roll] in degrees.
  /// Pitch: angle between gravity and phone's Z axis projected onto YZ plane.
  /// Roll: angle between gravity and phone's Z axis projected onto XZ plane.
  List<double> get orientationDegrees {
    final gx = _rotationMatrix[6];
    final gy = _rotationMatrix[7];
    final gz = _rotationMatrix[8];
    // Pitch: rotation about phone X axis (tilting forward/back)
    final pitch = atan2(gy, gz) * (180.0 / pi);
    // Roll: rotation about phone Y axis (tilting left/right)
    final roll = atan2(gx, gz) * (180.0 / pi);
    return [pitch, roll];
  }

  /// Returns the current estimated gravity vector in phone frame [gx, gy, gz].
  /// This is the Z row of the rotation matrix (gravity-aligned axis).
  List<double> get gravityVector => [
    _rotationMatrix[6],
    _rotationMatrix[7],
    _rotationMatrix[8],
  ];
}
