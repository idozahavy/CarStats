# CarStats

Native Flutter app that records phone sensors to measure a car's acceleration at specific speeds.

The user mounts the phone anywhere in the car (dashboard, mount, cupholder — any orientation). The app auto-calibrates during a 5-second countdown before recording starts. During recording, it continuously tracks device orientation changes and corrects acceleration direction in real time. GPS heading is used to validate and correct the forward-acceleration axis.

**GPS is the only viable speed source.** The speed vs. acceleration graph uses GPS speed as the x-axis. Accelerometer data provides the high-frequency acceleration values, but speed comes from GPS.


## Platform

- **Framework:** Flutter (native Android/iOS)
- **Sensors:** Accelerometer (raw + `TYPE_LINEAR_ACCELERATION`), gyroscope, magnetometer, GPS
- **Storage:** Local SQLite for recordings, JSON export


## Calibration

The app must handle any arbitrary phone orientation and rotation during a session:

1. **Countdown calibration** — When the user starts a recording, a 5→0 second countdown begins. During this countdown the app performs auto-calibration: samples the gravity vector and gyroscope to lock the phone's orientation. Ideally the car is stationary or at constant speed for best accuracy, but not required — GPS heading data will correct any calibration offset on the fly once the car moves.
2. **Continuous rotation tracking** — Gyroscope integration tracks any phone orientation changes mid-recording and adjusts the acceleration decomposition in real time.
3. **GPS heading correction** — Use GPS-derived heading (direction between consecutive GPS points) to validate and correct the forward-axis mapping. This compensates for drift in gyroscope integration over time.
4. **No mount constraint** — The phone can be in any orientation: flat, vertical, angled, portrait, landscape.


## Acceleration Calculation

The car's forward acceleration is extracted by:

1. Determining phone orientation via gravity vector + gyroscope.
2. Decomposing raw accelerometer data into car-forward, car-lateral, and vertical components.
3. Subtracting gravity to isolate motion acceleration.
4. Using GPS heading to confirm which axis is "forward."

**Dev mode shows both side by side:**
- Custom calculation (raw accelerometer → orientation decomposition → gravity subtraction → forward acceleration)
- `TYPE_LINEAR_ACCELERATION` / platform-provided linear acceleration

This allows comparing and validating the custom pipeline against the OS sensor fusion.


## Recordings

Two recording types, with benchmarks derived as a view:

### Dev Recording
All raw sensor data for development and analysis:
- Raw accelerometer (x, y, z)
- `TYPE_LINEAR_ACCELERATION` (x, y, z) — platform sensor fusion result
- Custom calculated forward acceleration (side by side with above)
- Gyroscope (x, y, z)
- Magnetometer (x, y, z)
- Gravity vector
- Barometric pressure
- GPS position, GPS speed, GPS heading
- GPS-derived direction (bearing between consecutive points)
- Computed phone orientation (quaternion / rotation matrix)
- Timestamp (high resolution)

### User Recording
Clean recording for end users:
- GPS speed
- Calculated car forward acceleration
- Timestamp
- Session metadata (see below)

### Benchmark View (derived from User Recording)
Processed summary computed post-run from a user recording. Not a separate capture — a computed analysis.

**Two benchmark types:**

1. **Max acceleration at speed** — Peak acceleration the car can produce at a given speed. Example: maximum g-force available at 60 km/h, 80 km/h, 100 km/h. Shows the car's power curve in real-world terms.
2. **Sudden acceleration at speed** — The car is cruising at a steady speed (e.g., 60 km/h), then the driver floors it. Measures the acceleration response: how quickly the car responds and the g-force produced from a semi-resting state. Shows real-world overtaking / merging capability.

**Standard benchmarks (computed when enough data exists):**
- 0–100 km/h time
- 0–60 mph time
- 80–120 km/h time (in-gear pull)
- Quarter mile (400m) time and trap speed

### Export
The user can export any recording to a JSON file.


## Session Metadata

Every recording captures as much context as possible:

- Car model / make / year (user input, saved as profile)
- Fuel type (petrol / diesel / electric / hybrid)
- Fuel level / battery % (if electric)
- Tire type / brand / size
- Air temperature (from barometric sensor or user input)
- Weather conditions (user input or API)
- Altitude (from GPS + barometer)
- Road surface type (user input)
- Passenger count / load estimate
- Drive mode (eco / normal / sport — user input)
- Transmission type (auto / manual / DCT)
- Gear (if manual — user input)
- Windows open/closed, AC on/off (user input)
- Date, time, location name
- Device model and OS version


## Overlay Comparison

Users can select two recordings and overlay them on the same graph:
- Speed vs. acceleration curves plotted together
- Aligned by speed (x-axis = speed) or by time (x-axis = elapsed time)
- Visual diff highlighting where one run outperforms another
- **Sudden acceleration comparison** — Compare sudden acceleration events at the same starting speed across recordings. Shows how the car responds differently under different conditions (temperature, load, drive mode, modifications).
- Use case: compare runs before/after modification, different weather, different drive modes


## Implementation Status

### MVP (v0.1.0) — Implemented

- [x] Flutter project scaffolding (Android + iOS)
- [x] Sensor service: accelerometer (raw + linear via `sensors_plus`), gyroscope
- [x] GPS service: speed, heading, position via `geolocator`
- [x] 5-second countdown calibration (gravity vector averaging → rotation matrix)
- [x] Acceleration decomposition: raw accel → world frame → gravity subtraction → forward acceleration
- [x] GPS heading correction of forward axis
- [x] Recording engine: coordinates sensors + GPS, buffers and batch-inserts to DB
- [x] Drift (SQLite) database with `Recordings` and `SensorSamples` tables
- [x] Home screen with start recording button
- [x] Recording screen: live countdown → live speed/accel stats + speed-vs-accel chart
- [x] Recording detail screen: summary cards + 3 charts (speed vs accel, accel vs time, speed vs time)
- [x] Recordings list screen with delete support
- [x] Settings screen: light/dark/system theme picker, dev mode toggle
- [x] Dev mode: shows platform linear acceleration magnitude alongside custom calculation during recording
- [x] Android + iOS permissions configured (location, sensors)
- [x] Provider-based state management

### Not Yet Implemented

- [ ] Continuous rotation tracking (gyroscope integration mid-recording)
- [ ] Magnetometer integration
- [ ] Barometric pressure sensor
- [ ] Session metadata (car profile, fuel, tires, weather, etc.)
- [ ] Car profile management (vehicle database lookup + free text)
- [ ] Benchmark view (0–100, quarter mile, max accel at speed, sudden accel)
- [ ] Overlay comparison (two recordings on same graph)
- [ ] JSON export
- [ ] GPS-derived direction (bearing between consecutive points)
- [ ] Computed phone orientation storage (quaternion / rotation matrix per sample)
- [ ] Gravity vector storage per sample
- [ ] Separate dev vs user recording types in UI
