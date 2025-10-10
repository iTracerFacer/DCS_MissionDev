-- Simple TADC - Just Works
-- Detect blue aircraft, launch red fighters, make them intercept

-- Configuration
local TADC_CONFIG = {
    checkInterval = 30,        -- Check for threats every 10 seconds
    interceptRatio = 1.4,      -- Launch 1 fighter per threat (minimum)
    maxActiveCAP = 24,         -- Max fighters airborne at once
    squadronCooldown = 900,    -- Squadron cooldown after destruction (15 minutes)
}

-- Define squadron configurations with their designated airbases and patrol zones
local squadronConfigs = {
    -- Fixed-wing fighters patrol RED BORDER zone
    {
        templateName = "FIGHTER_SWEEP_RED_Kilpyavr",
        displayName = "Kilpyavr CAP",
        airbaseName = "Kilpyavr",
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
        aircraft = 1,
        skill = AI.Skill.GOOD,
        altitude = 30000,
        speed = 450,
        patrolTime = 35,
        type = "FIGHTER"
    },
    --[[]
    -- Helicopter squadron patrols HELO BORDER zone
    {
        templateName = "HELO_SWEEP_RED_Afrikanda",
        displayName = "Afrikanda Helo CAP",
        airbaseName = "Afrikanda",
        aircraft = 4,
        skill = AI.Skill.GOOD,
        altitude = 1000,
        speed = 150,
        patrolTime = 30,
        type = "HELICOPTER"
    }
    --]]
}

-- Track active missions
local activeInterceptors = {}
local lastLaunchTime = {}
local assignedThreats = {}  -- Track which threats already have interceptors assigned
local squadronCooldowns = {}  -- Track squadron cooldowns after destruction

-- Simple logging
local function log(message)
    env.info("[Simple TADC] " .. message)
end

-- Send interceptor back to base
local function sendInterceptorHome(interceptor)
    if not interceptor or not interceptor:IsAlive() then
        return
    end
    
    -- Find nearest friendly airbase
    local interceptorCoord = interceptor:GetCoordinate()
    local nearestAirbase = nil
    local shortestDistance = math.huge
    
    -- Check all squadron airbases to find the nearest one that's still friendly
    for _, squadron in pairs(squadronConfigs) do
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
        local rtbAltitude = 3000 -- RTB at 3000 feet
        local rtbCoord = airbaseCoord:SetAltitude(rtbAltitude * 0.3048) -- Convert feet to meters
        
        -- Clear current tasks and route home
        interceptor:ClearTasks()
        interceptor:RouteAirTo(rtbCoord, 250 * 0.5144, "BARO") -- RTB at 250 knots
        
        log("Sending " .. interceptor:GetName() .. " back to " .. nearestAirbase:GetName())
        
        -- Schedule cleanup after they should have landed (give them time to get home)
        local flightTime = math.ceil(shortestDistance / (250 * 0.5144)) + 300 -- Flight time + 5 min buffer
        SCHEDULER:New(nil, function()
            if activeInterceptors[interceptor:GetName()] then
                activeInterceptors[interceptor:GetName()] = nil
                log("Cleaned up " .. interceptor:GetName() .. " after RTB")
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
    
    for _, squadron in pairs(squadronConfigs) do
        -- Check if squadron is on cooldown
        local squadronAvailable = true
        if squadronCooldowns[squadron.templateName] then
            local cooldownEnd = squadronCooldowns[squadron.templateName]
            if currentTime < cooldownEnd then
                local timeLeft = math.ceil((cooldownEnd - currentTime) / 60)
                log("Squadron " .. squadron.displayName .. " on cooldown for " .. timeLeft .. " more minutes")
                squadronAvailable = false
            else
                -- Cooldown expired, remove it
                squadronCooldowns[squadron.templateName] = nil
                log("Squadron " .. squadron.displayName .. " cooldown expired, available for launch")
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
                -- Airbase is valid, check if squadron can spawn
                local spawn = SPAWN:New(squadron.templateName)
                if spawn then
                    -- Get squadron's airbase
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
                    end
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
    local threatSize = threatGroup:GetSize() -- Get the number of aircraft in the threat group
    
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
    
    -- Calculate how many interceptors to launch (at least match threat size, up to ratio)
    local interceptorsNeeded = math.max(threatSize, math.ceil(threatSize * TADC_CONFIG.interceptRatio))
    
    -- Check if we have capacity
    if countActiveFighters() + interceptorsNeeded > TADC_CONFIG.maxActiveCAP then
        interceptorsNeeded = TADC_CONFIG.maxActiveCAP - countActiveFighters()
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
                        interceptor:RouteAirTo(interceptCoord, squadron.speed * 0.5144, "BARO") -- Convert kts to m/s
                        
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
            
            -- Emergency cleanup (safety net - should normally RTB before this)
            SCHEDULER:New(nil, function()
                if activeInterceptors[interceptor:GetName()] then
                    log("Emergency cleanup of " .. interceptor:GetName() .. " (should have RTB'd)")
                    activeInterceptors[interceptor:GetName()] = nil
                end
            end, {}, 7200) -- Emergency cleanup after 2 hours
        end
    end
    
    -- Log the launch and track assignment
    if #interceptors > 0 then
        log("Launched " .. #interceptors .. " x " .. squadron.displayName .. " to intercept " .. 
            threatSize .. " x " .. threatName)
        assignedThreats[threatName] = interceptors  -- Track which interceptors are assigned to this threat
        lastLaunchTime[threatName] = timer.getTime()
    end
end

-- Main threat detection loop
local function detectThreats()
    log("Scanning for threats...")
    
    -- Clean up dead threats from tracking
    local currentThreats = {}
    
    -- Find all blue aircraft
    local blueAircraft = SET_GROUP:New():FilterCoalitions("blue"):FilterCategoryAirplane():FilterStart()
    local threatCount = 0
    
    blueAircraft:ForEach(function(blueGroup)
        if blueGroup and blueGroup:IsAlive() then
            threatCount = threatCount + 1
            currentThreats[blueGroup:GetName()] = true
            log("Found threat: " .. blueGroup:GetName() .. " (" .. blueGroup:GetTypeName() .. ")")
            
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

-- Monitor interceptor groups and apply cooldowns when destroyed
local function monitorInterceptors()
    local currentTime = timer.getTime()
    local destroyedSquadrons = {}
    
    -- Check all active interceptors
    for interceptorName, interceptorData in pairs(activeInterceptors) do
        if interceptorData and interceptorData.group then
            if not interceptorData.group:IsAlive() then
                -- Interceptor group is destroyed
                local squadronName = interceptorData.squadron
                local displayName = interceptorData.displayName
                
                -- Track destroyed squadrons (avoid duplicate cooldowns)
                if not destroyedSquadrons[squadronName] then
                    destroyedSquadrons[squadronName] = displayName
                    
                    -- Apply cooldown
                    squadronCooldowns[squadronName] = currentTime + TADC_CONFIG.squadronCooldown
                    local cooldownMinutes = TADC_CONFIG.squadronCooldown / 60
                    log("Squadron " .. displayName .. " DESTROYED! Applying " .. cooldownMinutes .. " minute cooldown")
                end
                
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
    
    for _, squadron in pairs(squadronConfigs) do
        local usable, status = isAirbaseUsable(squadron.airbaseName)
        
        -- Check if squadron is on cooldown
        local cooldownStatus = ""
        if squadronCooldowns[squadron.templateName] then
            local cooldownEnd = squadronCooldowns[squadron.templateName]
            if currentTime < cooldownEnd then
                local timeLeft = math.ceil((cooldownEnd - currentTime) / 60)
                cooldownStatus = " (COOLDOWN: " .. timeLeft .. "m)"
                status = status .. cooldownStatus
            end
        end
        
        if usable and cooldownStatus == "" then
            usableCount = usableCount + 1
            log("✓ " .. squadron.airbaseName .. " - " .. status)
        else
            log("✗ " .. squadron.airbaseName .. " - " .. status)
        end
    end
    
    log("Status: " .. usableCount .. "/" .. #squadronConfigs .. " airbases operational")
end

-- Start the system
log("Simple TADC starting...")
log("Squadrons configured: " .. #squadronConfigs)

-- Run detection every interval
SCHEDULER:New(nil, detectThreats, {}, 5, TADC_CONFIG.checkInterval)

-- Run interceptor monitoring every 30 seconds
SCHEDULER:New(nil, monitorInterceptors, {}, 10, 30)

-- Run airbase status check every 2 minutes
SCHEDULER:New(nil, checkAirbaseStatus, {}, 30, 120)

log("Simple TADC operational!")