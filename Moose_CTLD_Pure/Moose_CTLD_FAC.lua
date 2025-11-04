-- Moose_CTLD_FAC.lua
-- FAC/RECCE features integrated with pure-MOOSE CTLD
-- Provides: recce zones, auto target marking (smoke/illum), JTAC auto-lase bootstrap, optional artillery mark tasks

if not _G.Moose or not _G.BASE then
  env.info('[Moose_CTLD_FAC] Moose not detected. Ensure Moose.lua is loaded before this script.')
end

local FAC = {}
FAC.__index = FAC
FAC.Version = '0.1.0-alpha'

FAC.Config = {
  CoalitionSide = coalition.side.BLUE,
  ScanInterval = 20,         -- seconds between scans
  MarkSmokeColor = trigger.smokeColor.Red,
  MarkIllum = false,         -- drop illumination at night if true
  MarkText = true,           -- place map marks with target info
  DetectionRadius = 5000,    -- meters within zone
  MinReportSeparation = 400, -- meters between subsequent marks to reduce spam
  UseGroupMenus = true,
  Debug = false,
  Arty = {                   -- optional artillery support
    Enabled = true,
    Groups = {               -- names of friendly artillery groups to use for marking
      -- 'BLUE_ARTY_1',
    },
    Rounds = 3,
    Spread = 120,            -- meters randomization around mark point
  }
}

FAC._lastMarks = {} -- [zoneName] = { lastPoint = {x,z} }

function FAC:New(ctld, cfg)
  local o = setmetatable({}, self)
  o.CTLD = ctld
  o.Config = BASE:DeepCopy(FAC.Config)
  if cfg then o.Config = BASE:Inherit(o.Config, cfg) end
  o.Side = o.Config.CoalitionSide
  o.Zones = {}
  o.MenusByGroup = {}

  if o.Config.UseGroupMenus then o:WireBirthHandler() end
  return o
end

function FAC:WireBirthHandler()
  local handler = EVENTHANDLER:New()
  handler:HandleEvent(EVENTS.Birth)
  local selfref = self
  function handler:OnEventBirth(eventData)
    local unit = eventData.IniUnit
    if not unit or not unit:IsAlive() then return end
    if unit:GetCoalition() ~= selfref.Side then return end
    local grp = unit:GetGroup()
    if not grp then return end
    local gname = grp:GetName()
    if selfref.MenusByGroup[gname] then return end
    -- Simple menu: FAC actions
    local root = MENU_GROUP:New(grp, 'FAC/RECCE')
    MENU_GROUP_COMMAND:New(grp, 'List Recce Zones', root, function() selfref:MenuListZones(grp) end)
    MENU_GROUP_COMMAND:New(grp, 'Mark Contacts (all zones)', root, function() selfref:ForceScanAll(grp) end)
    selfref.MenusByGroup[gname] = root
    MESSAGE:New('FAC/RECCE menu available (F10)', 10):ToGroup(grp)
  end
  self.BirthHandler = handler
end

function FAC:AddRecceZone(def)
  -- def: { name='ZONE_NAME' } or { coord={x,y,z}, radius=NN, name='Recce1' }
  local z
  if def.name then
    z = ZONE:FindByName(def.name)
  end
  if not z and def.coord then
    local r = def.radius or 5000
    z = ZONE_RADIUS:New(def.name or ('FAC_ZONE_'..math.random(10000,99999)), VECTOR2:New(def.coord.x, def.coord.z), r)
  end
  if not z then return nil end
  local Z = {
    Zone = z,
    Name = z:GetName(),
    Detector = self:CreateDetector(z),
    LastScan = 0,
  }
  table.insert(self.Zones, Z)
  return Z
end

function FAC:CreateDetector(zone)
  -- Detection in areas using Moose detection classes
  local enemySide = (self.Side == coalition.side.BLUE) and coalition.side.RED or coalition.side.BLUE
  local setEnemies = SET_GROUP:New():FilterCoalitions(enemySide):FilterCategoryGround():FilterStart()
  local det = DETECTION_AREAS:New(setEnemies, zone:GetRadius())
  det:BoundZone(zone)
  return det
end

function FAC:MenuListZones(group)
  local names = {}
  for _,Z in ipairs(self.Zones) do table.insert(names, Z.Name) end
  MESSAGE:New('Recce zones: '..(table.concat(names, ', '):gsub('^%s+$','none')), 15):ToGroup(group)
end

function FAC:ForceScanAll(group)
  for _,Z in ipairs(self.Zones) do self:ScanZone(Z, group) end
end

function FAC:Run()
  -- schedule periodic scanning
  if self.Sched then self.Sched:Stop() end
  self.Sched = SCHEDULER:New(nil, function()
    for _,Z in ipairs(self.Zones) do self:ScanZone(Z) end
  end, {}, 5, self.Config.ScanInterval)
end

local function _p3(v2)
  return { x = v2.x, y = land.getHeight({x=v2.x, y=v2.y}), z = v2.y }
end

function FAC:ScanZone(Z, notifyGroup)
  local now = timer.getTime()
  local det = Z.Detector
  det:DetectionUpdate()
  local reports = det:GetDetectedItems()
  if not reports or #reports == 0 then
    if notifyGroup then MESSAGE:New('No contacts detected in '..Z.Name, 10):ToGroup(notifyGroup) end
    return
  end

  local enemySide = (self.Side == coalition.side.BLUE) and coalition.side.RED or coalition.side.BLUE
  for _,rep in ipairs(reports) do
    local contact = rep.object -- wrapper around GROUP or UNIT
    local pos2 = rep.point -- vec2
    if pos2 then
      local markPoint = { x = pos2.x, z = pos2.y }
      local allow = true
      local last = FAC._lastMarks[Z.Name]
      if last then
        local dx = (markPoint.x - last.x); local dz = (markPoint.z - last.z)
        if math.sqrt(dx*dx+dz*dz) < self.Config.MinReportSeparation then allow = false end
      end
      if allow then
        FAC._lastMarks[Z.Name] = { x = markPoint.x, z = markPoint.z }
        self:MarkTarget(Z, markPoint, rep, enemySide)
        if notifyGroup then MESSAGE:New(string.format('Marked contact in %s', Z.Name), 10):ToGroup(notifyGroup) end
      end
    end
  end
end

function FAC:MarkTarget(Z, point, rep, enemySide)
  -- Smoke
  trigger.action.smoke(point, self.Config.MarkSmokeColor)
  -- Map mark
  if self.Config.MarkText then
    local txt = string.format('FAC: %s at %s', rep.type or 'Contact', coord.LLtoString(coord.LOtoLL(point), 0))
    trigger.action.markToCoalition(math.random(100000,999999), txt, point, self.Side, true)
  end
  -- Optional arty marking
  if self.Config.Arty.Enabled then
    self:ArtyMark(point)
  end
end

function FAC:ArtyMark(point)
  local rounds = self.Config.Arty.Rounds or 1
  for _,gname in ipairs(self.Config.Arty.Groups or {}) do
    local g = Group.getByName(gname)
    if g and g:isExist() then
      local ctrl = g:getController()
      if ctrl then
        for i=1,rounds do
          local spread = self.Config.Arty.Spread or 0
          local tgt = { x = point.x + math.random(-spread, spread), y = point.z + math.random(-spread, spread) }
          local task = {
            id = 'FireAtPoint',
            params = {
              point = { x = tgt.x, y = land.getHeight({x=tgt.x, y=tgt.y}), z = tgt.y },
              expendQty = 1,
              dispersion = 50,
              attackQty = 1,
              weaponType = 0,
            }
          }
          ctrl:setTask(task)
        end
      end
    end
  end
end

-- Bootstrap a JTAC on a spawned unit/group via MOOSE FAC_AUTO
function FAC:StartJTACOnGroup(groupName, code, smoke)
  local grp = GROUP:FindByName(groupName)
  if not grp then return nil end
  local fac = FAC_AUTO:New(grp)
  fac:SetLaser(true, code or 1688)
  fac:SetSmoke(smoke or self.Config.MarkSmokeColor)
  fac:SetDetectVehicles()
  fac:Start()
  return fac
end

_MOOSE_CTLD_FAC = FAC
return FAC
