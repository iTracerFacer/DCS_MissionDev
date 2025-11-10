# Copilot instructions for DCS_MissionDev

These notes teach AI coding agents how to be productive in this DCS World mission-scripting workspace. Keep responses concrete, reference the files below, and prefer making small targeted edits over broad rewrites.

## Big picture

- This repo is a DCS mission lab focused on Lua scripting for the MOOSE, MIST, CTLD, and CSAR ecosystems.
- Structure:
  - Root hosts shared framework scripts and utilities: `Moose_.lua`, `Moose.lua`, `mist.lua`, multiple pinned `mist_*` versions, `CTLD.lua`, `CSAR.lua`, plus helper and mission glue scripts (e.g., `NukeBlockerScriptv1_2_1.lua`, `OnBirthMessage.lua`).
  - Mission families live under `DCS_<Theater>/...` with individual `.miz` files and scenario folders.
  - Purpose-built modules live under `Moose_*/*` with a main Lua, demo `.miz`, and a README describing setup.
- Loading order matters in DCS: framework(s) first, then modules, then mission glue. Typical trigger order: `Moose_.lua` → framework/middleware → module script(s) → custom mission logic.

## Core modules and patterns (examples in repo)

- Zone Capture (dual coalition): `Moose_DualCoalitionZoneCapture/Moose_DualCoalitionZoneCapture.lua`
  - Edit-only config tables: `ZONE_CONFIG` (BLUE/RED/NEUTRAL lists) and `ZONE_SETTINGS` (scan/capture/guard).
  - Uses MOOSE classes like `ZONE`, `ZONE_CAPTURE_COALITION`, `COMMANDCENTER`, `MISSION`; logs via `env.info` with `[CAPTURE Module]` prefix.
  - Visuals driven by `ZONE_COLORS`; contested/attacked overrides ownership color.
- Dynamic Ground Battle: `Moose_DynamicGroundBattle/Moose_DynamicGroundBattle.lua`
  - User-edit section defines red/blue `ZONE:New(...)`, warehouse `STATIC:FindByName(...)`, and template arrays. After the “DO NOT EDIT BELOW THIS LINE” banner core logic runs.
  - Spawn rates scale with warehouse survival; periodic tasking (`ASSIGN_TASKS_SCHED`) retasks idle groups; optional infantry movement via `MOVING_INFANTRY_PATROLS`.
- CTLD: `CTLD.lua`
  - Large, configurable logistics/troop script; user config at top: smoke, hover pickup, crate rules, pickup/drop/wp zones, vehicle weights, JTAC settings, and transport pilot names.
  - Important distances: `ctld.maximumDistanceLogistic`, `ctld.minimumDeployDistance`, etc. Keep names matching ME zones strictly.
- CSAR: `CSAR.lua`
  - Note: the current file contains an HTML GitHub page artifact. When updating, replace with the raw Lua from ciribob/DCS-CSAR (use the Raw file, not the HTML page).

## Developer workflows (what to run and how)

- Script load in missions (Mission Editor → Triggers):
  1) DO SCRIPT FILE `Moose_.lua`
  2) DO SCRIPT FILE your module(s) (e.g., DualCoalitionZoneCapture or DynamicGroundBattle)
  3) DO SCRIPT FILE mission glue (CTLD/CSAR/others), respecting their config requirements
- Fast mission patching without opening the editor: `Patch-MooseMissions/`
  - Use `Patch-MooseMissions.ps1` to inject or replace a Lua inside a `.miz` and auto-bump version numbers.
  - See `Patch-MooseMissions/README.md` for examples (pipeline-friendly; default script location inside miz: `l10n/DEFAULT/*.lua`).
- Versioning conventions for missions: filenames embed the version (`F99th-Operation Ronin 1.4.miz` → next `1.5`); the patcher respects X, X.Y, X.Y.Z.
- Debugging:
  - Prefer `env.info("[Tag] message")`; check `Saved Games\DCS\Logs\DCS.log`. Modules log with distinct prefixes (e.g., `[CAPTURE Module]`).
  - Common issues: wrong zone/group/static names; framework not loaded first; CTLD/CSAR configs mismatched with ME. Fix by aligning names and load order.

## Conventions and gotchas (repo-specific)

- Name matching is strict across modules. Examples to copy:
  - Zones: `"Capture Zone-1"`, `"FrontLine7"`, etc.
  - HQ groups: `BLUEHQ`, `REDHQ` for MOOSE `COMMANDCENTER`/`MISSION` creation.
  - Warehouses: use Static object Unit Name: `RedWarehouse1-1`, `BlueWarehouse3-1`.
- Module layout: top “user config” section, followed by `-- DO NOT EDIT BELOW THIS LINE` guard. Keep PRs to config when possible; avoid editing engine logic unless necessary.
- Framework pinning: multiple `mist_*` versions live alongside `mist.lua`. Mission scripts may expect a specific version; don’t silently swap them—load the version matching the mission.
- CTLD settings commonly used here: `ctld.enableCrates`, `ctld.slingLoad`, `ctld.pickupZones`, `ctld.dropOffZones`, `ctld.wpZones`, `ctld.transportPilotNames`. Follow the existing style when extending.
- CSAR file hygiene: replace HTML artifacts with raw Lua. Verify by ensuring the file starts with Lua, not `<!DOCTYPE html>`.

## Integration points

- MOOSE: all advanced orchestration depends on `Moose_.lua`/`Moose.lua` APIs (`ZONE`, `GROUP`, `STATIC`, `ZONE_CAPTURE_COALITION`, `COMMANDCENTER`, `MISSION`, `SCORING`). Load it first.
- CTLD/CSAR interop: DynamicGroundBattle notes CTLD troops integrate automatically; ensure CTLD is active if you expect troop drops to influence zones.
- VoiceAttack: profiles under `Moose_CTLD_Pure/Voice Attack/` are player tooling, not runtime dependencies. Don’t reference them from mission scripts.

## Making changes safely

- When adding new zones/templates/warehouses, update the corresponding arrays in the module’s user config and mirror the names in the Mission Editor.
- When changing visuals or scan cadence, update `ZONE_COLORS` and `ZONE_SETTINGS` in Zone Capture, or scheduler values in Dynamic Ground Battle.
- For patching `.miz` with new `Moose_.lua`/scripts, prefer the PowerShell patcher; it preserves originals and bumps the version.

## Pointers to examples in this repo

- Dual coalition capture: `Moose_DualCoalitionZoneCapture/README.md` and example `.miz` in same folder.
- Dynamic ground battle: `Moose_DynamicGroundBattle/README.md`.
- Mission patching: `Patch-MooseMissions/README.md`.

If anything above is ambiguous (e.g., CSAR expected version, CTLD defaults for a specific mission family), ask for the target mission and we’ll codify the exact load order and script set.