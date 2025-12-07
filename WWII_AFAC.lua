-- WWII AFAC System using Moose
-- This script provides an AFAC-like system for WWII DCS missions to help players spot air and ground targets.
-- It simulates pilot intuition and reconnaissance without modern labels.

-- Global configuration table for settings
AFAC_CONFIG = {
    airDetectionRange = 5000,  -- Meters
    groundDetectionRange = 3000,  -- Meters
    messageCooldown = 10,  -- Seconds between messages
    markerType = "smoke",  -- Options: "smoke", "flare", "none"
    markerDuration = 300,  -- Seconds for marker visibility
    threatHotRange = 1000,  -- Meters for "hot" threat
    threatColdRange = 5000,  -- Meters for "cold" threat
    scanInterval = 5,  -- Seconds between scans
    playerCoalition = coalition.side.BLUE,  -- Adjust based on mission
    enemyCoalition = coalition.side.RED,  -- Adjust based on mission
}

-- AFAC Class
AFAC = {
    ClassName = "AFAC",
    trackedAirTargets = {},  -- Table to track air targets
    trackedGroundTargets = {},  -- Table to track ground targets
    lastMessageTime = 0,
    menu = nil,
}

function AFAC:New()
    local self = BASE:Inherit(self, BASE:New())
    self.trackedAirTargets = {}
    self.trackedGroundTargets = {}
    self.lastMessageTime = timer.getTime()
    self:SetupMenu()
    self:StartScheduler()
    return self
end

function AFAC:SetupMenu()
    -- Create a mission menu for settings
    self.menu = MENU_MISSION:New("AFAC Settings")
    MENU_MISSION_COMMAND:New("Set Marker to Smoke", self.menu, self.SetMarkerType, self, "smoke")
    MENU_MISSION_COMMAND:New("Set Marker to Flare", self.menu, self.SetMarkerType, self, "flare")
    MENU_MISSION_COMMAND:New("Disable Markers", self.menu, self.SetMarkerType, self, "none")
end

function AFAC:SetMarkerType(markerType)
    AFAC_CONFIG.markerType = markerType
    MESSAGE:New("Marker type set to: " .. markerType):ToAll()
end

function AFAC:StartScheduler()
    -- Schedule periodic scans
    SCHEDULER:New(nil, self.ScanTargets, {self}, 1, AFAC_CONFIG.scanInterval)
end

function AFAC:ScanTargets()
    self:ScanAirTargets()
    self:ScanGroundTargets()
end

function AFAC:ScanAirTargets()
    local playerUnit = UNIT:FindByName("PlayerUnit")  -- Replace with actual player unit name or get dynamically
    if not playerUnit or not playerUnit:IsAlive() then return end

    local playerPos = playerUnit:GetCoordinate()
    local enemyAirUnits = SET_UNIT:New():FilterCoalitions(AFAC_CONFIG.enemyCoalition):FilterCategories("plane"):FilterActive():FilterOnce()

    enemyAirUnits:ForEachUnit(function(unit)
        local distance = playerPos:Get2DDistance(unit:GetCoordinate())
        if distance <= AFAC_CONFIG.airDetectionRange then
            local targetID = unit:GetName()
            if not self.trackedAirTargets[targetID] then
                self.trackedAirTargets[targetID] = { unit = unit, engaged = false }
            end
            if not self.trackedAirTargets[targetID].engaged then
                self:ReportAirTarget(unit, playerPos)
            end
        end
    end)
end

function AFAC:ReportAirTarget(unit, playerPos)
    local now = timer.getTime()
    if now - self.lastMessageTime < AFAC_CONFIG.messageCooldown then return end

    local bearing = playerPos:GetAngleDegrees(playerPos:GetDirectionVec3(unit:GetCoordinate()))
    local range = playerPos:Get2DDistance(unit:GetCoordinate()) / 1000  -- In km
    local alt = unit:GetAltitude() / 1000  -- In km
    local threat = "cold"
    if range * 1000 <= AFAC_CONFIG.threatHotRange then
        threat = "hot"
    end

    local message = string.format("Bandit %s at %.0f degrees, %.1f km, angels %.0f!", threat, bearing, range, alt)
    MESSAGE:New(message):ToAll()
    self.lastMessageTime = now
end

function AFAC:ScanGroundTargets()
    local playerUnit = UNIT:FindByName("PlayerUnit")  -- Replace with actual player unit name
    if not playerUnit or not playerUnit:IsAlive() then return end

    local playerPos = playerUnit:GetCoordinate()
    local enemyGroundGroups = SET_GROUP:New():FilterCoalitions(AFAC_CONFIG.enemyCoalition):FilterCategories("ground"):FilterActive():FilterOnce()

    enemyGroundGroups:ForEachGroup(function(group)
        local distance = playerPos:Get2DDistance(group:GetCoordinate())
        if distance <= AFAC_CONFIG.groundDetectionRange then
            local targetID = group:GetName()
            if not self.trackedGroundTargets[targetID] then
                self.trackedGroundTargets[targetID] = { group = group, marked = false }
                self:ReportGroundTarget(group, playerPos)
            end
        end
    end)
end

function AFAC:ReportGroundTarget(group, playerPos)
    local now = timer.getTime()
    if now - self.lastMessageTime < AFAC_CONFIG.messageCooldown then return end

    local bearing = playerPos:GetAngleDegrees(playerPos:GetDirectionVec3(group:GetCoordinate()))
    local distance = playerPos:Get2DDistance(group:GetCoordinate()) / 1000  -- In km
    local unitType = group:GetUnits()[1]:GetTypeName()  -- Rough type from first unit

    local message = string.format("Ground contact: %s at %.0f degrees, %.1f km.", unitType, bearing, distance)
    MESSAGE:New(message):ToAll()
    self.lastMessageTime = now

    -- Place marker
    if AFAC_CONFIG.markerType ~= "none" then
        local coord = group:GetCoordinate()
        if AFAC_CONFIG.markerType == "smoke" then
            coord:SmokeRed()
        elseif AFAC_CONFIG.markerType == "flare" then
            coord:FlareRed()
        end
        -- Note: Markers are temporary; Moose doesn't have built-in timed markers, so this is basic
    end
end

-- Handle engagement (simplified: if player shoots, assume engagement for nearest target)
function AFAC:OnPlayerShot(EventData)
    local playerUnit = EventData.IniUnit
    if playerUnit:GetCoalition() == AFAC_CONFIG.playerCoalition then
        -- Find nearest air target and mark as engaged
        for id, data in pairs(self.trackedAirTargets) do
            if not data.engaged then
                local distance = playerUnit:GetCoordinate():Get2DDistance(data.unit:GetCoordinate())
                if distance <= AFAC_CONFIG.airDetectionRange then
                    data.engaged = true
                    MESSAGE:New("Engaged!"):ToAll()
                    break
                end
            end
        end
    end
end

-- Initialize the AFAC system
local afacSystem = AFAC:New()

-- Event handler for shots
EVENT:New():HandleEvent(EVENTS.Shot):OnEvent(function(EventData) afacSystem:OnPlayerShot(EventData) end)