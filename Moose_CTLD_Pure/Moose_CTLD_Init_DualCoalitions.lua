-- init_mission_dual_coalition.lua
-- Use in Mission Editor with DO SCRIPT FILE load order:
--  1) Moose.lua
--  2) Moose_CTLD_Pure/Moose_CTLD.lua
--  3) Moose_CTLD_Pure/catalogs/CrateCatalog_CTLD_Extract.lua  -- optional but recommended catalog with BLUE+RED items (_CTLD_EXTRACTED_CATALOG)
--  4) Moose_CTLD_Pure/Moose_CTLD_FAC.lua                      -- optional FAC/RECCE support
--  5) DO SCRIPT: dofile on this file OR paste the block below directly
--
-- Zones you should create in the Mission Editor (as trigger zones):
--   BLUE: PICKUP_BLUE_MAIN, DROP_BLUE_1, FOB_BLUE_A
--   RED : PICKUP_RED_MAIN,  DROP_RED_1,  FOB_RED_A
-- Adjust names below if you use different zone names.


-- Create CTLD instances only if Moose and CTLD are available
if _MOOSE_CTLD and _G.BASE then
ctldBlue = _MOOSE_CTLD:New({
    CoalitionSide = coalition.side.BLUE,
    RootMenuName = '1-CTLD',               -- Menu name with numeric prefix to control F10 ordering (1=first, 2=second, etc.)
    PickupZoneSmokeColor = trigger.smokeColor.Blue,
    AllowedAircraft = {                    -- transport-capable unit type names (case-sensitive as in DCS DB)
        'UH-1H','Mi-8MTV2','Mi-24P','SA342M','SA342L','SA342Minigun','UH-60L','CH-47Fbl1','CH-47F','Mi-17','GazelleAI'
    },
  -- Optional: drive zone activation from mission flags (preferred: set per-zone below via flag/activeWhen)
    
  Zones = {
    PickupZones = { { name = 'ALPHA', smoke = trigger.smokeColor.Blue, flag = 9001, activeWhen = 0 } },
    DropZones   = { { name = 'BRAVO', flag = 9002, activeWhen = 0 } },
    FOBZones    = { { name = 'CHARLIE',  flag = 9003, activeWhen = 0 } },
  },
    BuildRequiresGroundCrates = true,
})

ctldRed = _MOOSE_CTLD:New({
    CoalitionSide = coalition.side.RED,
    RootMenuName = '1-CTLD',               -- Menu name with numeric prefix to control F10 ordering (1=first, 2=second, etc.)
    PickupZoneSmokeColor = trigger.smokeColor.Red,
    AllowedAircraft = {                    -- transport-capable unit type names (case-sensitive as in DCS DB)
        'UH-1H','Mi-8MTV2','Mi-24P','SA342M','SA342L','SA342Minigun','UH-60L','CH-47Fbl1','CH-47F','Mi-17','GazelleAI'

    },
  -- Optional: drive zone activation for RED via per-zone flag/activeWhen

  Zones = {
    PickupZones = { { name = 'DELTA', smoke = trigger.smokeColor.Red, flag = 9101, activeWhen = 0 } },
    DropZones   = { { name = 'ECHO', flag = 9102, activeWhen = 0 } },
    FOBZones    = { { name = 'FOXTROT',  flag = 9103, activeWhen = 0 } },
  },
    BuildRequiresGroundCrates = true,
})
else
  env.info('[init_mission_dual_coalition] Moose or CTLD missing; skipping CTLD init')
end


-- Optional: FAC/RECCE for both sides (requires Moose_CTLD_FAC.lua)
if _MOOSE_CTLD_FAC and _G.BASE and ctldBlue and ctldRed then
  facBlue = _MOOSE_CTLD_FAC:New(ctldBlue, {
    CoalitionSide = coalition.side.BLUE,
    RootMenuName = '2-FAC/RECCE',        -- Menu name with numeric prefix to control F10 ordering (CTLD=1, FAC=2)
    Arty = { Enabled = false },
  })
  -- facBlue:AddRecceZone({ name = 'RECCE_BLUE_1' })
  facBlue:Run()

  facRed = _MOOSE_CTLD_FAC:New(ctldRed, {
    CoalitionSide = coalition.side.RED,
    RootMenuName = '2-FAC/RECCE',        -- Menu name with numeric prefix to control F10 ordering (CTLD=1, FAC=2)
    Arty = { Enabled = false },
  })
  -- facRed:AddRecceZone({ name = 'RECCE_RED_1' })
  facRed:Run()
else
  env.info('[init_mission_dual_coalition] FAC not initialized (missing Moose/CTLD/FAC or CTLD not created)')
end
