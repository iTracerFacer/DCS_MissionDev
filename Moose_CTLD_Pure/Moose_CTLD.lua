-- Pure-MOOSE, template-free CTLD-style logistics & troop transport
-- Drop-in script: no MIST, no mission editor templates required
-- Dependencies: Moose.lua must be loaded before this script
-- Author: Copilot (generated)

-- Contract
-- Inputs: Config table or defaults. No ME templates needed. Zones may be named ME trigger zones or provided via coordinates in config.
-- Outputs: F10 menus for helo/transport groups; crate spawning/building; troop load/unload; optional JTAC hookup (via FAC module);
-- Error modes: missing Moose -> abort; unknown crate key -> message; spawn blocked in enemy airbase; zone missing -> message.

-- Table of Contents (navigation)
-- 1) Config (version, messaging, main Config table)
-- 2) State
-- 3) Utilities
-- 4) Construction (zones, bindings, init)
-- 5) Menus (group/coalition, dynamic lists)
-- 6) Coalition Summary
-- 7) Crates (request/spawn, nearby, cleanup)
-- 8) Build logic
-- 9) Loaded crate management
-- 10) Hover pickup scanner
-- 11) Troops
-- 12) Auto-build FOB in zones
-- 13) Inventory helpers
-- 14) Public helpers (catalog registration/merge)
-- 15) Export
-- =========================

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

-- General CTLD event messages (non-hover). Tweak freely.
CTLD.Messages = {
  -- Crates
  crate_spawn_requested = "Request received—spawning {type} crate at {zone}.",
  pickup_zone_required = "Move within {zone_dist} {zone_dist_u} of a Supply Zone to request crates. Bearing {zone_brg}° to nearest zone.",
  no_pickup_zones = "No Pickup Zones are configured for this coalition. Ask the mission maker to add supply zones or disable the pickup zone requirement.",
  crate_re_marked = "Re-marking crate {id} with {mark}.",
  crate_expired = "Crate {id} expired and was removed.",
  crate_max_capacity = "Max load reached ({total}). Drop or build before picking up more.",
  crate_aircraft_capacity = "Aircraft capacity reached ({current}/{max} crates). Your {aircraft} can only carry {max} crates.",
  troop_aircraft_capacity = "Aircraft capacity reached. Your {aircraft} can only carry {max} troops (you need {count}).",
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

  -- Zone restrictions
  drop_forbidden_in_pickup = "Cannot drop crates inside a Supply Zone. Move outside the zone boundary.",
  troop_deploy_forbidden_in_pickup = "Cannot deploy troops inside a Supply Zone. Move outside the zone boundary.",
  drop_zone_too_close_to_pickup = "Drop Zone creation blocked: too close to Supply Zone {zone} (need at least {need} {need_u}; current {dist} {dist_u}). Fly further away and try again.",
  
  -- MEDEVAC messages
  medevac_crew_spawned = "MEDEVAC REQUEST: {vehicle} crew at {grid}. {crew_size} personnel awaiting rescue. Salvage value: {salvage}.",
  medevac_crew_loaded = "Rescued {vehicle} crew ({crew_size} personnel). {vehicle} will respawn shortly.",
  medevac_vehicle_respawned = "{vehicle} repaired and returned to the field at original location!",
  medevac_crew_delivered_mash = "{player} delivered {vehicle} crew to MASH. Earned {salvage} salvage points! Coalition total: {total}.",
  medevac_crew_timeout = "MEDEVAC FAILED: {vehicle} crew at {grid} KIA - no rescue attempted. Vehicle lost.",
  medevac_crew_killed = "MEDEVAC FAILED: {vehicle} crew killed in action. Vehicle lost.",
  medevac_no_requests = "No active MEDEVAC requests.",
  medevac_vectors = "MEDEVAC: {vehicle} crew bearing {brg}°, range {rng} {rng_u}. Time remaining: {time_remain} mins.",
  medevac_salvage_status = "Coalition Salvage Points: {points}. Use salvage to build out-of-stock items.",
  medevac_salvage_used = "Built {item} using {salvage} salvage points. Remaining: {remaining}.",
  medevac_salvage_insufficient = "Out of stock and insufficient salvage. Need {need} salvage points (have {have}). Deliver MEDEVAC crews to MASH to earn more.",
  medevac_crew_warn_15min = "WARNING: {vehicle} crew at {grid} - rescue window expires in 15 minutes!",
  medevac_crew_warn_5min = "URGENT: {vehicle} crew at {grid} - rescue window expires in 5 minutes!",
  
  -- Mobile MASH messages
  medevac_mash_deployed = "Mobile MASH {mash_id} deployed at {grid}. Beacon: {freq}. Delivering MEDEVAC crews here earns salvage points.",
  medevac_mash_announcement = "Mobile MASH {mash_id} available at {grid}. Beacon: {freq}.",
  medevac_mash_destroyed = "Mobile MASH {mash_id} destroyed! No longer accepting deliveries.",
  mash_announcement = "MASH {name} operational at {grid}. Accepting MEDEVAC deliveries for salvage credit. Monitoring {freq} AM.",
  mash_vectors = "Nearest MASH: {name} at bearing {brg}°, range {rng} {rng_u}.",
  mash_no_zones = "No MASH zones available.",
}

-- #endregion Messaging

CTLD.Config = {
  CoalitionSide = coalition.side.BLUE,   -- default coalition this instance serves (menus created for this side)
  AllowedAircraft = {                    -- transport-capable unit type names (case-sensitive as in DCS DB)
    'UH-1H','Mi-8MTV2','Mi-24P','SA342M','SA342L','SA342Minigun','Ka-50','Ka-50_3','AH-64D_BLK_II','UH-60L','CH-47Fbl1','CH-47F','Mi-17','GazelleAI'
  },
  
  -- Per-aircraft capacity limits (realistic cargo/troop capacities)
  -- Set maxCrates = 0 and maxTroops = 0 for attack helicopters with no cargo capability
  -- If an aircraft type is not listed here, it will use DefaultCapacity values
  AircraftCapacities = {
    -- Small/Light Helicopters (very limited capacity)
    ['SA342M']        = { maxCrates = 1,  maxTroops = 3 },   -- Gazelle - tiny observation/scout helo
    ['SA342L']        = { maxCrates = 1,  maxTroops = 3 },
    ['SA342Minigun']  = { maxCrates = 1,  maxTroops = 3 },
    ['GazelleAI']     = { maxCrates = 1,  maxTroops = 3 },
    
    -- Attack Helicopters (no cargo capacity - combat only)
    ['Ka-50']         = { maxCrates = 0,  maxTroops = 0 },   -- Black Shark - single seat attack
    ['Ka-50_3']       = { maxCrates = 0,  maxTroops = 0 },   -- Black Shark 3
    ['AH-64D_BLK_II'] = { maxCrates = 0,  maxTroops = 0 },   -- Apache - attack/recon only
    ['Mi-24P']        = { maxCrates = 2,  maxTroops = 8 },   -- Hind - attack helo but has small troop bay
    
    -- Light Utility Helicopters (moderate capacity)
    ['UH-1H']         = { maxCrates = 3,  maxTroops = 11 },  -- Huey - classic light transport
    
    -- Medium Transport Helicopters (good capacity)
    ['Mi-8MTV2']      = { maxCrates = 5,  maxTroops = 24 },  -- Hip - Russian medium transport
    ['Mi-17']         = { maxCrates = 5,  maxTroops = 24 },  -- Hip variant
    ['UH-60L']        = { maxCrates = 4,  maxTroops = 11 },  -- Black Hawk - medium utility
    
    -- Heavy Lift Helicopters (maximum capacity)
    ['CH-47Fbl1']     = { maxCrates = 10, maxTroops = 33 },  -- Chinook - heavy lift beast
    ['CH-47F']        = { maxCrates = 10, maxTroops = 33 },  -- Chinook variant

    -- Fixed Wing Transport (limited capacity)
    ['C-130']         = { maxCrates = 20, maxTroops = 92 },  -- C-130 Hercules - tactical airlifter
    ['C-17A']         = { maxCrates = 30, maxTroops = 150 }, -- C-17 Globemaster III - strategic airlifter
  },
  
  -- Default capacities for aircraft not listed in AircraftCapacities table
  -- Used as fallback for any transport aircraft without specific limits defined
  DefaultCapacity = {
    maxCrates = 4,   -- reasonable middle ground
    maxTroops = 12,  -- moderate squad size
  },
  
  UseGroupMenus = true,                  -- if true, F10 menus per player group; otherwise coalition-wide
  UseCategorySubmenus = true,            -- if true, organize crate requests by category submenu (menuCategory)
  UseBuiltinCatalog = false,             -- if false, starts with an empty catalog; intended when you preload a global catalog and want only that
  -- Safety offsets to avoid spawning units too close to player aircraft
  BuildSpawnOffset = 40,                 -- meters: shift build point forward from the aircraft to avoid rotor/ground collisions (0 = spawn centered on aircraft)
  TroopSpawnOffset = 40,                 -- meters: shift troop unload point forward from the aircraft
  
  -- Air-spawn settings for CTLD-built drones (AIRPLANE category entries in the catalog like MQ-9 / WingLoong)
  DroneAirSpawn = {
    Enabled = true,          -- when true, AIRPLANE catalog items that opt-in can spawn in the air at a set altitude
    AltitudeMeters = 5000,   -- default spawn altitude ASL (meters)
    SpeedMps = 120           -- default initial speed in m/s
  },
  DropCrateForwardOffset = 20,           -- meters: drop loaded crates this far in front of the aircraft (instead of directly under)
  RestrictFOBToZones = false,            -- if true, recipes marked isFOB only build inside configured FOBZones
  AutoBuildFOBInZones = false,           -- if true, CTLD auto-builds FOB recipes when required crates are inside a FOB zone
  BuildRadius = 60,                      -- meters around build point to collect crates
  CrateLifetime = 3600,                  -- seconds before crates auto-clean up; 0 = disable
  MessageDuration = 15,                  -- seconds for on-screen messages
  Debug = false,
  -- Build safety
  BuildConfirmEnabled = false,            -- require a second confirmation within a short window before building
  BuildConfirmWindowSeconds = 30,        -- seconds allowed between first and second "Build Here" press
  BuildCooldownEnabled = true,           -- after a successful build, impose a cooldown before allowing another build by the same group
  BuildCooldownSeconds = 60,             -- seconds of cooldown after a successful build per group
  PickupZoneSmokeColor = trigger.smokeColor.Green, -- default smoke color when spawning crates at pickup zones
  
  -- Crate Smoke Settings
  -- NOTE: Individual smoke effects last ~5 minutes (DCS hardcoded, cannot be changed)
  -- These settings control whether/how often NEW smoke is spawned, not how long each smoke lasts
  CrateSmoke = {
    Enabled = true,                      -- if true, spawn smoke when crates are created; if false, no smoke at all
    AutoRefresh = false,                 -- if true, automatically spawn new smoke every RefreshInterval seconds (creates continuous smoke)
    RefreshInterval = 240,               -- seconds: how often to spawn new smoke (only used if AutoRefresh = true; 240s = 4min recommended)
    MaxRefreshDuration = 600,            -- seconds: stop auto-refresh after this long (safety limit; 600s = 10min; set high or disable AutoRefresh for one-time smoke)
    OffsetMeters = 0,                    -- meters: horizontal offset from crate so helicopters don't hover in smoke (0 = directly on crate)
    OffsetRandom = true,                 -- if true, randomize horizontal offset direction; if false, always offset north
    OffsetVertical = 20,                  -- meters: vertical offset above ground level (helps smoke be more visible; 2-3 recommended)
  },
  
  RequirePickupZoneForCrateRequest = true, -- enforce that crate requests must be near a Supply (Pickup) Zone
  RequirePickupZoneForTroopLoad = true,   -- if true, troops can only be loaded while inside a Supply (Pickup) Zone
  PickupZoneMaxDistance = 10000,        -- meters; nearest pickup zone must be within this distance to allow a request
  -- Safety rules around Supply (Pickup) Zones
  ForbidDropsInsidePickupZones = true,   -- if true, players cannot drop crates while inside a Pickup Zone
  ForbidTroopDeployInsidePickupZones = true, -- if true, players cannot deploy troops while inside a Pickup Zone
  ForbidChecksActivePickupOnly = true,   -- when true, restriction applies only to ACTIVE pickup zones; set false to block inside any configured pickup zone

  -- Dynamic Drop Zone settings
  DropZoneRadius = 250,                  -- meters: radius used when creating a Drop Zone via the admin menu at player position
  MinDropZoneDistanceFromPickup = 10000, -- meters: minimum distance from nearest Pickup Zone required to create a dynamic Drop Zone (0 to disable)
  MinDropDistanceActivePickupOnly = true, -- when true, only ACTIVE pickup zones are considered for the minimum distance check
  
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
    LabelOffsetRatio = 0.5,       -- fraction of the radius to add to the offset (e.g., 0.1 => +10% of r)
    LabelOffsetX = 200,           -- meters: horizontal nudge; adjust if text appears left-anchored in your DCS build
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
  
  -- Troop type presets (menu-driven loadable teams)
  Troops = {
    -- Default troop type to use when no specific type is chosen
    DefaultType = 'AS',
    -- Team definitions: label (menu text), size (number spawned), and unit pools per coalition
    -- NOTE: Unit type names are DCS database strings. The provided defaults are conservative and
    -- use generic infantry to maximize compatibility. You can customize per mission/era.
    TroopTypes = {
      -- Assault squad: general-purpose rifles/MG
      AS = {
        label = 'Assault Squad',
        size = 8,
        -- Fallback pools; adjust for era/faction if you want richer mixes
        unitsBlue = { 'Infantry M4', 'Infantry M249' },
        unitsRed  = { 'Infantry AK', 'Infantry AK' },
        -- If specific Blue/Red not available, this generic pool is used
        units     = { 'Infantry AK' },
      },
      -- Anti-air team: MANPADS element
      AA = {
        label = 'MANPADS Team',
        size = 4,
        -- These names vary by mod/DB; defaults fall back to generic infantry if unavailable
        unitsBlue = { 'Infantry manpad Stinger', 'Infantry M4' },
        unitsRed  = { 'Infantry manpad Igla', 'Infantry AK' },
        units     = { 'Infantry AK' },
      },
      -- Anti-tank team: RPG/AT4 element
      AT = {
        label = 'AT Team',
        size = 4,
        unitsBlue = { 'Soldier M136', 'Infantry M4' },
        unitsRed  = { 'Soldier RPG', 'Infantry AK' },
        units     = { 'Infantry AK' },
      },
      -- Indirect fire: mortar detachment
      AR = {
        label = 'Mortar Team',
        size = 4,
        unitsBlue = { 'Mortar M252' },
        unitsRed  = { '2B11 mortar' },
        units     = { 'Infantry AK' },
      },
    },
  },
}
  -- #endregion Config

-- Immersive Hover Coach configuration (messages, thresholds, throttling)
-- All user-facing text lives here; logic only fills placeholders.
CTLD.HoverCoachConfig = {
  enabled = true,             -- master switch for hover coaching feature
  coachOnByDefault = true,    -- per-player default; players can toggle via F10 > Navigation > Hover Coach
  
  -- Pickup parameters
  maxCratesPerLoad = 6,       -- maximum crates the aircraft can carry simultaneously
  autoPickupDistance = 25,    -- meters max search distance for candidate crates

  thresholds = {
    arrivalDist = 1000,       -- m: start guidance "You're close…"
    closeDist = 100,          -- m: reduce speed / set AGL guidance
    precisionDist = 8,       -- m: start precision hints
    captureHoriz = 5,         -- m: horizontal sweet spot radius
    captureVert = 5,          -- m: vertical sweet spot tolerance around AGL window
    aglMin = 5,               -- m: hover window min AGL
    aglMax = 20,              -- m: hover window max AGL
    maxGS = 8/3.6,            -- m/s: 8 km/h for precision, used for errors
    captureGS = 4/3.6,        -- m/s: 4 km/h capture requirement
    maxVS = 2.0,              -- m/s: absolute vertical speed during capture
    driftResetDist = 13,      -- m: if beyond, reset precision phase
    stabilityHold = 2.0       -- s: hold steady before loading
  },

  throttle = {
    coachUpdate = 3.0,         -- s between hint updates in precision
    generic = 3.0,            -- s between non-coach messages
    repeatSame = 6.0          -- s before repeating same message key
  },
}

-- =========================
-- MEDEVAC Configuration
-- =========================
-- #region MEDEVAC Config
CTLD.MEDEVAC = {
  Enabled = true,
  
  -- Crew spawning
  CrewSpawnDelay = 180,           -- seconds after death before crew requests pickup (invulnerable during this time)
  CrewInvulnerableDuration = 300, -- 5 minutes total invulnerability
  CrewTimeout = 3600,             -- 1 hour max wait before crew is KIA
  CrewSpawnOffset = 15,           -- meters from death location (toward nearest enemy)
  CrewDefaultSize = 2,            -- default crew size if not specified in catalog
  CrewDefendSelf = true,          -- crews will return fire if engaged
  
  -- Crew unit types per coalition (fallback if not specified in catalog)
  CrewUnitTypes = {
    [coalition.side.BLUE] = 'Soldier M4',
    [coalition.side.RED] = 'Infantry AK',
  },
  
  -- Respawn settings
  RespawnOnPickup = true,         -- if true, vehicle respawns when crew loaded into helo
  RespawnOffset = 15,             -- meters from original death position
  RespawnSameHeading = true,      -- preserve original heading
  
  -- Salvage system
  Salvage = {
    Enabled = true,
    PoolType = 'global',          -- 'global' = coalition-wide pool
    DefaultValue = 1,             -- default salvageValue if not in catalog
    ShowInStatus = true,          -- show salvage points in F10 status menu
    AutoApply = true,             -- auto-use salvage when out of stock (no manual confirmation)
    AllowAnyItem = true,          -- can build items that never had inventory using salvage
  },
  
  -- Map markers for downed crews
  MapMarkers = {
    Enabled = true,
    IconText = '🔴 MEDEVAC',      -- prefix for marker text
    ShowGrid = true,              -- include grid coordinates in marker
    ShowTimeRemaining = true,     -- show expiration time in marker
    ShowSalvageValue = true,      -- show salvage value in marker
  },
  
  -- Warning messages before crew timeout
  Warnings = {
    { time = 900, message = 'MEDEVAC: {crew} at {grid} has 15 minutes remaining!' },
    { time = 300, message = 'URGENT MEDEVAC: {crew} at {grid} will be KIA in 5 minutes!' },
  },
  
  -- MASH Zones (fixed, defined in mission editor)
  MASHZones = {
    -- Example: { name = 'MASH Alpha', freq = 251.0, radius = 500 },
    -- Mission makers add their zones here or via CTLD:AddMASHZone()
  },
  
  MASHZoneRadius = 500,           -- default radius for MASH zones
  MASHZoneColors = {
    border = {1, 1, 0, 0.85},     -- yellow border
    fill = {1, 0.75, 0.8, 0.25},  -- pink fill
  },
  
  -- Mobile MASH (player-deployable via crates)
  MobileMASH = {
    Enabled = true,
    ZoneRadius = 500,                     -- radius of Mobile MASH zone in meters
    CrateRecipeKey = 'MOBILE_MASH',       -- catalog key for building mobile MASH
    AnnouncementInterval = 1800,          -- 30 mins between announcements
    BeaconFrequency = '30.0 FM',          -- radio frequency for announcements
    Destructible = true,
    VehicleTypes = {
      [coalition.side.BLUE] = 'M113',     -- Medical variant for BLUE
      [coalition.side.RED] = 'BTR-D',     -- Medical/transport variant for RED
    },
    AutoIncrementName = true,             -- "Mobile MASH 1", "Mobile MASH 2"...
  },
  
  -- Statistics tracking
  Statistics = {
    Enabled = true,
    TrackByPlayer = false,            -- if true, track per-player stats (not yet implemented)
  },
}
-- #endregion MEDEVAC Config

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
-- MEDEVAC state
CTLD._medevacCrews = CTLD._medevacCrews or {}     -- [crewGroupName] = { vehicleType, side, spawnTime, position, salvageValue, markerID, originalHeading, requestTime, warningsSent }
CTLD._salvagePoints = CTLD._salvagePoints or {}   -- [coalition.side] = points (global pool)
CTLD._mashZones = CTLD._mashZones or {}           -- [zoneName] = { zone, side, isMobile, unitName (if mobile) }
CTLD._mobileMASHCounter = CTLD._mobileMASHCounter or { [coalition.side.BLUE] = 0, [coalition.side.RED] = 0 }
CTLD._medevacStats = CTLD._medevacStats or {      -- [coalition.side] = { spawned, rescued, delivered, timedOut, killed, salvageEarned, vehiclesRespawned }
  [coalition.side.BLUE] = { spawned = 0, rescued = 0, delivered = 0, timedOut = 0, killed = 0, salvageEarned = 0, vehiclesRespawned = 0, salvageUsed = 0 },
  [coalition.side.RED] = { spawned = 0, rescued = 0, delivered = 0, timedOut = 0, killed = 0, salvageEarned = 0, vehiclesRespawned = 0, salvageUsed = 0 },
}

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
    -- Create a Vec2 in a way that works even if MOOSE VECTOR2 class isn't available
    local function _mkVec2(x, z)
      if VECTOR2 and VECTOR2.New then return VECTOR2:New(x, z) end
      -- DCS uses Vec2 with fields x and y
      return { x = x, y = z }
    end
    local v = _mkVec2(z.coord.x, z.coord.z)
    return ZONE_RADIUS:New(z.name or ('CTLD_ZONE_'..math.random(10000,99999)), v, r)
  end
  return nil
end

local function _getUnitType(unit)
  local ud = unit and unit:GetDesc() or nil
  return ud and ud.typeName or unit and unit:GetTypeName()
end

-- Get aircraft capacity limits for crates and troops
-- Returns { maxCrates, maxTroops } for the given unit
-- Falls back to DefaultCapacity if aircraft type not specifically configured
local function _getAircraftCapacity(unit)
  if not unit then 
    return { 
      maxCrates = CTLD.Config.DefaultCapacity.maxCrates or 4,
      maxTroops = CTLD.Config.DefaultCapacity.maxTroops or 12
    }
  end
  
  local unitType = _getUnitType(unit)
  local capacities = CTLD.Config.AircraftCapacities or {}
  local specific = capacities[unitType]
  
  if specific then
    return {
      maxCrates = specific.maxCrates or 0,
      maxTroops = specific.maxTroops or 0
    }
  end
  
  -- Fallback to defaults
  local defaults = CTLD.Config.DefaultCapacity or {}
  return {
    maxCrates = defaults.maxCrates or 4,
    maxTroops = defaults.maxTroops or 12
  }
end

local function _nearestZonePoint(unit, list)
  if not unit or not unit:IsAlive() then return nil end
  -- Get unit position using DCS API to avoid dependency on MOOSE point methods
  local uname = unit:GetName()
  local du = Unit.getByName and Unit.getByName(uname) or nil
  if not du or not du:getPoint() then return nil end
  local up = du:getPoint()
  local ux, uz = up.x, up.z

  local best, bestd = nil, nil
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
      if (not bestd) or d < bestd then best, bestd = mz, d end
    end
  end
  if not best then return nil, nil end
  return best, bestd
end

-- Check if a unit is inside a Pickup Zone. Returns (inside:boolean, zone, dist, radius)
function CTLD:_isUnitInsidePickupZone(unit, activeOnly)
  if not unit or not unit:IsAlive() then return false, nil, nil, nil end
  local zone, dist
  if activeOnly then
    zone, dist = self:_nearestActivePickupZone(unit)
  else
    local defs = self.Config and self.Config.Zones and self.Config.Zones.PickupZones or {}
    zone, dist = _nearestZonePoint(unit, defs)
  end
  if not zone or not dist then return false, nil, nil, nil end
  local r = self:_getZoneRadius(zone)
  if not r then return false, zone, dist, nil end
  return dist <= r, zone, dist, r
end

-- Helper: get nearest ACTIVE pickup zone (by configured list), respecting CTLD's active flags
function CTLD:_collectActivePickupDefs()
  local out = {}
  -- From config-defined zones
  local defs = (self.Config and self.Config.Zones and self.Config.Zones.PickupZones) or {}
  for _, z in ipairs(defs) do
    local n = z.name
    if (not n) or self._ZoneActive.Pickup[n] ~= false then table.insert(out, z) end
  end
  -- From MOOSE zone objects if present
  if self.PickupZones and #self.PickupZones > 0 then
    for _, mz in ipairs(self.PickupZones) do
      if mz and mz.GetName then
        local n = mz:GetName()
        if self._ZoneActive.Pickup[n] ~= false then table.insert(out, { name = n }) end
      end
    end
  end
  return out
end

function CTLD:_nearestActivePickupZone(unit)
  return _nearestZonePoint(unit, self:_collectActivePickupDefs())
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

-- Spawn smoke at a position using MOOSE COORDINATE smoke (better appearance) or trigger smoke (old thick ground smoke)
-- position: {x, y, z} table (Vec3)
-- color: trigger.smokeColor enum value
-- config: reference to a CrateSmoke config table (or nil to use defaults)
-- crateId: optional crate identifier for tracking smoke refresh schedules
local function _spawnCrateSmoke(position, color, config, crateId)
  if not position or not color then return end
  
  -- Parse config with defaults
  local enabled = true
  local autoRefresh = false
  local refreshInterval = 240
  local maxRefreshDuration = 600
  local offsetMeters = 5
  local offsetRandom = true
  local offsetVertical = 2
  
  if config then
    enabled = (config.Enabled ~= false)  -- default true
    autoRefresh = (config.AutoRefresh == true)
    refreshInterval = tonumber(config.RefreshInterval) or 240
    maxRefreshDuration = tonumber(config.MaxRefreshDuration) or 600
    offsetMeters = tonumber(config.OffsetMeters) or 5
    offsetRandom = (config.OffsetRandom ~= false)  -- default true
    offsetVertical = tonumber(config.OffsetVertical) or 2
  end
  
  -- If smoke is disabled, skip entirely
  if not enabled then return end
  
  -- Apply offset to smoke position so helicopters don't hover in the smoke
  local smokePos = { x = position.x, y = position.y, z = position.z }
  if offsetMeters > 0 then
    local angle = 0  -- North by default
    if offsetRandom then
      angle = math.random() * 2 * math.pi  -- Random direction
    end
    smokePos.x = smokePos.x + offsetMeters * math.cos(angle)
    smokePos.z = smokePos.z + offsetMeters * math.sin(angle)
  end
  -- Apply vertical offset (above ground level)
  smokePos.y = smokePos.y + offsetVertical
  
  -- Spawn the smoke using MOOSE COORDINATE (better appearance than trigger.action.smoke)
  local coord = COORDINATE:New(smokePos.x, smokePos.y, smokePos.z)
  if coord and coord.Smoke then
    -- MOOSE smoke method - produces better looking smoke similar to F6 cargo smoke
    if color == trigger.smokeColor.Green then
      coord:SmokeGreen()
    elseif color == trigger.smokeColor.Red then
      coord:SmokeRed()
    elseif color == trigger.smokeColor.White then
      coord:SmokeWhite()
    elseif color == trigger.smokeColor.Orange then
      coord:SmokeOrange()
    elseif color == trigger.smokeColor.Blue then
      coord:SmokeBlue()
    else
      coord:SmokeGreen()  -- default
    end
  else
    -- Fallback to trigger.action.smoke if MOOSE COORDINATE not available
    trigger.action.smoke(smokePos, color)
  end
  
  -- Schedule smoke refresh if enabled
  if autoRefresh and crateId and refreshInterval > 0 and maxRefreshDuration > 0 then

      CTLD._smokeRefreshSchedules = CTLD._smokeRefreshSchedules or {}
      
      -- Clear any existing schedule for this crate
      if CTLD._smokeRefreshSchedules[crateId] then
        timer.removeFunction(CTLD._smokeRefreshSchedules[crateId].funcId)
      end
      
      local startTime = timer.getTime()
      local capturedColor = color  -- Capture variables for the closure
      local capturedOffsetMeters = offsetMeters
      local capturedOffsetRandom = offsetRandom
      local capturedOffsetVertical = offsetVertical
      local function refreshSmoke()
        local elapsed = timer.getTime() - startTime
        if elapsed >= maxRefreshDuration then
          -- Max refresh duration exceeded, stop refreshing (safety limit)
          CTLD._smokeRefreshSchedules[crateId] = nil
          return nil
        end
        
        -- Check if crate still exists
        if not CTLD._crates or not CTLD._crates[crateId] then
          -- Crate was picked up, built, or cleaned up - stop refreshing
          CTLD._smokeRefreshSchedules[crateId] = nil
          return nil
        end
        
        -- Refresh smoke at crate position
        local crateMeta = CTLD._crates[crateId]
        if crateMeta and crateMeta.point then
          local sy = 0
          if land and land.getHeight then
            local ok, h = pcall(land.getHeight, { x = crateMeta.point.x, y = crateMeta.point.z })
            if ok and type(h) == 'number' then sy = h end
          end
          
          -- Apply offset to smoke position
          local refreshSmokePos = { x = crateMeta.point.x, y = sy, z = crateMeta.point.z }
          if capturedOffsetMeters > 0 then
            local angle = 0  -- North by default
            if capturedOffsetRandom then
              angle = math.random() * 2 * math.pi  -- Random direction
            end
            refreshSmokePos.x = refreshSmokePos.x + capturedOffsetMeters * math.cos(angle)
            refreshSmokePos.z = refreshSmokePos.z + capturedOffsetMeters * math.sin(angle)
          end
          -- Apply vertical offset
          refreshSmokePos.y = refreshSmokePos.y + capturedOffsetVertical
          
          local refreshCoord = COORDINATE:New(refreshSmokePos.x, refreshSmokePos.y, refreshSmokePos.z)
          if refreshCoord and refreshCoord.Smoke then
            if capturedColor == trigger.smokeColor.Green then
              refreshCoord:SmokeGreen()
            elseif capturedColor == trigger.smokeColor.Red then
              refreshCoord:SmokeRed()
            elseif capturedColor == trigger.smokeColor.White then
              refreshCoord:SmokeWhite()
            elseif capturedColor == trigger.smokeColor.Orange then
              refreshCoord:SmokeOrange()
            elseif capturedColor == trigger.smokeColor.Blue then
              refreshCoord:SmokeBlue()
            else
              refreshCoord:SmokeGreen()
            end
          else
            trigger.action.smoke(refreshSmokePos, capturedColor)
          end
        end
        
        return timer.getTime() + refreshInterval
      end
      
      local funcId = timer.scheduleFunction(refreshSmoke, nil, timer.getTime() + refreshInterval)
      CTLD._smokeRefreshSchedules[crateId] = { funcId = funcId, startTime = startTime }
  end

end

-- Clean up smoke refresh schedule for a crate
local function _cleanupCrateSmoke(crateId)
  if not crateId then return end
  CTLD._smokeRefreshSchedules = CTLD._smokeRefreshSchedules or {}
  if CTLD._smokeRefreshSchedules[crateId] then
    if CTLD._smokeRefreshSchedules[crateId].funcId then
      timer.removeFunction(CTLD._smokeRefreshSchedules[crateId].funcId)
    end
    CTLD._smokeRefreshSchedules[crateId] = nil
  end
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
  local pv = mz.GetPointVec3 and mz:GetPointVec3() or nil
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
    local vec2 = (VECTOR2 and VECTOR2.New) and VECTOR2:New(targetPoint.x, targetPoint.z) or { x = targetPoint.x, y = targetPoint.z }
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

-- Normalize MOOSE/DCS heading to both radians and degrees consistently.
-- Some environments may yield degrees; others radians. This returns (rad, deg).
local function _headingRadDeg(unit)
  local h = (unit and unit.GetHeading and unit:GetHeading()) or 0
  local hrad, hdeg
  if h and h > (2*math.pi + 0.1) then
    -- Looks like degrees
    hdeg = h % 360
    hrad = math.rad(hdeg)
  else
    -- Radians (normalize into [0, 2pi))
    hrad = (h or 0) % (2*math.pi)
    hdeg = math.deg(hrad)
  end
  return hrad, hdeg
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
          -- For composite recipes, show bundle availability based on component stock; otherwise show per-key stock
          if def and type(def.requires) == 'table' then
            local stockTbl = CTLD._stockByZone[zname] or {}
            local bundles = math.huge
            for reqKey, qty in pairs(def.requires) do
              local have = tonumber(stockTbl[reqKey] or 0) or 0
              local need = tonumber(qty or 0) or 0
              if need > 0 then bundles = math.min(bundles, math.floor(have / need)) end
            end
            if bundles == math.huge then bundles = 0 end
            return string.format('%s (%s) [%s: %d bundle%s]', base, suffix, zname, bundles, (bundles==1 and '' or 's'))
          else
            local stock = (CTLD._stockByZone[zname] and CTLD._stockByZone[zname][key]) or 0
            return string.format('%s (%s) [%s: %d]', base, suffix, zname, stock)
          end
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
  
  -- Initialize MEDEVAC system
  if CTLD.MEDEVAC and CTLD.MEDEVAC.Enabled then
    pcall(function() o:InitMEDEVAC() end)
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
  local coachCfg = CTLD.HoverCoachConfig or {}
  if coachCfg.enabled then
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

  -- Initialize per-player coach preference from default
  local gname = group:GetName()
  CTLD._coachOverride = CTLD._coachOverride or {}
  if CTLD._coachOverride[gname] == nil then
    local coachCfg = CTLD.HoverCoachConfig or {}
    CTLD._coachOverride[gname] = coachCfg.coachOnByDefault
  end

  -- Top-level roots per requested structure
  local opsRoot   = MENU_GROUP:New(group, 'Operations', root)
  local logRoot   = MENU_GROUP:New(group, 'Logistics', root)
  local toolsRoot = MENU_GROUP:New(group, 'Field Tools', root)
  local navRoot   = MENU_GROUP:New(group, 'Navigation', root)
  local adminRoot = MENU_GROUP:New(group, 'Admin/Help', root)

  -- Admin/Help -> Player Guides (moved to top of Admin/Help)
  local help = MENU_GROUP:New(group, 'Player Guides', adminRoot)
  MENU_GROUP_COMMAND:New(group, 'CTLD Basics (2-minute tour)', help, function()
    local lines = {}
    table.insert(lines, 'CTLD Basics - 2 minute tour')
    table.insert(lines, '')
    table.insert(lines, 'Loop: Request -> Deliver -> Build -> Fight')
    table.insert(lines, '- Request crates at an ACTIVE Supply Zone (Pickup).')
    table.insert(lines, '- Deliver crates to the build point (within Build Radius).')
    table.insert(lines, '- Build units or sites with "Build Here" (confirm + cooldown).')
    table.insert(lines, '- Optional: set Attack or Defend behavior when building.')
    table.insert(lines, '')
    table.insert(lines, 'Key concepts:')
    table.insert(lines, '- Zones: Pickup (supply), Drop (mission targets), FOB (forward supply).')
    table.insert(lines, '- Inventory: stock is tracked per zone; requests consume stock there.')
    table.insert(lines, '- FOBs: building one creates a local supply point with seeded stock.')
    table.insert(lines, '- Advanced: SAM site repair crates, AI attack orders, EWR/JTAC support.')
    MESSAGE:New(table.concat(lines, '\n'), 35):ToGroup(group)
  end)
  MENU_GROUP_COMMAND:New(group, 'Zones - Guide', help, function()
    local lines = {}
    table.insert(lines, 'CTLD Zones - Guide')
    table.insert(lines, '')
    table.insert(lines, 'Zone types:')
    table.insert(lines, '- Pickup (Supply): Request crates and load troops here. Crate requests require proximity to an ACTIVE pickup zone (default within 10 km).')
    table.insert(lines, '- Drop: Mission-defined delivery or rally areas. Some missions may require delivery or deployment at these zones (see briefing).')
    table.insert(lines, '- FOB: Forward Operating Base areas. Some recipes (FOB Site) can be built here; if FOB restriction is enabled, FOB-only builds must be inside an FOB zone.')
    table.insert(lines, '')
    table.insert(lines, 'Colors and map marks:')
    table.insert(lines, '- Pickup zone crate spawns are marked with smoke in the configured color. Admin/Help -> Draw CTLD Zones on Map draws zone circles and labels on F10.')
    table.insert(lines, '- Use Admin/Help -> Clear CTLD Map Drawings to remove the drawings. Drawings are read-only if configured.')
    table.insert(lines, '')
    table.insert(lines, 'How to use zones:')
    table.insert(lines, '- To request crates: move within the pickup zone distance and use CTLD -> Request Crate.')
    table.insert(lines, '- To load troops: must be inside a Pickup zone if troop loading restriction is enabled.')
    table.insert(lines, '- Navigation: CTLD -> Coach & Nav -> Vectors to Nearest Pickup Zone gives bearing and range.')
    table.insert(lines, '- Activation: Zones can be active/inactive per mission logic; inactive pickup zones block crate requests.')
    table.insert(lines, '')
    table.insert(lines, string.format('Build Radius: about %d m to collect nearby crates when building.', self.Config.BuildRadius or 60))
    table.insert(lines, string.format('Pickup Zone Max Distance: about %d m to request crates.', self.Config.PickupZoneMaxDistance or 10000))
    MESSAGE:New(table.concat(lines, '\n'), 40):ToGroup(group)
  end)
  MENU_GROUP_COMMAND:New(group, 'Inventory - How It Works', help, function()
    local inv = self.Config.Inventory or {}
    local enabled = inv.Enabled ~= false
    local showHint = inv.ShowStockInMenu == true
    local fobPct = math.floor(((inv.FOBStockFactor or 0.25) * 100) + 0.5)
    local lines = {}
    table.insert(lines, 'CTLD Inventory - How It Works')
    table.insert(lines, '')
    table.insert(lines, 'Overview:')
    table.insert(lines, '- Inventory is tracked per Supply (Pickup) Zone and per FOB. Requests consume stock at that location.')
    table.insert(lines, string.format('- Inventory is %s.', enabled and 'ENABLED' or 'DISABLED'))
    table.insert(lines, '')
    table.insert(lines, 'Starting stock:')
    table.insert(lines, '- Each configured Supply Zone is seeded from the catalog initialStock for every crate type at mission start.')
    table.insert(lines, string.format('- When you build a FOB, it creates a small Supply Zone with stock seeded at ~%d%% of initialStock.', fobPct))
    table.insert(lines, '')
    table.insert(lines, 'Requesting crates:')
    table.insert(lines, '- You must be within range of an ACTIVE Supply Zone to request crates; stock is decremented on spawn.')
    table.insert(lines, '- If out of stock for a type at that zone, requests are denied for that type until resupplied (mission logic).')
    table.insert(lines, '')
    table.insert(lines, 'UI hints:')
    table.insert(lines, string.format('- Show stock in menu labels: %s.', showHint and 'ON' or 'OFF'))
    table.insert(lines, '- Some missions may include an "In Stock Here" list showing only items available at the nearest zone.')
    MESSAGE:New(table.concat(lines, '\n'), 40):ToGroup(group)
  end)

  MENU_GROUP_COMMAND:New(group, 'Troop Transport & JTAC Use', help, function()
    local lines = {}
    table.insert(lines, 'Troop Transport & JTAC Use')
    table.insert(lines, '')
    table.insert(lines, 'Troops:')
    table.insert(lines, '- Load inside an ACTIVE Supply Zone (if mission enforces it).')
    table.insert(lines, '- Deploy with Defend (hold) or Attack (advance to targets/bases).')
    table.insert(lines, '- Attack uses a search radius and moves at configured speed.')
    table.insert(lines, '')
    table.insert(lines, 'JTAC:')
    table.insert(lines, '- Build JTAC units (MRAP/Tigr or drones) to support target marking.')
    table.insert(lines, '- JTAC helps with target designation/SA; details depend on mission setup.')
    MESSAGE:New(table.concat(lines, '\n'), 35):ToGroup(group)
  end)
  MENU_GROUP_COMMAND:New(group, 'Crates 101: Requesting and Handling', help, function()
    local lines = {}
    table.insert(lines, 'Crates 101 - Requesting and Handling')
    table.insert(lines, '')
    table.insert(lines, '- Request crates near an ACTIVE Supply Zone; max distance is configurable.')
    table.insert(lines, '- Menu labels show the total crates required for a recipe.')
    table.insert(lines, '- Drop crates close together but avoid overlap; smoke marks spawns.')
    table.insert(lines, '- Use Coach & Nav tools: vectors to nearest pickup zone, re-mark crate with smoke.')
    MESSAGE:New(table.concat(lines, '\n'), 35):ToGroup(group)
  end)
  MENU_GROUP_COMMAND:New(group, 'Hover Pickup & Slingloading', help, function()
    local coachCfg = CTLD.HoverCoachConfig or {}
    local aglMin = (coachCfg.thresholds and coachCfg.thresholds.aglMin) or 5
    local aglMax = (coachCfg.thresholds and coachCfg.thresholds.aglMax) or 20
    local capGS = (coachCfg.thresholds and coachCfg.thresholds.captureGS) or (4/3.6)
    local hold = (coachCfg.thresholds and coachCfg.thresholds.stabilityHold) or 1.8
    local lines = {}
    table.insert(lines, 'Hover Pickup & Slingloading')
    table.insert(lines, '')
    table.insert(lines, string.format('- Hover pickup: hold AGL %d-%d m, speed < %.1f m/s, for ~%.1f s to auto-load.', aglMin, aglMax, capGS, hold))
    table.insert(lines, '- Keep steady within ~15 m of the crate; Hover Coach gives cues if enabled.')
    table.insert(lines, '- Slingloading tips: avoid rotor wash over stacks; approach from upwind; re-mark crate with smoke if needed.')
    MESSAGE:New(table.concat(lines, '\n'), 35):ToGroup(group)
  end)
  MENU_GROUP_COMMAND:New(group, 'Build System: Build Here and Advanced', help, function()
    local br = self.Config.BuildRadius or 60
    local win = self.Config.BuildConfirmWindowSeconds or 10
    local cd = self.Config.BuildCooldownSeconds or 60
    local lines = {}
    table.insert(lines, 'Build System - Build Here and Advanced')
    table.insert(lines, '')
    table.insert(lines, string.format('- Build Here collects crates within ~%d m. Double-press within %d s to confirm.', br, win))
    table.insert(lines, string.format('- Cooldown: about %d s per group after a successful build.', cd))
    table.insert(lines, '- Advanced Build lets you choose Defend (hold) or Attack (move).')
    table.insert(lines, '- Static or unsuitable units will hold even if Attack is chosen.')
    table.insert(lines, '- FOB-only recipes must be inside an FOB zone when restriction is enabled.')
    MESSAGE:New(table.concat(lines, '\n'), 40):ToGroup(group)
  end)
  MENU_GROUP_COMMAND:New(group, 'FOBs: Forward Supply & Why They Matter', help, function()
    local fobPct = math.floor(((self.Config.Inventory and self.Config.Inventory.FOBStockFactor or 0.25) * 100) + 0.5)
    local lines = {}
    table.insert(lines, 'FOBs - Forward Supply and Why They Matter')
    table.insert(lines, '')
    table.insert(lines, '- Build a FOB by assembling its crate recipe (see Recipe Info).')
    table.insert(lines, string.format('- A new local Supply Zone is created and seeded at ~%d%% of initial stock.', fobPct))
    table.insert(lines, '- FOBs shorten logistics legs and increase throughput toward the front.')
    table.insert(lines, '- If enabled, FOB-only builds must occur inside FOB zones.')
    MESSAGE:New(table.concat(lines, '\n'), 35):ToGroup(group)
  end)
  MENU_GROUP_COMMAND:New(group, 'SAM Sites: Building, Repairing, and Augmenting', help, function()
    local br = self.Config.BuildRadius or 60
    local lines = {}
    table.insert(lines, 'SAM Sites - Building, Repairing, and Augmenting')
    table.insert(lines, '')
    table.insert(lines, 'Build:')
    table.insert(lines, '- Assemble site recipes using the required component crates (see menu labels). Build Here will place the full site.')
    table.insert(lines, '')
    table.insert(lines, 'Repair/Augment (merged):')
    table.insert(lines, '- Request the matching "Repair/Launcher +1" crate for your site type (HAWK, Patriot, KUB, BUK).')
    table.insert(lines, string.format('- Drop repair crate(s) within ~%d m of the site, then use Build Here (confirm window applies).', br))
    table.insert(lines, '- The nearest matching site (within a local search) is respawned fully repaired; +1 launcher per crate, up to caps.')
    table.insert(lines, '- Caps: HAWK 6, Patriot 6, KUB 3, BUK 6. Extra crates beyond the cap are not consumed.')
    table.insert(lines, '- Must match coalition and site type; otherwise no changes are applied.')
    table.insert(lines, '- Respawn is required to apply repairs/augmentation due to DCS limitations.')
    table.insert(lines, '')
    table.insert(lines, 'Placement tips:')
    table.insert(lines, '- Space launchers to avoid masking; keep radars with good line-of-sight; avoid fratricide arcs.')
    MESSAGE:New(table.concat(lines, '\n'), 45):ToGroup(group)
  end)

  -- Operations -> Troop Transport
  local troopsRoot = MENU_GROUP:New(group, 'Troop Transport', opsRoot)
  CMD('Load Troops', troopsRoot, function() self:LoadTroops(group) end)
  -- Optional typed troop loading submenu
  do
    local typedRoot = MENU_GROUP:New(group, 'Load Troops (Type)', troopsRoot)
    local tcfg = (self.Config.Troops and self.Config.Troops.TroopTypes) or {}
    -- Stable order per common roles
    local order = { 'AS', 'AA', 'AT', 'AR' }
    local seen = {}
    local function addItem(key)
      local def = tcfg[key]
      if not def then return end
      local label = (def.label or key)
      local size = def.size or 6
      CMD(string.format('%s (%d)', label, size), typedRoot, function()
        self:LoadTroops(group, { typeKey = key })
      end)
      seen[key] = true
    end
    for _,k in ipairs(order) do addItem(k) end
    -- Add any additional custom types not in the default order
    for k,_ in pairs(tcfg) do if not seen[k] then addItem(k) end end
  end
  do
    local tr = (self.Config.AttackAI and self.Config.AttackAI.TroopSearchRadius) or 3000
    CMD('Deploy [Hold Position]', troopsRoot, function() self:UnloadTroops(group, { behavior = 'defend' }) end)
    CMD(string.format('Deploy [Attack (%dm)]', tr), troopsRoot, function() self:UnloadTroops(group, { behavior = 'attack' }) end)
  end

  -- Operations -> Build
  local buildRoot = MENU_GROUP:New(group, 'Build', opsRoot)
  CMD('Build Here', buildRoot, function() self:BuildAtGroup(group) end)
  local buildAdvRoot = MENU_GROUP:New(group, 'Build (Advanced)', buildRoot)
  -- Buildable Near You (dynamic) lives directly under Build
  self:_BuildOrRefreshBuildAdvancedMenu(group, buildRoot)
  -- Refresh Buildable List (refreshes the list under Build)
  MENU_GROUP_COMMAND:New(group, 'Refresh Buildable List', buildRoot, function()
    self:_BuildOrRefreshBuildAdvancedMenu(group, buildRoot)
    MESSAGE:New('Buildable list refreshed.', 6):ToGroup(group)
  end)

  -- Logistics -> Request Crate and Recipe Info
  local reqRoot = MENU_GROUP:New(group, 'Request Crate', logRoot)
  local infoRoot = MENU_GROUP:New(group, 'Recipe Info', logRoot)
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
        if def and type(def.requires) == 'table' then
          -- Composite recipe: request full bundle of component crates
          CMD(label, parent, function() self:RequestRecipeBundleForGroup(group, key) end)
        else
          CMD(label, parent, function() self:RequestCrateForGroup(group, key) end)
        end
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
        if def and type(def.requires) == 'table' then
          CMD(label, reqRoot, function() self:RequestRecipeBundleForGroup(group, key) end)
        else
          CMD(label, reqRoot, function() self:RequestCrateForGroup(group, key) end)
        end
        CMD(((def and (def.menu or def.description)) or key)..' (info)', infoRoot, function()
          local text = self:_formatRecipeInfo(key, def)
          _msgGroup(group, text)
        end)
      end
    end
  end
  -- Logistics -> Crate Management
  local crateMgmt = MENU_GROUP:New(group, 'Crate Management', logRoot)
  CMD('Drop One Loaded Crate', crateMgmt, function() self:DropLoadedCrates(group, 1) end)
  CMD('Drop All Loaded Crates', crateMgmt, function() self:DropLoadedCrates(group, -1) end)
  CMD('Re-mark Nearest Crate (Smoke)', crateMgmt, function()
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
      local sx, sz = bestMeta.point.x, bestMeta.point.z
      local sy = 0
      if land and land.getHeight then
        -- land.getHeight expects Vec2 where y is z
        local ok, h = pcall(land.getHeight, { x = sx, y = sz })
        if ok and type(h) == 'number' then sy = h end
      end
      -- Use new smoke helper with crate ID for refresh scheduling
      local smokeColor = (zdef and zdef.smoke) or self.Config.PickupZoneSmokeColor
      _spawnCrateSmoke({ x = sx, y = sy, z = sz }, smokeColor, self.Config.CrateSmoke, bestName)
      _eventSend(self, group, nil, 'crate_re_marked', { id = bestName, mark = 'smoke' })
    else
      _msgGroup(group, 'No friendly crates found to mark.')
    end
  end)

  -- Field Tools
  CMD('Create Drop Zone (AO)', toolsRoot, function() self:CreateDropZoneAtGroup(group) end)
  local smokeRoot = MENU_GROUP:New(group, 'Smoke My Location', toolsRoot)
  local function smokeHere(color)
    local unit = group:GetUnit(1)
    if not unit or not unit:IsAlive() then return end
    local p = unit:GetPointVec3()
    -- Use full Vec3 to ensure correct placement
    trigger.action.smoke({ x = p.x, y = p.y, z = p.z }, color)
  end
  MENU_GROUP_COMMAND:New(group, 'Green', smokeRoot, function() smokeHere(trigger.smokeColor.Green) end)
  MENU_GROUP_COMMAND:New(group, 'Red', smokeRoot, function() smokeHere(trigger.smokeColor.Red) end)
  MENU_GROUP_COMMAND:New(group, 'White', smokeRoot, function() smokeHere(trigger.smokeColor.White) end)
  MENU_GROUP_COMMAND:New(group, 'Orange', smokeRoot, function() smokeHere(trigger.smokeColor.Orange) end)
  MENU_GROUP_COMMAND:New(group, 'Blue', smokeRoot, function() smokeHere(trigger.smokeColor.Blue) end)

  -- Navigation
  local gname = group:GetName()
  CMD('Request Vectors to Nearest Crate', navRoot, function()
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

  -- Navigation -> Smoke Nearest Zone (Pickup/Drop/FOB)
  CMD('Smoke Nearest Zone (Pickup/Drop/FOB)', navRoot, function()
    local unit = group:GetUnit(1)
    if not unit or not unit:IsAlive() then return end

    -- Build lists of active zones by kind in a format usable by _nearestZonePoint
    local function collectActive(kind)
      if kind == 'Pickup' then
        return self:_collectActivePickupDefs()
      elseif kind == 'Drop' then
        local out = {}
        for _, mz in ipairs(self.DropZones or {}) do
          if mz and mz.GetName then
            local n = mz:GetName()
            if (self._ZoneActive and self._ZoneActive.Drop and self._ZoneActive.Drop[n] ~= false) then
              table.insert(out, { name = n })
            end
          end
        end
        return out
      elseif kind == 'FOB' then
        local out = {}
        for _, mz in ipairs(self.FOBZones or {}) do
          if mz and mz.GetName then
            local n = mz:GetName()
            if (self._ZoneActive and self._ZoneActive.FOB and self._ZoneActive.FOB[n] ~= false) then
              table.insert(out, { name = n })
            end
          end
        end
        return out
      end
      return {}
    end

    local bestKind, bestZone, bestDist
    for _, k in ipairs({ 'Pickup', 'Drop', 'FOB' }) do
      local list = collectActive(k)
      if list and #list > 0 then
        local z, d = _nearestZonePoint(unit, list)
        if z and d and ((not bestDist) or d < bestDist) then
          bestKind, bestZone, bestDist = k, z, d
        end
      end
    end

    if not bestZone then
      _msgGroup(group, 'No zones available to smoke.')
      return
    end

    -- Determine smoke point (zone center)
    -- _getZoneCenterAndRadius returns (center, radius); call directly to capture center
    local center
    if self._getZoneCenterAndRadius then center = select(1, self:_getZoneCenterAndRadius(bestZone)) end
    if not center then
      local v3 = bestZone:GetPointVec3()
      center = { x = v3.x, y = v3.y or 0, z = v3.z }
    else
      center = { x = center.x, y = center.y or 0, z = center.z }
    end

    -- Choose smoke color per kind (fallbacks if not configured)
    local color = (bestKind == 'Pickup' and (self.Config.PickupZoneSmokeColor or trigger.smokeColor.Green))
                  or (bestKind == 'Drop' and trigger.smokeColor.Blue)
                  or trigger.smokeColor.White

    if trigger and trigger.action and trigger.action.smoke then
      trigger.action.smoke(center, color)
      _msgGroup(group, string.format('Smoked nearest %s zone: %s', bestKind, bestZone:GetName()))
    else
      _msgGroup(group, 'Smoke not available in this environment.')
    end
  end)

  -- Navigation -> MEDEVAC menu items (if MEDEVAC enabled)
  if CTLD.MEDEVAC and CTLD.MEDEVAC.Enabled then
    CMD('Vectors to Nearest MEDEVAC Crew', navRoot, function()
      local unit = group:GetUnit(1)
      if not unit or not unit:IsAlive() then return end
      
      local pos = unit:GetPointVec3()
      local isMetric = _getPlayerIsMetric(unit)
      local nearest = nil
      local nearestDist = math.huge
      
      -- Find nearest crew of same coalition
      for crewName, crewData in pairs(CTLD._medevacCrews or {}) do
        if crewData.side == self.Side and not crewData.pickedUp then
          local dx = crewData.position.x - pos.x
          local dz = crewData.position.z - pos.z
          local dist = math.sqrt(dx*dx + dz*dz)
          
          if dist < nearestDist then
            nearestDist = dist
            nearest = crewData
          end
        end
      end
      
      if not nearest then
        _msgGroup(group, 'No active MEDEVAC requests.')
        return
      end
      
      local brg = _bearingDeg({ x = pos.x, z = pos.z }, { x = nearest.position.x, z = nearest.position.z })
      local v, u = _fmtRange(nearestDist, isMetric)
      local timeRemain = math.floor((nearest.timeout - timer.getTime()) / 60)
      
      _msgGroup(group, _fmtTemplate(CTLD.Messages.medevac_vectors, {
        vehicle = nearest.vehicleType,
        brg = brg,
        rng = v,
        rng_u = u,
        time_remain = timeRemain
      }))
    end)
    
    CMD('Vectors to Nearest MASH', navRoot, function()
      local unit = group:GetUnit(1)
      if not unit or not unit:IsAlive() then return end
      
      local pos = unit:GetPointVec3()
      local isMetric = _getPlayerIsMetric(unit)
      local nearest = nil
      local nearestDist = math.huge
      
      -- Find nearest MASH of same coalition
      for _, mashData in ipairs(CTLD._mashZones or {}) do
        if mashData.side == self.Side then
          local dx = mashData.position.x - pos.x
          local dz = mashData.position.z - pos.z
          local dist = math.sqrt(dx*dx + dz*dz)
          
          if dist < nearestDist then
            nearestDist = dist
            nearest = mashData
          end
        end
      end
      
      if not nearest then
        _msgGroup(group, 'No active MASH zones.')
        return
      end
      
      local brg = _bearingDeg({ x = pos.x, z = pos.z }, { x = nearest.position.x, z = nearest.position.z })
      local v, u = _fmtRange(nearestDist, isMetric)
      local mashName = nearest.isMobile and ('Mobile MASH ' .. (nearest.id:match('_(%d+)$') or '?')) or nearest.catalogKey
      
      _msgGroup(group, string.format('Nearest MASH: %s, bearing %d°, range %s %s', mashName, brg, v, u))
    end)
  end

  -- Hover Coach (at end of Navigation submenu)
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

  -- Admin/Help
  -- Status & map controls
  CMD('Show CTLD Status', adminRoot, function()
    local crates = 0
    for _ in pairs(CTLD._crates) do crates = crates + 1 end
    local msg = string.format('CTLD Status:\nActive crates: %d\nPickup zones: %d\nDrop zones: %d\nFOB zones: %d\nBuild Confirm: %s (%ds window)\nBuild Cooldown: %s (%ds)'
      , crates, #(self.PickupZones or {}), #(self.DropZones or {}), #(self.FOBZones or {})
      , self.Config.BuildConfirmEnabled and 'ON' or 'OFF', self.Config.BuildConfirmWindowSeconds or 0
      , self.Config.BuildCooldownEnabled and 'ON' or 'OFF', self.Config.BuildCooldownSeconds or 0)
    
    -- Add MEDEVAC info if enabled
    if CTLD.MEDEVAC and CTLD.MEDEVAC.Enabled then
      local activeRequests = 0
      for _, data in pairs(CTLD._medevacCrews or {}) do
        if data.side == self.Side and not data.pickedUp then
          activeRequests = activeRequests + 1
        end
      end
      local salvage = CTLD._salvagePoints[self.Side] or 0
      local mashCount = 0
      for _, m in ipairs(CTLD._mashZones or {}) do
        if m.side == self.Side then mashCount = mashCount + 1 end
      end
      msg = msg .. string.format('\n\nMEDEVAC:\nActive requests: %d\nMASH zones: %d\nSalvage points: %d', 
        activeRequests, mashCount, salvage)
    end
    
    MESSAGE:New(msg, 20):ToGroup(group)
  end)
  CMD('Draw CTLD Zones on Map', adminRoot, function()
    self:DrawZonesOnMap()
    MESSAGE:New('CTLD zones drawn on F10 map.', 8):ToGroup(group)
  end)
  CMD('Clear CTLD Map Drawings', adminRoot, function()
    self:ClearMapDrawings()
    MESSAGE:New('CTLD map drawings cleared.', 8):ToGroup(group)
  end)
  
  -- MEDEVAC Statistics (if enabled)
  if CTLD.MEDEVAC and CTLD.MEDEVAC.Enabled and CTLD.MEDEVAC.Statistics and CTLD.MEDEVAC.Statistics.Enabled then
    CMD('Show MEDEVAC Statistics', adminRoot, function()
      local stats = CTLD._medevacStats[self.Side] or {}
      local lines = {}
      table.insert(lines, 'MEDEVAC Statistics:')
      table.insert(lines, '')
      table.insert(lines, string.format('Crews spawned: %d', stats.spawned or 0))
      table.insert(lines, string.format('Crews rescued: %d', stats.rescued or 0))
      table.insert(lines, string.format('Delivered to MASH: %d', stats.delivered or 0))
      table.insert(lines, string.format('Timed out: %d', stats.timedOut or 0))
      table.insert(lines, string.format('Killed in action: %d', stats.killed or 0))
      table.insert(lines, '')
      table.insert(lines, string.format('Vehicles respawned: %d', stats.vehiclesRespawned or 0))
      table.insert(lines, string.format('Salvage earned: %d', stats.salvageEarned or 0))
      table.insert(lines, string.format('Salvage used: %d', stats.salvageUsed or 0))
      table.insert(lines, string.format('Current salvage: %d', CTLD._salvagePoints[self.Side] or 0))
      
      MESSAGE:New(table.concat(lines, '\n'), 30):ToGroup(group)
    end)
  end

  -- Admin/Help -> Debug
  local debugMenu = MENU_GROUP:New(group, 'Debug', adminRoot)
  CMD('Enable logging', debugMenu, function()
    self.Config.Debug = true
    env.info(string.format('[Moose_CTLD][%s] Debug ENABLED via Admin menu', tostring(self.Side)))
    MESSAGE:New('CTLD Debug logging ENABLED', 8):ToGroup(group)
  end)
  CMD('Disable logging', debugMenu, function()
    self.Config.Debug = false
    env.info(string.format('[Moose_CTLD][%s] Debug DISABLED via Admin menu', tostring(self.Side)))
    MESSAGE:New('CTLD Debug logging DISABLED', 8):ToGroup(group)
  end)

  -- Admin/Help -> Player Guides (moved earlier)

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
  -- Remove existing dynamic children by creating a fresh inner menu under the provided root
  local dynRoot = MENU_GROUP:New(group, 'Buildable Near You', rootMenu)

  local unit = group:GetUnit(1)
  if not unit or not unit:IsAlive() then return end
  local p = unit:GetPointVec3()
  local here = { x = p.x, z = p.z }
  local hdgRad, _ = _headingRadDeg(unit)
  local buildOffset = math.max(0, tonumber(self.Config.BuildSpawnOffset or 0) or 0)
  local spawnAt = (buildOffset > 0) and { x = here.x + math.sin(hdgRad) * buildOffset, z = here.z + math.cos(hdgRad) * buildOffset } or { x = here.x, z = here.z }
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
  local hdgRad, hdgDeg = _headingRadDeg(unit)
  local buildOffset = math.max(0, tonumber(self.Config.BuildSpawnOffset or 0) or 0)
  local spawnAt = (buildOffset > 0) and { x = here.x + math.sin(hdgRad) * buildOffset, z = here.z + math.cos(hdgRad) * buildOffset } or { x = here.x, z = here.z }
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
        _cleanupCrateSmoke(c.name)  -- Clean up smoke refresh schedule
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
  local gdata = def.build({ x = spawnAt.x, z = spawnAt.z }, hdgDeg, def.side or self.Side)
    _eventSend(self, group, nil, 'build_started', { build = def.description or recipeKey })
    local g = _coalitionAddGroup(def.side or self.Side, def.category or Group.Category.GROUND, gdata)
    if not g then _eventSend(self, group, nil, 'build_failed', { reason = 'DCS group spawn error' }); return end
    for reqKey,qty in pairs(def.requires) do consumeCrates(reqKey, qty or 0) end
    _eventSend(self, nil, self.Side, 'build_success_coalition', { build = def.description or recipeKey, player = _playerNameFromGroup(group) })
    if def.isFOB then pcall(function() self:_CreateFOBPickupZone({ x = spawnAt.x, z = spawnAt.z }, def, hdg) end) end
    if def.isMobileMASH then pcall(function() self:_CreateMobileMASH(g, { x = spawnAt.x, z = spawnAt.z }, def) end) end
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
  local gdata = def.build({ x = spawnAt.x, z = spawnAt.z }, hdgDeg, def.side or self.Side)
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
  -- Player Help submenu (moved to top of Admin/Help)
  local helpMenu = MENU_COALITION:New(self.Side, 'Player Help', root)
  -- Removed standalone "Repair - How To" in favor of consolidated SAM Sites help
  MENU_COALITION_COMMAND:New(self.Side, 'Zones - Guide', helpMenu, function()
    local lines = {}
    table.insert(lines, 'CTLD Zones - Guide')
    table.insert(lines, '')
    table.insert(lines, 'Zone types:')
    table.insert(lines, '- Pickup (Supply): Request crates and load troops here. Crate requests require proximity to an ACTIVE pickup zone (default within 10 km).')
    table.insert(lines, '- Drop: Mission-defined delivery or rally areas. Some missions may require delivery or deployment at these zones (see briefing).')
    table.insert(lines, '- FOB: Forward Operating Base areas. Some recipes (FOB Site) can be built here; if FOB restriction is enabled, FOB-only builds must be inside an FOB zone.')
    table.insert(lines, '')
    table.insert(lines, 'Colors and map marks:')
    table.insert(lines, '- Pickup zone crate spawns are marked with smoke in the configured color. Admin/Help -> Draw CTLD Zones on Map draws zone circles and labels on F10.')
    table.insert(lines, '- Use Admin/Help -> Clear CTLD Map Drawings to remove the drawings. Drawings are read-only if configured.')
    table.insert(lines, '')
    table.insert(lines, 'How to use zones:')
    table.insert(lines, '- To request crates: move within the pickup zone distance and use CTLD -> Request Crate.')
    table.insert(lines, '- To load troops: must be inside a Pickup zone if troop loading restriction is enabled.')
    table.insert(lines, '- Navigation: CTLD -> Coach & Nav -> Vectors to Nearest Pickup Zone gives bearing and range.')
    table.insert(lines, '- Activation: Zones can be active/inactive per mission logic; inactive pickup zones block crate requests.')
    table.insert(lines, '')
    table.insert(lines, string.format('- Build Radius: about %d m to collect nearby crates when building.', self.Config.BuildRadius or 60))
    table.insert(lines, string.format('- Pickup Zone Max Distance: about %d m to request crates (configurable).', self.Config.PickupZoneMaxDistance or 10000))
    _msgCoalition(self.Side, table.concat(lines, '\n'), 40)
  end)
  MENU_COALITION_COMMAND:New(self.Side, 'Inventory - How It Works', helpMenu, function()
    local inv = self.Config.Inventory or {}
    local enabled = inv.Enabled ~= false
    local showHint = inv.ShowStockInMenu == true
    local fobPct = math.floor(((inv.FOBStockFactor or 0.25) * 100) + 0.5)
    local lines = {}
    table.insert(lines, 'CTLD Inventory - How It Works')
    table.insert(lines, '')
    table.insert(lines, 'Overview:')
    table.insert(lines, '- Inventory is tracked per Supply (Pickup) Zone and per FOB. Requests consume stock at that location.')
    table.insert(lines, string.format('- Inventory is %s.', enabled and 'ENABLED' or 'DISABLED'))
    table.insert(lines, '')
    table.insert(lines, 'Starting stock:')
    table.insert(lines, '- Each configured Supply Zone is seeded from the catalog initialStock for every crate type at mission start.')
    table.insert(lines, string.format('- When you build a FOB, it creates a small Supply Zone with stock seeded at ~%d%% of initialStock.', fobPct))
    table.insert(lines, '')
    table.insert(lines, 'Requesting crates:')
    table.insert(lines, '- You must be within range of an ACTIVE Supply Zone to request crates; stock is decremented on spawn.')
    table.insert(lines, '- If out of stock for a type at that zone, requests are denied for that type until resupplied (mission logic).')
    table.insert(lines, '')
    table.insert(lines, 'UI hints:')
    table.insert(lines, string.format('- Show stock in menu labels: %s.', showHint and 'ON' or 'OFF'))
    table.insert(lines, '- Some missions may include an "In Stock Here" list showing only items available at the nearest zone.')
    _msgCoalition(self.Side, table.concat(lines, '\n'), 40)
  end)
  MENU_COALITION_COMMAND:New(self.Side, 'CTLD Basics (2-minute tour)', helpMenu, function()
    local isMetric = true
    local lines = {}
    table.insert(lines, 'CTLD Basics - 2 minute tour')
    table.insert(lines, '')
    table.insert(lines, 'Loop: Request -> Deliver -> Build -> Fight')
    table.insert(lines, '- Request crates at an ACTIVE Supply Zone (Pickup).')
    table.insert(lines, '- Deliver crates to the build point (within Build Radius).')
    table.insert(lines, '- Build units or sites with "Build Here" (confirm + cooldown).')
    table.insert(lines, '- Optional: set Attack or Defend behavior when building.')
    table.insert(lines, '')
    table.insert(lines, 'Key concepts:')
    table.insert(lines, '- Zones: Pickup (supply), Drop (mission targets), FOB (forward supply).')
    table.insert(lines, '- Inventory: stock is tracked per zone; requests consume stock there.')
    table.insert(lines, '- FOBs: building one creates a local supply point with seeded stock.')
    table.insert(lines, '- Advanced: SAM site repair crates, AI attack orders, EWR/JTAC support.')
    _msgCoalition(self.Side, table.concat(lines, '\n'), 35)
  end)
  MENU_COALITION_COMMAND:New(self.Side, 'Troop Transport & JTAC Use', helpMenu, function()
    local lines = {}
    table.insert(lines, 'Troop Transport & JTAC Use')
    table.insert(lines, '')
    table.insert(lines, 'Troops:')
    table.insert(lines, '- Load inside an ACTIVE Supply Zone (if mission enforces it).')
    table.insert(lines, '- Deploy with Defend (hold) or Attack (advance to targets/bases).')
    table.insert(lines, '- Attack uses a search radius and moves at configured speed.')
    table.insert(lines, '')
    table.insert(lines, 'JTAC:')
    table.insert(lines, '- Build JTAC units (MRAP/Tigr or drones) to support target marking.')
    table.insert(lines, '- JTAC helps with target designation/SA; details depend on mission setup.')
    _msgCoalition(self.Side, table.concat(lines, '\n'), 35)
  end)
  MENU_COALITION_COMMAND:New(self.Side, 'Crates 101: Requesting and Handling', helpMenu, function()
    local lines = {}
    table.insert(lines, 'Crates 101 - Requesting and Handling')
    table.insert(lines, '')
    table.insert(lines, '- Request crates near an ACTIVE Supply Zone; max distance is configurable.')
    table.insert(lines, '- Menu labels show the total crates required for a recipe.')
    table.insert(lines, '- Drop crates close together but avoid overlap; smoke marks spawns.')
    table.insert(lines, '- Use Coach & Nav tools: vectors to nearest pickup zone, re-mark crate with smoke.')
    _msgCoalition(self.Side, table.concat(lines, '\n'), 35)
  end)
  MENU_COALITION_COMMAND:New(self.Side, 'Hover Pickup & Slingloading', helpMenu, function()
    local coachCfg = CTLD.HoverCoachConfig or {}
    local aglMin = (coachCfg.thresholds and coachCfg.thresholds.aglMin) or 5
    local aglMax = (coachCfg.thresholds and coachCfg.thresholds.aglMax) or 20
    local capGS = (coachCfg.thresholds and coachCfg.thresholds.captureGS) or (4/3.6)
    local hold = (coachCfg.thresholds and coachCfg.thresholds.stabilityHold) or 1.8
    local lines = {}
    table.insert(lines, 'Hover Pickup & Slingloading')
    table.insert(lines, '')
    table.insert(lines, string.format('- Hover pickup: hold AGL %d-%d m, speed < %.1f m/s, for ~%.1f s to auto-load.', aglMin, aglMax, capGS, hold))
    table.insert(lines, '- Keep steady within ~15 m of the crate; Hover Coach gives cues if enabled.')
    table.insert(lines, '- Slingloading tips: avoid rotor wash over stacks; approach from upwind; re-mark crate with smoke if needed.')
    _msgCoalition(self.Side, table.concat(lines, '\n'), 35)
  end)
  MENU_COALITION_COMMAND:New(self.Side, 'Build System: Build Here and Advanced', helpMenu, function()
    local br = self.Config.BuildRadius or 60
    local win = self.Config.BuildConfirmWindowSeconds or 10
    local cd = self.Config.BuildCooldownSeconds or 60
    local lines = {}
    table.insert(lines, 'Build System - Build Here and Advanced')
    table.insert(lines, '')
    table.insert(lines, string.format('- Build Here collects crates within ~%d m. Double-press within %d s to confirm.', br, win))
    table.insert(lines, string.format('- Cooldown: about %d s per group after a successful build.', cd))
    table.insert(lines, '- Advanced Build lets you choose Defend (hold) or Attack (move).')
    table.insert(lines, '- Static or unsuitable units will hold even if Attack is chosen.')
    table.insert(lines, '- FOB-only recipes must be inside an FOB zone when restriction is enabled.')
    _msgCoalition(self.Side, table.concat(lines, '\n'), 40)
  end)
  MENU_COALITION_COMMAND:New(self.Side, 'FOBs: Forward Supply & Why They Matter', helpMenu, function()
    local fobPct = math.floor(((self.Config.Inventory and self.Config.Inventory.FOBStockFactor or 0.25) * 100) + 0.5)
    local lines = {}
    table.insert(lines, 'FOBs - Forward Supply and Why They Matter')
    table.insert(lines, '')
    table.insert(lines, '- Build a FOB by assembling its crate recipe (see Recipe Info).')
    table.insert(lines, string.format('- A new local Supply Zone is created and seeded at ~%d%% of initial stock.', fobPct))
    table.insert(lines, '- FOBs shorten logistics legs and increase throughput toward the front.')
    table.insert(lines, '- If enabled, FOB-only builds must occur inside FOB zones.')
    _msgCoalition(self.Side, table.concat(lines, '\n'), 35)
  end)
  MENU_COALITION_COMMAND:New(self.Side, 'SAM Sites: Building, Repairing, and Augmenting', helpMenu, function()
    local br = self.Config.BuildRadius or 60
    local lines = {}
    table.insert(lines, 'SAM Sites - Building, Repairing, and Augmenting')
    table.insert(lines, '')
    table.insert(lines, 'Build:')
    table.insert(lines, '- Assemble site recipes using the required component crates (see menu labels). Build Here will place the full site.')
    table.insert(lines, '')
    table.insert(lines, 'Repair/Augment (merged):')
    table.insert(lines, '- Request the matching "Repair/Launcher +1" crate for your site type (HAWK, Patriot, KUB, BUK).')
    table.insert(lines, string.format('- Drop repair crate(s) within ~%d m of the site, then use Build Here (confirm window applies).', br))
    table.insert(lines, '- The nearest matching site (within a local search) is respawned fully repaired; +1 launcher per crate, up to caps.')
    table.insert(lines, '- Caps: HAWK 6, Patriot 6, KUB 3, BUK 6. Extra crates beyond the cap are not consumed.')
    table.insert(lines, '- Must match coalition and site type; otherwise no changes are applied.')
    table.insert(lines, '- Respawn is required to apply repairs/augmentation due to DCS limitations.')
    table.insert(lines, '')
    table.insert(lines, 'Placement tips:')
    table.insert(lines, '- Space launchers to avoid masking; keep radars with good line-of-sight; avoid fratricide arcs.')
    _msgCoalition(self.Side, table.concat(lines, '\n'), 45)
  end)
  
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
  -- Player Help submenu (was below; removed there and added above)
  self.AdminMenu = root
end
-- #endregion Menus

-- =========================
-- Coalition Summary
-- =========================
-- #region Coalition Summary
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
-- #endregion Coalition Summary

-- =========================
-- Crates
-- =========================
-- #region Crates
-- Note: Menu creation lives in the Menus region; this section handles crate request/spawn/nearby/cleanup only.
function CTLD:RequestCrateForGroup(group, crateKey)
  local cat = self.Config.CrateCatalog[crateKey]
  if not cat then _msgGroup(group, 'Unknown crate type: '..tostring(crateKey)) return end
  local unit = group:GetUnit(1)
  if not unit or not unit:IsAlive() then return end
  local zone, dist = self:_nearestActivePickupZone(unit)
  local defs = self:_collectActivePickupDefs()
  local hasPickupZones = (#defs > 0)
  local spawnPoint
  local maxd = (self.Config.PickupZoneMaxDistance or 10000)
  -- Announce request
  local zoneName = zone and zone:GetName() or (hasPickupZones and 'nearest zone' or 'NO PICKUP ZONES CONFIGURED')
  _eventSend(self, group, nil, 'crate_spawn_requested', { type = tostring(crateKey), zone = zoneName })

  if not hasPickupZones and self.Config.RequirePickupZoneForCrateRequest then
    _eventSend(self, group, nil, 'no_pickup_zones', {})
    return
  end

  if zone and dist and dist <= maxd then
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
    -- (Smoke will be spawned after crate creation so we can pass the crate ID for refresh scheduling)
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
      -- Try salvage system if enabled
      if self:_TryUseSalvageForCrate(group, crateKey, cat) then
        -- Salvage used successfully, continue with crate spawn
        env.info(string.format('[Moose_CTLD][Salvage] Used salvage to spawn %s', crateKey))
      else
        _msgGroup(group, string.format('Out of stock at %s for %s', zoneNameForStock, self:_friendlyNameForKey(crateKey)))
        return
      end
    else
      CTLD._stockByZone[zoneNameForStock][crateKey] = cur - 1
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
  
  -- Now that crate is created, spawn smoke with refresh scheduling if enabled
  if zone then
    local zdef = self._ZoneDefs.PickupZones[zone:GetName()]
    local smokeColor = (zdef and zdef.smoke) or self.Config.PickupZoneSmokeColor
    if smokeColor then
      local sx, sz = spawnPoint.x, spawnPoint.z
      local sy = 0
      if land and land.getHeight then
        local ok, h = pcall(land.getHeight, { x = sx, y = sz })
        if ok and type(h) == 'number' then sy = h end
      end
      -- Pass crate ID for smoke refresh scheduling
      _spawnCrateSmoke({ x = sx, y = sy, z = sz }, smokeColor, self.Config.CrateSmoke, cname)
    end
  end
  
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

-- Convenience: for composite recipes (def.requires), request all component crates in one go
function CTLD:RequestRecipeBundleForGroup(group, recipeKey)
  local def = self.Config.CrateCatalog[recipeKey]
  if not def or type(def.requires) ~= 'table' then
    -- Fallback to single crate request
    return self:RequestCrateForGroup(group, recipeKey)
  end
  local unit = group and group:GetUnit(1)
  if not unit or not unit:IsAlive() then return end
  -- Require proximity to an active pickup zone if inventory is enabled or config requires it
  local zone, dist = self:_nearestActivePickupZone(unit)
  local hasPickupZones = (#self:_collectActivePickupDefs() > 0)
  local maxd = (self.Config.PickupZoneMaxDistance or 10000)
  if self.Config.RequirePickupZoneForCrateRequest and (not zone or not dist or dist > maxd) then
    local isMetric = _getPlayerIsMetric(unit)
    local v, u = _fmtRange(math.max(0, (dist or 0) - maxd), isMetric)
    local brg = 0
    if zone then
      local up = unit:GetPointVec3(); local zp = zone:GetPointVec3()
      brg = _bearingDeg({x=up.x,z=up.z}, {x=zp.x,z=zp.z})
    end
    _eventSend(self, group, nil, 'pickup_zone_required', { zone_dist = v, zone_dist_u = u, zone_brg = brg })
    return
  end
  if (self.Config.Inventory and self.Config.Inventory.Enabled) then
    if not zone then
      _msgGroup(group, 'Crate bundle requests must be at a Supply Zone for stock control.')
      return
    end
    local zname = zone:GetName()
    local stockTbl = CTLD._stockByZone[zname] or {}
    -- Pre-check: ensure we can fulfill at least one bundle (check stock or salvage)
    for reqKey, qty in pairs(def.requires) do
      local have = tonumber(stockTbl[reqKey] or 0) or 0
      local need = tonumber(qty or 0) or 0
      if need > 0 and have < need then
        -- Try salvage for the shortfall
        local catEntry = self.Config.CrateCatalog[reqKey]
        if not self:_CanUseSalvageForCrate(reqKey, catEntry, need - have) then
          _msgGroup(group, string.format('Out of stock at %s for %s bundle: need %d x %s', zname, self:_friendlyNameForKey(recipeKey), need, self:_friendlyNameForKey(reqKey)))
          return
        end
      end
    end
  end
  -- Spawn each required component crate with separate requests (these handle stock decrement + placement)
  for reqKey, qty in pairs(def.requires) do
    local n = tonumber(qty or 0) or 0
    for _=1,n do
      self:RequestCrateForGroup(group, reqKey)
    end
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
      _cleanupCrateSmoke(name)  -- Clean up smoke refresh schedule
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
  local hdgRad, hdgDeg = _headingRadDeg(unit)
  local buildOffset = math.max(0, tonumber(self.Config.BuildSpawnOffset or 0) or 0)
  local spawnAt = (buildOffset > 0) and { x = here.x + math.sin(hdgRad) * buildOffset, z = here.z + math.cos(hdgRad) * buildOffset } or { x = here.x, z = here.z }
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
        _cleanupCrateSmoke(c.name)  -- Clean up smoke refresh schedule
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
          local gdata = cat.build({ x = spawnAt.x, z = spawnAt.z }, hdgDeg, cat.side or self.Side)
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
  local gdata = cat.build({ x = spawnAt.x, z = spawnAt.z }, hdgDeg, cat.side or self.Side)
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
  -- Restrict dropping crates inside Pickup Zones if configured
  if self.Config.ForbidDropsInsidePickupZones then
    local activeOnly = (self.Config.ForbidChecksActivePickupOnly ~= false)
    local inside = false
    local ok, err = pcall(function()
      inside = select(1, self:_isUnitInsidePickupZone(unit, activeOnly))
    end)
    if ok and inside then
      _eventSend(self, group, nil, 'drop_forbidden_in_pickup', {})
      return
    end
  end
  local p = unit:GetPointVec3()
  local here = { x = p.x, z = p.z }
  -- Offset drop point forward of the aircraft to avoid rotor/airframe damage
  local hdgRad, _ = _headingRadDeg(unit)
  local fwd = math.max(0, tonumber(self.Config.DropCrateForwardOffset or 20) or 0)
  local dropPt = (fwd > 0) and { x = here.x + math.sin(hdgRad) * fwd, z = here.z + math.cos(hdgRad) * fwd } or { x = here.x, z = here.z }
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
      _spawnStaticCargo(self.Side, dropPt, (cat and cat.dcsCargoType) or 'uh1h_cargo', cname)
      CTLD._crates[cname] = { key = k, side = self.Side, spawnTime = timer.getTime(), point = { x = dropPt.x, z = dropPt.z } }
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
  local coachCfg = CTLD.HoverCoachConfig or { enabled = false }
  if not coachCfg.enabled then return end
  
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
          local maxd = coachCfg.autoPickupDistance or 25
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
              local hdg, _ = _headingRadDeg(unit)
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

          -- Auto-load logic using capture thresholds
          local capGS = coachCfg.thresholds.captureGS or (4/3.6)
          local aglMin = coachCfg.thresholds.aglMin or 5
          local aglMax = coachCfg.thresholds.aglMax or 20
          local speedOK = gs <= capGS
          local heightOK = (agl >= aglMin and agl <= aglMax)

          if bestName and bestMeta and speedOK and heightOK then
            local withinRadius = bestd <= (coachCfg.thresholds.captureHoriz or 2)

            if withinRadius then
              local carried = CTLD._loadedCrates[gname]
              local total = carried and carried.total or 0
              -- Get aircraft-specific capacity instead of global setting
              local capacity = _getAircraftCapacity(unit)
              local maxCrates = capacity.maxCrates
              if total < maxCrates then
                local hs = CTLD._hoverState[uname]
                if not hs or hs.targetCrate ~= bestName then
                  CTLD._hoverState[uname] = { targetCrate = bestName, startTime = now }
                  if coachEnabled then _coachSend(self, group, uname, 'coach_hold', {}, false) end
                else
                  -- stability hold timer
                  local holdNeeded = coachCfg.thresholds.stabilityHold or 1.8
                  if (now - hs.startTime) >= holdNeeded then
                    -- load it
                    local obj = StaticObject.getByName(bestName)
                    if obj then obj:destroy() end
                    _cleanupCrateSmoke(bestName)  -- Clean up smoke refresh schedule
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
              else
                -- Aircraft at capacity - notify player
                local aircraftType = _getUnitType(unit) or 'aircraft'
                _eventSend(self, group, nil, 'crate_aircraft_capacity', { current = total, max = maxCrates, aircraft = aircraftType })
                CTLD._hoverState[uname] = nil
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
  
  -- Check for MEDEVAC crew pickup first
  if CTLD.MEDEVAC and CTLD.MEDEVAC.Enabled then
    local medevacPickedUp = self:CheckMEDEVACPickup(group)
    if medevacPickedUp then
      return -- MEDEVAC crew was picked up, don't continue with normal troop loading
    end
  end

  -- Enforce pickup zone requirement for troop loading (inside zone)
  if self.Config.RequirePickupZoneForTroopLoad then
    local hasPickupZones = (self.PickupZones and #self.PickupZones > 0) or (self.Config.Zones and self.Config.Zones.PickupZones and #self.Config.Zones.PickupZones > 0)
    if not hasPickupZones then
      _eventSend(self, group, nil, 'no_pickup_zones', {})
      return
    end
    local zone, dist = self:_nearestActivePickupZone(unit)
    if not zone or not dist then
      -- No active pickup zone resolvable; provide helpful vectors to nearest configured zone if any
      local list = {}
      if self.Config and self.Config.Zones and self.Config.Zones.PickupZones then
        for _, z in ipairs(self.Config.Zones.PickupZones) do table.insert(list, z) end
      elseif self.PickupZones and #self.PickupZones > 0 then
        for _, mz in ipairs(self.PickupZones) do if mz and mz.GetName then table.insert(list, { name = mz:GetName() }) end end
      end
      local fbZone, fbDist = _nearestZonePoint(unit, list)
      if fbZone and fbDist then
        local isMetric = _getPlayerIsMetric(unit)
        local rZone = self:_getZoneRadius(fbZone) or 0
        local delta = math.max(0, fbDist - rZone)
        local v, u = _fmtRange(delta, isMetric)
        local up = unit:GetPointVec3(); local zp = fbZone:GetPointVec3()
        local brg = _bearingDeg({ x = up.x, z = up.z }, { x = zp.x, z = zp.z })
        _eventSend(self, group, nil, 'troop_pickup_zone_required', { zone_dist = v, zone_dist_u = u, zone_brg = brg })
      else
        _eventSend(self, group, nil, 'no_pickup_zones', {})
      end
      return
    end
    local inside = false
    if zone then
      local rZone = self:_getZoneRadius(zone) or 0
      if dist and rZone and dist <= rZone then inside = true end
    end
    if not inside then
      local isMetric = _getPlayerIsMetric(unit)
      local rZone = (self:_getZoneRadius(zone) or 0)
      local delta = (dist and rZone) and math.max(0, dist - rZone) or 0
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

  -- Determine troop type and composition
  local requestedType = (opts and (opts.typeKey or opts.type))
                        or (self.Config.Troops and self.Config.Troops.DefaultType)
                        or 'AS'
  local unitsList, label = self:_resolveTroopUnits(requestedType)
  
  -- Check aircraft capacity for troops
  local capacity = _getAircraftCapacity(unit)
  local maxTroops = capacity.maxTroops
  local troopCount = #unitsList
  
  if troopCount > maxTroops then
    -- Aircraft cannot carry this many troops
    local aircraftType = _getUnitType(unit) or 'aircraft'
    _eventSend(self, group, nil, 'troop_aircraft_capacity', { count = troopCount, max = maxTroops, aircraft = aircraftType })
    return
  end
  
  CTLD._troopsLoaded[gname] = {
    count = #unitsList,
    typeKey = requestedType,
  }
  _eventSend(self, group, nil, 'troops_loaded', { count = #unitsList })
end

function CTLD:UnloadTroops(group, opts)
  local gname = group:GetName()
  local load = CTLD._troopsLoaded[gname]
  if not load or (load.count or 0) == 0 then _eventSend(self, group, nil, 'no_troops', {}) return end

  local unit = group:GetUnit(1)
  if not unit or not unit:IsAlive() then return end
  
  -- Check for MEDEVAC crew delivery to MASH first
  if CTLD.MEDEVAC and CTLD.MEDEVAC.Enabled then
    local medevacDelivered = self:CheckMEDEVACDelivery(group, load)
    if medevacDelivered then
      -- Crew delivered to MASH, clear troops and return
      CTLD._troopsLoaded[gname] = nil
      return
    end
  end
  
  -- Restrict deploying troops inside Pickup Zones if configured
  if self.Config.ForbidTroopDeployInsidePickupZones then
    local activeOnly = (self.Config.ForbidChecksActivePickupOnly ~= false)
    local inside = false
    local ok, _ = pcall(function()
      inside = select(1, self:_isUnitInsidePickupZone(unit, activeOnly))
    end)
    if ok and inside then
      _eventSend(self, group, nil, 'troop_deploy_forbidden_in_pickup', {})
      return
    end
  end
  local p = unit:GetPointVec3()
  local here = { x = p.x, z = p.z }
  local hdgRad, _ = _headingRadDeg(unit)
  -- Offset troop spawn forward to avoid spawning under/near rotors
  local troopOffset = math.max(0, tonumber(self.Config.TroopSpawnOffset or 0) or 0)
  local center = (troopOffset > 0) and { x = here.x + math.sin(hdgRad) * troopOffset, z = here.z + math.cos(hdgRad) * troopOffset } or { x = here.x, z = here.z }

  -- Build the unit composition based on type
  local comp, _ = self:_resolveTroopUnits(load.typeKey)
  local units = {}
  local spacing = 1.8
  for i=1, #comp do
    local dx = (i-1) * spacing
    local dz = ((i % 2) == 0) and 2.0 or -2.0
    table.insert(units, {
      type = tostring(comp[i] or 'Infantry AK'),
      name = string.format('CTLD-TROOP-%d', math.random(100000,999999)),
  x = center.x + dx, y = center.z + dz, heading = hdgRad
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

-- Internal: resolve troop composition list for a given type key and coalition
function CTLD:_resolveTroopUnits(typeKey)
  local tcfg = (self.Config.Troops and self.Config.Troops.TroopTypes) or {}
  local def = tcfg[typeKey or 'AS'] or {}
  local size = tonumber(def.size or 0) or 0
  if size <= 0 then size = 6 end
  local pool
  if self.Side == coalition.side.BLUE then
    pool = def.unitsBlue or def.units
  elseif self.Side == coalition.side.RED then
    pool = def.unitsRed or def.units
  else
    pool = def.units
  end
  if not pool or #pool == 0 then pool = { 'Infantry AK' } end
  local list = {}
  for i=1,size do list[i] = pool[((i-1) % #pool) + 1] end
  local label = def.label or typeKey or 'Troops'
  return list, label
end

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
            _cleanupCrateSmoke(c.name)  -- Clean up smoke refresh schedule
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
-- #region Inventory helpers
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
  local v2 = (VECTOR2 and VECTOR2.New) and VECTOR2:New(point.x, point.z) or { x = point.x, y = point.z }
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
-- #endregion Inventory helpers

-- =========================
-- MEDEVAC System
-- =========================
-- #region MEDEVAC

-- Initialize MEDEVAC system (called from CTLD:New)
function CTLD:InitMEDEVAC()
  if not (CTLD.MEDEVAC and CTLD.MEDEVAC.Enabled) then return end
  
  -- Initialize salvage pools
  if CTLD.MEDEVAC.Salvage and CTLD.MEDEVAC.Salvage.Enabled then
    CTLD._salvagePoints[self.Side] = CTLD._salvagePoints[self.Side] or 0
  end
  
  -- Setup event handler for unit deaths
  local handler = EVENTHANDLER:New()
  handler:HandleEvent(EVENTS.Dead)
  local selfref = self
  
  function handler:OnEventDead(eventData)
    local unit = eventData.IniUnit
    if not unit then return end
    
    -- Only process ground units from our coalition
    local unitCoalition = unit:GetCoalition()
    if unitCoalition ~= selfref.Side then return end
    if unit:GetCategory() ~= Unit.Category.GROUND_UNIT then return end
    
    -- Check if this unit type is eligible for MEDEVAC
    local unitType = unit:GetTypeName()
    local catalogEntry = selfref:_FindCatalogEntryByUnitType(unitType)
    
    if catalogEntry and catalogEntry.MEDEVAC == true then
      selfref:_SpawnMEDEVACCrew(unit, catalogEntry)
    end
  end
  
  self.MEDEVACHandler = handler
  
  -- Start crew timeout checker (runs every 30 seconds)
  self.MEDEVACSched = SCHEDULER:New(nil, function()
    selfref:_CheckMEDEVACTimeouts()
  end, {}, 30, 30)
  
  -- Initialize MASH zones from config
  self:_InitMASHZones()
  
  env.info('[Moose_CTLD] MEDEVAC system initialized for coalition '..tostring(self.Side))
end

-- Find catalog entry that spawns a given unit type
function CTLD:_FindCatalogEntryByUnitType(unitType)
  for key, def in pairs(self.Config.CrateCatalog or {}) do
    -- Check if this catalog entry builds the unit type
    if def.build then
      -- Try to extract unit type from build function (heuristic)
      -- For singleUnit entries, check if the build creates this type
      local buildStr = tostring(def.build)
      if buildStr:find(unitType, 1, true) then
        return def
      end
    end
  end
  return nil
end

-- Spawn MEDEVAC crew when vehicle destroyed
function CTLD:_SpawnMEDEVACCrew(unit, catalogEntry)
  local cfg = CTLD.MEDEVAC
  if not cfg or not cfg.Enabled then return end
  
  local unitType = unit:GetTypeName()
  local unitName = unit:GetName()
  local pos = unit:GetPointVec3()
  local heading = unit:GetHeading() or 0
  
  -- Determine crew size
  local crewSize = catalogEntry.crewSize or cfg.CrewDefaultSize or 2
  
  -- Determine salvage value
  local salvageValue = catalogEntry.salvageValue
  if not salvageValue then
    salvageValue = catalogEntry.required or cfg.Salvage.DefaultValue or 1
  end
  
  -- Find nearest enemy to spawn crew toward them
  local spawnPoint = { x = pos.x, z = pos.z }
  local enemySide = (self.Side == coalition.side.BLUE) and coalition.side.RED or coalition.side.BLUE
  local nearestEnemy = self:_FindNearestEnemyGround({ x = pos.x, z = pos.z }, 2000) -- 2km search
  
  if nearestEnemy and nearestEnemy.point then
    -- Calculate direction toward enemy
    local dx = nearestEnemy.point.x - pos.x
    local dz = nearestEnemy.point.z - pos.z
    local dist = math.sqrt(dx*dx + dz*dz)
    if dist > 0 then
      local dirX = dx / dist
      local dirZ = dz / dist
      local offset = cfg.CrewSpawnOffset or 15
      spawnPoint.x = pos.x + dirX * offset
      spawnPoint.z = pos.z + dirZ * offset
    end
  else
    -- No enemy found, spawn at random offset
    local angle = math.random() * 2 * math.pi
    local offset = cfg.CrewSpawnOffset or 15
    spawnPoint.x = pos.x + math.cos(angle) * offset
    spawnPoint.z = pos.z + math.sin(angle) * offset
  end
  
  -- Spawn crew group
  local crewGroupName = string.format('MEDEVAC_Crew_%s_%d', unitType, math.random(100000, 999999))
  local crewUnitType = catalogEntry.crewType or cfg.CrewUnitTypes[self.Side] or 'Soldier M4'
  
  local groupData = {
    visible = false,
    lateActivation = false,
    tasks = {},
    task = 'Ground Nothing',
    route = {},
    units = {},
    name = crewGroupName
  }
  
  for i = 1, crewSize do
    table.insert(groupData.units, {
      type = crewUnitType,
      name = string.format('%s_U%d', crewGroupName, i),
      x = spawnPoint.x + (i-1) * 2, -- slight spacing
      y = spawnPoint.z,
      heading = heading
    })
  end
  
  local crewGroup = coalition.addGroup(self.Side, Group.Category.GROUND, groupData)
  
  if not crewGroup then
    env.info('[Moose_CTLD][MEDEVAC] Failed to spawn crew for '..unitType)
    return
  end
  
  -- Make crew invulnerable initially
  local crewGroupDCS = Group.getByName(crewGroupName)
  if crewGroupDCS then
    for _, u in ipairs(crewGroupDCS:getUnits() or {}) do
      if u and u:isExist() then
        u:setCommand({
          id = 'SetImmortal',
          params = { value = true }
        })
      end
    end
  end
  
  -- Schedule invulnerability removal and pickup request
  timer.scheduleFunction(function()
    local g = Group.getByName(crewGroupName)
    if g and g:isExist() then
      -- Remove invulnerability
      for _, u in ipairs(g:getUnits() or {}) do
        if u and u:isExist() then
          u:setCommand({
            id = 'SetImmortal',
            params = { value = false }
          })
        end
      end
      
      -- Announce crew is ready for pickup
      local grid = self:_GetMGRSString(spawnPoint)
      _msgCoalition(self.Side, _fmtTemplate(CTLD.Messages.medevac_crew_spawned, {
        vehicle = unitType,
        grid = grid,
        crew_size = crewSize,
        salvage = salvageValue
      }), 20)
      
      -- Create map marker
      if cfg.MapMarkers and cfg.MapMarkers.Enabled then
        local markerID = self:_CreateMEDEVACMarker(spawnPoint, unitType, crewSize, salvageValue, crewGroupName)
        CTLD._medevacCrews[crewGroupName].markerID = markerID
      end
      
      CTLD._medevacCrews[crewGroupName].requestTime = timer.getTime()
      
      -- Track statistics
      if CTLD.MEDEVAC and CTLD.MEDEVAC.Statistics and CTLD.MEDEVAC.Statistics.Enabled then
        CTLD._medevacStats[self.Side].spawned = (CTLD._medevacStats[self.Side].spawned or 0) + 1
      end
    end
  end, nil, timer.getTime() + (cfg.CrewSpawnDelay or 180))
  
  -- Store crew data
  CTLD._medevacCrews[crewGroupName] = {
    vehicleType = unitType,
    side = self.Side,
    spawnTime = timer.getTime(),
    position = spawnPoint,
    salvageValue = salvageValue,
    originalHeading = heading,
    crewSize = crewSize,
    catalogKey = catalogEntry.key or unitType,
    warningsSent = {},
    requestTime = nil, -- set when crew requests pickup
    markerID = nil, -- set when marker created
  }
  
  env.info(string.format('[Moose_CTLD][MEDEVAC] Spawned crew for %s at %.0f, %.0f', unitType, spawnPoint.x, spawnPoint.z))
end

-- Create map marker for MEDEVAC crew
function CTLD:_CreateMEDEVACMarker(position, vehicleType, crewSize, salvageValue, crewGroupName)
  local cfg = CTLD.MEDEVAC.MapMarkers
  if not cfg or not cfg.Enabled then return nil end
  
  local grid = self:_GetMGRSString(position)
  local text = string.format('%s: %s Crew (%d) - Salvage: %d - %s', 
    cfg.IconText or '🔴 MEDEVAC',
    vehicleType,
    crewSize,
    salvageValue,
    grid
  )
  
  local markerID = _nextMarkupId()
  trigger.action.markToCoalition(markerID, text, {x = position.x, y = 0, z = position.z}, self.Side, true)
  
  return markerID
end

-- Get MGRS grid string for position
function CTLD:_GetMGRSString(position)
  local lat, lon = coord.LOtoLL({x = position.x, y = 0, z = position.z})
  local mgrs = coord.LLtoMGRS(lat, lon)
  if mgrs and mgrs.UTMZone and mgrs.MGRSDigraph then
    return string.format('%d%s %05d %05d', mgrs.UTMZone, mgrs.MGRSDigraph, mgrs.Easting or 0, mgrs.Northing or 0)
  end
  return string.format('%.0f, %.0f', position.x, position.z)
end

-- Check for MEDEVAC crew timeouts and send warnings
function CTLD:_CheckMEDEVACTimeouts()
  local cfg = CTLD.MEDEVAC
  if not cfg or not cfg.Enabled then return end
  
  local now = timer.getTime()
  local toRemove = {}
  
  for crewGroupName, data in pairs(CTLD._medevacCrews) do
    if data.side == self.Side then
      local requestTime = data.requestTime
      if requestTime then -- Only check after crew has requested pickup
        local elapsed = now - requestTime
        local remaining = (cfg.CrewTimeout or 3600) - elapsed
        
        -- Send warnings
        if cfg.Warnings then
          for _, warning in ipairs(cfg.Warnings) do
            local warnTime = warning.time
            if remaining <= warnTime and not data.warningsSent[warnTime] then
              local grid = self:_GetMGRSString(data.position)
              _msgCoalition(self.Side, _fmtTemplate(warning.message, {
                crew = data.vehicleType..' crew',
                grid = grid
              }), 15)
              data.warningsSent[warnTime] = true
            end
          end
        end
        
        -- Check timeout
        if remaining <= 0 then
          table.insert(toRemove, crewGroupName)
        end
      end
    end
  end
  
  -- Remove timed-out crews
  for _, crewGroupName in ipairs(toRemove) do
    self:_RemoveMEDEVACCrew(crewGroupName, 'timeout')
  end
end

-- Remove MEDEVAC crew (timeout or death)
function CTLD:_RemoveMEDEVACCrew(crewGroupName, reason)
  local data = CTLD._medevacCrews[crewGroupName]
  if not data then return end
  
  -- Remove map marker
  if data.markerID then
    pcall(function() trigger.action.removeMark(data.markerID) end)
  end
  
  -- Destroy crew group
  local g = Group.getByName(crewGroupName)
  if g and g:isExist() then
    g:destroy()
  end
  
  -- Send message
  if reason == 'timeout' then
    local grid = self:_GetMGRSString(data.position)
    _msgCoalition(self.Side, _fmtTemplate(CTLD.Messages.medevac_crew_timeout, {
      vehicle = data.vehicleType,
      grid = grid
    }), 15)
    
    -- Track statistics
    if CTLD.MEDEVAC and CTLD.MEDEVAC.Statistics and CTLD.MEDEVAC.Statistics.Enabled then
      CTLD._medevacStats[self.Side].timedOut = (CTLD._medevacStats[self.Side].timedOut or 0) + 1
    end
  elseif reason == 'killed' then
    -- Track statistics
    if CTLD.MEDEVAC and CTLD.MEDEVAC.Statistics and CTLD.MEDEVAC.Statistics.Enabled then
      CTLD._medevacStats[self.Side].killed = (CTLD._medevacStats[self.Side].killed or 0) + 1
    end
  end
  
  -- Remove from tracking
  CTLD._medevacCrews[crewGroupName] = nil
  
  env.info(string.format('[Moose_CTLD][MEDEVAC] Removed crew %s (reason: %s)', crewGroupName, reason or 'unknown'))
end

-- Check if crew was picked up (called from troop loading system)
function CTLD:CheckMEDEVACPickup(group)
  local cfg = CTLD.MEDEVAC
  if not cfg or not cfg.Enabled then return end
  
  local unit = group:GetUnit(1)
  if not unit or not unit:IsAlive() then return end
  
  local pos = unit:GetPointVec3()
  local searchRadius = 100 -- meters to search for nearby crew
  
  for crewGroupName, data in pairs(CTLD._medevacCrews) do
    if data.side == self.Side and data.requestTime then
      local crewPos = data.position
      local dx = pos.x - crewPos.x
      local dz = pos.z - crewPos.z
      local dist = math.sqrt(dx*dx + dz*dz)
      
      if dist <= searchRadius then
        -- Check if crew group still exists and is being loaded
        local crewGroup = Group.getByName(crewGroupName)
        if crewGroup and crewGroup:isExist() then
          -- Crew was picked up! Handle respawn
          self:_HandleMEDEVACPickup(group, crewGroupName, data)
          return true
        end
      end
    end
  end
  
  return false
end

-- Handle MEDEVAC crew pickup - respawn vehicle
function CTLD:_HandleMEDEVACPickup(rescueGroup, crewGroupName, crewData)
  local cfg = CTLD.MEDEVAC
  
  -- Remove map marker
  if crewData.markerID then
    pcall(function() trigger.action.removeMark(crewData.markerID) end)
  end
  
  -- Message to player
  _msgGroup(rescueGroup, _fmtTemplate(CTLD.Messages.medevac_crew_loaded, {
    vehicle = crewData.vehicleType,
    crew_size = crewData.crewSize
  }), 10)
  
  -- Track statistics
  if CTLD.MEDEVAC and CTLD.MEDEVAC.Statistics and CTLD.MEDEVAC.Statistics.Enabled then
    CTLD._medevacStats[self.Side].rescued = (CTLD._medevacStats[self.Side].rescued or 0) + 1
  end
    -- Respawn vehicle if enabled
  if cfg.RespawnOnPickup then
    timer.scheduleFunction(function()
      self:_RespawnMEDEVACVehicle(crewData)
    end, nil, timer.getTime() + 2) -- 2 second delay for realism
  end
  
  -- Mark crew as picked up (for MASH delivery tracking)
  crewData.pickedUp = true
  crewData.rescueGroup = rescueGroup:GetName()
  
  env.info(string.format('[Moose_CTLD][MEDEVAC] Crew %s picked up by %s', crewGroupName, rescueGroup:GetName()))
end

-- Respawn the vehicle at original death location
function CTLD:_RespawnMEDEVACVehicle(crewData)
  local cfg = CTLD.MEDEVAC
  if not cfg or not cfg.RespawnOnPickup then return end
  
  -- Calculate respawn position (offset from original death)
  local offset = cfg.RespawnOffset or 15
  local angle = math.random() * 2 * math.pi
  local respawnPos = {
    x = crewData.position.x + math.cos(angle) * offset,
    z = crewData.position.z + math.sin(angle) * offset
  }
  
  local heading = cfg.RespawnSameHeading and (crewData.originalHeading or 0) or 0
  
  -- Find catalog entry to get build function
  local catalogEntry = nil
  for key, def in pairs(self.Config.CrateCatalog or {}) do
    if def.MEDEVAC and tostring(def.build):find(crewData.vehicleType, 1, true) then
      catalogEntry = def
      break
    end
  end
  
  if not catalogEntry or not catalogEntry.build then
    env.info('[Moose_CTLD][MEDEVAC] No catalog entry found for respawn: '..crewData.vehicleType)
    return
  end
  
  -- Spawn vehicle using catalog build function
  local groupData = catalogEntry.build(respawnPos, math.deg(heading))
  if not groupData then
    env.info('[Moose_CTLD][MEDEVAC] Failed to generate group data for: '..crewData.vehicleType)
    return
  end
  
  local newGroup = coalition.addGroup(self.Side, Group.Category.GROUND, groupData)
  
  if newGroup then
    _msgCoalition(self.Side, _fmtTemplate(CTLD.Messages.medevac_vehicle_respawned, {
      vehicle = crewData.vehicleType
    }), 10)
    
    -- Track statistics
    if CTLD.MEDEVAC and CTLD.MEDEVAC.Statistics and CTLD.MEDEVAC.Statistics.Enabled then
      CTLD._medevacStats[self.Side].vehiclesRespawned = (CTLD._medevacStats[self.Side].vehiclesRespawned or 0) + 1
    end
    
    env.info(string.format('[Moose_CTLD][MEDEVAC] Respawned %s at %.0f, %.0f', crewData.vehicleType, respawnPos.x, respawnPos.z))
  else
    env.info('[Moose_CTLD][MEDEVAC] Failed to respawn vehicle: '..crewData.vehicleType)
  end
end

-- Check if troops being unloaded are MEDEVAC crew and if inside MASH zone
function CTLD:CheckMEDEVACDelivery(group, troopData)
  local cfg = CTLD.MEDEVAC
  if not cfg or not cfg.Enabled then return false end
  if not cfg.Salvage or not cfg.Salvage.Enabled then return false end
  
  -- Check if any picked-up crews match this group
  local deliveredCrews = {}
  for crewGroupName, data in pairs(CTLD._medevacCrews) do
    if data.side == self.Side and data.pickedUp and data.rescueGroup == group:GetName() then
      table.insert(deliveredCrews, {name = crewGroupName, data = data})
    end
  end
  
  if #deliveredCrews == 0 then return false end
  
  -- Check if inside MASH zone
  local unit = group:GetUnit(1)
  if not unit or not unit:IsAlive() then return false end
  
  local pos = unit:GetPointVec3()
  local inMASH, mashZone = self:_IsPositionInMASHZone({x = pos.x, z = pos.z})
  
  if not inMASH then return false end
  
  -- Deliver all picked-up crews
  for _, crew in ipairs(deliveredCrews) do
    self:_DeliverMEDEVACCrewToMASH(group, crew.name, crew.data)
  end
  
  return true
end

-- Deliver MEDEVAC crew to MASH - award salvage points
function CTLD:_DeliverMEDEVACCrewToMASH(group, crewGroupName, crewData)
  local cfg = CTLD.MEDEVAC.Salvage
  if not cfg or not cfg.Enabled then return end
  
  -- Award salvage points
  CTLD._salvagePoints[self.Side] = (CTLD._salvagePoints[self.Side] or 0) + crewData.salvageValue
  
  -- Message to coalition
  _msgCoalition(self.Side, _fmtTemplate(CTLD.Messages.medevac_crew_delivered_mash, {
    player = _playerNameFromGroup(group),
    vehicle = crewData.vehicleType,
    salvage = crewData.salvageValue,
    total = CTLD._salvagePoints[self.Side]
  }), 15)
  
  -- Track statistics
  if CTLD.MEDEVAC and CTLD.MEDEVAC.Statistics and CTLD.MEDEVAC.Statistics.Enabled then
    CTLD._medevacStats[self.Side].delivered = (CTLD._medevacStats[self.Side].delivered or 0) + 1
    CTLD._medevacStats[self.Side].salvageEarned = (CTLD._medevacStats[self.Side].salvageEarned or 0) + crewData.salvageValue
  end
    -- Remove crew from tracking
  CTLD._medevacCrews[crewGroupName] = nil
  
  env.info(string.format('[Moose_CTLD][MEDEVAC] Delivered %s crew to MASH - awarded %d salvage (total: %d)', 
    crewData.vehicleType, crewData.salvageValue, CTLD._salvagePoints[self.Side]))
end

-- Try to use salvage to spawn a crate when out of stock
function CTLD:_TryUseSalvageForCrate(group, crateKey, catalogEntry)
  local cfg = CTLD.MEDEVAC and CTLD.MEDEVAC.Salvage
  if not cfg or not cfg.Enabled then return false end
  if not cfg.AutoApply then return false end
  
  -- Check if item has salvage value
  local salvageCost = (catalogEntry and catalogEntry.salvageValue) or 0
  if salvageCost <= 0 then return false end
  
  -- Check if we have enough salvage
  local available = CTLD._salvagePoints[self.Side] or 0
  if available < salvageCost then
    -- Send insufficient salvage message
    _msgGroup(group, _fmtTemplate(CTLD.Messages.medevac_salvage_insufficient, {
      need = salvageCost,
      have = available
    }))
    return false
  end
  
  -- Consume salvage
  CTLD._salvagePoints[self.Side] = available - salvageCost
  
  -- Track statistics
  if CTLD.MEDEVAC and CTLD.MEDEVAC.Statistics and CTLD.MEDEVAC.Statistics.Enabled then
    CTLD._medevacStats[self.Side].salvageUsed = (CTLD._medevacStats[self.Side].salvageUsed or 0) + salvageCost
  end
  
  -- Send success message
  _msgGroup(group, _fmtTemplate(CTLD.Messages.medevac_salvage_used, {
    item = self:_friendlyNameForKey(crateKey),
    salvage = salvageCost,
    remaining = CTLD._salvagePoints[self.Side]
  }))
  
  env.info(string.format('[Moose_CTLD][Salvage] Used %d salvage for %s (remaining: %d)', 
    salvageCost, crateKey, CTLD._salvagePoints[self.Side]))
  
  return true
end

-- Check if salvage can cover a crate request (for bundle pre-checks)
function CTLD:_CanUseSalvageForCrate(crateKey, catalogEntry, quantity)
  local cfg = CTLD.MEDEVAC and CTLD.MEDEVAC.Salvage
  if not cfg or not cfg.Enabled then return false end
  if not cfg.AutoApply then return false end
  
  quantity = quantity or 1
  local salvageCost = ((catalogEntry and catalogEntry.salvageValue) or 0) * quantity
  if salvageCost <= 0 then return false end
  
  local available = CTLD._salvagePoints[self.Side] or 0
  return available >= salvageCost
end

-- Check if position is inside any MASH zone
function CTLD:_IsPositionInMASHZone(position)
  for zoneName, mashData in pairs(CTLD._mashZones) do
    if mashData.side == self.Side then
      local zone = mashData.zone
      if zone then
        local zonePos = zone:GetPointVec3()
        local radius = mashData.radius or CTLD.MEDEVAC.MASHZoneRadius or 500
        local dx = position.x - zonePos.x
        local dz = position.z - zonePos.z
        local dist = math.sqrt(dx*dx + dz*dz)
        
        if dist <= radius then
          return true, mashData
        end
      end
    end
  end
  return false, nil
end

-- Initialize MASH zones from config
function CTLD:_InitMASHZones()
  local cfg = CTLD.MEDEVAC
  if not cfg or not cfg.Enabled then return end
  
  -- Load fixed MASH zones from config
  for _, zoneConfig in ipairs(cfg.MASHZones or {}) do
    if zoneConfig.name then
      local zone = ZONE:FindByName(zoneConfig.name)
      if zone then
        CTLD._mashZones[zoneConfig.name] = {
          zone = zone,
          side = self.Side,
          isMobile = false,
          radius = zoneConfig.radius or cfg.MASHZoneRadius or 500,
          freq = zoneConfig.freq
        }
        env.info('[Moose_CTLD][MEDEVAC] Registered MASH zone: '..zoneConfig.name)
      else
        env.info('[Moose_CTLD][MEDEVAC] WARNING: MASH zone not found in mission: '..zoneConfig.name)
      end
    end
  end
  
  -- Draw MASH zones on map
  if cfg.MapMarkers and cfg.MapMarkers.Enabled then
    self:_DrawMASHZones()
  end
end

-- Draw MASH zones on F10 map
function CTLD:_DrawMASHZones()
  local cfg = CTLD.MEDEVAC
  if not cfg or not cfg.Enabled then return end
  
  local md = self.Config.MapDraw
  if not md or not md.Enabled then return end
  
  for zoneName, mashData in pairs(CTLD._mashZones) do
    if mashData.side == self.Side then
      local zone = mashData.zone
      if zone then
        local p, r = self:_getZoneCenterAndRadius(zone)
        if p and r then
          local circleId = _nextMarkupId()
          local textId = _nextMarkupId()
          
          local borderColor = cfg.MASHZoneColors.border or {1, 1, 0, 0.85}
          local fillColor = cfg.MASHZoneColors.fill or {1, 0.75, 0.8, 0.25}
          
          trigger.action.circleToCoalition(self.Side, circleId, p, r, borderColor, fillColor, 1, true, "")
          
          local label = string.format('MASH: %s', zoneName)
          local textPos = {x = p.x, y = 0, z = p.z - r - 50}
          trigger.action.textToCoalition(self.Side, textId, textPos, {1,1,1,0.9}, {0,0,0,0}, 18, true, label)
        end
      end
    end
  end
end

-- #endregion MEDEVAC

-- #region Mobile MASH

-- Create a Mobile MASH zone and start announcements
function CTLD:_CreateMobileMASH(group, position, catalogDef)
  local cfg = CTLD.MEDEVAC
  if not cfg or not cfg.Enabled then return end
  if not cfg.MobileMASH or not cfg.MobileMASH.Enabled then return end
  
  local side = catalogDef.side or self.Side
  if not CTLD._mobileMASHCounter then CTLD._mobileMASHCounter = {} end
  if not CTLD._mobileMASHCounter[side] then CTLD._mobileMASHCounter[side] = 0 end
  CTLD._mobileMASHCounter[side] = CTLD._mobileMASHCounter[side] + 1
  
  local mashId = string.format('MOBILE_MASH_%d_%d', side, CTLD._mobileMASHCounter[side])
  local radius = cfg.MobileMASH.ZoneRadius or 500
  
  -- Register the MASH zone
  local mashData = {
    id = mashId,
    position = {x = position.x, z = position.z},
    radius = radius,
    side = side,
    group = group,
    isMobile = true,
    catalogKey = catalogDef.description or 'Mobile MASH'
  }
  
  if not CTLD._mashZones then CTLD._mashZones = {} end
  table.insert(CTLD._mashZones, mashData)
  
  -- Draw on F10 map
  local circleId = mashId .. '_circle'
  local textId = mashId .. '_text'
  local p = {x = position.x, y = 0, z = position.z}
  
  local borderColor = cfg.MASHZoneColors.border or {1, 1, 0, 0.85}
  local fillColor = cfg.MASHZoneColors.fill or {1, 0.75, 0.8, 0.25}
  
  trigger.action.circleToCoalition(side, circleId, p, radius, borderColor, fillColor, 1, true, "")
  
  local label = string.format('Mobile MASH %d', CTLD._mobileMASHCounter[side])
  local textPos = {x = p.x, y = 0, z = p.z - radius - 50}
  trigger.action.textToCoalition(side, textId, textPos, {1,1,1,0.9}, {0,0,0,0}, 18, true, label)
  
  mashData.circleId = circleId
  mashData.textId = textId
  
  -- Send initial deployment message
  local gridStr = self:_GetMGRSString(position)
  local msg = _fmtMsg(CTLD.Messages.medevac_mash_deployed, {
    mash_id = CTLD._mobileMASHCounter[side],
    grid = gridStr,
    freq = cfg.MobileMASH.BeaconFrequency or '30.0 FM'
  })
  trigger.action.outTextForCoalition(side, msg, 30)
  env.info(string.format('[Moose_CTLD][MobileMASH] Deployed MASH %d at %s', CTLD._mobileMASHCounter[side], gridStr))
  
  -- Start announcement scheduler
  if cfg.MobileMASH.AnnouncementInterval and cfg.MobileMASH.AnnouncementInterval > 0 then
    local ctldInstance = self
    local scheduler = SCHEDULER:New(nil, function()
      -- Check if group still exists
      if not group or not group:IsAlive() then
        ctldInstance:_RemoveMobileMASH(mashId)
        return
      end
      
      -- Send periodic announcement
      local currentPos = group:GetCoordinate()
      if currentPos then
        local currentGrid = ctldInstance:_GetMGRSString({x = currentPos.x, z = currentPos.z})
        local announceMsg = _fmtMsg(CTLD.Messages.medevac_mash_announcement, {
          mash_id = CTLD._mobileMASHCounter[side],
          grid = currentGrid,
          freq = cfg.MobileMASH.BeaconFrequency or '30.0 FM'
        })
        trigger.action.outTextForCoalition(side, announceMsg, 20)
      end
    end, {}, cfg.MobileMASH.AnnouncementInterval, cfg.MobileMASH.AnnouncementInterval)
    
    mashData.scheduler = scheduler
  end
  
  -- Set up death event handler for this specific MASH
  local ctldInstance = self
  local mashGroupName = group:GetName()
  local eventHandler = EVENTHANDLER:New()
  eventHandler:HandleEvent(EVENTS.Dead)
  
  function eventHandler:OnEventDead(EventData)
    if EventData.IniUnit and EventData.IniGroup then
      local deadGroup = EventData.IniGroup
      if deadGroup:GetName() == mashGroupName then
        ctldInstance:_RemoveMobileMASH(mashId)
      end
    end
  end
  
  mashData.eventHandler = eventHandler
end

-- Remove a Mobile MASH zone (on destruction or manual removal)
function CTLD:_RemoveMobileMASH(mashId)
  if not CTLD._mashZones then return end
  
  for i = #CTLD._mashZones, 1, -1 do
    local mash = CTLD._mashZones[i]
    if mash.id == mashId then
      -- Stop scheduler
      if mash.scheduler then
        mash.scheduler:Stop()
      end
      
      -- Remove map drawings
      if mash.circleId then trigger.action.removeMark(mash.circleId) end
      if mash.textId then trigger.action.removeMark(mash.textId) end
      
      -- Send destruction message
      local msg = _fmtMsg(CTLD.Messages.medevac_mash_destroyed, {
        mash_id = string.match(mashId, 'MOBILE_MASH_%d+_(%d+)') or '?'
      })
      trigger.action.outTextForCoalition(mash.side, msg, 20)
      
      -- Remove from table
      table.remove(CTLD._mashZones, i)
      env.info(string.format('[Moose_CTLD][MobileMASH] Removed MASH %s', mashId))
      break
    end
  end
end

-- #endregion Mobile MASH

-- #endregion Inventory helpers

-- Create a new Drop Zone (AO) at the player's current location and draw it on the map if enabled
function CTLD:CreateDropZoneAtGroup(group)
  if not group or not group:IsAlive() then return end
  local unit = group:GetUnit(1)
  if not unit or not unit:IsAlive() then return end
  -- Prevent creating a Drop Zone inside or too close to a Pickup Zone
  -- 1) Block if inside a (potentially active-only) pickup zone
  local activeOnlyForInside = (self.Config and self.Config.ForbidChecksActivePickupOnly ~= false)
  local inside, pz, distInside, pr = self:_isUnitInsidePickupZone(unit, activeOnlyForInside)
  if inside then
    local isMetric = _getPlayerIsMetric(unit)
    local curV, curU = _fmtRange(distInside or 0, isMetric)
    local needV, needU = _fmtRange(self.Config.MinDropZoneDistanceFromPickup or 10000, isMetric)
    _eventSend(self, group, nil, 'drop_zone_too_close_to_pickup', {
      zone = (pz and pz.GetName and pz:GetName()) or '(pickup)',
      need = needV, need_u = needU,
      dist = curV, dist_u = curU,
    })
    return
  end
  -- 2) Enforce a minimum distance from the nearest pickup zone (configurable)
  local minD = tonumber(self.Config and self.Config.MinDropZoneDistanceFromPickup) or 0
  if minD > 0 then
    local considerActive = (self.Config and self.Config.MinDropDistanceActivePickupOnly ~= false)
    local nearestZone, nearestDist
    if considerActive then
      nearestZone, nearestDist = self:_nearestActivePickupZone(unit)
    else
      local list = (self.Config and self.Config.Zones and self.Config.Zones.PickupZones) or {}
      nearestZone, nearestDist = _nearestZonePoint(unit, list)
    end
    if nearestZone and nearestDist and nearestDist < minD then
      local isMetric = _getPlayerIsMetric(unit)
      local needV, needU = _fmtRange(minD, isMetric)
      local curV, curU = _fmtRange(nearestDist, isMetric)
      _eventSend(self, group, nil, 'drop_zone_too_close_to_pickup', {
        zone = (nearestZone and nearestZone.GetName and nearestZone:GetName()) or '(pickup)',
        need = needV, need_u = needU,
        dist = curV, dist_u = curU,
      })
      return
    end
  end
  local p = unit:GetPointVec3()
  local baseName = group:GetName() or 'GROUP'
  local safe = tostring(baseName):gsub('%W', '')
  local name = string.format('AO_%s_%d', safe, math.random(100000,999999))
  local r = tonumber(self.Config and self.Config.DropZoneRadius) or 250
  local v2 = (VECTOR2 and VECTOR2.New) and VECTOR2:New(p.x, p.z) or { x = p.x, y = p.z }
  local mz = ZONE_RADIUS:New(name, v2, r)
  -- Register in runtime and config so other features can find it
  self.DropZones = self.DropZones or {}
  table.insert(self.DropZones, mz)
  self._ZoneDefs = self._ZoneDefs or { PickupZones = {}, DropZones = {}, FOBZones = {} }
  self._ZoneDefs.DropZones[name] = { name = name, radius = r, active = true }
  self._ZoneActive = self._ZoneActive or { Pickup = {}, Drop = {}, FOB = {} }
  self._ZoneActive.Drop[name] = true
  self.Config.Zones = self.Config.Zones or { PickupZones = {}, DropZones = {}, FOBZones = {} }
  table.insert(self.Config.Zones.DropZones, { name = name, radius = r, active = true })
  -- Draw on map if configured
  local md = self.Config and self.Config.MapDraw or {}
  if md.Enabled and (md.DrawDropZones ~= false) then
    local opts = {
      OutlineColor = md.OutlineColor,
      FillColor = (md.FillColors and md.FillColors.Drop) or nil,
      LineType = (md.LineTypes and md.LineTypes.Drop) or md.LineType or 1,
      FontSize = md.FontSize,
      ReadOnly = (md.ReadOnly ~= false),
      LabelOffsetX = md.LabelOffsetX,
      LabelOffsetFromEdge = md.LabelOffsetFromEdge,
      LabelOffsetRatio = md.LabelOffsetRatio,
      LabelPrefix = (md.LabelPrefixes and md.LabelPrefixes.Drop) or 'Drop Zone',
      ForAll = (md.ForAll == true),
    }
    pcall(function() self:_drawZoneCircleAndLabel('Drop', mz, opts) end)
  end
  MESSAGE:New(string.format('Drop Zone created: %s (r≈%dm)', name, r), 10):ToGroup(group)
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
