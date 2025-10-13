--[[
═══════════════════════════════════════════════════════════════════════════════
                              UNIVERSAL TADC
                  Dual-Coalition Tactical Air Defense Controller
═══════════════════════════════════════════════════════════════════════════════

DESCRIPTION:
This script provides an automated air defense system for BOTH RED and BLUE coalitions.
Each side detects enemy aircraft and launches interceptors independently. Perfect for
creating dynamic air-to-air combat scenarios or testing AI vs AI engagements.

FEATURES:
• Dual-coalition support (RED and BLUE operate independently)
• Automatic threat detection and response for both sides
• Multiple squadron management with individual cooldowns per side
• Aircraft inventory tracking and cargo replenishment
• Configurable intercept ratios and response patterns per coalition
• Smart interceptor routing and RTB behavior
• Airbase status monitoring (operational/captured/destroyed)
• Comprehensive logging and status reports
• Asymmetric warfare support (different capabilities per side)

SETUP INSTRUCTIONS:
1. Create fighter aircraft templates for BOTH coalitions in the mission editor
2. Configure RED squadrons in RED_SQUADRON_CONFIG section below
3. Configure BLUE squadrons in BLUE_SQUADRON_CONFIG section below
4. Set desired behavior for each coalition in TADC_SETTINGS
5. Add this script as a "DO SCRIPT" trigger at mission start
6. Optionally create cargo aircraft with standard naming for replenishment

REQUIREMENTS:
• MOOSE framework (https://github.com/FlightControl-Master/MOOSE)
• Fighter aircraft templates must exist for each coalition
• Airbases must be under correct coalition control to launch

TACTICAL SCENARIOS:
• Balanced air warfare (equal capabilities)
• Asymmetric scenarios (one side stronger/weaker)
• Training missions (AI vs AI for observation)
• Dynamic frontline battles with air support

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
    cargoCheckInterval = 15,     -- How often to check for cargo deliveries (seconds)
    
    -- RED Coalition Settings
    red = {
        maxActiveCAP = 24,           -- Maximum RED fighters airborne at once
        squadronCooldown = 900,      -- RED cooldown after squadron launch (seconds)
        interceptRatio = 0.8,        -- RED interceptors per threat aircraft
        cargoReplenishmentAmount = 4, -- RED aircraft added per cargo delivery
        emergencyCleanupTime = 7200, -- RED force cleanup time (seconds)
        rtbFlightBuffer = 300,       -- RED extra landing time before cleanup (seconds)
    },
    
    -- BLUE Coalition Settings  
    blue = {
        maxActiveCAP = 24,           -- Maximum BLUE fighters airborne at once
        squadronCooldown = 900,      -- BLUE cooldown after squadron launch (seconds)
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
    },
    ]]
    
    -- ADD YOUR RED SQUADRONS HERE
    {
        templateName = "RED_CAP_SQUADRON_1",     -- Change to your RED template name
        displayName = "RED Squadron 1",          -- Change to your preferred name
        airbaseName = "YOUR_RED_AIRBASE_1",      -- Change to your RED airbase
        aircraft = 12,                           -- Adjust aircraft count
        skill = AI.Skill.GOOD,                   -- AVERAGE, GOOD, HIGH, EXCELLENT
        altitude = 20000,                        -- Patrol altitude (feet)
        speed = 350,                             -- Patrol speed (knots)
        patrolTime = 25,                         -- Time on station (minutes)
        type = "FIGHTER"
    },
    
    {
        templateName = "RED_CAP_SQUADRON_2",     -- Change to your RED template name
        displayName = "RED Squadron 2",          -- Change to your preferred name
        airbaseName = "YOUR_RED_AIRBASE_2",      -- Change to your RED airbase
        aircraft = 16,                           -- Adjust aircraft count
        skill = AI.Skill.GOOD,                   -- AVERAGE, GOOD, HIGH, EXCELLENT
        altitude = 25000,                        -- Patrol altitude (feet)
        speed = 400,                             -- Patrol speed (knots)
        patrolTime = 30,                         -- Time on station (minutes)
        type = "FIGHTER"
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
        skill = AI.Skill.EXCELLENT,             -- AI skill level
        altitude = 22000,                        -- Patrol altitude (feet)
        speed = 380,                             -- Patrol speed (knots)
        patrolTime = 28,                         -- Time on station (minutes)
        type = "FIGHTER"                         -- Aircraft type
    },
    ]]
    
    -- ADD YOUR BLUE SQUADRONS HERE
    {
        templateName = "BLUE_CAP_SQUADRON_1",    -- Change to your BLUE template name
        displayName = "BLUE Squadron 1",         -- Change to your preferred name
        airbaseName = "YOUR_BLUE_AIRBASE_1",     -- Change to your BLUE airbase
        aircraft = 14,                           -- Adjust aircraft count
        skill = AI.Skill.GOOD,                   -- AVERAGE, GOOD, HIGH, EXCELLENT
        altitude = 22000,                        -- Patrol altitude (feet)
        speed = 380,                             -- Patrol speed (knots)
        patrolTime = 28,                         -- Time on station (minutes)
        type = "FIGHTER"
    },
    
    {
        templateName = "BLUE_CAP_SQUADRON_2",    -- Change to your BLUE template name
        displayName = "BLUE Squadron 2",         -- Change to your preferred name
        airbaseName = "YOUR_BLUE_AIRBASE_2",     -- Change to your BLUE airbase
        aircraft = 18,                           -- Adjust aircraft count
        skill = AI.Skill.EXCELLENT,             -- AVERAGE, GOOD, HIGH, EXCELLENT
        altitude = 18000,                        -- Patrol altitude (feet)
        speed = 320,                             -- Patrol speed (knots)
        patrolTime = 22,                         -- Time on station (minutes)
        type = "FIGHTER"
    },
}

--[[
═══════════════════════════════════════════════════════════════════════════════
                            ADVANCED SETTINGS
═══════════════════════════════════════════════════════════════════════════════

These settings control more detailed behavior. Most users won't need to change these.
]]

local ADVANCED_SETTINGS = {
    -- Cargo aircraft detection patterns (aircraft with these names will replenish squadrons)
    cargoPatterns = {"CARGO", "TRANSPORT", "C130", "C-130", "AN26", "AN-26"},
    
    -- Distance from airbase to consider cargo "landed" (meters)
    cargoLandingDistance = 3000,
    
    -- Velocity below which aircraft is considered "landed" (km/h)
    cargoLandedVelocity = 5,
    
    -- RTB settings
    rtbAltitude = 3000,    -- Return to base altitude (feet)
    rtbSpeed = 250,        -- Return to base speed (knots)
    
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
            end
        end
    end
    
    -- Report errors
    if #errors > 0 then
        log("CONFIGURATION ERRORS DETECTED:")
        for _, error in pairs(errors) do
            log("  ✗ " .. error)
        end
        log("Please fix configuration before using Universal TADC!")
        return false
    else
        log("Configuration validation passed ✓")
        return true
    end
end

-- Monitor cargo aircraft landings for squadron replenishment
local function monitorCargoReplenishment()
    -- Process RED cargo aircraft
    if TADC_SETTINGS.enableRed then
        local redCargo = SET_GROUP:New():FilterCoalitions("red"):FilterCategoryAirplane():FilterStart()
        
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
                                    -- Check if we haven't already processed this delivery
                                    local deliveryKey = cargoName .. "_RED_" .. squadron.airbaseName
                                    if not _G.processedDeliveries then
                                        _G.processedDeliveries = {}
                                    end
                                    
                                    if not _G.processedDeliveries[deliveryKey] then
                                        -- Process replenishment
                                        local currentCount = squadronAircraftCounts.red[squadron.templateName] or 0
                                        local maxCount = squadron.aircraft
                                        local newCount = math.min(currentCount + TADC_SETTINGS.red.cargoReplenishmentAmount, maxCount)
                                        local actualAdded = newCount - currentCount
                                        
                                        if actualAdded > 0 then
                                            squadronAircraftCounts.red[squadron.templateName] = newCount
                                            log("RED CARGO DELIVERY: " .. cargoName .. " delivered " .. actualAdded .. 
                                                " aircraft to " .. squadron.displayName .. 
                                                " (" .. newCount .. "/" .. maxCount .. ")")
                                            
                                            -- Mark delivery as processed
                                            _G.processedDeliveries[deliveryKey] = timer.getTime()
                                        else
                                            log("RED CARGO DELIVERY: " .. squadron.displayName .. " already at max capacity", true)
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
        local blueCargo = SET_GROUP:New():FilterCoalitions("blue"):FilterCategoryAirplane():FilterStart()
        
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
                                    -- Check if we haven't already processed this delivery
                                    local deliveryKey = cargoName .. "_BLUE_" .. squadron.airbaseName
                                    if not _G.processedDeliveries then
                                        _G.processedDeliveries = {}
                                    end
                                    
                                    if not _G.processedDeliveries[deliveryKey] then
                                        -- Process replenishment
                                        local currentCount = squadronAircraftCounts.blue[squadron.templateName] or 0
                                        local maxCount = squadron.aircraft
                                        local newCount = math.min(currentCount + TADC_SETTINGS.blue.cargoReplenishmentAmount, maxCount)
                                        local actualAdded = newCount - currentCount
                                        
                                        if actualAdded > 0 then
                                            squadronAircraftCounts.blue[squadron.templateName] = newCount
                                            log("BLUE CARGO DELIVERY: " .. cargoName .. " delivered " .. actualAdded .. 
                                                " aircraft to " .. squadron.displayName .. 
                                                " (" .. newCount .. "/" .. maxCount .. ")")
                                            
                                            -- Mark delivery as processed
                                            _G.processedDeliveries[deliveryKey] = timer.getTime()
                                        else
                                            log("BLUE CARGO DELIVERY: " .. squadron.displayName .. " already at max capacity", true)
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

-- Send interceptor back to base (dual coalition)
local function sendInterceptorHome(interceptor, coalitionSide)
    if not interceptor or not interceptor:IsAlive() then
        return
    end
    
    -- Find nearest friendly airbase
    local interceptorCoord = interceptor:GetCoordinate()
    local nearestAirbase = nil
    local shortestDistance = math.huge
    
    -- Check all squadron airbases to find the nearest one that's still friendly
    for _, squadron in pairs(SQUADRON_CONFIG) do
        local airbase = AIRBASE:FindByName(squadron.airbaseName)
        if airbase and airbase:GetCoalition() == coalition.side.RED and airbase:IsAlive() then
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
        
        log("Sending " .. interceptor:GetName() .. " back to " .. nearestAirbase:GetName(), true)
        
        -- Schedule cleanup after they should have landed
        local flightTime = math.ceil(shortestDistance / (ADVANCED_SETTINGS.rtbSpeed * 0.5144)) + TADC_SETTINGS.rtbFlightBuffer
        SCHEDULER:New(nil, function()
            if activeInterceptors[interceptor:GetName()] then
                activeInterceptors[interceptor:GetName()] = nil
                log("Cleaned up " .. interceptor:GetName() .. " after RTB", true)
            end
        end, {}, flightTime)
    else
        log("No friendly airbase found for " .. interceptor:GetName() .. ", will clean up normally")
    end
end

-- Check if airbase is still usable
local function isAirbaseUsable(airbaseName)
    local airbase = AIRBASE:FindByName(airbaseName)
    if not airbase then
        return false, "not found"
    elseif airbase:GetCoalition() ~= coalition.side.RED then
        return false, "captured by " .. (airbase:GetCoalition() == coalition.side.BLUE and "Blue" or "Neutral")
    elseif not airbase:IsAlive() then
        return false, "destroyed"
    else
        return true, "operational"
    end
end

-- Count active red fighters
local function countActiveFighters()
    local count = 0
    for _, interceptorData in pairs(activeInterceptors) do
        if interceptorData and interceptorData.group and interceptorData.group:IsAlive() then
            count = count + interceptorData.group:GetSize()
        end
    end
    return count
end

-- Find best squadron to launch
local function findBestSquadron(threatCoord)
    local bestSquadron = nil
    local shortestDistance = math.huge
    local currentTime = timer.getTime()
    
    for _, squadron in pairs(SQUADRON_CONFIG) do
        -- Check if squadron is on cooldown
        local squadronAvailable = true
        if squadronCooldowns[squadron.templateName] then
            local cooldownEnd = squadronCooldowns[squadron.templateName]
            if currentTime < cooldownEnd then
                local timeLeft = math.ceil((cooldownEnd - currentTime) / 60)
                log("Squadron " .. squadron.displayName .. " on cooldown for " .. timeLeft .. " more minutes", true)
                squadronAvailable = false
            else
                -- Cooldown expired, remove it
                squadronCooldowns[squadron.templateName] = nil
                log("Squadron " .. squadron.displayName .. " cooldown expired, available for launch", true)
            end
        end
        
        if squadronAvailable then
            -- Check if squadron has available aircraft
            local availableAircraft = squadronAircraftCounts[squadron.templateName] or 0
            if availableAircraft <= 0 then
                log("Squadron " .. squadron.displayName .. " has no aircraft available (" .. availableAircraft .. "/" .. squadron.aircraft .. ")", true)
                squadronAvailable = false
            end
        end
        
        if squadronAvailable then
            -- Check if airbase is still under Red control
            local airbase = AIRBASE:FindByName(squadron.airbaseName)
            if not airbase then
                log("Warning: Airbase " .. squadron.airbaseName .. " not found")
            elseif airbase:GetCoalition() ~= coalition.side.RED then
                log("Warning: Airbase " .. squadron.airbaseName .. " no longer under Red control")
            elseif not airbase:IsAlive() then
                log("Warning: Airbase " .. squadron.airbaseName .. " is destroyed")
            else
                -- Airbase is valid, check if squadron template exists and can spawn
                local template = GROUP:FindByName(squadron.templateName)
                if template then
                    local airbaseCoord = template:GetCoordinate()
                    if airbaseCoord then
                        local distance = airbaseCoord:Get2DDistance(threatCoord)
                        if distance < shortestDistance then
                            shortestDistance = distance
                            bestSquadron = squadron
                        end
                    end
                else
                    log("Warning: Template " .. squadron.templateName .. " not found in mission", true)
                end
            end
        end
    end
    
    return bestSquadron
end

-- Launch interceptor
local function launchInterceptor(threatGroup)
    if not threatGroup or not threatGroup:IsAlive() then
        return
    end
    
    local threatCoord = threatGroup:GetCoordinate()
    local threatName = threatGroup:GetName()
    local threatSize = threatGroup:GetSize()
    
    -- Check if threat already has interceptors assigned
    if assignedThreats[threatName] then
        local assignedInterceptors = assignedThreats[threatName]
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
            assignedThreats[threatName] = nil
        end
    end
    
    -- Calculate how many interceptors to launch
    local interceptorsNeeded = math.max(threatSize, math.ceil(threatSize * TADC_SETTINGS.interceptRatio))
    
    -- Check if we have capacity
    if countActiveFighters() + interceptorsNeeded > TADC_SETTINGS.maxActiveCAP then
        interceptorsNeeded = TADC_SETTINGS.maxActiveCAP - countActiveFighters()
        if interceptorsNeeded <= 0 then
            log("Max fighters airborne, skipping launch")
            return
        end
    end
    
    -- Find best squadron
    local squadron = findBestSquadron(threatCoord)
    if not squadron then
        log("No squadron available")
        return
    end
    
    -- Limit interceptors to available aircraft
    local availableAircraft = squadronAircraftCounts[squadron.templateName] or 0
    interceptorsNeeded = math.min(interceptorsNeeded, availableAircraft)
    
    if interceptorsNeeded <= 0 then
        log("Squadron " .. squadron.displayName .. " has no aircraft to launch")
        return
    end
    
    -- Launch multiple interceptors to match threat
    local spawn = SPAWN:New(squadron.templateName)
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
            activeInterceptors[interceptor:GetName()] = {
                group = interceptor,
                squadron = squadron.templateName,
                displayName = squadron.displayName
            }
            
            -- Emergency cleanup (safety net)
            SCHEDULER:New(nil, function()
                if activeInterceptors[interceptor:GetName()] then
                    log("Emergency cleanup of " .. interceptor:GetName() .. " (should have RTB'd)")
                    activeInterceptors[interceptor:GetName()] = nil
                end
            end, {}, TADC_SETTINGS.emergencyCleanupTime)
        end
    end
    
    -- Log the launch and track assignment
    if #interceptors > 0 then
        -- Decrement squadron aircraft count
        local currentCount = squadronAircraftCounts[squadron.templateName] or 0
        squadronAircraftCounts[squadron.templateName] = math.max(0, currentCount - #interceptors)
        local remainingCount = squadronAircraftCounts[squadron.templateName]
        
        log("Launched " .. #interceptors .. " x " .. squadron.displayName .. " to intercept " .. 
            threatSize .. " x " .. threatName .. " (Remaining: " .. remainingCount .. "/" .. squadron.aircraft .. ")")
        assignedThreats[threatName] = interceptors
        lastLaunchTime[threatName] = timer.getTime()
        
        -- Apply cooldown immediately when squadron launches
        local currentTime = timer.getTime()
        squadronCooldowns[squadron.templateName] = currentTime + TADC_SETTINGS.squadronCooldown
        local cooldownMinutes = TADC_SETTINGS.squadronCooldown / 60
        log("Squadron " .. squadron.displayName .. " LAUNCHED! Applying " .. cooldownMinutes .. " minute cooldown")
    end
end

-- Main threat detection loop
local function detectThreats()
    log("Scanning for threats...", true)
    
    -- Clean up dead threats from tracking
    local currentThreats = {}
    
    -- Find all blue aircraft
    local blueAircraft = SET_GROUP:New():FilterCoalitions("blue"):FilterCategoryAirplane():FilterStart()
    local threatCount = 0
    
    blueAircraft:ForEach(function(blueGroup)
        if blueGroup and blueGroup:IsAlive() then
            threatCount = threatCount + 1
            currentThreats[blueGroup:GetName()] = true
            log("Found threat: " .. blueGroup:GetName() .. " (" .. blueGroup:GetTypeName() .. ")", true)
            
            -- Launch interceptor for this threat
            launchInterceptor(blueGroup)
        end
    end)
    
    -- Clean up assignments for threats that no longer exist and send interceptors home
    for threatName, assignedInterceptors in pairs(assignedThreats) do
        if not currentThreats[threatName] then
            log("Threat " .. threatName .. " eliminated, sending interceptors home...")
            
            -- Send assigned interceptors back to base
            if type(assignedInterceptors) == "table" then
                for _, interceptor in pairs(assignedInterceptors) do
                    if interceptor and interceptor:IsAlive() then
                        sendInterceptorHome(interceptor)
                    end
                end
            else
                -- Handle legacy single interceptor assignment
                if assignedInterceptors and assignedInterceptors:IsAlive() then
                    sendInterceptorHome(assignedInterceptors)
                end
            end
            
            assignedThreats[threatName] = nil
        end
    end
    
    -- Count assigned threats
    local assignedCount = 0
    for _ in pairs(assignedThreats) do assignedCount = assignedCount + 1 end
    
    log("Scan complete: " .. threatCount .. " threats, " .. countActiveFighters() .. " active fighters, " .. 
        assignedCount .. " assigned")
end

-- Monitor interceptor groups for cleanup when destroyed
local function monitorInterceptors()
    -- Check all active interceptors for cleanup
    for interceptorName, interceptorData in pairs(activeInterceptors) do
        if interceptorData and interceptorData.group then
            if not interceptorData.group:IsAlive() then
                -- Interceptor group is destroyed - just clean up tracking
                local displayName = interceptorData.displayName
                log("Interceptor from " .. displayName .. " destroyed: " .. interceptorName, true)
                
                -- Remove from active tracking
                activeInterceptors[interceptorName] = nil
            end
        end
    end
end

-- Periodic airbase status check
local function checkAirbaseStatus()
    log("=== AIRBASE STATUS REPORT ===")
    local usableCount = 0
    local currentTime = timer.getTime()
    
    for _, squadron in pairs(SQUADRON_CONFIG) do
        local usable, status = isAirbaseUsable(squadron.airbaseName)
        
        -- Add aircraft count to status
        local aircraftCount = squadronAircraftCounts[squadron.templateName] or 0
        local maxAircraft = squadron.aircraft
        local aircraftStatus = " Aircraft: " .. aircraftCount .. "/" .. maxAircraft
        
        -- Check if squadron is on cooldown
        local cooldownStatus = ""
        if squadronCooldowns[squadron.templateName] then
            local cooldownEnd = squadronCooldowns[squadron.templateName]
            if currentTime < cooldownEnd then
                local timeLeft = math.ceil((cooldownEnd - currentTime) / 60)
                cooldownStatus = " (COOLDOWN: " .. timeLeft .. "m)"
            end
        end
        
        local fullStatus = status .. aircraftStatus .. cooldownStatus
        
        if usable and cooldownStatus == "" and aircraftCount > 0 then
            usableCount = usableCount + 1
            log("✓ " .. squadron.airbaseName .. " - " .. fullStatus)
        else
            log("✗ " .. squadron.airbaseName .. " - " .. fullStatus)
        end
    end
    
    log("Status: " .. usableCount .. "/" .. #SQUADRON_CONFIG .. " airbases operational")
end

-- System initialization
local function initializeSystem()
    log("Universal TADC starting...")
    
    -- Validate configuration
    if not validateConfiguration() then
        log("System startup aborted due to configuration errors!")
        return false
    end
    
    log("Squadrons configured: " .. #SQUADRON_CONFIG)
    
    -- Log initial squadron aircraft counts
    for _, squadron in pairs(SQUADRON_CONFIG) do
        local count = squadronAircraftCounts[squadron.templateName]
        log("Initial: " .. squadron.displayName .. " has " .. count .. "/" .. squadron.aircraft .. " aircraft")
    end
    
    -- Start schedulers
    SCHEDULER:New(nil, detectThreats, {}, 5, TADC_SETTINGS.checkInterval)
    SCHEDULER:New(nil, monitorInterceptors, {}, 10, TADC_SETTINGS.monitorInterval)
    SCHEDULER:New(nil, checkAirbaseStatus, {}, 30, TADC_SETTINGS.statusReportInterval)
    SCHEDULER:New(nil, monitorCargoReplenishment, {}, 15, TADC_SETTINGS.cargoCheckInterval)
    
    log("Universal TADC operational!")
    log("Aircraft replenishment: " .. TADC_SETTINGS.cargoReplenishmentAmount .. " aircraft per cargo delivery")
    
    return true
end

-- Start the system
initializeSystem()