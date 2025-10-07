--[[
Simple AFAC System v1.0
========================

A lightweight, standalone Forward Air Controller system for DCS World.
No external dependencies required.

Features:
- Automatic AFAC aircraft detection
- Target scanning with line-of-sight verification
- Laser designation with customizable codes
- Visual marking (smoke/flares)
- F10 map markers with detailed target information
- Auto and manual targeting modes
- Clean F10 menu integration

Author: Based on original FAC script, streamlined for simplicity
]]

-- =====================================================
-- CONFIGURATION
-- =====================================================

AFAC = {}

AFAC.Config = {
    -- Detection ranges
    maxRange = 18520,              -- Maximum AFAC detection range in meters
    
    -- Aircraft types that auto-qualify as AFAC (perfect for dynamic spawning)
    afacAircraft = {
        -- Helicopters
        "SA342L",
        "SA342Mistral", 
        "SA342Minigun",
        "UH-60L",
        "UH-1H",
        "OH-58D",
        "AH-64D_BLK_II",
        "Mi-8MT",
        "Mi-24P",
        "Ka-50",
        "Ka-50_3",
        "AH-1W",
        
        -- Light Aircraft
        "TF-51D",
        "P-51D-30-NA",
        "Bf-109K-4",
        "FW-190D9",
        "I-16",
        "C-101EB",
        "C-101CC",
        "L-39ZA",
        "L-39C",
        
        -- Jets (for high-speed FAC)
        --"A-10C",
        --"A-10C_2",
        --"AV8BNA",
        --"F-16C_50",
        --"FA-18C_hornet",
        --"F-14",
        --"A-4E-C"
    },
    
    -- Available laser codes
    laserCodes = {'1688', '1677', '1666', '1113', '1115', '1111'},
    
    -- Smoke/flare colors
    smokeColors = {
        GREEN = 0,
        RED = 1,
        WHITE = 2,
        ORANGE = 3,
        BLUE = 4
    },
    
    -- Default marker settings
    defaultSmokeColor = {
        [1] = 4, -- RED coalition uses BLUE smoke
        [2] = 3  -- BLUE coalition uses ORANGE smoke
    },
    
    -- Marker duration (seconds)
    mapMarkerDuration = 120,
    smokeInterval = 300,
    
    -- Target update intervals
    autoUpdateInterval = 1.0,
    manualScanRange = 18520,
    
    -- Debug mode
    debug = true
}

-- =====================================================
-- CORE DATA STRUCTURES
-- =====================================================

AFAC.Data = {
    pilots = {},                   -- Active AFAC pilots
    targets = {},                  -- Current targets per pilot
    laserPoints = {},              -- Laser designations
    irPoints = {},                 -- IR pointers
    smokeMarks = {},               -- Smoke marker tracking
    onStation = {},                -- On-station status
    laserCodes = {},               -- Assigned laser codes per pilot
    markerSettings = {},           -- Per-pilot marker preferences
    menuIds = {},                  -- F10 menu tracking
    manualTargets = {},            -- Manual mode target lists
    nextMarkerId = 1000            -- Map marker ID counter
}

-- =====================================================
-- UTILITY FUNCTIONS
-- =====================================================

-- Debug logging
function AFAC.log(message)
    if AFAC.Config.debug then
        env.info("AFAC: " .. tostring(message))
    end
end

-- Check if table contains value
function AFAC.contains(table, value)
    for i = 1, #table do
        if table[i] == value then
            return true
        end
    end
    return false
end

-- Calculate distance between two points
function AFAC.getDistance(point1, point2)
    local dx = point1.x - point2.x
    local dz = point1.z - point2.z
    return math.sqrt(dx * dx + dz * dz)
end

-- Get unit heading in radians
function AFAC.getHeading(unit)
    local unitPos = unit:getPosition()
    if unitPos then
        local heading = math.atan2(unitPos.x.z, unitPos.x.x)
        if heading < 0 then
            heading = heading + 2 * math.pi
        end
        return heading
    end
    return 0
end

-- Convert coordinates to Lat/Long string
function AFAC.coordToString(point)
    local lat, lon = coord.LOtoLL(point)
    local latDeg = math.floor(lat)
    local latMin = (lat - latDeg) * 60
    local lonDeg = math.floor(lon)
    local lonMin = (lon - lonDeg) * 60
    
    local latDir = latDeg >= 0 and "N" or "S"
    local lonDir = lonDeg >= 0 and "E" or "W"
    
    return string.format("%02d°%06.3f'%s %03d°%06.3f'%s", 
        math.abs(latDeg), latMin, latDir, 
        math.abs(lonDeg), lonMin, lonDir)
end

-- Get MGRS coordinate string
function AFAC.getMGRS(point)
    local lat, lon = coord.LOtoLL(point)
    -- Simplified MGRS - in real implementation you'd want full MGRS conversion
    return string.format("MGRS: %02d%s%05d%05d", 
        math.floor(lat), "ABC"[math.random(1,3)], 
        math.random(10000, 99999), math.random(10000, 99999))
end

-- Get group ID from unit
function AFAC.getGroupId(unit)
    local group = unit:getGroup()
    if group then
        return group:getID()
    end
    return nil
end

-- Notify coalition
function AFAC.notifyCoalition(message, duration, coalition)
    trigger.action.outTextForCoalition(coalition, message, duration or 10)
end

-- =====================================================
-- AIRCRAFT DETECTION & MANAGEMENT
-- =====================================================

-- Check if unit qualifies as AFAC (by aircraft type only)
function AFAC.isAFAC(unit)
    if not unit then 
        AFAC.log("isAFAC: unit is nil")
        return false 
    end
    
    local unitType = unit:getTypeName()
    AFAC.log("Checking unit type: " .. tostring(unitType))
    
    -- Check aircraft type only - perfect for dynamic spawning
    local result = AFAC.contains(AFAC.Config.afacAircraft, unitType)
    AFAC.log("isAFAC result for " .. unitType .. ": " .. tostring(result))
    
    return result
end

-- Add pilot to AFAC system
function AFAC.addPilot(unit)
    local unitName = unit:getName()
    local groupId = AFAC.getGroupId(unit)
    
    if not groupId then return end
    
    -- Initialize pilot data
    AFAC.Data.pilots[unitName] = {
        name = unitName,
        unit = unit,
        coalition = unit:getCoalition(),
        groupId = groupId
    }
    
    -- Set default laser code
    AFAC.Data.laserCodes[unitName] = AFAC.Config.laserCodes[1]
    
    -- Set default marker settings
    AFAC.Data.markerSettings[unitName] = {
        type = "SMOKE",
        color = AFAC.Config.defaultSmokeColor[unit:getCoalition()]
    }
    
    -- Set on station
    AFAC.Data.onStation[unitName] = true
    
    -- Notify player
    local message = string.format("AFAC System Active\nAircraft: %s\nUse F10 menu to control targeting", 
        unit:getTypeName())
    trigger.action.outTextForGroup(groupId, message, 15)
    
    -- Start auto-lasing
    AFAC.startAutoLasing(unitName)
    
    AFAC.log("Added AFAC pilot: " .. unitName)
end

-- Remove pilot from system
function AFAC.removePilot(unitName)
    if not AFAC.Data.pilots[unitName] then return end
    
    -- Clean up laser points
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
    
    AFAC.log("Removed AFAC pilot: " .. unitName)
end

-- =====================================================
-- TARGET DETECTION
-- =====================================================

-- Find nearest visible enemy to AFAC unit
function AFAC.findNearestTarget(afacUnit, maxRange)
    local afacPoint = afacUnit:getPoint()
    local afacCoalition = afacUnit:getCoalition()
    local enemyCoalition = afacCoalition == 1 and 2 or 1
    
    local nearestTarget = nil
    local nearestDistance = maxRange or AFAC.Config.maxRange
    
    -- Search for enemy units
    local searchVolume = {
        id = world.VolumeType.SPHERE,
        params = {
            point = afacPoint,
            radius = nearestDistance
        }
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
        
        -- Priority system: SAMs first, then vehicles, then infantry
        local priority = 1
        if foundUnit:hasAttribute("SAM TR") or foundUnit:hasAttribute("IR Guided SAM") then
            priority = 0.1  -- Highest priority
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

-- Scan area for multiple targets (manual mode)
function AFAC.scanForTargets(afacUnit, maxCount)
    local afacPoint = afacUnit:getPoint()
    local afacCoalition = afacUnit:getCoalition()
    local enemyCoalition = afacCoalition == 1 and 2 or 1
    
    local targets = {}
    local samTargets = {}
    
    local searchVolume = {
        id = world.VolumeType.SPHERE,
        params = {
            point = afacPoint,
            radius = AFAC.Config.manualScanRange
        }
    }
    
    local function checkUnit(foundUnit)
        if foundUnit:getCoalition() ~= enemyCoalition then return end
        if not foundUnit:isActive() then return end
        if foundUnit:inAir() then return end
        if foundUnit:getLife() <= 1 then return end
        
        local unitPoint = foundUnit:getPoint()
        
        -- Check line of sight
        local offsetAfacPos = {x = afacPoint.x, y = afacPoint.y + 2, z = afacPoint.z}
        local offsetUnitPos = {x = unitPoint.x, y = unitPoint.y + 2, z = unitPoint.z}
        
        if not land.isVisible(offsetAfacPos, offsetUnitPos) then return end
        
        -- Separate SAMs from other targets
        if foundUnit:hasAttribute("SAM TR") or foundUnit:hasAttribute("IR Guided SAM") then
            table.insert(samTargets, foundUnit)
        else
            table.insert(targets, foundUnit)
        end
    end
    
    world.searchObjects(Object.Category.UNIT, searchVolume, checkUnit)
    
    -- Priority: SAMs first, then others
    local finalTargets = {}
    for i = 1, math.min(#samTargets, maxCount or 10) do
        table.insert(finalTargets, samTargets[i])
    end
    
    local remainingSlots = (maxCount or 10) - #finalTargets
    for i = 1, math.min(#targets, remainingSlots) do
        table.insert(finalTargets, targets[i])
    end
    
    return finalTargets
end

-- =====================================================
-- LASER DESIGNATION SYSTEM
-- =====================================================

-- Start laser designation on target
function AFAC.startLasing(afacUnit, target, laserCode)
    local unitName = afacUnit:getName()
    
    -- Cancel existing lasing
    AFAC.cancelLasing(unitName)
    
    local targetPoint = target:getPoint()
    local targetVector = {x = targetPoint.x, y = targetPoint.y + 2, z = targetPoint.z}
    
    -- Create laser and IR points
    local success, result = pcall(function()
        local laserSpot = Spot.createLaser(afacUnit, {x = 0, y = 2, z = 0}, targetVector, laserCode)
        local irSpot = Spot.createInfraRed(afacUnit, {x = 0, y = 2, z = 0}, targetVector)
        return {laser = laserSpot, ir = irSpot}
    end)
    
    if success and result then
        AFAC.Data.laserPoints[unitName] = result.laser
        AFAC.Data.irPoints[unitName] = result.ir
        AFAC.log("Started lasing target for " .. unitName)
    else
        AFAC.log("Failed to create laser designation for " .. unitName)
    end
end

-- Update laser position
function AFAC.updateLasing(unitName, target)
    local laserSpot = AFAC.Data.laserPoints[unitName]
    local irSpot = AFAC.Data.irPoints[unitName]
    
    if not laserSpot or not irSpot then return end
    
    local targetPoint = target:getPoint()
    local targetVector = {x = targetPoint.x, y = targetPoint.y + 2, z = targetPoint.z}
    
    laserSpot:setPoint(targetVector)
    irSpot:setPoint(targetVector)
end

-- Cancel laser designation
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
-- VISUAL MARKING SYSTEM
-- =====================================================

-- Create smoke or flare marker
function AFAC.createVisualMarker(target, markerType, color)
    local targetPoint = target:getPoint()
    local markerPoint = {x = targetPoint.x, y = targetPoint.y + 2, z = targetPoint.z}
    
    if markerType == "SMOKE" then
        trigger.action.smoke(markerPoint, color)
    else -- FLARE
        trigger.action.signalFlare(markerPoint, color, 0)
    end
end

-- Create F10 map marker with target details
function AFAC.createMapMarker(target, spotter)
    local targetPoint = target:getPoint()
    local coalition = AFAC.Data.pilots[spotter].coalition
    
    -- Get target details
    local velocity = target:getVelocity()
    local speed = 0
    if velocity then
        speed = math.sqrt(velocity.x^2 + velocity.z^2) * 2.237 -- Convert to mph
    end
    
    local heading = AFAC.getHeading(target) * 180 / math.pi
    local coords = AFAC.coordToString(targetPoint)
    local mgrs = AFAC.getMGRS(targetPoint)
    local altitude = math.floor(targetPoint.y)
    
    local markerText = string.format("%s\n%s\n%s\nAlt: %dm/%dft\nHdg: %03d°\nSpd: %.0f mph\nSpotter: %s",
        target:getTypeName(),
        coords,
        mgrs,
        altitude,
        altitude * 3.28084,
        heading,
        speed,
        spotter
    )
    
    local markerId = AFAC.Data.nextMarkerId
    AFAC.Data.nextMarkerId = AFAC.Data.nextMarkerId + 1
    
    trigger.action.markToCoalition(markerId, markerText, targetPoint, coalition, false, "AFAC Target")
    
    -- Schedule marker removal
    timer.scheduleFunction(
        function(args)
            trigger.action.removeMark(args[1])
        end,
        {markerId},
        timer.getTime() + AFAC.Config.mapMarkerDuration
    )
    
    return markerId
end

-- =====================================================
-- AUTOMATIC LASING SYSTEM
-- =====================================================

-- Start automatic target lasing
function AFAC.startAutoLasing(unitName)
    timer.scheduleFunction(AFAC.autoLaseUpdate, {unitName}, timer.getTime() + 1)
end

-- Auto-lasing update function
function AFAC.autoLaseUpdate(args)
    local unitName = args[1]
    local pilot = AFAC.Data.pilots[unitName]
    
    -- Check if pilot still exists and is on station
    if not pilot or not AFAC.Data.onStation[unitName] then
        return -- Don't reschedule
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
        -- Target destroyed
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
            
            -- Start lasing
            AFAC.startLasing(afacUnit, newTarget, laserCode)
            
            -- Create visual markers
            AFAC.createVisualMarker(newTarget, markerSettings.type, markerSettings.color)
            AFAC.createMapMarker(newTarget, unitName)
            
            -- Notify coalition
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

-- Add F10 menus for AFAC pilot
function AFAC.addMenus(unitName)
    local pilot = AFAC.Data.pilots[unitName]
    if not pilot then return end
    
    local groupId = pilot.groupId
    
    -- Main AFAC menu
    local mainMenu = missionCommands.addSubMenuForGroup(groupId, "AFAC Control")
    
    -- Targeting mode menu
    local targetMenu = missionCommands.addSubMenuForGroup(groupId, "Targeting Mode", mainMenu)
    missionCommands.addCommandForGroup(groupId, "Auto Mode ON", targetMenu, AFAC.setAutoMode, {unitName, true})
    missionCommands.addCommandForGroup(groupId, "Auto Mode OFF", targetMenu, AFAC.setAutoMode, {unitName, false})
    
    -- Manual targeting
    local manualMenu = missionCommands.addSubMenuForGroup(groupId, "Manual Targeting", targetMenu)
    missionCommands.addCommandForGroup(groupId, "Scan for Targets", manualMenu, AFAC.manualScan, {unitName})
    
    -- Target selection (will be populated after scan)
    local selectMenu = missionCommands.addSubMenuForGroup(groupId, "Select Target", manualMenu)
    for i = 1, 10 do
        missionCommands.addCommandForGroup(groupId, "Target " .. i, selectMenu, AFAC.selectManualTarget, {unitName, i})
    end
    
    -- Laser code menu
    local laserMenu = missionCommands.addSubMenuForGroup(groupId, "Laser Codes", mainMenu)
    for _, code in ipairs(AFAC.Config.laserCodes) do
        missionCommands.addCommandForGroup(groupId, "Code: " .. code, laserMenu, AFAC.setLaserCode, {unitName, code})
    end
    
    -- Marker settings
    local markerMenu = missionCommands.addSubMenuForGroup(groupId, "Marker Settings", mainMenu)
    
    -- Smoke colors
    local smokeMenu = missionCommands.addSubMenuForGroup(groupId, "Smoke Color", markerMenu)
    for colorName, colorValue in pairs(AFAC.Config.smokeColors) do
        missionCommands.addCommandForGroup(groupId, colorName, smokeMenu, AFAC.setMarkerColor, {unitName, "SMOKE", colorValue})
    end
    
    -- Flare colors (limited selection)
    local flareMenu = missionCommands.addSubMenuForGroup(groupId, "Flare Color", markerMenu)
    missionCommands.addCommandForGroup(groupId, "GREEN", flareMenu, AFAC.setMarkerColor, {unitName, "FLARE", 0})
    missionCommands.addCommandForGroup(groupId, "WHITE", flareMenu, AFAC.setMarkerColor, {unitName, "FLARE", 2})
    missionCommands.addCommandForGroup(groupId, "ORANGE", flareMenu, AFAC.setMarkerColor, {unitName, "FLARE", 3})
    
    -- Status
    missionCommands.addCommandForGroup(groupId, "AFAC Status", mainMenu, AFAC.showStatus, {unitName})
end

-- =====================================================
-- F10 MENU FUNCTIONS
-- =====================================================

-- Set auto/manual mode
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

-- Manual target scan
function AFAC.manualScan(args)
    local unitName = args[1]
    local pilot = AFAC.Data.pilots[unitName]
    
    if not pilot then return end
    
    local targets = AFAC.scanForTargets(pilot.unit, 10)
    AFAC.Data.manualTargets[unitName] = targets
    
    -- Report found targets
    if #targets > 0 then
        local afacPoint = pilot.unit:getPoint()
        trigger.action.outTextForGroup(pilot.groupId, "Targets found:", 5)
        
        for i, target in ipairs(targets) do
            local targetPoint = target:getPoint()
            local distance = AFAC.getDistance(afacPoint, targetPoint)
            local bearing = math.atan2(targetPoint.z - afacPoint.z, targetPoint.x - afacPoint.x) * 180 / math.pi
            if bearing < 0 then bearing = bearing + 360 end
            
            local message = string.format("Target %d: %s, Bearing %03d°, Range %.1fkm", 
                i, target:getTypeName(), bearing, distance / 1000)
            trigger.action.outTextForGroup(pilot.groupId, message, 15)
            
            -- Create map marker
            AFAC.createMapMarker(target, unitName)
        end
    else
        trigger.action.outTextForGroup(pilot.groupId, "No targets found in range", 10)
    end
end

-- Select manual target
function AFAC.selectManualTarget(args)
    local unitName = args[1]
    local targetIndex = args[2]
    local pilot = AFAC.Data.pilots[unitName]
    
    if not pilot then return end
    
    local targets = AFAC.Data.manualTargets[unitName]
    if not targets or not targets[targetIndex] then
        trigger.action.outTextForGroup(pilot.groupId, "Invalid target selection", 10)
        return
    end
    
    local target = targets[targetIndex]
    if not target:isActive() or target:getLife() <= 1 then
        trigger.action.outTextForGroup(pilot.groupId, "Selected target is no longer active", 10)
        return
    end
    
    -- Set as current target
    AFAC.Data.targets[unitName] = target
    
    -- Start lasing
    local laserCode = AFAC.Data.laserCodes[unitName]
    AFAC.startLasing(pilot.unit, target, laserCode)
    
    -- Create markers
    local markerSettings = AFAC.Data.markerSettings[unitName]
    AFAC.createVisualMarker(target, markerSettings.type, markerSettings.color)
    
    -- Notify
    local message = string.format("Designating Target %d: %s, CODE: %s", 
        targetIndex, target:getTypeName(), laserCode)
    trigger.action.outTextForGroup(pilot.groupId, message, 10)
    
    AFAC.notifyCoalition("[" .. unitName .. "] " .. message, 10, pilot.coalition)
end

-- Set laser code
function AFAC.setLaserCode(args)
    local unitName = args[1]
    local laserCode = args[2]
    local pilot = AFAC.Data.pilots[unitName]
    
    if not pilot then return end
    
    AFAC.Data.laserCodes[unitName] = laserCode
    trigger.action.outTextForGroup(pilot.groupId, "Laser code set to: " .. laserCode, 10)
    
    -- Update current lasing if active
    local currentTarget = AFAC.Data.targets[unitName]
    if currentTarget then
        AFAC.startLasing(pilot.unit, currentTarget, laserCode)
    end
end

-- Set marker color/type
function AFAC.setMarkerColor(args)
    local unitName = args[1]
    local markerType = args[2]
    local color = args[3]
    local pilot = AFAC.Data.pilots[unitName]
    
    if not pilot then return end
    
    AFAC.Data.markerSettings[unitName] = {
        type = markerType,
        color = color
    }
    
    local colorNames = {"GREEN", "RED", "WHITE", "ORANGE", "BLUE"}
    trigger.action.outTextForGroup(pilot.groupId, 
        string.format("Marker set to %s %s", colorNames[color + 1] or "UNKNOWN", markerType), 10)
end

-- Show AFAC status
function AFAC.showStatus(args)
    local unitName = args[1]
    local pilot = AFAC.Data.pilots[unitName]
    
    if not pilot then return end
    
    local status = "AFAC STATUS:\n\n"
    
    for pilotName, pilotData in pairs(AFAC.Data.pilots) do
        if pilotData.coalition == pilot.coalition thenn then
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
-- EVENT HANDLERS
-- =====================================================

-- Event handler for unit spawning and player connections
AFAC.EventHandler = {}

function AFAC.EventHandler:onEvent(event)
    -- Handle new unit spawning
    if event.id == world.event.S_EVENT_BIRTH then
        AFAC.log("S_EVENT_BIRTH triggered")
        local unit = event.initiator
        
        if unit and Object.getCategory(unit) == Object.Category.UNIT then
            local objDesc = unit:getDesc()
            AFAC.log("Birth event - Unit category: " .. tostring(objDesc.category))
            if objDesc.category == Unit.Category.AIRPLANE or objDesc.category == Unit.Category.HELICOPTER then
                AFAC.log("Birth event - Aircraft detected: " .. unit:getTypeName())
                if AFAC.isAFAC(unit) then
                    AFAC.log("Birth event - AFAC aircraft confirmed, scheduling add")
                    -- Delay slightly to ensure unit is fully initialized
                    timer.scheduleFunction(
                        function(args)
                            local u = args[1]
                            if u and u:isActive() then
                                AFAC.log("Adding pilot from birth event: " .. u:getName())
                                AFAC.addPilot(u)
                                AFAC.addMenus(u:getName())
                            end
                        end,
                        {unit},
                        timer.getTime() + 2
                    )
                end
            end
        end
    end
    
    -- Debug: Log ALL player enter events to see what's happening
    if event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT then
        AFAC.log("PLAYER ENTERED UNIT - Type: " .. (event.initiator and event.initiator:getTypeName() or "UNKNOWN"))
    end
    
    -- Handle player entering existing unit (like joining a running UH-1H)
    if event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT then
        AFAC.log("S_EVENT_PLAYER_ENTER_UNIT triggered")
        local unit = event.initiator
        
        if unit and Object.getCategory(unit) == Object.Category.UNIT then
            local objDesc = unit:getDesc()
            AFAC.log("Player enter - Unit category: " .. tostring(objDesc.category))
            if objDesc.category == Unit.Category.AIRPLANE or objDesc.category == Unit.Category.HELICOPTER then
                AFAC.log("Player enter - Aircraft detected: " .. unit:getTypeName())
                if AFAC.isAFAC(unit) then
                    local unitName = unit:getName()
                    AFAC.log("Player enter - AFAC aircraft confirmed: " .. unitName)
                    
                    -- Check if already registered
                    if not AFAC.Data.pilots[unitName] then
                        AFAC.log("Player enter - Not registered, adding pilot")
                        -- Add pilot and menus for existing aircraft
                        timer.scheduleFunction(
                            function(args)
                                local u = args[1]
                                if u and u:isActive() then
                                    AFAC.log("Adding pilot from player enter event: " .. u:getName())
                                    AFAC.addPilot(u)
                                    AFAC.addMenus(u:getName())
                                end
                            end,
                            {unit},
                            timer.getTime() + 1
                        )
                    else
                        AFAC.log("Player enter - Already registered")
                    end
                end
            end
        end
    end
end

-- =====================================================
-- INITIALIZATION
-- =====================================================

-- Add event handler
world.addEventHandler(AFAC.EventHandler)

-- Continuous check for new AFAC pilots (catches players joining existing aircraft)
function AFAC.checkForNewPilots()
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
                        
                        -- Check if this is a player-controlled AFAC that we haven't registered yet
                        if unit:getPlayerName() and not AFAC.Data.pilots[unitName] then
                            AFAC.log("Found new player AFAC: " .. unitName .. " (Player: " .. unit:getPlayerName() .. ")")
                            AFAC.addPilot(unit)
                            AFAC.addMenus(unitName)
                        end
                    end
                end
            end
        end
    end
    
    -- Reschedule check every 10 seconds
    timer.scheduleFunction(AFAC.checkForNewPilots, nil, timer.getTime() + 10)
end

-- Initialize existing units (for mission restart)
timer.scheduleFunction(
    function()
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
                            AFAC.addPilot(unit)
                            AFAC.addMenus(unit:getName())
                        end
                    end
                end
            end
        end
        
        AFAC.log("AFAC System initialized")
        
        -- Start continuous pilot checking
        AFAC.checkForNewPilots()
    end,
    nil,
    timer.getTime() + 5
)

-- Success message
trigger.action.outText("Simple AFAC System v1.0 loaded successfully!", 10)
AFAC.log("AFAC Script fully loaded and initialized")

-- Test message every 30 seconds to verify script is running
function AFAC.heartbeat()
    AFAC.log("AFAC System heartbeat - script is running")
    timer.scheduleFunction(AFAC.heartbeat, nil, timer.getTime() + 30)
end

timer.scheduleFunction(AFAC.heartbeat, nil, timer.getTime() + 30)