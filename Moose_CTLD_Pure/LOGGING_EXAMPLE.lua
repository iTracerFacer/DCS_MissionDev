-- Example: Using Moose_CTLD with Logging Control
-- This example shows how to configure logging levels for different environments

-- =========================
-- Production Server (Minimal Logging)
-- =========================
-- Only logs errors - keeps DCS.log clean
local ctld_blue_prod = CTLD:New({
  CoalitionSide = coalition.side.BLUE,
  LogLevel = 1,  -- 1 = ERROR only
  RootMenuName = 'CTLD',
  -- ... rest of your config
})

-- =========================
-- Development Server (Full Logging)
-- =========================
-- Logs everything for debugging
local ctld_blue_dev = CTLD:New({
  CoalitionSide = coalition.side.BLUE,
  LogLevel = 4,  -- 4 = DEBUG (everything)
  RootMenuName = 'CTLD',
  -- ... rest of your config
})

-- =========================
-- Typical Production (Recommended)
-- =========================
-- Logs important events but not verbose details
local ctld_blue = CTLD:New({
  CoalitionSide = coalition.side.BLUE,
  LogLevel = 2,  -- 2 = INFO (recommended default)
  RootMenuName = 'CTLD',
  UseGroupMenus = true,
  -- ... rest of your config
})

-- =========================
-- Log Level Reference
-- =========================
-- 0 = NONE    - No logging at all (maximum performance)
-- 1 = ERROR   - Only errors and warnings (production minimum)
-- 2 = INFO    - Important events: init, cleanup, salvage (RECOMMENDED for production)
-- 3 = VERBOSE - Operational details: zone changes, MEDEVAC, builds
-- 4 = DEBUG   - Everything: spawns, pickups, hover checks (debugging only)

-- =========================
-- Changing Log Level In-Game
-- =========================
-- Players can change logging via F10 menus:
-- F10 → CTLD → Admin/Help → Debug → [Select Level]
--
-- Options in-game:
-- - Enable Verbose (Level 4)
-- - Normal INFO (Level 2)
-- - Errors Only (Level 1)  
-- - Disable All (Level 0)

-- =========================
-- Troubleshooting
-- =========================
-- Problem: Too much spam in DCS.log
-- Solution: Set LogLevel = 1 or LogLevel = 2

-- Problem: Need to debug MEDEVAC issues
-- Solution: Temporarily set LogLevel = 4, reproduce issue, then set back to 2

-- Problem: Want zero logging overhead
-- Solution: Set LogLevel = 0

-- =========================
-- Migration from Old Debug Flag
-- =========================
-- OLD (deprecated):
-- Debug = true  -- logged everything
-- Debug = false -- logged some things

-- NEW (LogLevel):
-- LogLevel = 4  -- equivalent to Debug = true (everything)
-- LogLevel = 2  -- equivalent to Debug = false (important only)
-- LogLevel = 1  -- errors only
-- LogLevel = 0  -- nothing
