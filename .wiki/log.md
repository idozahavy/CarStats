# Wiki Log

> Append-only record. Most recent entries at the bottom.

## [2026-04-18] build | Initial wiki generation
Pages created:
- architecture.md
- data-model.md
- stack.md
- conventions.md
- features/recording.md
- features/recording-history.md
- features/export-import.md
- features/settings.md
- features/benchmarks.md (planned)
- features/overlay-comparison.md (planned)
- features/session-metadata.md (planned)
- concepts/acceleration-calculation.md
- concepts/state-management.md
- index.md

Source: built from codebase + idea.md (subsequently deleted, content absorbed).

Logical errors corrected vs. idea.md:
- Quaternion/rotation-matrix storage was marked "Not Yet Implemented" in idea.md but is actually implemented (schema v3 `quat_w/x/y/z`, populated per sample by `RecordingEngine._assembleSample`). Moved to the recording feature page as implemented behaviour.
- idea.md described the 5 s countdown as sampling gravity **and** gyroscope. Actual `CalibrationService` only averages accelerometer readings; gyroscope is used for mid-recording orientation tracking, not calibration. Corrected in the acceleration-calculation concept page.
- idea.md said "JSON export" — both CSV export and JSON import exist too. Corrected in stack.md and features/export-import.md.
- idea.md described "User Recording" as a reduced data shape. Actual schema is identical for dev and user recordings; `isDevRecording` is only a filter flag. Corrected in data-model.md and features/recording-history.md.
- Magnetometer is listed as a planned sensor in idea.md and remains not implemented; captured only where relevant (not as a separate page).
