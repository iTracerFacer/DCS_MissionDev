--[[
═══════════════════════════════════════════════════════════════════════════════
                              UNIVERSAL TADC
                  Dual-Coalition Tactical Air Defense Controller
                           Advanced Zone-Based System
═══════════════════════════════════════════════════════════════════════════════

DESCRIPTION:
This script provides a sophisticated automated air defense system for BOTH RED and 
BLUE coalitions operating independently. Features advanced zone-based area of 
responsibility (AOR) management, allowing squadrons to respond differently based 
on threat location and priority levels. Perfect for complex scenarios requiring 
realistic air defense behavior and tactical depth.

CORE FEATURES:
• Dual-coalition support with completely independent operation
• Advanced zone-based area of responsibility system (Primary/Secondary/Tertiary)
• Automatic threat detection with intelligent interceptor allocation
• Multi-squadron management with individual cooldowns and aircraft tracking
• Dynamic cargo aircraft replenishment system
• Configurable intercept ratios with zone-specific response modifiers
• Smart interceptor routing, engagement, and RTB (Return to Base) behavior
• Real-time airbase status monitoring (operational/captured/destroyed)
• Comprehensive configuration validation and error reporting
• Asymmetric warfare support with coalition-specific capabilities
• Emergency cleanup systems and safety nets for mission stability

ADVANCED ZONE SYSTEM:
Each squadron can be configured with up to three zone types:
• PRIMARY ZONE: Main area of responsibility (full response ratio)
• SECONDARY ZONE: Support area (reduced response, optional low-priority filtering)
• TERTIARY ZONE: Emergency/fallback area (enhanced response when base threatened)
• Squadrons will respond based on threat location relative to their zones
• Zone-specific response modifiers can be configured for each squadron
• Zones may overlap between squadrons for layered defense.  

ADVANCED ZONE SETUP:
• Create zones in the mission editor (MOOSE polygons, circles, etc.)
• Assign zone names to squadrons in the configuration (exact match required)
• Leave zones as nil for global threat response (no zone restrictions)
• Each zone is defined by placing a helicopter group with waypoints outlining the area
• The script will create polygon zones from the helicopter waypoints automatically

Zone response behaviors include:
• Distance-based engagement limits (max range from airbase)
• Priority thresholds for threat classification (major vs minor threats)
• Fallback conditions (auto-switch to tertiary when squadron weakened)
• Response ratio multipliers per zone type
• Low-priority threat filtering in secondary zones

REPLENISHMENT SYSTEM:
• Automated cargo aircraft detection system that monitors for transport aircraft
  landings to replenish squadron aircraft counts (fixed wing only):
• Detects cargo aircraft by name patterns (CARGO, TRANSPORT, C130, C-130, AN26, AN-26)
• Monitors landing status based on velocity and proximity to friendly airbases
• Replenishes squadron aircraft up to maximum capacity per airbase
• Prevents duplicate processing of the same cargo delivery
• Coalition-specific replenishment amounts configurable independently
• Supports sustained operations over extended mission duration

*** This system does not spawn or manage cargo aircraft - it only detects when
your existing cargo aircraft complete deliveries. Create and route your own
transport missions to maintain squadron strength. ***

INTERCEPT RATIO SYSTEM:
Sophisticated threat response calculation with zone-based modifiers:
• Base intercept ratio (e.g., 0.8 = 8 interceptors per 10 threats)
• Zone-specific multipliers (primary: 1.0, secondary: 0.6, tertiary: 1.4)
• Threat size considerations (larger formations get proportional response)
• Squadron selection based on zone priority and proximity
• Aircraft availability and cooldown status factored into decisions

SETUP INSTRUCTIONS:
1. Load MOOSE framework in mission before this script
2. Configure Squadrons: Create fighter aircraft GROUP templates for both coalitions in mission editor
3. Configure RED squadrons in RED_SQUADRON_CONFIG section
4. Configure BLUE squadrons in BLUE_SQUADRON_CONFIG section
5. Optionally create zones in mission editor for area-of-responsibility using helicopter groups with waypoints.
6. Set coalition behavior parameters in TADC_SETTINGS
7. Configure cargo patterns in ADVANCED_SETTINGS if using replenishment
8. Add this script as "DO SCRIPT" trigger at mission start (after MOOSE loaded)
9. Create and manage cargo aircraft missions for replenishment (optional)

CONFIGURATION VALIDATION:
Built-in validation system checks for:
• Template existence and proper naming
• Airbase name accuracy and coalition control
• Zone existence in mission editor
• Parameter ranges and logical consistency
• Coalition enablement and squadron availability
• Prevents common configuration errors before mission starts

TACTICAL SCENARIOS SUPPORTED:
• Balanced air warfare with equal capabilities and symmetric response
• Asymmetric scenarios with different coalition strengths and capabilities
• Layered air defense with overlapping squadron zones
• Border/perimeter defense with primary and fallback positions
• Training missions for AI vs AI air combat observation
• Dynamic frontline battles with shifting territorial control
• Long-duration missions with cargo resupply operations
• Emergency response scenarios with threat priority management

LOGGING AND MONITORING:
• Real-time threat detection and interceptor launch notifications
• Squadron status reports including aircraft counts and cooldown timers
• Airbase operational status with capture/destruction detection
• Cargo delivery tracking and replenishment confirmations
• Zone-based engagement decisions with detailed reasoning
• Configuration validation results and error reporting
• Performance monitoring with emergency cleanup notifications

REQUIREMENTS:
• MOOSE framework (https://github.com/FlightControl-Master/MOOSE)
• Fighter aircraft GROUP templates (not UNIT templates) for each coalition
• Airbases must exist in mission and be under correct coalition control
• Zone objects in mission editor (if using zone-based features)
• Proper template naming matching squadron configuration

AUTHOR:
• Based off MOOSE framework by FlightControl-Master
• Developed and customized by Mission Designer "F99th-TracerFacer"

VERSION: 1.0
═══════════════════════════════════════════════════════════════════════════════
]]

--[[
═══════════════════════════════════════════════════════════════════════════════
                                MAIN SETTINGS
═══════════════════════════════════════════════════════════════════════════════
]]

-- Core TADC behavior settings - applies to BOTH coalitions unless overridden
local TADC_SETTINGS = {
    -- Enable/Disable coalitions
    enableRed = true,            -- Set to false to disable RED TADC
    enableBlue = true,           -- Set to false to disable BLUE TADC
    
    -- Timing settings (applies to both coalitions)
    checkInterval = 30,          -- How often to scan for threats (seconds)
    monitorInterval = 30,        -- How often to check interceptor status (seconds)
    statusReportInterval = 120,  -- How often to report airbase status (seconds)
    squadronSummaryInterval = 600, -- How often to broadcast squadron summary (seconds)
    cargoCheckInterval = 15,     -- How often to check for cargo deliveries (seconds)
    
    -- RED Coalition Settings
    red = {
        maxActiveCAP = 24,           -- Maximum RED fighters airborne at once
        squadronCooldown = 300,      -- RED cooldown after squadron launch (seconds)
        interceptRatio = 0.8,        -- RED interceptors per threat aircraft
        cargoReplenishmentAmount = 4, -- RED aircraft added per cargo delivery
        emergencyCleanupTime = 7200, -- RED force cleanup time (seconds)
        rtbFlightBuffer = 300,       -- RED extra landing time before cleanup (seconds)
    },
    
    -- BLUE Coalition Settings  
    blue = {
        maxActiveCAP = 24,           -- Maximum BLUE fighters airborne at once
        squadronCooldown = 300,      -- BLUE cooldown after squadron launch (seconds)
        interceptRatio = 0.8,        -- BLUE interceptors per threat aircraft
        cargoReplenishmentAmount = 4, -- BLUE aircraft added per cargo delivery
        emergencyCleanupTime = 7200, -- BLUE force cleanup time (seconds)
        rtbFlightBuffer = 300,       -- BLUE extra landing time before cleanup (seconds)
    },
}

--[[
INTERCEPT RATIO CHART - How many interceptors launch per threat aircraft:

Threat Size:        1    2    4    8    12   16   (aircraft)
====================================================================
interceptRatio 0.2: 1    1    1    2     3    4   (conservative)
interceptRatio 0.5: 1    1    2    4     6    8   (light response)
interceptRatio 0.8: 1    2    4    7    10   13   (balanced) <- DEFAULT
interceptRatio 1.0: 1    2    4    8    12   16   (1:1 parity)
interceptRatio 1.2: 2    3    5   10    15   20   (slight advantage)
interceptRatio 1.4: 2    3    6   12    17   23   (good advantage)
interceptRatio 1.6: 2    4    7   13    20   26   (strong response)
interceptRatio 1.8: 2    4    8   15    22   29   (overwhelming)
interceptRatio 2.0: 2    4    8   16    24   32   (overkill)

TACTICAL EFFECTS:
• 0.2-0.5: Minimal response, may be overwhelmed by large formations
• 0.8-1.0: Realistic parity, creates balanced dogfights
• 1.2-1.4: Coalition advantage, challenging for enemy
• 1.6-1.8: Strong defense, difficult penetration missions
• 1.9-2.0: Nearly impenetrable, may exhaust squadrons quickly

SQUADRON IMPACT:
• Low ratios (0.2-0.8): Squadrons last longer, sustained defense
• High ratios (1.6-2.0): Rapid squadron depletion, coverage gaps
• Sweet spot (1.0-1.4): Balanced response with good coverage duration

ASYMMETRIC SCENARIOS:
• Set RED ratio 1.2, BLUE ratio 0.8 = RED advantage
• Set RED ratio 0.6, BLUE ratio 1.4 = BLUE advantage
• Different maxActiveCAP values create capacity imbalances
]]

--[[
═══════════════════════════════════════════════════════════════════════════════
                              SQUADRON CONFIGURATION
═══════════════════════════════════════════════════════════════════════════════

INSTRUCTIONS:
1. Create fighter aircraft templates for BOTH coalitions in the mission editor
2. Place them at or near the airbases you want them to operate from  
3. Configure RED squadrons in RED_SQUADRON_CONFIG
4. Configure BLUE squadrons in BLUE_SQUADRON_CONFIG

TEMPLATE NAMING SUGGESTIONS:
• RED: "RED_CAP_Batumi_F15", "RED_INTERCEPT_Senaki_MiG29"
• BLUE: "BLUE_CAP_Nellis_F16", "BLUE_INTERCEPT_Creech_F22"
• Include coalition and airbase name for easy identification

AIRBASE NAMES:
• Use exact names as they appear in DCS (case sensitive)
• RED examples: "Batumi", "Senaki", "Gudauta"
• BLUE examples: "Nellis AFB", "McCarran International", "Tonopah Test Range"
• Find airbase names in the mission editor

AIRCRAFT NUMBERS:
• Set realistic numbers based on mission requirements
• Consider aircraft consumption and cargo replenishment
• Balance between realism and gameplay performance

ZONE-BASED AREAS OF RESPONSIBILITY:
• Create zones in mission editor (MOOSE polygons, circles, etc.)
• primaryZone: Squadron's main area (full response)
• secondaryZone: Backup/support area (reduced response)
• tertiaryZone: Emergency fallback area (enhanced response)
• Leave zones as nil for global threat response
• Multiple squadrons can share overlapping zones
• Use zone names exactly as they appear in mission editor

ZONE BEHAVIOR EXAMPLES:
• Border Defense: primaryZone = "SECTOR_ALPHA", secondaryZone = "BUFFER_ZONE"
• Base Defense: tertiaryZone = "BASE_PERIMETER", enableFallback = true
• Layered Defense: Different zones per squadron with overlap
• Emergency Response: High tertiaryResponse ratio for critical areas
]]

-- ═══════════════════════════════════════════════════════════════════════════
--                            RED COALITION SQUADRONS
-- ═══════════════════════════════════════════════════════════════════════════

local RED_SQUADRON_CONFIG = {
    --[[ EXAMPLE RED SQUADRON - CUSTOMIZE FOR YOUR MISSION
    {
        templateName = "RED_CAP_Batumi_F15",     -- Template name from mission editor
        displayName = "Batumi F-15C CAP",        -- Human-readable name for logs
        airbaseName = "Batumi",                  -- Exact airbase name from DCS
        aircraft = 12,                           -- Maximum aircraft in squadron
        skill = AI.Skill.GOOD,                   -- AI skill level
        altitude = 20000,                        -- Patrol altitude (feet)
        speed = 350,                             -- Patrol speed (knots)
        patrolTime = 25,                         -- Time on station (minutes)
        type = "FIGHTER"                         -- Aircraft type

                -- Zone-based Areas of Responsibility (optional - leave nil for global response)
        primaryZone = "RED_BORDER",                       -- Main responsibility area (zone name from mission editor)
        secondaryZone = nil,                     -- Secondary coverage area (zone name)
        tertiaryZone = nil,                      -- Emergency/fallback zone (zone name)
        
        -- Zone behavior settings (optional - uses defaults if not specified)
        zoneConfig = {
            primaryResponse = 1.0,               -- Intercept ratio multiplier in primary zone
            secondaryResponse = 0.6,             -- Intercept ratio multiplier in secondary zone  
            tertiaryResponse = 1.4,              -- Intercept ratio multiplier in tertiary zone
            maxRange = 200,                      -- Maximum engagement range from airbase (nm)
            enableFallback = false,              -- Auto-switch to tertiary when base threatened
            priorityThreshold = 4,               -- Min aircraft count for "major threat"
            ignoreLowPriority = false,           -- Ignore threats below threshold in secondary zones
        }
    },
    ]]
    
    -- ADD YOUR RED SQUADRONS HERE
    {
        templateName = "Sukhumi CAP",            -- Change to your RED template name
        displayName = "Sukhumi CAP",             -- Change to your preferred name
        airbaseName = "Sukhumi-Babushara",       -- Change to your RED airbase
        aircraft = 12,                           -- Adjust aircraft count
        skill = AI.Skill.ACE,                    -- AVERAGE, GOOD, HIGH, EXCELLENT, ACE
        altitude = 20000,                        -- Patrol altitude (feet)
        speed = 350,                             -- Patrol speed (knots)
        patrolTime = 25,                         -- Time on station (minutes)
        type = "FIGHTER",
        
        -- Zone-based Areas of Responsibility (optional - leave nil for global response)
        primaryZone = "RED_BORDER",                       -- Main responsibility area (zone name from mission editor)
        secondaryZone = nil,                     -- Secondary coverage area (zone name)
        tertiaryZone = nil,                      -- Emergency/fallback zone (zone name)
        
        -- Zone behavior settings (optional - uses defaults if not specified)
        zoneConfig = {
            primaryResponse = 1.0,               -- Intercept ratio multiplier in primary zone
            secondaryResponse = 0.6,             -- Intercept ratio multiplier in secondary zone  
            tertiaryResponse = 1.4,              -- Intercept ratio multiplier in tertiary zone
            maxRange = 200,                      -- Maximum engagement range from airbase (nm)
            enableFallback = false,              -- Auto-switch to tertiary when base threatened
            priorityThreshold = 4,               -- Min aircraft count for "major threat"
            ignoreLowPriority = false,           -- Ignore threats below threshold in secondary zones
        }
    },

    {
        templateName = "Gudauta CAP-MiG-21",     -- Change to your RED template name
        displayName = "Gudauta CAP-MiG-21",      -- Change to your preferred name
        airbaseName = "Gudauta",                 -- Change to your RED airbase
        aircraft = 12,                           -- Adjust aircraft count
        skill = AI.Skill.ACE,                    -- AVERAGE, GOOD, HIGH, EXCELLENT
        altitude = 20000,                        -- Patrol altitude (feet)
        speed = 350,                             -- Patrol speed (knots)
        patrolTime = 25,                         -- Time on station (minutes)
        type = "FIGHTER",
        
        -- Zone-based Areas of Responsibility (optional - leave nil for global response)
        primaryZone = "GUDAUTA_BORDER",          -- Main responsibility area (zone name from mission editor)
        secondaryZone = nil,                     -- Secondary coverage area (zone name)
        tertiaryZone = nil,                      -- Emergency/fallback zone (zone name)
        
        -- Zone behavior settings (optional - uses defaults if not specified)
        zoneConfig = {
            primaryResponse = 1.0,               -- Intercept ratio multiplier in primary zone
            secondaryResponse = 0.6,             -- Intercept ratio multiplier in secondary zone  
            tertiaryResponse = 1.4,              -- Intercept ratio multiplier in tertiary zone
            maxRange = 200,                      -- Maximum engagement range from airbase (nm)
            enableFallback = false,              -- Auto-switch to tertiary when base threatened
            priorityThreshold = 4,               -- Min aircraft count for "major threat"
            ignoreLowPriority = false,           -- Ignore threats below threshold in secondary zones
        }
    },

        {
        templateName = "Gudauta CAP-MiG-23",     -- Change to your RED template name
        displayName = "Gudauta CAP-MiG-23",      -- Change to your preferred name
        airbaseName = "Gudauta",                 -- Change to your RED airbase
        aircraft = 14,                           -- Adjust aircraft count
        skill = AI.Skill.ACE,                    -- AVERAGE, GOOD, HIGH, EXCELLENT
        altitude = 20000,                        -- Patrol altitude (feet)
        speed = 350,                             -- Patrol speed (knots)
        patrolTime = 25,                         -- Time on station (minutes)
        type = "FIGHTER",
        
        -- Zone-based Areas of Responsibility (optional - leave nil for global response)
        primaryZone = "GUDAUTA_BORDER",          -- Main responsibility area (zone name from mission editor)
        secondaryZone = "RED_BORDER",            -- Secondary coverage area (zone name)
        tertiaryZone = nil,                      -- Emergency/fallback zone (zone name)
        
        -- Zone behavior settings (optional - uses defaults if not specified)
        zoneConfig = {
            primaryResponse = 1.0,               -- Intercept ratio multiplier in primary zone
            secondaryResponse = 0.6,             -- Intercept ratio multiplier in secondary zone  
            tertiaryResponse = 1.4,              -- Intercept ratio multiplier in tertiary zone
            maxRange = 200,                      -- Maximum engagement range from airbase (nm)
            enableFallback = false,              -- Auto-switch to tertiary when base threatened
            priorityThreshold = 4,               -- Min aircraft count for "major threat"
            ignoreLowPriority = false,           -- Ignore threats below threshold in secondary zones
        }
    },
}

-- ═══════════════════════════════════════════════════════════════════════════
--                           BLUE COALITION SQUADRONS
-- ═══════════════════════════════════════════════════════════════════════════

local BLUE_SQUADRON_CONFIG = {
    --[[ EXAMPLE BLUE SQUADRON - CUSTOMIZE FOR YOUR MISSION
    {
        templateName = "BLUE_CAP_Nellis_F16",    -- Template name from mission editor
        displayName = "Nellis F-16C CAP",        -- Human-readable name for logs
        airbaseName = "Nellis AFB",              -- Exact airbase name from DCS
        aircraft = 14,                           -- Maximum aircraft in squadron
        skill = AI.Skill.EXCELLENT,              -- AI skill level
        altitude = 22000,                        -- Patrol altitude (feet)
        speed = 380,                             -- Patrol speed (knots)
        patrolTime = 28,                         -- Time on station (minutes)
        type = "FIGHTER"                         -- Aircraft type
    },
    ]]
    
    -- ADD YOUR BLUE SQUADRONS HERE
 
    {
        templateName = "Kutaisi CAP",            -- Change to your BLUE template name
        displayName = "Kutaisi CAP",             -- Change to your preferred name
        airbaseName = "Kutaisi",                 -- Change to your BLUE airbase
        aircraft = 18,                           -- Adjust aircraft count
        skill = AI.Skill.EXCELLENT,              -- AVERAGE, GOOD, HIGH, EXCELLENT
        altitude = 18000,                        -- Patrol altitude (feet)
        speed = 320,                             -- Patrol speed (knots)
        patrolTime = 22,                         -- Time on station (minutes)
        type = "FIGHTER",
        
        -- Zone-based Areas of Responsibility (optional - leave nil for global response)
        primaryZone = "BLUE_BORDER",             -- Main responsibility area (zone name from mission editor)
        secondaryZone = nil,                     -- Secondary coverage area (zone name)
        tertiaryZone = nil,                      -- Emergency/fallback zone (zone name)
        
        -- Zone behavior settings (optional - uses defaults if not specified)
        zoneConfig = {
            primaryResponse = 1.0,               -- Intercept ratio multiplier in primary zone
            secondaryResponse = 0.6,             -- Intercept ratio multiplier in secondary zone  
            tertiaryResponse = 1.4,              -- Intercept ratio multiplier in tertiary zone
            maxRange = 200,                      -- Maximum engagement range from airbase (nm)
            enableFallback = true,               -- Auto-switch to tertiary when base threatened
            priorityThreshold = 4,               -- Min aircraft count for "major threat"
            ignoreLowPriority = false,           -- Ignore threats below threshold in secondary zones
        }
    },

    {
        templateName = "Batumi CAP",             -- Change to your BLUE template name
        displayName = "Batumi CAP",              -- Change to your preferred name
        airbaseName = "Batumi",                  -- Change to your BLUE airbase
        aircraft = 18,                           -- Adjust aircraft count
        skill = AI.Skill.EXCELLENT,              -- AVERAGE, GOOD, HIGH, EXCELLENT
        altitude = 18000,                        -- Patrol altitude (feet)
        speed = 320,                             -- Patrol speed (knots)
        patrolTime = 22,                         -- Time on station (minutes)
        type = "FIGHTER",
        
        -- Zone-based Areas of Responsibility (optional - leave nil for global response)
        primaryZone = "BATUMI_BORDER",           -- Main responsibility area (zone name from mission editor)
        secondaryZone = "BLUE_BORDER",           -- Secondary coverage area (zone name)
        tertiaryZone = "BATUMI_BORDER",          -- Emergency/fallback zone (zone name)
        
        -- Zone behavior settings (optional - uses defaults if not specified)
        zoneConfig = {
            primaryResponse = 1.0,               -- Intercept ratio multiplier in primary zone
            secondaryResponse = 0.6,             -- Intercept ratio multiplier in secondary zone  
            tertiaryResponse = 1.4,              -- Intercept ratio multiplier in tertiary zone
            maxRange = 200,                      -- Maximum engagement range from airbase (nm)
            enableFallback = true,               -- Auto-switch to tertiary when base threatened
            priorityThreshold = 4,               -- Min aircraft count for "major threat"
            ignoreLowPriority = false,           -- Ignore threats below threshold in secondary zones
        }
    },
}

--[[
═══════════════════════════════════════════════════════════════════════════════
                            ADVANCED SETTINGS
═══════════════════════════════════════════════════════════════════════════════

These settings control more detailed behavior. Most users won't need to change these.
]]

local ADVANCED_SETTINGS = {
    -- Cargo aircraft detection patterns (aircraft with these names will replenish squadrons (Currently only fixed wing aircraft supported)) 
    cargoPatterns = {"CARGO", "TRANSPORT", "C130", "C-130", "AN26", "AN-26"},
    
    -- Distance from airbase to consider cargo "landed" (meters)
    cargoLandingDistance = 3000,
    
    -- Velocity below which aircraft is considered "landed" (km/h)
    cargoLandedVelocity = 5,
    
    -- RTB settings
    rtbAltitude = 6000,    -- Return to base altitude (feet)
    rtbSpeed = 430,        -- Return to base speed (knots)
    
    -- Logging settings
    enableDetailedLogging = true,  -- Set to false to reduce log spam
    logPrefix = "[Universal TADC]", -- Prefix for all log messages
}

--[[
═══════════════════════════════════════════════════════════════════════════════
                              SYSTEM CODE
                    (DO NOT MODIFY BELOW THIS LINE)
═══════════════════════════════════════════════════════════════════════════════
]]

-- Internal tracking variables - separate for each coalition
local activeInterceptors = {
    red = {},
    blue = {}
}
local lastLaunchTime = {
    red = {},
    blue = {}
}
local assignedThreats = {
    red = {},
    blue = {}
}
local squadronCooldowns = {
    red = {},
    blue = {}
}
local squadronAircraftCounts = {
    red = {},
    blue = {}
}

-- Performance optimization: Cache SET_GROUP objects to avoid repeated creation
local cachedSets = {
    redCargo = nil,
    blueCargo = nil,
    redAircraft = nil,
    blueAircraft = nil
}

-- Initialize squadron aircraft counts for both coalitions
for _, squadron in pairs(RED_SQUADRON_CONFIG) do
    if squadron.aircraft and squadron.templateName then
        squadronAircraftCounts.red[squadron.templateName] = squadron.aircraft
    end
end

for _, squadron in pairs(BLUE_SQUADRON_CONFIG) do
    if squadron.aircraft and squadron.templateName then
        squadronAircraftCounts.blue[squadron.templateName] = squadron.aircraft
    end
end

-- Logging function
local function log(message, detailed)
    if not detailed or ADVANCED_SETTINGS.enableDetailedLogging then
        env.info(ADVANCED_SETTINGS.logPrefix .. " " .. message)
    end
end

-- Squadron resource summary generator

local function getSquadronResourceSummary(coalitionSide)
    local function getStatus(remaining, max)
        local percent = (remaining / max) * 100
    if percent <= 10 then return "[CRITICAL]" end
    if percent <= 25 then return "[LOW]" end
    return "OK"
    end

    local lines = {}
    table.insert(lines, "-=[ Tactical Air Defense Controller ]=-\n")
    table.insert(lines, "Squadron Resource Summary:\n")
    table.insert(lines, "| Squadron     | Aircraft Remaining | Status      |")
    table.insert(lines, "|--------------|--------------------|-------------|")

    if coalitionSide == coalition.side.RED then
        for _, squadron in pairs(RED_SQUADRON_CONFIG) do
            local remaining = squadronAircraftCounts.red[squadron.templateName] or 0
            local max = squadron.aircraft or 0
            local status = getStatus(remaining, max)
            table.insert(lines, string.format("| %-13s | %2d / %-15d | %-11s |", squadron.displayName or squadron.templateName, remaining, max, status))
        end
    elseif coalitionSide == coalition.side.BLUE then
        for _, squadron in pairs(BLUE_SQUADRON_CONFIG) do
            local remaining = squadronAircraftCounts.blue[squadron.templateName] or 0
            local max = squadron.aircraft or 0
            local status = getStatus(remaining, max)
            table.insert(lines, string.format("| %-13s | %2d / %-15d | %-11s |", squadron.displayName or squadron.templateName, remaining, max, status))
        end
    end

    table.insert(lines, "\n- [LOW]: Below 25%\n- [CRITICAL]: Below 10%\n- OK: Above 25%")
    return table.concat(lines, "\n")
end

-- Broadcast squadron summary to all players
local function broadcastSquadronSummary()
    if TADC_SETTINGS.enableRed then
        local summaryRed = getSquadronResourceSummary(coalition.side.RED)
        MESSAGE:New(summaryRed, 20):ToCoalition(coalition.side.RED)
    end
    if TADC_SETTINGS.enableBlue then
        local summaryBlue = getSquadronResourceSummary(coalition.side.BLUE)
        MESSAGE:New(summaryBlue, 20):ToCoalition(coalition.side.BLUE)
    end
end

-- Coalition-specific settings helper
local function getCoalitionSettings(coalitionSide)
    if coalitionSide == coalition.side.RED then
        return TADC_SETTINGS.red, "RED"
    elseif coalitionSide == coalition.side.BLUE then
        return TADC_SETTINGS.blue, "BLUE"
    else
        return nil, "UNKNOWN"
    end
end

-- Get squadron config for coalition
local function getSquadronConfig(coalitionSide)
    if coalitionSide == coalition.side.RED then
        return RED_SQUADRON_CONFIG
    elseif coalitionSide == coalition.side.BLUE then
        return BLUE_SQUADRON_CONFIG
    else
        return {}
    end
end

-- Check if coordinate is within a zone
local function isInZone(coordinate, zoneName)
    if not zoneName or zoneName == "" then
        return false
    end
    
    -- Try to find the zone
    local zone = ZONE:FindByName(zoneName)
    if zone then
        return zone:IsCoordinateInZone(coordinate)
    else
        -- Try to create polygon zone from helicopter group waypoints if not found
        local group = GROUP:FindByName(zoneName)
        if group then
            -- Create polygon zone using the group's waypoints as vertices
            zone = ZONE_POLYGON:NewFromGroupName(zoneName, zoneName)
            if zone then
                log("Created polygon zone '" .. zoneName .. "' from helicopter waypoints")
                return zone:IsCoordinateInZone(coordinate)
            else
                log("Warning: Could not create polygon zone from group '" .. zoneName .. "' - check waypoints")
            end
        else
            log("Warning: No group named '" .. zoneName .. "' found for zone creation")
        end
        
        log("Warning: Zone '" .. zoneName .. "' not found in mission and could not create from helicopter group", true)
        return false
    end
end

-- Get default zone configuration
local function getDefaultZoneConfig()
    return {
        primaryResponse = 1.0,
        secondaryResponse = 0.6,
        tertiaryResponse = 1.4,
        maxRange = 200,
        enableFallback = false,
        priorityThreshold = 4,
        ignoreLowPriority = false,
    }
end

-- Check if squadron should respond to fallback conditions
local function checkFallbackConditions(squadron, coalitionSide)
    local coalitionKey = (coalitionSide == coalition.side.RED) and "red" or "blue"
    
    -- Check if airbase is under attack (simplified - check if base has low aircraft)
    local currentAircraft = squadronAircraftCounts[coalitionKey][squadron.templateName] or 0
    local maxAircraft = squadron.aircraft
    local aircraftRatio = currentAircraft / maxAircraft
    
    -- Trigger fallback if squadron is below 50% strength or base is threatened
    if aircraftRatio < 0.5 then
        return true
    end
    
    -- Could add more complex conditions here (base under attack, etc.)
    return false
end

-- Get threat zone priority and response ratio for squadron
local function getThreatZonePriority(threatCoord, squadron, coalitionSide)
    local zoneConfig = squadron.zoneConfig or getDefaultZoneConfig()
    
    -- Check distance from airbase first
    local airbase = AIRBASE:FindByName(squadron.airbaseName)
    if airbase then
        local airbaseCoord = airbase:GetCoordinate()
        local distance = airbaseCoord:Get2DDistance(threatCoord) / 1852 -- Convert meters to nautical miles
        
        if distance > zoneConfig.maxRange then
            return "none", 0, "out of range (" .. math.floor(distance) .. "nm > " .. zoneConfig.maxRange .. "nm)"
        end
    end
    
    -- Check tertiary zone first (highest priority if fallback enabled)
    if squadron.tertiaryZone and zoneConfig.enableFallback then
        if checkFallbackConditions(squadron, coalitionSide) then
            if isInZone(threatCoord, squadron.tertiaryZone) then
                return "tertiary", zoneConfig.tertiaryResponse, "fallback zone (enhanced response)"
            end
        end
    end
    
    -- Check primary zone
    if squadron.primaryZone and isInZone(threatCoord, squadron.primaryZone) then
        return "primary", zoneConfig.primaryResponse, "primary AOR"
    end
    
    -- Check secondary zone
    if squadron.secondaryZone and isInZone(threatCoord, squadron.secondaryZone) then
        return "secondary", zoneConfig.secondaryResponse, "secondary AOR"
    end
    
    -- Check tertiary zone (normal priority)
    if squadron.tertiaryZone and isInZone(threatCoord, squadron.tertiaryZone) then
        return "tertiary", zoneConfig.tertiaryResponse, "tertiary zone"
    end
    
    -- If no zones are defined, use global response
    if not squadron.primaryZone and not squadron.secondaryZone and not squadron.tertiaryZone then
        return "global", 1.0, "global response (no zones defined)"
    end
    
    -- Outside all defined zones
    return "none", 0, "outside defined zones"
end

-- Startup validation
local function validateConfiguration()
    local errors = {}
    
    -- Check coalition enablement
    if not TADC_SETTINGS.enableRed and not TADC_SETTINGS.enableBlue then
        table.insert(errors, "Both coalitions disabled - enable at least one in TADC_SETTINGS")
    end
    
    -- Validate RED squadrons if enabled
    if TADC_SETTINGS.enableRed then
        if #RED_SQUADRON_CONFIG == 0 then
            table.insert(errors, "No RED squadrons configured but RED TADC is enabled")
        else
            for i, squadron in pairs(RED_SQUADRON_CONFIG) do
                local prefix = "RED Squadron " .. i .. ": "
                
                if not squadron.templateName or squadron.templateName == "" or 
                   squadron.templateName == "RED_CAP_SQUADRON_1" or 
                   squadron.templateName == "RED_CAP_SQUADRON_2" then
                    table.insert(errors, prefix .. "templateName not configured or using default example")
                end
                
                if not squadron.displayName or squadron.displayName == "" then
                    table.insert(errors, prefix .. "displayName not configured")
                end
                
                if not squadron.airbaseName or squadron.airbaseName == "" or 
                   squadron.airbaseName:find("YOUR_RED_AIRBASE") then
                    table.insert(errors, prefix .. "airbaseName not configured or using default example")
                end
                
                if not squadron.aircraft or squadron.aircraft <= 0 then
                    table.insert(errors, prefix .. "aircraft count not configured or invalid")
                end
                
                -- Validate zone configuration if zones are specified
                if squadron.primaryZone or squadron.secondaryZone or squadron.tertiaryZone then
                    if squadron.zoneConfig then
                        local zc = squadron.zoneConfig
                        if zc.primaryResponse and (zc.primaryResponse < 0 or zc.primaryResponse > 5) then
                            table.insert(errors, prefix .. "primaryResponse ratio out of range (0-5)")
                        end
                        if zc.secondaryResponse and (zc.secondaryResponse < 0 or zc.secondaryResponse > 5) then
                            table.insert(errors, prefix .. "secondaryResponse ratio out of range (0-5)")
                        end
                        if zc.tertiaryResponse and (zc.tertiaryResponse < 0 or zc.tertiaryResponse > 5) then
                            table.insert(errors, prefix .. "tertiaryResponse ratio out of range (0-5)")
                        end
                        if zc.maxRange and (zc.maxRange < 10 or zc.maxRange > 1000) then
                            table.insert(errors, prefix .. "maxRange out of range (10-1000 nm)")
                        end
                    end
                    
                    -- Check if specified zones exist in mission
                    local zones = {}
                    if squadron.primaryZone then table.insert(zones, squadron.primaryZone) end
                    if squadron.secondaryZone then table.insert(zones, squadron.secondaryZone) end
                    if squadron.tertiaryZone then table.insert(zones, squadron.tertiaryZone) end
                    
                    for _, zoneName in ipairs(zones) do
                        local zoneObj = ZONE:FindByName(zoneName)
                        if not zoneObj then
                            -- Check if there's a helicopter unit/group with this name for zone creation
                            local unit = UNIT:FindByName(zoneName)
                            local group = GROUP:FindByName(zoneName)
                            if not unit and not group then
                                table.insert(errors, prefix .. "zone '" .. zoneName .. "' not found in mission (no zone or helicopter unit named '" .. zoneName .. "')")
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Validate BLUE squadrons if enabled
    if TADC_SETTINGS.enableBlue then
        if #BLUE_SQUADRON_CONFIG == 0 then
            table.insert(errors, "No BLUE squadrons configured but BLUE TADC is enabled")
        else
            for i, squadron in pairs(BLUE_SQUADRON_CONFIG) do
                local prefix = "BLUE Squadron " .. i .. ": "
                
                if not squadron.templateName or squadron.templateName == "" or 
                   squadron.templateName == "BLUE_CAP_SQUADRON_1" or 
                   squadron.templateName == "BLUE_CAP_SQUADRON_2" then
                    table.insert(errors, prefix .. "templateName not configured or using default example")
                end
                
                if not squadron.displayName or squadron.displayName == "" then
                    table.insert(errors, prefix .. "displayName not configured")
                end
                
                if not squadron.airbaseName or squadron.airbaseName == "" or 
                   squadron.airbaseName:find("YOUR_BLUE_AIRBASE") then
                    table.insert(errors, prefix .. "airbaseName not configured or using default example")
                end
                
                if not squadron.aircraft or squadron.aircraft <= 0 then
                    table.insert(errors, prefix .. "aircraft count not configured or invalid")
                end
                
                -- Validate zone configuration if zones are specified
                if squadron.primaryZone or squadron.secondaryZone or squadron.tertiaryZone then
                    if squadron.zoneConfig then
                        local zc = squadron.zoneConfig
                        if zc.primaryResponse and (zc.primaryResponse < 0 or zc.primaryResponse > 5) then
                            table.insert(errors, prefix .. "primaryResponse ratio out of range (0-5)")
                        end
                        if zc.secondaryResponse and (zc.secondaryResponse < 0 or zc.secondaryResponse > 5) then
                            table.insert(errors, prefix .. "secondaryResponse ratio out of range (0-5)")
                        end
                        if zc.tertiaryResponse and (zc.tertiaryResponse < 0 or zc.tertiaryResponse > 5) then
                            table.insert(errors, prefix .. "tertiaryResponse ratio out of range (0-5)")
                        end
                        if zc.maxRange and (zc.maxRange < 10 or zc.maxRange > 1000) then
                            table.insert(errors, prefix .. "maxRange out of range (10-1000 nm)")
                        end
                    end
                    
                    -- Check if specified zones exist in mission
                    local zones = {}
                    if squadron.primaryZone then table.insert(zones, squadron.primaryZone) end
                    if squadron.secondaryZone then table.insert(zones, squadron.secondaryZone) end
                    if squadron.tertiaryZone then table.insert(zones, squadron.tertiaryZone) end
                    
                    for _, zoneName in ipairs(zones) do
                        local zoneObj = ZONE:FindByName(zoneName)
                        if not zoneObj then
                            -- Check if there's a helicopter unit/group with this name for zone creation
                            local unit = UNIT:FindByName(zoneName)
                            local group = GROUP:FindByName(zoneName)
                            if not unit and not group then
                                table.insert(errors, prefix .. "zone '" .. zoneName .. "' not found in mission (no zone or helicopter unit named '" .. zoneName .. "')")
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Report errors
    if #errors > 0 then
    log("CONFIGURATION ERRORS DETECTED:")
    MESSAGE:New("CONFIGURATION ERRORS DETECTED:", 30):ToAll()
        for _, error in pairs(errors) do
            log("  ✗ " .. error)
            MESSAGE:New("CONFIG ERROR: " .. error, 30):ToAll()
        end
    log("Please fix configuration before using Universal TADC!")
    MESSAGE:New("Please fix configuration before using Universal TADC!", 30):ToAll()
        return false
    else
    log("Configuration validation passed ✓")
    MESSAGE:New("Universal TADC configuration passed ✓", 10):ToAll()
        return true
    end
end

-- Monitor cargo aircraft landings for squadron replenishment
local function monitorCargoReplenishment()
    -- Process RED cargo aircraft
    if TADC_SETTINGS.enableRed then
        -- Use cached set for performance, create if needed
        if not cachedSets.redCargo then
            cachedSets.redCargo = SET_GROUP:New():FilterCoalitions("red"):FilterCategoryAirplane():FilterStart()
        end
        local redCargo = cachedSets.redCargo
        
        redCargo:ForEach(function(cargoGroup)
            if cargoGroup and cargoGroup:IsAlive() then
                local cargoName = cargoGroup:GetName():upper()
                local isCargoAircraft = false
                
                -- Check if aircraft name matches cargo patterns
                for _, pattern in pairs(ADVANCED_SETTINGS.cargoPatterns) do
                    if string.find(cargoName, pattern) then
                        isCargoAircraft = true
                        break
                    end
                end
                
                if isCargoAircraft then
                    local cargoCoord = cargoGroup:GetCoordinate()
                    local cargoVelocity = cargoGroup:GetVelocityKMH()
                    
                    -- Consider aircraft "landed" if velocity is very low
                    if cargoVelocity < ADVANCED_SETTINGS.cargoLandedVelocity then
                        -- Check which RED airbase it's near
                        for _, squadron in pairs(RED_SQUADRON_CONFIG) do
                            local airbase = AIRBASE:FindByName(squadron.airbaseName)
                            if airbase and airbase:GetCoalition() == coalition.side.RED then
                                local airbaseCoord = airbase:GetCoordinate()
                                local distance = cargoCoord:Get2DDistance(airbaseCoord)
                                
                                -- If within configured distance of airbase, consider it a delivery
                                if distance < ADVANCED_SETTINGS.cargoLandingDistance then
                                    -- Initialize processed deliveries table
                                    if not _G.processedDeliveries then
                                        _G.processedDeliveries = {}
                                    end
                                    
                                    -- Create unique delivery key including timestamp to prevent race conditions
                                    local deliveryKey = cargoName .. "_RED_" .. squadron.airbaseName .. "_" .. cargoGroup:GetID()
                                    
                                    if not _G.processedDeliveries[deliveryKey] then
                                        -- Mark delivery as processed immediately to prevent race conditions
                                        _G.processedDeliveries[deliveryKey] = timer.getTime()
                                        -- Process replenishment
                                        local currentCount = squadronAircraftCounts.red[squadron.templateName] or 0
                                        local maxCount = squadron.aircraft
                                        local newCount = math.min(currentCount + TADC_SETTINGS.red.cargoReplenishmentAmount, maxCount)
                                        local actualAdded = newCount - currentCount
                                        
                                        if actualAdded > 0 then
                                            squadronAircraftCounts.red[squadron.templateName] = newCount
                                            local msg = "RED CARGO DELIVERY: " .. cargoName .. " delivered " .. actualAdded .. 
                                                " aircraft to " .. squadron.displayName .. 
                                                " (" .. newCount .. "/" .. maxCount .. ")"
                                            log(msg)
                                            MESSAGE:New(msg, 20):ToAll()
                                        else
                                            local msg = "RED CARGO DELIVERY: " .. squadron.displayName .. " already at max capacity"
                                            log(msg, true)
                                            MESSAGE:New(msg, 15):ToAll()
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
    
    -- Process BLUE cargo aircraft
    if TADC_SETTINGS.enableBlue then
        -- Use cached set for performance, create if needed
        if not cachedSets.blueCargo then
            cachedSets.blueCargo = SET_GROUP:New():FilterCoalitions("blue"):FilterCategoryAirplane():FilterStart()
        end
        local blueCargo = cachedSets.blueCargo
        
        blueCargo:ForEach(function(cargoGroup)
            if cargoGroup and cargoGroup:IsAlive() then
                local cargoName = cargoGroup:GetName():upper()
                local isCargoAircraft = false
                
                -- Check if aircraft name matches cargo patterns
                for _, pattern in pairs(ADVANCED_SETTINGS.cargoPatterns) do
                    if string.find(cargoName, pattern) then
                        isCargoAircraft = true
                        break
                    end
                end
                
                if isCargoAircraft then
                    local cargoCoord = cargoGroup:GetCoordinate()
                    local cargoVelocity = cargoGroup:GetVelocityKMH()
                    
                    -- Consider aircraft "landed" if velocity is very low
                    if cargoVelocity < ADVANCED_SETTINGS.cargoLandedVelocity then
                        -- Check which BLUE airbase it's near
                        for _, squadron in pairs(BLUE_SQUADRON_CONFIG) do
                            local airbase = AIRBASE:FindByName(squadron.airbaseName)
                            if airbase and airbase:GetCoalition() == coalition.side.BLUE then
                                local airbaseCoord = airbase:GetCoordinate()
                                local distance = cargoCoord:Get2DDistance(airbaseCoord)
                                
                                -- If within configured distance of airbase, consider it a delivery
                                if distance < ADVANCED_SETTINGS.cargoLandingDistance then
                                    -- Initialize processed deliveries table
                                    if not _G.processedDeliveries then
                                        _G.processedDeliveries = {}
                                    end
                                    
                                    -- Create unique delivery key including timestamp to prevent race conditions
                                    local deliveryKey = cargoName .. "_BLUE_" .. squadron.airbaseName .. "_" .. cargoGroup:GetID()
                                    
                                    if not _G.processedDeliveries[deliveryKey] then
                                        -- Mark delivery as processed immediately to prevent race conditions
                                        _G.processedDeliveries[deliveryKey] = timer.getTime()
                                        -- Process replenishment
                                        local currentCount = squadronAircraftCounts.blue[squadron.templateName] or 0
                                        local maxCount = squadron.aircraft
                                        local newCount = math.min(currentCount + TADC_SETTINGS.blue.cargoReplenishmentAmount, maxCount)
                                        local actualAdded = newCount - currentCount
                                        
                                        if actualAdded > 0 then
                                            squadronAircraftCounts.blue[squadron.templateName] = newCount
                                            local msg = "BLUE CARGO DELIVERY: " .. cargoName .. " delivered " .. actualAdded .. 
                                                " aircraft to " .. squadron.displayName .. 
                                                " (" .. newCount .. "/" .. maxCount .. ")"
                                            log(msg)
                                            MESSAGE:New(msg, 20):ToAll()
                                        else
                                            local msg = "BLUE CARGO DELIVERY: " .. squadron.displayName .. " already at max capacity"
                                            log(msg, true)
                                            MESSAGE:New(msg, 15):ToAll()
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end

-- Send interceptor back to base
local function sendInterceptorHome(interceptor, coalitionSide)
    if not interceptor or not interceptor:IsAlive() then
        return
    end
    
    -- Find nearest friendly airbase
    local interceptorCoord = interceptor:GetCoordinate()
    if not interceptorCoord then
        log("ERROR: Could not get interceptor coordinates for RTB", true)
        return
    end
    local nearestAirbase = nil
    local shortestDistance = math.huge
    local squadronConfig = getSquadronConfig(coalitionSide)
    
    -- Check all squadron airbases to find the nearest one that's still friendly
    for _, squadron in pairs(squadronConfig) do
        local airbase = AIRBASE:FindByName(squadron.airbaseName)
        if airbase and airbase:GetCoalition() == coalitionSide and airbase:IsAlive() then
            local airbaseCoord = airbase:GetCoordinate()
            local distance = interceptorCoord:Get2DDistance(airbaseCoord)
            if distance < shortestDistance then
                shortestDistance = distance
                nearestAirbase = airbase
            end
        end
    end
    
    if nearestAirbase then
        local airbaseCoord = nearestAirbase:GetCoordinate()
        local rtbAltitude = ADVANCED_SETTINGS.rtbAltitude * 0.3048 -- Convert feet to meters
        local rtbCoord = airbaseCoord:SetAltitude(rtbAltitude)
        
        -- Clear current tasks and route home
        interceptor:ClearTasks()
        interceptor:RouteAirTo(rtbCoord, ADVANCED_SETTINGS.rtbSpeed * 0.5144, "BARO") -- Convert knots to m/s
        
        local _, coalitionName = getCoalitionSettings(coalitionSide)
        log("Sending " .. coalitionName .. " " .. interceptor:GetName() .. " back to " .. nearestAirbase:GetName(), true)
        
        -- Schedule cleanup after they should have landed
        local coalitionSettings = getCoalitionSettings(coalitionSide)
        local flightTime = math.ceil(shortestDistance / (ADVANCED_SETTINGS.rtbSpeed * 0.5144)) + coalitionSettings.rtbFlightBuffer
        
        SCHEDULER:New(nil, function()
            local coalitionKey = (coalitionSide == coalition.side.RED) and "red" or "blue"
            if activeInterceptors[coalitionKey][interceptor:GetName()] then
                activeInterceptors[coalitionKey][interceptor:GetName()] = nil
                log("Cleaned up " .. coalitionName .. " " .. interceptor:GetName() .. " after RTB", true)
            end
        end, {}, flightTime)
    else
        local _, coalitionName = getCoalitionSettings(coalitionSide)
        log("No friendly airbase found for " .. coalitionName .. " " .. interceptor:GetName() .. ", will clean up normally")
    end
end

-- Check if airbase is still usable
local function isAirbaseUsable(airbaseName, expectedCoalition)
    local airbase = AIRBASE:FindByName(airbaseName)
    if not airbase then
        return false, "not found"
    elseif airbase:GetCoalition() ~= expectedCoalition then
        local capturedBy = "Unknown"
        if airbase:GetCoalition() == coalition.side.RED then
            capturedBy = "Red"
        elseif airbase:GetCoalition() == coalition.side.BLUE then
            capturedBy = "Blue"
        else
            capturedBy = "Neutral"
        end
        return false, "captured by " .. capturedBy
    elseif not airbase:IsAlive() then
        return false, "destroyed"
    else
        return true, "operational"
    end
end

-- Count active fighters for coalition
local function countActiveFighters(coalitionSide)
    local count = 0
    local coalitionKey = (coalitionSide == coalition.side.RED) and "red" or "blue"
    
    for _, interceptorData in pairs(activeInterceptors[coalitionKey]) do
        if interceptorData and interceptorData.group and interceptorData.group:IsAlive() then
            count = count + interceptorData.group:GetSize()
        end
    end
    return count
end

-- Find best squadron to launch for coalition using zone-based priorities
local function findBestSquadron(threatCoord, threatSize, coalitionSide)
    local bestSquadron = nil
    local bestPriority = "none"
    local bestResponseRatio = 0
    local shortestDistance = math.huge
    local currentTime = timer.getTime()
    local squadronConfig = getSquadronConfig(coalitionSide)
    local coalitionSettings, coalitionName = getCoalitionSettings(coalitionSide)
    local coalitionKey = (coalitionSide == coalition.side.RED) and "red" or "blue"
    local zonePriorityOrder = {"tertiary", "primary", "secondary", "global"}
    
    -- First pass: find squadrons that can respond to this threat
    local availableSquadrons = {}
    
    for _, squadron in pairs(squadronConfig) do
        -- Check basic availability
        local squadronAvailable = true
        local unavailableReason = ""
        
        -- Check cooldown
        if squadronCooldowns[coalitionKey][squadron.templateName] then
            local cooldownEnd = squadronCooldowns[coalitionKey][squadron.templateName]
            if currentTime < cooldownEnd then
                local timeLeft = math.ceil((cooldownEnd - currentTime) / 60)
                squadronAvailable = false
                unavailableReason = "on cooldown for " .. timeLeft .. "m"
            else
                -- Cooldown expired, remove it
                squadronCooldowns[coalitionKey][squadron.templateName] = nil
                log(coalitionName .. " Squadron " .. squadron.displayName .. " cooldown expired, available for launch", true)
            end
        end
        
        -- Check aircraft availability
        if squadronAvailable then
            local availableAircraft = squadronAircraftCounts[coalitionKey][squadron.templateName] or 0
            if availableAircraft <= 0 then
                squadronAvailable = false
                unavailableReason = "no aircraft available (" .. availableAircraft .. "/" .. squadron.aircraft .. ")"
            end
        end
        
        -- Check airbase status
        if squadronAvailable then
            local airbase = AIRBASE:FindByName(squadron.airbaseName)
            if not airbase then
                squadronAvailable = false
                unavailableReason = "airbase not found"
            elseif airbase:GetCoalition() ~= coalitionSide then
                squadronAvailable = false
                unavailableReason = "airbase no longer under " .. coalitionName .. " control"
            elseif not airbase:IsAlive() then
                squadronAvailable = false
                unavailableReason = "airbase destroyed"
            end
        end
        
        -- Check template exists (Note: Templates are validated during SPAWN:New() call)
        -- Template validation is handled by MOOSE SPAWN class during actual spawning
        
        if squadronAvailable then
            -- Get zone priority and response ratio
            local zonePriority, responseRatio, zoneDescription = getThreatZonePriority(threatCoord, squadron, coalitionSide)
            
            -- Check if threat meets priority threshold for secondary zones
            local zoneConfig = squadron.zoneConfig or getDefaultZoneConfig()
            if zonePriority == "secondary" and zoneConfig.ignoreLowPriority then
                if threatSize < zoneConfig.priorityThreshold then
                    log(coalitionName .. " " .. squadron.displayName .. " ignoring low-priority threat in secondary zone (" .. 
                        threatSize .. " < " .. zoneConfig.priorityThreshold .. ")", true)
                    responseRatio = 0
                    zonePriority = "none"
                end
            end
            
            if responseRatio > 0 then
                local airbase = AIRBASE:FindByName(squadron.airbaseName)
                local airbaseCoord = airbase:GetCoordinate()
                local distance = airbaseCoord:Get2DDistance(threatCoord)
                
                table.insert(availableSquadrons, {
                    squadron = squadron,
                    zonePriority = zonePriority,
                    responseRatio = responseRatio,
                    distance = distance,
                    zoneDescription = zoneDescription
                })
                
                log(coalitionName .. " " .. squadron.displayName .. " can respond: " .. zoneDescription .. 
                    " (ratio: " .. responseRatio .. ", distance: " .. math.floor(distance/1852) .. "nm)", true)
            else
                log(coalitionName .. " " .. squadron.displayName .. " will not respond: " .. zoneDescription, true)
            end
        else
            log(coalitionName .. " " .. squadron.displayName .. " unavailable: " .. unavailableReason, true)
        end
    end
    
    -- Second pass: select best squadron by priority and distance
    if #availableSquadrons > 0 then
        -- Sort by zone priority (higher priority first), then by distance (closer first)
        table.sort(availableSquadrons, function(a, b)
            -- Get priority indices
            local aPriorityIndex = 5
            local bPriorityIndex = 5
            for i, priority in ipairs(zonePriorityOrder) do
                if a.zonePriority == priority then aPriorityIndex = i end
                if b.zonePriority == priority then bPriorityIndex = i end
            end
            
            -- First sort by priority (lower index = higher priority)
            if aPriorityIndex ~= bPriorityIndex then
                return aPriorityIndex < bPriorityIndex
            end
            
            -- Then sort by distance (closer is better)
            return a.distance < b.distance
        end)
        
        local selected = availableSquadrons[1]
        log("Selected " .. coalitionName .. " " .. selected.squadron.displayName .. " for response: " .. 
            selected.zoneDescription .. " (distance: " .. math.floor(selected.distance/1852) .. "nm)")
        
        return selected.squadron, selected.responseRatio, selected.zoneDescription
    end
    
    log("No " .. coalitionName .. " squadron available for threat at coordinates")
    return nil, 0, "no available squadrons"
end

-- Launch interceptor for coalition
local function launchInterceptor(threatGroup, coalitionSide)
    if not threatGroup or not threatGroup:IsAlive() then
        return
    end
    
    local threatCoord = threatGroup:GetCoordinate()
    local threatName = threatGroup:GetName()
    local threatSize = threatGroup:GetSize()
    local coalitionSettings, coalitionName = getCoalitionSettings(coalitionSide)
    local coalitionKey = (coalitionSide == coalition.side.RED) and "red" or "blue"
    
    -- Check if threat already has interceptors assigned
    if assignedThreats[coalitionKey][threatName] then
        local assignedInterceptors = assignedThreats[coalitionKey][threatName]
        local aliveCount = 0
        
        -- Check if assigned interceptors are still alive
        if type(assignedInterceptors) == "table" then
            for _, interceptor in pairs(assignedInterceptors) do
                if interceptor and interceptor:IsAlive() then
                    aliveCount = aliveCount + 1
                end
            end
        else
            -- Handle legacy single interceptor assignment
            if assignedInterceptors and assignedInterceptors:IsAlive() then
                aliveCount = 1
            end
        end
        
        if aliveCount > 0 then
            return -- Still being intercepted
        else
            -- All interceptors are dead, clear the assignment
            assignedThreats[coalitionKey][threatName] = nil
        end
    end
    
    -- Find best squadron using zone-based priority system first
    local squadron, zoneResponseRatio, zoneDescription = findBestSquadron(threatCoord, threatSize, coalitionSide)
    
    if not squadron then
        log("No " .. coalitionName .. " squadron available")
        return
    end
    
    -- Calculate how many interceptors to launch using zone-modified ratio
    local finalInterceptRatio = coalitionSettings.interceptRatio * zoneResponseRatio
    local interceptorsNeeded = math.max(1, math.ceil(threatSize * finalInterceptRatio))
    
    -- Check if we have capacity
    if countActiveFighters(coalitionSide) + interceptorsNeeded > coalitionSettings.maxActiveCAP then
        interceptorsNeeded = coalitionSettings.maxActiveCAP - countActiveFighters(coalitionSide)
        if interceptorsNeeded <= 0 then
            log(coalitionName .. " max fighters airborne, skipping launch")
            return
        end
    end
    if not squadron then
        log("No " .. coalitionName .. " squadron available")
        return
    end
    
    -- Limit interceptors to available aircraft
    local availableAircraft = squadronAircraftCounts[coalitionKey][squadron.templateName] or 0
    interceptorsNeeded = math.min(interceptorsNeeded, availableAircraft)
    
    if interceptorsNeeded <= 0 then
        log(coalitionName .. " Squadron " .. squadron.displayName .. " has no aircraft to launch")
        return
    end
    
    -- Launch multiple interceptors to match threat
    local spawn = SPAWN:New(squadron.templateName)
    if not spawn then
        log("ERROR: Failed to create SPAWN object for " .. coalitionName .. " " .. squadron.templateName)
        return
    end
    
    local interceptors = {}
    
    for i = 1, interceptorsNeeded do
        local interceptor = spawn:Spawn()
        
        if interceptor then
            table.insert(interceptors, interceptor)
            
            -- Wait a moment for initialization
            SCHEDULER:New(nil, function()
                if interceptor and interceptor:IsAlive() then
                    -- Set aggressive AI
                    interceptor:OptionROEOpenFire()
                    interceptor:OptionROTVertical()
                    
                    -- Route to threat
                    local currentThreatCoord = threatGroup:GetCoordinate()
                    if currentThreatCoord then
                        local interceptCoord = currentThreatCoord:SetAltitude(squadron.altitude * 0.3048) -- Convert feet to meters
                        interceptor:RouteAirTo(interceptCoord, squadron.speed * 0.5144, "BARO") -- Convert knots to m/s
                        
                        -- Attack the threat
                        local attackTask = {
                            id = 'AttackGroup',
                            params = {
                                groupId = threatGroup:GetID(),
                                weaponType = 'Auto',
                                attackQtyLimit = 0,
                                priority = 1
                            }
                        }
                        interceptor:PushTask(attackTask, 1)
                    end
                end
            end, {}, 3)
            
            -- Track the interceptor with squadron info
            activeInterceptors[coalitionKey][interceptor:GetName()] = {
                group = interceptor,
                squadron = squadron.templateName,
                displayName = squadron.displayName
            }
            
            -- Emergency cleanup (safety net)
            SCHEDULER:New(nil, function()
                if activeInterceptors[coalitionKey][interceptor:GetName()] then
                    log("Emergency cleanup of " .. coalitionName .. " " .. interceptor:GetName() .. " (should have RTB'd)")
                    activeInterceptors[coalitionKey][interceptor:GetName()] = nil
                end
            end, {}, coalitionSettings.emergencyCleanupTime)
        end
    end
    
    -- Log the launch and track assignment
    if #interceptors > 0 then
        -- Decrement squadron aircraft count
        local currentCount = squadronAircraftCounts[coalitionKey][squadron.templateName] or 0
        squadronAircraftCounts[coalitionKey][squadron.templateName] = math.max(0, currentCount - #interceptors)
        local remainingCount = squadronAircraftCounts[coalitionKey][squadron.templateName]
        
        log("Launched " .. #interceptors .. " x " .. coalitionName .. " " .. squadron.displayName .. " to intercept " .. 
            threatSize .. " x " .. threatName .. " (" .. zoneDescription .. ", ratio: " .. string.format("%.1f", finalInterceptRatio) .. 
            ", remaining: " .. remainingCount .. "/" .. squadron.aircraft .. ")")
        assignedThreats[coalitionKey][threatName] = interceptors
        lastLaunchTime[coalitionKey][threatName] = timer.getTime()
        
        -- Apply cooldown immediately when squadron launches
        local currentTime = timer.getTime()
        squadronCooldowns[coalitionKey][squadron.templateName] = currentTime + coalitionSettings.squadronCooldown
        local cooldownMinutes = coalitionSettings.squadronCooldown / 60
        log(coalitionName .. " Squadron " .. squadron.displayName .. " LAUNCHED! Applying " .. cooldownMinutes .. " minute cooldown")
    end
end

-- Main threat detection loop for coalition
local function detectThreatsForCoalition(coalitionSide)
    local coalitionSettings, coalitionName = getCoalitionSettings(coalitionSide)
    local enemyCoalition = (coalitionSide == coalition.side.RED) and "blue" or "red"
    local coalitionKey = (coalitionSide == coalition.side.RED) and "red" or "blue"
    
    log("Scanning for " .. coalitionName .. " threats...", true)
    
    -- Clean up dead threats from tracking
    local currentThreats = {}
    
    -- Find all enemy aircraft using cached set for performance
    local cacheKey = enemyCoalition .. "Aircraft"
    if not cachedSets[cacheKey] then
        cachedSets[cacheKey] = SET_GROUP:New():FilterCoalitions(enemyCoalition):FilterCategoryAirplane():FilterStart()
    end
    local enemyAircraft = cachedSets[cacheKey]
    local threatCount = 0
    
    enemyAircraft:ForEach(function(enemyGroup)
        if enemyGroup and enemyGroup:IsAlive() then
            threatCount = threatCount + 1
            currentThreats[enemyGroup:GetName()] = true
            log("Found " .. coalitionName .. " threat: " .. enemyGroup:GetName() .. " (" .. enemyGroup:GetTypeName() .. ")", true)
            
            -- Launch interceptor for this threat
            launchInterceptor(enemyGroup, coalitionSide)
        end
    end)
    
    -- Clean up assignments for threats that no longer exist and send interceptors home
    for threatName, assignedInterceptors in pairs(assignedThreats[coalitionKey]) do
        if not currentThreats[threatName] then
            log("Threat " .. threatName .. " eliminated, sending " .. coalitionName .. " interceptors home...")
            
            -- Send assigned interceptors back to base
            if type(assignedInterceptors) == "table" then
                for _, interceptor in pairs(assignedInterceptors) do
                    if interceptor and interceptor:IsAlive() then
                        sendInterceptorHome(interceptor, coalitionSide)
                    end
                end
            else
                -- Handle legacy single interceptor assignment
                if assignedInterceptors and assignedInterceptors:IsAlive() then
                    sendInterceptorHome(assignedInterceptors, coalitionSide)
                end
            end
            
            assignedThreats[coalitionKey][threatName] = nil
        end
    end
    
    -- Count assigned threats
    local assignedCount = 0
    for _ in pairs(assignedThreats[coalitionKey]) do assignedCount = assignedCount + 1 end
    
    log(coalitionName .. " scan complete: " .. threatCount .. " threats, " .. countActiveFighters(coalitionSide) .. " active fighters, " .. 
        assignedCount .. " assigned")
end

-- Main threat detection loop - calls both coalitions
local function detectThreats()
    if TADC_SETTINGS.enableRed then
        detectThreatsForCoalition(coalition.side.RED)
    end
    
    if TADC_SETTINGS.enableBlue then
        detectThreatsForCoalition(coalition.side.BLUE)
    end
end

-- Monitor interceptor groups for cleanup when destroyed
local function monitorInterceptors()
    -- Check RED interceptors
    if TADC_SETTINGS.enableRed then
        for interceptorName, interceptorData in pairs(activeInterceptors.red) do
            if interceptorData and interceptorData.group then
                if not interceptorData.group:IsAlive() then
                    -- Interceptor group is destroyed - just clean up tracking
                    local displayName = interceptorData.displayName
                    log("RED Interceptor from " .. displayName .. " destroyed: " .. interceptorName, true)
                    
                    -- Remove from active tracking
                    activeInterceptors.red[interceptorName] = nil
                end
            end
        end
    end
    
    -- Check BLUE interceptors
    if TADC_SETTINGS.enableBlue then
        for interceptorName, interceptorData in pairs(activeInterceptors.blue) do
            if interceptorData and interceptorData.group then
                if not interceptorData.group:IsAlive() then
                    -- Interceptor group is destroyed - just clean up tracking
                    local displayName = interceptorData.displayName
                    log("BLUE Interceptor from " .. displayName .. " destroyed: " .. interceptorName, true)
                    
                    -- Remove from active tracking
                    activeInterceptors.blue[interceptorName] = nil
                end
            end
        end
    end
end

-- Periodic airbase status check
local function checkAirbaseStatus()
    log("=== AIRBASE STATUS REPORT ===")
    
    local redUsableCount = 0
    local blueUsableCount = 0
    local currentTime = timer.getTime()
    
    -- Check RED airbases
    if TADC_SETTINGS.enableRed then
        log("=== RED COALITION STATUS ===")
        for _, squadron in pairs(RED_SQUADRON_CONFIG) do
            local usable, status = isAirbaseUsable(squadron.airbaseName, coalition.side.RED)
            
            -- Add aircraft count to status
            local aircraftCount = squadronAircraftCounts.red[squadron.templateName] or 0
            local maxAircraft = squadron.aircraft
            local aircraftStatus = " Aircraft: " .. aircraftCount .. "/" .. maxAircraft
            
            -- Add zone information if configured
            local zoneStatus = ""
            if squadron.primaryZone or squadron.secondaryZone or squadron.tertiaryZone then
                local zones = {}
                if squadron.primaryZone then table.insert(zones, "P:" .. squadron.primaryZone) end
                if squadron.secondaryZone then table.insert(zones, "S:" .. squadron.secondaryZone) end
                if squadron.tertiaryZone then table.insert(zones, "T:" .. squadron.tertiaryZone) end
                zoneStatus = " Zones: " .. table.concat(zones, " ")
            end
            
            -- Check if squadron is on cooldown
            local cooldownStatus = ""
            if squadronCooldowns.red[squadron.templateName] then
                local cooldownEnd = squadronCooldowns.red[squadron.templateName]
                if currentTime < cooldownEnd then
                    local timeLeft = math.ceil((cooldownEnd - currentTime) / 60)
                    cooldownStatus = " (COOLDOWN: " .. timeLeft .. "m)"
                end
            end
            
            local fullStatus = status .. aircraftStatus .. zoneStatus .. cooldownStatus
            
            if usable and cooldownStatus == "" and aircraftCount > 0 then
                redUsableCount = redUsableCount + 1
                log("✓ " .. squadron.airbaseName .. " - " .. fullStatus)
            else
                log("✗ " .. squadron.airbaseName .. " - " .. fullStatus)
            end
        end
        log("RED Status: " .. redUsableCount .. "/" .. #RED_SQUADRON_CONFIG .. " airbases operational")
    end
    
    -- Check BLUE airbases
    if TADC_SETTINGS.enableBlue then
        log("=== BLUE COALITION STATUS ===")
        for _, squadron in pairs(BLUE_SQUADRON_CONFIG) do
            local usable, status = isAirbaseUsable(squadron.airbaseName, coalition.side.BLUE)
            
            -- Add aircraft count to status
            local aircraftCount = squadronAircraftCounts.blue[squadron.templateName] or 0
            local maxAircraft = squadron.aircraft
            local aircraftStatus = " Aircraft: " .. aircraftCount .. "/" .. maxAircraft
            
            -- Add zone information if configured
            local zoneStatus = ""
            if squadron.primaryZone or squadron.secondaryZone or squadron.tertiaryZone then
                local zones = {}
                if squadron.primaryZone then table.insert(zones, "P:" .. squadron.primaryZone) end
                if squadron.secondaryZone then table.insert(zones, "S:" .. squadron.secondaryZone) end
                if squadron.tertiaryZone then table.insert(zones, "T:" .. squadron.tertiaryZone) end
                zoneStatus = " Zones: " .. table.concat(zones, " ")
            end
            
            -- Check if squadron is on cooldown
            local cooldownStatus = ""
            if squadronCooldowns.blue[squadron.templateName] then
                local cooldownEnd = squadronCooldowns.blue[squadron.templateName]
                if currentTime < cooldownEnd then
                    local timeLeft = math.ceil((cooldownEnd - currentTime) / 60)
                    cooldownStatus = " (COOLDOWN: " .. timeLeft .. "m)"
                end
            end
            
            local fullStatus = status .. aircraftStatus .. zoneStatus .. cooldownStatus
            
            if usable and cooldownStatus == "" and aircraftCount > 0 then
                blueUsableCount = blueUsableCount + 1
                log("✓ " .. squadron.airbaseName .. " - " .. fullStatus)
            else
                log("✗ " .. squadron.airbaseName .. " - " .. fullStatus)
            end
        end
        log("BLUE Status: " .. blueUsableCount .. "/" .. #BLUE_SQUADRON_CONFIG .. " airbases operational")
    end
end

-- Cleanup old delivery records to prevent memory buildup
local function cleanupOldDeliveries()
    if _G.processedDeliveries then
        local currentTime = timer.getTime()
        local cleanupAge = 3600 -- Remove delivery records older than 1 hour
        local removedCount = 0
        
        for deliveryKey, timestamp in pairs(_G.processedDeliveries) do
            if currentTime - timestamp > cleanupAge then
                _G.processedDeliveries[deliveryKey] = nil
                removedCount = removedCount + 1
            end
        end
        
        if removedCount > 0 then
            log("Cleaned up " .. removedCount .. " old cargo delivery records", true)
        end
    end
end

-- System initialization
local function initializeSystem()
    log("Universal Dual-Coalition TADC starting...")
    
    -- Create zones from late-activated helicopter units (MOOSE method)
    -- This allows using helicopters named "RED_BORDER", "BLUE_BORDER" etc. as zone markers
    -- Uses the helicopter's waypoints as polygon vertices (standard MOOSE method)
    local function createZoneFromUnit(unitName)
        -- Try to find as a group first (this is the standard MOOSE way)
        local group = GROUP:FindByName(unitName)
        if group then
            -- Create polygon zone using the group's waypoints as vertices
            local zone = ZONE_POLYGON:NewFromGroupName(unitName, unitName)
            if zone then
                log("Created polygon zone '" .. unitName .. "' from helicopter waypoints")
                return zone
            else
                log("Warning: Could not create polygon zone from group '" .. unitName .. "' - check waypoints")
            end
        else
            log("Warning: No group named '" .. unitName .. "' found for zone creation")
        end
        return nil
    end
    
    -- Try to create zones for all configured zone names
    local zoneNames = {}
    for _, squadron in pairs(RED_SQUADRON_CONFIG) do
        if squadron.primaryZone then table.insert(zoneNames, squadron.primaryZone) end
        if squadron.secondaryZone then table.insert(zoneNames, squadron.secondaryZone) end
        if squadron.tertiaryZone then table.insert(zoneNames, squadron.tertiaryZone) end
    end
    for _, squadron in pairs(BLUE_SQUADRON_CONFIG) do
        if squadron.primaryZone then table.insert(zoneNames, squadron.primaryZone) end
        if squadron.secondaryZone then table.insert(zoneNames, squadron.secondaryZone) end
        if squadron.tertiaryZone then table.insert(zoneNames, squadron.tertiaryZone) end
    end
    
    -- Create zones from helicopters
    for _, zoneName in ipairs(zoneNames) do
        if not ZONE:FindByName(zoneName) then
            createZoneFromUnit(zoneName)
        end
    end
    
    -- Validate configuration
    if not validateConfiguration() then
        log("System startup aborted due to configuration errors!")
        return false
    end
    
    -- Log enabled coalitions
    local enabledCoalitions = {}
    if TADC_SETTINGS.enableRed then
        table.insert(enabledCoalitions, "RED (" .. #RED_SQUADRON_CONFIG .. " squadrons)")
    end
    if TADC_SETTINGS.enableBlue then
        table.insert(enabledCoalitions, "BLUE (" .. #BLUE_SQUADRON_CONFIG .. " squadrons)")
    end
    log("Enabled coalitions: " .. table.concat(enabledCoalitions, ", "))
    
    -- Log initial squadron aircraft counts
    if TADC_SETTINGS.enableRed then
        for _, squadron in pairs(RED_SQUADRON_CONFIG) do
            local count = squadronAircraftCounts.red[squadron.templateName]
            log("Initial RED: " .. squadron.displayName .. " has " .. count .. "/" .. squadron.aircraft .. " aircraft")
        end
    end
    
    if TADC_SETTINGS.enableBlue then
        for _, squadron in pairs(BLUE_SQUADRON_CONFIG) do
            local count = squadronAircraftCounts.blue[squadron.templateName]
            log("Initial BLUE: " .. squadron.displayName .. " has " .. count .. "/" .. squadron.aircraft .. " aircraft")
        end
    end
    
    -- Start schedulers
    SCHEDULER:New(nil, detectThreats, {}, 5, TADC_SETTINGS.checkInterval)
    SCHEDULER:New(nil, monitorInterceptors, {}, 10, TADC_SETTINGS.monitorInterval)
    SCHEDULER:New(nil, checkAirbaseStatus, {}, 30, TADC_SETTINGS.statusReportInterval)
    SCHEDULER:New(nil, monitorCargoReplenishment, {}, 15, TADC_SETTINGS.cargoCheckInterval)
    SCHEDULER:New(nil, cleanupOldDeliveries, {}, 60, 3600) -- Cleanup old delivery records every hour

    -- Start periodic squadron summary broadcast
    SCHEDULER:New(nil, broadcastSquadronSummary, {}, 10, TADC_SETTINGS.squadronSummaryInterval)
    
    log("Universal Dual-Coalition TADC operational!")
    log("RED Replenishment: " .. TADC_SETTINGS.red.cargoReplenishmentAmount .. " aircraft per cargo delivery")
    log("BLUE Replenishment: " .. TADC_SETTINGS.blue.cargoReplenishmentAmount .. " aircraft per cargo delivery")
    
    return true
end


initializeSystem()

-- Add F10 menu command for squadron summary
local menuRoot = MENU_MISSION:New("TADC Utilities")

MENU_COALITION_COMMAND:New(coalition.side.RED, "Show Squadron Resource Summary", menuRoot, function()
    local summary = getSquadronResourceSummary(coalition.side.RED)
    MESSAGE:New(summary, 20):ToCoalition(coalition.side.RED)
end)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Show Squadron Resource Summary", menuRoot, function()
    local summary = getSquadronResourceSummary(coalition.side.BLUE)
    MESSAGE:New(summary, 20):ToCoalition(coalition.side.BLUE)
end)

-- 1. Show Airbase Status Report
MENU_COALITION_COMMAND:New(coalition.side.RED, "Show Airbase Status Report", menuRoot, function()
    local report = "=== RED Airbase Status ===\n"
    for _, squadron in pairs(RED_SQUADRON_CONFIG) do
        local usable, status = isAirbaseUsable(squadron.airbaseName, coalition.side.RED)
        local aircraftCount = squadronAircraftCounts.red[squadron.templateName] or 0
        local maxAircraft = squadron.aircraft
        local cooldown = squadronCooldowns.red[squadron.templateName]
        local cooldownStatus = ""
        if cooldown then
            local timeLeft = math.ceil((cooldown - timer.getTime()) / 60)
            if timeLeft > 0 then cooldownStatus = " (COOLDOWN: " .. timeLeft .. "m)" end
        end
        report = report .. string.format("%s: %s | Aircraft: %d/%d%s\n", squadron.displayName, status, aircraftCount, maxAircraft, cooldownStatus)
    end
    MESSAGE:New(report, 20):ToCoalition(coalition.side.RED)
end)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Show Airbase Status Report", menuRoot, function()
    local report = "=== BLUE Airbase Status ===\n"
    for _, squadron in pairs(BLUE_SQUADRON_CONFIG) do
        local usable, status = isAirbaseUsable(squadron.airbaseName, coalition.side.BLUE)
        local aircraftCount = squadronAircraftCounts.blue[squadron.templateName] or 0
        local maxAircraft = squadron.aircraft
        local cooldown = squadronCooldowns.blue[squadron.templateName]
        local cooldownStatus = ""
        if cooldown then
            local timeLeft = math.ceil((cooldown - timer.getTime()) / 60)
            if timeLeft > 0 then cooldownStatus = " (COOLDOWN: " .. timeLeft .. "m)" end
        end
        report = report .. string.format("%s: %s | Aircraft: %d/%d%s\n", squadron.displayName, status, aircraftCount, maxAircraft, cooldownStatus)
    end
    MESSAGE:New(report, 20):ToCoalition(coalition.side.BLUE)
end)

-- 2. Show Active Interceptors
MENU_COALITION_COMMAND:New(coalition.side.RED, "Show Active Interceptors", menuRoot, function()
    local lines = {"Active RED Interceptors:"}
    for name, data in pairs(activeInterceptors.red) do
        if data and data.group and data.group:IsAlive() then
            table.insert(lines, string.format("%s (Squadron: %s, Threat: %s)", name, data.displayName or data.squadron, assignedThreats.red[name] or "N/A"))
        end
    end
    MESSAGE:New(table.concat(lines, "\n"), 20):ToCoalition(coalition.side.RED)
end)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Show Active Interceptors", menuRoot, function()
    local lines = {"Active BLUE Interceptors:"}
    for name, data in pairs(activeInterceptors.blue) do
        if data and data.group and data.group:IsAlive() then
            table.insert(lines, string.format("%s (Squadron: %s, Threat: %s)", name, data.displayName or data.squadron, assignedThreats.blue[name] or "N/A"))
        end
    end
    MESSAGE:New(table.concat(lines, "\n"), 20):ToCoalition(coalition.side.BLUE)
end)

-- 3. Show Threat Summary
MENU_COALITION_COMMAND:New(coalition.side.RED, "Show Threat Summary", menuRoot, function()
    local lines = {"Detected BLUE Threats:"}
    if cachedSets.blueAircraft then
        cachedSets.blueAircraft:ForEach(function(group)
            if group and group:IsAlive() then
                table.insert(lines, string.format("%s (Size: %d)", group:GetName(), group:GetSize()))
            end
        end)
    end
    MESSAGE:New(table.concat(lines, "\n"), 20):ToCoalition(coalition.side.RED)
end)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Show Threat Summary", menuRoot, function()
    local lines = {"Detected RED Threats:"}
    if cachedSets.redAircraft then
        cachedSets.redAircraft:ForEach(function(group)
            if group and group:IsAlive() then
                table.insert(lines, string.format("%s (Size: %d)", group:GetName(), group:GetSize()))
            end
        end)
    end
    MESSAGE:New(table.concat(lines, "\n"), 20):ToCoalition(coalition.side.BLUE)
end)

-- 4. Request Immediate Squadron Summary Broadcast
MENU_COALITION_COMMAND:New(coalition.side.RED, "Broadcast Squadron Summary Now", menuRoot, function()
    local summary = getSquadronResourceSummary(coalition.side.RED)
    MESSAGE:New(summary, 20):ToCoalition(coalition.side.RED)
end)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Broadcast Squadron Summary Now", menuRoot, function()
    local summary = getSquadronResourceSummary(coalition.side.BLUE)
    MESSAGE:New(summary, 20):ToCoalition(coalition.side.BLUE)
end)

-- 5. Show Cargo Delivery Log
MENU_COALITION_COMMAND:New(coalition.side.RED, "Show Cargo Delivery Log", menuRoot, function()
    local lines = {"Recent RED Cargo Deliveries:"}
    if _G.processedDeliveries then
        for key, timestamp in pairs(_G.processedDeliveries) do
            if string.find(key, "RED") then
                table.insert(lines, string.format("%s at %d", key, timestamp))
            end
        end
    end
    MESSAGE:New(table.concat(lines, "\n"), 20):ToCoalition(coalition.side.RED)
end)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Show Cargo Delivery Log", menuRoot, function()
    local lines = {"Recent BLUE Cargo Deliveries:"}
    if _G.processedDeliveries then
        for key, timestamp in pairs(_G.processedDeliveries) do
            if string.find(key, "BLUE") then
                table.insert(lines, string.format("%s at %d", key, timestamp))
            end
        end
    end
    MESSAGE:New(table.concat(lines, "\n"), 20):ToCoalition(coalition.side.BLUE)
end)

-- 6. Show Zone Coverage Map
MENU_COALITION_COMMAND:New(coalition.side.RED, "Show Zone Coverage Map", menuRoot, function()
    local lines = {"RED Zone Coverage:"}
    for _, squadron in pairs(RED_SQUADRON_CONFIG) do
        local zones = {}
        if squadron.primaryZone then table.insert(zones, "Primary: " .. squadron.primaryZone) end
        if squadron.secondaryZone then table.insert(zones, "Secondary: " .. squadron.secondaryZone) end
        if squadron.tertiaryZone then table.insert(zones, "Tertiary: " .. squadron.tertiaryZone) end
        table.insert(lines, string.format("%s: %s", squadron.displayName, table.concat(zones, ", ")))
    end
    MESSAGE:New(table.concat(lines, "\n"), 20):ToCoalition(coalition.side.RED)
end)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Show Zone Coverage Map", menuRoot, function()
    local lines = {"BLUE Zone Coverage:"}
    for _, squadron in pairs(BLUE_SQUADRON_CONFIG) do
        local zones = {}
        if squadron.primaryZone then table.insert(zones, "Primary: " .. squadron.primaryZone) end
        if squadron.secondaryZone then table.insert(zones, "Secondary: " .. squadron.secondaryZone) end
        if squadron.tertiaryZone then table.insert(zones, "Tertiary: " .. squadron.tertiaryZone) end
        table.insert(lines, string.format("%s: %s", squadron.displayName, table.concat(zones, ", ")))
    end
    MESSAGE:New(table.concat(lines, "\n"), 20):ToCoalition(coalition.side.BLUE)
end)

-- 7. Request Emergency Cleanup (admin/global)
MENU_MISSION_COMMAND:New("Emergency Cleanup Interceptors", menuRoot, function()
    local cleaned = 0
    for _, interceptors in pairs(activeInterceptors.red) do
        if interceptors and interceptors.group and not interceptors.group:IsAlive() then
            interceptors.group = nil
            cleaned = cleaned + 1
        end
    end
    for _, interceptors in pairs(activeInterceptors.blue) do
        if interceptors and interceptors.group and not interceptors.group:IsAlive() then
            interceptors.group = nil
            cleaned = cleaned + 1
        end
    end
    MESSAGE:New("Cleaned up " .. cleaned .. " dead interceptor groups.", 20):ToAll()
end)

-- 9. Show System Uptime/Status
local systemStartTime = timer.getTime()
MENU_MISSION_COMMAND:New("Show TADC System Status", menuRoot, function()
    local uptime = math.floor((timer.getTime() - systemStartTime) / 60)
    local status = string.format("TADC System Uptime: %d minutes\nCheck Interval: %ds\nMonitor Interval: %ds\nStatus Report Interval: %ds\nSquadron Summary Interval: %ds\nCargo Check Interval: %ds", uptime, TADC_SETTINGS.checkInterval, TADC_SETTINGS.monitorInterval, TADC_SETTINGS.statusReportInterval, TADC_SETTINGS.squadronSummaryInterval, TADC_SETTINGS.cargoCheckInterval)
    MESSAGE:New(status, 20):ToAll()
end)



