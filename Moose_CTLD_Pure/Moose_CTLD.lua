-- Pure-MOOSE, template-free CTLD-style logistics & troop transport
-- Drop-in script: no MIST, no mission editor templates required
-- Dependencies: Moose.lua must be loaded before this script
-- Author: Copilot (generated)

-- Contract
-- Inputs: Config table or defaults. No ME templates needed. Zones may be named ME trigger zones or provided via coordinates in config.
-- Outputs: F10 menus for helo/transport groups; crate spawning/building; troop load/unload; optional JTAC hookup (via FAC module);
-- Error modes: missing Moose -> abort; unknown crate key -> message; spawn blocked in enemy airbase; zone missing -> message.

if not _G.BASE then
  env.info('[Moose_CTLD] Moose (BASE) not detected. Ensure Moose.lua is loaded before Moose_CTLD.lua')
end

local CTLD = {}
CTLD.__index = CTLD

-- Safe deep copy: prefer MOOSE UTILS.DeepCopy when available; fallback to Lua implementation
local function _deepcopy_fallback(obj, seen)
  if type(obj) ~= 'table' then return obj end
  seen = seen or {}
  if seen[obj] then return seen[obj] end
  local res = {}
  seen[obj] = res
  for k, v in pairs(obj) do
    res[_deepcopy_fallback(k, seen)] = _deepcopy_fallback(v, seen)
  end
  local mt = getmetatable(obj)
  if mt then setmetatable(res, mt) end
  return res
end

local function DeepCopy(obj)
  if _G.UTILS and type(UTILS.DeepCopy) == 'function' then
    return UTILS.DeepCopy(obj)
  end
  return _deepcopy_fallback(obj)
end

-- Deep-merge src into dst (recursively). Arrays/lists in src replace dst.
local function DeepMerge(dst, src)
  if type(dst) ~= 'table' or type(src) ~= 'table' then return src end
  for k, v in pairs(src) do
    if type(v) == 'table' then
      local isArray = (rawget(v, 1) ~= nil) -- simple heuristic
      if isArray then
        dst[k] = DeepCopy(v)
      else
        dst[k] = DeepMerge(dst[k] or {}, v)
      end
    else
      dst[k] = v
    end
  end
  return dst
end

-- =========================
-- Defaults and State
-- =========================
-- #region Config
CTLD.Version = '0.1.0-alpha'

-- Immersive Hover Coach configuration (messages, thresholds, throttling)
-- All user-facing text lives here; logic only fills placeholders.
CTLD.HoverCoachConfig = {
  enabled = true,             -- master switch for hover coaching messages
  coachOnByDefault = true,    -- future per-player toggle; currently always on when enabled

  thresholds = {
    arrivalDist = 1000,       -- m: start guidance “You’re close…”
    closeDist = 100,          -- m: reduce speed / set AGL guidance
    precisionDist = 30,       -- m: start precision hints
    captureHoriz = 2,         -- m: horizontal sweet spot radius
    captureVert = 2,          -- m: vertical sweet spot tolerance around AGL window
    aglMin = 5,               -- m: hover window min AGL
    aglMax = 20,              -- m: hover window max AGL
    maxGS = 8/3.6,            -- m/s: 8 km/h for precision, used for errors
    captureGS = 4/3.6,        -- m/s: 4 km/h capture requirement
    maxVS = 1.5,              -- m/s: absolute vertical speed during capture
    driftResetDist = 35,      -- m: if beyond, reset precision phase
    stabilityHold = 1.8       -- s: hold steady before loading
  },

  throttle = {
    coachUpdate = 1.5,        -- s between hint updates in precision
    generic = 3.0,            -- s between non-coach messages
    repeatSame = 6.0          -- s before repeating same message key
  },
}

-- General CTLD event messages (non-hover). Tweak freely.
CTLD.Messages = {
  -- Crates
  crate_spawn_requested = "Request received—spawning {type} crate at {zone}.",
  pickup_zone_required = "Move within {zone_dist} {zone_dist_u} of a Supply Zone to request crates. Bearing {zone_brg}° to nearest zone.",
  no_pickup_zones = "No Pickup Zones are configured for this coalition. Ask the mission maker to add supply zones or disable the pickup zone requirement.",
  crate_re_marked = "Re-marking crate {id} with {mark}.",
  crate_expired = "Crate {id} expired and was removed.",
  crate_max_capacity = "Max load reached ({total}). Drop or build before picking up more.",
  crate_spawned = "Crate’s live! {type} [{id}]. Bearing {brg}° range {rng} {rng_u}. Call for vectors if you need a hand.",

  -- Drops
  drop_initiated = "Dropping {count} crate(s) here…",
  dropped_crates = "Dropped {count} crate(s) at your location.",
  no_loaded_crates = "No loaded crates to drop.",

  -- Build
  build_insufficient_crates = "Insufficient crates to build {build}.",
  build_requires_ground = "You have {total} crate(s) onboard—drop them first to build here.",
  build_started = "Building {build} at your position…",
  build_success = "{build} deployed to the field!",
  build_success_coalition = "{player} deployed {build} to the field!",
  build_failed = "Build failed: {reason}.",
  fob_restricted = "FOB building is restricted to designated FOB zones.",
  auto_fob_built = "FOB auto-built at {zone}.",

  -- Troops
  troops_loaded = "Loaded {count} troops—ready to deploy.",
  troops_unloaded = "Deployed {count} troops.",
  troops_unloaded_coalition = "{player} deployed {count} troops.",
  no_troops = "No troops onboard.",
  troops_deploy_failed = "Deploy failed: {reason}.",
  troop_pickup_zone_required = "Move inside a Supply Zone to load troops. Nearest zone is {zone_dist}, {zone_dist_u} away bearing {zone_brg}°.",

  -- Coach & nav
  vectors_to_crate = "Nearest crate {id}: bearing {brg}°, range {rng} {rng_u}.",
  vectors_to_pickup_zone = "Nearest supply zone {zone}: bearing {brg}°, range {rng} {rng_u}.",
  coach_enabled = "Hover Coach enabled.",
  coach_disabled = "Hover Coach disabled.",

  -- Hover Coach guidance
  coach_arrival = "You’re close—nice and easy. Hover at 5–20 meters.",
  coach_close = "Reduce speed below 15 km/h and set 5–20 m AGL.",
  coach_hint = "{hints} GS {gs} {gs_u}.",
  coach_too_fast = "Too fast for pickup: GS {gs} {gs_u}. Reduce below 8 km/h.",
  coach_too_high = "Too high: AGL {agl} {agl_u}. Target 5–20 m.",
  coach_too_low = "Too low: AGL {agl} {agl_u}. Maintain at least 5 m.",
  coach_drift = "Outside pickup window. Re-center within 25 m.",
  coach_hold = "Oooh, right there! HOLD POSITION…",
  coach_loaded = "Crate is hooked! Nice flying!",
  coach_hover_lost = "Movement detected—recover hover to load.",
  coach_abort = "Hover lost. Reacquire within 25 m, GS < 8 km/h, AGL 5–20 m.",

  -- Zone state changes
  zone_activated = "{kind} Zone {zone} is now ACTIVE.",
  zone_deactivated = "{kind} Zone {zone} is now INACTIVE.",
  
  -- Attack/Defend announcements
  attack_enemy_announce = "{unit_name} deployed by {player} has spotted an enemy {enemy_type} at {brg}°, {rng} {rng_u}. Moving to engage!",
  attack_base_announce = "{unit_name} deployed by {player} is moving to capture {base_name} at {brg}°, {rng} {rng_u}.",
  attack_no_targets = "{unit_name} deployed by {player} found no targets within {rng} {rng_u}. Holding position.",
}

CTLD.Config = {
  CoalitionSide = coalition.side.BLUE,   -- default coalition this instance serves (menus created for this side)
  AllowedAircraft = {                    -- transport-capable unit type names (case-sensitive as in DCS DB)
    'UH-1H','Mi-8MTV2','Mi-24P','SA342M','SA342L','SA342Minigun','Ka-50','Ka-50_3','AH-64D_BLK_II','UH-60L','CH-47Fbl1','CH-47F','Mi-17','GazelleAI'
  },
  UseGroupMenus = true,                  -- if true, F10 menus per player group; otherwise coalition-wide
  UseCategorySubmenus = true,            -- if true, organize crate requests by category submenu (menuCategory)
  UseBuiltinCatalog = false,             -- if false, starts with an empty catalog; intended when you preload a global catalog and want only that
  -- Safety offsets to avoid spawning units too close to player aircraft
  BuildSpawnOffset = 25,                 -- meters: shift build point forward from the aircraft to avoid rotor/ground collisions (0 = spawn centered on aircraft)
  TroopSpawnOffset = 25,                 -- meters: shift troop unload point forward from the aircraft
  RestrictFOBToZones = false,            -- if true, recipes marked isFOB only build inside configured FOBZones
  AutoBuildFOBInZones = false,           -- if true, CTLD auto-builds FOB recipes when required crates are inside a FOB zone
  BuildRadius = 60,                      -- meters around build point to collect crates
  CrateLifetime = 3600,                  -- seconds before crates auto-clean up; 0 = disable
  MessageDuration = 15,                  -- seconds for on-screen messages
  Debug = false,
  -- Build safety
  BuildConfirmEnabled = true,            -- require a second confirmation within a short window before building
  BuildConfirmWindowSeconds = 10,        -- seconds allowed between first and second "Build Here" press
  BuildCooldownEnabled = true,           -- after a successful build, impose a cooldown before allowing another build by the same group
  BuildCooldownSeconds = 60,             -- seconds of cooldown after a successful build per group
  PickupZoneSmokeColor = trigger.smokeColor.Green, -- default smoke color when spawning crates at pickup zones
  RequirePickupZoneForCrateRequest = true, -- enforce that crate requests must be near a Supply (Pickup) Zone
  RequirePickupZoneForTroopLoad = true,   -- if true, troops can only be loaded while inside a Supply (Pickup) Zone
  PickupZoneMaxDistance = 10000,        -- meters; nearest pickup zone must be within this distance to allow a request
  
  -- Attack/Defend AI behavior for deployed troops and built vehicles
  AttackAI = {
    Enabled = true,                 -- master switch for attack behavior
    TroopSearchRadius = 3000,       -- meters: when deploying troops with Attack, search radius for targets/bases
    VehicleSearchRadius = 6000,     -- meters: when building vehicles with Attack, search radius
    PrioritizeEnemyBases = true,    -- if true, prefer enemy-held bases over ground units when both are in range
    TroopAdvanceSpeedKmh = 20,      -- movement speed for troops when ordered to attack
    VehicleAdvanceSpeedKmh = 35,    -- movement speed for vehicles when ordered to attack
  },
  
  -- Optional: draw zones on the F10 map using trigger.action.* markup (ME Draw-like)
  MapDraw = {
    Enabled = true,              -- master switch for any map drawings created by this script
    DrawPickupZones = true,      -- draw Pickup/Supply zones as shaded circles with labels
    DrawDropZones = true,       -- optionally draw Drop zones
    DrawFOBZones = true,        -- optionally draw FOB zones
    FontSize = 18,               -- label text size
    ReadOnly = true,             -- prevent clients from removing the shapes
    ForAll = false,              -- if true, draw shapes to all (-1) instead of coalition only (useful for testing/briefing)
  OutlineColor = {1, 1, 0, 0.85},  -- RGBA 0..1 for outlines (bright yellow)
    -- Optional per-kind fill overrides
    FillColors = {
      Pickup = {0, 1, 0, 0.15},   -- light green fill for Pickup zones
      Drop   = {0, 0, 0, 0.25},   -- black fill for Drop zones
      FOB    = {1, 1, 0, 0.15},   -- yellow fill for FOB zones
    },
    LineType = 1,                -- default line type if per-kind is not set (0 None, 1 Solid, 2 Dashed, 3 Dotted, 4 DotDash, 5 LongDash, 6 TwoDash)
    LineTypes = {                -- override border style per zone kind
      Pickup = 3,                -- dotted
      Drop   = 2,                -- dashed
      FOB    = 4,                -- dot-dash
    },
  -- Label placement tuning (simple):
  -- Effective extra offset from the circle edge = r * LabelOffsetRatio + LabelOffsetFromEdge
  LabelOffsetFromEdge = -50,    -- meters beyond the zone radius to place the label (12 o'clock)
  LabelOffsetRatio = 0.5,     -- fraction of the radius to add to the offset (e.g., 0.1 => +10% of r)
  LabelOffsetX = 200,         -- meters: horizontal nudge; adjust if text appears left-anchored in your DCS build
    -- Per-kind label prefixes
    LabelPrefixes = {
      Pickup = 'Supply Zone',
      Drop   = 'Drop Zone',
      FOB    = 'FOB Zone',
    }
  },

  -- Crate spawn placement within pickup zones
  PickupZoneSpawnRandomize = true,      -- if true, spawn crates at a random point within the pickup zone (avoids stacking)
  PickupZoneSpawnEdgeBuffer = 10,       -- meters: keep spawns at least this far inside the zone edge
  PickupZoneSpawnMinOffset = 100,         -- meters: keep spawns at least this far from the exact center
  CrateSpawnMinSeparation = 7,          -- meters: try not to place a new crate closer than this to an existing one
  CrateSpawnSeparationTries = 6,        -- attempts to find a non-overlapping position before accepting best effort
  BuildRequiresGroundCrates = true,      -- if true, all required crates must be on the ground (won't count/consume carried crates)

  -- Inventory system (per pickup zone and FOBs)
  Inventory = {
    Enabled = true,              -- master switch for per-location stock control
    FOBStockFactor = 0.25,       -- starting stock at newly built FOBs relative to pickup-zone initialStock
    ShowStockInMenu = true,      -- if true, append simple stock hints to menu labels (per current nearest zone)
    HideZeroStockMenu = false,   -- removed: previously created an "In Stock Here" submenu; now disabled by default
  },

  -- Hover pickup configuration (Ciribob-style inspired)
  HoverPickup = {
    Enabled = true,             -- if true, auto-load the nearest crate when hovering close enough for a duration
    Height = 3,                  -- legacy: meters AGL threshold for hover pickup (superseded by HoverCoach thresholds when coach enabled)
    Radius = 15,                 -- meters horizontal distance to crate to consider for pickup (used if precision thresholds not applicable)
    AutoPickupDistance = 25,     -- meters max search distance for candidate crates
    Duration = 3,                -- seconds of continuous hover before loading occurs (steady time)
    MaxCratesPerLoad = 6,        -- maximum crates the aircraft can carry simultaneously
    RequireLowSpeed = true,      -- require near-stationary hover
    MaxSpeedMPS = 5              -- max allowed speed in m/s for hover pickup
  },

  -- Crate catalog: key -> crate properties and build recipe
  -- No ME templates; unit compositions are defined directly here.
  CrateCatalog = {
    -- Example: MANPADS team requiring 2 crates
    MANPADS = {
      description = '2x Crates -> MANPADS team',
      weight = 120,              -- affects sling/limits only informationally (no physics in script)
      dcsCargoType = 'uh1h_cargo', -- static cargo type (can adjust per DCS version); user-tunable
      required = 2,              -- number of crates to assemble
      canAttackMove = true,      -- infantry can move to engage
      side = coalition.side.BLUE,
      category = Group.Category.GROUND,
      build = function(point, headingDeg)
        local u1 = { type = 'Soldier stinger', name = string.format('CTLD-MANPADS-%d', math.random(100000,999999)),
          x = point.x, y = point.z, heading = math.rad(headingDeg or 0) }
        local group = {
          visible = false, lateActivation = false, tasks = {}, task = 'Ground Nothing',
          units = { u1 }, route = { }, name = string.format('CTLD_MANPADS_%d', math.random(100000,999999))
        }
        return group
      end,
    },
    -- Example: AAA site needing 3 crates
    AAA = {
      description = '3x Crates -> ZU-23 site',
      weight = 400,
      dcsCargoType = 'container_cargo',
      required = 3,
      canAttackMove = false,     -- static emplacement; do not attempt attack-move
      side = coalition.side.BLUE,
      category = Group.Category.GROUND,
      build = function(point, headingDeg)
        local hdg = math.rad(headingDeg or 0)
        local function offset(dx, dz) return { x = point.x + dx, z = point.z + dz } end
        local units = {
          { type='ZU-23 Emplacement', name=string.format('CTLD-ZU23-%d', math.random(100000,999999)), x=point.x, y=point.z, heading=hdg },
          { type='Ural-375', name=string.format('CTLD-TRK-%d', math.random(100000,999999)), x=offset(15, 12).x, y=offset(15, 12).z, heading=hdg },
          { type='Infantry AK', name=string.format('CTLD-INF-%d', math.random(100000,999999)), x=offset(-12,-15).x, y=offset(-12,-15).z, heading=hdg },
        }
        return { visible=false, lateActivation=false, tasks={}, task='Ground Nothing', units=units, route={}, name=string.format('CTLD_AAA_%d', math.random(100000,999999)) }
      end,
    },
    -- Example: FARP/FOB build from 4 crates (spawns helipads + support statics/vehicles)
  FOB = {
      description = '4x Crates -> FARP/FOB',
      weight = 500,
      dcsCargoType = 'container_cargo',
      required = 4,
      isFOB = true, -- mark as FOB recipe for zone restrictions/auto-build
    canAttackMove = false,     -- logistics site; never attack-move
      side = coalition.side.BLUE,
      category = Group.Category.GROUND,
      build = function(point, headingDeg, spawnSide)
        local heading = math.rad(headingDeg or 0)
        -- Spawn statics that provide FARP services
        local function addStatic(typeName, dx, dz, nameSuffix)
          local p = { x = point.x + dx, z = point.z + dz }
          local st = {
            name = string.format('CTLD-FOB-%s-%d', nameSuffix, math.random(100000,999999)),
            type = typeName,
            x = p.x, y = p.z,
            heading = heading,
          }
          coalition.addStaticObject(spawnSide or coalition.side.BLUE, st)
        end
        -- Common FARP layout
        addStatic('FARP', 0, 0, 'PAD')
        addStatic('FARP Ammo Dump Coating', 15, 10, 'AMMO')
        addStatic('FARP Fuel Depot', -15, 10, 'FUEL')
        addStatic('FARP Tent', 10, -12, 'TENT1')
        addStatic('FARP Tent', -10, -12, 'TENT2')
        -- Ground support vehicles to enable rearm/refuel/repair
        local units = {
          { type='HEMTT TFFT', name=string.format('CTLD-FOB-FUEL-%d', math.random(100000,999999)), x=point.x + 20, y=point.z + 15, heading=heading },
          { type='Ural-375 PBU', name=string.format('CTLD-FOB-REPAIR-%d', math.random(100000,999999)), x=point.x - 20, y=point.z + 15, heading=heading },
          { type='Ural-375', name=string.format('CTLD-FOB-AMMO-%d', math.random(100000,999999)), x=point.x, y=point.z - 18, heading=heading },
        }
        return { visible=false, lateActivation=false, tasks={}, task='Ground Nothing', units=units, route={}, name=string.format('CTLD_FOB_%d', math.random(100000,999999)) }
      end,
    },
  },
}

  -- #endregion Config

  -- #region State
  -- Internal state tables
CTLD._instances = CTLD._instances or {}
CTLD._crates = {}          -- [crateName] = { key, zone, side, spawnTime, point }
CTLD._troopsLoaded = {}    -- [groupName] = { count, typeKey }
CTLD._loadedCrates = {}    -- [groupName] = { total=n, byKey = { key -> count } }
CTLD._hoverState = {}       -- [unitName] = { targetCrate=name, startTime=t }
CTLD._unitLast = {}         -- [unitName] = { x, z, t }
CTLD._coachState = {}       -- [unitName] = { lastKeyTimes = {key->time}, lastHint = "", phase = "", lastPhaseMsg = 0, target = crateName, holdStart = nil }
CTLD._msgState = { }        -- messaging throttle state: [scopeKey] = { lastKeyTimes = { key -> time } }
CTLD._buildConfirm = {}     -- [groupName] = time of first build request (awaiting confirmation)
CTLD._buildCooldown = {}    -- [groupName] = time of last successful build
CTLD._NextMarkupId = 10000  -- global-ish id generator shared by instances for map drawings
-- Inventory state
CTLD._stockByZone = CTLD._stockByZone or {}   -- [zoneName] = { [crateKey] = count }
CTLD._inStockMenus = CTLD._inStockMenus or {} -- per-group filtered menu handles

  -- #endregion State

-- =========================
-- Utilities
-- =========================
  -- #region Utilities
local function _isIn(list, value)
  for _,v in ipairs(list or {}) do if v == value then return true end end
  return false
end

local function _msgGroup(group, text, t)
  if not group then return end
  MESSAGE:New(text, t or CTLD.Config.MessageDuration):ToGroup(group)
end

local function _msgCoalition(side, text, t)
  MESSAGE:New(text, t or CTLD.Config.MessageDuration):ToCoalition(side)
end

local function _findZone(z)
  if z.name then
    local mz = ZONE:FindByName(z.name)
    if mz then return mz end
  end
  if z.coord then
    local r = z.radius or 150
    local v = VECTOR2:New(z.coord.x, z.coord.z)
    return ZONE_RADIUS:New(z.name or ('CTLD_ZONE_'..math.random(10000,99999)), v, r)
  end
  return nil
end

local function _getUnitType(unit)
  local ud = unit and unit:GetDesc() or nil
  return ud and ud.typeName or unit and unit:GetTypeName()
end

local function _nearestZonePoint(unit, list)
  if not unit or not unit:IsAlive() then return nil end
  -- Get unit position using DCS API to avoid dependency on MOOSE point methods
  local uname = unit:GetName()
  local du = Unit.getByName and Unit.getByName(uname) or nil
  if not du or not du:getPoint() then return nil end
  local up = du:getPoint()
  local ux, uz = up.x, up.z

  local best, bestd = nil, 1e12
  for _, z in ipairs(list or {}) do
    local mz = _findZone(z)
    local zx, zz
    if z and z.name and trigger and trigger.misc and trigger.misc.getZone then
      local tz = trigger.misc.getZone(z.name)
      if tz and tz.point then zx, zz = tz.point.x, tz.point.z end
    end
    if (not zx) and mz and mz.GetPointVec3 then
      local zp = mz:GetPointVec3()
      -- Try to read numeric fields directly to avoid method calls
      if zp and type(zp) == 'table' and zp.x and zp.z then zx, zz = zp.x, zp.z end
    end
    if (not zx) and z and z.coord then
      zx, zz = z.coord.x, z.coord.z
    end

    if zx and zz then
      local dx = (zx - ux)
      local dz = (zz - uz)
      local d = math.sqrt(dx*dx + dz*dz)
      if d < bestd then best, bestd = mz, d end
    end
  end
  return best, bestd
end

-- Helper: get nearest ACTIVE pickup zone (by configured list), respecting CTLD's active flags
function CTLD:_nearestActivePickupZone(unit)
  local function _activePickupDefs()
    local defs, out = self.Config.Zones.PickupZones or {}, {}
    for _,z in ipairs(defs) do
      local n = z.name
      if (not n) or self._ZoneActive.Pickup[n] ~= false then table.insert(out, z) end
    end
    return out
  end
  return _nearestZonePoint(unit, _activePickupDefs())
end

local function _coalitionAddGroup(side, category, groupData)
  -- Enforce side/category in groupData just to be safe
  groupData.category = category
  return coalition.addGroup(side, category, groupData)
end

local function _spawnStaticCargo(side, point, cargoType, name)
  local static = {
    name = name,
    type = cargoType,
    x = point.x,
    y = point.z,
    heading = 0,
    canCargo = true,
  }
  return coalition.addStaticObject(side, static)
end

local function _vec3FromUnit(unit)
  local p = unit:GetPointVec3()
  return { x = p.x, y = p.y, z = p.z }
end

-- Unique id generator for map markups (lines/circles/text)
local function _nextMarkupId()
  CTLD._NextMarkupId = (CTLD._NextMarkupId or 10000) + 1
  return CTLD._NextMarkupId
end

-- Resolve a zone's center (vec3) and radius (meters).
-- Accepts a MOOSE ZONE object returned by _findZone/ZONE:FindByName/ZONE_RADIUS:New
function CTLD:_getZoneCenterAndRadius(mz)
  if not mz then return nil, nil end
  local name = mz.GetName and mz:GetName() or nil
  -- Prefer Mission Editor zone data if available
  if name and trigger and trigger.misc and trigger.misc.getZone then
    local z = trigger.misc.getZone(name)
    if z and z.point and z.radius then
      local p = { x = z.point.x, y = z.point.y or 0, z = z.point.z }
      return p, z.radius
    end
  end
  -- Fall back to MOOSE zone center
  local pv = mz.GetPointVec3 and mz:GetPointVec3(mz) or nil
  local p = pv and { x = pv.x, y = pv.y or 0, z = pv.z } or nil
  -- Try to fetch a configured radius from our zone defs
  local r
  if name and self._ZoneDefs then
    local d = self._ZoneDefs.PickupZones and self._ZoneDefs.PickupZones[name]
            or self._ZoneDefs.DropZones and self._ZoneDefs.DropZones[name]
            or self._ZoneDefs.FOBZones and self._ZoneDefs.FOBZones[name]
    if d and d.radius then r = d.radius end
  end
  r = r or (mz.GetRadius and mz:GetRadius()) or 150
  return p, r
end

-- Draw a circle and label for a zone on the F10 map for this coalition.
-- kind: 'Pickup' | 'Drop' | 'FOB'
function CTLD:_drawZoneCircleAndLabel(kind, mz, opts)
  if not (trigger and trigger.action and trigger.action.circleToAll and trigger.action.textToAll) then return end
  opts = opts or {}
  local p, r = self:_getZoneCenterAndRadius(mz)
  if not p or not r then return end
  local side = (opts.ForAll and -1) or self.Side
  local outline = opts.OutlineColor or {0,1,0,0.85}
  local fill = opts.FillColor or {0,1,0,0.15}
  local lineType = opts.LineType or 1
  local readOnly = (opts.ReadOnly ~= false)
  local fontSize = opts.FontSize or 18
  local labelPrefix = opts.LabelPrefix or 'Zone'
  local zname = (mz.GetName and mz:GetName()) or '(zone)'
  local circleId = _nextMarkupId()
  local textId = _nextMarkupId()
  trigger.action.circleToAll(side, circleId, p, r, outline, fill, lineType, readOnly, "")
  local label = string.format('%s: %s', labelPrefix, zname)
  -- Place label centered above the circle (12 o'clock). Horizontal nudge via LabelOffsetX.
  -- Simple formula: extra offset from edge = r * ratio + fromEdge
  local extra = (r * (opts.LabelOffsetRatio or 0.0)) + (opts.LabelOffsetFromEdge or 30)
  local nx = p.x + (opts.LabelOffsetX or 0)
  local nz = p.z - (r + (extra or 0))
  local textPos = { x = nx, y = 0, z = nz }
  trigger.action.textToAll(side, textId, textPos, {1,1,1,0.9}, {0,0,0,0}, fontSize, readOnly, label)
  -- Track ids so they can be cleared later
  self._MapMarkup = self._MapMarkup or { Pickup = {}, Drop = {}, FOB = {} }
  self._MapMarkup[kind] = self._MapMarkup[kind] or {}
  self._MapMarkup[kind][zname] = { circle = circleId, text = textId }
end

function CTLD:ClearMapDrawings()
  if not (self._MapMarkup and trigger and trigger.action and trigger.action.removeMark) then return end
  for _, byName in pairs(self._MapMarkup) do
    for _, ids in pairs(byName) do
      if ids.circle then pcall(trigger.action.removeMark, ids.circle) end
      if ids.text then pcall(trigger.action.removeMark, ids.text) end
    end
  end
  self._MapMarkup = { Pickup = {}, Drop = {}, FOB = {} }
end

function CTLD:_removeZoneDrawing(kind, zname)
  if not (self._MapMarkup and self._MapMarkup[kind] and self._MapMarkup[kind][zname]) then return end
  local ids = self._MapMarkup[kind][zname]
  if ids.circle then pcall(trigger.action.removeMark, ids.circle) end
  if ids.text then pcall(trigger.action.removeMark, ids.text) end
  self._MapMarkup[kind][zname] = nil
end

-- Public: set a specific zone active/inactive by kind and name
function CTLD:SetZoneActive(kind, name, active, silent)
  if not (kind and name) then return end
  local k = (kind == 'Pickup' or kind == 'Drop' or kind == 'FOB') and kind or nil
  if not k then return end
  self._ZoneActive = self._ZoneActive or { Pickup = {}, Drop = {}, FOB = {} }
  self._ZoneActive[k][name] = (active ~= false)
  -- Update drawings for this one zone only
  if self.Config.MapDraw and self.Config.MapDraw.Enabled then
    -- Find the MOOSE zone object by name
    local list = (k=='Pickup' and self.PickupZones) or (k=='Drop' and self.DropZones) or (k=='FOB' and self.FOBZones) or {}
    local mz
    for _,z in ipairs(list or {}) do if z and z.GetName and z:GetName() == name then mz = z break end end
    if self._ZoneActive[k][name] then
      if mz then
        local md = self.Config.MapDraw
        local opts = {
          OutlineColor = md.OutlineColor,
          FillColor = (md.FillColors and md.FillColors[k]) or nil,
          LineType = (md.LineTypes and md.LineTypes[k]) or md.LineType or 1,
          FontSize = md.FontSize,
          ReadOnly = (md.ReadOnly ~= false),
          LabelOffsetX = md.LabelOffsetX,
          LabelOffsetFromEdge = md.LabelOffsetFromEdge,
          LabelOffsetRatio = md.LabelOffsetRatio,
          LabelPrefix = ((md.LabelPrefixes and md.LabelPrefixes[k])
                        or (k=='Pickup' and md.LabelPrefix)
                        or (k..' Zone'))
        }
        self:_drawZoneCircleAndLabel(k, mz, opts)
      end
    else
      self:_removeZoneDrawing(k, name)
    end
  end
  -- Optional messaging
  local stateStr = self._ZoneActive[k][name] and 'ACTIVATED' or 'DEACTIVATED'
  env.info(string.format('[Moose_CTLD] Zone %s %s (%s)', tostring(name), stateStr, k))
  if not silent then
    local msgKey = self._ZoneActive[k][name] and 'zone_activated' or 'zone_deactivated'
    _eventSend(self, nil, self.Side, msgKey, { kind = k, zone = name })
  end
end

function CTLD:DrawZonesOnMap()
  local md = self.Config and self.Config.MapDraw or {}
  if not md.Enabled then return end
  -- Clear previous drawings before re-drawing
  self:ClearMapDrawings()
  local opts = {
    OutlineColor = md.OutlineColor,
    LineType = md.LineType,
    FontSize = md.FontSize,
    ReadOnly = (md.ReadOnly ~= false),
    LabelPrefix = md.LabelPrefix or 'Zone',
    LabelOffsetX = md.LabelOffsetX,
    LabelOffsetFromEdge = md.LabelOffsetFromEdge,
    LabelOffsetRatio = md.LabelOffsetRatio,
    ForAll = (md.ForAll == true),
  }
  if md.DrawPickupZones then
    for _,mz in ipairs(self.PickupZones or {}) do
      local name = mz:GetName()
      if self._ZoneActive.Pickup[name] ~= false then
      opts.LabelPrefix = (md.LabelPrefixes and md.LabelPrefixes.Pickup) or md.LabelPrefix or 'Pickup Zone'
      opts.LineType = (md.LineTypes and md.LineTypes.Pickup) or md.LineType or 1
  opts.FillColor = (md.FillColors and md.FillColors.Pickup) or nil
      self:_drawZoneCircleAndLabel('Pickup', mz, opts)
      end
    end
  end
  if md.DrawDropZones then
    for _,mz in ipairs(self.DropZones or {}) do
      local name = mz:GetName()
      if self._ZoneActive.Drop[name] ~= false then
      opts.LabelPrefix = (md.LabelPrefixes and md.LabelPrefixes.Drop) or 'Drop Zone'
      opts.LineType = (md.LineTypes and md.LineTypes.Drop) or md.LineType or 1
  opts.FillColor = (md.FillColors and md.FillColors.Drop) or nil
      self:_drawZoneCircleAndLabel('Drop', mz, opts)
      end
    end
  end
  if md.DrawFOBZones then
    for _,mz in ipairs(self.FOBZones or {}) do
      local name = mz:GetName()
      if self._ZoneActive.FOB[name] ~= false then
      opts.LabelPrefix = (md.LabelPrefixes and md.LabelPrefixes.FOB) or 'FOB Zone'
      opts.LineType = (md.LineTypes and md.LineTypes.FOB) or md.LineType or 1
  opts.FillColor = (md.FillColors and md.FillColors.FOB) or nil
      self:_drawZoneCircleAndLabel('FOB', mz, opts)
      end
    end
  end
end

-- Unit preference detection and unit-aware formatting
local function _getPlayerIsMetric(unit)
  local ok, isMetric = pcall(function()
    local pname = unit and unit.GetPlayerName and unit:GetPlayerName() or nil
    if pname and type(SETTINGS) == 'table' and SETTINGS.Set then
      local ps = SETTINGS:Set(pname)
      if ps and ps.IsMetric then return ps:IsMetric() end
    end
    if _SETTINGS and _SETTINGS.IsMetric then return _SETTINGS:IsMetric() end
    return true
  end)
  return (ok and isMetric) and true or false
end

local function _round(n, prec)
  local m = 10^(prec or 0)
  return math.floor(n * m + 0.5) / m
end

local function _fmtDistance(meters, isMetric)
  if isMetric then
    local v = math.max(0, _round(meters, 0))
    return v, 'm'
  else
    local ft = meters * 3.28084
    -- snap to 5 ft increments for readability
    ft = math.max(0, math.floor((ft + 2.5) / 5) * 5)
    return ft, 'ft'
  end
end

local function _fmtRange(meters, isMetric)
  if isMetric then
    local v = math.max(0, _round(meters, 0))
    return v, 'm'
  else
    local nm = meters / 1852
    return _round(nm, 1), 'NM'
  end
end

local function _fmtSpeed(mps, isMetric)
  if isMetric then
    return _round(mps, 1), 'm/s'
  else
    local fps = mps * 3.28084
    return math.max(0, math.floor(fps + 0.5)), 'ft/s'
  end
end

local function _fmtAGL(meters, isMetric)
  return _fmtDistance(meters, isMetric)
end

local function _fmtTemplate(tpl, data)
  if not tpl or tpl == '' then return '' end
  -- Support placeholder keys with underscores (e.g., {zone_dist_u})
  return (tpl:gsub('{([%w_]+)}', function(k)
    local v = data and data[k]
    -- If value is missing, leave placeholder intact to aid debugging
    if v == nil then return '{'..k..'}' end
    return tostring(v)
  end))
end

-- Coalition utility: return opposite side (BLUE<->RED); NEUTRAL returns RED by default
local function _enemySide(side)
  if coalition and coalition.side then
    if side == coalition.side.BLUE then return coalition.side.RED end
    if side == coalition.side.RED then return coalition.side.BLUE end
  end
  return coalition.side.RED
end

-- Find nearest enemy-held base within radius; returns {point=vec3, name=string, dist=meters}
function CTLD:_findNearestEnemyBase(point, radius)
  local enemy = _enemySide(self.Side)
  local ok, bases = pcall(function()
    if coalition and coalition.getAirbases then return coalition.getAirbases(enemy) end
    return {}
  end)
  if not ok or not bases then return nil end
  local best
  for _,ab in ipairs(bases) do
    local p = ab:getPoint()
    local dx = (p.x - point.x); local dz = (p.z - point.z)
    local d = math.sqrt(dx*dx + dz*dz)
    if d <= radius and ((not best) or d < best.dist) then
      best = { point = { x = p.x, z = p.z }, name = ab:getName() or 'Base', dist = d }
    end
  end
  return best
end

-- Find nearest enemy ground group centroid within radius; returns {point=vec3, group=GROUP|nil, dcsGroupName=string, dist=meters, type=string}
function CTLD:_findNearestEnemyGround(point, radius)
  local enemy = _enemySide(self.Side)
  local best
  -- Use MOOSE SET_GROUP to enumerate enemy ground groups
  local set = SET_GROUP:New():FilterCoalitions(enemy):FilterCategories(Group.Category.GROUND):FilterActive(true):FilterStart()
  set:ForEachGroup(function(g)
    local alive = g:IsAlive()
    if alive then
      local c = g:GetCoordinate()
      if c then
        local v3 = c:GetVec3()
        local dx = (v3.x - point.x); local dz = (v3.z - point.z)
        local d = math.sqrt(dx*dx + dz*dz)
        if d <= radius and ((not best) or d < best.dist) then
          -- Try to infer a type label from first unit
          local ut = 'unit'
          local u1 = g:GetUnit(1)
          if u1 then ut = _getUnitType(u1) or ut end
          best = { point = { x = v3.x, z = v3.z }, group = g, dcsGroupName = g:GetName(), dist = d, type = ut }
        end
      end
    end
  end)
  return best
end

-- Order a ground group by name to move toward target point at a given speed (km/h). Uses MOOSE route when available.
function CTLD:_orderGroundGroupToPointByName(groupName, targetPoint, speedKmh)
  if not groupName or not targetPoint then return end
  local mg
  local ok = pcall(function() mg = GROUP:FindByName(groupName) end)
  if ok and mg then
    local vec2 = VECTOR2:New(targetPoint.x, targetPoint.z)
    -- RouteGroundTo(speed km/h). Use pcall to avoid mission halt if API differs.
    local _, _ = pcall(function() mg:RouteGroundTo(vec2, speedKmh or 25) end)
    return
  end
  -- Fallback: DCS Group controller simple mission to single waypoint
  local dg = Group.getByName(groupName)
  if not dg then return end
  local ctrl = dg:getController()
  if not ctrl then return end
  -- Try to set a simple go-to task
  local task = {
    id = 'Mission',
    params = {
      route = {
        points = {
          {
            x = targetPoint.x, y = targetPoint.z, speed = 5, action = 'Off Road', task = {}, type = 'Turning Point', ETA = 0, ETA_locked = false,
          }
        }
      }
    }
  }
  pcall(function() ctrl:setTask(task) end)
end

-- Assign attack behavior to a newly spawned ground group by name
function CTLD:_assignAttackBehavior(groupName, originPoint, isVehicle)
  if not (self.Config.AttackAI and self.Config.AttackAI.Enabled) then return end
  local radius = isVehicle and (self.Config.AttackAI.VehicleSearchRadius or 5000) or (self.Config.AttackAI.TroopSearchRadius or 3000)
  local prioBase = (self.Config.AttackAI.PrioritizeEnemyBases ~= false)
  local speed = isVehicle and (self.Config.AttackAI.VehicleAdvanceSpeedKmh or 35) or (self.Config.AttackAI.TroopAdvanceSpeedKmh or 20)
  local player = 'Player'
  -- Try to infer last requesting player from crate/troop context is complex; caller should pass announcements separately when needed.
  -- Target selection
  local target
  local pickedBase
  if prioBase then
    local base = self:_findNearestEnemyBase(originPoint, radius)
    if base then target = { point = base.point, name = base.name, kind = 'base', dist = base.dist } pickedBase = base end
  end
  if not target then
    local eg = self:_findNearestEnemyGround(originPoint, radius)
    if eg then target = { point = eg.point, name = eg.dcsGroupName, kind = 'enemy', dist = eg.dist, etype = eg.type } end
  end
  -- Order movement if we have a target
  if target then
    self:_orderGroundGroupToPointByName(groupName, target.point, speed)
  end
  return target -- caller will handle announcement
end

local function _bearingDeg(from, to)
  local dx = (to.x - from.x)
  local dz = (to.z - from.z)
  local ang = math.deg(math.atan2(dx, dz)) -- 0=N, +CW
  if ang < 0 then ang = ang + 360 end
  return math.floor(ang + 0.5)
end

local function _projectToBodyFrame(dx, dz, hdg)
  -- world (east=X=dx, north=Z=dz) to body frame (fwd/right)
  local fwd = dx * math.sin(hdg) + dz * math.cos(hdg)
  local right = dx * math.cos(hdg) - dz * math.sin(hdg)
  return right, fwd
end

local function _playerNameFromGroup(group)
  if not group then return 'Player' end
  local unit = group:GetUnit(1)
  local pname = unit and unit.GetPlayerName and unit:GetPlayerName()
  if pname and pname ~= '' then return pname end
  return group:GetName() or 'Player'
end

local function _coachSend(self, group, unitName, key, data, isCoach)
  local cfg = CTLD.HoverCoachConfig or {}
  local now = timer.getTime()
  CTLD._coachState[unitName] = CTLD._coachState[unitName] or { lastKeyTimes = {} }
  local st = CTLD._coachState[unitName]
  local last = st.lastKeyTimes[key] or 0
  local minGap = isCoach and ((cfg.throttle and cfg.throttle.coachUpdate) or 1.5) or ((cfg.throttle and cfg.throttle.generic) or 3.0)
  local repeatGap = (cfg.throttle and cfg.throttle.repeatSame) or (minGap * 2)
  if last > 0 and (now - last) < minGap then return end
  -- prevent repeat spam of identical key too fast (only after first send)
  if last > 0 and (now - last) < repeatGap then return end
  local tpl = CTLD.Messages and CTLD.Messages[key]
  if not tpl then return end
  local text = _fmtTemplate(tpl, data)
  if text and text ~= '' then
    _msgGroup(group, text)
    st.lastKeyTimes[key] = now
  end
end

local function _eventSend(self, group, side, key, data)
  local tpl = CTLD.Messages and CTLD.Messages[key]
  if not tpl then return end
  local now = timer.getTime()
  local scopeKey
  if group then scopeKey = 'GRP:'..group:GetName() else scopeKey = 'COAL:'..tostring(side or self.Side) end
  CTLD._msgState[scopeKey] = CTLD._msgState[scopeKey] or { lastKeyTimes = {} }
  local st = CTLD._msgState[scopeKey]
  local last = st.lastKeyTimes[key] or 0
  local cfg = CTLD.HoverCoachConfig
  local minGap = (cfg and cfg.throttle and cfg.throttle.generic) or 3.0
  local repeatGap = (cfg and cfg.throttle and cfg.throttle.repeatSame) or (minGap * 2)
  if last > 0 and (now - last) < minGap then return end
  if last > 0 and (now - last) < repeatGap then return end

  local text = _fmtTemplate(tpl, data)
  if not text or text == '' then return end
  if group then _msgGroup(group, text) else _msgCoalition(side or self.Side, text) end
  st.lastKeyTimes[key] = now
end

-- Format helpers for menu labels and recipe info
function CTLD:_recipeTotalCrates(def)
  if not def then return 1 end
  if type(def.requires) == 'table' then
    local n = 0
    for _,qty in pairs(def.requires) do n = n + (qty or 0) end
    return math.max(1, n)
  end
  return math.max(1, def.required or 1)
end

function CTLD:_friendlyNameForKey(key)
  local d = self.Config and self.Config.CrateCatalog and self.Config.CrateCatalog[key]
  if not d then return tostring(key) end
  return (d.menu or d.description or key)
end

function CTLD:_formatMenuLabelWithCrates(key, def)
  local base = (def and (def.menu or def.description)) or key
  local total = self:_recipeTotalCrates(def)
  local suffix = (total == 1) and '1 crate' or (tostring(total)..' crates')
  -- Optionally append stock for UX; uses nearest pickup zone dynamically
  if self.Config.Inventory and self.Config.Inventory.ShowStockInMenu then
    local group = nil
    -- Try to find any active group menu owner to infer nearest zone; if none, skip hint
    for gname,_ in pairs(self.MenusByGroup or {}) do group = GROUP:FindByName(gname); if group then break end end
    if group and group:IsAlive() then
      local unit = group:GetUnit(1)
      if unit and unit:IsAlive() then
        local zone, dist = _nearestZonePoint(unit, self.Config.Zones and self.Config.Zones.PickupZones or {})
        if zone and dist and dist <= (self.Config.PickupZoneMaxDistance or 10000) then
          local zname = zone:GetName()
          local stock = (CTLD._stockByZone[zname] and CTLD._stockByZone[zname][key]) or 0
          return string.format('%s (%s) [%s: %d]', base, suffix, zname, stock)
        end
      end
    end
  end
  return string.format('%s (%s)', base, suffix)
end

function CTLD:_formatRecipeInfo(key, def)
  local lines = {}
  local title = self:_friendlyNameForKey(key)
  table.insert(lines, string.format('%s', title))
  if def and def.isFOB then table.insert(lines, '(FOB recipe)') end
  if def and type(def.requires) == 'table' then
    local total = self:_recipeTotalCrates(def)
    table.insert(lines, string.format('Requires: %d crate(s) total', total))
    table.insert(lines, 'Breakdown:')
    -- stable order
    local items = {}
    for k,qty in pairs(def.requires) do table.insert(items, {k=k, q=qty}) end
    table.sort(items, function(a,b) return tostring(a.k) < tostring(b.k) end)
    for _,it in ipairs(items) do
      local fname = self:_friendlyNameForKey(it.k)
      table.insert(lines, string.format('- %dx %s', it.q or 1, fname))
    end
  else
    local n = self:_recipeTotalCrates(def)
    table.insert(lines, string.format('Requires: %d crate(s)', n))
  end
  if def and def.dcsCargoType then
    table.insert(lines, string.format('Cargo type: %s', tostring(def.dcsCargoType)))
  end
  return table.concat(lines, '\n')
end

-- Determine an approximate radius for a ZONE. Tries MOOSE radius, then trigger zone radius, then configured radius.
function CTLD:_getZoneRadius(zone)
  if zone and zone.Radius then return zone.Radius end
  local name = zone and zone.GetName and zone:GetName() or nil
  if name and trigger and trigger.misc and trigger.misc.getZone then
    local z = trigger.misc.getZone(name)
    if z and z.radius then return z.radius end
  end
  if name and self._ZoneDefs and self._ZoneDefs.FOBZones and self._ZoneDefs.FOBZones[name] then
    local d = self._ZoneDefs.FOBZones[name]
    if d and d.radius then return d.radius end
  end
  return 150
end

-- Check if a 2D point (x,z) lies within any FOB zone; returns (bool, zone)
function CTLD:IsPointInFOBZones(point)
  for _,z in ipairs(self.FOBZones or {}) do
    local pz = z:GetPointVec3()
    local r = self:_getZoneRadius(z)
    local dx = (pz.x - point.x)
    local dz = (pz.z - point.z)
    if (dx*dx + dz*dz) <= (r*r) then return true, z end
  end
  return false, nil
end

-- #endregion Utilities

-- =========================
-- Construction
-- =========================
-- #region Construction
function CTLD:New(cfg)
  local o = setmetatable({}, self)
  o.Config = DeepCopy(CTLD.Config)
  if cfg then o.Config = DeepMerge(o.Config, cfg) end
  o.Side = o.Config.CoalitionSide
  o.MenuRoots = {}
  o.MenusByGroup = {}

  -- If caller disabled builtin catalog, clear it before merging any globals
  if o.Config.UseBuiltinCatalog == false then
    o.Config.CrateCatalog = {}
  end

  -- If a global catalog was loaded earlier (via DO SCRIPT FILE), merge it automatically
  -- Supported globals: _CTLD_EXTRACTED_CATALOG (our extractor), CTLD_CATALOG, MOOSE_CTLD_CATALOG
  do
    local globalsToCheck = { '_CTLD_EXTRACTED_CATALOG', 'CTLD_CATALOG', 'MOOSE_CTLD_CATALOG' }
    for _,gn in ipairs(globalsToCheck) do
      local t = rawget(_G, gn)
      if type(t) == 'table' then
        o:MergeCatalog(t)
        if o.Config.Debug then env.info('[Moose_CTLD] Merged crate catalog from global '..gn) end
      end
    end
  end
  o:InitZones()
  -- Validate configured zones and warn if missing
  o:ValidateZones()
  -- Optional: draw configured zones on the F10 map
  if o.Config.MapDraw and o.Config.MapDraw.Enabled then
    -- Defer a tiny bit to ensure mission environment is fully up
    timer.scheduleFunction(function()
      pcall(function() o:DrawZonesOnMap() end)
    end, {}, timer.getTime() + 1)
  end
  -- Optional: bind zone activation to mission flags (merge from config table and per-zone flag fields)
  do
    local merged = {}
    -- Collect from explicit bindings (backward compatible)
    if o.Config.ZoneEventBindings then
      for _,b in ipairs(o.Config.ZoneEventBindings) do table.insert(merged, b) end
    end
    -- Collect from per-zone entries (preferred)
    local function pushFromZones(kind, list)
      for _,z in ipairs(list or {}) do
        if z and z.name and z.flag then
          table.insert(merged, { kind = kind, name = z.name, flag = z.flag, activeWhen = z.activeWhen or 1 })
        end
      end
    end
    pushFromZones('Pickup', o.Config.Zones and o.Config.Zones.PickupZones)
    pushFromZones('Drop',   o.Config.Zones and o.Config.Zones.DropZones)
    pushFromZones('FOB',    o.Config.Zones and o.Config.Zones.FOBZones)

    o._BindingsMerged = merged
    if o._BindingsMerged and #o._BindingsMerged > 0 then
      o._ZoneFlagState = {}
      o._ZoneFlagsPrimed = false
      o.ZoneFlagSched = SCHEDULER:New(nil, function()
        if not o._ZoneFlagsPrimed then
          -- Prime states on first run without spamming messages
          for _,b in ipairs(o._BindingsMerged) do
            if b and b.flag and b.kind and b.name then
              local val = (trigger and trigger.misc and trigger.misc.getUserFlag) and trigger.misc.getUserFlag(b.flag) or 0
              local activeWhen = (b.activeWhen ~= nil) and b.activeWhen or 1
              local shouldBeActive = (val == activeWhen)
              local key = tostring(b.kind)..'|'..tostring(b.name)
              o._ZoneFlagState[key] = shouldBeActive
              o:SetZoneActive(b.kind, b.name, shouldBeActive, true)
            end
          end
          o._ZoneFlagsPrimed = true
          return
        end
        -- Subsequent runs: announce changes
        for _,b in ipairs(o._BindingsMerged) do
          if b and b.flag and b.kind and b.name then
            local val = (trigger and trigger.misc and trigger.misc.getUserFlag) and trigger.misc.getUserFlag(b.flag) or 0
            local activeWhen = (b.activeWhen ~= nil) and b.activeWhen or 1
            local shouldBeActive = (val == activeWhen)
            local key = tostring(b.kind)..'|'..tostring(b.name)
            if o._ZoneFlagState[key] ~= shouldBeActive then
              o._ZoneFlagState[key] = shouldBeActive
              o:SetZoneActive(b.kind, b.name, shouldBeActive, false)
            end
          end
        end
      end, {}, 1, 1)
    end
  end
  o:InitMenus()

  -- Initialize inventory for configured pickup zones (seed from catalog initialStock)
  if o.Config.Inventory and o.Config.Inventory.Enabled then
    pcall(function() o:InitInventory() end)
  end

  -- Periodic cleanup for crates
  o.Sched = SCHEDULER:New(nil, function()
    o:CleanupCrates()
  end, {}, 60, 60)

  -- Optional: auto-build FOBs inside FOB zones when crates present
  if o.Config.AutoBuildFOBInZones then
    o.AutoFOBSched = SCHEDULER:New(nil, function()
      o:AutoBuildFOBCheck()
    end, {}, 10, 10) -- check every 10 seconds
  end

  -- Optional: hover pickup scanner
  if o.Config.HoverPickup and o.Config.HoverPickup.Enabled then
    o.HoverSched = SCHEDULER:New(nil, function()
      o:ScanHoverPickup()
    end, {}, 0.5, 0.5)
  end

  table.insert(CTLD._instances, o)
  _msgCoalition(o.Side, string.format('CTLD %s initialized for coalition', CTLD.Version))
  return o
end

function CTLD:InitZones()
  self.PickupZones = {}
  self.DropZones = {}
  self.FOBZones = {}
  self._ZoneDefs = { PickupZones = {}, DropZones = {}, FOBZones = {} }
  self._ZoneActive = { Pickup = {}, Drop = {}, FOB = {} }
  for _,z in ipairs(self.Config.Zones.PickupZones or {}) do
    local mz = _findZone(z)
    if mz then
      table.insert(self.PickupZones, mz)
      local name = mz:GetName()
      self._ZoneDefs.PickupZones[name] = z
      if self._ZoneActive.Pickup[name] == nil then self._ZoneActive.Pickup[name] = (z.active ~= false) end
    end
  end
  for _,z in ipairs(self.Config.Zones.DropZones or {}) do
    local mz = _findZone(z)
    if mz then
      table.insert(self.DropZones, mz)
      local name = mz:GetName()
      self._ZoneDefs.DropZones[name] = z
      if self._ZoneActive.Drop[name] == nil then self._ZoneActive.Drop[name] = (z.active ~= false) end
    end
  end
  for _,z in ipairs(self.Config.Zones.FOBZones or {}) do
    local mz = _findZone(z)
    if mz then
      table.insert(self.FOBZones, mz)
      local name = mz:GetName()
      self._ZoneDefs.FOBZones[name] = z
      if self._ZoneActive.FOB[name] == nil then self._ZoneActive.FOB[name] = (z.active ~= false) end
    end
  end
end

-- Validate configured zone names exist in the mission; warn coalition if any are missing.
function CTLD:ValidateZones()
  local function zoneExistsByName(name)
    if not name or name == '' then return false end
    if trigger and trigger.misc and trigger.misc.getZone then
      local z = trigger.misc.getZone(name)
      if z then return true end
    end
    if ZONE and ZONE.FindByName then
      local mz = ZONE:FindByName(name)
      if mz then return true end
    end
    return false
  end

  local function sideToStr(s)
    if coalition and coalition.side then
      if s == coalition.side.BLUE then return 'BLUE' end
      if s == coalition.side.RED then return 'RED' end
      if s == coalition.side.NEUTRAL then return 'NEUTRAL' end
    end
    return tostring(s)
  end

  local function join(t)
    local s = ''
    for i,name in ipairs(t) do s = s .. (i>1 and ', ' or '') .. tostring(name) end
    return s
  end

  local missing = { Pickup = {}, Drop = {}, FOB = {} }
  local found =   { Pickup = {}, Drop = {}, FOB = {} }
  local coords =  { Pickup = 0, Drop = 0, FOB = 0 }

  for _,z in ipairs(self.Config.Zones.PickupZones or {}) do
    if z.name then
      if zoneExistsByName(z.name) then table.insert(found.Pickup, z.name) else table.insert(missing.Pickup, z.name) end
    elseif z.coord then
      coords.Pickup = coords.Pickup + 1
    end
  end
  for _,z in ipairs(self.Config.Zones.DropZones or {}) do
    if z.name then
      if zoneExistsByName(z.name) then table.insert(found.Drop, z.name) else table.insert(missing.Drop, z.name) end
    elseif z.coord then
      coords.Drop = coords.Drop + 1
    end
  end
  for _,z in ipairs(self.Config.Zones.FOBZones or {}) do
    if z.name then
      if zoneExistsByName(z.name) then table.insert(found.FOB, z.name) else table.insert(missing.FOB, z.name) end
    elseif z.coord then
      coords.FOB = coords.FOB + 1
    end
  end

  -- Log a concise summary to dcs.log
  local sideStr = sideToStr(self.Side)
  env.info(string.format('[Moose_CTLD][ZoneValidation][%s] Pickup: configured=%d (named=%d, coord=%d) found=%d missing=%d',
    sideStr,
    #(self.Config.Zones.PickupZones or {}), #found.Pickup + #missing.Pickup, coords.Pickup, #found.Pickup, #missing.Pickup))
  env.info(string.format('[Moose_CTLD][ZoneValidation][%s] Drop  : configured=%d (named=%d, coord=%d) found=%d missing=%d',
    sideStr,
    #(self.Config.Zones.DropZones or {}),   #found.Drop + #missing.Drop,   coords.Drop,   #found.Drop,   #missing.Drop))
  env.info(string.format('[Moose_CTLD][ZoneValidation][%s] FOB   : configured=%d (named=%d, coord=%d) found=%d missing=%d',
    sideStr,
    #(self.Config.Zones.FOBZones or {}),    #found.FOB + #missing.FOB,     coords.FOB,    #found.FOB,    #missing.FOB))

  local anyMissing = (#missing.Pickup > 0) or (#missing.Drop > 0) or (#missing.FOB > 0)
  if anyMissing then
    if #missing.Pickup > 0 then
      local msg = 'CTLD config warning: Missing Pickup Zones: '..join(missing.Pickup)
      _msgCoalition(self.Side, msg); env.info('[Moose_CTLD][ZoneValidation]['..sideStr..'] '..msg)
    end
    if #missing.Drop > 0 then
      local msg = 'CTLD config warning: Missing Drop Zones: '..join(missing.Drop)
      _msgCoalition(self.Side, msg); env.info('[Moose_CTLD][ZoneValidation]['..sideStr..'] '..msg)
    end
    if #missing.FOB > 0 then
      local msg = 'CTLD config warning: Missing FOB Zones: '..join(missing.FOB)
      _msgCoalition(self.Side, msg); env.info('[Moose_CTLD][ZoneValidation]['..sideStr..'] '..msg)
    end
  else
    env.info(string.format('[Moose_CTLD][ZoneValidation][%s] All configured zone names resolved successfully.', sideStr))
  end

  self._MissingZones = missing
end
-- #endregion Construction

-- =========================
-- Menus
-- =========================
-- #region Menus
function CTLD:InitMenus()
  if self.Config.UseGroupMenus then
    self:WireBirthHandler()
    -- No coalition-level root when using per-group menus; Admin/Help is nested under each group's CTLD menu
  else
    self.MenuRoot = MENU_COALITION:New(self.Side, 'CTLD')
    self:BuildCoalitionMenus(self.MenuRoot)
    self:InitCoalitionAdminMenu()
  end
end

function CTLD:WireBirthHandler()
  local handler = EVENTHANDLER:New()
  handler:HandleEvent(EVENTS.Birth)
  local selfref = self
  function handler:OnEventBirth(eventData)
    local unit = eventData.IniUnit
    if not unit or not unit:IsAlive() then return end
    if unit:GetCoalition() ~= selfref.Side then return end
    local typ = _getUnitType(unit)
    if not _isIn(selfref.Config.AllowedAircraft, typ) then return end
    local grp = unit:GetGroup()
    if not grp then return end
    local gname = grp:GetName()
    if selfref.MenusByGroup[gname] then return end
    selfref.MenusByGroup[gname] = selfref:BuildGroupMenus(grp)
    _msgGroup(grp, 'CTLD menu available (F10)')
  end
  self.BirthHandler = handler
end

function CTLD:BuildGroupMenus(group)
  local root = MENU_GROUP:New(group, 'CTLD')
  -- Safe menu command helper: wraps callbacks to prevent silent errors
  local function CMD(title, parent, cb)
    return MENU_GROUP_COMMAND:New(group, title, parent, function()
      local ok, err = pcall(cb)
      if not ok then
        env.info('[Moose_CTLD] Menu error: '..tostring(err))
        MESSAGE:New('CTLD menu error: '..tostring(err), 8):ToGroup(group)
      end
    end)
  end
  -- Troop transport submenu at top
  local troopsRoot = MENU_GROUP:New(group, 'Troop Transport', root)
  CMD('Load Troops', troopsRoot, function() self:LoadTroops(group) end)
  do
    local tr = (self.Config.AttackAI and self.Config.AttackAI.TroopSearchRadius) or 3000
    CMD('Deploy [Hold Position]', troopsRoot, function() self:UnloadTroops(group, { behavior = 'defend' }) end)
    CMD(string.format('Deploy [Attack (%dm)]', tr), troopsRoot, function() self:UnloadTroops(group, { behavior = 'attack' }) end)
  end
  -- Request crate submenu per catalog entry
  local reqRoot = MENU_GROUP:New(group, 'Request Crate', root)
  -- Removed: previously created a filtered "Request Crate (In Stock Here)" submenu
  -- Optional: parallel Recipe Info submenu to display detailed requirements
  local infoRoot = MENU_GROUP:New(group, 'Recipe Info', root)
  if self.Config.UseCategorySubmenus then
    local submenus = {}
    local function getSubmenu(catLabel)
      if not submenus[catLabel] then
        submenus[catLabel] = MENU_GROUP:New(group, catLabel, reqRoot)
      end
      return submenus[catLabel]
    end
    local infoSubs = {}
    local function getInfoSub(catLabel)
      if not infoSubs[catLabel] then
        infoSubs[catLabel] = MENU_GROUP:New(group, catLabel, infoRoot)
      end
      return infoSubs[catLabel]
    end
    for key,def in pairs(self.Config.CrateCatalog) do
      local label = self:_formatMenuLabelWithCrates(key, def)
      local sideOk = (not def.side) or def.side == self.Side
      if sideOk then
        local catLabel = (def and def.menuCategory) or 'Other'
        local parent = getSubmenu(catLabel)
        CMD(label, parent, function() self:RequestCrateForGroup(group, key) end)
        local infoParent = getInfoSub(catLabel)
        CMD((def and (def.menu or def.description)) or key, infoParent, function()
          local text = self:_formatRecipeInfo(key, def)
          _msgGroup(group, text)
        end)
      end
    end
  else
    for key,def in pairs(self.Config.CrateCatalog) do
      local label = self:_formatMenuLabelWithCrates(key, def)
      local sideOk = (not def.side) or def.side == self.Side
      if sideOk then
        CMD(label, reqRoot, function() self:RequestCrateForGroup(group, key) end)
        CMD(((def and (def.menu or def.description)) or key)..' (info)', infoRoot, function()
          local text = self:_formatRecipeInfo(key, def)
          _msgGroup(group, text)
        end)
      end
    end
  end

  -- Removed: filtered "In Stock Here" submenu
  -- (Troop Transport submenu created at top)

  -- Build
  CMD('Build Here', root, function() self:BuildAtGroup(group) end)
  -- Build (Advanced): per-item attack/defend options
  local buildAdvRoot = MENU_GROUP:New(group, 'Build (Advanced)', root)
  MENU_GROUP_COMMAND:New(group, 'Refresh Buildable List', buildAdvRoot, function()
    self:_BuildOrRefreshBuildAdvancedMenu(group, buildAdvRoot)
    MESSAGE:New('Buildable list refreshed.', 6):ToGroup(group)
  end)
  -- Initial populate
  self:_BuildOrRefreshBuildAdvancedMenu(group, buildAdvRoot)

  -- Crate management (loaded crates)
  CMD('Drop One Loaded Crate', root, function() self:DropLoadedCrates(group, 1) end)
  CMD('Drop All Loaded Crates', root, function() self:DropLoadedCrates(group, -1) end)

  -- Coach & Navigation utilities
  local navRoot = MENU_GROUP:New(group, 'Coach & Nav', root)
  local gname = group:GetName()
  CMD('Hover Coach: Enable', navRoot, function()
    CTLD._coachOverride = CTLD._coachOverride or {}
    CTLD._coachOverride[gname] = true
    _eventSend(self, group, nil, 'coach_enabled', {})
  end)
  CMD('Hover Coach: Disable', navRoot, function()
    CTLD._coachOverride = CTLD._coachOverride or {}
    CTLD._coachOverride[gname] = false
    _eventSend(self, group, nil, 'coach_disabled', {})
  end)
  CMD('Request Vectors to Nearest Crate', navRoot, function()
    local unit = group:GetUnit(1)
    if not unit or not unit:IsAlive() then return end
    local p = unit:GetPointVec3()
    local here = { x = p.x, z = p.z }
    -- find nearest same-side crate
    local bestName, bestMeta, bestd
    for name,meta in pairs(CTLD._crates) do
      if meta.side == self.Side then
        local dx = (meta.point.x - here.x)
        local dz = (meta.point.z - here.z)
        local d = math.sqrt(dx*dx + dz*dz)
        if (not bestd) or d < bestd then
          bestName, bestMeta, bestd = name, meta, d
        end
      end
    end
    if bestName and bestMeta then
      local brg = _bearingDeg(here, bestMeta.point)
      local isMetric = _getPlayerIsMetric(unit)
      local rngV, rngU = _fmtRange(bestd, isMetric)
      _eventSend(self, group, nil, 'vectors_to_crate', { id = bestName, brg = brg, rng = rngV, rng_u = rngU })
    else
      _msgGroup(group, 'No friendly crates found.')
    end
  end)
  CMD('Vectors to Nearest Pickup Zone', navRoot, function()
    local unit = group:GetUnit(1)
    if not unit or not unit:IsAlive() then return end
    local zone = nil
    local dist = nil
    -- Prefer configured pickup zones list; fallback to runtime zones converted to name list
    local list = nil
    if self.Config and self.Config.Zones and self.Config.Zones.PickupZones then
      list = {}
      for _,z in ipairs(self.Config.Zones.PickupZones) do
        if (not z.name) or self._ZoneActive.Pickup[z.name] ~= false then table.insert(list, z) end
      end
    elseif self.PickupZones and #self.PickupZones > 0 then
      list = {}
      for _,mz in ipairs(self.PickupZones) do
        if mz and mz.GetName then
          local n = mz:GetName()
          if self._ZoneActive.Pickup[n] ~= false then table.insert(list, { name = n }) end
        end
      end
    else
      list = {}
    end
    zone, dist = _nearestZonePoint(unit, list)
    if not zone then
      -- Fallback: try any configured pickup zone even if inactive to provide vectors
      local allDefs = self.Config and self.Config.Zones and self.Config.Zones.PickupZones or {}
      if allDefs and #allDefs > 0 then
        local fbZone, fbDist = _nearestZonePoint(unit, allDefs)
        if fbZone then
          local up = unit:GetPointVec3(); local zp = fbZone:GetPointVec3()
          local from = { x = up.x, z = up.z }
          local to = { x = zp.x, z = zp.z }
          local brg = _bearingDeg(from, to)
          local isMetric = _getPlayerIsMetric(unit)
          local rngV, rngU = _fmtRange(fbDist or 0, isMetric)
          _eventSend(self, group, nil, 'vectors_to_pickup_zone', { zone = fbZone:GetName(), brg = brg, rng = rngV, rng_u = rngU })
          return
        end
      end
      _eventSend(self, group, nil, 'no_pickup_zones', {})
      return
    end
    local up = unit:GetPointVec3()
    local zp = zone:GetPointVec3()
    local from = { x = up.x, z = up.z }
    local to = { x = zp.x, z = zp.z }
    local brg = _bearingDeg(from, to)
    local isMetric = _getPlayerIsMetric(unit)
    local rngV, rngU = _fmtRange(dist, isMetric)
    _eventSend(self, group, nil, 'vectors_to_pickup_zone', { zone = zone:GetName(), brg = brg, rng = rngV, rng_u = rngU })
  end)
  CMD('Re-mark Nearest Crate (Smoke)', navRoot, function()
    local unit = group:GetUnit(1)
    if not unit or not unit:IsAlive() then return end
    local p = unit:GetPointVec3()
    local here = { x = p.x, z = p.z }
    local bestName, bestMeta, bestd
    for name,meta in pairs(CTLD._crates) do
      if meta.side == self.Side then
        local dx = (meta.point.x - here.x)
        local dz = (meta.point.z - here.z)
        local d = math.sqrt(dx*dx + dz*dz)
        if (not bestd) or d < bestd then
          bestName, bestMeta, bestd = name, meta, d
        end
      end
    end
    if bestName and bestMeta then
      local zdef = { smoke = self.Config.PickupZoneSmokeColor }
      trigger.action.smoke({ x = bestMeta.point.x, z = bestMeta.point.z }, (zdef and zdef.smoke) or self.Config.PickupZoneSmokeColor)
      _eventSend(self, group, nil, 'crate_re_marked', { id = bestName, mark = 'smoke' })
    else
      _msgGroup(group, 'No friendly crates found to mark.')
    end
  end)

  -- Admin/Help (nested under CTLD group menu when using group menus)
  local admin = MENU_GROUP:New(group, 'Admin/Help', root)
  -- Removed: 'In Stock' quick refresh admin command
  CMD('Enable CTLD Debug Logging', admin, function()
    self.Config.Debug = true
    env.info(string.format('[Moose_CTLD][%s] Debug ENABLED via Admin menu', tostring(self.Side)))
    MESSAGE:New('CTLD Debug logging ENABLED', 8):ToGroup(group)
  end)
  CMD('Disable CTLD Debug Logging', admin, function()
    self.Config.Debug = false
    env.info(string.format('[Moose_CTLD][%s] Debug DISABLED via Admin menu', tostring(self.Side)))
    MESSAGE:New('CTLD Debug logging DISABLED', 8):ToGroup(group)
  end)
  CMD('Show CTLD Status (crates/zones)', admin, function()
    -- Reuse the coalition summary builder but send to this group
    local crates = 0
    for _ in pairs(CTLD._crates) do crates = crates + 1 end
    local msg = string.format('CTLD Status:\nActive crates: %d\nPickup zones: %d\nDrop zones: %d\nFOB zones: %d\nBuild Confirm: %s (%ds window)\nBuild Cooldown: %s (%ds)'
      , crates, #(self.PickupZones or {}), #(self.DropZones or {}), #(self.FOBZones or {})
      , self.Config.BuildConfirmEnabled and 'ON' or 'OFF', self.Config.BuildConfirmWindowSeconds or 0
      , self.Config.BuildCooldownEnabled and 'ON' or 'OFF', self.Config.BuildCooldownSeconds or 0)
    MESSAGE:New(msg, 20):ToGroup(group)
  end)
  CMD('Draw CTLD Zones on Map', admin, function()
    self:DrawZonesOnMap()
    MESSAGE:New('CTLD zones drawn on F10 map.', 8):ToGroup(group)
  end)
  CMD('Clear CTLD Map Drawings', admin, function()
    self:ClearMapDrawings()
    MESSAGE:New('CTLD map drawings cleared.', 8):ToGroup(group)
  end)

  return root
end

-- Create or refresh the filtered "In Stock Here" menu for a group.
-- If rootMenu is provided, (re)create under that. Otherwise, reuse previous stored root.
function CTLD:_BuildOrRefreshInStockMenu(group, rootMenu)
  if not (self.Config.Inventory and self.Config.Inventory.Enabled and self.Config.Inventory.HideZeroStockMenu) then return end
  if not group or not group:IsAlive() then return end
  local gname = group:GetName()
  -- remove previous menu if present and rootMenu not explicitly provided
  local existing = CTLD._inStockMenus[gname]
  if existing and existing.menu and (rootMenu == nil) then
    pcall(function() existing.menu:Remove() end)
    CTLD._inStockMenus[gname] = nil
  end

  local parent = rootMenu or (self.MenusByGroup and self.MenusByGroup[gname])
  if not parent then return end

  -- Create a fresh submenu root
  local inRoot = MENU_GROUP:New(group, 'Request Crate (In Stock Here)', parent)
  CTLD._inStockMenus[gname] = { menu = inRoot }

  -- Find nearest active pickup zone
  local unit = group:GetUnit(1)
  if not unit or not unit:IsAlive() then return end
  local zone, dist = self:_nearestActivePickupZone(unit)
  if not zone then
    MENU_GROUP_COMMAND:New(group, 'No active supply zone nearby', inRoot, function()
      -- Inform and also provide vectors to nearest configured zone if any
      _eventSend(self, group, nil, 'no_pickup_zones', {})
      -- Fallback: try any configured pickup zone (ignoring active state) for helpful vectors
      local list = self.Config and self.Config.Zones and self.Config.Zones.PickupZones or {}
      if list and #list > 0 then
        local unit = group:GetUnit(1)
        if unit and unit:IsAlive() then
          local fallbackZone, fallbackDist = _nearestZonePoint(unit, list)
          if fallbackZone then
            local up = unit:GetPointVec3(); local zp = fallbackZone:GetPointVec3()
            local brg = _bearingDeg({x=up.x,z=up.z}, {x=zp.x,z=zp.z})
            local isMetric = _getPlayerIsMetric(unit)
            local rngV, rngU = _fmtRange(fallbackDist or 0, isMetric)
            _eventSend(self, group, nil, 'vectors_to_pickup_zone', { zone = fallbackZone:GetName(), brg = brg, rng = rngV, rng_u = rngU })
          end
        end
      end
    end)
    -- Still add a refresh item
    MENU_GROUP_COMMAND:New(group, 'Refresh In-Stock List', inRoot, function() self:_BuildOrRefreshInStockMenu(group) end)
    return
  end
  local zname = zone:GetName()
  local maxd = self.Config.PickupZoneMaxDistance or 10000
  if not dist or dist > maxd then
    MENU_GROUP_COMMAND:New(group, string.format('Nearest zone %s is beyond limit (%.0f m).', zname, dist or 0), inRoot, function()
      local isMetric = _getPlayerIsMetric(unit)
      local v, u = _fmtRange(math.max(0, (dist or 0) - maxd), isMetric)
      local up = unit:GetPointVec3(); local zp = zone:GetPointVec3()
      local brg = _bearingDeg({x=up.x,z=up.z}, {x=zp.x,z=zp.z})
      _eventSend(self, group, nil, 'pickup_zone_required', { zone_dist = v, zone_dist_u = u, zone_brg = brg })
    end)
    MENU_GROUP_COMMAND:New(group, 'Refresh In-Stock List', inRoot, function() self:_BuildOrRefreshInStockMenu(group) end)
    return
  end

  -- Info and refresh commands at top
  MENU_GROUP_COMMAND:New(group, string.format('Nearest Supply: %s', zname), inRoot, function()
    local up = unit:GetPointVec3(); local zp = zone:GetPointVec3()
    local brg = _bearingDeg({x=up.x,z=up.z}, {x=zp.x,z=zp.z})
    local isMetric = _getPlayerIsMetric(unit)
    local rngV, rngU = _fmtRange(dist or 0, isMetric)
    _eventSend(self, group, nil, 'vectors_to_pickup_zone', { zone = zname, brg = brg, rng = rngV, rng_u = rngU })
  end)
  MENU_GROUP_COMMAND:New(group, 'Refresh In-Stock List', inRoot, function() self:_BuildOrRefreshInStockMenu(group) end)

  -- Build commands for items with stock > 0 at this zone; single-unit entries only
  local inStock = {}
  local stock = CTLD._stockByZone[zname] or {}
  for key,def in pairs(self.Config.CrateCatalog or {}) do
    local sideOk = (not def.side) or def.side == self.Side
    local isSingle = (type(def.requires) ~= 'table')
    if sideOk and isSingle then
      local cnt = tonumber(stock[key] or 0) or 0
      if cnt > 0 then
        table.insert(inStock, { key = key, def = def, cnt = cnt })
      end
    end
  end
  -- Stable sort by menu label for consistency
  table.sort(inStock, function(a,b)
    local la = (a.def and (a.def.menu or a.def.description)) or a.key
    local lb = (b.def and (b.def.menu or b.def.description)) or b.key
    return tostring(la) < tostring(lb)
  end)

  if #inStock == 0 then
    MENU_GROUP_COMMAND:New(group, 'None in stock at this zone', inRoot, function()
      _msgGroup(group, string.format('No crates in stock at %s.', zname))
    end)
  else
    for _,it in ipairs(inStock) do
      local base = (it.def and (it.def.menu or it.def.description)) or it.key
      local total = self:_recipeTotalCrates(it.def)
      local suffix = (total == 1) and '1 crate' or (tostring(total)..' crates')
      local label = string.format('%s (%s) [%d available]', base, suffix, it.cnt)
      MENU_GROUP_COMMAND:New(group, label, inRoot, function()
        self:RequestCrateForGroup(group, it.key)
        -- After requesting, refresh to reflect the decremented stock
        timer.scheduleFunction(function() self:_BuildOrRefreshInStockMenu(group) end, {}, timer.getTime() + 0.1)
      end)
    end
  end
end

-- Create or refresh the dynamic Build (Advanced) menu for a group.
function CTLD:_BuildOrRefreshBuildAdvancedMenu(group, rootMenu)
  if not group or not group:IsAlive() then return end
  -- Clear previous dynamic children if any by recreating the submenu root when rootMenu passed
  -- We'll remove and recreate inner items by making a temporary child root
  local gname = group:GetName()
  -- Remove existing dynamic children by creating a fresh inner menu
  local dynRoot = MENU_GROUP:New(group, 'Buildable Near You', rootMenu)

  local unit = group:GetUnit(1)
  if not unit or not unit:IsAlive() then return end
  local p = unit:GetPointVec3()
  local here = { x = p.x, z = p.z }
  local hdg = unit:GetHeading() or 0
  local buildOffset = math.max(0, tonumber(self.Config.BuildSpawnOffset or 0) or 0)
  local spawnAt = (buildOffset > 0) and { x = here.x + math.sin(hdg) * buildOffset, z = here.z + math.cos(hdg) * buildOffset } or { x = here.x, z = here.z }
  local radius = self.Config.BuildRadius or 60
  local nearby = self:GetNearbyCrates(here, radius)
  local filtered = {}
  for _,c in ipairs(nearby) do if c.meta.side == self.Side then table.insert(filtered, c) end end
  nearby = filtered
  -- Count by key
  local counts = {}
  for _,c in ipairs(nearby) do counts[c.meta.key] = (counts[c.meta.key] or 0) + 1 end
  -- Include carried crates if allowed
  if self.Config.BuildRequiresGroundCrates ~= true then
    local gname = group:GetName()
    local carried = CTLD._loadedCrates[gname]
    if carried and carried.byKey then
      for k,v in pairs(carried.byKey) do counts[k] = (counts[k] or 0) + v end
    end
  end
  -- FOB restriction context
  local insideFOBZone = select(1, self:IsPointInFOBZones(here))

  -- Build list of buildable recipes
  local items = {}
  for key,cat in pairs(self.Config.CrateCatalog or {}) do
    local sideOk = (not cat.side) or cat.side == self.Side
    if sideOk and cat and cat.build then
      local ok = false
      if type(cat.requires) == 'table' then
        ok = true
        for reqKey,qty in pairs(cat.requires) do if (counts[reqKey] or 0) < (qty or 0) then ok = false; break end end
      else
        ok = ((counts[key] or 0) >= (cat.required or 1))
      end
      if ok then
        if not (cat.isFOB and self.Config.RestrictFOBToZones and not insideFOBZone) then
          table.insert(items, { key = key, def = cat })
        end
      end
    end
  end

  if #items == 0 then
    MENU_GROUP_COMMAND:New(group, 'None buildable here. Drop required crates close to your aircraft.', dynRoot, function()
      MESSAGE:New('No buildable items with nearby crates. Use Recipe Info to check requirements.', 10):ToGroup(group)
    end)
    return
  end

  -- Stable ordering by label
  table.sort(items, function(a,b)
    local la = (a.def and (a.def.menu or a.def.description)) or a.key
    local lb = (b.def and (b.def.menu or b.def.description)) or b.key
    return tostring(la) < tostring(lb)
  end)

  -- Create per-item submenus
  local function CMD(title, parent, cb)
    return MENU_GROUP_COMMAND:New(group, title, parent, function()
      local ok, err = pcall(cb)
      if not ok then env.info('[Moose_CTLD] BuildAdv menu error: '..tostring(err)); MESSAGE:New('CTLD menu error: '..tostring(err), 8):ToGroup(group) end
    end)
  end

  for _,it in ipairs(items) do
    local label = (it.def and (it.def.menu or it.def.description)) or it.key
    local perItem = MENU_GROUP:New(group, label, dynRoot)
    -- Hold Position
    CMD('Build [Hold Position]', perItem, function()
      self:BuildSpecificAtGroup(group, it.key, { behavior = 'defend' })
    end)
    -- Attack variant (render even if canAttackMove=false; we message accordingly)
    local vr = (self.Config.AttackAI and self.Config.AttackAI.VehicleSearchRadius) or 5000
    CMD(string.format('Build [Attack (%dm)]', vr), perItem, function()
      if it.def and it.def.canAttackMove == false then
        MESSAGE:New('This unit is static or not suited to move; it will hold position.', 8):ToGroup(group)
        self:BuildSpecificAtGroup(group, it.key, { behavior = 'defend' })
      else
        self:BuildSpecificAtGroup(group, it.key, { behavior = 'attack' })
      end
    end)
  end
end

-- Build a specific recipe at the group position if crates permit; supports behavior opts
function CTLD:BuildSpecificAtGroup(group, recipeKey, opts)
  local unit = group:GetUnit(1)
  if not unit or not unit:IsAlive() then return end
  -- Reuse Build cooldown/confirm logic
  local now = timer.getTime()
  local gname = group:GetName()
  if self.Config.BuildCooldownEnabled then
    local last = CTLD._buildCooldown[gname]
    if last and (now - last) < (self.Config.BuildCooldownSeconds or 60) then
      local rem = math.max(0, math.ceil((self.Config.BuildCooldownSeconds or 60) - (now - last)))
      _msgGroup(group, string.format('Build on cooldown. Try again in %ds.', rem))
      return
    end
  end
  if self.Config.BuildConfirmEnabled then
    local first = CTLD._buildConfirm[gname]
    local win = self.Config.BuildConfirmWindowSeconds or 10
    if not first or (now - first) > win then
      CTLD._buildConfirm[gname] = now
      _msgGroup(group, string.format('Confirm build: select again within %ds to proceed.', win))
      return
    else
      CTLD._buildConfirm[gname] = nil
    end
  end

  local def = self.Config.CrateCatalog[recipeKey]
  if not def or not def.build then _msgGroup(group, 'Unknown or unbuildable recipe: '..tostring(recipeKey)); return end

  local p = unit:GetPointVec3()
  local here = { x = p.x, z = p.z }
  local hdg = unit:GetHeading() or 0
  local buildOffset = math.max(0, tonumber(self.Config.BuildSpawnOffset or 0) or 0)
  local spawnAt = (buildOffset > 0) and { x = here.x + math.sin(hdg) * buildOffset, z = here.z + math.cos(hdg) * buildOffset } or { x = here.x, z = here.z }
  local radius = self.Config.BuildRadius or 60
  local nearby = self:GetNearbyCrates(here, radius)
  local filtered = {}
  for _,c in ipairs(nearby) do if c.meta.side == self.Side then table.insert(filtered, c) end end
  nearby = filtered
  if #nearby == 0 and self.Config.BuildRequiresGroundCrates ~= true then
    -- still can build using carried crates
  elseif #nearby == 0 then
    _eventSend(self, group, nil, 'build_insufficient_crates', { build = def.description or recipeKey })
    return
  end

  -- Count by key
  local counts = {}
  for _,c in ipairs(nearby) do counts[c.meta.key] = (counts[c.meta.key] or 0) + 1 end
  -- Include carried crates
  local carried = CTLD._loadedCrates[gname]
  if self.Config.BuildRequiresGroundCrates ~= true then
    if carried and carried.byKey then for k,v in pairs(carried.byKey) do counts[k] = (counts[k] or 0) + v end end
  end

  -- Helper to consume crates of a given key/qty (prefers carried when allowed)
  local function consumeCrates(key, qty)
    local removed = 0
    if self.Config.BuildRequiresGroundCrates ~= true then
      if carried and carried.byKey and (carried.byKey[key] or 0) > 0 then
        local take = math.min(qty, carried.byKey[key])
        carried.byKey[key] = carried.byKey[key] - take
        if carried.byKey[key] <= 0 then carried.byKey[key] = nil end
        carried.total = math.max(0, (carried.total or 0) - take)
        removed = removed + take
      end
    end
    for _,c in ipairs(nearby) do
      if removed >= qty then break end
      if c.meta.key == key then
        local obj = StaticObject.getByName(c.name)
        if obj then obj:destroy() end
        CTLD._crates[c.name] = nil
        removed = removed + 1
      end
    end
  end

  -- FOB restriction check
  if def.isFOB and self.Config.RestrictFOBToZones then
    local inside = select(1, self:IsPointInFOBZones(here))
    if not inside then _eventSend(self, group, nil, 'fob_restricted', {}); return end
  end

  -- Special-case: SAM Site Repair/Augment entries (isRepair)
  if def.isRepair == true or tostring(recipeKey):find('_REPAIR', 1, true) then
    -- Map recipe key family to a template definition
    local function identifyTemplate(key)
      if key:find('HAWK', 1, true) then
        return {
          name='HAWK', side=def.side or self.Side,
          baseUnits={ {type='Hawk sr', dx=12, dz=8}, {type='Hawk tr', dx=-12, dz=8}, {type='Hawk pcp', dx=18, dz=12}, {type='Hawk cwar', dx=-18, dz=12} },
          launcherType='Hawk ln', launcherStart={dx=0, dz=0}, launcherStep={dx=6, dz=0}, maxLaunchers=6
        }
      elseif key:find('PATRIOT', 1, true) then
        return {
          name='PATRIOT', side=def.side or self.Side,
          baseUnits={ {type='Patriot str', dx=14, dz=10}, {type='Patriot ECS', dx=-14, dz=10} },
          launcherType='Patriot ln', launcherStart={dx=0, dz=0}, launcherStep={dx=8, dz=0}, maxLaunchers=6
        }
      elseif key:find('KUB', 1, true) then
        return {
          name='KUB', side=def.side or self.Side,
          baseUnits={ {type='Kub 1S91 str', dx=12, dz=8} },
          launcherType='Kub 2P25 ln', launcherStart={dx=0, dz=0}, launcherStep={dx=6, dz=0}, maxLaunchers=3
        }
      elseif key:find('BUK', 1, true) then
        return {
          name='BUK', side=def.side or self.Side,
          baseUnits={ {type='SA-11 Buk SR 9S18M1', dx=12, dz=8}, {type='SA-11 Buk CC 9S470M1', dx=-12, dz=8} },
          launcherType='SA-11 Buk LN 9A310M1', launcherStart={dx=0, dz=0}, launcherStep={dx=6, dz=0}, maxLaunchers=6
        }
      end
      return nil
    end

    local tpl = identifyTemplate(tostring(recipeKey))
    if not tpl then _msgGroup(group, 'No matching SAM site type for repair: '..tostring(recipeKey)); return end

    -- Determine how many repair crates to apply
    local cratesAvail = counts[recipeKey] or 0
    if cratesAvail <= 0 then _eventSend(self, group, nil, 'build_insufficient_crates', { build = def.description or recipeKey }); return end

    -- Find nearest existing site group that matches template
    local function vec2(u)
      local p = u:getPoint(); return { x = p.x, z = p.z }
    end
    local function dist2(a,b)
      local dx, dz = a.x-b.x, a.z-b.z; return math.sqrt(dx*dx+dz*dz)
    end
    local searchR = math.max(250, (self.Config.BuildRadius or 60) * 10)
    local groups = coalition.getGroups(tpl.side, Group.Category.GROUND) or {}
    local here2 = { x = here.x, z = here.z }
    local bestG, bestD, bestInfo = nil, 1e9, nil
    for _,g in ipairs(groups) do
      if g and g:isExist() then
        local units = g:getUnits() or {}
        if #units > 0 then
          -- Compute center and count types
          local cx, cz = 0, 0
          local byType = {}
          for _,u in ipairs(units) do
            local pt = u:getPoint(); cx = cx + pt.x; cz = cz + pt.z
            local tname = u:getTypeName() or ''
            byType[tname] = (byType[tname] or 0) + 1
          end
          cx = cx / #units; cz = cz / #units
          local d = dist2(here2, { x = cx, z = cz })
          if d <= searchR then
            -- Check presence of base units (at least 1 each)
            local ok = true
            for _,u in ipairs(tpl.baseUnits) do if (byType[u.type] or 0) < 1 then ok = false; break end end
            -- Require at least 1 launcher or allow 0 (initial repair to full base)? we'll allow 0 too.
            if ok then
              if d < bestD then
                bestG, bestD = g, d
                bestInfo = { byType = byType, center = { x = cx, z = cz }, headingDeg = function()
                  local h = 0; local leader = units[1]; if leader and leader.isExist and leader:isExist() then h = math.deg(leader:getHeading() or 0) end; return h
                end }
              end
            end
          end
        end
      end
    end

    if not bestG then
      _msgGroup(group, 'No matching SAM site found nearby to repair/augment.')
      return
    end

    -- Current launchers in site
    local curLaunchers = (bestInfo.byType[tpl.launcherType] or 0)
    local maxL = tpl.maxLaunchers or (curLaunchers + cratesAvail)
    local canAdd = math.max(0, (maxL - curLaunchers))
    if canAdd <= 0 then
      _msgGroup(group, 'SAM site is already at max launchers.')
      return
    end
    local addNum = math.min(cratesAvail, canAdd)

    -- Build new group composition: base units + (curLaunchers + addNum) launchers
    local function buildSite(point, headingDeg, side, launcherCount)
      local hdg = math.rad(headingDeg or 0)
      local function off(dx, dz)
        -- rotate offsets by heading
        local s, c = math.sin(hdg), math.cos(hdg)
        local rx = dx * c + dz * s
        local rz = -dx * s + dz * c
        return { x = point.x + rx, z = point.z + rz }
      end
      local units = {}
      -- Place launchers in a row starting at launcherStart and stepping by launcherStep
      for i=0, (launcherCount-1) do
        local dx = (tpl.launcherStart.dx or 0) + (tpl.launcherStep.dx or 0) * i
        local dz = (tpl.launcherStart.dz or 0) + (tpl.launcherStep.dz or 0) * i
        local p = off(dx, dz)
        table.insert(units, { type = tpl.launcherType, name = string.format('CTLD-%s-%d', tpl.launcherType, math.random(100000,999999)), x = p.x, y = p.z, heading = hdg })
      end
      -- Place base units at their template offsets
      for _,u in ipairs(tpl.baseUnits) do
        local p = off(u.dx or 0, u.dz or 0)
        table.insert(units, { type = u.type, name = string.format('CTLD-%s-%d', u.type, math.random(100000,999999)), x = p.x, y = p.z, heading = hdg })
      end
      return { visible=false, lateActivation=false, tasks={}, task='Ground Nothing', route={}, units=units, name=string.format('CTLD_SITE_%d', math.random(100000,999999)) }
    end

    _eventSend(self, group, nil, 'build_started', { build = def.description or recipeKey })
    -- Destroy old group, spawn new one
    local oldName = bestG:getName()
    local newLauncherCount = curLaunchers + addNum
    local center = bestInfo.center
    local headingDeg = bestInfo.headingDeg()
    if Group.getByName(oldName) then pcall(function() Group.getByName(oldName):destroy() end) end
    local gdata = buildSite({ x = center.x, z = center.z }, headingDeg, tpl.side, newLauncherCount)
    local newG = _coalitionAddGroup(tpl.side, Group.Category.GROUND, gdata)
    if not newG then _eventSend(self, group, nil, 'build_failed', { reason = 'DCS group spawn error' }); return end
    -- Consume used repair crates
    consumeCrates(recipeKey, addNum)
    _eventSend(self, nil, self.Side, 'build_success_coalition', { build = (def.description or recipeKey), player = _playerNameFromGroup(group) })
    if self.Config.BuildCooldownEnabled then CTLD._buildCooldown[gname] = now end
    return
  end

  -- Verify counts and build
  if type(def.requires) == 'table' then
    for reqKey,qty in pairs(def.requires) do if (counts[reqKey] or 0) < (qty or 0) then _eventSend(self, group, nil, 'build_insufficient_crates', { build = def.description or recipeKey }); return end end
    local gdata = def.build({ x = spawnAt.x, z = spawnAt.z }, math.deg(hdg), def.side or self.Side)
    _eventSend(self, group, nil, 'build_started', { build = def.description or recipeKey })
    local g = _coalitionAddGroup(def.side or self.Side, def.category or Group.Category.GROUND, gdata)
    if not g then _eventSend(self, group, nil, 'build_failed', { reason = 'DCS group spawn error' }); return end
    for reqKey,qty in pairs(def.requires) do consumeCrates(reqKey, qty or 0) end
    _eventSend(self, nil, self.Side, 'build_success_coalition', { build = def.description or recipeKey, player = _playerNameFromGroup(group) })
    if def.isFOB then pcall(function() self:_CreateFOBPickupZone({ x = spawnAt.x, z = spawnAt.z }, def, hdg) end) end
    -- behavior
    local behavior = opts and opts.behavior or nil
    if behavior == 'attack' and (def.canAttackMove ~= false) and self.Config.AttackAI and self.Config.AttackAI.Enabled then
      local t = self:_assignAttackBehavior(g:getName(), spawnAt, true)
      local isMetric = _getPlayerIsMetric(group:GetUnit(1))
      if t and t.kind == 'base' then
        local brg = _bearingDeg(spawnAt, t.point)
        local v, u = _fmtRange(t.dist or 0, isMetric)
        _eventSend(self, nil, self.Side, 'attack_base_announce', { unit_name = g:getName(), player = _playerNameFromGroup(group), base_name = t.name, brg = brg, rng = v, rng_u = u })
      elseif t and t.kind == 'enemy' then
        local brg = _bearingDeg(spawnAt, t.point)
        local v, u = _fmtRange(t.dist or 0, isMetric)
        _eventSend(self, nil, self.Side, 'attack_enemy_announce', { unit_name = g:getName(), player = _playerNameFromGroup(group), enemy_type = t.etype or 'unit', brg = brg, rng = v, rng_u = u })
      else
        local v, u = _fmtRange((self.Config.AttackAI and self.Config.AttackAI.VehicleSearchRadius) or 5000, isMetric)
        _eventSend(self, nil, self.Side, 'attack_no_targets', { unit_name = g:getName(), player = _playerNameFromGroup(group), rng = v, rng_u = u })
      end
    elseif behavior == 'attack' and def.canAttackMove == false then
      MESSAGE:New('This unit is static or not suited to move; it will hold position.', 8):ToGroup(group)
    end
    if self.Config.BuildCooldownEnabled then CTLD._buildCooldown[gname] = now end
    return
  else
    -- single-key
    local need = def.required or 1
    if (counts[recipeKey] or 0) < need then _eventSend(self, group, nil, 'build_insufficient_crates', { build = def.description or recipeKey }); return end
    local gdata = def.build({ x = spawnAt.x, z = spawnAt.z }, math.deg(hdg), def.side or self.Side)
    _eventSend(self, group, nil, 'build_started', { build = def.description or recipeKey })
    local g = _coalitionAddGroup(def.side or self.Side, def.category or Group.Category.GROUND, gdata)
    if not g then _eventSend(self, group, nil, 'build_failed', { reason = 'DCS group spawn error' }); return end
    consumeCrates(recipeKey, need)
    _eventSend(self, nil, self.Side, 'build_success_coalition', { build = def.description or recipeKey, player = _playerNameFromGroup(group) })
    -- behavior
    local behavior = opts and opts.behavior or nil
    if behavior == 'attack' and (def.canAttackMove ~= false) and self.Config.AttackAI and self.Config.AttackAI.Enabled then
      local t = self:_assignAttackBehavior(g:getName(), spawnAt, true)
      local isMetric = _getPlayerIsMetric(group:GetUnit(1))
      if t and t.kind == 'base' then
        local brg = _bearingDeg(spawnAt, t.point)
        local v, u = _fmtRange(t.dist or 0, isMetric)
        _eventSend(self, nil, self.Side, 'attack_base_announce', { unit_name = g:getName(), player = _playerNameFromGroup(group), base_name = t.name, brg = brg, rng = v, rng_u = u })
      elseif t and t.kind == 'enemy' then
        local brg = _bearingDeg(spawnAt, t.point)
        local v, u = _fmtRange(t.dist or 0, isMetric)
        _eventSend(self, nil, self.Side, 'attack_enemy_announce', { unit_name = g:getName(), player = _playerNameFromGroup(group), enemy_type = t.etype or 'unit', brg = brg, rng = v, rng_u = u })
      else
        local v, u = _fmtRange((self.Config.AttackAI and self.Config.AttackAI.VehicleSearchRadius) or 5000, isMetric)
        _eventSend(self, nil, self.Side, 'attack_no_targets', { unit_name = g:getName(), player = _playerNameFromGroup(group), rng = v, rng_u = u })
      end
    elseif behavior == 'attack' and def.canAttackMove == false then
      MESSAGE:New('This unit is static or not suited to move; it will hold position.', 8):ToGroup(group)
    end
    if self.Config.BuildCooldownEnabled then CTLD._buildCooldown[gname] = now end
    return
  end
end

function CTLD:BuildCoalitionMenus(root)
  -- Optional: implement coalition-level crate spawns at pickup zones
  for key,_ in pairs(self.Config.CrateCatalog) do
    MENU_COALITION_COMMAND:New(self.Side, 'Spawn '..key..' at nearest Pickup Zone', root, function()
      -- Not group-context; skip here
      _msgCoalition(self.Side, 'Group menus recommended for crate requests')
    end)
  end
end

function CTLD:InitCoalitionAdminMenu()
  if self.AdminMenu then return end
  -- Ensure we have a coalition-level CTLD parent menu to nest Admin/Help under
  local rootCaption = (self.Config and self.Config.UseGroupMenus) and 'CTLD Admin' or 'CTLD'
  self.MenuRoot = self.MenuRoot or MENU_COALITION:New(self.Side, rootCaption)
  local root = MENU_COALITION:New(self.Side, 'Admin/Help', self.MenuRoot)
  MENU_COALITION_COMMAND:New(self.Side, 'Enable CTLD Debug Logging', root, function()
    self.Config.Debug = true
    env.info(string.format('[Moose_CTLD][%s] Debug ENABLED via Admin menu', tostring(self.Side)))
    _msgCoalition(self.Side, 'CTLD Debug logging ENABLED', 8)
  end)
  MENU_COALITION_COMMAND:New(self.Side, 'Disable CTLD Debug Logging', root, function()
    self.Config.Debug = false
    env.info(string.format('[Moose_CTLD][%s] Debug DISABLED via Admin menu', tostring(self.Side)))
    _msgCoalition(self.Side, 'CTLD Debug logging DISABLED', 8)
  end)
  MENU_COALITION_COMMAND:New(self.Side, 'Show CTLD Status (crates/zones)', root, function()
    local crates = 0
    for _ in pairs(CTLD._crates) do crates = crates + 1 end
    local msg = string.format('CTLD Status:\nActive crates: %d\nPickup zones: %d\nDrop zones: %d\nFOB zones: %d\nBuild Confirm: %s (%ds window)\nBuild Cooldown: %s (%ds)'
      , crates, #(self.PickupZones or {}), #(self.DropZones or {}), #(self.FOBZones or {})
      , self.Config.BuildConfirmEnabled and 'ON' or 'OFF', self.Config.BuildConfirmWindowSeconds or 0
      , self.Config.BuildCooldownEnabled and 'ON' or 'OFF', self.Config.BuildCooldownSeconds or 0)
    _msgCoalition(self.Side, msg, 20)
  end)
  MENU_COALITION_COMMAND:New(self.Side, 'Show Coalition Summary', root, function()
    self:ShowCoalitionSummary()
  end)
  MENU_COALITION_COMMAND:New(self.Side, 'Draw CTLD Zones on Map', root, function()
    self:DrawZonesOnMap()
    _msgCoalition(self.Side, 'CTLD zones drawn on F10 map.', 8)
  end)
  MENU_COALITION_COMMAND:New(self.Side, 'Clear CTLD Map Drawings', root, function()
    self:ClearMapDrawings()
    _msgCoalition(self.Side, 'CTLD map drawings cleared.', 8)
  end)
  self.AdminMenu = root
end
-- #endregion Menus

-- =========================
-- Coalition Summary
-- =========================
function CTLD:ShowCoalitionSummary()
  -- Crate counts per type (this coalition)
  local perType = {}
  local total = 0
  for _,meta in pairs(CTLD._crates) do
    if meta.side == self.Side then
      perType[meta.key] = (perType[meta.key] or 0) + 1
      total = total + 1
    end
  end
  local lines = {}
  table.insert(lines, string.format('CTLD Coalition Summary (%s)', (self.Side==coalition.side.BLUE and 'BLUE') or (self.Side==coalition.side.RED and 'RED') or 'NEUTRAL'))
  -- Crate timeout information first (lifetime is in seconds; 0 disables cleanup)
  local lifeSec = tonumber(self.Config.CrateLifetime or 0) or 0
  if lifeSec > 0 then
    local mins = math.floor((lifeSec + 30) / 60)
    table.insert(lines, string.format('Crate Timeout: %d mins (Crates will despawn to prevent clutter)', mins))
  else
    table.insert(lines, 'Crate Timeout: Disabled')
  end
  table.insert(lines, string.format('Active crates: %d', total))
  if next(perType) then
    table.insert(lines, 'Crates by type:')
    -- stable order: sort keys alphabetically
    local keys = {}
    for k,_ in pairs(perType) do table.insert(keys, k) end
    table.sort(keys)
    for _,k in ipairs(keys) do
      table.insert(lines, string.format('  %s: %d', k, perType[k]))
    end
  else
    table.insert(lines, 'Crates by type: (none)')
  end

  -- Nearby buildable recipes for each active player
  table.insert(lines, '\nBuildable near players:')
  local players = coalition.getPlayers(self.Side) or {}
  if #players == 0 then
    table.insert(lines, '  (no active players)')
  else
    for _,u in ipairs(players) do
      local g = u:getGroup()
      local gname = g and g:getName() or u:getName() or 'Group'
      local pos = u:getPoint()
      local here = { x = pos.x, z = pos.z }
      local radius = self.Config.BuildRadius or 60
      local nearby = self:GetNearbyCrates(here, radius)
      local counts = {}
      for _,c in ipairs(nearby) do if c.meta.side == self.Side then counts[c.meta.key] = (counts[c.meta.key] or 0) + 1 end end
      -- include carried crates if allowed
      if self.Config.BuildRequiresGroundCrates ~= true then
        local lc = CTLD._loadedCrates[gname]
        if lc and lc.byKey then for k,v in pairs(lc.byKey) do counts[k] = (counts[k] or 0) + v end end
      end
      local insideFOB, _ = self:IsPointInFOBZones(here)
      local buildable = {}
      -- composite recipes first
      for recipeKey,cat in pairs(self.Config.CrateCatalog) do
        if type(cat.requires) == 'table' and cat.build then
          if not (cat.isFOB and self.Config.RestrictFOBToZones and not insideFOB) then
            local ok = true
            for reqKey,qty in pairs(cat.requires) do if (counts[reqKey] or 0) < qty then ok = false; break end end
            if ok then table.insert(buildable, cat.description or recipeKey) end
          end
        end
      end
      -- single-key
      for key,cat in pairs(self.Config.CrateCatalog) do
        if cat and cat.build and (not cat.requires) then
          if not (cat.isFOB and self.Config.RestrictFOBToZones and not insideFOB) then
            if (counts[key] or 0) >= (cat.required or 1) then table.insert(buildable, cat.description or key) end
          end
        end
      end
      if #buildable == 0 then
        table.insert(lines, string.format('  %s: none', gname))
      else
        -- limit to keep message short
        local maxShow = 6
        local shown = {}
        for i=1, math.min(#buildable, maxShow) do table.insert(shown, buildable[i]) end
        local suffix = (#buildable > maxShow) and string.format(' (+%d more)', #buildable - maxShow) or ''
        table.insert(lines, string.format('  %s: %s%s', gname, table.concat(shown, ', '), suffix))
      end
    end
  end

  -- Quick help card
  table.insert(lines, '\nQuick Help:')
  table.insert(lines, '- Request crates: CTLD → Request Crate (near Pickup Zones).')
  table.insert(lines, '- Build: double-press "Build Here" within '..tostring(self.Config.BuildConfirmWindowSeconds or 10)..'s; cooldown '..tostring(self.Config.BuildCooldownSeconds or 60)..'s per group.')
  table.insert(lines, '- Hover Coach: CTLD → Coach & Nav → Enable/Disable; vectors to crates/zones available.')
  table.insert(lines, '- Manage crates: Drop One/All from CTLD menu; build consumes nearby crates.')

  _msgCoalition(self.Side, table.concat(lines, '\n'), 25)
end

-- =========================
-- Crates
-- =========================
-- #region Crates
function CTLD:RequestCrateForGroup(group, crateKey)
  local cat = self.Config.CrateCatalog[crateKey]
  if not cat then _msgGroup(group, 'Unknown crate type: '..tostring(crateKey)) return end
  local unit = group:GetUnit(1)
  if not unit or not unit:IsAlive() then return end
  local function _activePickupDefs()
    local defs, out = self.Config.Zones.PickupZones or {}, {}
    for _,z in ipairs(defs) do
      local n = z.name
      if (not n) or self._ZoneActive.Pickup[n] ~= false then table.insert(out, z) end
    end
    return out
  end
  local zone, dist = _nearestZonePoint(unit, _activePickupDefs())
  local hasPickupZones = ((self.PickupZones and #self.PickupZones > 0) or (self.Config.Zones and self.Config.Zones.PickupZones and #self.Config.Zones.PickupZones > 0))
                          and (next(self._ZoneActive.Pickup) ~= nil)
  local spawnPoint
  local maxd = (self.Config.PickupZoneMaxDistance or 10000)
  -- Announce request
  local zoneName = zone and zone:GetName() or (hasPickupZones and 'nearest zone' or 'NO PICKUP ZONES CONFIGURED')
  _eventSend(self, group, nil, 'crate_spawn_requested', { type = tostring(crateKey), zone = zoneName })

  if not hasPickupZones and self.Config.RequirePickupZoneForCrateRequest then
    _eventSend(self, group, nil, 'no_pickup_zones', {})
    return
  end

  if zone and dist <= maxd then
    -- Compute a random spawn point within the pickup zone to avoid stacking crates
    local center = zone:GetPointVec3()
    local rZone = self:_getZoneRadius(zone)
    local edgeBuf = math.max(0, self.Config.PickupZoneSpawnEdgeBuffer or 10)
    local minOff = math.max(0, self.Config.PickupZoneSpawnMinOffset or 5)
    local rMax = math.max(0, (rZone or 150) - edgeBuf)
    local tries = math.max(1, self.Config.CrateSpawnSeparationTries or 6)
    local minSep = math.max(0, self.Config.CrateSpawnMinSeparation or 7)

    local function candidate()
      if (self.Config.PickupZoneSpawnRandomize == false) or rMax <= 0 then
        return { x = center.x, z = center.z }
      end
      local rr
      if rMax > minOff then
        rr = minOff + math.sqrt(math.random()) * (rMax - minOff)
      else
        rr = rMax
      end
      local th = math.random() * 2 * math.pi
      return { x = center.x + rr * math.cos(th), z = center.z + rr * math.sin(th) }
    end

    local function isClear(pt)
      if minSep <= 0 then return true end
      for _,meta in pairs(CTLD._crates) do
        if meta and meta.side == self.Side and meta.point then
          local dx = (meta.point.x - pt.x)
          local dz = (meta.point.z - pt.z)
          if (dx*dx + dz*dz) < (minSep*minSep) then return false end
        end
      end
      return true
    end

    local chosen = candidate()
    if not isClear(chosen) then
      for _=1,tries-1 do
        local c = candidate()
        if isClear(c) then chosen = c; break end
      end
    end
    spawnPoint = { x = chosen.x, z = chosen.z }
    -- if pickup zone has smoke configured, mark the spawn location
    local zdef = self._ZoneDefs.PickupZones[zone:GetName()]
    local smokeColor = (zdef and zdef.smoke) or self.Config.PickupZoneSmokeColor
    if smokeColor then
      trigger.action.smoke({ x = spawnPoint.x, z = spawnPoint.z }, smokeColor)
    end
  else
    -- Either require a pickup zone proximity, or fallback to near-aircraft spawn (legacy behavior)
    if self.Config.RequirePickupZoneForCrateRequest then
      local isMetric = _getPlayerIsMetric(unit)
      local v, u = _fmtRange(math.max(0, dist - maxd), isMetric)
      local brg = 0
      if zone then
        local up = unit:GetPointVec3(); local zp = zone:GetPointVec3()
        brg = _bearingDeg({x=up.x,z=up.z}, {x=zp.x,z=zp.z})
      end
      _eventSend(self, group, nil, 'pickup_zone_required', { zone_dist = v, zone_dist_u = u, zone_brg = brg })
      return
    else
      -- fallback: spawn near aircraft current position (safe offset)
      local p = unit:GetPointVec3()
      spawnPoint = POINT_VEC3:New(p.x + 10, p.y, p.z + 10)
    end
  end
  -- Enforce per-location inventory before spawning
  local zoneNameForStock = zone and zone:GetName() or nil
  if self.Config.Inventory and self.Config.Inventory.Enabled then
    if not zoneNameForStock then
      _msgGroup(group, 'Crate requests must be at a Supply Zone for stock control.')
      return
    end
    CTLD._stockByZone[zoneNameForStock] = CTLD._stockByZone[zoneNameForStock] or {}
    local cur = tonumber(CTLD._stockByZone[zoneNameForStock][crateKey] or 0) or 0
    if cur <= 0 then
      _msgGroup(group, string.format('Out of stock at %s for %s', zoneNameForStock, self:_friendlyNameForKey(crateKey)))
      return
    end
    CTLD._stockByZone[zoneNameForStock][crateKey] = cur - 1
  end

  local cname = string.format('CTLD_CRATE_%s_%d', crateKey, math.random(100000,999999))
  _spawnStaticCargo(self.Side, { x = spawnPoint.x, z = spawnPoint.z }, cat.dcsCargoType or 'uh1h_cargo', cname)
  CTLD._crates[cname] = {
    key = crateKey,
    side = self.Side,
    spawnTime = timer.getTime(),
    point = { x = spawnPoint.x, z = spawnPoint.z },
    requester = group:GetName(),
  }
  -- Immersive spawn message with bearing/range per player units
  do
    local unitPos = unit:GetPointVec3()
    local from = { x = unitPos.x, z = unitPos.z }
    local to = { x = spawnPoint.x, z = spawnPoint.z }
    local brg = _bearingDeg(from, to)
  local isMetric = _getPlayerIsMetric(unit)
  local rngMeters = math.sqrt(((to.x-from.x)^2)+((to.z-from.z)^2))
  local rngV, rngU = _fmtRange(rngMeters, isMetric)
    local data = {
      id = cname,
      type = tostring(crateKey),
      brg = brg,
      rng = rngV,
      rng_u = rngU,
    }
    _eventSend(self, group, nil, 'crate_spawned', data)
  end
end

function CTLD:GetNearbyCrates(point, radius)
  local result = {}
  for name,meta in pairs(CTLD._crates) do
    local dx = (meta.point.x - point.x)
    local dz = (meta.point.z - point.z)
    local d = math.sqrt(dx*dx + dz*dz)
    if d <= radius then
      table.insert(result, { name = name, meta = meta })
    end
  end
  return result
end

function CTLD:CleanupCrates()
  local now = timer.getTime()
  local life = self.Config.CrateLifetime
  for name,meta in pairs(CTLD._crates) do
    if now - (meta.spawnTime or now) > life then
      local obj = StaticObject.getByName(name)
      if obj then obj:destroy() end
      CTLD._crates[name] = nil
      if self.Config.Debug then env.info('[CTLD] Cleaned up crate '..name) end
      -- Notify requester group if still around; else coalition
      local gname = meta.requester
      local group = gname and GROUP:FindByName(gname) or nil
      if group and group:IsAlive() then
        _eventSend(self, group, nil, 'crate_expired', { id = name })
      else
        _eventSend(self, nil, self.Side, 'crate_expired', { id = name })
      end
    end
  end
end
-- #endregion Crates

-- =========================
-- Build logic
-- =========================
-- #region Build logic
function CTLD:BuildAtGroup(group, opts)
  local unit = group:GetUnit(1)
  if not unit or not unit:IsAlive() then return end
  -- Build cooldown/confirmation guardrails
  local now = timer.getTime()
  local gname = group:GetName()
  if self.Config.BuildCooldownEnabled then
    local last = CTLD._buildCooldown[gname]
    if last and (now - last) < (self.Config.BuildCooldownSeconds or 60) then
      local rem = math.max(0, math.ceil((self.Config.BuildCooldownSeconds or 60) - (now - last)))
      _msgGroup(group, string.format('Build on cooldown. Try again in %ds.', rem))
      return
    end
  end
  if self.Config.BuildConfirmEnabled then
    local first = CTLD._buildConfirm[gname]
    local win = self.Config.BuildConfirmWindowSeconds or 10
    if not first or (now - first) > win then
      CTLD._buildConfirm[gname] = now
      _msgGroup(group, string.format('Confirm build: select "Build Here" again within %ds to proceed.', win))
      return
    else
      -- within window; proceed and clear pending
      CTLD._buildConfirm[gname] = nil
    end
  end
  local p = unit:GetPointVec3()
  local here = { x = p.x, z = p.z }
  -- Compute a safe spawn point offset forward from the aircraft to prevent rotor/ground collisions with spawned units
  local hdg = unit:GetHeading() or 0
  local buildOffset = math.max(0, tonumber(self.Config.BuildSpawnOffset or 0) or 0)
  local spawnAt = (buildOffset > 0) and { x = here.x + math.sin(hdg) * buildOffset, z = here.z + math.cos(hdg) * buildOffset } or { x = here.x, z = here.z }
  local radius = self.Config.BuildRadius
  local nearby = self:GetNearbyCrates(here, radius)
  -- filter crates to coalition side for this CTLD instance
  local filtered = {}
  for _,c in ipairs(nearby) do
    if c.meta.side == self.Side then table.insert(filtered, c) end
  end
  nearby = filtered
  if #nearby == 0 then
    _eventSend(self, group, nil, 'build_insufficient_crates', { build = 'asset' })
    -- Nudge players to use Recipe Info
    _msgGroup(group, 'Tip: Use CTLD → Recipe Info to see exact crate requirements for each build.')
    return
  end

  -- Count by key
  local counts = {}
  for _,c in ipairs(nearby) do
    counts[c.meta.key] = (counts[c.meta.key] or 0) + 1
  end

  -- Include loaded crates carried by this group
  local carried = CTLD._loadedCrates[gname]
  if self.Config.BuildRequiresGroundCrates ~= true then
    if carried and carried.byKey then
      for k,v in pairs(carried.byKey) do
        counts[k] = (counts[k] or 0) + v
      end
    end
  end

  -- Helper to consume crates of a given key/qty
  local function consumeCrates(key, qty)
    local removed = 0
    -- Optionally consume from carried crates
    if self.Config.BuildRequiresGroundCrates ~= true then
      if carried and carried.byKey and (carried.byKey[key] or 0) > 0 then
        local take = math.min(qty, carried.byKey[key])
        carried.byKey[key] = carried.byKey[key] - take
        if carried.byKey[key] <= 0 then carried.byKey[key] = nil end
        carried.total = math.max(0, (carried.total or 0) - take)
        removed = removed + take
      end
    end
    for _,c in ipairs(nearby) do
      if removed >= qty then break end
      if c.meta.key == key then
        local obj = StaticObject.getByName(c.name)
        if obj then obj:destroy() end
        CTLD._crates[c.name] = nil
        removed = removed + 1
      end
    end
  end

  local insideFOBZone, fz = self:IsPointInFOBZones(here)
  local fobBlocked = false
  -- Try composite recipes first (requires is a map of key->qty)
  for recipeKey,cat in pairs(self.Config.CrateCatalog) do
    if type(cat.requires) == 'table' and cat.build then
      if cat.isFOB and self.Config.RestrictFOBToZones and not insideFOBZone then
        fobBlocked = true
      else
        -- Build caps disabled: rely solely on inventory/catalog control
        local ok = true
        for reqKey,qty in pairs(cat.requires) do
          if (counts[reqKey] or 0) < qty then ok = false; break end
        end
        if ok then
          local gdata = cat.build({ x = spawnAt.x, z = spawnAt.z }, math.deg(hdg), cat.side or self.Side)
          _eventSend(self, group, nil, 'build_started', { build = cat.description or recipeKey })
          local g = _coalitionAddGroup(cat.side or self.Side, cat.category or Group.Category.GROUND, gdata)
          if g then
            for reqKey,qty in pairs(cat.requires) do consumeCrates(reqKey, qty) end
            -- No site cap counters when caps are disabled
            _eventSend(self, nil, self.Side, 'build_success_coalition', { build = cat.description or recipeKey, player = _playerNameFromGroup(group) })
            -- If this was a FOB, register a new pickup zone with reduced stock
            if cat.isFOB then
              pcall(function()
                self:_CreateFOBPickupZone({ x = spawnAt.x, z = spawnAt.z }, cat, hdg)
              end)
            end
            -- Assign optional behavior for built vehicles/groups
            local behavior = opts and opts.behavior or nil
            if behavior == 'attack' and self.Config.AttackAI and self.Config.AttackAI.Enabled then
              local t = self:_assignAttackBehavior(g:getName(), spawnAt, true)
              local isMetric = _getPlayerIsMetric(group:GetUnit(1))
              if t and t.kind == 'base' then
                local brg = _bearingDeg({ x = spawnAt.x, z = spawnAt.z }, { x = t.point.x, z = t.point.z })
                local v, u = _fmtRange(t.dist or 0, isMetric)
                _eventSend(self, nil, self.Side, 'attack_base_announce', { unit_name = g:getName(), player = _playerNameFromGroup(group), base_name = t.name, brg = brg, rng = v, rng_u = u })
              elseif t and t.kind == 'enemy' then
                local brg = _bearingDeg({ x = spawnAt.x, z = spawnAt.z }, { x = t.point.x, z = t.point.z })
                local v, u = _fmtRange(t.dist or 0, isMetric)
                _eventSend(self, nil, self.Side, 'attack_enemy_announce', { unit_name = g:getName(), player = _playerNameFromGroup(group), enemy_type = t.etype or 'unit', brg = brg, rng = v, rng_u = u })
              else
                local v, u = _fmtRange((self.Config.AttackAI and self.Config.AttackAI.VehicleSearchRadius) or 5000, isMetric)
                _eventSend(self, nil, self.Side, 'attack_no_targets', { unit_name = g:getName(), player = _playerNameFromGroup(group), rng = v, rng_u = u })
              end
            end
            if self.Config.BuildCooldownEnabled then CTLD._buildCooldown[gname] = now end
            return
          else
            _eventSend(self, group, nil, 'build_failed', { reason = 'DCS group spawn error' })
            return
          end
        end
  -- continue_composite (Lua 5.1 compatible: no labels)
      end
    end
  end

  -- Then single-key recipes
  for key,count in pairs(counts) do
    local cat = self.Config.CrateCatalog[key]
    if cat and cat.build and (not cat.requires) and count >= (cat.required or 1) then
      if cat.isFOB and self.Config.RestrictFOBToZones and not insideFOBZone then
        fobBlocked = true
      else
        -- Build caps disabled: rely solely on inventory/catalog control
        local gdata = cat.build({ x = spawnAt.x, z = spawnAt.z }, math.deg(hdg), cat.side or self.Side)
        _eventSend(self, group, nil, 'build_started', { build = cat.description or key })
        local g = _coalitionAddGroup(cat.side or self.Side, cat.category or Group.Category.GROUND, gdata)
        if g then
          consumeCrates(key, cat.required or 1)
          -- No single-unit cap counters when caps are disabled
          _eventSend(self, nil, self.Side, 'build_success_coalition', { build = cat.description or key, player = _playerNameFromGroup(group) })
          -- Assign optional behavior for built vehicles/groups
          local behavior = opts and opts.behavior or nil
          if behavior == 'attack' and self.Config.AttackAI and self.Config.AttackAI.Enabled then
            local t = self:_assignAttackBehavior(g:getName(), spawnAt, true)
            local isMetric = _getPlayerIsMetric(group:GetUnit(1))
            if t and t.kind == 'base' then
              local brg = _bearingDeg({ x = spawnAt.x, z = spawnAt.z }, { x = t.point.x, z = t.point.z })
              local v, u = _fmtRange(t.dist or 0, isMetric)
              _eventSend(self, nil, self.Side, 'attack_base_announce', { unit_name = g:getName(), player = _playerNameFromGroup(group), base_name = t.name, brg = brg, rng = v, rng_u = u })
            elseif t and t.kind == 'enemy' then
              local brg = _bearingDeg({ x = spawnAt.x, z = spawnAt.z }, { x = t.point.x, z = t.point.z })
              local v, u = _fmtRange(t.dist or 0, isMetric)
              _eventSend(self, nil, self.Side, 'attack_enemy_announce', { unit_name = g:getName(), player = _playerNameFromGroup(group), enemy_type = t.etype or 'unit', brg = brg, rng = v, rng_u = u })
            else
              local v, u = _fmtRange((self.Config.AttackAI and self.Config.AttackAI.VehicleSearchRadius) or 5000, isMetric)
              _eventSend(self, nil, self.Side, 'attack_no_targets', { unit_name = g:getName(), player = _playerNameFromGroup(group), rng = v, rng_u = u })
            end
          end
          if self.Config.BuildCooldownEnabled then CTLD._buildCooldown[gname] = now end
          return
        else
          _eventSend(self, group, nil, 'build_failed', { reason = 'DCS group spawn error' })
          return
        end
      end
    end
  -- continue_single (Lua 5.1 compatible: no labels)
  end

  if fobBlocked then
    _eventSend(self, group, nil, 'fob_restricted', {})
    return
  end

  -- Helpful hint if building requires ground crates and player is carrying crates
  if self.Config.BuildRequiresGroundCrates == true then
    local carried = CTLD._loadedCrates[gname]
    if carried and (carried.total or 0) > 0 then
      _eventSend(self, group, nil, 'build_requires_ground', { total = carried.total })
      return
    end
  end
  _eventSend(self, group, nil, 'build_insufficient_crates', { build = 'asset' })
  -- Provide a short breakdown of most likely recipes and what is missing
  local suggestions = {}
  local function pushSuggestion(name, missingStr, haveParts, totalParts)
    table.insert(suggestions, { name = name, miss = missingStr, have = haveParts, total = totalParts })
  end
  -- consider composite recipes with at least one matching component nearby
  for rkey,cat in pairs(self.Config.CrateCatalog) do
    if type(cat.requires) == 'table' then
      local have, total, missingList = 0, 0, {}
      for reqKey,qty in pairs(cat.requires) do
        total = total + (qty or 0)
        local haveHere = math.min(qty or 0, counts[reqKey] or 0)
        have = have + haveHere
        local need = math.max(0, (qty or 0) - (counts[reqKey] or 0))
        if need > 0 then
          local fname = self:_friendlyNameForKey(reqKey)
          table.insert(missingList, string.format('%dx %s', need, fname))
        end
      end
      if have > 0 and have < total then
        local name = cat.description or cat.menu or rkey
        pushSuggestion(name, table.concat(missingList, ', '), have, total)
      end
    else
      -- single-key recipe: if some crates present but not enough
      local need = (cat and (cat.required or 1)) or 1
      local have = counts[rkey] or 0
      if have > 0 and have < need then
        local name = cat.description or cat.menu or rkey
        pushSuggestion(name, string.format('%d more crate(s) of %s', need - have, self:_friendlyNameForKey(rkey)), have, need)
      end
    end
  end
  table.sort(suggestions, function(a,b)
    local ra = (a.total > 0) and (a.have / a.total) or 0
    local rb = (b.total > 0) and (b.have / b.total) or 0
    if ra == rb then return (a.total - a.have) < (b.total - b.have) end
    return ra > rb
  end)
  if #suggestions > 0 then
    local maxShow = math.min(2, #suggestions)
    for i=1,maxShow do
      local s = suggestions[i]
      _msgGroup(group, string.format('Missing for %s: %s', s.name, s.miss))
    end
  else
    _msgGroup(group, 'No matching recipe found with nearby crates. Check Recipe Info for requirements.')
  end
end
-- #endregion Build logic

-- =========================
-- Loaded crate management
-- =========================
-- #region Loaded crate management
function CTLD:_addLoadedCrate(group, crateKey)
  local gname = group:GetName()
  CTLD._loadedCrates[gname] = CTLD._loadedCrates[gname] or { total = 0, byKey = {} }
  local lc = CTLD._loadedCrates[gname]
  lc.total = lc.total + 1
  lc.byKey[crateKey] = (lc.byKey[crateKey] or 0) + 1
end

function CTLD:DropLoadedCrates(group, howMany)
  local gname = group:GetName()
  local lc = CTLD._loadedCrates[gname]
  if not lc or (lc.total or 0) == 0 then _eventSend(self, group, nil, 'no_loaded_crates', {}) return end
  local unit = group:GetUnit(1)
  if not unit or not unit:IsAlive() then return end
  local p = unit:GetPointVec3()
  local here = { x = p.x, z = p.z }
  local initialTotal = lc.total or 0
  local requested = (howMany and howMany > 0) and howMany or initialTotal
  local toDrop = math.min(requested, initialTotal)
  _eventSend(self, group, nil, 'drop_initiated', { count = toDrop })
  -- Warn about crate timeout when dropping
  local lifeSec = tonumber(self.Config.CrateLifetime or 0) or 0
  if lifeSec > 0 then
    local mins = math.floor((lifeSec + 30) / 60)
    _msgGroup(group, string.format('Note: Crates will despawn after %d mins to prevent clutter.', mins))
  end
  -- Drop in key order
  for k,count in pairs(DeepCopy(lc.byKey)) do
    if toDrop <= 0 then break end
    local dropNow = math.min(count, toDrop)
    for i=1,dropNow do
      local cname = string.format('CTLD_CRATE_%s_%d', k, math.random(100000,999999))
      local cat = self.Config.CrateCatalog[k]
      _spawnStaticCargo(self.Side, here, (cat and cat.dcsCargoType) or 'uh1h_cargo', cname)
      CTLD._crates[cname] = { key = k, side = self.Side, spawnTime = timer.getTime(), point = { x = here.x, z = here.z } }
      lc.byKey[k] = lc.byKey[k] - 1
      if lc.byKey[k] <= 0 then lc.byKey[k] = nil end
      lc.total = lc.total - 1
      toDrop = toDrop - 1
      if toDrop <= 0 then break end
    end
  end
  local actualDropped = initialTotal - (lc.total or 0)
  _eventSend(self, group, nil, 'dropped_crates', { count = actualDropped })
  -- Reiterate timeout after drop completes (players may miss the initial warning)
  if lifeSec > 0 then
    local mins = math.floor((lifeSec + 30) / 60)
    _msgGroup(group, string.format('Reminder: Dropped crates will despawn after %d mins to prevent clutter.', mins))
  end
end
-- #endregion Loaded crate management

-- =========================
-- Hover pickup scanner
-- =========================
-- #region Hover pickup scanner
function CTLD:ScanHoverPickup()
  local hp = self.Config.HoverPickup or {}
  if not hp.Enabled then return end
  local coachCfg = CTLD.HoverCoachConfig or { enabled = false }
  -- iterate all groups that have menus (active transports)
  for gname,_ in pairs(self.MenusByGroup or {}) do
    local group = GROUP:FindByName(gname)
    if group and group:IsAlive() then
      local unit = group:GetUnit(1)
      if unit and unit:IsAlive() then
        -- Allowed type check
        local typ = _getUnitType(unit)
        if _isIn(self.Config.AllowedAircraft, typ) then
          local uname = unit:GetName()
          local now = timer.getTime()
          local p3 = unit:GetPointVec3()
          local ground = land and land.getHeight and land.getHeight({ x = p3.x, y = p3.z }) or 0
          local agl = math.max(0, p3.y - ground)
          -- speeds (ground/vertical)
          local last = CTLD._unitLast[uname]
          local gs, vs = 0, 0
          if last and (now > (last.t or 0)) then
            local dt = now - last.t
            if dt > 0 then
              local dx = (p3.x - last.x)
              local dz = (p3.z - last.z)
              gs = math.sqrt(dx*dx + dz*dz) / dt
              if last.agl then vs = (agl - last.agl) / dt end
            end
          end
          CTLD._unitLast[uname] = { x = p3.x, z = p3.z, t = now, agl = agl }

          -- find nearest crate within search distance
          local bestName, bestMeta, bestd
          local maxd = hp.AutoPickupDistance or hp.Radius or 25
          for name,meta in pairs(CTLD._crates) do
            if meta.side == self.Side then
              local dx = (meta.point.x - p3.x)
              local dz = (meta.point.z - p3.z)
              local d = math.sqrt(dx*dx + dz*dz)
              if d <= maxd and ((not bestd) or d < bestd) then
                bestName, bestMeta, bestd = name, meta, d
              end
            end
          end

          -- Resolve per-group coach enable override
          local coachEnabled = coachCfg.enabled
          if CTLD._coachOverride and CTLD._coachOverride[gname] ~= nil then
            coachEnabled = CTLD._coachOverride[gname]
          end
          -- If coach is on, provide phased guidance
          if coachEnabled and bestName and bestMeta then
            local isMetric = _getPlayerIsMetric(unit)
            -- Arrival phase
            if bestd <= (coachCfg.thresholds.arrivalDist or 1000) then
              _coachSend(self, group, uname, 'coach_arrival', {}, false)
            end
            -- Close-in
            if bestd <= (coachCfg.thresholds.closeDist or 100) then
              _coachSend(self, group, uname, 'coach_close', {}, false)
            end

            -- Precision phase
            if bestd <= (coachCfg.thresholds.precisionDist or 30) then
              local hdg = unit:GetHeading() or 0
              local dx = (bestMeta.point.x - p3.x)
              local dz = (bestMeta.point.z - p3.z)
              local right, fwd = _projectToBodyFrame(dx, dz, hdg)

              -- Horizontal hint formatting
              local function hintDir(val, posWord, negWord, toUnits)
                local mag = math.abs(val)
                local v, u = _fmtDistance(mag, isMetric)
                if mag < 0.5 then return nil end
                return string.format("%s %d %s", (val >= 0 and posWord or negWord), v, u)
              end
              local h = {}
              local rHint = hintDir(right, 'Right', 'Left')
              local fHint = hintDir(fwd, 'Forward', 'Back')
              if rHint then table.insert(h, rHint) end
              if fHint then table.insert(h, fHint) end

              -- Vertical hint against AGL window
              local vHint
              local aglMin = coachCfg.thresholds.aglMin or 5
              local aglMax = coachCfg.thresholds.aglMax or 20
              if agl < aglMin then
                local dv, du = _fmtAGL(aglMin - agl, isMetric)
                vHint = string.format("Up %d %s", dv, du)
              elseif agl > aglMax then
                local dv, du = _fmtAGL(agl - aglMax, isMetric)
                vHint = string.format("Down %d %s", dv, du)
              end
              if vHint then table.insert(h, vHint) end

              local hints = table.concat(h, ", ")
              local gsV, gsU = _fmtSpeed(gs, isMetric)
              local data = { hints = (hints ~= '' and (hints..'.') or ''), gs = gsV, gs_u = gsU }

              _coachSend(self, group, uname, 'coach_hint', data, true)

              -- Error prompts (dominant one)
              local maxGS = coachCfg.thresholds.maxGS or (8/3.6)
              local aglMinT = aglMin
              local aglMaxT = aglMax
              if gs > maxGS then
                local v, u = _fmtSpeed(gs, isMetric)
                _coachSend(self, group, uname, 'coach_too_fast', { gs = v, gs_u = u }, false)
              elseif agl > aglMaxT then
                local v, u = _fmtAGL(agl, isMetric)
                _coachSend(self, group, uname, 'coach_too_high', { agl = v, agl_u = u }, false)
              elseif agl < aglMinT then
                local v, u = _fmtAGL(agl, isMetric)
                _coachSend(self, group, uname, 'coach_too_low', { agl = v, agl_u = u }, false)
              end
            end
          end

          -- Auto-load logic using capture thresholds (coach or legacy)
          local speedOK, heightOK
          if coachCfg.enabled then
            local capGS = coachCfg.thresholds.captureGS or (4/3.6)
            local aglMin = coachCfg.thresholds.aglMin or 5
            local aglMax = coachCfg.thresholds.aglMax or 20
            speedOK = gs <= capGS
            heightOK = (agl >= aglMin and agl <= aglMax)
          else
            speedOK = (not hp.RequireLowSpeed) or (gs <= (hp.MaxSpeedMPS or 5))
            heightOK = agl <= (hp.Height or 3)
          end

          if bestName and bestMeta and speedOK and heightOK then
            local withinRadius
            if coachCfg.enabled then
              withinRadius = bestd <= (coachCfg.thresholds.captureHoriz or 2)
            else
              withinRadius = bestd <= (hp.Radius or hp.AutoPickupDistance or 25)
            end

            if withinRadius then
              local carried = CTLD._loadedCrates[gname]
              local total = carried and carried.total or 0
              if total < (hp.MaxCratesPerLoad or 6) then
                local hs = CTLD._hoverState[uname]
                if not hs or hs.targetCrate ~= bestName then
                  CTLD._hoverState[uname] = { targetCrate = bestName, startTime = now }
                  if coachCfg.enabled then _coachSend(self, group, uname, 'coach_hold', {}, false) end
                else
                  -- stability hold timer
                  local holdNeeded = coachCfg.enabled and (coachCfg.thresholds.stabilityHold or (hp.Duration or 3)) or (hp.Duration or 3)
                  if (now - hs.startTime) >= holdNeeded then
                    -- load it
                    local obj = StaticObject.getByName(bestName)
                    if obj then obj:destroy() end
                    CTLD._crates[bestName] = nil
                    self:_addLoadedCrate(group, bestMeta.key)
                    if coachEnabled then
                      _coachSend(self, group, uname, 'coach_loaded', {}, false)
                    else
                      _msgGroup(group, string.format('Loaded %s crate', tostring(bestMeta.key)))
                    end
                    CTLD._hoverState[uname] = nil
                  end
                end
              end
            else
              -- lost precision window
              if coachEnabled then _coachSend(self, group, uname, 'coach_hover_lost', {}, false) end
              CTLD._hoverState[uname] = nil
            end
          else
            -- reset hover state when outside primary envelope
            if CTLD._hoverState[uname] then
              if coachEnabled then _coachSend(self, group, uname, 'coach_abort', {}, false) end
            end
            CTLD._hoverState[uname] = nil
          end
        end
      end
    end
  end
end
-- #endregion Hover pickup scanner

-- =========================
-- Troops
-- =========================
-- #region Troops
function CTLD:LoadTroops(group, opts)
  local gname = group:GetName()
  local unit = group:GetUnit(1)
  if not unit or not unit:IsAlive() then return end

  -- Enforce pickup zone requirement for troop loading (inside zone)
  if self.Config.RequirePickupZoneForTroopLoad then
    local hasPickupZones = (self.PickupZones and #self.PickupZones > 0) or (self.Config.Zones and self.Config.Zones.PickupZones and #self.Config.Zones.PickupZones > 0)
    if not hasPickupZones then
      _eventSend(self, group, nil, 'no_pickup_zones', {})
      return
    end
    local activeDefs = {}
    for _,z in ipairs(self.Config.Zones.PickupZones or {}) do
      if (not z.name) or self._ZoneActive.Pickup[z.name] ~= false then table.insert(activeDefs, z) end
    end
    local zone, dist = _nearestZonePoint(unit, activeDefs)
    local inside = false
    if zone then
      local rZone = self:_getZoneRadius(zone) or 0
      if dist and rZone and dist <= rZone then inside = true end
    end
    if not inside then
      local isMetric = _getPlayerIsMetric(unit)
      local rZone = (zone and (self:_getZoneRadius(zone) or 0)) or 0
      local delta = math.max(0, (dist or 0) - rZone)
      local v, u = _fmtRange(delta, isMetric)
      -- Bearing from player to zone center
      local up = unit:GetPointVec3()
      local zp = zone and zone:GetPointVec3() or nil
      local brg = 0
      if zp then
        brg = _bearingDeg({ x = up.x, z = up.z }, { x = zp.x, z = zp.z })
      end
      _eventSend(self, group, nil, 'troop_pickup_zone_required', { zone_dist = v, zone_dist_u = u, zone_brg = brg })
      return
    end
  end

  local capacity = 6 -- simple default; can be adjusted per type later
  CTLD._troopsLoaded[gname] = {
    count = capacity,
    typeKey = 'RIFLE',
  }
  _eventSend(self, group, nil, 'troops_loaded', { count = capacity })
end

function CTLD:UnloadTroops(group, opts)
  local gname = group:GetName()
  local load = CTLD._troopsLoaded[gname]
  if not load or (load.count or 0) == 0 then _eventSend(self, group, nil, 'no_troops', {}) return end

  local unit = group:GetUnit(1)
  if not unit or not unit:IsAlive() then return end
  local p = unit:GetPointVec3()
  local here = { x = p.x, z = p.z }
  local hdg = unit:GetHeading() or 0
  -- Offset troop spawn forward to avoid spawning under/near rotors
  local troopOffset = math.max(0, tonumber(self.Config.TroopSpawnOffset or 0) or 0)
  local center = (troopOffset > 0) and { x = here.x + math.sin(hdg) * troopOffset, z = here.z + math.cos(hdg) * troopOffset } or { x = here.x, z = here.z }

  local count = load.count
  -- Spawn a simple infantry fireteam
  local units = {}
  for i=1, math.min(count, 8) do
    table.insert(units, {
      type = 'Infantry AK', name = string.format('CTLD-TROOP-%d', math.random(100000,999999)),
      x = center.x + i*1.5, y = center.z + (i%2==0 and 2 or -2), heading = hdg
    })
  end
  local groupData = {
    visible=false, lateActivation=false, tasks={}, task='Ground Nothing',
    units=units, route={}, name=string.format('CTLD_TROOPS_%d', math.random(100000,999999))
  }
  local spawned = _coalitionAddGroup(self.Side, Group.Category.GROUND, groupData)
  if spawned then
    CTLD._troopsLoaded[gname] = nil
    _eventSend(self, nil, self.Side, 'troops_unloaded_coalition', { count = #units, player = _playerNameFromGroup(group) })
    -- Assign optional behavior
    local behavior = opts and opts.behavior or nil
    if behavior == 'attack' and self.Config.AttackAI and self.Config.AttackAI.Enabled then
      local t = self:_assignAttackBehavior(spawned:getName(), center, false)
      -- Announce intentions globally
      local isMetric = _getPlayerIsMetric(group:GetUnit(1))
      if t and t.kind == 'base' then
        local brg = _bearingDeg({ x = center.x, z = center.z }, { x = t.point.x, z = t.point.z })
        local v, u = _fmtRange(t.dist or 0, isMetric)
        _eventSend(self, nil, self.Side, 'attack_base_announce', { unit_name = spawned:getName(), player = _playerNameFromGroup(group), base_name = t.name, brg = brg, rng = v, rng_u = u })
      elseif t and t.kind == 'enemy' then
        local brg = _bearingDeg({ x = center.x, z = center.z }, { x = t.point.x, z = t.point.z })
        local v, u = _fmtRange(t.dist or 0, isMetric)
        _eventSend(self, nil, self.Side, 'attack_enemy_announce', { unit_name = spawned:getName(), player = _playerNameFromGroup(group), enemy_type = t.etype or 'unit', brg = brg, rng = v, rng_u = u })
      else
        local v, u = _fmtRange((self.Config.AttackAI and self.Config.AttackAI.TroopSearchRadius) or 3000, isMetric)
        _eventSend(self, nil, self.Side, 'attack_no_targets', { unit_name = spawned:getName(), player = _playerNameFromGroup(group), rng = v, rng_u = u })
      end
    end
  else
    _eventSend(self, group, nil, 'troops_deploy_failed', { reason = 'DCS group spawn error' })
  end
end
-- #endregion Troops

-- =========================
-- Public helpers
-- =========================
-- =========================
-- Auto-build FOB in zones
-- =========================
-- #region Auto-build FOB in zones
function CTLD:AutoBuildFOBCheck()
  if not (self.FOBZones and #self.FOBZones > 0) then return end
  -- Find any FOB recipe definitions
  local fobDefs = {}
  for key,def in pairs(self.Config.CrateCatalog) do if def.isFOB and def.build then fobDefs[key] = def end end
  if next(fobDefs) == nil then return end

  for _,zone in ipairs(self.FOBZones) do
    local center = zone:GetPointVec3()
    local radius = self:_getZoneRadius(zone)
    local nearby = self:GetNearbyCrates({ x = center.x, z = center.z }, radius)
    -- filter to this coalition side
    local filtered = {}
    for _,c in ipairs(nearby) do if c.meta.side == self.Side then table.insert(filtered, c) end end
    nearby = filtered

    if #nearby > 0 then
      local counts = {}
      for _,c in ipairs(nearby) do counts[c.meta.key] = (counts[c.meta.key] or 0) + 1 end

      local function consumeCrates(key, qty)
        local removed = 0
        for _,c in ipairs(nearby) do
          if removed >= qty then break end
          if c.meta.key == key then
            local obj = StaticObject.getByName(c.name)
            if obj then obj:destroy() end
            CTLD._crates[c.name] = nil
            removed = removed + 1
          end
        end
      end

      local built = false

      -- Prefer composite recipes
      for recipeKey,cat in pairs(fobDefs) do
        if type(cat.requires) == 'table' then
          local ok = true
          for reqKey,qty in pairs(cat.requires) do if (counts[reqKey] or 0) < qty then ok = false; break end end
          if ok then
            local gdata = cat.build({ x = center.x, z = center.z }, 0, cat.side or self.Side)
            local g = _coalitionAddGroup(cat.side or self.Side, cat.category or Group.Category.GROUND, gdata)
            if g then
              for reqKey,qty in pairs(cat.requires) do consumeCrates(reqKey, qty) end
              _msgCoalition(self.Side, string.format('FOB auto-built at %s', zone:GetName()))
              built = true
              break -- move to next zone; avoid multiple builds per tick
            end
          end
        end
      end

      -- Then single-key FOB recipes
      if not built then
        for key,cat in pairs(fobDefs) do
          if not cat.requires and (counts[key] or 0) >= (cat.required or 1) then
            local gdata = cat.build({ x = center.x, z = center.z }, 0, cat.side or self.Side)
            local g = _coalitionAddGroup(cat.side or self.Side, cat.category or Group.Category.GROUND, gdata)
            if g then
              consumeCrates(key, cat.required or 1)
              _msgCoalition(self.Side, string.format('FOB auto-built at %s', zone:GetName()))
              built = true
              break
            end
          end
        end
      end
      -- next zone iteration continues automatically
    end
  end
end
-- #endregion Auto-build FOB in zones

-- =========================
-- Public helpers
-- =========================
-- #region Public helpers
function CTLD:RegisterCrate(key, def)
  self.Config.CrateCatalog[key] = def
end

function CTLD:MergeCatalog(tbl)
  for k,v in pairs(tbl or {}) do self.Config.CrateCatalog[k] = v end
end

-- =========================
-- Inventory helpers
-- =========================
function CTLD:InitInventory()
  if not (self.Config.Inventory and self.Config.Inventory.Enabled) then return end
  -- Seed stock for each configured pickup zone (by name only)
  for _,z in ipairs(self.PickupZones or {}) do
    local name = z:GetName()
    self:_SeedZoneStock(name, 1.0)
  end
end

function CTLD:_SeedZoneStock(zoneName, factor)
  if not zoneName then return end
  CTLD._stockByZone[zoneName] = CTLD._stockByZone[zoneName] or {}
  local f = factor or 1.0
  for key,def in pairs(self.Config.CrateCatalog or {}) do
    local n = tonumber(def.initialStock or 0) or 0
    n = math.max(0, math.floor(n * f + 0.0001))
    -- Only seed if not already present (avoid overwriting saved/progress state)
    if CTLD._stockByZone[zoneName][key] == nil then
      CTLD._stockByZone[zoneName][key] = n
    end
  end
end

function CTLD:_CreateFOBPickupZone(point, cat, hdg)
  -- Create a small pickup zone at the FOB to act as a supply point
  local name = string.format('FOB_PZ_%d', math.random(100000,999999))
  local v2 = VECTOR2:New(point.x, point.z)
  local r = 150
  local z = ZONE_RADIUS:New(name, v2, r)
  table.insert(self.PickupZones, z)
  self._ZoneDefs.PickupZones[name] = { name = name, radius = r, active = true }
  self._ZoneActive.Pickup[name] = true
  table.insert(self.Config.Zones.PickupZones, { name = name, radius = r, active = true })
  -- Seed FOB stock at fraction of initial pickup stock
  local f = (self.Config.Inventory and self.Config.Inventory.FOBStockFactor) or 0.25
  self:_SeedZoneStock(name, f)
  _msgCoalition(self.Side, string.format('FOB supply established: %s (stock seeded at %d%%)', name, math.floor(f*100+0.5)))
end

function CTLD:AddPickupZone(z)
  local mz = _findZone(z)
  if mz then table.insert(self.PickupZones, mz); table.insert(self.Config.Zones.PickupZones, z) end
end

function CTLD:AddDropZone(z)
  local mz = _findZone(z)
  if mz then table.insert(self.DropZones, mz); table.insert(self.Config.Zones.DropZones, z) end
end

function CTLD:SetAllowedAircraft(list)
  self.Config.AllowedAircraft = DeepCopy(list)
end
-- #endregion Public helpers

-- =========================
-- Return factory
-- =========================
-- #region Export
_MOOSE_CTLD = CTLD
return CTLD
-- #endregion Export
