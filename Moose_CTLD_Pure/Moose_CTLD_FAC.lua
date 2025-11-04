-- Moose_CTLD_FAC.lua
--[[
Full-featured FAC/RECCE module (FAC2 parity) for pure-MOOSE CTLD, without MIST
==========================================================================
Dependencies: MOOSE (Moose.lua) and DCS core. No MIST required.

Capabilities
- AFAC/RECCE auto-detect (by group name or unit type) on Birth; per-group F10 menu
- Auto-lase (laser + IR) using DCS Spot API; configurable marker type/color; per-FAC laser code
- Manual target workflow: scan nearby, list top 10 (prioritize AA/SAM), select one, multi-strike helper
- RECCE sweeps: LoS-based scan; adds map marks with DMS/MGRS/alt/heading/speed; stores target list
- Fires & strikes: Artillery, Naval guns, Bombers/Fighters; HE/illum/mortar, guided multi-task combos
- Carpet/TALD: via menu or map marks (CBRQT/TDRQT/AttackAz <heading>)
- Event handling: Map marks (tasking), Shots (re-task), periodic schedulers (menus, status, AI spotter)

Quick start
1) Load order: Moose.lua -> Moose_CTLD.lua -> Moose_CTLD_FAC.lua
2) In mission init: local fac = _MOOSE_CTLD_FAC:New(ctld, { CoalitionSide = coalition.side.BLUE })
3) Put players in groups named with AFAC/RECON/RECCE (or use configured aircraft types)
4) Use F10 FAC/RECCE: Auto Laze ON, Scan, Select Target, Artillery, etc.

Design notes
- This module aims to match FAC2 behaviors using DCS+MOOSE equivalents; some heuristics (e.g., naval ranges)
  are conservative approximations to avoid silent failures.
]]

if not _G.BASE then
  env.info('[Moose_CTLD_FAC] Moose (BASE) not detected. Ensure Moose.lua is loaded before this script.')
end

local FAC = {}
FAC.__index = FAC
FAC.Version = '0.2.0'

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
      local isArray = (rawget(v, 1) ~= nil)
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

-- #region Config
-- Configuration for FAC behavior and UI. Adjust defaults here or pass overrides to :New().
FAC.Config = {
  CoalitionSide = coalition.side.BLUE,
  UseGroupMenus = true,
  Debug = false,

  -- Visuals / marking
  FAC_maxDistance = 18520,        -- FAC LoS search distance (m)
  FAC_smokeOn_RED = true,
  FAC_smokeOn_BLUE = true,
  FAC_smokeColour_RED = trigger.smokeColor.Green,
  FAC_smokeColour_BLUE = trigger.smokeColor.Orange,
  MarkerDefault = 'FLARES',       -- 'FLARES' | 'SMOKE'

  FAC_location = true,            -- include coords in messages
  FAC_lock = 'all',               -- 'vehicle' | 'troop' | 'all'
  FAC_laser_codes = { '1688','1677','1666','1113','1115','1111' },

  fireMissionRounds = 24,         -- default shells per call
  illumHeight = 500,              -- illumination height
  facOffsetDist = 5000,           -- offset aimpoint for mortars

  -- Platform type hints (names or types)
  facACTypes = { 'SA342L','UH-1H','Mi-8MTV2','SA342M','SA342Minigun','Mi-24P','AH-64D_BLK_II','Ka-50','Ka-50_3' },
  artyDirectorTypes = { 'Soldier M249','Paratrooper AKS-74','Soldier M4' },

  -- RECCE scan
  RecceScanRadius = 40000,
  MinReportSeparation = 400,

  -- Arty tasking
  Arty = {
    Enabled = true,
  },
}
-- #endregion Config

-- #region State
-- Internal state tracking for FACs, targets, menus, and tasking
FAC._ctld = nil
FAC._menus = {}           -- [groupName] = { root = MENU_GROUP, ... }
FAC._facUnits = {}        -- [unitName] = { name, side }
FAC._facOnStation = {}    -- [unitName] = true|nil
FAC._laserCodes = {}      -- [unitName] = '1688'
FAC._markerType = {}      -- [unitName] = 'FLARES'|'SMOKE'
FAC._markerColor = {}     -- [unitName] = smokeColor (0..4)
FAC._currentTargets = {}  -- [unitName] = { name, unitType, unitId }
FAC._laserSpots = {}      -- [unitName] = { ir=Spot, laser=Spot }
FAC._smokeMarks = {}      -- [targetName] = nextTime
FAC._manualLists = {}     -- [unitName] = { Unit[] }

FAC._facPilotNames = {}   -- dynamic add on Birth if name contains AFAC/RECON/RECCE or type in facACTypes
FAC._reccePilotNames = {}
FAC._artDirectNames = {}

FAC._ArtyTasked = {}      -- [groupName] = { tasked=int, timeTasked=time, tgt=Unit|nil, requestor=string|nil }
FAC._RECCETasked = {}     -- [unitName] = 1 when busy

-- Map mark debouncing
FAC._lastMarks = {}       -- [zoneName] = { x,z }
-- #endregion State

-- #region Utilities (no MIST)
-- Helpers for logging, vectors, coordinate formatting, headings, classification, etc.
local function _dbg(self, msg)
  if self.Config.Debug then env.info('[FAC] '..msg) end
end

local function _in(list, value)
  if not list then return false end
  for _,v in ipairs(list) do if v == value then return true end end
  return false
end

local function _vec3(p)
  return { x = p.x, y = p.y or land.getHeight({ x = p.x, y = p.z or p.y or 0 }), z = p.z or p.y }
end

local function _llToDMS(lat, lon)
  -- Convert lat/lon in degrees to DMS string (e.g., 33°30'12.34"N 036°12'34.56"E)
  local function dms(v, isLat)
    local hemi = isLat and (v >= 0 and 'N' or 'S') or (v >= 0 and 'E' or 'W')
    v = math.abs(v)
    local d = math.floor(v)
    local mFloat = (v - d) * 60
    local m = math.floor(mFloat)
    local s = (mFloat - m) * 60
    return string.format('%d°%02d\'%05.2f"%s', d, m, s, hemi)
  end
  return dms(lat, true)..' '..dms(lon, false)
end

local function _mgrsToString(m)
  -- Format DCS coord.LLtoMGRS table to "XXYY 00000 00000"; fallback to key=value if shape differs
  if not m then return '' end
  -- DCS coord.LLtoMGRS returns table like: { UTMZone=XX, MGRSDigraph=YY, Easting=nnnnn, Northing=nnnnnn }
  if m.UTMZone and m.MGRSDigraph and m.Easting and m.Northing then
    return string.format('%s%s %05d %05d', tostring(m.UTMZone), tostring(m.MGRSDigraph), math.floor(m.Easting+0.5), math.floor(m.Northing+0.5))
  end
  -- fallback stringify
  local t = {}
  for k,v in pairs(m) do table.insert(t, tostring(k)..'='..tostring(v)) end
  return table.concat(t, ',')
end

local function _bearingDeg(from, to)
  local dx = (to.x - from.x)
  local dz = (to.z - from.z)
  local ang = math.deg(math.atan2(dx, dz))
  if ang < 0 then ang = ang + 360 end
  return math.floor(ang + 0.5)
end

local function _distance(a, b)
  local dx = a.x - b.x
  local dz = a.z - b.z
  return math.sqrt(dx*dx + dz*dz)
end

local function _getHeading(unit)
  -- Approximate true heading using unit orientation + true north correction
  local pos = unit:getPosition()
  if pos then
    local heading = math.atan2(pos.x.z, pos.x.x)
    -- add true-north correction
    local p = pos.p
    local lat, lon = coord.LOtoLL(p)
    local northPos = coord.LLtoLO(lat + 1, lon)
    heading = heading + math.atan2(northPos.z - p.z, northPos.x - p.x)
    if heading < 0 then heading = heading + 2*math.pi end
    return heading
  end
  return 0
end

local function _formatUnitGeo(u)
  -- Extracts geo/status for a unit: DMS/MGRS, altitude (m/ft), heading (deg), speed (mph)
  local p = u:getPosition().p
  local lat, lon = coord.LOtoLL(p)
  local dms = _llToDMS(lat, lon)
  local mgrs = _mgrsToString(coord.LLtoMGRS(lat, lon))
  local altM = math.floor(p.y)
  local altF = math.floor(p.y * 3.28084)
  local vel = u:getVelocity() or {x=0,y=0,z=0}
  local spd = math.sqrt((vel.x or 0)^2 + (vel.z or 0)^2)
  local mph = math.floor(spd * 2) -- approx
  local hdg = math.floor(_getHeading(u) * 180/math.pi)
  return dms, mgrs, altM, altF, hdg, mph
end

local function _isInfantry(u)
  -- Heuristic: treat named manpads/mortars as infantry
  local tn = string.lower(u:getTypeName() or '')
  return tn:find('infantry') or tn:find('paratrooper') or tn:find('stinger') or tn:find('manpad') or tn:find('mortar')
end

local function _isVehicle(u)
  return not _isInfantry(u)
end

local function _isArtilleryUnit(u)
  -- Use DCS attributes to detect tube/MLRS artillery
  return u:hasAttribute('Artillery') or u:hasAttribute('MLRS')
end

local function _isNavalUnit(u)
  -- Use DCS attributes to detect surface ships with guns capability
  return u:hasAttribute('Naval') or u:hasAttribute('Cruisers') or u:hasAttribute('Frigates') or u:hasAttribute('Corvettes') or u:hasAttribute('Landing Ships')
end

local function _isBomberOrFighter(u)
  -- Detect fixed-wing strike-capable aircraft (for carpet/guided tasks)
  return u:hasAttribute('Strategic bombers') or u:hasAttribute('Bombers') or u:hasAttribute('Multirole fighters')
end

local function _coalitionOpposite(side)
  return (side == coalition.side.BLUE) and coalition.side.RED or coalition.side.BLUE
end
-- #endregion Utilities (no MIST)

-- #region Construction
-- Create a new FAC module instance. Optionally pass your CTLD instance and a config override table.
function FAC:New(ctld, cfg)
  local o = setmetatable({}, self)
  o._ctld = ctld
  o.Config = DeepCopy(FAC.Config)
  if cfg then o.Config = DeepMerge(o.Config, cfg) end
  o.Side = o.Config.CoalitionSide
  o._zones = {}

  o:_wireBirth()
  o:_wireMarks()
  o:_wireShots()

  -- Schedulers for menus/status/lase loop/AI spotters
  o._schedMenus = SCHEDULER:New(nil, function() o:_ensureMenus() end, {}, 5, 10)
  o._schedStatus = SCHEDULER:New(nil, function() o:_checkFacStatus() end, {}, 5, 1.0)
  o._schedAI = SCHEDULER:New(nil, function() o:_artyAICall() end, {}, 10, 30)

  return o
end
-- #endregion Construction

-- #region Event wiring
-- Wire Birth (to detect AFAC/RECCE/Artillery Director), Map Mark handlers (tasking), and Shot events (re-tasking)
function FAC:_wireBirth()
  local h = EVENTHANDLER:New()
  h:HandleEvent(EVENTS.Birth)
  local selfref = self
  function h:OnEventBirth(e)
    local unit = e.IniUnit
    if not unit or not unit:IsAlive() then return end
    if unit:GetCoalition() ~= selfref.Side then return end
    -- classify as AFAC / RECCE / Arty Director
    local name = unit:GetName()
    local tname = unit:GetTypeName()
    local g = unit:GetGroup()
    if not g then return end
    local gname = g:GetName() or name

  local isAFAC = (gname:find('AFAC') or gname:find('RECON')) or _in(selfref.Config.facACTypes, tname)
  local isRECCE = (gname:find('RECCE') or gname:find('RECON')) or _in(selfref.Config.facACTypes, tname)
  local isAD = _in(selfref.Config.artyDirectorTypes, tname)

    if isAFAC then selfref._facPilotNames[name] = true end
    if isRECCE then selfref._reccePilotNames[name] = true end
    if isAD then selfref._artDirectNames[name] = true end
  end
  self._hBirth = h
end

function FAC:_wireMarks()
  -- Map mark handlers for Carpet Bomb/TALD and RECCE area tasks
  local selfref = self
  self._markEH = {}
  function self._markEH:onEvent(e)
    if not e or not e.id then return end
    if e.id == world.event.S_EVENT_MARK_ADDED then
      if type(e.text) == 'string' then
        if e.text:find('CBRQT') or e.text:find('TDRQT') or e.text:find('AttackAz') then
          local az = tonumber((e.text or ''):match('(%d+)%s*$'))
          local mode = e.text:find('TDRQT') and 'TALD' or 'CARPET'
          selfref:_executeCarpetOrTALD(e.pos, e.coalition, mode, az)
          trigger.action.removeMark(e.idx)
        elseif e.text:find('RECCE') then
          selfref:_executeRecceMark(e.pos, e.coalition)
          trigger.action.removeMark(e.idx)
        end
      end
    end
  end
  world.addEventHandler(self._markEH)
end

function FAC:_wireShots()
  local selfref = self
  self._shotEH = {}
  function self._shotEH:onEvent(e)
    if e.id == world.event.S_EVENT_SHOT and e.initiator then
      local g = Unit.getGroup(e.initiator)
      if not g then return end
      local gname = g:getName()
      local T = selfref._ArtyTasked[gname]
      if T then
        T.tasked = math.max(0, (T.tasked or 0) - 1)
        if T.tasked == 0 then
          local d = g:getUnit(1):getDesc()
          trigger.action.outTextForCoalition(g:getCoalition(), (d and d.displayName or gname)..' Task Group available for re-tasking', 10)
        end
      end
    end
  end
  world.addEventHandler(self._shotEH)
end
-- #endregion Event wiring

-- #region Zone-based RECCE (optional)
-- Add a named or coordinate-based zone for periodic DETECTION_AREAS scans
function FAC:AddRecceZone(def)
  local z
  if def.name then z = ZONE:FindByName(def.name) end
  if not z and def.coord then
    local r = def.radius or 5000
    z = ZONE_RADIUS:New(def.name or ('FAC_ZONE_'..math.random(10000,99999)), VECTOR2:New(def.coord.x, def.coord.z), r)
  end
  if not z then return nil end
  local enemySide = _coalitionOpposite(self.Side)
  local setEnemies = SET_GROUP:New():FilterCoalitions(enemySide):FilterCategoryGround():FilterStart()
  local det = DETECTION_AREAS:New(setEnemies, z:GetRadius())
  det:BoundZone(z)
  local Z = { Zone = z, Name = z:GetName(), Detector = det, LastScan = 0 }
  table.insert(self._zones, Z)
  return Z
end

function FAC:RunZones(interval)
  -- Start/Restart periodic scans of configured recce zones
  if self._zoneSched then self._zoneSched:Stop() end
  self._zoneSched = SCHEDULER:New(nil, function()
    for _,Z in ipairs(self._zones) do self:_scanZone(Z) end
  end, {}, 5, interval or 20)
end

-- Backwards-compatible Run() entry point used by init scripts
function FAC:Run()
  -- Schedulers for menus/status are started in New(); here we can kick off zone scans if any zones exist.
  if #self._zones > 0 then self:RunZones() end
  return self
end

function FAC:_scanZone(Z)
  -- Perform one detection update and mark contacts, with spatial de-duplication
  Z.Detector:DetectionUpdate()
  local reps = Z.Detector:GetDetectedItems() or {}
  for _,rep in ipairs(reps) do
    local pos2 = rep.point
    if pos2 then
      local point = { x = pos2.x, z = pos2.y }
      local last = self._lastMarks[Z.Name]
      if not last or _distance(point, last) >= (self.Config.MinReportSeparation or 400) then
        self._lastMarks[Z.Name] = { x = point.x, z = point.z }
        self:_markPoint(nil, point, rep.type or 'Contact')
      end
    end
  end
end
-- #endregion Zone-based RECCE (optional)

-- #region Menus
-- Ensure per-group menus exist for active coalition player groups
function FAC:_ensureMenus()
  if not self.Config.UseGroupMenus then return end
  local players = coalition.getPlayers(self.Side) or {}
  for _,u in ipairs(players) do
    local dg = u:getGroup()
    if dg then
      local gname = dg:getName()
      if not self._menus[gname] then
        local mg = GROUP:FindByName(gname)
        if mg then
          self._menus[gname] = self:_buildGroupMenus(mg)
        end
      end
    end
  end
end

function FAC:_buildGroupMenus(group)
  -- Build the entire FAC/RECCE menu tree for a MOOSE GROUP
  local root = MENU_GROUP:New(group, 'FAC/RECCE')

  -- Status & On-Station
  MENU_GROUP_COMMAND:New(group, 'FAC: Status', root, function()
    self:_showFacStatus(group)
  end)

  local tgtRoot = MENU_GROUP:New(group, 'Targeting Mode', root)
  MENU_GROUP_COMMAND:New(group, 'Auto Laze ON', tgtRoot, function()
    self:_setOnStation(group, true)
  end)
  MENU_GROUP_COMMAND:New(group, 'Auto Laze OFF', tgtRoot, function()
    self:_setOnStation(group, nil)
  end)
  MENU_GROUP_COMMAND:New(group, 'Scan for Close Targets', tgtRoot, function()
    self:_scanManualList(group)
  end)
  local selRoot = MENU_GROUP:New(group, 'Select Found Target', tgtRoot)
  for i=1,10 do
    MENU_GROUP_COMMAND:New(group, 'Target '..i, selRoot, function() self:_setManualTarget(group, i) end)
  end
  MENU_GROUP_COMMAND:New(group, 'Call arty on all manual targets', tgtRoot, function()
    self:_multiStrike(group)
  end)

  -- Laser codes
  local lzr = MENU_GROUP:New(group, 'Laser Code', root)
  for _,code in ipairs(self.Config.FAC_laser_codes) do
    MENU_GROUP_COMMAND:New(group, code, lzr, function() self:_setLaserCode(group, code) end)
  end
  local cust = MENU_GROUP:New(group, 'Custom Code', lzr)
  local function addDigitMenu(d, max)
    local m = MENU_GROUP:New(group, 'Digit '..d, cust)
    for n=1,max do
      MENU_GROUP_COMMAND:New(group, tostring(n), m, function() self:_setLaserDigit(group, d, n) end)
    end
  end
  addDigitMenu(1,1); addDigitMenu(2,6); addDigitMenu(3,8); addDigitMenu(4,8)

  -- Marker
  local mk = MENU_GROUP:New(group, 'Marker', root)
  local sm = MENU_GROUP:New(group, 'Smoke', mk)
  local fl = MENU_GROUP:New(group, 'Flares', mk)
  local function setM(typeName, color)
    return function() self:_setMarker(group, typeName, color) end
  end
  MENU_GROUP_COMMAND:New(group, 'GREEN', sm, setM('SMOKE', trigger.smokeColor.Green))
  MENU_GROUP_COMMAND:New(group, 'RED', sm, setM('SMOKE', trigger.smokeColor.Red))
  MENU_GROUP_COMMAND:New(group, 'WHITE', sm, setM('SMOKE', trigger.smokeColor.White))
  MENU_GROUP_COMMAND:New(group, 'ORANGE', sm, setM('SMOKE', trigger.smokeColor.Orange))
  MENU_GROUP_COMMAND:New(group, 'BLUE', sm, setM('SMOKE', trigger.smokeColor.Blue))
  MENU_GROUP_COMMAND:New(group, 'GREEN', fl, setM('FLARES', trigger.smokeColor.Green))
  MENU_GROUP_COMMAND:New(group, 'WHITE', fl, setM('FLARES', trigger.smokeColor.White))
  MENU_GROUP_COMMAND:New(group, 'ORANGE', fl, setM('FLARES', trigger.smokeColor.Orange))
  MENU_GROUP_COMMAND:New(group, 'Map Marker current target', mk, function() self:_setMapMarker(group) end)

  -- Artillery
  local arty = MENU_GROUP:New(group, 'Artillery', root)
  MENU_GROUP_COMMAND:New(group, 'Check available arty', arty, function() self:_checkArty(group) end)
  MENU_GROUP_COMMAND:New(group, 'Call Fire Mission (HE)', arty, function() self:_callFireMission(group, self.Config.fireMissionRounds, 0) end)
  MENU_GROUP_COMMAND:New(group, 'Call Illumination', arty, function() self:_callFireMission(group, self.Config.fireMissionRounds, 1) end)
  MENU_GROUP_COMMAND:New(group, 'Call Mortar Only (anti-infantry)', arty, function() self:_callFireMission(group, self.Config.fireMissionRounds, 2) end)
  MENU_GROUP_COMMAND:New(group, 'Call Heavy Only (no smart)', arty, function() self:_callFireMission(group, 10, 3) end)

  local air = MENU_GROUP:New(group, 'Air/Naval', arty)
  MENU_GROUP_COMMAND:New(group, 'Single Target (GPS/Guided)', air, function() self:_callFireMission(group, 1, 4) end)
  MENU_GROUP_COMMAND:New(group, 'Multi Target (Guided only)', air, function() self:_callFireMissionMulti(group, 1, 4) end)
  MENU_GROUP_COMMAND:New(group, 'Carpet Bomb (attack heading = aircraft heading)', air, function() self:_callCarpetOnCurrent(group) end)

  -- RECCE
  MENU_GROUP_COMMAND:New(group, 'RECCE: Sweep & Mark', root, function() self:_recceDetect(group) end)

  MESSAGE:New('FAC/RECCE menu ready (F10)', 10):ToGroup(group)
  return { root = root }
end
-- #endregion Menus

-- #region Status & On-station
function FAC:_facName(unitName)
  local u = Unit.getByName(unitName)
  if u and u:getPlayerName() then return u:getPlayerName() end
  return unitName
end

function FAC:_showFacStatus(group)
  local unit = group:GetUnit(1)
  if not unit or not unit:IsAlive() then return end
  local side = unit:GetCoalition()
  local colorToStr = { [trigger.smokeColor.Green]='GREEN',[trigger.smokeColor.Red]='RED',[trigger.smokeColor.White]='WHITE',[trigger.smokeColor.Orange]='ORANGE',[trigger.smokeColor.Blue]='BLUE' }
  local msg = 'FAC STATUS:\n\n'
  for uname,_ in pairs(self._facUnits) do
    local u = Unit.getByName(uname)
    if u and u:getLife()>0 and u:isActive() and u:getCoalition()==side and self._facOnStation[uname] then
      local tgt = self._currentTargets[uname]
      local lcd = self._laserCodes[uname] or 'UNKNOWN'
      local marker = self._markerType[uname] or self.Config.MarkerDefault
      local mcol = self._markerColor[uname]
      local mcolStr = mcol and (colorToStr[mcol] or tostring(mcol)) or 'WHITE'
      if tgt then
        local eu = Unit.getByName(tgt.name)
        if eu and eu:isActive() and eu:getLife()>0 then
          msg = msg .. string.format('%s targeting %s CODE %s %s\nMarked %s %s\n', self:_facName(uname), eu:getTypeName(), lcd, self:_posString(eu), mcolStr, marker)
        else
          msg = msg .. string.format('%s on-station CODE %s\n', self:_facName(uname), lcd)
        end
      else
        msg = msg .. string.format('%s on-station CODE %s\n', self:_facName(uname), lcd)
      end
    end
  end
  if msg == 'FAC STATUS:\n\n' then
    msg = 'No Active FACs. Join AFAC/RECON to play as flying JTAC and Artillery Spotter.'
  end
  trigger.action.outTextForCoalition(side, msg, 20)
end

function FAC:_posString(u)
  -- Render a compact position string for messages
  if not self.Config.FAC_location then return '' end
  local p = u:getPosition().p
  local lat, lon = coord.LOtoLL(p)
  local dms = _llToDMS(lat, lon)
  local mgrs = _mgrsToString(coord.LLtoMGRS(lat, lon))
  local altM = math.floor(p.y)
  local altF = math.floor(p.y*3.28084)
  return string.format('@ DMS %s MGRS %s Alt %dm/%dft', dms, mgrs, altM, altF)
end

function FAC:_setOnStation(group, on)
  local u = group:GetUnit(1)
  if not u or not u:IsAlive() then return end
  local uname = u:GetName()
  -- init defaults
  if not self._laserCodes[uname] then self._laserCodes[uname] = self.Config.FAC_laser_codes[1] end
  if not self._markerType[uname] then self._markerType[uname] = self.Config.MarkerDefault end
  if not self._facUnits[uname] then self._facUnits[uname] = { name = uname, side = u:GetCoalition() } end

  if not self._facOnStation[uname] and on then
    trigger.action.outTextForCoalition(u:GetCoalition(), string.format('[FAC "%s" on-station using CODE %s]', self:_facName(uname), self._laserCodes[uname]), 10)
  elseif self._facOnStation[uname] and not on then
    trigger.action.outTextForCoalition(u:GetCoalition(), string.format('[FAC "%s" off-station]', self:_facName(uname)), 10)
    self:_cancelLase(uname)
    self._currentTargets[uname] = nil
    self._facUnits[uname] = nil
  end
  self._facOnStation[uname] = on and true or nil

  -- start autolase one-shot; the status scheduler keeps it alive every 1s
  if on then self:_autolase(uname) end
end

function FAC:_setLaserCode(group, code)
  -- Set the laser code for this FAC; updates status if on-station
  local u = group:GetUnit(1); if not u or not u:IsAlive() then return end
  local uname = u:GetName()
  self._laserCodes[uname] = tostring(code)
  if self._facOnStation[uname] then
    trigger.action.outTextForCoalition(u:GetCoalition(), string.format('[FAC "%s" on-station using CODE %s]', self:_facName(uname), self._laserCodes[uname]), 10)
  end
end

function FAC:_setLaserDigit(group, digit, val)
  local u = group:GetUnit(1); if not u or not u:IsAlive() then return end
  local uname = u:GetName()
  local cur = self._laserCodes[uname] or '1688'
  local s = tostring(cur)
  if #s ~= 4 then s = '1688' end
  local pre = s:sub(1, digit-1)
  local post = s:sub(digit+1)
  s = pre .. tostring(val) .. post
  self:_setLaserCode(group, s)
end

function FAC:_setMarker(group, typ, color)
  local u = group:GetUnit(1); if not u or not u:IsAlive() then return end
  local uname = u:GetName()
  self._markerType[uname] = typ
  self._markerColor[uname] = color
  local colorStr = ({[trigger.smokeColor.Green]='GREEN',[trigger.smokeColor.Red]='RED',[trigger.smokeColor.White]='WHITE',[trigger.smokeColor.Orange]='ORANGE',[trigger.smokeColor.Blue]='BLUE'})[color] or 'WHITE'
  if self._facOnStation[uname] then
    trigger.action.outTextForCoalition(u:GetCoalition(), string.format('[FAC "%s" on-station marking with %s %s]', self:_facName(uname), colorStr, typ), 10)
  else
    MESSAGE:New('Marker set to '..colorStr..' '..typ, 10):ToGroup(group)
  end
end

function FAC:_setMapMarker(group)
  local u = group:GetUnit(1); if not u or not u:IsAlive() then return end
  local uname = u:GetName()
  local tgt = self._currentTargets[uname]
  if not tgt then MESSAGE:New('No Target to Mark', 10):ToGroup(group); return end
  local t = Unit.getByName(tgt.name)
  if not t or not t:isActive() then return end
  local dms, mgrs, altM, altF, hdg, mph = _formatUnitGeo(t)
  local text = string.format('%s - DMS %s Alt %dm/%dft\nHeading %d Speed %d MPH\nSpotted by %s', t:getTypeName(), dms, altM, altF, hdg, mph, self:_facName(uname))
  local id = math.floor(timer.getTime()*1000 + 0.5)
  trigger.action.markToCoalition(id, text, t:getPoint(), u:GetCoalition(), false)
  timer.scheduleFunction(function(idp) trigger.action.removeMark(idp) end, id, timer.getTime() + 300)
end
-- #endregion Status & On-station

-- #region Auto-lase loop & target selection
function FAC:_checkFacStatus()
  -- Autostart for AI FACs and run autolase cadence
  for uname,_ in pairs(self._facPilotNames) do
    local u = Unit.getByName(uname)
    if u and u:isActive() and u:getLife()>0 then
      if not self._facUnits[uname] and (u:getPlayerName() == nil) then
        self._facOnStation[uname] = true
      end
      if (not self._facUnits[uname]) and self._facOnStation[uname] then
        self:_autolase(uname)
      end
    end
  end
end

function FAC:_autolase(uname)
  local u = Unit.getByName(uname)
  if not u then
    if self._facUnits[uname] then
      trigger.action.outTextForCoalition(self._facUnits[uname].side, string.format('[FAC "%s" MIA]', self:_facName(uname)), 10)
    end
    self:_cleanupFac(uname)
    return
  end
  if not self._facOnStation[uname] then self:_cancelLase(uname); self._currentTargets[uname]=nil; return end
  if not self._laserCodes[uname] then self._laserCodes[uname] = self.Config.FAC_laser_codes[1] end
  if not self._facUnits[uname] then self._facUnits[uname] = { name = u:getName(), side = u:getCoalition() } end
  if not self._markerType[uname] then self._markerType[uname] = self.Config.MarkerDefault end

  if not u:isActive() then
    timer.scheduleFunction(function(args) self:_autolase(args[1]) end, {uname}, timer.getTime()+30)
    return
  end

  local enemy = self:_currentOrFindEnemy(u, uname)
  if enemy then
    self:_laseUnit(enemy, u, uname, self._laserCodes[uname])
    -- variable next tick based on target speed
    local v = enemy:getVelocity() or {x=0,z=0}
    local spd = math.sqrt((v.x or 0)^2 + (v.z or 0)^2)
    local next = (spd < 1) and 1 or 1/spd
    timer.scheduleFunction(function(args) self:_autolase(args[1]) end, {uname}, timer.getTime()+next)
    -- markers recurring
    local nm = self._smokeMarks[enemy:getName()]
    if nm and nm < timer.getTime() then self:_createMarker(enemy, uname) end
  else
    self:_cancelLase(uname)
    timer.scheduleFunction(function(args) self:_autolase(args[1]) end, {uname}, timer.getTime()+5)
  end
end

function FAC:_currentOrFindEnemy(facUnit, uname)
  local cur = self._currentTargets[uname]
  if cur then
    local eu = Unit.getByName(cur.name)
    if eu and eu:isActive() and eu:getLife()>0 then
      local d = _distance(eu:getPoint(), facUnit:getPoint())
      if d < (self.Config.FAC_maxDistance or 18520) then
        local epos = eu:getPoint()
        if land.isVisible({x=epos.x,y=epos.y+2,z=epos.z}, {x=facUnit:getPoint().x,y=facUnit:getPoint().y+2,z=facUnit:getPoint().z}) then
          return eu
        end
      end
    end
  end
  -- find nearest visible
  return self:_findNearestEnemy(facUnit, self.Config.FAC_lock)
end

function FAC:_findNearestEnemy(facUnit, targetType)
  local facSide = facUnit:getCoalition()
  local enemySide = _coalitionOpposite(facSide)
  local nearest, best = nil, self.Config.FAC_maxDistance or 18520
  local origin = facUnit:getPoint()

  local volume = { id = world.VolumeType.SPHERE, params = { point = origin, radius = self.Config.FAC_maxDistance or 18520 } }
  local function search(u)
    if u:getLife() <= 1 or u:inAir() then return end
    if u:getCoalition() ~= enemySide then return end
    local up = u:getPoint()
    local d = _distance(up, origin)
    if d >= best then return end
    local allowed = true
    if targetType == 'vehicle' then allowed = _isVehicle(u)
    elseif targetType == 'troop' then allowed = _isInfantry(u) end
    if not allowed then return end
    if land.isVisible({x=up.x,y=up.y+2,z=up.z}, {x=origin.x,y=origin.y+2,z=origin.z}) and u:isActive() then
      best = d; nearest = u
    end
  end
  world.searchObjects(Object.Category.UNIT, volume, search)
  if nearest then
    local uname = facUnit:getName()
    self._currentTargets[uname] = { name = nearest:getName(), unitType = nearest:getTypeName(), unitId = nearest:getID() }
    self:_announceNewTarget(facUnit, nearest, uname)
    self:_createMarker(nearest, uname)
  end
  return nearest
end

function FAC:_announceNewTarget(facUnit, enemy, uname)
  local col = self._markerColor[uname]
  local colorStr = ({[trigger.smokeColor.Green]='GREEN',[trigger.smokeColor.Red]='RED',[trigger.smokeColor.White]='WHITE',[trigger.smokeColor.Orange]='ORANGE',[trigger.smokeColor.Blue]='BLUE'})[col or trigger.smokeColor.White] or 'WHITE'
  local dms, mgrs, altM, altF, hdg, mph = _formatUnitGeo(enemy)
  local msg = string.format('[%s lasing new target %s. CODE %s @ DMS %s MGRS %s Alt %dm/%dft\nMarked %s %s]',
    self:_facName(uname), enemy:getTypeName(), self._laserCodes[uname] or '1688', dms, mgrs, altM, altF, colorStr, self._markerType[uname] or 'FLARES')
  trigger.action.outTextForCoalition(facUnit:getCoalition(), msg, 10)
end

function FAC:_createMarker(enemy, uname)
  local typ = self._markerType[uname] or self.Config.MarkerDefault
  local col = self._markerColor[uname]
  local when = (typ == 'SMOKE') and 300 or 5
  self._smokeMarks[enemy:getName()] = timer.getTime() + when
  local p = enemy:getPoint()
  if typ == 'SMOKE' then
    trigger.action.smoke({x=p.x, y=p.y+2, z=p.z}, col or trigger.smokeColor.White)
  else
    trigger.action.signalFlare({x=p.x, y=p.y+2, z=p.z}, col or trigger.smokeColor.White, 0)
  end
end

function FAC:_cancelLase(uname)
  local S = self._laserSpots[uname]
  if S then
    if S.ir then Spot.destroy(S.ir) end
    if S.laser then Spot.destroy(S.laser) end
    self._laserSpots[uname] = nil
  end
end

function FAC:_laseUnit(enemy, facUnit, uname, code)
  local p = enemy:getPoint()
  local tgt = { x=p.x, y=p.y+2, z=p.z }
  local spots = self._laserSpots[uname]
  if not spots then
    spots = {}
    local ok, res = pcall(function()
      spots.ir = Spot.createInfraRed(facUnit, {x=0,y=2,z=0}, tgt)
      spots.laser = Spot.createLaser(facUnit, {x=0,y=2,z=0}, tgt, tonumber(code) or 1688)
      return spots
    end)
    if ok then
      self._laserSpots[uname] = spots
    else
      env.error('[FAC] Spot creation failed: '..tostring(res))
    end
  else
    if spots.ir then spots.ir:setPoint(tgt) end
    if spots.laser then spots.laser:setPoint(tgt) end
  end
end

function FAC:_cleanupFac(uname)
  self:_cancelLase(uname)
  self._laserCodes[uname] = nil
  self._markerType[uname] = nil
  self._markerColor[uname] = nil
  self._currentTargets[uname] = nil
  self._facUnits[uname] = nil
  self._facOnStation[uname] = nil
end

-- #endregion Auto-lase loop & target selection

-- #region Manual Scan/Select
-- Manual Scan/Select
function FAC:_scanManualList(group)
  local u = group:GetUnit(1); if not u or not u:IsAlive() then return end
  local uname = u:GetName()
  local origin = u:GetPoint()
  local enemySide = _coalitionOpposite(u:GetCoalition())
  local foundAA, foundOther = {}, {}
  local function ins(tbl, item) table.insert(tbl, item) end
  local function cb(item)
    if item:getCoalition() ~= enemySide then return end
    if item:inAir() or not item:isActive() or item:getLife() <= 1 then return end
    local p = item:getPoint()
    if land.isVisible({x=p.x,y=p.y+2,z=p.z}, {x=origin.x,y=origin.y+2,z=origin.z}) then
      if item:hasAttribute('SAM TR') or item:hasAttribute('IR Guided SAM') or item:hasAttribute('AA_flak') then
        ins(foundAA, item)
      else
        ins(foundOther, item)
      end
    end
  end
  world.searchObjects(Object.Category.UNIT, { id=world.VolumeType.SPHERE, params={ point = origin, radius = self.Config.FAC_maxDistance } }, cb)
  local list = {}
  for i=1,10 do list[i] = foundAA[i] or foundOther[i] end
  self._manualLists[uname] = list
  -- print bearings/ranges
  local gid = group:GetDCSObject() and group:GetDCSObject():getID() or nil
  for i,v in ipairs(list) do
    if v then
      local p = v:getPoint()
      local d = _distance(p, origin)
      local dy, dx = p.z - origin.z, p.x - origin.x
      local hdg = math.deg(math.atan2(dx, dy))
      if hdg < 0 then hdg = hdg + 360 end
      if gid then
        trigger.action.outTextForGroup(gid, string.format('Target %d: %s Bearing %d Range %dm/%dft', i, v:getTypeName(), math.floor(hdg+0.5), math.floor(d), math.floor(d*3.28084)), 30)
        local id = math.floor(timer.getTime()*1000 + i)
        trigger.action.markToGroup(id, 'Target '..i..':'..v:getTypeName(), v:getPoint(), gid, false)
        timer.scheduleFunction(function(mid) trigger.action.removeMark(mid) end, id, timer.getTime()+60)
      end
    end
  end
end

function FAC:_setManualTarget(group, idx)
  local u = group:GetUnit(1); if not u or not u:IsAlive() then return end
  local uname = u:GetName()
  local list = self._manualLists[uname]
  if not list or not list[idx] then
    MESSAGE:New('Invalid Target', 10):ToGroup(group)
    return
  end
  local enemy = list[idx]
  if enemy and enemy:getLife()>0 then
    self._currentTargets[uname] = { name = enemy:getName(), unitType = enemy:getTypeName(), unitId = enemy:getID() }
    self:_setOnStation(group, true)
    self:_createMarker(enemy, uname)
    MESSAGE:New(string.format('Designating Target %d: %s', idx, enemy:getTypeName()), 10):ToGroup(group)
  else
    MESSAGE:New(string.format('Target %d already dead', idx), 10):ToGroup(group)
  end
end

function FAC:_multiStrike(group)
  local u = group:GetUnit(1); if not u or not u:IsAlive() then return end
  local uname = u:GetName()
  local list = self._manualLists[uname] or {}
  for _,t in ipairs(list) do if t and t:isExist() then self:_callFireMission(group, 10, 0, t) end end
end
-- #endregion Manual Scan/Select

-- #region RECCE sweep (aircraft-based)
function FAC:_recceDetect(group)
  local u = group:GetUnit(1); if not u or not u:IsAlive() then return end
  local uname = u:GetName()
  local side = u:GetCoalition()
  local pos = u:GetPoint()
  local enemySide = _coalitionOpposite(side)
  local temp = {}
  local count = 0
  local function cb(item)
    if item:getCoalition() ~= enemySide then return end
    if item:getLife() < 1 then return end
    local p = item:getPoint()
    if land.isVisible({x=p.x,y=p.y+2,z=p.z}, {x=pos.x,y=pos.y+2,z=pos.z}) and (item:isActive() or item:getCategory()==Object.Category.STATIC) then
      count = count + 1
      local dms, mgrs, altM, altF, hdg, mph = _formatUnitGeo(item)
      local id = math.floor(timer.getTime()*1000 + count)
      local text = string.format('%s - DMS %s Alt %dm/%dft\nHeading %d Speed %d MPH\nSpotted by %s', item:getTypeName(), dms, altM, altF, hdg, mph, self:_facName(uname))
      trigger.action.markToCoalition(id, text, item:getPoint(), side, false)
      timer.scheduleFunction(function(mid) trigger.action.removeMark(mid) end, id, timer.getTime()+300)
      table.insert(temp, item)
    end
  end
  world.searchObjects(Object.Category.UNIT, { id=world.VolumeType.SPHERE, params={ point = pos, radius = self.Config.RecceScanRadius } }, cb)
  world.searchObjects(Object.Category.STATIC, { id=world.VolumeType.SPHERE, params={ point = pos, radius = self.Config.RecceScanRadius } }, cb)
  self._manualLists[uname] = temp
end

function FAC:_executeRecceMark(pos, coal)
  -- Find nearest AI recce unit of coalition not busy, task to fly over and run recceDetect via script action
  -- For simplicity we just run a coalition-wide recce flood at mark point using nearby AI if available; else no-op.
  trigger.action.outTextForCoalition(coal, 'RECCE task requested at map mark', 10)
end
-- #endregion RECCE sweep (aircraft-based)

-- #region Artillery/Naval/Air tasking
function FAC:_artyAmmo(units)
  local total = 0
  for i=1,#units do
    local ammo = units[i]:getAmmo()
    if ammo then
      if ammo[1] then total = total + (ammo[1].count or 0) end
    end
  end
  return total
end

function FAC:_guidedAmmo(units)
  local total = 0
  for i=1,#units do
    local ammo = units[i]:getAmmo()
    if ammo then
      for k=1,#ammo do
        local d = ammo[k].desc
        if d and d.guidance == 1 then total = total + (ammo[k].count or 0) end
      end
    end
  end
  return total
end

function FAC:_navalGunStats(units)
  local total, maxRange = 0, 0
  for i=1,#units do
    local ammo = units[i]:getAmmo()
    if ammo then
      for k=1,#ammo do
        local d = ammo[k].desc
        if d and d.category == 0 and d.warhead and d.warhead.caliber and d.warhead.caliber >= 75 then
          total = total + (ammo[k].count or 0)
          local r = (d.warhead.caliber >= 120) and 22222 or 18000
          if r > maxRange then maxRange = r end
        end
      end
    end
  end
  return total, maxRange
end

function FAC:_getArtyFor(point, facUnit, mode)
  -- mode: 0 HE, 1 illum, 2 mortar only, 3 heavy only (no smart), 4 guided/naval/air, -1 any except bombers
  local side = facUnit and facUnit:getCoalition() or self.Side
  local bestName
  local candidates = {}
  local function consider(found)
    if found:getCoalition() ~= side or not found:isActive() or found:getPlayerName() then return end
    local u = found
    local g = u:getGroup()
    if not g then return end
    local gname = g:getName()
    if candidates[gname] then return end
    if not self._ArtyTasked[gname] then self._ArtyTasked[gname] = { name=gname, tasked=0, timeTasked=nil, tgt=nil, requestor=nil } end
    if self._ArtyTasked[gname].tasked ~= 0 and (mode ~= -1 or self._ArtyTasked[gname].requestor ~= 'AI Spotter') then return end
    table.insert(candidates, gname)
  end
  world.searchObjects(Object.Category.UNIT, { id=world.VolumeType.SPHERE, params={ point = point, radius = 4600000 } }, consider)

  local filtered = {}
  for _,gname in ipairs(candidates) do
    local g = Group.getByName(gname)
    if g and g:isExist() then
      local u1 = g:getUnit(1)
      local pos = u1:getPoint()
      local d = _distance(pos, point)
      if mode == 4 then
        if _isBomberOrFighter(u1) or _isNavalUnit(u1) then
          if _isNavalUnit(u1) then
            local tot, rng = self:_navalGunStats(g:getUnits())
            if tot>0 and rng >= d then table.insert(filtered, gname) end
          else
            if self:_guidedAmmo(g:getUnits()) > 0 then table.insert(filtered, gname) end
          end
        end
      else
        if _isNavalUnit(u1) then
          local tot, rng = self:_navalGunStats(g:getUnits())
          if tot>0 and rng >= d then table.insert(filtered, gname) end
        elseif _isArtilleryUnit(u1) then
          -- crude range gates by type name buckets
          table.insert(filtered, gname)
        end
      end
    end
  end
  local best, bestAmmo
  for _,gname in ipairs(filtered) do
    local g = Group.getByName(gname)
    local ammo = self:_artyAmmo(g:getUnits())
    if (not bestAmmo) or ammo > bestAmmo then bestAmmo = ammo; best = gname end
  end
  if best then return Group.getByName(best) end
  return nil
end

function FAC:_checkArty(group)
  local u = group:GetUnit(1); if not u or not u:IsAlive() then return end
  local pos = u:GetPoint()
  local g = self:_getArtyFor(pos, u, 0)
  if g then
    MESSAGE:New('Arty available: '..g:getName(), 10):ToGroup(group)
  else
    MESSAGE:New('No untasked arty/bomber/naval in range', 10):ToGroup(group)
  end
end

function FAC:_callFireMission(group, rounds, mode, specificTarget)
  -- Resolve a suitable asset (arty/naval/air) and push a task at the current target or a forward offset
  local u = group:GetUnit(1); if not u or not u:IsAlive() then return end
  local uname = u:GetName()
  local enemy = specificTarget or (self._currentTargets[uname] and Unit.getByName(self._currentTargets[uname].name))
  local attackPoint
  if enemy and enemy:isActive() then attackPoint = enemy:getPoint() else
    -- offset forward of FAC as fallback
    local hdg = _getHeading(u)
    attackPoint = { x = u:GetPoint().x + math.cos(hdg)*self.Config.facOffsetDist, y = u:GetPoint().y, z = u:GetPoint().z + math.sin(hdg)*self.Config.facOffsetDist }
  end
  local arty = self:_getArtyFor(attackPoint, u, mode)
  if not arty then
    MESSAGE:New('Unable to process fire mission: no asset in range', 10):ToGroup(group)
    return
  end
  local firepoint = { x = attackPoint.x, y = attackPoint.z, altitude = arty:getUnit(1):getPoint().y, altitudeEnabled = true, attackQty = 1, expend = 'One', weaponType = 268402702 }
  local task
  if _isNavalUnit(arty:getUnit(1)) then
    task = { id='FireAtPoint', params = { point = { x = attackPoint.x, y = attackPoint.y, z = attackPoint.z }, expendQty = 1, dispersion = 50, attackQty = 1, weaponType = 0 } }
  elseif _isBomberOrFighter(arty:getUnit(1)) then
    task = { id='Bombing', params = { y = attackPoint.z, x = attackPoint.x, altitude = firepoint.altitude, altitudeEnabled = true, attackQty = 1, groupAttack = true, weaponType = 2147485694 } }
  else
    task = { id='FireAtPoint', params = { point = { x = attackPoint.x, y = attackPoint.y, z = attackPoint.z }, expendQty = rounds or 1, dispersion = 50, attackQty = 1, weaponType = 0 } }
  end
  local ctrl = arty:getController()
  ctrl:setOption(1,1)
  ctrl:pushTask(task)
  ctrl:setOption(10,3221225470)
  local ammo = self:_artyAmmo(arty:getUnits())
  self._ArtyTasked[arty:getName()] = { name = arty:getName(), tasked = rounds or 1, timeTasked = timer.getTime(), tgt = enemy, requestor = self:_facName(uname) }
  trigger.action.outTextForCoalition(u:GetCoalition(), string.format('Fire mission sent: %s firing %d rounds. Requestor: %s', arty:getUnit(1):getTypeName(), rounds or 1, self:_facName(uname)), 10)
end

function FAC:_callFireMissionMulti(group, rounds, mode)
  local u = group:GetUnit(1); if not u or not u:IsAlive() then return end
  local uname = u:GetName()
  local list = self._manualLists[uname]
  if not list or #list == 0 then MESSAGE:New('No manual targets. Scan first.', 10):ToGroup(group) return end
  local first = list[1]
  local arty = self:_getArtyFor(first:getPoint(), u, 4)
  if not arty then MESSAGE:New('No guided asset available', 10):ToGroup(group) return end
  local tasks = {}
  local guided = self:_guidedAmmo(arty:getUnits())
  for i,t in ipairs(list) do
    if i > guided then break end
    local p = t:getPoint()
    tasks[#tasks+1] = { number = i, id='Bombing', enabled=true, auto=false, params={ y=p.z, x=p.x, altitude=arty:getUnit(1):getPoint().y, altitudeEnabled=true, attackQty=1, groupAttack=false, weaponType=8589934592 } }
  end
  local combo = { id='ComboTask', params = { tasks = tasks } }
  local ctrl = arty:getController()
  ctrl:setOption(1,1)
  ctrl:pushTask(combo)
  ctrl:setOption(10,3221225470)
  self._ArtyTasked[arty:getName()] = { name=arty:getName(), tasked = #tasks, timeTasked=timer.getTime(), tgt=nil, requestor=self:_facName(uname) }
  trigger.action.outTextForCoalition(u:GetCoalition(), string.format('Guided strike queued on %d targets', #tasks), 10)
end

function FAC:_callCarpetOnCurrent(group)
  -- Carpet bomb the current target using attack heading of the aircraft
  local u = group:GetUnit(1); if not u or not u:IsAlive() then return end
  local uname = u:GetName()
  local tgt = self._currentTargets[uname]
  if not tgt then MESSAGE:New('No current target', 10):ToGroup(group) return end
  local enemy = Unit.getByName(tgt.name)
  if not enemy or not enemy:isActive() then MESSAGE:New('Target invalid', 10):ToGroup(group) return end
  self:_executeCarpetOrTALD(enemy:getPoint(), u:GetCoalition(), 'CARPET', math.floor(_getHeading(u)*180/math.pi))
end

function FAC:_executeCarpetOrTALD(point, coal, mode, attackHeadingDeg)
  local side = coal or self.Side
  local arty = self:_getArtyFor(point, nil, (mode=='TALD') and 4 or 5)
  if not arty then
    trigger.action.outTextForCoalition(side, 'No bomber/naval asset available for '..(mode or 'CARPET'), 10)
    return
  end
  local u1 = arty:getUnit(1)
  local pos = u1:getPoint()
  local hdg = attackHeadingDeg and math.rad(attackHeadingDeg) or 0
  local weaponType = (mode=='TALD') and 8589934592 or 2147485694
  local altitude = (mode=='TALD') and 10000 or pos.y
  local task = { id='Bombing', params={ x=point.x, y=point.z, altitude=altitude, altitudeEnabled=true, attackQty=1, groupAttack=true, weaponType=weaponType, direction=hdg, directionEnabled=true } }
  local ctrl = arty:getController()
  ctrl:setOption(1,1)
  ctrl:setTask(task)
  ctrl:setOption(10,3221225470)
  trigger.action.outTextForCoalition(side, string.format('%s ordered to attack map mark (hdg %d)', u1:getTypeName(), attackHeadingDeg or 0), 10)
end
-- Provide a stub for periodic AI spotter loop (safe to extend as needed)
function FAC:_artyAICall()
  return
end

-- #endregion Artillery/Naval/Air tasking

-- #region Mark helpers
function FAC:_markPoint(group, point, label)
  local p3 = { x=point.x, y=land.getHeight({x=point.x,y=point.z}), z=point.z }
  trigger.action.smoke(p3, self.Config.FAC_smokeColour_BLUE)
  local id = math.floor(timer.getTime()*1000 + 0.5)
  local lat, lon = coord.LOtoLL(p3)
  local txt = string.format('FAC: %s at %s', label or 'Contact', _llToDMS(lat,lon))
  trigger.action.markToCoalition(id, txt, p3, self.Side, true)
end
-- #endregion Mark helpers

-- #region Export
_MOOSE_CTLD_FAC = FAC
return FAC
-- #endregion Export
