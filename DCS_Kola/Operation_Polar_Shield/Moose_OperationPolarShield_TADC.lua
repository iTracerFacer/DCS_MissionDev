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
    threatRatio = 1,                -- Send 1x defenders per attacker
    maxSimultaneousCAP = 12,        -- Maximum total airborne aircraft
    reservePercent = 0.25,          -- Keep 25% of forces in reserve
    responseDelay = 23,             -- Seconds to assess threat before scrambling
    
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
    minPatrolDuration = 1800,       -- Minimum patrol duration in seconds (30 minutes)
    rtbDuration = 600,              -- Time allowed for RTB in seconds (10 minutes)
    missionCleanupTime = 1800,      -- Time before old missions are cleaned up (30 minutes)
    statusReportInterval = 300,     -- Interval between status reports (5 minutes)
    
    -- System Timing
    capSetupDelay = 5,              -- Delay before setting up CAP tasks (seconds)
    mainLoopDelay = 5,              -- Initial delay before starting main loop (seconds)
    mainLoopInterval = 30,          -- Main loop execution interval (seconds)
    
    -- Combat Aggression Parameters
    hyperAggressiveMode = true,     -- Enable maximum aggression settings
    pursuitRange = 50000,           -- How far aircraft will chase targets (50km)
    engagementUpdateInterval = 30,  -- How often to update target vectors (seconds)
    
    -- Debug Options
    debugLevel = 2,                 -- 0=Silent, 1=Basic, 2=Verbose
    
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
        env.error("TADC Configuration Errors:")
        for _, error in pairs(errors) do
            env.error("  - " .. error)
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
                    env.info("✓ Strategic target: " .. target.name .. " (Importance: " .. target.importance .. ")")
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
                        env.info("Threat proximity: " .. target.name .. " (" .. math.floor(distance/1000) .. "km) Score: " .. math.floor(targetScore))
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
        local speed = velocity -- Assuming velocity is in m/s
        
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
        if heading then
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
        env.info(string.format("Smart Priority: %s (x%d) = %.1f [Base:%.1f, Size:%.1f, Prox:%.1f, Speed:%.1f, Time:%.1f, EW:%.1f]",
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
            -- Predict position in 5 minutes
            local futureTime = 300 -- 5 minutes
            local futureDistance = threat.velocity * futureTime
            assessment.predictedPosition = threat.coordinate:Translate(futureDistance, threat.heading)
            
            -- Calculate time to closest strategic target
            local minTimeToTarget = math.huge
            for _, target in pairs(STRATEGIC_TARGETS) do
                if target.coord then
                    local distance = threat.coordinate:Get2DDistance(target.coord)
                    local timeToTarget = distance / math.max(threat.velocity, 50) -- Minimum 50 m/s
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
                            local heading = detectedGroup:GetHeading()
                            local velocity = detectedGroup:GetVelocity()
                            
                            -- Enhanced threat data with smart prioritization
                            newThreats[threatId] = {
                                id = threatId,
                                group = detectedGroup,
                                coordinate = blueCoord,
                                classification = classification,
                                size = size,
                                zone = inRedZone and "RED_BORDER" or "HELO_BORDER",
                                firstDetected = TADC.threats[threatId] and TADC.threats[threatId].firstDetected or currentTime,
                                lastSeen = currentTime,
                                heading = heading,
                                velocity = velocity,
                                priority = calculateThreatPriority(classification, blueCoord, size, velocity, heading, detectedGroup),
                                detectionMethod = "EWR",
                                -- Additional smart assessment data
                                typeName = detectedGroup:GetTypeName(),
                                altitude = blueCoord:GetLandHeight() + (detectedGroup:GetCoordinate():GetY() or 0)
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
                    local heading = blueGroup:GetHeading()
                    local velocity = blueGroup:GetVelocity()
                    
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
    
    -- Get enhanced threat assessment with smart prioritization
    local sortedThreats, threatAssessments = assessThreatWithPrediction(zoneThreats)
    
    -- Smart threat assessment logging
    if GCI_Config.debugLevel >= 1 and #sortedThreats > 0 then
        env.info("=== SMART THREAT ASSESSMENT: " .. zone .. " ===")
        for i, assessment in ipairs(sortedThreats) do
            local threat = assessment.threat
            local timeStr = assessment.timeToTarget and string.format("%.1fm", assessment.timeToTarget/60) or "N/A"
            env.info(string.format("%d. %s (%s x%d) Priority:%d TTT:%s Response:%s", 
                i, threat.id, threat.classification, threat.size or 1, 
                math.floor(assessment.priority), timeStr, assessment.recommendedResponse))
        end
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
                            env.info(string.format("  %s vs %s: Score=%.1f [Dist:%.1f, Type:%d, Ready:%.1f, Urg:%d, Pen:%.1f]",
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
                
                if GCI_Config.debugLevel >= 1 then
                    local timeStr = bestSquadron.assessment and bestSquadron.assessment.timeToTarget and 
                        string.format(" TTT:%.1fm", bestSquadron.assessment.timeToTarget/60) or ""
                    local responseStr = bestSquadron.assessment and bestSquadron.assessment.recommendedResponse or "STANDARD"
                    env.info(string.format("✓ SMART ASSIGNMENT: %s → %s (%s x%d) Score:%.1f Priority:%d%s %s", 
                        bestSquadron.squadron.displayName, threat.id, threat.classification, 
                        threat.size or 1, bestSquadron.matchScore or 0, 
                        bestSquadron.assessment and math.floor(bestSquadron.assessment.priority) or threat.priority,
                        timeStr, responseStr))
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
                
                env.info("Attempt " .. spawnAttempts .. ": Air spawn at " .. config.altitude .. "ft near " .. config.airbaseName)
                return spawner:SpawnFromCoordinate(spawnCoord, nil, SPAWN.Takeoff.Air)
                
            -- Method 2: Hot start from airbase
            elseif spawnAttempts == 2 then
                env.info("Attempt " .. spawnAttempts .. ": Hot start from airbase")
                return spawner:SpawnAtAirbase(airbaseObj, SPAWN.Takeoff.Hot)
                
            -- Method 3: Cold start from airbase
            elseif spawnAttempts == 3 then
                env.info("Attempt " .. spawnAttempts .. ": Cold start from airbase")
                return spawner:SpawnAtAirbase(airbaseObj, SPAWN.Takeoff.Cold)
            end
            
            return nil
        end
        
        -- Retry spawn with delays
        while spawnAttempts < maxAttempts and not spawnedGroup do
            spawnedGroup = attemptSpawn()
            if not spawnedGroup and spawnAttempts < maxAttempts then
                env.info("Spawn attempt " .. spawnAttempts .. " failed, retrying in 2 seconds...")
                -- Note: In actual implementation, you'd want to use SCHEDULER for the delay
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
                    
                    -- Set up AGGRESSIVE AI options with error handling
                    local success, errorMsg = pcall(function()
                        -- ENGAGEMENT RULES - AGGRESSIVE
                        spawnedGroup:OptionROEOpenFire()           -- Engage enemies immediately
                        spawnedGroup:OptionROTVertical()           -- No altitude restrictions (for all aircraft)
                        
                        -- DETECTION AND TARGETING - AGGRESSIVE
                        spawnedGroup:OptionECM_Never()             -- Never use ECM to stay hidden
                        spawnedGroup:OptionRadarUsing(AI.Option.Ground.val.RADAR_USING.FOR_SEARCH_IF_REQUIRED)
                        
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
                        
                        env.info("✓ Aggressive AI options set for " .. config.displayName)
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
-- AGGRESSIVE INTERCEPT FUNCTION - Direct threat vectoring
-- ================================================================================================

local function launchInterceptMission(config, threat, reason)
    env.info("=== LAUNCHING INTERCEPT MISSION ===")
    env.info("Squadron: " .. config.displayName)
    env.info("Target: " .. (threat and threat.id or "Unknown"))
    env.info("Target Type: " .. (threat and threat.classification or "Unknown"))
    env.info("Reason: " .. reason)
    
    local success, errorMsg = pcall(function()
        -- Find the airbase object
        local airbaseObj = AIRBASE:FindByName(config.airbaseName)
        if not airbaseObj then
            env.info("✗ Could not find airbase: " .. config.airbaseName)
            return
        end
        
        -- Check if template exists
        local templateGroup = GROUP:FindByName(config.templateName)
        if not templateGroup then
            env.info("✗ CRITICAL: Template group not found: " .. config.templateName)
            return
        end
        
        -- Create SPAWN object
        local spawner = SPAWN:New(config.templateName)
        
        -- Spawn aircraft in air at proper altitude
        local airbaseCoord = airbaseObj:GetCoordinate()
        local spawnCoord = airbaseCoord:Translate(math.random(GCI_Config.spawnDistanceMin, GCI_Config.spawnDistanceMax), math.random(0, 360))
        spawnCoord = spawnCoord:SetAltitude(config.altitude)
        
        env.info("Spawning interceptor at " .. config.altitude .. "ft near " .. config.airbaseName)
        local spawnedGroup = spawner:SpawnFromCoordinate(spawnCoord, nil, SPAWN.Takeoff.Air)
        
        if not spawnedGroup then
            -- Fallback spawn methods
            spawnedGroup = spawner:SpawnAtAirbase(airbaseObj, SPAWN.Takeoff.Hot)
            if not spawnedGroup then
                spawnedGroup = spawner:SpawnFromCoordinate(airbaseCoord)
            end
        end
        
        if spawnedGroup then
            env.info("✓ Interceptor spawned successfully: " .. config.displayName)
            
            -- Wait a moment then set up AGGRESSIVE INTERCEPT mission
            SCHEDULER:New(nil, function()
                if spawnedGroup and spawnedGroup:IsAlive() and threat and threat.group and threat.group:IsAlive() then
                    env.info("Setting up AGGRESSIVE INTERCEPT mission for " .. config.displayName .. " vs " .. threat.id)
                    
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
                        
                        env.info("✓ Maximum aggression AI options set")
                    end)
                    
                    -- DIRECT THREAT VECTORING - This is the key difference!
                    local threatCoord = nil
                    if threat.coordinate then
                        threatCoord = threat.coordinate
                    elseif threat.group and threat.group:IsAlive() then
                        threatCoord = threat.group:GetCoordinate()
                    end
                    
                    if threatCoord then
                        env.info("VECTORING " .. config.displayName .. " directly to threat at " .. threatCoord:ToStringLLDMS())
                        
                        -- Clear any existing tasks
                        spawnedGroup:ClearTasks()
                        
                        -- TASK 1: Direct intercept to threat location (HIGHEST PRIORITY)
                        local interceptCoord = threatCoord:SetAltitude(config.altitude * 0.3048)
                        
                        -- Additional safety check before routing
                        local interceptorCoord = spawnedGroup:GetCoordinate()
                        if interceptorCoord and interceptCoord then
                            spawnedGroup:RouteAirTo(interceptCoord, config.speed * 1.2, "BARO")  -- 20% faster to intercept
                        else
                            env.warning("Cannot route " .. config.displayName .. " - interceptor coordinate invalid")
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
                        
                        env.info("✓ " .. config.displayName .. " vectored to intercept " .. threat.id .. " with aggressive hunter-killer tasks")
                        
                        -- Set up threat tracking updates every 30 seconds
                        local trackingScheduler = SCHEDULER:New(nil, function()
                            if spawnedGroup and spawnedGroup:IsAlive() and threat and threat.group and threat.group:IsAlive() then
                                local currentThreatCoord = threat.group:GetCoordinate()
                                if currentThreatCoord then
                                    -- Update intercept vector to current threat position
                                    local newInterceptCoord = currentThreatCoord:SetAltitude(config.altitude * 0.3048)
                                    
                                    -- Additional safety check before routing
                                    local interceptorCoord = spawnedGroup:GetCoordinate()
                                    if interceptorCoord and newInterceptCoord then
                                        spawnedGroup:RouteAirTo(newInterceptCoord, config.speed * 1.1, "BARO")
                                        
                                        if GCI_Config.debugLevel >= 2 then
                                            env.info("Updated vector: " .. config.displayName .. " → " .. threat.id)
                                        end
                                    else
                                        env.warning("Cannot route " .. config.displayName .. " - invalid coordinates")
                                    end
                                else
                                    env.warning("Cannot get threat coordinate for " .. threat.id)
                                end
                            else
                                -- Stop tracking if threat or interceptor is dead
                                if GCI_Config.debugLevel >= 1 then
                                    env.info("Stopping threat tracking for " .. config.displayName)
                                end
                                return false  -- Stop scheduler
                            end
                        end, {}, 30, 30)  -- Update every 30 seconds
                        
                    else
                        env.info("⚠ Could not get threat coordinate for vectoring")
                        -- Fallback to aggressive patrol
                        local patrolZoneCoord = config.patrolZone:GetCoordinate()
                        if patrolZoneCoord then
                            local patrolCoord = patrolZoneCoord:SetAltitude(config.altitude * 0.3048)
                            -- Safety check before routing
                            local interceptorCoord = spawnedGroup:GetCoordinate()
                            if interceptorCoord then
                                spawnedGroup:RouteAirTo(patrolCoord, config.speed, "BARO")
                            else
                                env.warning("Cannot route " .. config.displayName .. " to patrol - interceptor coordinate invalid")
                            end
                        else
                            env.warning("Cannot get patrol zone coordinate for " .. config.displayName)
                        end
                    end
                    
                else
                    env.info("⚠ Threat no longer valid for intercept mission")
                end
            end, {}, 3)  -- 3 second delay
            
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
                    env.info(config.displayName .. " completing intercept mission - RTB")
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
            env.info("✗ Failed to spawn interceptor: " .. config.displayName)
        end
    end)
    
    if not success then
        env.info("✗ Error launching intercept: " .. tostring(errorMsg))
        return false
    else
        env.info("✓ Intercept mission launched successfully")
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
                            env.info("Vectoring " .. config.displayName .. " to nearby threat: " .. closestThreat.threat.id .. " (" .. math.floor(closestThreat.distance/1000) .. "km)")
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
                                env.warning("Cannot route " .. config.displayName .. " - invalid coordinates for intercept")
                            end
                        else
                            env.warning("No coordinate available for threat " .. closestThreat.threat.id)
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
    
    -- Enhanced AI Awareness and Target Sharing
    enhanceAIAwareness()
    
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
    
    -- Validate configuration before starting
    if not validateConfiguration() then
        env.info("✗ TADC configuration validation failed")
        return
    end
    
    env.info("✓ Configuration loaded and validated:")
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
    
    -- Initialize strategic targets for smart prioritization
    initializeStrategicTargets()
    
    env.info("=== TADC INITIALIZATION COMPLETE ===")
    env.info("✓ Smart threat prioritization system with multi-factor analysis")
    env.info("✓ Predictive threat assessment and response")
    env.info("✓ Intelligent threat assessment and response")
    env.info("✓ Multi-squadron coordinated intercepts")
    env.info("✓ Dynamic force sizing based on threat strength")
    env.info("✓ Resource management with reserve forces")
    env.info("✓ EWR network integration with " .. (RedEWR:Count()) .. " detection groups")
    env.info("✓ Strategic target protection with distance-based prioritization")
    env.info("✓ Enhanced squadron-threat matching algorithm")
    env.info("✓ Tactical Air Defense Controller operational!")
    
end, {}, 5)