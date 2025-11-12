# Mission Performance & Memory Diagnostics

## Overview

This guide covers runtime checks and configuration adjustments you can use to monitor and tune the script systems used in Operation Polar Shield. It focuses on the pure-MOOSE CTLD integration, but several concepts apply to other Moose modules you employ.

## Console Helpers

### `CTLD_DumpRuntimeStats()`

**Purpose**
- Dump current counts of salvage crates, MEDEVAC crews, and active CTLD timers.
- Print the statuses of the adaptive salvage scheduler loop.

**How to use**
1. Open the DCS server console (LShift+LWin+L to focus, F12 to open the Lua console).
2. Execute:
   ```lua
   CTLD_DumpRuntimeStats()
   ```
3. Inspect server log (`Saved Games\DCS\Logs\dcs.log`) for output lines that start with `[CTLD]`.

**What it reports**
- Number of active salvage crates per coalition.
- Age distribution of salvage crates, including longest-living crate in seconds.
- Total scheduled timers registered via `_registerSchedule` (adaptive loops).
- Adaptive salvage interval currently in use.

### `CTLD_DumpCrateAges()`

**Purpose**
- Print a sorted list of active salvage crates with the spawn timestamp and remaining time until expiration.
- Useful to confirm that the 1-hour lifetime setting is applied and crates are pruned appropriately.

**How to use**
```lua
CTLD_DumpCrateAges()
```

### `CTLD_ListSchedules()`

**Purpose**
- Enumerate the CTLD scheduler registry entries (`smokeTicker`, `backgroundLoop`, `periodicGC`, etc.).
- Helps confirm that no duplicate or stale timer functions are registered.

**How to use**
```lua
CTLD_ListSchedules()
```

## Tracking Active Schedules

The adaptive background loop maintained by `_ensureAdaptiveBackgroundLoop()` returns the next wake-up time to `timer.scheduleFunction`. The runtime stats show the current loop period. When salvage crate count is low, the interval is short (twice the detection interval); it expands automatically with more crates.

### Typical values to expect
- Idle (no crates): background loop runs every 10 seconds.
- Moderate activity (up to 20 crates): loop every ~10 seconds.
- Heavy load (>20 crates): loop extends to 15–20 seconds automatically.

If you observe constant short intervals despite high crate counts, re-run `CTLD_ListSchedules()` to ensure no duplicate loops are reinstated.

## Salvage System Lifecycle

### Spawn limits
- Hard cap: 40 active salvage crates per coalition. Additional spawn opportunities are skipped once the cap is reached.
- Inline log entries record when spawn suppression occurs.

### Lifetime
- Each crate expires 3600 seconds (1 hour) after spawning.
- Adaptive cleanup sweeps run every minute to destroy expired crates and remove references.

## Tips for Long-Running Missions

- Use the console helpers every few hours to verify that salvage and MEDEVAC tables are not growing unexpectedly.
- Monitor the `dcs.log` for `[CTLD]` log statements; they will indicate when salvaged crates are skipped due to hitting the cap or when the adaptive interval increases.
- Consider tying the new helper functions to your existing remote admin tool/Discord bot for quick telemetry.

For additional tuning (e.g., adjusting detection frequency or spawn caps), modify the `SlingLoadSalvage` configuration block in `Moose_CTLD.lua`.
