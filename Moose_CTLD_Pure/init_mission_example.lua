-- init_mission_example.lua
-- Use this with Mission Editor triggers as DO SCRIPT (no paths)
-- Load order (Mission Start):
--   Option A (catalog first):
--     1) DO SCRIPT FILE: Moose.lua
--     2) DO SCRIPT FILE: Moose_CTLD_Pure/catalogs/CrateCatalog_CTLD_Extract.lua  -- sets _CTLD_EXTRACTED_CATALOG
--     3) DO SCRIPT FILE: Moose_CTLD_Pure/Moose_CTLD.lua
--     4) DO SCRIPT FILE: Moose_CTLD_Pure/Moose_CTLD_FAC.lua   (optional)
--     5) DO SCRIPT: paste the block below
--   Option B (catalog after CTLD file):
--     1) DO SCRIPT FILE: Moose.lua
--     2) DO SCRIPT FILE: Moose_CTLD_Pure/Moose_CTLD.lua
--     3) DO SCRIPT FILE: Moose_CTLD_Pure/catalogs/CrateCatalog_CTLD_Extract.lua  -- still fine: load before ctld:New()
--     4) DO SCRIPT FILE: Moose_CTLD_Pure/Moose_CTLD_FAC.lua   (optional)
--     5) DO SCRIPT: paste the block below

-- create CTLD instance for BLUE
ctld = _MOOSE_CTLD:New({
  CoalitionSide = coalition.side.BLUE,
  UseCategorySubmenus = true,
  -- Set to false if you want ONLY the external catalog and no built-in examples
  -- UseBuiltinCatalog = false,
  RestrictFOBToZones = true,
  AutoBuildFOBInZones = true,
  Zones = {
    PickupZones = { { name = 'PICKUP_BLUE_MAIN' } },
    DropZones   = { { name = 'DROP_BLUE_1' } },
    FOBZones    = { { name = 'FOB_ALPHA' } },
  },
})

-- No manual merge needed: Moose_CTLD auto-detects and merges global catalogs
-- supported global names: _CTLD_EXTRACTED_CATALOG, CTLD_CATALOG, MOOSE_CTLD_CATALOG

-- set allowed transports (optional override)
-- ctld:SetAllowedAircraft({'UH-1H','Mi-8MTV2','Mi-24P'})

-- FAC/RECCE (optional)
if _MOOSE_CTLD_FAC then
  fac = _MOOSE_CTLD_FAC:New(ctld, {
    CoalitionSide = coalition.side.BLUE,
    Arty = { Enabled=true, Groups={'BLUE_ARTY_1'}, Rounds=2, Spread=80 },
  })
  fac:AddRecceZone({ name = 'RECCE_ZONE_1' })
  fac:Run()
end
