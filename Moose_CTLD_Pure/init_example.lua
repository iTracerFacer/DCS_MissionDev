-- init_example.lua (optional dev harness snippet)
-- Load Moose before this. Then do:
-- dofile(lfs.writedir()..[[Scripts\Moose_CTLD_Pure\init_example.lua]])

local CTLD = dofile(lfs.writedir()..[[Scripts\Moose_CTLD_Pure\Moose_CTLD.lua]])
local ctld = CTLD:New({
  CoalitionSide = coalition.side.BLUE,
  Zones = {
    PickupZones = { { name = 'PICKUP_BLUE_MAIN' } },
    DropZones = { { name = 'DROP_BLUE_1' } },
  },
})

-- Load the extracted CTLD-based crate catalog
local extracted = dofile(lfs.writedir()..[[Scripts\Moose_CTLD_Pure\catalogs\CrateCatalog_CTLD_Extract.lua]])
ctld:MergeCatalog(extracted)

-- Register a SAM site built from 4 crates
ctld:RegisterCrate('IR-SAM', {
  description = '4x crates -> IR SAM site',
  weight = 300,
  dcsCargoType = 'container_cargo',
  required = 4,
  side = coalition.side.BLUE,
  category = Group.Category.GROUND,
  build = function(point, headingDeg)
    local hdg = math.rad(headingDeg or 0)
    local function off(dx, dz) return { x=point.x+dx, z=point.z+dz } end
    local units = {
      { type='Strela-10M3', name='CTLD-SAM-1', x=point.x, y=point.z, heading=hdg },
      { type='Ural-375', name='CTLD-SAM-SUP', x=off(10,12).x, y=off(10,12).z, heading=hdg },
    }
    return { visible=false, lateActivation=false, units=units, name='CTLD_SAM_'..math.random(100000,999999) }
  end,
})

-- FAC/RECCE setup
local FAC = dofile(lfs.writedir()..[[Scripts\Moose_CTLD_Pure\Moose_CTLD_FAC.lua]])
local fac = FAC:New(ctld, {
  CoalitionSide = coalition.side.BLUE,
  Arty = { Enabled=true, Groups={'BLUE_ARTY_1'}, Rounds=2, Spread=80 },
})
fac:AddRecceZone({ name = 'RECCE_ZONE_1' })
fac:Run()
