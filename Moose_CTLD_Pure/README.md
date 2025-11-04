# Moose_CTLD_Pure

Pure-MOOSE CTLD-style logistics and FAC/RECCE without MIST or mission editor templates. Drop-in, config-driven.

## What this is

- Logistics and troop transport similar to popular CTLD scripts, implemented directly on MOOSE.
- No MIST. No mission editor templates. Unit compositions are defined in config tables.
- Optional FAC/RECCE module that auto-marks targets in zones and can drive artillery marking and JTAC auto-lase.

## Quick start

1) Load `Moose.lua` first, then include these files (order matters). Easiest path: load the crate catalog first so CTLD auto-detects it.
  - `Moose_CTLD_Pure/catalogs/CrateCatalog_CTLD_Extract.lua` (sets `_CTLD_EXTRACTED_CATALOG`)
  - `Moose_CTLD_Pure/Moose_CTLD.lua`
  - `Moose_CTLD_Pure/Moose_CTLD_FAC.lua` (optional, for FAC/RECCE)

2) Initialize CTLD with minimal config:

```lua
local CTLD = dofile(lfs.writedir()..[[Scripts\Moose_CTLD_Pure\Moose_CTLD.lua]])
local ctld = CTLD:New({
  CoalitionSide = coalition.side.BLUE,
  -- If you want to rely ONLY on the external catalog, disable built-ins
  -- UseBuiltinCatalog = false,
  Zones = {
    PickupZones = { { name = 'PICKUP_BLUE_MAIN' } },
    DropZones   = { { name = 'DROP_BLUE_1' } },
  },
})

-- No manual merge needed if you loaded the catalog file before CTLD.lua.
-- Supported globals that auto-merge: _CTLD_EXTRACTED_CATALOG, CTLD_CATALOG, MOOSE_CTLD_CATALOG
```

- If you don't have ME trigger zones, define by coordinates:

```lua
Zones = {
  PickupZones = {
    { coord = { x=123456, y=0, z=654321 }, radius=150, name='ScriptPickup1' },
  }
}
```

3) (Optional) FAC/RECCE:

```lua
local FAC = dofile(lfs.writedir()..[[Scripts\Moose_CTLD_Pure\Moose_CTLD_FAC.lua]])
local fac = FAC:New(ctld, {
  CoalitionSide = coalition.side.BLUE,
  Arty = { Enabled = true, Groups = { 'BLUE_ARTY_1' }, Rounds = 3, Spread = 100 },
})
fac:AddRecceZone({ name = 'RECCE_ZONE_1' })
fac:Run()
```

4) In mission, pilots of allowed aircraft (configured in `AllowedAircraft`) will see F10 menus:
- CTLD > Request Crate > [Type]
- CTLD > Load Troops / Unload Troops
- CTLD > Build Here
- FAC/RECCE > List Recce Zones / Mark Contacts (all zones)

## Configuring crates and builds (no templates)

Edit `CrateCatalog` in `Moose_CTLD.lua`. Each entry defines:
- `required`: how many crates to assemble
- `weight`: informational
- `dcsCargoType`: DCS static cargo type string (e.g., `uh1h_cargo`, `container_cargo`); tweak per map/mods
- `build(point, headingDeg)`: function returning a DCS group table for `coalition.addGroup`

Example snippet:

```lua
CrateCatalog = {
  MANPADS = {
    description = '2x Crates -> MANPADS team',
    weight = 120,
    dcsCargoType = 'uh1h_cargo',
    required = 2,
    side = coalition.side.BLUE,
    category = Group.Category.GROUND,
    build = function(point, headingDeg)
      return { visible=false, lateActivation=false, units={
        { type='Soldier stinger', name='CTLD-MANPADS-1', x=point.x, y=point.z, heading=math.rad(headingDeg or 0) }
      } }
    end,
  },
}
```

## Notes and limitations

- This avoids sling-load event dependency by using a player command "Build Here" that consumes nearby crates within a radius. You can still sling crates physically.
- Cargo static types vary across DCS versions. If a spawned crate isn’t sling-loadable, change `dcsCargoType` strings in `CrateCatalog` (e.g., `uh1h_cargo`, `container_cargo`, `ammo_cargo`, `container_20ft` depending on map/version).
- Troops are virtually loaded and spawned on unload. Adjust capacity logic if you want type-based capacities.
- FAC/RECCE detection leverages Moose `DETECTION_AREAS`. Tweak `ScanInterval`, `DetectionRadius`, and `MinReportSeparation` to balance spam/performance.
- Artillery marking uses `Controller.setTask('FireAtPoint')` on configured groups. Ensure those groups exist and are artillery-capable.
- JTAC Auto-Lase helper provided: `fac:StartJTACOnGroup(groupName, laserCode, smokeColor)` uses `FAC_AUTO`.

### Catalog sources and precedence

- By default, CTLD includes a small built-in sample catalog so it works out-of-the-box.
- If you load a catalog file before calling `CTLD:New()`, CTLD auto-merges the global catalog (no extra code needed).
- To use only your external catalog and avoid sample entries, set `UseBuiltinCatalog = false` in the `CTLD:New({...})` config.

## Extending

- Add radio beacons, FOB build recipes, fuel/ammo crates, and CSAR hooks by registering more `CrateCatalog` entries and/or adding helper methods.
- To support per-airframe capacities and sling-only rules, extend `AllowedAircraft` and add a type->capacity map.

## Changelog

- 0.1.0-alpha: Initial release: CTLD crate/troops/build, FAC recce zones + arty mark + JTAC bootstrap.
