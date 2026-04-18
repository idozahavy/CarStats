### Acceleration Calculation

> The math pipeline that turns raw phone accelerometer + gyroscope + GPS into the car's forward / lateral / vertical acceleration in a world frame, independent of phone orientation.

**Scope:** [lib/services/calibration_service.dart](lib/services/calibration_service.dart), [lib/services/recording_engine.dart](lib/services/recording_engine.dart)
**Last verified:** 2026-04-18

---

### Summary

The phone may be mounted in any arbitrary orientation. The app establishes a gravity-aligned world frame at the start, tracks orientation changes continuously, subtracts gravity, and uses GPS heading to lock the forward axis to the car's actual direction of travel.

### Pipeline

```
                    (during 5 s countdown)
 accel samples ─► CalibrationService.compute()
                     ├─ average → gravity vector (phone frame)
                     └─ build rotation matrix R₀
                        (worldZ = gravity,
                         worldX/Y = arbitrary orthonormal pair)

                    (during recording)
 accel samples ─► correctWithAccel   ┐
 gyro samples  ─► updateWithGyro(dt) │ mutate R over time
 gps heading   ─► gpsHeadingRad  ────┘
                          │
                          ▼
            decompose(ax, ay, az) returns
            [forward, lateral, vertical]
```

### Step 1 — Gravity calibration (5 s countdown)

`CalibrationService` accumulates raw accelerometer samples. `compute()` averages them to find the gravity direction **in phone coordinates**, then builds a 3×3 rotation matrix:

- `worldZ` = the measured gravity direction (points "down").
- `worldX` = an arbitrary horizontal axis (cross product of an axis unlikely to be parallel to gravity with the gravity vector, then normalised).
- `worldY` = `gravity × worldX` (completes a right-handed basis).

This frame has a real vertical axis but **arbitrary horizontal rotation** — which is what step 3 later fixes.

Note: only the accelerometer participates in calibration. Gyroscope is not sampled during the countdown.

### Step 2 — Continuous orientation tracking

While recording, `AccelerationDecomposer` keeps the rotation matrix live:

- **Gyroscope integration** (`updateWithGyro`): Rodrigues rotation formula. Each gyro sample rotates the world-frame mapping by `-ω · dt`. High-bandwidth but drifts over time.
- **Complementary-filter gravity correction** (`correctWithAccel`): when the raw accelerometer magnitude is within ±2 m/s² of 9.81, the phone is under low dynamic motion and the accelerometer reading is dominated by gravity. The current world-Z is blended toward the new measurement with `α = 0.02`, then the basis is re-orthogonalised. The tolerance gate prevents car acceleration from corrupting the gravity estimate.

Together: gyroscope provides responsive short-term tracking, accelerometer corrects long-term drift.

### Step 3 — Heading auto-calibration

After calibration, the horizontal `worldX`/`worldY` axes are arbitrary — they don't yet correspond to "forward along the car". `HeadingCalibrator` learns the offset between `worldX` and geographic north by correlating horizontal acceleration direction with GPS heading during clear acceleration/braking events:

- Qualifying sample: horizontal accel magnitude ≥ 1.0 m/s² **and** GPS speed change ≥ 0.3 m/s.
- Braking (`speedDelta < 0`) flips the measured accel angle by π (accel points opposite to heading).
- First 8 qualifying samples → circular mean → initial offset lock.
- Further samples → exponential moving average with α = 0.05.

Once locked, `decompose()` rotates the horizontal plane by `gpsHeading - offset` so the first returned axis is car-forward.

### Step 4 — Decomposition

`decompose(ax, ay, az)` per accel sample:

1. Transform raw reading into world frame: `w = R · a`.
2. Subtract gravity on the vertical axis: `wz -= 9.81`.
3. If GPS heading is available and the calibrator has converged, rotate the horizontal components by `-(gpsHeading - offset)` so axis 0 = forward along direction of travel, axis 1 = lateral.
4. Return `[forward, lateral, vertical]` (m/s²).

### GPS thresholds

| Constant | Value | Meaning |
|---|---|---|
| `gpsMinSpeedForHeading` | 2.0 m/s | Below this, OS GPS heading is too noisy to feed into the decomposer |
| `gpsStationarySpeed` | 0.5 m/s | Below this, the car is treated as stopped (display snaps speed to 0) |
| `accelNoiseFloor` | 0.05 g | When stopped, displayed |accel| below this is snapped to 0 |

### Stored orientation per sample

Each `SensorSamples` row carries the current gravity vector (`gravX/Y/Z`, the Z row of R) and the world-from-phone quaternion (`quatW/X/Y/Z`, Shepperd's method). This lets a future analysis replay or transform the data without re-running the filter.

### Why

- **No mount constraint** — the user can drop the phone anywhere. Calibration + GPS-heading correction make it work.
- **Gyro + accel complementary filter** — robust against both short-term jitter (gravity-only would be noisy) and long-term drift (gyro-only integrates error).
- **Heading EMA refinement** — lets the forward axis keep tracking if the initial lock was imperfect (calibrating while the car was slightly moving, for example).

### Related pages

- [recording](../features/recording.md) — the engine that drives this pipeline
- [data-model](../data-model.md) — where the outputs are stored
