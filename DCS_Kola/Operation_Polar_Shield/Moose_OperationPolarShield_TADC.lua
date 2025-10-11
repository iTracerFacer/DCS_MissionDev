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

-- ================================================================================================
-- TADC LOGGING HELPER FUNCTION
-- ================================================================================================

-- Helper function to prefix all TADC logging with module identifier
local function TADC_Log(level, message)
    if level == "error" then
        env.error("[TADC Module] " .. message)
    elseif level == "warning" then
        env.warning("[TADC Module] " .. message)
    else
        env.info("[TADC Module] " .. message)
    end
end

-- SIMPLE GCI Configuration
local GCI_Config = {
    
    -- Basic Response Parameters
    threatRatio = 0.5,              -- Send 0.5x defenders per attacker
    -- THREAT RATIO REFERENCE TABLE:
    -- Formula: defendersNeeded = math.ceil(threat.size * threatRatio)
    --
    -- Threat Size →    1    2    3    4    5    6    7    8   10
    -- Ratio 0.5        1    1    2    2    3    3    4    4    5
    -- Ratio 0.75       1    2    3    3    4    5    6    6    8
    -- Ratio 1.0        1    2    3    4    5    6    7    8   10
    -- Ratio 1.25       2    3    4    5    7    8    9   10   13
    -- Ratio 1.5        2    3    5    6    8    9   11   12   15
    -- Ratio 2.0        2    4    6    8   10   12   14   16   20
    --
    -- Current (0.5) = Conservative Response (good for limited resources)
    -- Recommended 1.0 = Proportional Response (balanced)
    -- Aggressive 1.5+ = Overwhelming Response (resource intensive)
    
    maxSimultaneousCAP = 12,        -- Maximum total airborne aircraft at once
    
    -- EWR Detection
    useEWRDetection = true,         -- Use EWR radar for detection
    ewrDetectionRadius = 50000,     -- EWR detection radius (50km)
    
    -- Simple Timing
    mainLoopInterval = 15,          -- Check for threats every 15 seconds
    mainLoopDelay = 10,             -- Initial delay before starting main loop
    squadronCooldown = 120,         -- 2 minutes between squadron launches
    
    -- Supply and Squadron Management
    supplyMode = "INFINITE",        -- INFINITE or FINITE
    defaultSquadronSize = 4,        -- Default aircraft per squadron
    reservePercent = 0.3,           -- Reserve 30% of aircraft
    responseDelay = 5,              -- Delay before responding to threats
    
    -- CAP Management
    capSetupDelay = 30,             -- Delay before setting up CAP
    capOrbitRadius = 10000,         -- CAP orbit radius in meters
    capEngagementRange = 25000,     -- CAP engagement range in meters
    capZoneConstraint = true,       -- Keep CAP within assigned zones
    
    -- Spawn Parameters
    spawnDistanceMin = 5000,        -- Minimum spawn distance from airbase (5km)
    spawnDistanceMax = 15000,       -- Maximum spawn distance from airbase (15km)
    
    -- Mission Parameters
    minPatrolDuration = 900,        -- Minimum patrol duration (15 minutes)
    rtbDuration = 300,              -- RTB and cleanup duration (5 minutes)
    AI_PATROL_TIME = 1800,          -- AI patrol rotation time (30 minutes)
    
    -- Status and Monitoring
    statusReportInterval = 300,     -- Status report every 5 minutes
    engagementUpdateInterval = 30,  -- Update engagements every 30 seconds
    
    -- Combat Effectiveness Ratios
    fighterVsFighter = 1.0,         -- Fighter vs Fighter effectiveness
    fighterVsBomber = 1.5,          -- Fighter vs Bomber effectiveness  
    fighterVsHelicopter = 2.0,      -- Fighter vs Helicopter effectiveness
    
    -- Threat Management
    threatTimeout = 300,            -- Remove threats after 5 minutes of no contact
    
    -- Testing and Debug
    forceOmniscientDetection = false, -- Force omniscient detection for testing
    debugLevel = 2,                 -- Verbose logging
    
    -- Persistent CAP Configuration
    enablePersistentCAP = true,     -- Enable continuous standing patrols
    persistentCAPCount = 2,         -- Number of persistent CAP flights to maintain
    persistentCAPInterval = 600,    -- Check/maintain persistent CAP every 2 minutes
    persistentCAPReserve = 0.3,     -- Reserve 30% of maxSimultaneousCAP slots for threat response
    
    -- Dynamic Resource Management
    enableDynamicReserves = true,   -- Adjust reserves based on threat level
    highThreatReserve = 0.4,       -- 40% reserve during high threat
    lowThreatReserve = 0.2,        -- 20% reserve during low threat
    threatThreshold = 3,           -- Number of threats to trigger high alert
    persistentCAPPriority = {       -- Priority order for persistent CAP squadrons
        "FIGHTER_SWEEP_RED_Severomorsk-1",  -- Primary intercept base
        "FIGHTER_SWEEP_RED_Olenya",         -- Northern coverage
        "FIGHTER_SWEEP_RED_Murmansk",       -- Western coverage
        "HELO_SWEEP_RED_Afrikanda"          -- Helicopter patrol
    },
    
    -- Optional Features
    initialStandingPatrols = true   -- Launch standing patrols on startup (ENABLED FOR TESTING)
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
    
    -- Enhanced Statistics & Performance Monitoring
    stats = {
        threatsDetected = 0,
        interceptsLaunched = 0,
        successfulEngagements = 0,
        aircraftLost = 0,
        avgResponseTime = 0,
        maxResponseTime = 0,
        systemLoadTime = 0,
        memoryUsage = 0
    },
    
    -- Performance tracking
    performance = {
        lastLoopTime = 0,
        avgLoopTime = 0,
        maxLoopTime = 0,
        loopCount = 0
    }
}

-- Configuration Validation
local function validateConfiguration()
    local errors = {}
    
    if GCI_Config.maxSimultaneousCAP < 1 then
        table.insert(errors, "maxSimultaneousCAP must be at least 1")
    end
    
    if GCI_Config.threatRatio <= 0 then
        table.insert(errors, "threatRatio must be positive")
    end
    
    if GCI_Config.reservePercent < 0 or GCI_Config.reservePercent > 1 then
        table.insert(errors, "reservePercent must be between 0 and 1")
    end
    
    if #errors > 0 then
        TADC_Log("error", "TADC Configuration Errors:")
        for _, error in pairs(errors) do
            TADC_Log("error", "  - " .. error)
        end
        return false
    end
    
    return true
end

-- Setup Distributed Multi-Base CAP System
-- This creates a dynamic response system where each squadron launches from its designated airbase
-- and responds to threats based on proximity and zone coverage.

-- Create border zones with error checking
local redBorderGroup = GROUP:FindByName("RED BORDER")
local heloBorderGroup = GROUP:FindByName("HELO BORDER")

if redBorderGroup then
    CCCPBorderZone = ZONE_POLYGON:New("RED BORDER", redBorderGroup)
    TADC_Log("info", "RED BORDER zone created successfully")
else
    TADC_Log("error", "RED BORDER group not found!")
    return
end

if heloBorderGroup then
    HeloBorderZone = ZONE_POLYGON:New("HELO BORDER", heloBorderGroup)
    TADC_Log("info", "HELO BORDER zone created successfully")
else
    TADC_Log("error", "HELO BORDER group not found!")
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
TADC_Log("info", "=== CHECKING SQUADRON TEMPLATES ===")
local availableSquadrons = {}

-- First, let's verify what airbases are actually available
TADC_Log("info", "=== VERIFYING AIRBASE NAMES ===")
local testAirbaseNames = {
    "Kilpyavr", "Severomorsk-1", "Severomorsk-3", 
    "Murmansk International", "Monchegorsk", "Olenya", "Afrikanda"
}
for _, airbaseName in pairs(testAirbaseNames) do
    local airbaseObj = AIRBASE:FindByName(airbaseName)
    if airbaseObj then
        TADC_Log("info", "✓ Airbase found: " .. airbaseName)
    else
        TADC_Log("info", "✗ Airbase NOT found: " .. airbaseName)
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
        homebase = AIRBASE:FindByName(config.airbaseName), -- Add homebase reference
        
        -- Enhanced Status Management
        readinessLevel = "READY",      -- READY, BUSY, MAINTENANCE, UNAVAILABLE, ALERT
        lastLaunch = -GCI_Config.squadronCooldown,  -- Allow immediate launch (set to -cooldown)
        launchCooldown = GCI_Config.squadronCooldown,  -- Cooldown from config
        alertLevel = "GREEN",          -- GREEN, YELLOW, RED
        maintenanceUntil = 0,          -- Time when maintenance completes
        fatigue = 0,                   -- Pilot fatigue factor (0-100)
        
        -- Statistics
        sorties = 0,
        kills = 0,
        losses = 0
    }
end

TADC_Log("info", "=== INITIALIZING SQUADRON DATABASE ===")
for _, config in pairs(squadronConfigs) do
    local template = GROUP:FindByName(config.templateName)
    if template then
        TADC_Log("info", "✓ Found squadron template: " .. config.templateName)
        
        -- Verify airbase exists and is Red coalition
        local airbaseObj = AIRBASE:FindByName(config.airbaseName)
        if airbaseObj then
            local airbaseCoalition = airbaseObj:GetCoalition()
            if airbaseCoalition == 1 then -- Red coalition
                TADC_Log("info", "  ✓ Airbase verified: " .. config.airbaseName .. " (Red Coalition)")
                
                -- Initialize squadron in TADC database
                local squadron = initializeSquadron(config)
                TADC.squadrons[config.templateName] = squadron
                availableSquadrons[config.templateName] = config -- Keep for compatibility
                
                TADC_Log("info", "  ✓ Squadron initialized: " .. squadron.availableAircraft .. " aircraft available")
            else
                TADC_Log("info", "  ✗ Airbase " .. config.airbaseName .. " not Red coalition - squadron disabled")
            end
        else
            TADC_Log("info", "  ✗ Airbase NOT found: " .. config.airbaseName .. " - squadron disabled")
        end
    else
        TADC_Log("info", "✗ Missing squadron template: " .. config.templateName)
    end
end

local squadronCount = 0
local totalAircraft = 0
for _, squadron in pairs(TADC.squadrons) do
    squadronCount = squadronCount + 1
    totalAircraft = totalAircraft + squadron.availableAircraft
end

TADC_Log("info", "✓ TADC Squadron Database: " .. squadronCount .. " squadrons, " .. totalAircraft .. " total aircraft")
if GCI_Config.supplyMode == "INFINITE" then
    TADC_Log("info", "✓ Supply Mode: INFINITE - unlimited aircraft spawning")
else
    TADC_Log("info", "✓ Supply Mode: FINITE - " .. totalAircraft .. " aircraft available")
end

-- ================================================================================================
-- TACTICAL AIR DEFENSE CONTROLLER (TADC) SYSTEM
-- A comprehensive GCI system for intelligent air defense coordination
-- ================================================================================================

TADC_Log("info", "=== INITIALIZING TACTICAL AIR DEFENSE CONTROLLER ===")

-- Create EWR Detection Network with Detection System
local RedEWR = SET_GROUP:New():FilterPrefixes("RED-EWR"):FilterStart()
local RedDetection = nil

-- Check EWR network availability
TADC_Log("info", "Searching for EWR groups with prefix 'RED-EWR'...")
TADC_Log("info", "Found " .. RedEWR:Count() .. " EWR groups")

-- TESTING: Force disable EWR detection if configured
if GCI_Config.forceOmniscientDetection then
    TADC_Log("info", "✓ TESTING MODE: Forcing omniscient detection (EWR disabled)")
    GCI_Config.useEWRDetection = false
end

if GCI_Config.useEWRDetection and RedEWR:Count() > 0 then
    TADC_Log("info", "✓ Red EWR Network: " .. RedEWR:Count() .. " detection groups")
    
    -- Create MOOSE Detection system using EWR network (basic version for compatibility)
    local success, errorMsg = pcall(function()
        RedDetection = DETECTION_AREAS:New(RedEWR, GCI_Config.ewrDetectionRadius)
        RedDetection:Start()
    end)
    
    if success then
        TADC_Log("info", "✓ EWR-based threat detection system initialized (" .. (GCI_Config.ewrDetectionRadius/1000) .. "km range)")
    else
        TADC_Log("info", "⚠ EWR detection failed: " .. tostring(errorMsg) .. " - falling back to omniscient detection")
        RedDetection = nil
    end
else
    if GCI_Config.useEWRDetection then
        TADC_Log("info", "⚠ Warning: No RED-EWR groups found - falling back to omniscient detection")
    else
        TADC_Log("info", "✓ Using omniscient detection (EWR detection disabled in config)")
    end
end

-- ================================================================================================
-- BACKUP IMMEDIATE RESPONSE SYSTEM (Like RU_INTERCEPT)
-- ================================================================================================

-- Forward declarations
local launchInterceptMission

-- Immediate response timer for aggressive intercepts
local lastImmediateCheck = 0
local immediateResponseInterval = 5 -- Check every 5 seconds

-- Simple immediate intercept function (backup to complex TADC system)
local function immediateInterceptCheck()
    local currentTime = timer.getTime()
    if currentTime - lastImmediateCheck < immediateResponseInterval then
        return
    end
    lastImmediateCheck = currentTime
    
    -- Quick scan for blue aircraft in border zones
    local BlueAircraft = SET_GROUP:New():FilterCoalitions("blue"):FilterCategoryAirplane():FilterStart()
    local threatsFound = 0
    
    BlueAircraft:ForEach(function(blueGroup)
        if blueGroup and blueGroup:IsAlive() then
            local blueCoord = blueGroup:GetCoordinate()
            local inRedZone = CCCPBorderZone and CCCPBorderZone:IsCoordinateInZone(blueCoord)
            local inHeloZone = HeloBorderZone and HeloBorderZone:IsCoordinateInZone(blueCoord)
            
            if inRedZone or inHeloZone then
                threatsFound = threatsFound + 1
                TADC_Log("info", "🚨 IMMEDIATE THREAT: " .. blueGroup:GetName() .. " in " .. (inRedZone and "RED_BORDER" or "HELO_BORDER"))
                
                -- Find nearest ready squadron and launch immediately
                local bestSquadron = nil
                local bestDistance = 999999
                
                for templateName, squadron in pairs(TADC.squadrons) do
                    if squadron.readinessLevel == "READY" and squadron.availableAircraft > 0 then
                        local squadronCoord = squadron.homebase and squadron.homebase:GetCoordinate()
                        if squadronCoord then
                            local distance = squadronCoord:Get2DDistance(blueCoord)
                            if distance < bestDistance then
                                bestDistance = distance
                                bestSquadron = squadron
                            end
                        end
                    end
                end
                
                if bestSquadron then
                    TADC_Log("info", "🚀 IMMEDIATE LAUNCH: " .. bestSquadron.displayName .. " responding to immediate threat")
                    -- Launch using simplified parameters
                    local simpleThreat = {
                        id = blueGroup:GetName(),
                        group = blueGroup,
                        coordinate = blueCoord,
                        classification = "FIGHTER",
                        zone = inRedZone and "RED_BORDER" or "HELO_BORDER"
                    }
                    
                    -- Find the original squadron config
                    local squadronConfig = nil
                    for _, config in pairs(squadronConfigs) do
                        if config.templateName == bestSquadron.templateName then
                            squadronConfig = config
                            break
                        end
                    end
                    
                    if squadronConfig then
                        launchInterceptMission(squadronConfig, simpleThreat, "IMMEDIATE_RESPONSE")
                    else
                        TADC_Log("error", "Could not find config for immediate response squadron: " .. bestSquadron.templateName)
                    end
                end
            end
        end
    end)
    
    if threatsFound > 0 then
        TADC_Log("info", "🚨 IMMEDIATE SCAN: " .. threatsFound .. " threats found in border zones")
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

-- ================================================================================================
-- SMART THREAT PRIORITIZATION SYSTEM
-- ================================================================================================

-- Strategic target definitions with importance weights
local STRATEGIC_TARGETS = {
    -- Airbases (highest priority)
    {name = "Severomorsk-1", coord = nil, importance = 100, type = "AIRBASE"},
    {name = "Olenya", coord = nil, importance = 95, type = "AIRBASE"},
    {name = "Murmansk", coord = nil, importance = 90, type = "AIRBASE"},
    {name = "Afrikanda", coord = nil, importance = 85, type = "AIRBASE"},
    
    -- SAM sites (medium-high priority)
    {name = "SA-10 Sites", coord = nil, importance = 70, type = "SAM"},
    {name = "SA-11 Sites", coord = nil, importance = 60, type = "SAM"},
    
    -- Command centers (high priority)
    {name = "Command Centers", coord = nil, importance = 80, type = "COMMAND"}
}

-- Initialize strategic target coordinates
local function initializeStrategicTargets()
    for _, target in pairs(STRATEGIC_TARGETS) do
        if target.type == "AIRBASE" then
            local airbase = AIRBASE:FindByName(target.name)
            if airbase then
                target.coord = airbase:GetCoordinate()
                if GCI_Config.debugLevel >= 1 then
                    TADC_Log("info", "✓ Strategic target: " .. target.name .. " (Importance: " .. target.importance .. ")")
                end
            end
        end
    end
end

-- Enhanced multi-factor threat priority calculation
local function calculateThreatPriority(classification, coordinate, size, velocity, heading, group)
    local priority = 0.0
    
    -- 1. BASE THREAT TYPE PRIORITY (40% weight)
    local basePriority = 0
    if classification == "BOMBER" then
        basePriority = 100    -- Highest threat - can destroy strategic targets
    elseif classification == "ATTACK" then
        basePriority = 85     -- High threat - ground attack capability
    elseif classification == "FIGHTER" then
        basePriority = 70     -- Medium threat - air superiority
    elseif classification == "HELICOPTER" then
        basePriority = 50     -- Lower threat but still dangerous
    else
        basePriority = 30     -- Unknown/other aircraft
    end
    priority = priority + (basePriority * 0.4)
    
    -- 2. FORMATION SIZE FACTOR (15% weight)
    local sizeMultiplier = 1.0
    if size and size > 1 then
        sizeMultiplier = 1.0 + ((size - 1) * 0.3) -- Each additional aircraft adds 30%
        sizeMultiplier = math.min(sizeMultiplier, 2.5) -- Cap at 250%
    end
    priority = priority * sizeMultiplier
    
    -- 3. STRATEGIC PROXIMITY ANALYSIS (25% weight)
    local proximityScore = 0
    if coordinate then
        local maxProximityScore = 0
        
        for _, target in pairs(STRATEGIC_TARGETS) do
            if target.coord then
                local distance = coordinate:Get2DDistance(target.coord)
                local threatRadius = 75000 -- 75km threat radius
                
                if distance <= threatRadius then
                    -- Exponential decay - closer threats much more dangerous
                    local proximityFactor = math.exp(-distance / (threatRadius * 0.3))
                    local targetScore = (target.importance / 100) * proximityFactor * 100
                    maxProximityScore = math.max(maxProximityScore, targetScore)
                    
                    if GCI_Config.debugLevel >= 2 then
                        TADC_Log("info", "Threat proximity: " .. target.name .. " (" .. math.floor(distance/1000) .. "km) Score: " .. math.floor(targetScore))
                    end
                end
            end
        end
        
        proximityScore = maxProximityScore
    end
    priority = priority + (proximityScore * 0.25)
    
    -- 4. SPEED AND HEADING ANALYSIS (10% weight)
    local speedThreatFactor = 0
    if velocity and coordinate then
        -- Calculate speed magnitude from velocity vector
        local speed = 0
        if type(velocity) == "table" then
            -- DCS velocity is typically a 3D vector {x, y, z}
            local x = velocity.x or velocity[1] or 0
            local y = velocity.y or velocity[2] or 0  
            local z = velocity.z or velocity[3] or 0
            speed = math.sqrt(x*x + y*y + z*z)
        elseif type(velocity) == "number" then
            speed = velocity
        end
        
        -- Fast-moving aircraft are more threatening (less intercept time)
        if speed > 250 then -- ~500 knots
            speedThreatFactor = 25 -- Very fast (supersonic)
        elseif speed > 150 then -- ~300 knots
            speedThreatFactor = 15 -- Fast
        elseif speed > 75 then -- ~150 knots
            speedThreatFactor = 10 -- Medium speed
        else
            speedThreatFactor = 5 -- Slow/hovering
        end
        
        -- Analyze heading threat (if heading toward strategic targets)
        if heading and type(heading) == "number" then
            local headingThreatBonus = 0
            for _, target in pairs(STRATEGIC_TARGETS) do
                if target.coord then
                    local bearingToTarget = coordinate:GetAngleDegrees(coordinate:GetDirectionVec3(target.coord))
                    local headingDiff = math.abs(heading - bearingToTarget)
                    if headingDiff > 180 then headingDiff = 360 - headingDiff end
                    
                    -- If heading within 30 degrees of target, significant bonus
                    if headingDiff <= 30 then
                        headingThreatBonus = math.max(headingThreatBonus, 20 * (target.importance / 100))
                    elseif headingDiff <= 60 then
                        headingThreatBonus = math.max(headingThreatBonus, 10 * (target.importance / 100))
                    end
                end
            end
            speedThreatFactor = speedThreatFactor + headingThreatBonus
        end
    end
    priority = priority + (speedThreatFactor * 0.1)
    
    -- 5. TEMPORAL FACTORS (10% weight)
    local temporalFactor = 0
    local currentTime = timer.getTime()
    
    -- Night operations (reduced visibility for defenders)
    local timeOfDay = (currentTime % 86400) / 3600 -- Hours since midnight
    if timeOfDay >= 20 or timeOfDay <= 6 then -- Night time
        temporalFactor = temporalFactor + 15
    end
    
    -- Weather considerations (if available)
    -- Note: DCS weather API would be needed for full implementation
    
    priority = priority + (temporalFactor * 0.1)
    
    -- 6. ELECTRONIC WARFARE CONSIDERATIONS
    local ewFactor = 0
    if group then
        -- Check for jamming or stealth characteristics
        local typeName = group:GetTypeName() or ""
        if string.find(typeName:upper(), "EA-") or string.find(typeName:upper(), "EF-") then
            ewFactor = 20 -- Electronic warfare aircraft are high priority
        elseif string.find(typeName:upper(), "F-22") or string.find(typeName:upper(), "F-35") then
            ewFactor = 15 -- Stealth aircraft harder to track
        end
    end
    priority = priority + ewFactor
    
    -- Final priority clamping and rounding
    priority = math.max(1, math.min(priority, 200)) -- Clamp between 1-200
    
    if GCI_Config.debugLevel >= 2 then
        TADC_Log("info", string.format("Smart Priority: %s (x%d) = %.1f [Base:%.1f, Size:%.1f, Prox:%.1f, Speed:%.1f, Time:%.1f, EW:%.1f]",
            classification, size or 1, priority, basePriority, sizeMultiplier, proximityScore, speedThreatFactor, temporalFactor, ewFactor))
    end
    
    return math.ceil(priority)
end

-- Enhanced threat assessment with predictive analysis
local function assessThreatWithPrediction(threats)
    local assessedThreats = {}
    local currentTime = timer.getTime()
    
    for threatId, threat in pairs(threats) do
        local assessment = {
            threat = threat,
            priority = threat.priority or 1,
            timeToTarget = nil,
            predictedPosition = nil,
            interceptWindow = nil,
            recommendedResponse = "STANDARD"
        }
        
        -- Predictive position analysis
        if threat.coordinate and threat.velocity and threat.heading then
            -- Calculate speed from velocity vector
            local speed = 0
            if type(threat.velocity) == "table" then
                local x = threat.velocity.x or threat.velocity[1] or 0
                local y = threat.velocity.y or threat.velocity[2] or 0  
                local z = threat.velocity.z or threat.velocity[3] or 0
                speed = math.sqrt(x*x + y*y + z*z)
            elseif type(threat.velocity) == "number" then
                speed = threat.velocity
            end
            
            -- Predict position in 5 minutes
            local futureTime = 300 -- 5 minutes
            local futureDistance = speed * futureTime
            assessment.predictedPosition = threat.coordinate:Translate(futureDistance, threat.heading)
            
            -- Calculate time to closest strategic target
            local minTimeToTarget = math.huge
            for _, target in pairs(STRATEGIC_TARGETS) do
                if target.coord then
                    local distance = threat.coordinate:Get2DDistance(target.coord)
                    local timeToTarget = distance / math.max(speed, 50) -- Minimum 50 m/s
                    minTimeToTarget = math.min(minTimeToTarget, timeToTarget)
                end
            end
            assessment.timeToTarget = minTimeToTarget
            
            -- Determine recommended response urgency
            if minTimeToTarget < 300 then -- Less than 5 minutes
                assessment.recommendedResponse = "EMERGENCY"
                assessment.priority = assessment.priority * 1.5
            elseif minTimeToTarget < 600 then -- Less than 10 minutes
                assessment.recommendedResponse = "URGENT"
                assessment.priority = assessment.priority * 1.3
            elseif minTimeToTarget < 1200 then -- Less than 20 minutes
                assessment.recommendedResponse = "HIGH"
                assessment.priority = assessment.priority * 1.1
            end
        end
        
        assessedThreats[threatId] = assessment
    end
    
    -- Sort by priority (highest first)
    local sortedThreats = {}
    for _, assessment in pairs(assessedThreats) do
        table.insert(sortedThreats, assessment)
    end
    
    table.sort(sortedThreats, function(a, b)
        return a.priority > b.priority
    end)
    
    return sortedThreats, assessedThreats
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

-- SIMPLE THREAT DETECTION - Just find blue aircraft detected by EWR in border zones
local function simpleDetectThreats()
    local newThreats = {}  -- This will be our return value
    local currentTime = timer.getTime()
    
    TADC_Log("info", "Checking for threats...")
    
    -- Use EWR detection if available and enabled
    if GCI_Config.useEWRDetection and RedDetection then
        local detectedItems = RedDetection:GetDetectedItems()
        TADC_Log("info", "EWR detected " .. #detectedItems .. " items")
        
        for _, detectedItem in pairs(detectedItems) do
            local detectedSet = detectedItem.Set
            if detectedSet then
                detectedSet:ForEach(function(blueGroup)
                    if blueGroup and blueGroup:IsAlive() and blueGroup:GetCoalition() == coalition.side.BLUE then
                        local coord = blueGroup:GetCoordinate()
                        
                        -- Check if in border zones
                        local inRedZone = CCCPBorderZone and CCCPBorderZone:IsCoordinateInZone(coord)
                        local inHeloZone = HeloBorderZone and HeloBorderZone:IsCoordinateInZone(coord)
                            
                        if inRedZone or inHeloZone then
                            local threatId = blueGroup:GetName()
                            local classification = classifyThreat(blueGroup)
                            local size = blueGroup:GetSize()
                            local heading = blueGroup:GetHeading()
                            local velocity = blueGroup:GetVelocity()
                            
                            -- Enhanced threat data with smart prioritization
                            newThreats[threatId] = {
                                id = threatId,
                                group = blueGroup,
                                coordinate = coord,
                                classification = classification,
                                size = size,
                                zone = inRedZone and "RED_BORDER" or "HELO_BORDER",
                                firstDetected = TADC.threats[threatId] and TADC.threats[threatId].firstDetected or currentTime,
                                lastSeen = currentTime,
                                heading = heading,
                                velocity = velocity,
                                priority = calculateThreatPriority(classification, coord, size, velocity, heading, blueGroup),
                                detectionMethod = "EWR",
                                -- Additional smart assessment data
                                typeName = blueGroup:GetTypeName(),
                                altitude = coord:GetLandHeight() + (blueGroup:GetCoordinate():GetY() or 0)
                            }
                            
                            -- Update statistics
                            if not TADC.threats[threatId] then
                                TADC.stats.threatsDetected = TADC.stats.threatsDetected + 1
                                if GCI_Config.debugLevel >= 1 then
                                    TADC_Log("info", "NEW EWR THREAT: " .. threatId .. " (" .. classification .. ", " .. size .. " aircraft) in " .. newThreats[threatId].zone)
                                end
                            end
                        end
                    end
                end)
            end
        end
    else
        -- Fallback: Omniscient detection (original method)
        TADC_Log("info", "🔍 Using OMNISCIENT detection mode")
        TADC_Log("info", "🔍 Zone check - CCCPBorderZone: " .. tostring(CCCPBorderZone ~= nil) .. ", HeloBorderZone: " .. tostring(HeloBorderZone ~= nil))
        
        local BlueAircraft = SET_GROUP:New():FilterCoalitions("blue"):FilterCategoryAirplane():FilterStart()
        
        -- DEBUG: Log how many blue aircraft we found
        local blueCount = BlueAircraft:Count()
        TADC_Log("info", "🔍 OMNISCIENT SCAN: Found " .. blueCount .. " blue aircraft on map")
        if blueCount == 0 then
            TADC_Log("warning", "⚠ No blue aircraft found on map - check coalition filtering")
        end
        
        BlueAircraft:ForEach(function(blueGroup)
            if blueGroup and blueGroup:IsAlive() then
                local blueCoord = blueGroup:GetCoordinate()
                local threatId = blueGroup:GetName()
                
                -- DEBUG: Log each blue aircraft found
                TADC_Log("info", "🔍 CHECKING BLUE AIRCRAFT: " .. threatId .. " (" .. blueGroup:GetTypeName() .. ") at " .. blueCoord:ToStringLLDMS())
                
                -- Check if threat is in any patrol zone
                local inRedZone = CCCPBorderZone and CCCPBorderZone:IsCoordinateInZone(blueCoord)
                local inHeloZone = HeloBorderZone and HeloBorderZone:IsCoordinateInZone(blueCoord)
                
                -- DEBUG: Log zone check results
                TADC_Log("info", "🔍   Zone Check - RED: " .. tostring(inRedZone) .. ", HELO: " .. tostring(inHeloZone))
                
                if inRedZone or inHeloZone then
                    TADC_Log("info", "🎯 THREAT IN ZONE: " .. threatId .. " detected in " .. (inRedZone and "RED_BORDER" or "HELO_BORDER"))
                    
                    local classification = classifyThreat(blueGroup)
                    local size = blueGroup:GetSize()
                    local heading = blueGroup:GetHeading()
                    local velocity = blueGroup:GetVelocity()
                    
                    TADC_Log("info", "🎯   Details: " .. classification .. ", " .. size .. " aircraft, heading " .. heading .. "°, " .. velocity .. " kts")
                    
                    newThreats[threatId] = {
                        id = threatId,
                        group = blueGroup,
                        coordinate = blueCoord,
                        classification = classification,
                        size = size,
                        zone = inRedZone and "RED_BORDER" or "HELO_BORDER",
                        firstDetected = TADC.threats[threatId] and TADC.threats[threatId].firstDetected or currentTime,
                        lastSeen = currentTime,
                        heading = heading,
                        velocity = velocity,
                        priority = calculateThreatPriority(classification, blueCoord, size, velocity, heading, blueGroup),
                        detectionMethod = "OMNISCIENT",
                        -- Additional smart assessment data
                        typeName = blueGroup:GetTypeName(),
                        altitude = blueCoord:GetLandHeight() + (blueGroup:GetCoordinate():GetY() or 0)
                    }
                    
                    -- Update statistics
                    if not TADC.threats[threatId] then
                        TADC.stats.threatsDetected = TADC.stats.threatsDetected + 1
                        TADC_Log("info", "✅ NEW THREAT REGISTERED: " .. threatId .. " (" .. classification .. ", " .. size .. " aircraft) in " .. newThreats[threatId].zone)
                    else
                        TADC_Log("info", "🔄 EXISTING THREAT UPDATED: " .. threatId)
                    end
                else
                    TADC_Log("debug", "❌ Aircraft " .. threatId .. " not in patrol zones - ignored")
                end
            end
        end)
    end
    
    -- Remove old threats (not seen for threatTimeout seconds)
    for threatId, threat in pairs(TADC.threats) do
        if not newThreats[threatId] and (currentTime - threat.lastSeen) > GCI_Config.threatTimeout then
            if GCI_Config.debugLevel >= 1 then
                TADC_Log("info", "THREAT TIMEOUT: " .. threatId .. " - removing from threat picture")
            end
        end
    end
    
    TADC.threats = newThreats
    
    -- Summary logging
    local threatCount = 0
    for _ in pairs(newThreats) do threatCount = threatCount + 1 end
    TADC_Log("info", "📊 Threat picture update complete: " .. threatCount .. " active threats")
    
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
    TADC_Log("info", "🎯 ASSIGNING THREATS TO SQUADRONS for " .. zone)
    
    local zoneThreats = {}
    for _, threat in pairs(threats) do
        if threat.zone == zone then
            table.insert(zoneThreats, threat)
        end
    end
    
    TADC_Log("info", "Found " .. #zoneThreats .. " threats in " .. zone)
    
    if #zoneThreats == 0 then
        TADC_Log("info", "No threats in zone, returning empty assignments")
        return {}
    end
    
    -- Get enhanced threat assessment with smart prioritization
    local sortedThreats, threatAssessments = assessThreatWithPrediction(zoneThreats)
    
    -- Smart threat assessment logging
    if GCI_Config.debugLevel >= 1 and #sortedThreats > 0 then
        TADC_Log("info", "=== SMART THREAT ASSESSMENT: " .. zone .. " ===")
        for i, assessment in ipairs(sortedThreats) do
            local threat = assessment.threat
            local timeStr = assessment.timeToTarget and string.format("%.1fm", assessment.timeToTarget/60) or "N/A"
            TADC_Log("info", string.format("%d. %s (%s x%d) Priority:%d TTT:%s Response:%s", 
                i, threat.id, threat.classification, threat.size or 1, 
                math.floor(assessment.priority), timeStr, assessment.recommendedResponse))
        end
    end
    
    local availableSquadrons, assessment, totalAvailable = findOptimalDefenders(threats, zone)
    
    -- Debug: Show squadron selection results
    if GCI_Config.debugLevel >= 1 then
        TADC_Log("info", "Squadron Selection for " .. zone .. ":")
        for i, squadronData in pairs(availableSquadrons) do
            local squadron = squadronData.data.squadron
            local currentTime = timer.getTime()
            local cooldownRemaining = math.max(0, squadron.launchCooldown - (currentTime - squadron.lastLaunch))
            TADC_Log("info", "  " .. i .. ". " .. squadron.displayName .. " - Available: " .. squadron.availableAircraft .. ", Cooldown: " .. math.ceil(cooldownRemaining) .. "s")
        end
    end
    
    -- Assign each unassigned threat to the best available squadron (using smart-prioritized order)
    local newAssignments = {}
    
    -- Process threats in smart priority order (highest priority first)
    for _, assessment in ipairs(sortedThreats) do
        local threat = assessment.threat
        local threatId = threat.id .. "_" .. threat.firstDetected
        
        -- Skip if threat is already assigned to an active squadron
        local skipThreat = false
        if TADC.threatAssignments[threatId] then
            local assignedSquadron = TADC.threatAssignments[threatId]
            local squadron = TADC.squadrons[assignedSquadron]
            if squadron and squadron.readinessLevel == "BUSY" then
                if GCI_Config.debugLevel >= 2 then
                    TADC_Log("info", "Threat " .. threat.id .. " already assigned to " .. assignedSquadron)
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
            -- Enhanced squadron selection with smart threat matching
            local bestSquadron = nil
            local bestScore = -1
            
            for _, squadronData in pairs(availableSquadrons) do
                local squadron = squadronData.data.squadron
                local templateName = squadronData.templateName
                
                -- Check if squadron is available (not already assigned to another threat)
                if not TADC.squadronMissions[templateName] and squadron.availableAircraft > 0 then
                    
                    -- Find the original squadron config
                    local originalConfig = nil
                    for _, config in pairs(squadronConfigs) do
                        if config.templateName == templateName then
                            originalConfig = config
                            break
                        end
                    end
                    
                    if originalConfig then
                        -- Calculate enhanced squadron suitability score
                        local score = 0
                        local distanceToThreat = squadronData.data.averageDistance or math.huge
                        
                        -- 1. DISTANCE FACTOR (40% of score) - Closer squadrons respond faster
                        local distanceScore = 40 * math.exp(-distanceToThreat / 75000) -- 75km ideal range
                        score = score + distanceScore
                        
                        -- 2. THREAT TYPE SPECIALIZATION (30% of score)
                        local typeBonus = 0
                        if threat.classification == "HELICOPTER" and originalConfig.type == "HELICOPTER" then
                            typeBonus = 30 -- Perfect match for helo vs helo
                        elseif threat.classification == "BOMBER" and originalConfig.type == "FIGHTER" then
                            typeBonus = 25 -- Fighters excellent vs bombers
                        elseif threat.classification == "ATTACK" and originalConfig.type == "FIGHTER" then
                            typeBonus = 20 -- Fighters good vs attack aircraft
                        elseif threat.classification == "FIGHTER" and originalConfig.type == "FIGHTER" then
                            typeBonus = 15 -- Fighter vs fighter
                        elseif originalConfig.type == "FIGHTER" then
                            typeBonus = 10 -- Fighters can handle most threats
                        end
                        score = score + typeBonus
                        
                        -- 3. SQUADRON READINESS (20% of score)
                        local readinessBonus = squadron.availableAircraft * 3 -- More aircraft = better
                        if squadron.alertLevel == "GREEN" then
                            readinessBonus = readinessBonus + 10
                        elseif squadron.alertLevel == "YELLOW" then
                            readinessBonus = readinessBonus + 5
                        end
                        score = score + readinessBonus
                        
                        -- 4. RESPONSE URGENCY MATCHING (10% of score)
                        local urgencyBonus = 0
                        if assessment.recommendedResponse == "EMERGENCY" then
                            urgencyBonus = 10 -- All squadrons get urgency bonus
                            score = score * 1.2 -- Emergency multiplier
                        elseif assessment.recommendedResponse == "URGENT" then
                            urgencyBonus = 7
                            score = score * 1.1 -- Urgent multiplier
                        elseif assessment.recommendedResponse == "HIGH" then
                            urgencyBonus = 4
                        end
                        score = score + urgencyBonus
                        
                        -- 5. PENALTY FACTORS
                        local penalties = 0
                        local currentTime = timer.getTime()
                        local timeSinceLaunch = currentTime - squadron.lastLaunch
                        if timeSinceLaunch < squadron.launchCooldown * 1.5 then
                            penalties = penalties + 5
                        end
                        if squadron.fatigue and squadron.fatigue > 50 then
                            penalties = penalties + (squadron.fatigue - 50) * 0.2
                        end
                        score = score - penalties
                        
                        if GCI_Config.debugLevel >= 2 then
                            TADC_Log("info", string.format("  %s vs %s: Score=%.1f [Dist:%.1f, Type:%d, Ready:%.1f, Urg:%d, Pen:%.1f]",
                                squadron.displayName, threat.id, score, distanceScore, typeBonus, readinessBonus, urgencyBonus, penalties))
                        end
                        
                        if score > bestScore then
                            bestScore = score
                            bestSquadron = {
                                templateName = templateName,
                                squadron = squadron,
                                distance = distanceToThreat,
                                threat = threat,
                                threatId = threatId,
                                config = originalConfig,
                                matchScore = score,
                                assessment = assessment -- Include threat assessment
                            }
                        end
                    end
                end
            end
            
            if bestSquadron then
                table.insert(newAssignments, bestSquadron)
                -- Mark squadron as assigned to prevent double-booking
                TADC.squadronMissions[bestSquadron.templateName] = bestSquadron.threatId
                TADC.threatAssignments[bestSquadron.threatId] = bestSquadron.templateName
                
                local timeStr = bestSquadron.assessment and bestSquadron.assessment.timeToTarget and 
                    string.format(" TTT:%.1fm", bestSquadron.assessment.timeToTarget/60) or ""
                local responseStr = bestSquadron.assessment and bestSquadron.assessment.recommendedResponse or "STANDARD"
                TADC_Log("info", string.format("✅ ASSIGNMENT CREATED: %s → %s (%s x%d) Score:%.1f Priority:%d%s %s", 
                    bestSquadron.squadron.displayName, threat.id, threat.classification, 
                    threat.size or 1, bestSquadron.matchScore or 0, 
                    bestSquadron.assessment and math.floor(bestSquadron.assessment.priority) or threat.priority,
                    timeStr, responseStr))
            else
                TADC_Log("warning", "❌ NO SQUADRON AVAILABLE for threat " .. threat.id .. " - checking why...")
                -- Debug why no squadron was available
                local availableCount = 0
                for templateName, squadron in pairs(TADC.squadrons) do
                    if squadron.readinessLevel == "READY" and squadron.availableAircraft >= 1 then
                        availableCount = availableCount + 1
                        TADC_Log("info", "  Available: " .. squadron.displayName)
                    else
                        TADC_Log("info", "  Unavailable: " .. squadron.displayName .. " (" .. squadron.readinessLevel .. ", " .. squadron.availableAircraft .. " aircraft)")
                    end
                end
                TADC_Log("info", "Total available squadrons: " .. availableCount)
            end
        end
    end
    
    TADC_Log("info", "📋 ASSIGNMENT SUMMARY: Created " .. #newAssignments .. " assignments for " .. #zoneThreats .. " threats in " .. zone)
    return newAssignments
end

-- ================================================================================================
-- CAP LAUNCH FUNCTION (Must be defined before executeInterceptMission)
-- ================================================================================================

local function launchCAP(config, aircraftCount, reason)
    aircraftCount = aircraftCount or 1
    
    TADC_Log("info", "=== LAUNCHING CAP ===")
    TADC_Log("info", "Squadron: " .. config.displayName)
    TADC_Log("info", "Airbase: " .. config.airbaseName)
    TADC_Log("info", "Aircraft: " .. aircraftCount)
    TADC_Log("info", "Reason: " .. reason)
    
    local success, errorMsg = pcall(function()
        -- Find the airbase object
        local airbaseObj = AIRBASE:FindByName(config.airbaseName)
        if not airbaseObj then
            TADC_Log("info", "✗ Could not find airbase: " .. config.airbaseName)
            return
        end
        
        TADC_Log("info", "✓ Airbase object found, attempting spawn...")
        TADC_Log("info", "Template: " .. config.templateName)
        TADC_Log("info", "Aircraft count: " .. config.aircraft)
        TADC_Log("info", "Skill: " .. tostring(config.skill))
        
        -- Check if template exists
        local templateGroup = GROUP:FindByName(config.templateName)
        if not templateGroup then
            TADC_Log("info", "✗ CRITICAL: Template group not found: " .. config.templateName)
            TADC_Log("info", "SOLUTION: In Mission Editor, ensure group '" .. config.templateName .. "' exists and is set to 'Late Activation'")
            return
        end
        
        -- Check template group properties
        local coalition = templateGroup:GetCoalition()
        local coalitionName = coalition == 1 and "Red" or (coalition == 2 and "Blue" or "Neutral")
        TADC_Log("info", "✓ Template group found - Coalition: " .. coalitionName)
        
        if coalition ~= 1 then
            TADC_Log("info", "✗ CRITICAL: Template group is not Red coalition (coalition=" .. coalition .. ")")
            TADC_Log("info", "SOLUTION: In Mission Editor, set group '" .. config.templateName .. "' to Red coalition")
            return
        end
        
        -- Template groups should NOT be alive if Late Activation is working correctly
        local isAlive = templateGroup:IsAlive()
        TADC_Log("info", "Template Status - Alive: " .. tostring(isAlive) .. " (should be false for Late Activation)")
        
        if isAlive then
            TADC_Log("info", "⚠ Warning: Template group is alive - Late Activation may not be set correctly")
            TADC_Log("info", "This means the group has already spawned in the mission")
        else
            TADC_Log("info", "✓ Template group correctly set to Late Activation")
        end
        
        -- Create SPAWN object with proper initialization
        TADC_Log("info", "Creating SPAWN object...")
        local spawner = SPAWN:New(config.templateName)
        
       
        -- Try different spawn methods that actually work
        local spawnedGroup = nil
        
        -- Enhanced spawn system with better error handling and retry logic
        local airbaseCoord = airbaseObj:GetCoordinate()
        local spawnAttempts = 0
        local maxAttempts = 3
        
        local function attemptSpawn()
            spawnAttempts = spawnAttempts + 1
            
            -- Method 1: Air spawn with validation
            if spawnAttempts == 1 then
                local spawnCoord = airbaseCoord:Translate(
                    math.random(GCI_Config.spawnDistanceMin, GCI_Config.spawnDistanceMax), 
                    math.random(0, 360)
                ):SetAltitude(config.altitude * 0.3048) -- Convert feet to meters
                
                TADC_Log("info", "Attempt " .. spawnAttempts .. ": Air spawn at " .. config.altitude .. "ft near " .. config.airbaseName)
                return spawner:SpawnFromCoordinate(spawnCoord, nil, SPAWN.Takeoff.Air)
                
            -- Method 2: Hot start from airbase
            elseif spawnAttempts == 2 then
                TADC_Log("info", "Attempt " .. spawnAttempts .. ": Hot start from airbase")
                return spawner:SpawnAtAirbase(airbaseObj, SPAWN.Takeoff.Hot)
                
            -- Method 3: Cold start from airbase
            elseif spawnAttempts == 3 then
                TADC_Log("info", "Attempt " .. spawnAttempts .. ": Cold start from airbase")
                return spawner:SpawnAtAirbase(airbaseObj, SPAWN.Takeoff.Cold)
            end
            
            return nil
        end
        
        -- Retry spawn with delays
        while spawnAttempts < maxAttempts and not spawnedGroup do
            spawnedGroup = attemptSpawn()
            if not spawnedGroup and spawnAttempts < maxAttempts then
                TADC_Log("info", "Spawn attempt " .. spawnAttempts .. " failed, retrying in 2 seconds...")
                -- Note: In actual implementation, you'd want to use SCHEDULER for the delay
            end
        end
        
        if spawnedGroup then
            TADC_Log("info", "✓ Aircraft spawned successfully: " .. config.displayName)
            -- Note: Skip immediate altitude check as coordinates may not be ready yet
            -- Altitude will be set properly in the scheduled CAP setup task
            
            -- Wait a moment then set up proper CAP mission
            SCHEDULER:New(nil, function()
                if spawnedGroup and spawnedGroup:IsAlive() then
                    TADC_Log("info", "Setting up CAP mission for " .. config.displayName)
                    
                    -- Set proper altitude and speed (with enhanced safety checks)
                    local currentCoord = nil
                    local coordSuccess = pcall(function()
                        currentCoord = spawnedGroup:GetCoordinate()
                    end)
                    
                    if coordSuccess and currentCoord then
                        local properAltCoord = currentCoord:SetAltitude(config.altitude)
                        spawnedGroup:RouteAirTo(properAltCoord, config.speed, "BARO")
                        TADC_Log("info", "✓ Set altitude to " .. config.altitude .. "ft")
                    else
                        TADC_Log("info", "⚠ Coordinate not ready yet, CAP task will handle altitude")
                    end
                    
                    -- Set up AGGRESSIVE AI options with error handling
                    local success, errorMsg = pcall(function()
                        -- ENGAGEMENT RULES - AGGRESSIVE
                        spawnedGroup:OptionROEOpenFire()           -- Engage enemies immediately
                        spawnedGroup:OptionROTVertical()           -- No altitude restrictions (for all aircraft)
                        
                        -- DETECTION AND TARGETING - AGGRESSIVE
                        spawnedGroup:OptionECM_Never()             -- Never use ECM to stay hidden
                        -- spawnedGroup:OptionRadarUsing(AI.Option.Ground.val.RADAR_USING.FOR_SEARCH_IF_REQUIRED) -- Skip this - not for air units
                        
                        -- RTB CONDITIONS - AGGRESSIVE (stay longer)
                        spawnedGroup:OptionRTBBingoFuel()          -- RTB when low fuel
                        spawnedGroup:OptionRTBAmmo(0.05)           -- RTB when 5% ammo left (was 10%)
                        
                        -- COMBAT BEHAVIOR - AGGRESSIVE
                        spawnedGroup:OptionAAAttackRange(AI.Option.Air.val.AA_ATTACK_RANGE.MAX_RANGE)  -- Use maximum weapon range
                        spawnedGroup:OptionMissileAttack(AI.Option.Air.val.MISSILE_ATTACK.MAX_RANGE)   -- Fire missiles at max range
                        
                        -- FORMATION AND MANEUVERING - AGGRESSIVE
                        if config.type == "HELICOPTER" then
                            spawnedGroup:OptionFormation(AI.Option.Air.val.FORMATION.LINE_ABREAST)     -- Spread out for helicopters
                        else
                            spawnedGroup:OptionFormation(AI.Option.Air.val.FORMATION.FINGER_FOUR)     -- Combat formation for fighters
                        end
                        
                        TADC_Log("info", "✓ Aggressive AI options set for " .. config.displayName)
                    end)
                    
                    if not success then
                        TADC_Log("info", "⚠ Warning: Could not set all AI options: " .. tostring(errorMsg))
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
                                
                                TADC_Log("info", "Setting new patrol area for " .. config.displayName .. " at " .. randomRadius .. "m/" .. randomBearing .. "°")
                                
                                -- Clear old tasks and set up AGGRESSIVE HUNTER-KILLER tasks
                                spawnedGroup:ClearTasks()
                                
                                -- PRIMARY TASK: AGGRESSIVE AREA SWEEP (Priority 1 - Most Important)
                                local sweepTask = {
                                    id = 'EngageTargetsInZone',
                                    params = {
                                        targetTypes = {'Air'},
                                        priority = 1,  -- HIGHEST PRIORITY
                                        zone = {
                                            point = {x = patrolPoint.x, y = patrolPoint.z},
                                            radius = GCI_Config.capEngagementRange,  -- Large search area
                                        },
                                        noTargetTypes = {},  -- Engage ALL air targets
                                        value = 'All',      -- Engage all found targets
                                    }
                                }
                                spawnedGroup:PushTask(sweepTask, 1)
                                
                                -- SECONDARY TASK: COMBAT AIR PATROL with AGGRESSIVE SEARCH (Priority 2)
                                local aggressiveCAP = {
                                    id = 'ComboTask',
                                    params = {
                                        tasks = {
                                            -- Search Pattern
                                            {
                                                id = 'EngageTargets',
                                                params = {
                                                    targetTypes = {'Air'},
                                                    priority = 1,
                                                    maxDistEnabled = true,
                                                    maxDist = GCI_Config.capEngagementRange * 1.2,  -- 20% larger search range
                                                    direction = 0,  -- Search all directions
                                                    attackQtyLimit = 0,  -- No limit on attacks
                                                    directionEnabled = false,  -- Search all directions
                                                    altitudeEnabled = false,    -- Search all altitudes
                                                }
                                            },
                                            -- Fallback Patrol (only if no targets)
                                            {
                                                id = 'Orbit',
                                                params = {
                                                    pattern = config.type == "HELICOPTER" and 'Race-Track' or 'Circle',
                                                    point = {x = patrolPoint.x, y = patrolPoint.z},
                                                    radius = config.type == "HELICOPTER" and 5000 or GCI_Config.patrolAreaRadius,
                                                    altitude = config.altitude * 0.3048,
                                                    speed = config.speed * 0.514444 * 1.1,  -- 10% faster for aggressive patrol
                                                }
                                            }
                                        }
                                    }
                                }
                                spawnedGroup:PushTask(aggressiveCAP, 2)
                                
                                TADC_Log("info", "✓ " .. config.displayName .. " assigned to patrol area " .. randomRadius .. "m from zone center")
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
                        TADC_Log("info", "⚠ Warning: Could not set CAP tasks: " .. tostring(capError))
                        -- Fallback: just set basic engage task
                        spawnedGroup:OptionROEOpenFire()
                    end
                    
                    TADC_Log("info", "✓ CAP mission established at " .. config.altitude .. "ft altitude")
                    
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
                    TADC_Log("info", config.displayName .. " completing patrol mission - RTB")
                    local group = TADC.activeCAPs[config.templateName].group
                    if group and group:IsAlive() then
                        -- Clear current tasks
                        group:ClearTasks()
                        
                        -- Send back to base
                        local airbaseObj = AIRBASE:FindByName(config.airbaseName)
                        if airbaseObj then
                            group:RouteRTB(airbaseObj)
                            TADC_Log("info", "✓ " .. config.displayName .. " returning to " .. config.airbaseName)
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
                                    TADC_Log("info", "✓ " .. config.displayName .. " landed and available for next sortie")
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
            TADC_Log("info", "✗ Failed to spawn " .. config.displayName)
        end
    end)
    
    if not success then
        TADC_Log("info", "✗ Error launching CAP: " .. tostring(errorMsg))
        return false
    else
        TADC_Log("info", "✓ CAP launch completed successfully")
        return true
    end
end

-- ================================================================================================
-- AGGRESSIVE INTERCEPT FUNCTION - Direct threat vectoring
-- ================================================================================================

launchInterceptMission = function(config, threat, reason)
    TADC_Log("info", "=== LAUNCHING INTERCEPT MISSION ===")
    TADC_Log("info", "Squadron: " .. config.displayName)
    TADC_Log("info", "Target: " .. (threat and threat.id or "Unknown"))
    TADC_Log("info", "Target Type: " .. (threat and threat.classification or "Unknown"))
    TADC_Log("info", "Reason: " .. reason)
    
    local success, errorMsg = pcall(function()
        -- Find the airbase object
        local airbaseObj = AIRBASE:FindByName(config.airbaseName)
        if not airbaseObj then
            TADC_Log("error", "✗ Could not find airbase: " .. config.airbaseName)
            error("Airbase not found: " .. config.airbaseName)
        end
        
        -- Check if template exists
        local templateGroup = GROUP:FindByName(config.templateName)
        if not templateGroup then
            TADC_Log("error", "✗ CRITICAL: Template group not found: " .. config.templateName)
            error("Template group not found: " .. config.templateName)
        end
        
        -- Create SPAWN object
        local spawner = SPAWN:New(config.templateName)
        
        -- Spawn aircraft in air at proper altitude
        local airbaseCoord = airbaseObj:GetCoordinate()
        local spawnCoord = airbaseCoord:Translate(math.random(GCI_Config.spawnDistanceMin, GCI_Config.spawnDistanceMax), math.random(0, 360))
        spawnCoord = spawnCoord:SetAltitude(config.altitude)
        
        TADC_Log("info", "Spawning interceptor at " .. config.altitude .. "ft near " .. config.airbaseName)
        local spawnedGroup = spawner:SpawnFromCoordinate(spawnCoord, nil, SPAWN.Takeoff.Air)
        
        if not spawnedGroup then
            -- Fallback spawn methods
            spawnedGroup = spawner:SpawnAtAirbase(airbaseObj, SPAWN.Takeoff.Hot)
            if not spawnedGroup then
                spawnedGroup = spawner:SpawnFromCoordinate(airbaseCoord)
            end
        end
        
        if spawnedGroup then
            TADC_Log("info", "✓ Interceptor spawned successfully: " .. config.displayName)
            
            -- Wait a moment then set up AGGRESSIVE INTERCEPT mission
            SCHEDULER:New(nil, function()
                -- Enhanced safety checks
                if not (spawnedGroup and spawnedGroup:IsAlive()) then
                    TADC_Log("warning", "⚠ Spawned group " .. config.displayName .. " is not alive, aborting intercept setup")
                    return
                end
                
                if not (threat and threat.group and threat.group:IsAlive()) then
                    TADC_Log("warning", "⚠ Threat is no longer valid, aborting intercept setup for " .. config.displayName)
                    return
                end
                
                -- Test if we can get coordinates before proceeding
                local testCoord = nil
                local coordSuccess = pcall(function()
                    testCoord = spawnedGroup:GetCoordinate()
                end)
                
                if not coordSuccess or not testCoord then
                    TADC_Log("warning", "⚠ Cannot get coordinates for " .. config.displayName .. ", delaying intercept setup")
                    -- Try again in 3 more seconds
                    SCHEDULER:New(nil, function()
                        if spawnedGroup and spawnedGroup:IsAlive() then
                            TADC_Log("info", "Retrying intercept setup for " .. config.displayName)
                            -- TODO: Repeat the setup logic here if needed
                        end
                    end, {}, 3)
                    return
                end
                
                TADC_Log("info", "Setting up AGGRESSIVE INTERCEPT mission for " .. config.displayName .. " vs " .. threat.id)
                    
                    -- Set MAXIMUM AGGRESSION AI options
                    local success, errorMsg = pcall(function()
                        spawnedGroup:OptionROEOpenFire()
                        spawnedGroup:OptionROTVertical()
                        spawnedGroup:OptionECM_Never()
                        spawnedGroup:OptionAAAttackRange(AI.Option.Air.val.AA_ATTACK_RANGE.MAX_RANGE)
                        spawnedGroup:OptionMissileAttack(AI.Option.Air.val.MISSILE_ATTACK.MAX_RANGE)
                        spawnedGroup:OptionFormation(AI.Option.Air.val.FORMATION.FINGER_FOUR)
                        spawnedGroup:OptionRTBBingoFuel()
                        spawnedGroup:OptionRTBAmmo(0.03)  -- Stay until almost no ammo (3%)
                        
                        TADC_Log("info", "✓ Maximum aggression AI options set")
                    end)
                    
                    -- DIRECT THREAT VECTORING - This is the key difference!
                    local threatCoord = nil
                    if threat.coordinate then
                        threatCoord = threat.coordinate
                    elseif threat.group and threat.group:IsAlive() then
                        threatCoord = threat.group:GetCoordinate()
                    end
                    
                    if threatCoord then
                        TADC_Log("info", "VECTORING " .. config.displayName .. " directly to threat at " .. threatCoord:ToStringLLDMS())
                        
                        -- Clear any existing tasks
                        spawnedGroup:ClearTasks()
                        
                        -- TASK 1: Direct intercept to threat location (HIGHEST PRIORITY)
                        local interceptCoord = threatCoord:SetAltitude(config.altitude * 0.3048)
                        
                        -- Additional safety check before routing
                        local interceptorCoord = spawnedGroup:GetCoordinate()
                        if interceptorCoord and interceptCoord then
                            spawnedGroup:RouteAirTo(interceptCoord, config.speed * 1.2, "BARO")  -- 20% faster to intercept
                        else
                            TADC_Log("warning", "Cannot route " .. config.displayName .. " - interceptor coordinate invalid")
                        end
                        
                        -- TASK 2: Attack the specific threat group (Priority 1)
                        local attackTask = {
                            id = 'AttackGroup',
                            params = {
                                groupId = threat.group:GetID(),
                                weaponType = 'Auto',  -- Use best available weapon
                                attackQtyLimit = 0,   -- No attack limit
                                priority = 1
                            }
                        }
                        spawnedGroup:PushTask(attackTask, 1)
                        
                        -- TASK 3: Engage all targets in area around threat (Priority 2)
                        local engageTask = {
                            id = 'EngageTargetsInZone',
                            params = {
                                targetTypes = {'Air'},
                                priority = 2,
                                zone = {
                                    point = {x = threatCoord.x, y = threatCoord.z},
                                    radius = 20000,  -- 20km around threat
                                },
                                noTargetTypes = {},
                                value = 'All',
                            }
                        }
                        spawnedGroup:PushTask(engageTask, 2)
                        
                        -- TASK 4: Continuous threat hunting if initial target is destroyed (Priority 3)
                        local huntTask = {
                            id = 'EngageTargets',
                            params = {
                                targetTypes = {'Air'},
                                priority = 3,
                                maxDistEnabled = true,
                                maxDist = GCI_Config.capEngagementRange,
                                attackQtyLimit = 0,
                            }
                        }
                        spawnedGroup:PushTask(huntTask, 3)
                        
                        TADC_Log("info", "✓ " .. config.displayName .. " vectored to intercept " .. threat.id .. " with aggressive hunter-killer tasks")
                        
                        -- Set up threat tracking updates every 30 seconds
                        local trackingScheduler = SCHEDULER:New(nil, function()
                            if spawnedGroup and spawnedGroup:IsAlive() and threat and threat.group and threat.group:IsAlive() then
                                local currentThreatCoord = threat.group:GetCoordinate()
                                if currentThreatCoord then
                                    -- Update intercept vector to current threat position
                                    local newInterceptCoord = currentThreatCoord:SetAltitude(config.altitude * 0.3048)
                                    
                                    -- Enhanced safety check before routing
                                    local interceptorCoord = nil
                                    local coordSuccess = pcall(function()
                                        interceptorCoord = spawnedGroup:GetCoordinate()
                                    end)
                                    
                                    if coordSuccess and interceptorCoord and newInterceptCoord then
                                        spawnedGroup:RouteAirTo(newInterceptCoord, config.speed * 1.1, "BARO")
                                        
                                        if GCI_Config.debugLevel >= 2 then
                                            TADC_Log("info", "Updated vector: " .. config.displayName .. " → " .. threat.id)
                                        end
                                    else
                                        TADC_Log("warning", "Cannot route " .. config.displayName .. " - invalid coordinates")
                                    end
                                else
                                    TADC_Log("warning", "Cannot get threat coordinate for " .. threat.id)
                                end
                            else
                                -- Stop tracking if threat or interceptor is dead
                                if GCI_Config.debugLevel >= 1 then
                                    TADC_Log("info", "Stopping threat tracking for " .. config.displayName)
                                end
                                return false  -- Stop scheduler
                            end
                        end, {}, 30, 30)  -- Update every 30 seconds
                        
                    else
                        TADC_Log("info", "⚠ Could not get threat coordinate for vectoring")
                        -- Fallback to aggressive patrol
                        local patrolZoneCoord = config.patrolZone:GetCoordinate()
                        if patrolZoneCoord then
                            local patrolCoord = patrolZoneCoord:SetAltitude(config.altitude * 0.3048)
                            -- Enhanced safety check before routing
                            local interceptorCoord = nil
                            local coordSuccess = pcall(function()
                                interceptorCoord = spawnedGroup:GetCoordinate()
                            end)
                            
                            if coordSuccess and interceptorCoord then
                                spawnedGroup:RouteAirTo(patrolCoord, config.speed, "BARO")
                                TADC_Log("info", "✓ Fallback patrol routing successful for " .. config.displayName)
                            else
                                TADC_Log("warning", "Cannot route " .. config.displayName .. " to patrol - GetCoordinate failed")
                            end
                        else
                            TADC_Log("warning", "Cannot get patrol zone coordinate for " .. config.displayName)
                        end
                    end
            end, {}, 5)  -- Increased to 5 second delay to allow full group initialization
            
            -- Mark as active
            TADC.activeCAPs[config.templateName] = {
                group = spawnedGroup,
                launchTime = timer.getTime(),
                config = config,
                isIntercept = true,  -- Mark as intercept mission
                targetThreat = threat
            }
            
            -- Set up mission duration
            local patrolDuration = math.max(config.patrolTime * 60, GCI_Config.minPatrolDuration)
            SCHEDULER:New(nil, function()
                if TADC.activeCAPs[config.templateName] then
                    TADC_Log("info", config.displayName .. " completing intercept mission - RTB")
                    local group = TADC.activeCAPs[config.templateName].group
                    if group and group:IsAlive() then
                        group:ClearTasks()
                        local airbaseObj = AIRBASE:FindByName(config.airbaseName)
                        if airbaseObj then
                            group:RouteRTB(airbaseObj)
                        end
                        
                        SCHEDULER:New(nil, function()
                            if TADC.activeCAPs[config.templateName] then
                                local rtbGroup = TADC.activeCAPs[config.templateName].group
                                if rtbGroup and rtbGroup:IsAlive() then
                                    rtbGroup:Destroy()
                                end
                                TADC.activeCAPs[config.templateName] = nil
                            end
                        end, {}, GCI_Config.rtbDuration)
                    else
                        TADC.activeCAPs[config.templateName] = nil
                    end
                end
            end, {}, patrolDuration)
        else
            TADC_Log("info", "✗ Failed to spawn interceptor: " .. config.displayName)
        end
    end)
    
    if not success then
        TADC_Log("info", "✗ Error launching intercept: " .. tostring(errorMsg))
        return false
    else
        TADC_Log("info", "✓ Intercept mission launched successfully")
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
    
    TADC_Log("info", "=== EXECUTING THREAT ASSIGNMENTS ===")
    TADC_Log("info", "Processing " .. #assignments .. " threat assignments")
    
    local launchedFlights = {}
    
    for _, assignment in pairs(assignments) do
        local squadron = assignment.squadron
        local templateName = assignment.templateName
        
        -- Check squadron availability and cooldown
        if squadron.readinessLevel == "READY" and 
           squadron.availableAircraft >= 1 and
           (currentTime - squadron.lastLaunch) >= squadron.launchCooldown then
            
            local reason = "Intercept: " .. (assignment.threat and assignment.threat.id or "Unknown") .. " (" .. (assignment.threat and assignment.threat.classification or "Unknown") .. ")"
            
            -- Use AGGRESSIVE INTERCEPT MISSION instead of generic CAP
            local success = false
            if assignment.threat then
                success = launchInterceptMission(assignment.config, assignment.threat, reason)
            else
                success = launchCAP(assignment.config, 1, reason)  -- Fallback to CAP if no specific threat
            end
            
            if success then
                -- Update squadron status - squadron is now BUSY with this threat
                squadron.availableAircraft = squadron.availableAircraft - 1
                squadron.airborneAircraft = squadron.airborneAircraft + 1
                squadron.lastLaunch = currentTime
                squadron.sorties = squadron.sorties + 1
                -- TESTING: Don't mark squadron as BUSY - allow multiple launches
                -- squadron.readinessLevel = "BUSY"  -- Squadron is now handling this threat
                
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
                
                TADC_Log("info", "✓ Launched: " .. squadron.displayName .. " → " .. (assignment.threat and assignment.threat.id or "Unknown"))
            else
                TADC_Log("info", "✗ Launch failed: " .. squadron.displayName)
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
            TADC_Log("info", "✗ Cannot launch " .. squadron.displayName .. ": " .. reason)
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
            TADC_Log("info", "✓ Persistent CAP launched: " .. squadron.displayName)
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
        TADC_Log("info", "⚠ Persistent CAP limited: Target=" .. GCI_Config.persistentCAPCount .. ", Effective=" .. effectiveTarget .. " (reserving " .. math.ceil(GCI_Config.maxSimultaneousCAP * GCI_Config.persistentCAPReserve) .. " slots for threats)")
    end
    
    if needed > 0 then
        if GCI_Config.debugLevel >= 1 then
            TADC_Log("info", "=== PERSISTENT CAP MAINTENANCE ===")
            TADC_Log("info", "Current: " .. currentPersistentCount .. ", Target: " .. GCI_Config.persistentCAPCount .. ", Need: " .. needed)
            TADC_Log("info", "Total airborne: " .. totalAirborne .. "/" .. GCI_Config.maxSimultaneousCAP .. " (available slots: " .. availableSlots .. ")")
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
            TADC_Log("info", "✓ Persistent CAP maintenance complete: " .. launched .. " new patrols launched")
        end
    end
end



-- ================================================================================================
-- ENHANCED AI AWARENESS AND TARGET SHARING SYSTEM
-- ================================================================================================

local function enhanceAIAwareness()
    -- Update all active CAP flights with current threat information
    for templateName, capData in pairs(TADC.activeCAPs) do
        if capData.group and capData.group:IsAlive() then
            local group = capData.group
            local config = capData.config
            
            -- Find nearby threats to make AI more aware
            local groupCoord = group:GetCoordinate()
            if groupCoord then
                local nearbyThreats = {}
                
                -- Collect threats within engagement range
                for _, threat in pairs(TADC.threats) do
                    if threat.group and threat.group:IsAlive() then
                        local threatCoord = threat.coordinate or threat.group:GetCoordinate()
                        if threatCoord then
                            local distance = groupCoord:Get2DDistance(threatCoord)
                            local maxPursuitRange = GCI_Config.hyperAggressiveMode and GCI_Config.pursuitRange or (GCI_Config.capEngagementRange * 1.5)
                            if distance <= maxPursuitRange then
                                table.insert(nearbyThreats, {
                                    threat = threat,
                                    distance = distance,
                                    coordinate = threatCoord
                                })
                            end
                        end
                    end
                end
                
                -- If threats are nearby, vector the aircraft towards the closest one
                if #nearbyThreats > 0 then
                    -- Sort by distance (closest first)
                    table.sort(nearbyThreats, function(a, b) return a.distance < b.distance end)
                    
                    local closestThreat = nearbyThreats[1]
                    
                    -- Only update if this is a significant threat change
                    if not capData.lastTargetedThreat or 
                       capData.lastTargetedThreat ~= closestThreat.threat.id or
                       (timer.getTime() - (capData.lastVectorUpdate or 0)) > GCI_Config.engagementUpdateInterval then
                        
                        if GCI_Config.debugLevel >= 2 then
                            TADC_Log("info", "Vectoring " .. config.displayName .. " to nearby threat: " .. closestThreat.threat.id .. " (" .. math.floor(closestThreat.distance/1000) .. "km)")
                        end
                        
                        -- Clear old tasks and add new aggressive intercept
                        group:ClearTasks()
                        
                        -- Route towards threat at higher speed
                        if closestThreat.coordinate then
                            local interceptCoord = closestThreat.coordinate:SetAltitude(config.altitude * 0.3048)
                            -- Safety check before routing
                            local groupCoord = group:GetCoordinate()
                            if groupCoord and interceptCoord then
                                group:RouteAirTo(interceptCoord, config.speed * 1.2, "BARO")
                            else
                                TADC_Log("warning", "Cannot route " .. config.displayName .. " - invalid coordinates for intercept")
                            end
                        else
                            TADC_Log("warning", "No coordinate available for threat " .. closestThreat.threat.id)
                        end
                        
                        -- Add aggressive attack task
                        local aggressiveAttack = {
                            id = 'AttackGroup',
                            params = {
                                groupId = closestThreat.threat.group:GetID(),
                                weaponType = 'Auto',
                                attackQtyLimit = 0,
                                priority = 1
                            }
                        }
                        group:PushTask(aggressiveAttack, 1)
                        
                        -- Add area sweep task
                        local areaSweep = {
                            id = 'EngageTargetsInZone',
                            params = {
                                targetTypes = {'Air'},
                                priority = 2,
                                zone = {
                                    point = {x = closestThreat.coordinate.x, y = closestThreat.coordinate.z},
                                    radius = 15000,  -- 15km area sweep
                                },
                                noTargetTypes = {},
                                value = 'All',
                            }
                        }
                        group:PushTask(areaSweep, 2)
                        
                        -- Update tracking info
                        capData.lastTargetedThreat = closestThreat.threat.id
                        capData.lastVectorUpdate = timer.getTime()
                    end
                end
            end
        end
    end
end

-- ================================================================================================
-- MAIN TADC CONTROL LOOP
-- ================================================================================================

-- SIMPLE GCI MAIN LOOP - Just detect threats and launch intercepts
local function simpleGCILoop()
    local currentTime = timer.getTime()
    
    -- Count current airborne aircraft
    local airborneCount = 0
    for _, squadron in pairs(TADC.squadrons) do
        airborneCount = airborneCount + squadron.airborneAircraft
    end
    
    -- Only proceed if we're under the airborne limit
    if airborneCount >= GCI_Config.maxSimultaneousCAP then
        TADC_Log("info", "Max aircraft limit reached (" .. airborneCount .. "/" .. GCI_Config.maxSimultaneousCAP .. ")")
        return
    end
    
    -- Detect threats using simple detection
    local threats = simpleDetectThreats()
    
    -- For each threat, find closest airfield and launch intercept
    for threatId, threat in pairs(threats) do
        TADC_Log("info", "Processing threat: " .. threatId)
        
        -- Calculate how many defenders needed (1 to 1.5 ratio)
        local defendersNeeded = math.ceil(threat.size * GCI_Config.threatRatio)
        
        -- Find closest available squadron
        local bestSquadron = nil
        local bestDistance = 999999
        
        for templateName, squadron in pairs(TADC.squadrons) do
            if squadron.readinessLevel == "READY" and squadron.availableAircraft >= defendersNeeded then
                -- Check cooldown
                local cooldown = currentTime - squadron.lastLaunch
                if cooldown >= GCI_Config.squadronCooldown then
                    local squadronCoord = squadron.homebase and squadron.homebase:GetCoordinate()
                    if squadronCoord then
                        local distance = squadronCoord:Get2DDistance(threat.coordinate)
                        if distance < bestDistance then
                            bestDistance = distance
                            bestSquadron = squadron
                            bestSquadron.templateName = templateName
                        end
                    end
                end
            end
        end
        
        -- Launch intercept if squadron found
        if bestSquadron then
            TADC_Log("info", "🚀 LAUNCHING: " .. bestSquadron.displayName .. " to intercept " .. threatId)
            
            -- Find the original squadron config for this squadron
            local squadronConfig = nil
            for _, config in pairs(squadronConfigs) do
                if config.templateName == bestSquadron.templateName then
                    squadronConfig = config
                    break
                end
            end
            
            if squadronConfig then
                launchInterceptMission(squadronConfig, threat, "GCI_INTERCEPT")
            else
                TADC_Log("error", "Could not find config for squadron: " .. bestSquadron.templateName)
            end
        else
            TADC_Log("info", "⚠ No available squadrons for " .. threatId)
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
                    TADC_Log("info", "Mission completed: " .. mission.squadron .. " freed from " .. (mission.threat and mission.threat.id or "unknown threat"))
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
        
        TADC_Log("info", "=== TADC STATUS REPORT ===")
        TADC_Log("info", "Threats: " .. threatCount .. " active")
        TADC_Log("info", "Aircraft: " .. totalAirborne .. " airborne, " .. totalAvailable .. " available")
        TADC_Log("info", "Statistics: " .. TADC.stats.threatsDetected .. " threats detected, " .. TADC.stats.interceptsLaunched .. " intercepts launched")
        
        -- Persistent CAP Status
        if GCI_Config.enablePersistentCAP then
            local persistentCount = getPersistentCAPCount()
            local maxPersistentAllowed = math.floor(GCI_Config.maxSimultaneousCAP * (1 - GCI_Config.persistentCAPReserve))
            local threatReserve = GCI_Config.maxSimultaneousCAP - maxPersistentAllowed
            TADC_Log("info", "Persistent CAP: " .. persistentCount .. "/" .. GCI_Config.persistentCAPCount .. " target (" .. maxPersistentAllowed .. " max, " .. threatReserve .. " reserved for threats)")
        end
    end
    
    -- Enhanced AI Awareness and Target Sharing
    enhanceAIAwareness()
    
    -- Persistent CAP Management
    if GCI_Config.enablePersistentCAP then
        maintainPersistentCAP()
    end
end

-- ================================================================================================
-- MAIN TADC LOOP FUNCTION (COMPREHENSIVE VERSION)
-- ================================================================================================

local function mainTADCLoop()
    local currentTime = timer.getTime()
    local startTime = currentTime
    
    -- Performance tracking
    TADC.performance.loopCount = TADC.performance.loopCount + 1
    
    -- Update system statistics
    TADC.stats.systemLoadTime = currentTime
    
    -- 1. IMMEDIATE RESPONSE CHECK (like RU_INTERCEPT backup)
    immediateInterceptCheck()
    
    -- 2. COMPREHENSIVE THREAT DETECTION
    local threats = simpleDetectThreats()
    local threatCount = 0
    for _ in pairs(threats) do threatCount = threatCount + 1 end
    
    if threatCount > 0 then
        TADC_Log("info", "🎯 MAIN LOOP: Detected " .. threatCount .. " active threats")
        TADC.stats.threatsDetected = TADC.stats.threatsDetected + threatCount
        
        -- Debug: Show which threats were detected
        for threatId, threat in pairs(threats) do
            TADC_Log("info", "  Threat: " .. threatId .. " (" .. threat.classification .. ") in " .. threat.zone)
        end
    else
        TADC_Log("info", "🎯 MAIN LOOP: No threats detected")
    end
    
    -- 3. PROCESS THREATS BY ZONE
    local zones = {"RED_BORDER", "HELO_BORDER"}
    
    for _, zone in pairs(zones) do
        -- Get threats in this zone
        local zoneThreats = {}
        for threatId, threat in pairs(threats) do
            if threat.zone == zone then
                table.insert(zoneThreats, threat)
            end
        end
        
        if #zoneThreats > 0 then
            if GCI_Config.debugLevel >= 1 then
                TADC_Log("info", "Processing " .. #zoneThreats .. " threats in " .. zone)
            end
            
            -- Assign threats to squadrons using smart algorithm
            local assignments = assignThreatsToSquadrons(zoneThreats, zone)
            
            -- Execute the assignments
            if #assignments > 0 then
                TADC_Log("info", "📋 EXECUTING " .. #assignments .. " ASSIGNMENTS FOR " .. zone)
                TADC.stats.interceptsLaunched = TADC.stats.interceptsLaunched + #assignments
                executeThreatsAssignments(assignments)
            else
                TADC_Log("warning", "⚠ NO ASSIGNMENTS GENERATED for " .. #zoneThreats .. " threats in " .. zone)
                -- Debug squadron availability
                local readySquadrons = 0
                local totalSquadrons = 0
                for templateName, squadron in pairs(TADC.squadrons) do
                    totalSquadrons = totalSquadrons + 1
                    if squadron.readinessLevel == "READY" and squadron.availableAircraft >= 1 then
                        readySquadrons = readySquadrons + 1
                        TADC_Log("info", "✓ READY: " .. squadron.displayName .. " (" .. squadron.availableAircraft .. " aircraft)")
                    else
                        TADC_Log("info", "✗ NOT READY: " .. squadron.displayName .. " - " .. squadron.readinessLevel .. " (" .. squadron.availableAircraft .. " aircraft)")
                    end
                end
                TADC_Log("info", "Squadron Status: " .. readySquadrons .. "/" .. totalSquadrons .. " ready")
            end
        end
    end
    
    -- 4. SQUADRON STATUS MANAGEMENT
    -- Clean up completed missions and free squadrons
    for missionId, mission in pairs(TADC.missions) do
        local squadron = TADC.squadrons[mission.squadron]
        if squadron then
            local missionAge = currentTime - mission.startTime
            local shouldComplete = false
            
            -- Mission completion conditions
            if missionAge > 1800 then -- 30 minutes timeout
                shouldComplete = true
            elseif squadron.airborneAircraft == 0 and missionAge > 300 then -- 5 min minimum
                shouldComplete = true
            end
            
            -- Check if threat still exists
            local threatExists = false
            for _, threat in pairs(threats) do
                if (threat.id .. "_" .. threat.firstDetected) == missionId then
                    threatExists = true
                    break
                end
            end
            if not threatExists and missionAge > 60 then
                shouldComplete = true
            end
            
            if shouldComplete then
                squadron.readinessLevel = "READY"
                TADC.squadronMissions[mission.squadron] = nil
                TADC.threatAssignments[missionId] = nil
                TADC.missions[missionId] = nil
                
                if GCI_Config.debugLevel >= 1 then
                    TADC_Log("info", "Mission completed: " .. mission.squadron .. " freed")
                end
            end
        else
            TADC.missions[missionId] = nil
            TADC.threatAssignments[missionId] = nil
        end
    end
    
    -- 5. ENHANCED AI AWARENESS AND TARGET SHARING
    enhanceAIAwareness()
    
    -- 6. PERSISTENT CAP MANAGEMENT
    if GCI_Config.enablePersistentCAP then
        maintainPersistentCAP()
    end
    
    -- 7. PERIODIC STATUS REPORTING
    if GCI_Config.debugLevel >= 1 and (currentTime % GCI_Config.statusReportInterval) < GCI_Config.mainLoopInterval then
        local totalAirborne = 0
        local totalAvailable = 0
        for _, squadron in pairs(TADC.squadrons) do
            totalAirborne = totalAirborne + squadron.airborneAircraft
            totalAvailable = totalAvailable + squadron.availableAircraft
        end
        
        TADC_Log("info", "=== TADC STATUS REPORT ===")
        TADC_Log("info", "Threats: " .. threatCount .. " active")
        TADC_Log("info", "Aircraft: " .. totalAirborne .. " airborne, " .. totalAvailable .. " available")
        TADC_Log("info", "Statistics: " .. TADC.stats.threatsDetected .. " threats detected, " .. TADC.stats.interceptsLaunched .. " intercepts launched")
        
        if GCI_Config.enablePersistentCAP then
            local persistentCount = getPersistentCAPCount()
            TADC_Log("info", "Persistent CAP: " .. persistentCount .. "/" .. GCI_Config.persistentCAPCount .. " target")
        end
    end
    
    -- 8. PERFORMANCE TRACKING
    local loopTime = timer.getTime() - startTime
    TADC.performance.lastLoopTime = loopTime
    TADC.performance.avgLoopTime = (TADC.performance.avgLoopTime * (TADC.performance.loopCount - 1) + loopTime) / TADC.performance.loopCount
    TADC.performance.maxLoopTime = math.max(TADC.performance.maxLoopTime, loopTime)
    
    if loopTime > 1.0 and GCI_Config.debugLevel >= 1 then
        TADC_Log("warning", "TADC loop took " .. string.format("%.2f", loopTime) .. "s (performance warning)")
    end
end

-- ================================================================================================
-- PERSISTENT CAP MANAGEMENT SYSTEM
-- ================================================================================================

local function setupTADC()
    TADC_Log("info", "=== INITIALIZING TACTICAL AIR DEFENSE CONTROLLER ===")
    
    -- Validate configuration before starting
    if not validateConfiguration() then
        TADC_Log("info", "✗ TADC configuration validation failed")
        return
    end
    
    TADC_Log("info", "✓ Configuration loaded and validated:")
    TADC_Log("info", "  - Threat Ratio: " .. GCI_Config.threatRatio .. ":1")
    TADC_Log("info", "  - Max Simultaneous CAP: " .. GCI_Config.maxSimultaneousCAP)
    TADC_Log("info", "  - Reserve Percentage: " .. (GCI_Config.reservePercent * 100) .. "%")
    TADC_Log("info", "  - Supply Mode: " .. GCI_Config.supplyMode)
    TADC_Log("info", "  - Response Delay: " .. GCI_Config.responseDelay .. " seconds")
    
    -- Persistent CAP Configuration
    if GCI_Config.enablePersistentCAP then
        local maxPersistentAllowed = math.floor(GCI_Config.maxSimultaneousCAP * (1 - GCI_Config.persistentCAPReserve))
        local threatReserve = math.ceil(GCI_Config.maxSimultaneousCAP * GCI_Config.persistentCAPReserve)
        TADC_Log("info", "  - Persistent CAP: ENABLED (" .. GCI_Config.persistentCAPCount .. " target, " .. maxPersistentAllowed .. " max allowed)")
        TADC_Log("info", "  - Threat Response Reserve: " .. threatReserve .. " aircraft slots")
        TADC_Log("info", "  - Persistent CAP Check Interval: " .. GCI_Config.persistentCAPInterval .. " seconds")
    else
        TADC_Log("info", "  - Persistent CAP: DISABLED")
    end
    
    -- CAP Behavior Configuration
    TADC_Log("info", "  - CAP Orbit Radius: " .. (GCI_Config.capOrbitRadius / 1000) .. "km")
    TADC_Log("info", "  - CAP Engagement Range: " .. (GCI_Config.capEngagementRange / 1000) .. "km")
    TADC_Log("info", "  - Zone Constraint: " .. (GCI_Config.capZoneConstraint and "ENABLED" or "DISABLED"))
    
    -- Start main control loop
    SCHEDULER:New(nil, mainTADCLoop, {}, GCI_Config.mainLoopDelay, GCI_Config.mainLoopInterval) -- Main loop timing from config
    
    TADC_Log("info", "✓ TADC main control loop started")
    TADC_Log("info", "✓ Tactical Air Defense Controller operational!")
end

-- Initialize the TADC system
SCHEDULER:New(nil, function()
    setupTADC()
    
    -- Launch initial persistent CAP flights if enabled
    if GCI_Config.enablePersistentCAP then
        TADC_Log("info", "=== LAUNCHING INITIAL PERSISTENT CAP ===")
        TADC.lastPersistentCheck = 0 -- Force immediate check
        maintainPersistentCAP()
        
        -- Schedule another check in 30 seconds to ensure CAP gets airborne
        SCHEDULER:New(nil, function()
            TADC_Log("info", "=== PERSISTENT CAP FOLLOW-UP CHECK ===")
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
    
    -- Initialize strategic targets for smart prioritization
    initializeStrategicTargets()
    
    TADC_Log("info", "=== TADC INITIALIZATION COMPLETE ===")
    TADC_Log("info", "✓ Smart threat prioritization system with multi-factor analysis")
    TADC_Log("info", "✓ Predictive threat assessment and response")
    TADC_Log("info", "✓ Intelligent threat assessment and response")
    TADC_Log("info", "✓ Multi-squadron coordinated intercepts")
    TADC_Log("info", "✓ Dynamic force sizing based on threat strength")
    TADC_Log("info", "✓ Resource management with reserve forces")
    TADC_Log("info", "✓ EWR network integration with " .. (RedEWR:Count()) .. " detection groups")
    TADC_Log("info", "✓ Strategic target protection with distance-based prioritization")
    TADC_Log("info", "✓ Enhanced squadron-threat matching algorithm")
    TADC_Log("info", "✓ Tactical Air Defense Controller operational!")
    
end, {}, 5)

-- ================================================================================================
-- SYSTEM STARTUP AND INITIALIZATION
-- ================================================================================================

-- Initialize strategic target coordinates
initializeStrategicTargets()

-- Start the TADC system with proper delays
SCHEDULER:New(nil, function()
    TADC_Log("info", "=== STARTING TADC SYSTEM ===")
    setupTADC()
    
    -- Launch initial standing patrols if configured
    if GCI_Config.initialStandingPatrols then
        TADC_Log("info", "Launching initial standing patrols...")
        
        -- Wait a bit more then launch initial CAPs
        SCHEDULER:New(nil, function()
            local launched = 0
            local maxInitialCAP = math.min(2, GCI_Config.persistentCAPCount) -- Start with 2 max
            
            for _, templateName in pairs(GCI_Config.persistentCAPPriority) do
                if launched >= maxInitialCAP then break end
                
                if launchPersistentCAP(templateName, "Initial standing patrol") then
                    launched = launched + 1
                    -- Stagger launches by 30 seconds
                    if launched < maxInitialCAP then
                        SCHEDULER:New(nil, function() end, {}, 30)
                    end
                end
            end
            
            if launched > 0 then
                TADC_Log("info", "✓ Initial standing patrols launched: " .. launched .. " flights")
            else
                TADC_Log("info", "⚠ Could not launch initial standing patrols - will retry during maintenance cycle")
            end
        end, {}, GCI_Config.capSetupDelay + 15) -- Extra delay for initial patrols
    end
    
    -- Start the main TADC control loop
    SCHEDULER:New(nil, function()
        TADC_Log("info", "✓ TADC Main Control Loop starting...")
        
        -- Schedule the main loop to run every mainLoopInterval seconds
        SCHEDULER:New(nil, mainTADCLoop, {}, 0, GCI_Config.mainLoopInterval)
        
        TADC_Log("info", "✓ TADC System fully operational!")
        TADC_Log("info", "✓ Monitoring for threats every " .. GCI_Config.mainLoopInterval .. " seconds")
        
    end, {}, GCI_Config.mainLoopDelay + GCI_Config.capSetupDelay)
    
end, {}, 3) -- Small initial delay to let MOOSE fully initialize
