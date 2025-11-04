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

-- Create CTLD for BLUE
ctldBlue = _MOOSE_CTLD:New({
  CoalitionSide = coalition.side.BLUE,
  UseCategorySubmenus = true,
  UseBuiltinCatalog = false,         -- rely on external catalog (recommended)
  RestrictFOBToZones = true,
  AutoBuildFOBInZones = true,
  Zones = {
    PickupZones = { { name = 'PICKUP_BLUE_MAIN' } },
    DropZones   = { { name = 'DROP_BLUE_1' } },
    FOBZones    = { { name = 'FOB_BLUE_A' } },
  },
})

-- Create CTLD for RED
ctldRed = _MOOSE_CTLD:New({
  CoalitionSide = coalition.side.RED,
  UseCategorySubmenus = true,
  UseBuiltinCatalog = false,         -- rely on external catalog (recommended)
  RestrictFOBToZones = true,
  AutoBuildFOBInZones = true,
  Zones = {
    PickupZones = { { name = 'PICKUP_RED_MAIN' } },
    DropZones   = { { name = 'DROP_RED_1' } },
    FOBZones    = { { name = 'FOB_RED_A' } },
  },
})

-- If the external catalog was loaded (as _CTLD_EXTRACTED_CATALOG), both instances auto-merged it
-- thanks to Moose_CTLD.lua. If you want to load it manually or from a different path, you can do:
-- local extracted = dofile(lfs.writedir()..[[Scripts\Moose_CTLD_Pure\catalogs\CrateCatalog_CTLD_Extract.lua]])
-- ctldBlue:MergeCatalog(extracted)
-- ctldRed:MergeCatalog(extracted)

-- Optional: add a couple of small, side-specific examples if you don't use the big catalog
-- (Uncomment to add a simple MANPADS and AAA on each side)
-- ctldBlue:RegisterCrate('MANPADS', {
--   menuCategory='Infantry', description='2x crates -> MANPADS (Stinger)', dcsCargoType='uh1h_cargo', required=2,
--   side=coalition.side.BLUE, category=Group.Category.GROUND,
--   build=function(point, headingDeg)
--     local hdg = math.rad(headingDeg or 0)
--     return { visible=false, lateActivation=false, tasks={}, task='Ground Nothing', route={}, name='CTLD_BP_MANPADS_'..math.random(1,999999),
--       units={ { type='Soldier stinger', name='CTLD-Stinger-'..math.random(1,999999), x=point.x, y=point.z, heading=hdg } } }
--   end,
-- })
-- ctldBlue:RegisterCrate('AAA', {
--   menuCategory='AAA', description='3x crates -> ZU-23 site', dcsCargoType='container_cargo', required=3,
--   side=coalition.side.BLUE, category=Group.Category.GROUND,
--   build=function(point, headingDeg)
--     local hdg = math.rad(headingDeg or 0)
--     local function off(dx,dz) return { x=point.x+dx, z=point.z+dz } end
--     local units={
--       { type='ZU-23 Emplacement', name='CTLD-ZU23-'..math.random(1,999999), x=point.x, y=point.z, heading=hdg },
--       { type='Ural-375', name='CTLD-TRK-'..math.random(1,999999), x=off(15,12).x, y=off(15,12).z, heading=hdg },
--       { type='Infantry AK', name='CTLD-INF-'..math.random(1,999999), x=off(-12,-15).x, y=off(-12,-15).z, heading=hdg },
--     }
--     return { visible=false, lateActivation=false, tasks={}, task='Ground Nothing', units=units, route={}, name='CTLD_BP_AAA_'..math.random(1,999999) }
--   end,
-- })
-- ctldRed:RegisterCrate('MANPADS', {
--   menuCategory='Infantry', description='2x crates -> MANPADS (Igla)', dcsCargoType='uh1h_cargo', required=2,
--   side=coalition.side.RED, category=Group.Category.GROUND,
--   build=function(point, headingDeg)
--     local hdg = math.rad(headingDeg or 0)
--     -- Using generic infantry to avoid DCS type-name mismatches; replace with accurate manpad unit if desired
--     return { visible=false, lateActivation=false, tasks={}, task='Ground Nothing', route={}, name='CTLD_RP_MANPADS_'..math.random(1,999999),
--       units={ { type='Infantry AK', name='CTLD-Igla-'..math.random(1,999999), x=point.x, y=point.z, heading=hdg } } }
--   end,
-- })
-- ctldRed:RegisterCrate('AAA', {
--   menuCategory='AAA', description='3x crates -> ZU-23 site', dcsCargoType='container_cargo', required=3,
--   side=coalition.side.RED, category=Group.Category.GROUND,
--   build=function(point, headingDeg)
--     local hdg = math.rad(headingDeg or 0)
--     local function off(dx,dz) return { x=point.x+dx, z=point.z+dz } end
--     local units={
--       { type='ZU-23 Emplacement', name='CTLD-ZU23-'..math.random(1,999999), x=point.x, y=point.z, heading=hdg },
--       { type='Ural-375', name='CTLD-TRK-'..math.random(1,999999), x=off(15,12).x, y=off(15,12).z, heading=hdg },
--       { type='Infantry AK', name='CTLD-INF-'..math.random(1,999999), x=off(-12,-15).x, y=off(-12,-15).z, heading=hdg },
--     }
--     return { visible=false, lateActivation=false, tasks={}, task='Ground Nothing', units=units, route={}, name='CTLD_RP_AAA_'..math.random(1,999999) }
--   end,
-- })

-- Optional: FAC/RECCE for both sides (requires Moose_CTLD_FAC.lua)
if _MOOSE_CTLD_FAC then
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
end
