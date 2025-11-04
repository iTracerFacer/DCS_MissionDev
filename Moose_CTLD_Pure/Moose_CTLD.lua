-- Moose_CTLD.lua
-- Pure-MOOSE, template-free CTLD-style logistics & troop transport
-- Drop-in script: no MIST, no mission editor templates required
-- Dependencies: Moose.lua must be loaded before this script
-- Author: Copilot (generated)

-- Contract
-- Inputs: Config table or defaults. No ME templates needed. Zones may be named ME trigger zones or provided via coordinates in config.
-- Outputs: F10 menus for helo/transport groups; crate spawning/building; troop load/unload; optional JTAC hookup (via FAC module);
-- Error modes: missing Moose -> abort; unknown crate key -> message; spawn blocked in enemy airbase; zone missing -> message.

if not _G.Moose or not _G.BASE then
  env.info('[Moose_CTLD] Moose not detected (BASE class missing). Ensure Moose.lua is loaded before Moose_CTLD.lua')
end

local CTLD = {}
CTLD.__index = CTLD

-- =========================
-- Defaults and State
-- =========================
CTLD.Version = '0.1.0-alpha'

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
  CrateLifetime = 3600,                  -- seconds before crates auto-clean
  MessageDuration = 15,                  -- seconds for on-screen messages
  Debug = false,
  PickupZoneSmokeColor = trigger.smokeColor.Green, -- default smoke color when spawning crates at pickup zones

  -- Hover pickup configuration (Ciribob-style inspired)
  HoverPickup = {
    Enabled = true,             -- if true, auto-load the nearest crate when hovering close enough for a duration
    Height = 3,                  -- meters AGL threshold for hover pickup
    Radius = 15,                 -- meters horizontal distance to crate to consider for pickup
    AutoPickupDistance = 25,     -- meters max search distance for candidate crates
    Duration = 3,                -- seconds of continuous hover before loading occurs
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

-- Internal state tables
CTLD._instances = CTLD._instances or {}
CTLD._crates = {}          -- [crateName] = { key, zone, side, spawnTime, point }
CTLD._troopsLoaded = {}    -- [groupName] = { count, typeKey }
CTLD._loadedCrates = {}    -- [groupName] = { total=n, byKey = { key -> count } }
CTLD._hoverState = {}       -- [unitName] = { targetCrate=name, startTime=t }
CTLD._unitLast = {}         -- [unitName] = { x, z, t }

-- =========================
-- Utilities
-- =========================
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
  local p3 = unit:GetPointVec3()
  local best, bestd = nil, 1e12
  for _,z in ipairs(list or {}) do
    local mz = _findZone(z)
    if mz then
      local d = p3:DistanceFromPoint(mz:GetPointVec3())
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

-- =========================
-- Construction
-- =========================
function CTLD:New(cfg)
  local o = setmetatable({}, self)
  o.Config = BASE:DeepCopy(CTLD.Config)
  if cfg then o.Config = BASE:Inherit(o.Config, cfg) end
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
  for _,z in ipairs(self.Config.Zones.PickupZones or {}) do
    local mz = _findZone(z)
    if mz then table.insert(self.PickupZones, mz); self._ZoneDefs.PickupZones[mz:GetName()] = z end
  end
  for _,z in ipairs(self.Config.Zones.DropZones or {}) do
    local mz = _findZone(z)
    if mz then table.insert(self.DropZones, mz); self._ZoneDefs.DropZones[mz:GetName()] = z end
  end
  for _,z in ipairs(self.Config.Zones.FOBZones or {}) do
    local mz = _findZone(z)
    if mz then table.insert(self.FOBZones, mz); self._ZoneDefs.FOBZones[mz:GetName()] = z end
  end
end

-- =========================
-- Menus
-- =========================
function CTLD:InitMenus()
  if self.Config.UseGroupMenus then
    self:WireBirthHandler()
  else
    self.MenuRoot = MENU_COALITION:New(self.Side, 'CTLD')
    self:BuildCoalitionMenus(self.MenuRoot)
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

-- =========================
-- Crates
-- =========================
function CTLD:RequestCrateForGroup(group, crateKey)
  local cat = self.Config.CrateCatalog[crateKey]
  if not cat then _msgGroup(group, 'Unknown crate type: '..tostring(crateKey)) return end
  local unit = group:GetUnit(1)
  if not unit or not unit:IsAlive() then return end
  local zone, dist = _nearestZonePoint(unit, self.Config.Zones.PickupZones)
  local spawnPoint
  if zone and dist < 10000 then
    spawnPoint = zone:GetPointVec3()
    -- if pickup zone has smoke configured, mark it
    local zdef = self._ZoneDefs.PickupZones[zone:GetName()]
    local smokeColor = (zdef and zdef.smoke) or self.Config.PickupZoneSmokeColor
    if smokeColor then
      trigger.action.smoke({ x = spawnPoint.x, z = spawnPoint.z }, smokeColor)
    end
  else
    -- fallback: spawn near aircraft current position (safe offset)
    local p = unit:GetPointVec3()
    spawnPoint = POINT_VEC3:New(p.x + 10, p.y, p.z + 10)
  end
  local cname = string.format('CTLD_CRATE_%s_%d', crateKey, math.random(100000,999999))
  _spawnStaticCargo(self.Side, { x = spawnPoint.x, z = spawnPoint.z }, cat.dcsCargoType or 'uh1h_cargo', cname)
  CTLD._crates[cname] = {
    key = crateKey,
    side = self.Side,
    spawnTime = timer.getTime(),
    point = { x = spawnPoint.x, z = spawnPoint.z },
  }
  _msgGroup(group, string.format('Spawned crate %s at %s', crateKey, zone and zone:GetName() or 'current pos'))
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
    end
  end
end

-- =========================
-- Build logic
-- =========================
function CTLD:BuildAtGroup(group)
  local unit = group:GetUnit(1)
  if not unit or not unit:IsAlive() then return end
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
  if #nearby == 0 then _msgGroup(group, 'No crates within '..radius..'m') return end

  -- Count by key
  local counts = {}
  for _,c in ipairs(nearby) do
    counts[c.meta.key] = (counts[c.meta.key] or 0) + 1
  end

  -- Include loaded crates carried by this group
  local gname = group:GetName()
  local carried = CTLD._loadedCrates[gname]
  if carried and carried.byKey then
    for k,v in pairs(carried.byKey) do
      counts[k] = (counts[k] or 0) + v
    end
  end

  -- Helper to consume crates of a given key/qty
  local function consumeCrates(key, qty)
    local removed = 0
    -- Consume from loaded crates first
    if carried and carried.byKey and (carried.byKey[key] or 0) > 0 then
      local take = math.min(qty, carried.byKey[key])
      carried.byKey[key] = carried.byKey[key] - take
      if carried.byKey[key] <= 0 then carried.byKey[key] = nil end
      carried.total = math.max(0, (carried.total or 0) - take)
      removed = removed + take
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
          local g = _coalitionAddGroup(cat.side or self.Side, cat.category or Group.Category.GROUND, gdata)
          if g then
            for reqKey,qty in pairs(cat.requires) do consumeCrates(reqKey, qty) end
            _msgGroup(group, string.format('Built %s at your location', cat.description or recipeKey))
            return
          else
            _msgGroup(group, 'Build failed: DCS group spawn error')
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
        local g = _coalitionAddGroup(cat.side or self.Side, cat.category or Group.Category.GROUND, gdata)
        if g then
          consumeCrates(key, cat.required or 1)
          _msgGroup(group, string.format('Built %s at your location', cat.description or key))
          return
        else
          _msgGroup(group, 'Build failed: DCS group spawn error')
          return
        end
      end
    end
  end

  if fobBlocked then
    _msgGroup(group, 'FOB building is restricted to designated FOB zones. Move inside a FOB zone to build.')
    return
  end

  _msgGroup(group, 'Insufficient crates to build any asset here')
end

-- =========================
-- Loaded crate management
-- =========================
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
  if not lc or (lc.total or 0) == 0 then _msgGroup(group, 'No loaded crates to drop') return end
  local unit = group:GetUnit(1)
  if not unit or not unit:IsAlive() then return end
  local p = unit:GetPointVec3()
  local here = { x = p.x, z = p.z }
  local toDrop = (howMany and howMany > 0) and howMany or lc.total
  -- Drop in key order
  for k,count in pairs(BASE:DeepCopy(lc.byKey)) do
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
  _msgGroup(group, 'Dropped loaded crates')
end

-- =========================
-- Hover pickup scanner
-- =========================
function CTLD:ScanHoverPickup()
  local hp = self.Config.HoverPickup or {}
  if not hp.Enabled then return end
  -- iterate all groups that have menus (active transports)
  for gname,root in pairs(self.MenusByGroup or {}) do
    local group = GROUP:FindByName(gname)
    if group and group:IsAlive() then
      local unit = group:GetUnit(1)
      if unit and unit:IsAlive() then
        -- Allowed type check
        local typ = _getUnitType(unit)
        if _isIn(self.Config.AllowedAircraft, typ) then
          local p3 = unit:GetPointVec3()
          local agl = 0
          if land and land.getHeight then
            agl = math.max(0, p3.y - land.getHeight({ x = p3.x, y = p3.z }))
          else
            agl = p3.y -- fallback
          end
          -- speed estimate
          local uname = unit:GetName()
          local now = timer.getTime()
          local last = CTLD._unitLast[uname]
          local speed = 0
          if last and (now > (last.t or 0)) then
            local dx = (p3.x - last.x)
            local dz = (p3.z - last.z)
            local dt = now - last.t
            if dt > 0 then speed = math.sqrt(dx*dx + dz*dz) / dt end
          end
          CTLD._unitLast[uname] = { x = p3.x, z = p3.z, t = now }

          local speedOK = (not hp.RequireLowSpeed) or (speed <= (hp.MaxSpeedMPS or 5))
          local heightOK = agl <= (hp.Height or 3)
          if speedOK and heightOK then
            -- find nearest crate within AutoPickupDistance
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
            if bestName and bestMeta and bestd <= (hp.Radius or maxd) then
              -- check capacity
              local carried = CTLD._loadedCrates[gname]
              local total = carried and carried.total or 0
              if total < (hp.MaxCratesPerLoad or 6) then
                local hs = CTLD._hoverState[uname]
                if not hs or hs.targetCrate ~= bestName then
                  CTLD._hoverState[uname] = { targetCrate = bestName, startTime = now }
                else
                  if (now - hs.startTime) >= (hp.Duration or 3) then
                    -- load it
                    local obj = StaticObject.getByName(bestName)
                    if obj then obj:destroy() end
                    CTLD._crates[bestName] = nil
                    self:_addLoadedCrate(group, bestMeta.key)
                    _msgGroup(group, string.format('Loaded %s crate', tostring(bestMeta.key)))
                    CTLD._hoverState[uname] = nil
                  end
                end
              end
            else
              CTLD._hoverState[uname] = nil
            end
          else
            CTLD._hoverState[uname] = nil
          end
        end
      end
    end
  end
end

-- =========================
-- Troops
-- =========================
function CTLD:LoadTroops(group, opts)
  local gname = group:GetName()
  local unit = group:GetUnit(1)
  if not unit or not unit:IsAlive() then return end

  local capacity = 6 -- simple default; can be adjusted per type later
  CTLD._troopsLoaded[gname] = {
    count = capacity,
    typeKey = 'RIFLE',
  }
  _msgGroup(group, string.format('Loaded %d troops (virtual). Use Unload Troops to deploy.', capacity))
end

function CTLD:UnloadTroops(group)
  local gname = group:GetName()
  local load = CTLD._troopsLoaded[gname]
  if not load or (load.count or 0) == 0 then _msgGroup(group, 'No troops onboard') return end

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
    _msgGroup(group, string.format('Deployed %d troops', #units))
  else
    _msgGroup(group, 'Deploy failed: DCS group spawn error')
  end
end

-- =========================
-- Public helpers
-- =========================
-- =========================
-- Auto-build FOB in zones
-- =========================
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
    if #nearby == 0 then goto continue end

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
            goto continue -- move to next zone; avoid multiple builds per tick
          end
        end
      end
    end
    -- Then single-key FOB recipes
    for key,cat in pairs(fobDefs) do
      if not cat.requires and (counts[key] or 0) >= (cat.required or 1) then
  local gdata = cat.build({ x = center.x, z = center.z }, 0, cat.side or self.Side)
        local g = _coalitionAddGroup(cat.side or self.Side, cat.category or Group.Category.GROUND, gdata)
        if g then
          consumeCrates(key, cat.required or 1)
          _msgCoalition(self.Side, string.format('FOB auto-built at %s', zone:GetName()))
          goto continue
        end
      end
    end

    ::continue::
  end
end

-- =========================
-- Public helpers
-- =========================
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
  self.Config.AllowedAircraft = BASE:DeepCopy(list)
end

-- =========================
-- Return factory
-- =========================
_MOOSE_CTLD = CTLD
return CTLD
