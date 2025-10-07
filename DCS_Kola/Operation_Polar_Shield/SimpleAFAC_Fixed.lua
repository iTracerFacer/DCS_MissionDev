--[[
Simple AFAC System v1.0
========================

A lightweight, standalone Forward Air Controller system for DCS World.
No external dependencies required.
]]

-- Initialize with success message
trigger.action.outText("Simple AFAC System v1.0 loading...", 10)

-- =====================================================
-- CONFIGURATION & INITIALIZATION
-- =====================================================

AFAC = {}

AFAC.Config = {
    maxRange = 18520,
    laserCodes = {'1688', '1677', '1666', '1113', '1115', '1111'},
    smokeColors = {GREEN = 0, RED = 1, WHITE = 2, ORANGE = 3, BLUE = 4},
    defaultSmokeColor = {[1] = 4, [2] = 3}, -- RED uses BLUE, BLUE uses ORANGE
    mapMarkerDuration = 120,
    smokeInterval = 300,
    autoUpdateInterval = 1.0,
    debug = true,
    
    afacAircraft = {
        "UH-1H", "UH-60L", "SA342L", "SA342Mistral", "SA342Minigun", "OH-58D", "Mi-8MT", "CH-47F",
        "P-51D", "A-4E-C", "L-39C", "C-101CC"
    }
}

AFAC.Data = {
    pilots = {},
    targets = {},
    laserPoints = {},
    irPoints = {},
    smokeMarks = {},
    onStation = {},
    laserCodes = {},
    markerSettings = {},
    manualTargets = {},
    menuIds = {},
    nextMarkerId = 1000
}

-- =====================================================
-- UTILITY FUNCTIONS
-- =====================================================

function AFAC.log(message)
    if AFAC.Config.debug then
        env.info("AFAC: " .. tostring(message))
    end
end

function AFAC.contains(table, value)
    for i = 1, #table do
        if table[i] == value then return true end
    end
    return false
end

function AFAC.getDistance(point1, point2)
    local dx = point1.x - point2.x
    local dz = point1.z - point2.z
    return math.sqrt(dx * dx + dz * dz)
end

function AFAC.getGroupId(unit)
    local group = unit:getGroup()
    if group then return group:getID() end
    return nil
end

function AFAC.notifyCoalition(message, duration, coalition)
    trigger.action.outTextForCoalition(coalition, message, duration or 10)
end

-- =====================================================
-- AIRCRAFT DETECTION
-- =====================================================

function AFAC.isAFAC(unit)
    if not unit then return false end
    local unitType = unit:getTypeName()
    AFAC.log("Checking aircraft type: " .. unitType)
    local result = AFAC.contains(AFAC.Config.afacAircraft, unitType)
    AFAC.log("isAFAC result for " .. unitType .. ": " .. tostring(result))
    return result
end

function AFAC.addPilot(unit)
    local unitName = unit:getName()
    local groupId = AFAC.getGroupId(unit)
    
    if not groupId then return end
    
    -- Check if pilot is already registered
    if AFAC.Data.pilots[unitName] then
        AFAC.log("Pilot " .. unitName .. " already registered, skipping")
        return
    end
    
    AFAC.log("Adding AFAC pilot: " .. unitName)
    
    -- Initialize pilot data
    AFAC.Data.pilots[unitName] = {
        name = unitName,
        unit = unit,
        coalition = unit:getCoalition(),
        groupId = groupId
    }
    
    -- Set defaults
    AFAC.Data.laserCodes[unitName] = AFAC.Config.laserCodes[1]
    AFAC.Data.markerSettings[unitName] = {
        type = "SMOKE",
        color = AFAC.Config.defaultSmokeColor[unit:getCoalition()]
    }
    AFAC.Data.onStation[unitName] = true
    
    -- Notify player
    local message = string.format("AFAC System Active\nAircraft: %s\nUse F10 menu to control targeting", unit:getTypeName())
    trigger.action.outTextForGroup(groupId, message, 15)
    
    -- Add F10 menu with slight delay to ensure everything is initialized
    timer.scheduleFunction(function(args)
        AFAC.addMenus(args[1])
    end, {unitName}, timer.getTime() + 0.5)
    
    -- Start auto-lasing
    AFAC.startAutoLasing(unitName)
end

function AFAC.removePilot(unitName)
    if not AFAC.Data.pilots[unitName] then return end
    
    AFAC.cancelLasing(unitName)
    
    -- Clean up data
    AFAC.Data.pilots[unitName] = nil
    AFAC.Data.targets[unitName] = nil
    AFAC.Data.laserPoints[unitName] = nil
    AFAC.Data.irPoints[unitName] = nil
    AFAC.Data.smokeMarks[unitName] = nil
    AFAC.Data.onStation[unitName] = nil
    AFAC.Data.laserCodes[unitName] = nil
    AFAC.Data.markerSettings[unitName] = nil
    AFAC.Data.manualTargets[unitName] = nil
    AFAC.Data.menuIds[unitName] = nil
    
    AFAC.log("Removed AFAC pilot: " .. unitName)
end

-- =====================================================
-- TARGET DETECTION
-- =====================================================

function AFAC.findNearestTarget(afacUnit)
    local afacPoint = afacUnit:getPoint()
    local afacCoalition = afacUnit:getCoalition()
    local enemyCoalition = afacCoalition == 1 and 2 or 1
    
    local nearestTarget = nil
    local nearestDistance = AFAC.Config.maxRange
    
    local searchVolume = {
        id = world.VolumeType.SPHERE,
        params = {point = afacPoint, radius = nearestDistance}
    }
    
    local function checkUnit(foundUnit)
        if foundUnit:getCoalition() ~= enemyCoalition then return end
        if not foundUnit:isActive() then return end
        if foundUnit:inAir() then return end
        if foundUnit:getLife() <= 1 then return end
        
        local unitPoint = foundUnit:getPoint()
        local distance = AFAC.getDistance(afacPoint, unitPoint)
        
        if distance >= nearestDistance then return end
        
        -- Check line of sight
        local offsetAfacPos = {x = afacPoint.x, y = afacPoint.y + 2, z = afacPoint.z}
        local offsetUnitPos = {x = unitPoint.x, y = unitPoint.y + 2, z = unitPoint.z}
        
        if not land.isVisible(offsetAfacPos, offsetUnitPos) then return end
        
        -- Priority system
        local priority = 1
        if foundUnit:hasAttribute("SAM TR") or foundUnit:hasAttribute("IR Guided SAM") then
            priority = 0.1
        elseif foundUnit:hasAttribute("Vehicles") then
            priority = 0.5
        end
        
        local adjustedDistance = distance * priority
        
        if adjustedDistance < nearestDistance then
            nearestDistance = adjustedDistance
            nearestTarget = foundUnit
        end
    end
    
    world.searchObjects(Object.Category.UNIT, searchVolume, checkUnit)
    return nearestTarget
end

-- =====================================================
-- LASER DESIGNATION
-- =====================================================

function AFAC.startLasing(afacUnit, target, laserCode)
    local unitName = afacUnit:getName()
    AFAC.cancelLasing(unitName)
    
    local targetPoint = target:getPoint()
    local targetVector = {x = targetPoint.x, y = targetPoint.y + 2, z = targetPoint.z}
    
    local success, result = pcall(function()
        local laserSpot = Spot.createLaser(afacUnit, {x = 0, y = 2, z = 0}, targetVector, laserCode)
        local irSpot = Spot.createInfraRed(afacUnit, {x = 0, y = 2, z = 0}, targetVector)
        return {laser = laserSpot, ir = irSpot}
    end)
    
    if success and result then
        AFAC.Data.laserPoints[unitName] = result.laser
        AFAC.Data.irPoints[unitName] = result.ir
        AFAC.log("Started lasing target for " .. unitName)
    end
end

function AFAC.updateLasing(unitName, target)
    local laserSpot = AFAC.Data.laserPoints[unitName]
    local irSpot = AFAC.Data.irPoints[unitName]
    
    if not laserSpot or not irSpot then return end
    
    local targetPoint = target:getPoint()
    local targetVector = {x = targetPoint.x, y = targetPoint.y + 2, z = targetPoint.z}
    
    laserSpot:setPoint(targetVector)
    irSpot:setPoint(targetVector)
end

function AFAC.cancelLasing(unitName)
    local laserSpot = AFAC.Data.laserPoints[unitName]
    local irSpot = AFAC.Data.irPoints[unitName]
    
    if laserSpot then
        Spot.destroy(laserSpot)
        AFAC.Data.laserPoints[unitName] = nil
    end
    
    if irSpot then
        Spot.destroy(irSpot)
        AFAC.Data.irPoints[unitName] = nil
    end
end

-- =====================================================
-- VISUAL MARKING
-- =====================================================

function AFAC.createVisualMarker(target, markerType, color)
    local targetPoint = target:getPoint()
    local markerPoint = {x = targetPoint.x, y = targetPoint.y + 2, z = targetPoint.z}
    
    if markerType == "SMOKE" then
        trigger.action.smoke(markerPoint, color)
    else
        trigger.action.signalFlare(markerPoint, color, 0)
    end
end

function AFAC.createMapMarker(target, spotter)
    local targetPoint = target:getPoint()
    local coalition = AFAC.Data.pilots[spotter].coalition
    
    local markerText = string.format("%s\nSpotter: %s", target:getTypeName(), spotter)
    
    local markerId = AFAC.Data.nextMarkerId
    AFAC.Data.nextMarkerId = AFAC.Data.nextMarkerId + 1
    
    trigger.action.markToCoalition(markerId, markerText, targetPoint, coalition, false, "AFAC Target")
    
    timer.scheduleFunction(function(args)
        trigger.action.removeMark(args[1])
    end, {markerId}, timer.getTime() + AFAC.Config.mapMarkerDuration)
    
    return markerId
end

-- =====================================================
-- AUTO-LASING SYSTEM
-- =====================================================

function AFAC.startAutoLasing(unitName)
    timer.scheduleFunction(AFAC.autoLaseUpdate, {unitName}, timer.getTime() + 1)
end

function AFAC.autoLaseUpdate(args)
    local unitName = args[1]
    local pilot = AFAC.Data.pilots[unitName]
    
    if not pilot or not AFAC.Data.onStation[unitName] then
        return
    end
    
    local afacUnit = pilot.unit
    if not afacUnit or not afacUnit:isActive() or afacUnit:getLife() <= 0 then
        AFAC.removePilot(unitName)
        return
    end
    
    local currentTarget = AFAC.Data.targets[unitName]
    local laserCode = AFAC.Data.laserCodes[unitName]
    local markerSettings = AFAC.Data.markerSettings[unitName]
    
    -- Check if current target is still valid
    if currentTarget and (not currentTarget:isActive() or currentTarget:getLife() <= 1) then
        local message = string.format("[%s] Target %s destroyed. Good job! Scanning for new targets.", 
            unitName, currentTarget:getTypeName())
        AFAC.notifyCoalition(message, 10, pilot.coalition)
        
        AFAC.Data.targets[unitName] = nil
        AFAC.cancelLasing(unitName)
        currentTarget = nil
    end
    
    -- Find new target if needed
    if not currentTarget then
        local newTarget = AFAC.findNearestTarget(afacUnit)
        if newTarget then
            AFAC.Data.targets[unitName] = newTarget
            
            AFAC.startLasing(afacUnit, newTarget, laserCode)
            AFAC.createVisualMarker(newTarget, markerSettings.type, markerSettings.color)
            AFAC.createMapMarker(newTarget, unitName)
            
            local message = string.format("[%s] Lasing new target: %s, CODE: %s", 
                unitName, newTarget:getTypeName(), laserCode)
            AFAC.notifyCoalition(message, 10, pilot.coalition)
            
            currentTarget = newTarget
        end
    end
    
    -- Update laser position if we have a target
    if currentTarget then
        AFAC.updateLasing(unitName, currentTarget)
        
        -- Update smoke markers periodically
        local nextSmokeTime = AFAC.Data.smokeMarks[unitName]
        if not nextSmokeTime or nextSmokeTime < timer.getTime() then
            AFAC.createVisualMarker(currentTarget, markerSettings.type, markerSettings.color)
            AFAC.Data.smokeMarks[unitName] = timer.getTime() + AFAC.Config.smokeInterval
        end
    end
    
    -- Schedule next update
    timer.scheduleFunction(AFAC.autoLaseUpdate, args, timer.getTime() + AFAC.Config.autoUpdateInterval)
end

-- =====================================================
-- F10 MENU SYSTEM
-- =====================================================

function AFAC.addMenus(unitName)
    local pilot = AFAC.Data.pilots[unitName]
    if not pilot then 
        AFAC.log("addMenus: No pilot data found for " .. unitName)
        return 
    end
    
    local groupId = pilot.groupId
    if not groupId then
        AFAC.log("addMenus: No group ID found for " .. unitName)
        return
    end
    
    -- Check if menus already exist for this pilot
    if AFAC.Data.menuIds[unitName] then
        AFAC.log("Menus already exist for " .. unitName .. ", skipping creation")
        return
    end
    
    AFAC.log("Creating menus for " .. unitName .. " (Group ID: " .. groupId .. ")")
    
    local mainMenu = missionCommands.addSubMenuForGroup(groupId, "AFAC Control")
    AFAC.Data.menuIds[unitName] = mainMenu
    AFAC.log("Main menu created")
    
    -- Wrap menu creation in pcall to catch any errors
    local success, error = pcall(function()
        -- Targeting mode
        local targetMenu = missionCommands.addSubMenuForGroup(groupId, "Targeting Mode", mainMenu)
        missionCommands.addCommandForGroup(groupId, "Auto Mode ON", targetMenu, AFAC.setAutoMode, {unitName, true})
        missionCommands.addCommandForGroup(groupId, "Auto Mode OFF", targetMenu, AFAC.setAutoMode, {unitName, false})
        AFAC.log("Targeting mode menu created")
        
        -- Laser codes
        local laserMenu = missionCommands.addSubMenuForGroup(groupId, "Laser Codes", mainMenu)
        for _, code in ipairs(AFAC.Config.laserCodes) do
            missionCommands.addCommandForGroup(groupId, "Code: " .. code, laserMenu, AFAC.setLaserCode, {unitName, code})
        end
        AFAC.log("Laser codes menu created with " .. #AFAC.Config.laserCodes .. " codes")
        
        -- Marker settings
        local markerMenu = missionCommands.addSubMenuForGroup(groupId, "Marker Settings", mainMenu)
        local smokeMenu = missionCommands.addSubMenuForGroup(groupId, "Smoke Color", markerMenu)
        
        -- Add smoke colors
        missionCommands.addCommandForGroup(groupId, "GREEN", smokeMenu, AFAC.setMarkerColor, {unitName, "SMOKE", 0})
        missionCommands.addCommandForGroup(groupId, "RED", smokeMenu, AFAC.setMarkerColor, {unitName, "SMOKE", 1})
        missionCommands.addCommandForGroup(groupId, "WHITE", smokeMenu, AFAC.setMarkerColor, {unitName, "SMOKE", 2})
        missionCommands.addCommandForGroup(groupId, "ORANGE", smokeMenu, AFAC.setMarkerColor, {unitName, "SMOKE", 3})
        missionCommands.addCommandForGroup(groupId, "BLUE", smokeMenu, AFAC.setMarkerColor, {unitName, "SMOKE", 4})
        AFAC.log("Marker settings menu created")
        
        -- Status
        missionCommands.addCommandForGroup(groupId, "AFAC Status", mainMenu, AFAC.showStatus, {unitName})
        AFAC.log("All menus created successfully for " .. unitName)
    end)
    
    if not success then
        AFAC.log("Error creating menus for " .. unitName .. ": " .. tostring(error))
    end
end

-- =====================================================
-- F10 MENU FUNCTIONS
-- =====================================================

function AFAC.setAutoMode(args)
    local unitName = args[1]
    local autoMode = args[2]
    local pilot = AFAC.Data.pilots[unitName]
    
    if not pilot then return end
    
    AFAC.Data.onStation[unitName] = autoMode
    
    if autoMode then
        trigger.action.outTextForGroup(pilot.groupId, "Auto targeting mode enabled", 10)
        AFAC.startAutoLasing(unitName)
    else
        trigger.action.outTextForGroup(pilot.groupId, "Auto targeting mode disabled", 10)
        AFAC.cancelLasing(unitName)
        AFAC.Data.targets[unitName] = nil
    end
end

function AFAC.setLaserCode(args)
    local unitName = args[1]
    local laserCode = args[2]
    local pilot = AFAC.Data.pilots[unitName]
    
    if not pilot then return end
    
    AFAC.Data.laserCodes[unitName] = laserCode
    trigger.action.outTextForGroup(pilot.groupId, "Laser code set to: " .. laserCode, 10)
    
    local currentTarget = AFAC.Data.targets[unitName]
    if currentTarget then
        AFAC.startLasing(pilot.unit, currentTarget, laserCode)
    end
end

function AFAC.setMarkerColor(args)
    local unitName = args[1]
    local markerType = args[2]
    local color = args[3]
    local pilot = AFAC.Data.pilots[unitName]
    
    if not pilot then return end
    
    AFAC.Data.markerSettings[unitName] = {type = markerType, color = color}
    
    local colorNames = {"GREEN", "RED", "WHITE", "ORANGE", "BLUE"}
    trigger.action.outTextForGroup(pilot.groupId, 
        string.format("Marker set to %s %s", colorNames[color + 1] or "UNKNOWN", markerType), 10)
end

function AFAC.showStatus(args)
    local unitName = args[1]
    local pilot = AFAC.Data.pilots[unitName]
    
    if not pilot then return end
    
    local status = "AFAC STATUS:\n\n"
    
    for pilotName, pilotData in pairs(AFAC.Data.pilots) do
        if pilotData.coalition == pilot.coalition then
            local target = AFAC.Data.targets[pilotName]
            local laserCode = AFAC.Data.laserCodes[pilotName]
            local onStation = AFAC.Data.onStation[pilotName]
            
            if target and target:isActive() then
                status = status .. string.format("%s: Targeting %s, CODE: %s\n", 
                    pilotName, target:getTypeName(), laserCode)
            elseif onStation then
                status = status .. string.format("%s: On station, searching for targets\n", pilotName)
            else
                status = status .. string.format("%s: Off station\n", pilotName)
            end
        end
    end
    
    trigger.action.outTextForGroup(pilot.groupId, status, 30)
end

-- =====================================================
-- EVENT HANDLER
-- =====================================================

AFAC.EventHandler = {}

function AFAC.EventHandler:onEvent(event)
    if event.id == world.event.S_EVENT_BIRTH then
        local unit = event.initiator
        
        if unit and Object.getCategory(unit) == Object.Category.UNIT then
            local objDesc = unit:getDesc()
            if objDesc.category == Unit.Category.AIRPLANE or objDesc.category == Unit.Category.HELICOPTER then
                if AFAC.isAFAC(unit) then
                    timer.scheduleFunction(function(args)
                        local u = args[1]
                        if u and u:isActive() then
                            AFAC.addPilot(u)
                        end
                    end, {unit}, timer.getTime() + 2)
                end
            end
        end
    end
    
    if event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT then
        local unit = event.initiator
        
        if unit and Object.getCategory(unit) == Object.Category.UNIT then
            local objDesc = unit:getDesc()
            if objDesc.category == Unit.Category.AIRPLANE or objDesc.category == Unit.Category.HELICOPTER then
                if AFAC.isAFAC(unit) then
                    local unitName = unit:getName()
                    
                    if not AFAC.Data.pilots[unitName] then
                        timer.scheduleFunction(function(args)
                            local u = args[1]
                            if u and u:isActive() then
                                AFAC.addPilot(u)
                            end
                        end, {unit}, timer.getTime() + 1)
                    end
                end
            end
        end
    end
end

-- =====================================================
-- INITIALIZATION
-- =====================================================

world.addEventHandler(AFAC.EventHandler)

-- Check for existing pilots
function AFAC.checkForExistingPilots()
    for coalitionId = 1, 2 do
        local airGroups = coalition.getGroups(coalitionId, Group.Category.AIRPLANE)
        local heliGroups = coalition.getGroups(coalitionId, Group.Category.HELICOPTER)
        
        local allGroups = {}
        for _, group in ipairs(airGroups) do table.insert(allGroups, group) end
        for _, group in ipairs(heliGroups) do table.insert(allGroups, group) end
        
        for _, group in ipairs(allGroups) do
            local units = group:getUnits()
            if units then
                for _, unit in ipairs(units) do
                    if unit and unit:isActive() and AFAC.isAFAC(unit) then
                        local unitName = unit:getName()
                        if unit:getPlayerName() and not AFAC.Data.pilots[unitName] then
                            AFAC.addPilot(unit)
                        end
                    end
                end
            end
        end
    end
end

timer.scheduleFunction(AFAC.checkForExistingPilots, nil, timer.getTime() + 3)

-- Periodic check for new pilots
function AFAC.periodicCheck()
    AFAC.checkForExistingPilots()
    timer.scheduleFunction(AFAC.periodicCheck, nil, timer.getTime() + 10)
end

timer.scheduleFunction(AFAC.periodicCheck, nil, timer.getTime() + 15)

AFAC.log("AFAC System initialized successfully")
trigger.action.outText("Simple AFAC System v1.0 loaded successfully!", 10)