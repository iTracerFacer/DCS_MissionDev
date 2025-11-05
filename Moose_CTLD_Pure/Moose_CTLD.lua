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
  pickup_zone_required = "Move within {zone_dist} {zone_dist_u} of a Supply Zone to request crates.",
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
  troop_pickup_zone_required = "Move inside a Supply Zone to load troops. Nearest zone is {zone_dist} {zone_dist_u} away.",

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
}

CTLD.Config = {
  CoalitionSide = coalition.side.BLUE,   -- default coalition this instance serves (menus created for this side)
  AllowedAircraft = {                    -- transport-capable unit type names (case-sensitive as in DCS DB)
    'UH-1H','Mi-8MTV2','Mi-24P','SA342M','SA342L','SA342Minigun','Ka-50','Ka-50_3','AH-64D_BLK_II','UH-60L','CH-47Fbl1','CH-47F','Mi-17','GazelleAI'
  },
  UseGroupMenus = true,                  -- if true, F10 menus per player group; otherwise coalition-wide
  UseCategorySubmenus = true,            -- if true, organize crate requests by category submenu (menuCategory)
  UseBuiltinCatalog = false,             -- if false, starts with an empty catalog; intended when you preload a global catalog and want only that
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
  
  -- Optional: draw zones on the F10 map using trigger.action.* markup (ME Draw-like)
  MapDraw = {
    Enabled = true,              -- master switch for any map drawings created by this script
    DrawPickupZones = true,      -- draw Pickup/Supply zones as shaded circles with labels
    DrawDropZones = false,       -- optionally draw Drop zones
    DrawFOBZones = false,        -- optionally draw FOB zones
    OutlineColor = {0, 1, 0, 0.85},  -- RGBA 0..1 for outlines (default green)
    FillColor = {0, 1, 0, 0.15},     -- RGBA 0..1 for fill (light green shade)
    LineType = 1,                -- default line type if per-kind is not set (0 None, 1 Solid, 2 Dashed, 3 Dotted, 4 DotDash, 5 LongDash, 6 TwoDash)
    LineTypes = {                -- override border style per zone kind
      Pickup = 3,                -- dotted
      Drop   = 2,                -- dashed
      FOB    = 4,                -- dot-dash
    },
    FontSize = 18,               -- label text size
    ReadOnly = true,             -- prevent clients from removing the shapes
    LabelPrefix = 'Pickup Zone'  -- prefix for labels; zone name will be appended
  },

  -- Optional: bindings to mission flags to activate/deactivate zones via ME triggers
  -- Each entry: { kind = 'Pickup'|'Drop'|'FOB', name = 'Zone Name', flag = 1001, activeWhen = 1 }
  ZoneEventBindings = {
    -- Example:
    -- { kind = 'Pickup', name = 'Pickup Zone 1', flag = 9001, activeWhen = 1 },
    -- { kind = 'Drop',   name = 'DZ_WEST',       flag = 9002, activeWhen = 1 },
  },
  -- Crate spawn placement within pickup zones
  PickupZoneSpawnRandomize = true,      -- if true, spawn crates at a random point within the pickup zone (avoids stacking)
  PickupZoneSpawnEdgeBuffer = 10,       -- meters: keep spawns at least this far inside the zone edge
  PickupZoneSpawnMinOffset = 100,         -- meters: keep spawns at least this far from the exact center
  CrateSpawnMinSeparation = 7,          -- meters: try not to place a new crate closer than this to an existing one
  CrateSpawnSeparationTries = 6,        -- attempts to find a non-overlapping position before accepting best effort
  BuildRequiresGroundCrates = true,      -- if true, all required crates must be on the ground (won't count/consume carried crates)

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

  Zones = {                              -- Optional: supply by name (ME trigger zones) or define coordinates inline
    PickupZones = {
      -- Examples:
      -- Create 5 trigger zones in the Mission Editor named exactly as below to get started quickly.
      -- If you run separate CTLD instances for BLUE and RED, give each side its own set of uniquely named zones
      -- (recommended to avoid overlap). You can keep the simple "Pickup Zone #" pattern per side if you prefer,
      -- just ensure the names in the ME match what you configure here.
      --
      -- Uncomment the lines you want to use:
      -- { name = 'Pickup Zone 1', smoke = trigger.smokeColor.Green },
      -- { name = 'Pickup Zone 2', smoke = trigger.smokeColor.Blue },
      -- { name = 'Pickup Zone 3', smoke = trigger.smokeColor.Orange },
      -- { name = 'Pickup Zone 4', smoke = trigger.smokeColor.White },
      -- { name = 'Pickup Zone 5', smoke = trigger.smokeColor.Red },
      --
      -- Tip: You can also define zones purely in script (no ME zone needed):
      -- { coord = { x = 12345, y = 0, z = 67890 }, radius = 150, name = 'Pickup Zone 1' },
    },
    DropZones = {
      -- { name = 'DROP_BLUE_1' },
    },
    FOBZones = {
      -- optional: where FOB crates can unpack to spawn FARP/FOB assets
    },
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
  local side = self.Side
  local outline = opts.OutlineColor or {0,1,0,0.85}
  local fill = opts.FillColor or {0,1,0,0.15}
  local lineType = opts.LineType or 1
  local readOnly = (opts.ReadOnly ~= false)
  local fontSize = opts.FontSize or 18
  local labelPrefix = opts.LabelPrefix or 'Zone'
  local zname = (mz.GetName and mz:GetName()) or '(zone)'
  local circleId = _nextMarkupId()
  local textId = _nextMarkupId()
  trigger.action.circleToAll(side, circleId, p, r, outline, fill, lineType, readOnly)
  local label = string.format('%s: %s', labelPrefix, zname)
  -- Offset text slightly north of center so it’s readable above the circle center
  local textPos = { x = p.x, y = 0, z = p.z - (r + 20) }
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
          FillColor = md.FillColor,
          LineType = (md.LineTypes and md.LineTypes[k]) or md.LineType or 1,
          FontSize = md.FontSize,
          ReadOnly = (md.ReadOnly ~= false),
          LabelPrefix = (k=='Pickup' and (md.LabelPrefix or 'Pickup Zone')) or (k..' Zone')
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
    FillColor = md.FillColor,
    LineType = md.LineType,
    FontSize = md.FontSize,
    ReadOnly = (md.ReadOnly ~= false),
    LabelPrefix = md.LabelPrefix or 'Zone'
  }
  if md.DrawPickupZones then
    for _,mz in ipairs(self.PickupZones or {}) do
      local name = mz:GetName()
      if self._ZoneActive.Pickup[name] ~= false then
      opts.LabelPrefix = md.LabelPrefix or 'Pickup Zone'
      opts.LineType = (md.LineTypes and md.LineTypes.Pickup) or md.LineType or 1
      self:_drawZoneCircleAndLabel('Pickup', mz, opts)
      end
    end
  end
  if md.DrawDropZones then
    for _,mz in ipairs(self.DropZones or {}) do
      local name = mz:GetName()
      if self._ZoneActive.Drop[name] ~= false then
      opts.LabelPrefix = 'Drop Zone'
      opts.LineType = (md.LineTypes and md.LineTypes.Drop) or md.LineType or 1
      self:_drawZoneCircleAndLabel('Drop', mz, opts)
      end
    end
  end
  if md.DrawFOBZones then
    for _,mz in ipairs(self.FOBZones or {}) do
      local name = mz:GetName()
      if self._ZoneActive.FOB[name] ~= false then
      opts.LabelPrefix = 'FOB Zone'
      opts.LineType = (md.LineTypes and md.LineTypes.FOB) or md.LineType or 1
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
    -- Always provide a coalition-level Admin/Help menu for mission makers
    self:InitCoalitionAdminMenu()
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
  -- Request crate submenu per catalog entry
  local reqRoot = MENU_GROUP:New(group, 'Request Crate', root)
  if self.Config.UseCategorySubmenus then
    local submenus = {}
    local function getSubmenu(catLabel)
      if not submenus[catLabel] then
        submenus[catLabel] = MENU_GROUP:New(group, catLabel, reqRoot)
      end
      return submenus[catLabel]
    end
    for key,def in pairs(self.Config.CrateCatalog) do
      local label = (def and (def.menu or def.description)) or key
      local sideOk = (not def.side) or def.side == self.Side
      if sideOk then
        local catLabel = (def and def.menuCategory) or 'Other'
        local parent = getSubmenu(catLabel)
        MENU_GROUP_COMMAND:New(group, label, parent, function()
          self:RequestCrateForGroup(group, key)
        end)
      end
    end
  else
    for key,def in pairs(self.Config.CrateCatalog) do
      local label = (def and (def.menu or def.description)) or key
      local sideOk = (not def.side) or def.side == self.Side
      if sideOk then
        MENU_GROUP_COMMAND:New(group, label, reqRoot, function()
          self:RequestCrateForGroup(group, key)
        end)
      end
    end
  end
  -- Troops
  MENU_GROUP_COMMAND:New(group, 'Load Troops', root, function() self:LoadTroops(group) end)
  MENU_GROUP_COMMAND:New(group, 'Unload Troops', root, function() self:UnloadTroops(group) end)

  -- Build
  MENU_GROUP_COMMAND:New(group, 'Build Here', root, function()
    self:BuildAtGroup(group)
  end)

  -- Crate management (loaded crates)
  MENU_GROUP_COMMAND:New(group, 'Drop One Loaded Crate', root, function()
    self:DropLoadedCrates(group, 1)
  end)
  MENU_GROUP_COMMAND:New(group, 'Drop All Loaded Crates', root, function()
    self:DropLoadedCrates(group, -1)
  end)

  -- Coach & Navigation utilities
  local navRoot = MENU_GROUP:New(group, 'Coach & Nav', root)
  local gname = group:GetName()
  MENU_GROUP_COMMAND:New(group, 'Hover Coach: Enable', navRoot, function()
    CTLD._coachOverride = CTLD._coachOverride or {}
    CTLD._coachOverride[gname] = true
    _eventSend(self, group, nil, 'coach_enabled', {})
  end)
  MENU_GROUP_COMMAND:New(group, 'Hover Coach: Disable', navRoot, function()
    CTLD._coachOverride = CTLD._coachOverride or {}
    CTLD._coachOverride[gname] = false
    _eventSend(self, group, nil, 'coach_disabled', {})
  end)
  MENU_GROUP_COMMAND:New(group, 'Request Vectors to Nearest Crate', navRoot, function()
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
  MENU_GROUP_COMMAND:New(group, 'Vectors to Nearest Pickup Zone', navRoot, function()
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
  MENU_GROUP_COMMAND:New(group, 'Re-mark Nearest Crate (Smoke)', navRoot, function()
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

  return root
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
  local root = MENU_COALITION:New(self.Side, 'CTLD Admin/Help')
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
      _eventSend(self, group, nil, 'pickup_zone_required', { zone_dist = v, zone_dist_u = u })
      return
    else
      -- fallback: spawn near aircraft current position (safe offset)
      local p = unit:GetPointVec3()
      spawnPoint = POINT_VEC3:New(p.x + 10, p.y, p.z + 10)
    end
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
function CTLD:BuildAtGroup(group)
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
        local ok = true
        for reqKey,qty in pairs(cat.requires) do
          if (counts[reqKey] or 0) < qty then ok = false; break end
        end
        if ok then
          local hdg = unit:GetHeading()
          local gdata = cat.build({ x = here.x, z = here.z }, math.deg(hdg), cat.side or self.Side)
          _eventSend(self, group, nil, 'build_started', { build = cat.description or recipeKey })
          local g = _coalitionAddGroup(cat.side or self.Side, cat.category or Group.Category.GROUND, gdata)
          if g then
            for reqKey,qty in pairs(cat.requires) do consumeCrates(reqKey, qty) end
            _eventSend(self, nil, self.Side, 'build_success_coalition', { build = cat.description or recipeKey, player = _playerNameFromGroup(group) })
            if self.Config.BuildCooldownEnabled then CTLD._buildCooldown[gname] = now end
            return
          else
            _eventSend(self, group, nil, 'build_failed', { reason = 'DCS group spawn error' })
            return
          end
        end
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
  local hdg = unit:GetHeading()
  local gdata = cat.build({ x = here.x, z = here.z }, math.deg(hdg), cat.side or self.Side)
        _eventSend(self, group, nil, 'build_started', { build = cat.description or key })
        local g = _coalitionAddGroup(cat.side or self.Side, cat.category or Group.Category.GROUND, gdata)
        if g then
          consumeCrates(key, cat.required or 1)
          _eventSend(self, nil, self.Side, 'build_success_coalition', { build = cat.description or key, player = _playerNameFromGroup(group) })
          if self.Config.BuildCooldownEnabled then CTLD._buildCooldown[gname] = now end
          return
        else
          _eventSend(self, group, nil, 'build_failed', { reason = 'DCS group spawn error' })
          return
        end
      end
    end
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
      _eventSend(self, group, nil, 'troop_pickup_zone_required', { zone_dist = v, zone_dist_u = u })
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

function CTLD:UnloadTroops(group)
  local gname = group:GetName()
  local load = CTLD._troopsLoaded[gname]
  if not load or (load.count or 0) == 0 then _eventSend(self, group, nil, 'no_troops', {}) return end

  local unit = group:GetUnit(1)
  if not unit or not unit:IsAlive() then return end
  local p = unit:GetPointVec3()
  local here = { x = p.x, z = p.z }
  local hdg = unit:GetHeading()

  local count = load.count
  -- Spawn a simple infantry fireteam
  local units = {}
  for i=1, math.min(count, 8) do
    table.insert(units, {
      type = 'Infantry AK', name = string.format('CTLD-TROOP-%d', math.random(100000,999999)),
      x = here.x + i*1.5, y = here.z + (i%2==0 and 2 or -2), heading = hdg
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
