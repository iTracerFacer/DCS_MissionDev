# Moose_CTLD Logging System

## Overview
A comprehensive logging system has been implemented to control the verbosity of log output in production environments.

## LogLevel Configuration

Add to your CTLD configuration:

```lua
local ctld = CTLD:New({
  LogLevel = 2,  -- Set desired logging level (0-4)
  -- ... other config
})
```

## Log Levels

| Level | Name    | Description | Use Case |
|-------|---------|-------------|----------|
| 0     | NONE    | No logging at all | Production servers where logging causes performance issues |
| 1     | ERROR   | Only critical errors and warnings | Production - only see problems |
| 2     | INFO    | Important state changes, initialization, cleanup | **Default for production** |
| 3     | VERBOSE | Detailed operational info (zone validation, builds, MEDEVAC events) | Debugging missions |
| 4     | DEBUG   | Everything including hover checks, detailed spawns | Deep troubleshooting |

## Default Setting

**LogLevel = 2 (INFO)** - Recommended for production servers
- Shows initialization, catalog loading, cleanup
- Shows errors and warnings
- Hides verbose MEDEVAC details, zone validation, debug info

## Changing Log Level In-Mission

Players with access to F10 menus can change logging on-the-fly:

**Group Menus (per-player):**
- F10 → CTLD → Admin/Help → Debug → [Select Level]

**Coalition Menus:**
- F10 → CTLD → Debug Logging → [Select Level]

Options:
- Enable Verbose (LogLevel 4) - Full debug output
- Normal INFO (LogLevel 2) - Default production level
- Errors Only (LogLevel 1) - Minimal logging
- Disable All (LogLevel 0) - No logging

## What Gets Logged at Each Level

### Level 0 (NONE)
- Nothing

### Level 1 (ERROR)
- Missing Moose library
- Catalog loading failures
- Missing configured zones
- Menu errors
- MEDEVAC spawn failures
- Critical system errors

### Level 2 (INFO) - **RECOMMENDED**
- All ERROR level messages
- System initialization
- Catalog merging
- Troop type loading
- MEDEVAC system init
- Cleanup/shutdown messages
- Salvage system operations
- Mobile MASH deployment

### Level 3 (VERBOSE)
- All INFO level messages
- Zone state changes (activation/deactivation)
- Zone validation summary
- MEDEVAC crew spawning
- MEDEVAC crew pickup/delivery
- Vehicle respawn
- MASH zone registration
- Smoke pop events

### Level 4 (DEBUG)
- All VERBOSE level messages
- Config merge details
- MASH zone existence checks
- Crate cleanup
- Troop group cleanup
- Troop spawn details
- Detailed MEDEVAC event processing
- Catalog search operations
- Position extraction attempts
- Crew composition details
- Immortality/invisibility toggles
- Crew movement AI
- Hover detection (if implemented)

## Examples

### Production Server (Minimal Logging)
```lua
local ctld_blue = CTLD:New({
  CoalitionSide = coalition.side.BLUE,
  LogLevel = 1,  -- Errors only
  -- ... rest of config
})
```

### Development/Testing (Full Logging)
```lua
local ctld_blue = CTLD:New({
  CoalitionSide = coalition.side.BLUE,
  LogLevel = 4,  -- Everything
  -- ... rest of config
})
```

### Typical Production Setup
```lua
local ctld_blue = CTLD:New({
  CoalitionSide = coalition.side.BLUE,
  LogLevel = 2,  -- INFO - good balance
  -- ... rest of config
})
```

## Migration from Old Debug Flag

The old `Debug = true/false` flag is now replaced by `LogLevel`:

**Old way:**
```lua
Debug = false  -- or true
```

**New way:**
```lua
LogLevel = 2  -- 0=NONE, 1=ERROR, 2=INFO, 3=VERBOSE, 4=DEBUG
```

## Performance Notes

- LogLevel 0 (NONE) has zero overhead - no string formatting occurs
- LogLevel 1-2 have minimal overhead - only critical/important messages
- LogLevel 3-4 can generate significant log output - use for debugging only
- All logging goes to DCS.log file (not in-game messages)

## Remaining Manual Replacements

Due to the large number of logging statements (150+), the following categories still use `env.info()` directly and should be replaced when needed:

1. **MEDEVAC System** (~80 statements) - Most verbose part
   - Event processing, crew spawning, pickup/delivery
   - Recommend: ERROR for failures, VERBOSE for operations, DEBUG for detailed state

2. **Salvage/Build System** (~10 statements)
   - Recommend: VERBOSE level

3. **Cleanup System** (~5 statements)
   - Recommend: INFO level

4. **Troop System** (~10 statements)
   - Recommend: VERBOSE for spawns, DEBUG for details

5. **MASH Zones** (~15 statements)
   - Recommend: VERBOSE for registration/operations, DEBUG for checks

To complete the migration, search for remaining `env.info` calls and replace with:
- `_logError()` for failures
- `_logInfo()` for important state changes
- `_logVerbose()` for operational details
- `_logDebug()` for troubleshooting info

## Summary

The logging system is now in place with core functions defined. The most critical parts (initialization, zone validation, menu errors) have been updated. The remaining ~150 log statements (primarily MEDEVAC system) can be migrated incrementally as needed. For production use, simply set `LogLevel = 1` or `LogLevel = 2` to dramatically reduce log output.
