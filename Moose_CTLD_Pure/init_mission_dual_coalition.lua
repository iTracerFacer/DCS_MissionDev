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
    PickupZoneSmokeColor = trigger.smokeColor.Blue,
    AllowedAircraft = {                    -- transport-capable unit type names (case-sensitive as in DCS DB)
        'UH-1H','Mi-8MTV2','Mi-24P','SA342M','SA342L','SA342Minigun','UH-60L','CH-47Fbl1','CH-47F','Mi-17','GazelleAI'
    },
  -- Optional: drive zone activation from mission flags (preferred: set per-zone below via flag/activeWhen)
    
  Zones = {
    PickupZones = { { name = 'Blue_PickupZone_1', smoke = trigger.smokeColor.Blue, flag = 9001, activeWhen = 0 } },
    DropZones   = { { name = 'ALPHA-1', flag = 9002, activeWhen = 0 } },
    FOBZones    = { { name = 'FOB-1',  flag = 9003, activeWhen = 0 } },
  },
    BuildRequiresGroundCrates = true,
})

ctldRed = _MOOSE_CTLD:New({
    CoalitionSide = coalition.side.RED,
    PickupZoneSmokeColor = trigger.smokeColor.Red,
    AllowedAircraft = {                    -- transport-capable unit type names (case-sensitive as in DCS DB)
        'UH-1H','Mi-8MTV2','Mi-24P','SA342M','SA342L','SA342Minigun','UH-60L','CH-47Fbl1','CH-47F','Mi-17','GazelleAI'

    },
  -- Optional: drive zone activation for RED via per-zone flag/activeWhen

  Zones = {
    PickupZones = { { name = 'Red_PickupZone_1', smoke = trigger.smokeColor.Red, flag = 9101, activeWhen = 0 } },
    DropZones   = { { name = 'ALPHA-2', flag = 9102, activeWhen = 0 } },
    FOBZones    = { { name = 'FOB-2',  flag = 9103, activeWhen = 0 } },
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
    Arty = { Enabled = false },
  })
  -- facBlue:AddRecceZone({ name = 'RECCE_BLUE_1' })
  facBlue:Run()

  facRed = _MOOSE_CTLD_FAC:New(ctldRed, {
    CoalitionSide = coalition.side.RED,
    Arty = { Enabled = false },
  })
  -- facRed:AddRecceZone({ name = 'RECCE_RED_1' })
  facRed:Run()
else
  env.info('[init_mission_dual_coalition] FAC not initialized (missing Moose/CTLD/FAC or CTLD not created)')
end
