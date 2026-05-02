# AI_TODO — Phase Plan

> Self-contained phase prompts. Each file is designed to run in a **fresh agent context** with zero memory of previous phases. Embed-everything-you-need is the rule — do not cross-reference between phase files.

## Run order

| # | File | Title | Approx scope | Completed |
|---|---|---|---|---|
| 01 | [phase_01_cleanup.md](phase_01_cleanup.md) | Cleanup & dependencies | Small | [x] |
| 02 | [phase_02_robustness.md](phase_02_robustness.md) | Robustness pass | Medium | [x] |
| 03 | [phase_03_charts_polish.md](phase_03_charts_polish.md) | Charts polish + flaky-test investigation | Small | [x] |
| 04 | [phase_04_ux_polish.md](phase_04_ux_polish.md) | UX polish (name, rename, share, empty states) | Medium | [x] |
| 05 | [phase_05_i18n.md](phase_05_i18n.md) | i18n scaffolding (English + Hebrew, RTL) | Medium | [x] |
| 06 | [phase_06_session_metadata.md](phase_06_session_metadata.md) | Session metadata + car profiles (schema v5) | Large | [x] |
| 07 | [phase_07_recording_validation.md](phase_07_recording_validation.md) | Recording-pipeline validation against synthetic inputs + data-quality badge | Medium-Large | [ ] |
| 08 | [phase_08_benchmarks.md](phase_08_benchmarks.md) | Benchmarks (0–100, ¼ mile, max-accel-at-speed, sudden-accel) | Large | [ ] |
| 09 | [phase_09_overlay_comparison.md](phase_09_overlay_comparison.md) | Overlay comparison of two recordings | Medium-Large | [ ] |
| 10 | [phase_10_infrastructure.md](phase_10_infrastructure.md) | App icon, README, CHANGELOG, CI, signing docs | Medium | [ ] |

## Conventions for every phase

- Read `.wiki/index.md` first, then the wiki pages listed in the phase's "Context primer".
- After schema edits: `dart run build_runner build --delete-conflicting-outputs`.
- Migrations are additive only — bump `schemaVersion` and append an `if (from < N)` block. Never drop or rename columns.
- A phase is **done** only when:
  1. `flutter analyze` returns "No issues found"
  2. `flutter test` all green
  3. Affected wiki pages updated per `.wiki/SCHEMA.md` (bump `Last verified`, add log entry)
  4. No half-finished code, no orphan TODOs, no commented-out blocks

## How to run a phase

```
1. Open a fresh chat in the project root.
2. Paste the contents of the phase file as the prompt.
3. Let the agent execute end-to-end.
4. Review the diff, run the app on a device, then merge.
```
