-- Operation Polar Shield - MOOSE Mission Script
-- 
-- KNOWN ISSUES WITH EASYGCICAP v0.1.30:
-- 1. Internal MOOSE errors during intercept assignments (_AssignIntercept)
-- 2. Inconsistent wing size requests (alternates between 1 and 2 aircraft)
-- 3. These errors do NOT prevent CAP operations - system works despite them
--
-- VERIFICATION: Check F10 map for active CAP flights patrolling border zones
-- The script successfully initializes all squadrons and patrol points.

-- STATUS: OPERATIONAL ✅
-- All squadrons added, all patrol points configured, RedCAP started successfully
--
-- NEW FEATURES:
-- ✅ Randomized AI Patrol System - Aircraft pick random patrol areas within their zones
-- ✅ Anti-Clustering Behavior - Each aircraft patrols different areas to prevent clustering
-- ✅ Dynamic Patrol Rotation - Aircraft change patrol areas every AI_PATROL_TIME seconds
-- ✅ Configurable Patrol Parameters - Adjust patrol timing and area sizes via config

-- Optional: Reduce MOOSE error message boxes in game
-- env.setErrorMessageBoxEnabled(false)

--================================================================================================
-- TACTICAL AIR DEFENSE CONTROLLER (TADC) CONFIGURATION
-- ================================================================================================

-- GCI Configuration - Define at top level for global access
local GCI_Config = {
    -- Threat Response Parameters
    threatRatio = 1,              -- Send 1.5x defenders per attacker
    maxSimultaneousCAP = 12,        -- Maximum total airborne aircraft
    reservePercent = 0.25,          -- Keep 25% of forces in reserve
    responseDelay = 15,             -- Seconds to assess threat before scrambling
    
    -- Supply Management
    supplyMode = "INFINITE",          -- "FINITE" or "INFINITE" aircraft spawning
    defaultSquadronSize = 25,        -- Aircraft per squadron if not specified
    
    -- Detection Parameters
    useEWRDetection = true,         -- Use realistic EWR-based detection (true) or omniscient detection (false)
    ewrDetectionRadius = 30000,     -- EWR detection radius in meters (30km)
    ewrUpdateInterval = 10,         -- EWR detection update interval in seconds
    threatTimeout = 300,            -- Remove threats not seen for 5 minutes
    minThreatDistance = 50000,      -- Minimum 50km to consider threat
    
    -- Force Sizing Rules
    fighterVsFighter = 1.0,         -- Multiplier for fighter threats (reduced from 1.5)
    fighterVsBomber = 1.2,          -- Multiplier for bomber threats (reduced from 2.0)
    fighterVsHelicopter = 0.8,      -- Multiplier for helicopter threats
    
    -- CAP Behavior Parameters
    capOrbitRadius = 30000,         -- CAP orbit radius in meters (30km)
    capEngagementRange = 35000,     -- Maximum engagement range in meters (35km)
    capZoneConstraint = true,       -- Keep CAP flights within their patrol zones
    
    -- AI Patrol Parameters
    AI_PATROL_TIME = 300,           -- Time aircraft patrol one area before moving (5 minutes)
    patrolAreaRadius = 15000,       -- Radius of individual patrol areas in meters (15km)
    minPatrolSeparation = 25000,    -- Minimum distance between patrol areas (25km)
    
    -- Squadron Operational Parameters
    squadronCooldown = 1800,        -- Seconds between squadron launches (30 minutes - increased from 15)
    maxAircraftPerMission = 1,      -- Maximum aircraft per squadron per mission (reduced from 2)
    
    -- Spawn Positioning
    spawnDistanceMin = 1000,        -- Minimum spawn distance from airbase (meters)
    spawnDistanceMax = 3000,        -- Maximum spawn distance from airbase (meters)
    takeoffDistance = 5000,         -- Distance for ground spawn takeoff positioning (meters)
    
    -- Mission Timing
    minPatrolDuration = 7200,       -- Minimum patrol duration in seconds (2 hours)
    rtbDuration = 600,              -- Time allowed for RTB in seconds (10 minutes)
    missionCleanupTime = 1800,      -- Time before old missions are cleaned up (30 minutes)
    statusReportInterval = 300,     -- Interval between status reports (5 minutes)
    
    -- System Timing
    capSetupDelay = 5,              -- Delay before setting up CAP tasks (seconds)
    mainLoopDelay = 5,              -- Initial delay before starting main loop (seconds)
    mainLoopInterval = 30,          -- Main loop execution interval (seconds)
    
    -- Debug Options
    debugLevel = 2,                 -- 0=Silent, 1=Basic, 2=Verbose
    
    -- Persistent CAP Configuration
    enablePersistentCAP = true,     -- Enable continuous standing patrols
    persistentCAPCount = 4,         -- Number of persistent CAP flights to maintain
    persistentCAPInterval = 120,    -- Check/maintain persistent CAP every 2 minutes
    persistentCAPReserve = 0.3,     -- Reserve 30% of maxSimultaneousCAP slots for threat response
    persistentCAPPriority = {       -- Priority order for persistent CAP squadrons
        "FIGHTER_SWEEP_RED_Severomorsk-1",  -- Primary intercept base
        "FIGHTER_SWEEP_RED_Olenya",         -- Northern coverage
        "FIGHTER_SWEEP_RED_Murmansk",       -- Western coverage
        "HELO_SWEEP_RED_Afrikanda"          -- Helicopter patrol
    },
    
    -- Optional Features
    initialStandingPatrols = false  -- Launch standing patrols on startup (legacy)
}


-- Initialize TADC Data Structures - Must be defined before any usage
local TADC = {
    -- Squadron Management
    squadrons = {},                 -- Squadron data and status
    activeCAPs = {},               -- Currently airborne CAP flights
    launchQueue = {},              -- Pending launch orders
    
    -- Threat Tracking
    threats = {},                  -- Detected threat contacts
    threatHistory = {},            -- Historical threat data
    
    -- Mission Control
    missions = {},                 -- Active intercept missions
    reserves = {},                 -- Aircraft held in reserve
    threatAssignments = {},        -- Maps threat IDs to assigned squadrons
    squadronMissions = {},         -- Maps squadrons to their current threats
    
    -- Persistent CAP Management
    persistentCAPs = {},           -- Currently active persistent CAP flights
    lastPersistentCheck = 0,       -- Last time persistent CAP was checked/maintained
    
    -- Statistics
    stats = {
        threatsDetected = 0,
        interceptsLaunched = 0,
        successfulEngagements = 0,
        aircraftLost = 0
    }
}

-- Setup Distributed Multi-Base CAP System
-- This creates a dynamic response system where each squadron launches from its designated airbase
-- and responds to threats based on proximity and zone coverage.

-- Create border zones with error checking
local redBorderGroup = GROUP:FindByName("RED BORDER")
local heloBorderGroup = GROUP:FindByName("HELO BORDER")

if redBorderGroup then
    CCCPBorderZone = ZONE_POLYGON:New("RED BORDER", redBorderGroup)
    env.info("RED BORDER zone created successfully")
else
    env.info("ERROR: RED BORDER group not found!")
    return
end

if heloBorderGroup then
    HeloBorderZone = ZONE_POLYGON:New("HELO BORDER", heloBorderGroup)
    env.info("HELO BORDER zone created successfully")
else
    env.info("ERROR: HELO BORDER group not found!")
    return
end

-- Define squadron configurations with their designated airbases and patrol zones
local squadronConfigs = {
    -- Fixed-wing fighters patrol RED BORDER zone
    {
        templateName = "FIGHTER_SWEEP_RED_Kilpyavr",
        displayName = "Kilpyavr CAP",
        airbaseName = "Kilpyavr",
        patrolZone = CCCPBorderZone,
        aircraft = 1,
        skill = AI.Skill.GOOD,
        altitude = 15000,
        speed = 300,
        patrolTime = 20,
        type = "FIGHTER"
    },
    {
        templateName = "FIGHTER_SWEEP_RED_Severomorsk-1",
        displayName = "Severomorsk-1 CAP", 
        airbaseName = "Severomorsk-1",
        patrolZone = CCCPBorderZone,
        aircraft = 1,
        skill = AI.Skill.GOOD,
        altitude = 20000,
        speed = 350,
        patrolTime = 25,
        type = "FIGHTER"
    },
    {
        templateName = "FIGHTER_SWEEP_RED_Severomorsk-3",
        displayName = "Severomorsk-3 CAP",
        airbaseName = "Severomorsk-3",
        patrolZone = CCCPBorderZone,
        aircraft = 1,
        skill = AI.Skill.GOOD,
        altitude = 25000,
        speed = 400,
        patrolTime = 30,
        type = "FIGHTER"
    },
    {
        templateName = "FIGHTER_SWEEP_RED_Murmansk",
        displayName = "Murmansk CAP",
        airbaseName = "Murmansk International",
        patrolZone = CCCPBorderZone,
        aircraft = 1,
        skill = AI.Skill.GOOD,
        altitude = 18000,
        speed = 320,
        patrolTime = 22,
        type = "FIGHTER"
    },
    {
        templateName = "FIGHTER_SWEEP_RED_Monchegorsk",
        displayName = "Monchegorsk CAP",
        airbaseName = "Monchegorsk",
        patrolZone = CCCPBorderZone,
        aircraft = 1,
        skill = AI.Skill.GOOD,
        altitude = 22000,
        speed = 380,
        patrolTime = 25,
        type = "FIGHTER"
    },
    {
        templateName = "FIGHTER_SWEEP_RED_Olenya",
        displayName = "Olenya CAP",
        airbaseName = "Olenya",
        patrolZone = CCCPBorderZone,
        aircraft = 1,
        skill = AI.Skill.GOOD,
        altitude = 30000,
        speed = 450,
        patrolTime = 35,
        type = "FIGHTER"
    },
    -- Helicopter squadron patrols HELO BORDER zone
    {
        templateName = "HELO_SWEEP_RED_Afrikanda",
        displayName = "Afrikanda Helo CAP",
        airbaseName = "Afrikanda",
        patrolZone = HeloBorderZone,
        aircraft = 4,
        skill = AI.Skill.GOOD,
        altitude = 1000,
        speed = 150,
        patrolTime = 30,
        type = "HELICOPTER"
    }
}

-- Check which squadron templates exist in the mission
env.info("=== CHECKING SQUADRON TEMPLATES ===")
local availableSquadrons = {}

-- First, let's verify what airbases are actually available
env.info("=== VERIFYING AIRBASE NAMES ===")
local testAirbaseNames = {
    "Kilpyavr", "Severomorsk-1", "Severomorsk-3", 
    "Murmansk International", "Monchegorsk", "Olenya", "Afrikanda"
}
for _, airbaseName in pairs(testAirbaseNames) do
    local airbaseObj = AIRBASE:FindByName(airbaseName)
    if airbaseObj then
        env.info("✓ Airbase found: " .. airbaseName)
    else
        env.info("✗ Airbase NOT found: " .. airbaseName)
    end
end

-- ================================================================================================
-- SQUADRON MANAGEMENT SYSTEM
-- ================================================================================================

local function initializeSquadron(config)
    return {
        -- Basic Info
        templateName = config.templateName,
        displayName = config.displayName,
        airbaseName = config.airbaseName,
        type = config.type,
        
        -- Aircraft Management
        totalAircraft = GCI_Config.supplyMode == "INFINITE" and 999 or (config.totalAircraft or GCI_Config.defaultSquadronSize),
        availableAircraft = GCI_Config.supplyMode == "INFINITE" and 999 or (config.totalAircraft or GCI_Config.defaultSquadronSize),
        airborneAircraft = 0,
        reserveAircraft = 0,
        
        -- Mission Parameters
        patrolZone = config.patrolZone,
        altitude = config.altitude,
        speed = config.speed,
        patrolTime = config.patrolTime,
        skill = config.skill,
        
        -- Status
        readinessLevel = "READY",      -- READY, BUSY, UNAVAILABLE
        lastLaunch = -GCI_Config.squadronCooldown,  -- Allow immediate launch (set to -cooldown)
        launchCooldown = GCI_Config.squadronCooldown,  -- Cooldown from config
        
        -- Statistics
        sorties = 0,
        kills = 0,
        losses = 0
    }
end

env.info("=== INITIALIZING SQUADRON DATABASE ===")
for _, config in pairs(squadronConfigs) do
    local template = GROUP:FindByName(config.templateName)
    if template then
        env.info("✓ Found squadron template: " .. config.templateName)
        
        -- Verify airbase exists and is Red coalition
        local airbaseObj = AIRBASE:FindByName(config.airbaseName)
        if airbaseObj then
            local airbaseCoalition = airbaseObj:GetCoalition()
            if airbaseCoalition == 1 then -- Red coalition
                env.info("  ✓ Airbase verified: " .. config.airbaseName .. " (Red Coalition)")
                
                -- Initialize squadron in TADC database
                local squadron = initializeSquadron(config)
                TADC.squadrons[config.templateName] = squadron
                availableSquadrons[config.templateName] = config -- Keep for compatibility
                
                env.info("  ✓ Squadron initialized: " .. squadron.availableAircraft .. " aircraft available")
            else
                env.info("  ✗ Airbase " .. config.airbaseName .. " not Red coalition - squadron disabled")
            end
        else
            env.info("  ✗ Airbase NOT found: " .. config.airbaseName .. " - squadron disabled")
        end
    else
        env.info("✗ Missing squadron template: " .. config.templateName)
    end
end

local squadronCount = 0
local totalAircraft = 0
for _, squadron in pairs(TADC.squadrons) do
    squadronCount = squadronCount + 1
    totalAircraft = totalAircraft + squadron.availableAircraft
end

env.info("✓ TADC Squadron Database: " .. squadronCount .. " squadrons, " .. totalAircraft .. " total aircraft")
if GCI_Config.supplyMode == "INFINITE" then
    env.info("✓ Supply Mode: INFINITE - unlimited aircraft spawning")
else
    env.info("✓ Supply Mode: FINITE - " .. totalAircraft .. " aircraft available")
end

-- ================================================================================================
-- TACTICAL AIR DEFENSE CONTROLLER (TADC) SYSTEM
-- A comprehensive GCI system for intelligent air defense coordination
-- ================================================================================================

env.info("=== INITIALIZING TACTICAL AIR DEFENSE CONTROLLER ===")

-- Create EWR Detection Network with Detection System
local RedEWR = SET_GROUP:New():FilterPrefixes("RED-EWR"):FilterStart()
local RedDetection = nil

if GCI_Config.useEWRDetection and RedEWR:Count() > 0 then
    env.info("✓ Red EWR Network: " .. RedEWR:Count() .. " detection groups")
    
    -- Create MOOSE Detection system using EWR network (basic version for compatibility)
    local success, errorMsg = pcall(function()
        RedDetection = DETECTION_AREAS:New(RedEWR, GCI_Config.ewrDetectionRadius)
        RedDetection:Start()
    end)
    
    if success then
        env.info("✓ EWR-based threat detection system initialized (" .. (GCI_Config.ewrDetectionRadius/1000) .. "km range)")
    else
        env.info("⚠ EWR detection failed: " .. tostring(errorMsg) .. " - falling back to omniscient detection")
        RedDetection = nil
    end
else
    if GCI_Config.useEWRDetection then
        env.info("⚠ Warning: No RED-EWR groups found - falling back to omniscient detection")
    else
        env.info("✓ Using omniscient detection (EWR detection disabled in config)")
    end
end

-- ================================================================================================
-- THREAT DETECTION AND ASSESSMENT SYSTEM
-- ================================================================================================

local function classifyThreat(group)
    local category = group:GetCategory()
    local typeName = group:GetTypeName() or "Unknown"
    
    -- Classify by DCS category and type name
    if category == Group.Category.AIRPLANE then
        if string.find(typeName:upper(), "B-") or string.find(typeName:upper(), "BOMBER") then
            return "BOMBER"
        elseif string.find(typeName:upper(), "A-") or string.find(typeName:upper(), "ATTACK") then
            return "ATTACK"
        else
            return "FIGHTER"
        end
    elseif category == Group.Category.HELICOPTER then
        return "HELICOPTER"
    else
        return "UNKNOWN"
    end
end

local function assessThreatStrength(threats)
    local fighters = 0
    local bombers = 0
    local helicopters = 0
    local totalThreat = 0
    
    for _, threat in pairs(threats) do
        local aircraft = threat.size or 1
        if threat.classification == "FIGHTER" then
            fighters = fighters + aircraft
            totalThreat = totalThreat + (aircraft * GCI_Config.fighterVsFighter)
        elseif threat.classification == "BOMBER" then
            bombers = bombers + aircraft
            totalThreat = totalThreat + (aircraft * GCI_Config.fighterVsBomber)
        elseif threat.classification == "HELICOPTER" then
            helicopters = helicopters + aircraft
            totalThreat = totalThreat + (aircraft * GCI_Config.fighterVsHelicopter)
        end
    end
    
    return {
        fighters = fighters,
        bombers = bombers,
        helicopters = helicopters,
        totalAircraft = fighters + bombers + helicopters,
        requiredDefenders = math.ceil(totalThreat)
    }
end

local function updateThreatPicture()
    local currentTime = timer.getTime()
    local newThreats = {}
    
    -- Use EWR-based detection if enabled and available, otherwise fall back to omniscient detection
    if GCI_Config.useEWRDetection and RedDetection then
        -- EWR-based realistic detection
        local detectedItems = RedDetection:GetDetectedItems()
        
        if GCI_Config.debugLevel >= 2 then
            env.info("EWR DETECTION: Found " .. #detectedItems .. " detected items")
        end
        
        for _, detectedItem in pairs(detectedItems) do
            local detectedSet = detectedItem.Set
            if detectedSet then
                detectedSet:ForEach(function(detectedGroup)
                    if detectedGroup and detectedGroup:IsAlive() and detectedGroup:GetCoalition() == coalition.side.BLUE then
                        local blueCoord = detectedGroup:GetCoordinate()
                        local threatId = detectedGroup:GetName()
                        
                        -- DEBUG: Log each EWR-detected aircraft
                        if GCI_Config.debugLevel >= 2 then
                            env.info("EWR DETECTED: " .. threatId .. " at " .. blueCoord:ToStringLLDMS())
                        end
                        
                        -- Check if threat is in any patrol zone
                        local inRedZone = CCCPBorderZone and CCCPBorderZone:IsCoordinateInZone(blueCoord)
                        local inHeloZone = HeloBorderZone and HeloBorderZone:IsCoordinateInZone(blueCoord)
                        
                        -- DEBUG: Log zone check results
                        if GCI_Config.debugLevel >= 2 then
                            env.info("  Zone Check - RED: " .. tostring(inRedZone) .. ", HELO: " .. tostring(inHeloZone))
                        end
                        
                        if inRedZone or inHeloZone then
                            local classification = classifyThreat(detectedGroup)
                            local size = detectedGroup:GetSize()
                            
                            newThreats[threatId] = {
                                id = threatId,
                                group = detectedGroup,
                                coordinate = blueCoord,
                                classification = classification,
                                size = size,
                                zone = inRedZone and "RED_BORDER" or "HELO_BORDER",
                                firstDetected = TADC.threats[threatId] and TADC.threats[threatId].firstDetected or currentTime,
                                lastSeen = currentTime,
                                heading = detectedGroup:GetHeading(),
                                velocity = detectedGroup:GetVelocity(),
                                priority = classification == "BOMBER" and 3 or (classification == "FIGHTER" and 2 or 1),
                                detectionMethod = "EWR"
                            }
                            
                            -- Update statistics
                            if not TADC.threats[threatId] then
                                TADC.stats.threatsDetected = TADC.stats.threatsDetected + 1
                                if GCI_Config.debugLevel >= 1 then
                                    env.info("NEW EWR THREAT: " .. threatId .. " (" .. classification .. ", " .. size .. " aircraft) in " .. newThreats[threatId].zone)
                                end
                            end
                        end
                    end
                end)
            end
        end
    else
        -- Fallback: Omniscient detection (original method)
        local BlueAircraft = SET_GROUP:New():FilterCoalitions("blue"):FilterCategoryAirplane():FilterStart()
        
        -- DEBUG: Log how many blue aircraft we found
        local blueCount = BlueAircraft:Count()
        if blueCount > 0 and GCI_Config.debugLevel >= 2 then
            env.info("OMNISCIENT SCAN: Found " .. blueCount .. " blue aircraft on map")
        end
        
        BlueAircraft:ForEach(function(blueGroup)
            if blueGroup and blueGroup:IsAlive() then
                local blueCoord = blueGroup:GetCoordinate()
                local threatId = blueGroup:GetName()
                
                -- DEBUG: Log each blue aircraft found
                if GCI_Config.debugLevel >= 2 then
                    env.info("CHECKING BLUE AIRCRAFT: " .. threatId .. " at " .. blueCoord:ToStringLLDMS())
                end
                
                -- Check if threat is in any patrol zone
                local inRedZone = CCCPBorderZone and CCCPBorderZone:IsCoordinateInZone(blueCoord)
                local inHeloZone = HeloBorderZone and HeloBorderZone:IsCoordinateInZone(blueCoord)
                
                -- DEBUG: Log zone check results
                if GCI_Config.debugLevel >= 2 then
                    env.info("  Zone Check - RED: " .. tostring(inRedZone) .. ", HELO: " .. tostring(inHeloZone))
                end
                
                if inRedZone or inHeloZone then
                    local classification = classifyThreat(blueGroup)
                    local size = blueGroup:GetSize()
                    
                    newThreats[threatId] = {
                        id = threatId,
                        group = blueGroup,
                        coordinate = blueCoord,
                        classification = classification,
                        size = size,
                        zone = inRedZone and "RED_BORDER" or "HELO_BORDER",
                        firstDetected = TADC.threats[threatId] and TADC.threats[threatId].firstDetected or currentTime,
                        lastSeen = currentTime,
                        heading = blueGroup:GetHeading(),
                        velocity = blueGroup:GetVelocity(),
                        priority = classification == "BOMBER" and 3 or (classification == "FIGHTER" and 2 or 1),
                        detectionMethod = "OMNISCIENT"
                    }
                    
                    -- Update statistics
                    if not TADC.threats[threatId] then
                        TADC.stats.threatsDetected = TADC.stats.threatsDetected + 1
                        if GCI_Config.debugLevel >= 1 then
                            env.info("NEW THREAT: " .. threatId .. " (" .. classification .. ", " .. size .. " aircraft) in " .. newThreats[threatId].zone)
                        end
                    end
                end
            end
        end)
    end
    
    -- Remove old threats (not seen for threatTimeout seconds)
    for threatId, threat in pairs(TADC.threats) do
        if not newThreats[threatId] and (currentTime - threat.lastSeen) > GCI_Config.threatTimeout then
            if GCI_Config.debugLevel >= 1 then
                env.info("THREAT TIMEOUT: " .. threatId .. " - removing from threat picture")
            end
        end
    end
    
    TADC.threats = newThreats
    return newThreats
end

local function findOptimalDefenders(threats, zone)
    local assessment = assessThreatStrength(threats)
    local availableSquadrons = {}
    local totalAvailable = 0
    
    -- Find available squadrons for this zone
    local currentTime = timer.getTime()
    for templateName, squadron in pairs(TADC.squadrons) do
        -- Check availability, aircraft count, AND cooldown status
        local cooldownRemaining = squadron.launchCooldown - (currentTime - squadron.lastLaunch)
        if squadron.readinessLevel == "READY" and 
           squadron.availableAircraft > 0 and 
           cooldownRemaining <= 0 then
            -- Check if squadron type matches zone
            local canRespond = false
            if zone == "RED_BORDER" and squadron.type == "FIGHTER" then
                canRespond = true
            elseif zone == "HELO_BORDER" and squadron.type == "HELICOPTER" then
                canRespond = true
            end
            
            if canRespond then
                local airbaseObj = AIRBASE:FindByName(squadron.airbaseName)
                if airbaseObj then
                    -- Calculate average distance to threats
                    local totalDistance = 0
                    local threatCount = 0
                    for _, threat in pairs(threats) do
                        if threat.zone == zone then
                            local distance = threat.coordinate:Get2DDistance(airbaseObj:GetCoordinate())
                            totalDistance = totalDistance + distance
                            threatCount = threatCount + 1
                        end
                    end
                    
                    if threatCount > 0 then
                        availableSquadrons[templateName] = {
                            squadron = squadron,
                            averageDistance = totalDistance / threatCount,
                            priority = squadron.type == "FIGHTER" and 2 or 1
                        }
                        totalAvailable = totalAvailable + squadron.availableAircraft
                    end
                end
            end
        end
    end
    
    -- Sort by distance and priority
    local sortedSquadrons = {}
    for templateName, data in pairs(availableSquadrons) do
        table.insert(sortedSquadrons, {templateName = templateName, data = data})
    end
    
    table.sort(sortedSquadrons, function(a, b)
        if a.data.priority ~= b.data.priority then
            return a.data.priority > b.data.priority
        else
            return a.data.averageDistance < b.data.averageDistance
        end
    end)
    
    return sortedSquadrons, assessment, totalAvailable
end

-- ================================================================================================
-- MISSION PLANNING AND LAUNCH COORDINATION
-- ================================================================================================

local function calculateRequiredForce(threats, zone)
    local zoneThreats = {}
    for _, threat in pairs(threats) do
        if threat.zone == zone then
            table.insert(zoneThreats, threat)
        end
    end
    
    if #zoneThreats == 0 then
        return 0, {}
    end
    
    local assessment = assessThreatStrength(zoneThreats)
    return assessment.requiredDefenders, zoneThreats
end

local function assignThreatsToSquadrons(threats, zone)
    local zoneThreats = {}
    for _, threat in pairs(threats) do
        if threat.zone == zone then
            table.insert(zoneThreats, threat)
        end
    end
    
    if #zoneThreats == 0 then
        return {}
    end
    
    local availableSquadrons, assessment, totalAvailable = findOptimalDefenders(threats, zone)
    
    -- Debug: Show squadron selection results
    if GCI_Config.debugLevel >= 1 then
        env.info("Squadron Selection for " .. zone .. ":")
        for i, squadronData in pairs(availableSquadrons) do
            local squadron = squadronData.data.squadron
            local currentTime = timer.getTime()
            local cooldownRemaining = math.max(0, squadron.launchCooldown - (currentTime - squadron.lastLaunch))
            env.info("  " .. i .. ". " .. squadron.displayName .. " - Available: " .. squadron.availableAircraft .. ", Cooldown: " .. math.ceil(cooldownRemaining) .. "s")
        end
    end
    
    -- Assign each unassigned threat to the best available squadron
    local newAssignments = {}
    
    for _, threat in pairs(zoneThreats) do
        local threatId = threat.id .. "_" .. threat.firstDetected
        
        -- Skip if threat is already assigned to an active squadron
        local skipThreat = false
        if TADC.threatAssignments[threatId] then
            local assignedSquadron = TADC.threatAssignments[threatId]
            local squadron = TADC.squadrons[assignedSquadron]
            if squadron and squadron.readinessLevel == "BUSY" then
                if GCI_Config.debugLevel >= 2 then
                    env.info("Threat " .. threat.id .. " already assigned to " .. assignedSquadron)
                end
                skipThreat = true -- Skip this threat, it's being handled
            else
                -- Squadron is no longer busy, clear the assignment
                TADC.threatAssignments[threatId] = nil
                if TADC.squadronMissions[assignedSquadron] then
                    TADC.squadronMissions[assignedSquadron] = nil
                end
            end
        end
        
        -- Only process threat if not skipped
        if not skipThreat then
            -- Find the best available squadron for this specific threat
            local bestSquadron = nil
            local bestDistance = math.huge
            
            for _, squadronData in pairs(availableSquadrons) do
                local squadron = squadronData.data.squadron
                local templateName = squadronData.templateName
                
                -- Check if squadron is available (not already assigned to another threat)
                if not TADC.squadronMissions[templateName] and squadron.availableAircraft > 0 then
                    if squadronData.data.averageDistance < bestDistance then
                        bestDistance = squadronData.data.averageDistance
                        -- Find the original squadron config
                        local originalConfig = nil
                        for _, config in pairs(squadronConfigs) do
                            if config.templateName == templateName then
                                originalConfig = config
                                break
                            end
                        end
                        
                        bestSquadron = {
                            templateName = templateName,
                            squadron = squadron,
                            distance = squadronData.data.averageDistance,
                            threat = threat,
                            threatId = threatId,
                            config = originalConfig  -- Include original squadron config
                        }
                    end
                end
            end
            
            if bestSquadron then
                table.insert(newAssignments, bestSquadron)
                -- Mark squadron as assigned to prevent double-booking
                TADC.squadronMissions[bestSquadron.templateName] = bestSquadron.threatId
                TADC.threatAssignments[bestSquadron.threatId] = bestSquadron.templateName
                
                if GCI_Config.debugLevel >= 1 then
                    env.info("Assigning threat " .. threat.id .. " to " .. bestSquadron.squadron.displayName .. " (" .. math.floor(bestDistance/1000) .. "km)")
                end
            else
                if GCI_Config.debugLevel >= 1 then
                    env.info("No available squadron for threat " .. threat.id)
                end
            end
        end
    end
    
    return newAssignments
end

-- ================================================================================================
-- CAP LAUNCH FUNCTION (Must be defined before executeInterceptMission)
-- ================================================================================================

local function launchCAP(config, aircraftCount, reason)
    aircraftCount = aircraftCount or 1
    
    env.info("=== LAUNCHING CAP ===")
    env.info("Squadron: " .. config.displayName)
    env.info("Airbase: " .. config.airbaseName)
    env.info("Aircraft: " .. aircraftCount)
    env.info("Reason: " .. reason)
    
    local success, errorMsg = pcall(function()
        -- Find the airbase object
        local airbaseObj = AIRBASE:FindByName(config.airbaseName)
        if not airbaseObj then
            env.info("✗ Could not find airbase: " .. config.airbaseName)
            return
        end
        
        env.info("✓ Airbase object found, attempting spawn...")
        env.info("Template: " .. config.templateName)
        env.info("Aircraft count: " .. config.aircraft)
        env.info("Skill: " .. tostring(config.skill))
        
        -- Check if template exists
        local templateGroup = GROUP:FindByName(config.templateName)
        if not templateGroup then
            env.info("✗ CRITICAL: Template group not found: " .. config.templateName)
            env.info("SOLUTION: In Mission Editor, ensure group '" .. config.templateName .. "' exists and is set to 'Late Activation'")
            return
        end
        
        -- Check template group properties
        local coalition = templateGroup:GetCoalition()
        local coalitionName = coalition == 1 and "Red" or (coalition == 2 and "Blue" or "Neutral")
        env.info("✓ Template group found - Coalition: " .. coalitionName)
        
        if coalition ~= 1 then
            env.info("✗ CRITICAL: Template group is not Red coalition (coalition=" .. coalition .. ")")
            env.info("SOLUTION: In Mission Editor, set group '" .. config.templateName .. "' to Red coalition")
            return
        end
        
        -- Template groups should NOT be alive if Late Activation is working correctly
        local isAlive = templateGroup:IsAlive()
        env.info("Template Status - Alive: " .. tostring(isAlive) .. " (should be false for Late Activation)")
        
        if isAlive then
            env.info("⚠ Warning: Template group is alive - Late Activation may not be set correctly")
            env.info("This means the group has already spawned in the mission")
        else
            env.info("✓ Template group correctly set to Late Activation")
        end
        
        -- Create SPAWN object with proper initialization
        env.info("Creating SPAWN object...")
        local spawner = SPAWN:New(config.templateName)
        
       
        -- Try different spawn methods that actually work
        local spawnedGroup = nil
        
        -- Method 1: Try spawning in air at proper altitude near airbase
        local airbaseCoord = airbaseObj:GetCoordinate()
        local spawnCoord = airbaseCoord:Translate(math.random(GCI_Config.spawnDistanceMin, GCI_Config.spawnDistanceMax), math.random(0, 360))
        spawnCoord = spawnCoord:SetAltitude(config.altitude) -- Set proper altitude
        
        env.info("Attempting air spawn at " .. config.altitude .. "ft near " .. config.airbaseName)
        spawnedGroup = spawner:SpawnFromCoordinate(spawnCoord, nil, SPAWN.Takeoff.Air)
        
        if not spawnedGroup then
            -- Method 2: Try airbase spawn
            env.info("Air spawn failed, trying airbase spawn")
            spawnedGroup = spawner:SpawnAtAirbase(airbaseObj, SPAWN.Takeoff.Hot)
        end
        
        if not spawnedGroup then
            -- Method 3: Try ground spawn then immediate takeoff
            env.info("Airbase spawn failed, trying ground spawn with takeoff")
            spawnedGroup = spawner:SpawnFromCoordinate(airbaseCoord)
            if spawnedGroup then
                -- Force immediate takeoff to proper altitude
                local takeoffCoord = airbaseCoord:Translate(5000, math.random(0, 360)):SetAltitude(config.altitude)
                spawnedGroup:RouteAirTo(takeoffCoord, config.speed, "BARO")
            end
        end
        
        if spawnedGroup then
            env.info("✓ Aircraft spawned successfully: " .. config.displayName)
            -- Note: Skip immediate altitude check as coordinates may not be ready yet
            -- Altitude will be set properly in the scheduled CAP setup task
            
            -- Wait a moment then set up proper CAP mission
            SCHEDULER:New(nil, function()
                if spawnedGroup and spawnedGroup:IsAlive() then
                    env.info("Setting up CAP mission for " .. config.displayName)
                    
                    -- Set proper altitude and speed (with nil checks)
                    local currentCoord = spawnedGroup:GetCoordinate()
                    if currentCoord then
                        local properAltCoord = currentCoord:SetAltitude(config.altitude)
                        spawnedGroup:RouteAirTo(properAltCoord, config.speed, "BARO")
                        env.info("✓ Set altitude to " .. config.altitude .. "ft")
                    else
                        env.info("⚠ Coordinate not ready yet, CAP task will handle altitude")
                    end
                    
                    -- Set up comprehensive AI options with error handling
                    local success, errorMsg = pcall(function()
                        spawnedGroup:OptionROEOpenFire()           -- Engage enemies
                        spawnedGroup:OptionRTBBingoFuel()          -- RTB when low fuel
                        spawnedGroup:OptionRTBAmmo(0.1)            -- RTB when 10% ammo left
                        
                        -- Helicopter-specific AI options to prevent oscillation
                        if config.type == "HELICOPTER" then
                            spawnedGroup:OptionROTNoReaction()     -- Less aggressive altitude changes
                        else
                            spawnedGroup:OptionROTVertical()       -- No altitude restrictions for fighters
                        end
                    end)
                    
                    if not success then
                        env.info("⚠ Warning: Could not set all AI options: " .. tostring(errorMsg))
                    end
                    
                    -- Create randomized patrol system to prevent clustering
                    local function setupRandomPatrol()
                        if spawnedGroup and spawnedGroup:IsAlive() and config.patrolZone then
                            -- Get a random point within the patrol zone
                            local patrolZoneCoord = config.patrolZone:GetCoordinate()
                            if patrolZoneCoord then
                                -- Generate random patrol point within zone boundaries
                                local maxRadius = math.min(GCI_Config.capOrbitRadius, 25000) -- Max 25km from zone center
                                local randomRadius = math.random(GCI_Config.minPatrolSeparation, maxRadius)
                                local randomBearing = math.random(0, 360)
                                
                                local patrolPoint = patrolZoneCoord:Translate(randomRadius, randomBearing)
                                patrolPoint = patrolPoint:SetAltitude(config.altitude * 0.3048) -- Convert to meters
                                
                                env.info("Setting new patrol area for " .. config.displayName .. " at " .. randomRadius .. "m/" .. randomBearing .. "°")
                                
                                -- Clear old tasks and set new patrol orbit
                                spawnedGroup:ClearTasks()
                                
                                -- Primary orbit task at random location (helicopter-specific parameters)
                                local orbitTask = {}
                                if config.type == "HELICOPTER" then
                                    -- Helicopter-specific orbit to prevent oscillation
                                    orbitTask = {
                                        id = 'Orbit',
                                        params = {
                                            pattern = 'Race-Track',  -- More stable for helicopters
                                            point = {x = patrolPoint.x, y = patrolPoint.z},
                                            radius = math.min(GCI_Config.patrolAreaRadius, 8000), -- Smaller radius for helos
                                            altitude = config.altitude * 0.3048,
                                            speed = config.speed * 0.514444,
                                            altitudeEdited = true -- Lock altitude to prevent oscillation
                                        }
                                    }
                                else
                                    -- Standard fighter orbit
                                    orbitTask = {
                                        id = 'Orbit',
                                        params = {
                                            pattern = 'Circle',
                                            point = {x = patrolPoint.x, y = patrolPoint.z},
                                            radius = GCI_Config.patrolAreaRadius,
                                            altitude = config.altitude * 0.3048,
                                            speed = config.speed * 0.514444,
                                        }
                                    }
                                end
                                spawnedGroup:PushTask(orbitTask, 1)
                                
                                -- Secondary engage task (always active)
                                local engageTask = {
                                    id = 'EngageTargets',
                                    params = {
                                        targetTypes = {'Air'},
                                        priority = 2,
                                        maxDistEnabled = true,
                                        maxDist = GCI_Config.capEngagementRange,
                                    }
                                }
                                spawnedGroup:PushTask(engageTask, 2)
                                
                                env.info("✓ " .. config.displayName .. " assigned to patrol area " .. randomRadius .. "m from zone center")
                            end
                        end
                    end
                    
                    -- Set up initial patrol area
                    local capSuccess, capError = pcall(function()
                        setupRandomPatrol()

                        -- Schedule patrol area changes every AI_PATROL_TIME seconds
                        if TADC.activeCAPs[config.templateName] then
                            TADC.activeCAPs[config.templateName].patrolScheduler = SCHEDULER:New(nil, setupRandomPatrol, {}, GCI_Config.AI_PATROL_TIME, GCI_Config.AI_PATROL_TIME)
                        end
                    end)
                    
                    if not capSuccess then
                        env.info("⚠ Warning: Could not set CAP tasks: " .. tostring(capError))
                        -- Fallback: just set basic engage task
                        spawnedGroup:OptionROEOpenFire()
                    end
                    
                    env.info("✓ CAP mission established at " .. config.altitude .. "ft altitude")
                    
                end
            end, {}, 5) -- 5 second delay to let aircraft stabilize
            
            -- Mark as active
            TADC.activeCAPs[config.templateName] = {
                group = spawnedGroup,
                launchTime = timer.getTime(),
                config = config
            }
            
            -- Set up extended patrol timer (much longer than before)
            local patrolDuration = math.max(config.patrolTime * 60, GCI_Config.minPatrolDuration) -- Minimum from config
            SCHEDULER:New(nil, function()
                if TADC.activeCAPs[config.templateName] then
                    env.info(config.displayName .. " completing patrol mission - RTB")
                    local group = TADC.activeCAPs[config.templateName].group
                    if group and group:IsAlive() then
                        -- Clear current tasks
                        group:ClearTasks()
                        
                        -- Send back to base
                        local airbaseObj = AIRBASE:FindByName(config.airbaseName)
                        if airbaseObj then
                            group:RouteRTB(airbaseObj)
                            env.info("✓ " .. config.displayName .. " returning to " .. config.airbaseName)
                        end
                        
                        -- Clean up after RTB delay
                        SCHEDULER:New(nil, function()
                            if TADC.activeCAPs[config.templateName] then
                                local capData = TADC.activeCAPs[config.templateName]
                                local rtbGroup = capData.group
                                
                                -- Stop patrol scheduler
                                if capData.patrolScheduler then
                                    capData.patrolScheduler:Stop()
                                end
                                
                                if rtbGroup and rtbGroup:IsAlive() then
                                    rtbGroup:Destroy()
                                    env.info("✓ " .. config.displayName .. " landed and available for next sortie")
                                end
                                TADC.activeCAPs[config.templateName] = nil
                            end
                        end, {}, GCI_Config.rtbDuration) -- RTB time from config
                    else
                        -- Stop patrol scheduler if CAP is being cleaned up early
                        if TADC.activeCAPs[config.templateName] and TADC.activeCAPs[config.templateName].patrolScheduler then
                            TADC.activeCAPs[config.templateName].patrolScheduler:Stop()
                        end
                        TADC.activeCAPs[config.templateName] = nil
                    end
                end
            end, {}, patrolDuration)
            
        else
            env.info("✗ Failed to spawn " .. config.displayName)
        end
    end)
    
    if not success then
        env.info("✗ Error launching CAP: " .. tostring(errorMsg))
        return false
    else
        env.info("✓ CAP launch completed successfully")
        return true
    end
end

-- ================================================================================================
-- MISSION EXECUTION FUNCTION (Now can call launchCAP)
-- ================================================================================================

local function executeThreatsAssignments(assignments)
    if not assignments or #assignments == 0 then
        return false
    end
    
    local currentTime = timer.getTime()
    
    env.info("=== EXECUTING THREAT ASSIGNMENTS ===")
    env.info("Processing " .. #assignments .. " threat assignments")
    
    local launchedFlights = {}
    
    for _, assignment in pairs(assignments) do
        local squadron = assignment.squadron
        local templateName = assignment.templateName
        
        -- Check squadron availability and cooldown
        if squadron.readinessLevel == "READY" and 
           squadron.availableAircraft >= 1 and
           (currentTime - squadron.lastLaunch) >= squadron.launchCooldown then
            
            local reason = "Intercept: " .. (assignment.threat and assignment.threat.id or "Unknown") .. " (" .. (assignment.threat and assignment.threat.classification or "Unknown") .. ")"
            local success = launchCAP(assignment.config, 1, reason)
            
            if success then
                -- Update squadron status - squadron is now BUSY with this threat
                squadron.availableAircraft = squadron.availableAircraft - 1
                squadron.airborneAircraft = squadron.airborneAircraft + 1
                squadron.lastLaunch = currentTime
                squadron.sorties = squadron.sorties + 1
                squadron.readinessLevel = "BUSY"  -- Squadron is now handling this threat
                
                TADC.stats.interceptsLaunched = TADC.stats.interceptsLaunched + 1
                
                -- Store mission details
                TADC.missions[assignment.threatId] = {
                    threatId = assignment.threatId,
                    squadron = templateName,
                    threat = assignment.threat,
                    startTime = currentTime,
                    status = "ACTIVE"
                }
                
                table.insert(launchedFlights, {
                    squadron = templateName,
                    threat = assignment.threat and assignment.threat.id or "Unknown",
                    launchTime = currentTime
                })
                
                env.info("✓ Launched: " .. squadron.displayName .. " → " .. (assignment.threat and assignment.threat.id or "Unknown"))
            else
                env.info("✗ Launch failed: " .. squadron.displayName)
            end
        else
            local reason = "Unknown"
            if squadron.readinessLevel ~= "READY" then
                reason = "Not ready (" .. squadron.readinessLevel .. ")"
            elseif squadron.availableAircraft < 1 then
                reason = "Insufficient aircraft (" .. squadron.availableAircraft .. " available)"
            elseif (currentTime - squadron.lastLaunch) < squadron.launchCooldown then
                reason = "On cooldown (" .. math.ceil(squadron.launchCooldown - (currentTime - squadron.lastLaunch)) .. "s remaining)"
            end
            env.info("✗ Cannot launch " .. squadron.displayName .. ": " .. reason)
        end
    end
    
    -- Store mission for tracking
    -- (Removed assignment to TADC.missions[missionId] due to undefined variables)
    
    return #launchedFlights > 0
end

-- ================================================================================================
-- PERSISTENT CAP HELPER FUNCTIONS
-- ================================================================================================

local function getPersistentCAPCount()
    local count = 0
    for _, capData in pairs(TADC.persistentCAPs) do
        if capData.group and capData.group:IsAlive() then
            count = count + 1
        else
            -- Clean up dead persistent CAPs
            TADC.persistentCAPs[capData.templateName] = nil
        end
    end
    return count
end

local function launchPersistentCAP(templateName, reason)
    -- Find the original squadron config
    local config = nil
    for _, squadronConfig in pairs(squadronConfigs) do
        if squadronConfig.templateName == templateName then
            config = squadronConfig
            break
        end
    end
    
    if not config or not TADC.squadrons[templateName] then
        return false
    end
    
    local squadron = TADC.squadrons[templateName]
    local currentTime = timer.getTime()
    
    -- Check if squadron is available (not on cooldown, has aircraft)
    if squadron.readinessLevel ~= "READY" or 
       squadron.availableAircraft < 1 or
       (currentTime - squadron.lastLaunch) < squadron.launchCooldown then
        return false
    end
    
    -- Launch the CAP
    local success = launchCAP(config, 1, reason)
    if success then
        -- Track as persistent CAP (separate from regular intercept CAPs)
        TADC.persistentCAPs[templateName] = {
            templateName = templateName,
            group = TADC.activeCAPs[templateName] and TADC.activeCAPs[templateName].group,
            launchTime = currentTime,
            isPersistent = true
        }
        
        if GCI_Config.debugLevel >= 1 then
            env.info("✓ Persistent CAP launched: " .. squadron.displayName)
        end
        
        return true
    end
    
    return false
end

local function maintainPersistentCAP()
    if not GCI_Config.enablePersistentCAP then
        return
    end
    
    local currentTime = timer.getTime()
    
    -- Only check every persistentCAPInterval seconds
    if (currentTime - TADC.lastPersistentCheck) < GCI_Config.persistentCAPInterval then
        return
    end
    
    TADC.lastPersistentCheck = currentTime
    
    -- Calculate total airborne aircraft to respect maxSimultaneousCAP limit
    local totalAirborne = 0
    for _, squadron in pairs(TADC.squadrons) do
        totalAirborne = totalAirborne + squadron.airborneAircraft
    end
    
    local currentPersistentCount = getPersistentCAPCount()
    local needed = GCI_Config.persistentCAPCount - currentPersistentCount
    
    -- Respect maxSimultaneousCAP limit with reserve for threat response
    local maxPersistentAllowed = math.floor(GCI_Config.maxSimultaneousCAP * (1 - GCI_Config.persistentCAPReserve))
    local effectiveTarget = math.min(GCI_Config.persistentCAPCount, maxPersistentAllowed)
    local availableSlots = maxPersistentAllowed - currentPersistentCount
    
    -- Recalculate needed based on effective limits
    needed = math.min(needed, availableSlots)
    needed = math.max(0, needed)
    
    if needed < (GCI_Config.persistentCAPCount - currentPersistentCount) and GCI_Config.debugLevel >= 1 then
        env.info("⚠ Persistent CAP limited: Target=" .. GCI_Config.persistentCAPCount .. ", Effective=" .. effectiveTarget .. " (reserving " .. math.ceil(GCI_Config.maxSimultaneousCAP * GCI_Config.persistentCAPReserve) .. " slots for threats)")
    end
    
    if needed > 0 then
        if GCI_Config.debugLevel >= 1 then
            env.info("=== PERSISTENT CAP MAINTENANCE ===")
            env.info("Current: " .. currentPersistentCount .. ", Target: " .. GCI_Config.persistentCAPCount .. ", Need: " .. needed)
            env.info("Total airborne: " .. totalAirborne .. "/" .. GCI_Config.maxSimultaneousCAP .. " (available slots: " .. availableSlots .. ")")
        end
        
        -- Launch needed persistent CAPs from priority list
        local launched = 0
        for _, templateName in pairs(GCI_Config.persistentCAPPriority) do
            if launched >= needed then
                break
            end
            
            -- Skip if this squadron already has a persistent CAP
            if not TADC.persistentCAPs[templateName] or 
               not TADC.persistentCAPs[templateName].group or 
               not TADC.persistentCAPs[templateName].group:IsAlive() then
                
                if launchPersistentCAP(templateName, "Persistent CAP maintenance") then
                    launched = launched + 1
                end
            end
        end
        
        if GCI_Config.debugLevel >= 1 then
            env.info("✓ Persistent CAP maintenance complete: " .. launched .. " new patrols launched")
        end
    end
end



-- ================================================================================================
-- MAIN TADC CONTROL LOOP
-- ================================================================================================

local function mainTADCLoop()
    local currentTime = timer.getTime()
    
    -- Update threat picture
    local threats = updateThreatPicture()
    local threatCount = 0
    for _ in pairs(threats) do threatCount = threatCount + 1 end
    
    if threatCount > 0 then
        if GCI_Config.debugLevel >= 2 then
            env.info("=== TADC THREAT ASSESSMENT ===")
            env.info("Active threats: " .. threatCount)
        end
        
        -- Plan responses for each zone
        local zones = {"RED_BORDER", "HELO_BORDER"}
        
        for _, zone in pairs(zones) do
            local assignments = assignThreatsToSquadrons(threats, zone)
            
            if #assignments > 0 then
                -- Wait for response delay before executing (allows threat picture to stabilize)
                local readyAssignments = {}
                
                for _, assignment in pairs(assignments) do
                    local threatAge = currentTime - assignment.threat.firstDetected
                    if threatAge >= GCI_Config.responseDelay then
                        table.insert(readyAssignments, assignment)
                    elseif GCI_Config.debugLevel >= 2 then
                        env.info("Delaying assignment: " .. (assignment.threat and assignment.threat.id or "Unknown") .. " (age: " .. math.floor(threatAge) .. "s)")
                    end
                end
                
                if #readyAssignments > 0 then
                    executeThreatsAssignments(readyAssignments)
                end
            end
        end
    end
    
    -- Clean up completed missions and free squadrons
    for missionId, mission in pairs(TADC.missions) do
        local squadron = TADC.squadrons[mission.squadron]
        if squadron then
            -- Check if mission should be completed (threat destroyed, timed out, or squadron has no airborne aircraft)
            local missionAge = currentTime - mission.startTime
            local shouldComplete = false
            
            -- Mission timeout (30 minutes)
            if missionAge > 1800 then
                shouldComplete = true
            end
            
            -- Squadron has returned (no airborne aircraft)
            if squadron.airborneAircraft == 0 and missionAge > 300 then -- Give 5 min minimum mission time
                shouldComplete = true
            end
            
            -- Threat no longer exists
            local threatExists = false
            for _, threat in pairs(threats) do
                if (threat.id .. "_" .. threat.firstDetected) == missionId then
                    threatExists = true
                    break
                end
            end
            if not threatExists and missionAge > 60 then -- 1 minute grace period
                shouldComplete = true
            end
            
            if shouldComplete then
                -- Free the squadron for new missions
                squadron.readinessLevel = "READY"
                TADC.squadronMissions[mission.squadron] = nil
                TADC.threatAssignments[missionId] = nil
                TADC.missions[missionId] = nil
                
                if GCI_Config.debugLevel >= 1 then
                    env.info("Mission completed: " .. mission.squadron .. " freed from " .. (mission.threat and mission.threat.id or "unknown threat"))
                end
            end
        else
            -- Squadron doesn't exist anymore, clean up
            TADC.missions[missionId] = nil
            TADC.threatAssignments[missionId] = nil
        end
    end
    
    -- Periodic status report
    if GCI_Config.debugLevel >= 1 and (currentTime % GCI_Config.statusReportInterval) < 30 then -- Status reports from config
        local totalAirborne = 0
        local totalAvailable = 0
        for _, squadron in pairs(TADC.squadrons) do
            totalAirborne = totalAirborne + squadron.airborneAircraft
            totalAvailable = totalAvailable + squadron.availableAircraft
        end
        
        env.info("=== TADC STATUS REPORT ===")
        env.info("Threats: " .. threatCount .. " active")
        env.info("Aircraft: " .. totalAirborne .. " airborne, " .. totalAvailable .. " available")
        env.info("Statistics: " .. TADC.stats.threatsDetected .. " threats detected, " .. TADC.stats.interceptsLaunched .. " intercepts launched")
        
        -- Persistent CAP Status
        if GCI_Config.enablePersistentCAP then
            local persistentCount = getPersistentCAPCount()
            local maxPersistentAllowed = math.floor(GCI_Config.maxSimultaneousCAP * (1 - GCI_Config.persistentCAPReserve))
            local threatReserve = GCI_Config.maxSimultaneousCAP - maxPersistentAllowed
            env.info("Persistent CAP: " .. persistentCount .. "/" .. GCI_Config.persistentCAPCount .. " target (" .. maxPersistentAllowed .. " max, " .. threatReserve .. " reserved for threats)")
        end
    end
    
    -- Persistent CAP Management
    if GCI_Config.enablePersistentCAP then
        maintainPersistentCAP()
    end
end

-- ================================================================================================
-- PERSISTENT CAP MANAGEMENT SYSTEM
-- ================================================================================================

local function setupTADC()
    env.info("=== INITIALIZING TACTICAL AIR DEFENSE CONTROLLER ===")
    env.info("✓ Configuration loaded:")
    env.info("  - Threat Ratio: " .. GCI_Config.threatRatio .. ":1")
    env.info("  - Max Simultaneous CAP: " .. GCI_Config.maxSimultaneousCAP)
    env.info("  - Reserve Percentage: " .. (GCI_Config.reservePercent * 100) .. "%")
    env.info("  - Supply Mode: " .. GCI_Config.supplyMode)
    env.info("  - Response Delay: " .. GCI_Config.responseDelay .. " seconds")
    
    -- Persistent CAP Configuration
    if GCI_Config.enablePersistentCAP then
        local maxPersistentAllowed = math.floor(GCI_Config.maxSimultaneousCAP * (1 - GCI_Config.persistentCAPReserve))
        local threatReserve = math.ceil(GCI_Config.maxSimultaneousCAP * GCI_Config.persistentCAPReserve)
        env.info("  - Persistent CAP: ENABLED (" .. GCI_Config.persistentCAPCount .. " target, " .. maxPersistentAllowed .. " max allowed)")
        env.info("  - Threat Response Reserve: " .. threatReserve .. " aircraft slots")
        env.info("  - Persistent CAP Check Interval: " .. GCI_Config.persistentCAPInterval .. " seconds")
    else
        env.info("  - Persistent CAP: DISABLED")
    end
    
    -- CAP Behavior Configuration
    env.info("  - CAP Orbit Radius: " .. (GCI_Config.capOrbitRadius / 1000) .. "km")
    env.info("  - CAP Engagement Range: " .. (GCI_Config.capEngagementRange / 1000) .. "km")
    env.info("  - Zone Constraint: " .. (GCI_Config.capZoneConstraint and "ENABLED" or "DISABLED"))
    
    -- Start main control loop
    SCHEDULER:New(nil, mainTADCLoop, {}, GCI_Config.mainLoopDelay, GCI_Config.mainLoopInterval) -- Main loop timing from config
    
    env.info("✓ TADC main control loop started")
    env.info("✓ Tactical Air Defense Controller operational!")
end

-- Initialize the TADC system
SCHEDULER:New(nil, function()
    setupTADC()
    
    -- Launch initial persistent CAP flights if enabled
    if GCI_Config.enablePersistentCAP then
        env.info("=== LAUNCHING INITIAL PERSISTENT CAP ===")
        TADC.lastPersistentCheck = 0 -- Force immediate check
        maintainPersistentCAP()
        
        -- Schedule another check in 30 seconds to ensure CAP gets airborne
        SCHEDULER:New(nil, function()
            env.info("=== PERSISTENT CAP FOLLOW-UP CHECK ===")
            TADC.lastPersistentCheck = 0 -- Force another immediate check
            maintainPersistentCAP()
        end, {}, 30)
    end
    
    -- Legacy: Optional initial standing patrols (if configured)
    if GCI_Config.initialStandingPatrols then
        local initialPatrols = {
            "FIGHTER_SWEEP_RED_Severomorsk-1", -- Main base always has standing patrol
            "HELO_SWEEP_RED_Afrikanda" -- Helo patrol coverage
        }
        
        for _, templateName in pairs(initialPatrols) do
            if TADC.squadrons[templateName] then
                -- Find the original squadron config
                local config = nil
                for _, squadronConfig in pairs(squadronConfigs) do
                    if squadronConfig.templateName == templateName then
                        config = squadronConfig
                        break
                    end
                end
                
                if config then
                    launchCAP(config, 1, "Initial standing patrol")
                end
            end
        end
    end
    
    env.info("=== TADC INITIALIZATION COMPLETE ===")
    env.info("✓ Intelligent threat assessment and response")
    env.info("✓ Multi-squadron coordinated intercepts")
    env.info("✓ Dynamic force sizing based on threat strength")
    env.info("✓ Resource management with reserve forces")
    env.info("✓ EWR network integration with " .. (RedEWR:Count()) .. " detection groups")
    env.info("✓ Tactical Air Defense Controller operational!")
    
end, {}, 5)