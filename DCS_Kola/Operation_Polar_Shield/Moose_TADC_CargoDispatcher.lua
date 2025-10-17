--[[
═══════════════════════════════════════════════════════════════════════════════
                Moose_TDAC_CargoDispatcher.lua
    Automated Logistics System for TADC Squadron Replenishment
═══════════════════════════════════════════════════════════════════════════════

DESCRIPTION:
    This script monitors RED and BLUE squadrons for low aircraft counts and automatically dispatches CARGO aircraft from a list of supply airfields to replenish them. It tracks each supply mission, announces key stages to players, and prevents duplicate or spam missions. The system integrates with TADC's existing cargo landing logic for replenishment.

CONFIGURATION:
    - Update static templates and airfield lists as needed for your mission.
    - Set thresholds and supply airfields in CARGO_SUPPLY_CONFIG.
    - Replace static templates with actual group templates from the mission editor for realism.

REQUIRES:
    - MOOSE framework (for SPAWN, AIRBASE, etc.)
    - Optional: MIST for deep copy of templates

═══════════════════════════════════════════════════════════════════════════════
]]

--[[
    GLOBAL STATE AND CONFIGURATION
    --------------------------------------------------------------------------
    Tracks all active cargo missions and dispatcher configuration.
]]
if not cargoMissions then
    cargoMissions = { red = {}, blue = {} }
end

-- Dispatcher config (interval in seconds)
if not DISPATCHER_CONFIG then
    -- default interval (seconds) and a slightly larger grace period to account for slow servers/networks
    DISPATCHER_CONFIG = { interval = 60, gracePeriod = 25 }
end

-- Safety flag: when false, do NOT fall back to spawning from in-memory template tables.
-- Set to true if you understand the tweaked-template warning and accept the risk.
if DISPATCHER_CONFIG.ALLOW_FALLBACK_TO_INMEM_TEMPLATE == nil then
    DISPATCHER_CONFIG.ALLOW_FALLBACK_TO_INMEM_TEMPLATE = false
end

--[[
    UTILITY STUBS
    --------------------------------------------------------------------------
    selectRandomAirfield: Picks a random airfield from a list.
    announceToCoalition: Stub for in-game coalition messaging.
    Replace with your own logic as needed.
]]
if not selectRandomAirfield then
    function selectRandomAirfield(airfieldList)
        if type(airfieldList) == "table" and #airfieldList > 0 then
            return airfieldList[math.random(1, #airfieldList)]
        end
        return nil
    end
end

-- Stub for announceToCoalition (replace with your own logic if needed)
if not announceToCoalition then
    function announceToCoalition(coalitionKey, message)
        -- Replace with actual in-game message logic
        env.info("[ANNOUNCE] [" .. tostring(coalitionKey) .. "]: " .. tostring(message))
    end
end


--[[
    LOGGING
    --------------------------------------------------------------------------
    Advanced logging configuration and helper function for debug output.
]]
local ADVANCED_LOGGING = {
    enableDetailedLogging = true,
    logPrefix = "[TDAC Cargo]"
}

-- Provide a safe deepCopy if MIST is not available
local function deepCopy(obj)
    if type(obj) ~= 'table' then return obj end
    local res = {}
    for k, v in pairs(obj) do
        if type(v) == 'table' then
            res[k] = deepCopy(v)
        else
            res[k] = v
        end
    end
    return res
end

-- Dispatch cooldown per airbase (seconds) to avoid repeated immediate retries
local CARGO_DISPATCH_COOLDOWN = DISPATCHER_CONFIG and DISPATCHER_CONFIG.cooldown or 300 -- default 5 minutes
local lastDispatchAttempt = { red = {}, blue = {} }

local function getCoalitionSide(coalitionKey)
    if coalitionKey == 'blue' then return coalition.side.BLUE end
    if coalitionKey == 'red' then return coalition.side.RED end
    return nil
end

-- Logging function (mimics Moose_TADC_Load2nd.lua)
local function log(message, detailed)
    if not detailed or ADVANCED_LOGGING.enableDetailedLogging then
        env.info(ADVANCED_LOGGING.logPrefix .. " " .. message)
    end
end


log("═══════════════════════════════════════════════════════════════════════════════", true)
log("Moose_TDAC_CargoDispatcher.lua loaded.", true)
log("═══════════════════════════════════════════════════════════════════════════════", true)

--[[
    CARGO SUPPLY CONFIGURATION
    --------------------------------------------------------------------------
    Set supply airfields, cargo template names, and resupply thresholds for each coalition.
]]
local CARGO_SUPPLY_CONFIG = {
    red = {
        supplyAirfields = { "Kuusamo", "Kalevala", "Vuojarvi", "Kalevala", "Poduzhemye", "Kirkenes" }, -- replace with your RED supply airbase names
        cargoTemplate = "CARGO_RED_AN26",    -- replace with your RED cargo aircraft template name
        threshold = 0.90                              -- ratio below which to trigger resupply (testing)
    },
    blue = {
        supplyAirfields = { "Banak", "Kittila", "Alta", "Sodankyla", "Vuojarvi", "Enontekio" }, -- replace with your BLUE supply airbase names
        cargoTemplate = "CARGO_BLUE_C130",   -- replace with your BLUE cargo aircraft template name
        threshold = 0.90                              -- ratio below which to trigger resupply (testing)
    }
}


--[[
    getSquadronStatus(squadron, coalitionKey)
    --------------------------------------------------------------------------
    Returns the current, max, and ratio of aircraft for a squadron.
    If you track current aircraft in a table, update this logic accordingly.
    Returns: currentCount, maxCount, ratio
]]
local function getSquadronStatus(squadron, coalitionKey)
    local current = squadron.current or squadron.count or squadron.aircraft or 0
    local max = squadron.max or squadron.aircraft or 1
    if squadron.templateName and _G.squadronAircraftCounts and _G.squadronAircraftCounts[coalitionKey] then
        current = _G.squadronAircraftCounts[coalitionKey][squadron.templateName] or current
    end
    local ratio = (max > 0) and (current / max) or 0
    return current, max, ratio
end



--[[
    hasActiveCargoMission(coalitionKey, airbaseName)
    --------------------------------------------------------------------------
    Returns true if there is an active (not completed/failed) cargo mission for the given airbase.
]]
local function hasActiveCargoMission(coalitionKey, airbaseName)
    for _, mission in pairs(cargoMissions[coalitionKey]) do
        if mission.destination == airbaseName then
            -- Ignore completed or failed missions
            if mission.status == "completed" or mission.status == "failed" then
                -- not active
            else
                -- Consider mission active only if the group is alive OR we're still within the grace window
                local stillActive = false
                if mission.group and mission.group.IsAlive and mission.group:IsAlive() then
                    stillActive = true
                else
                    local pending = mission._pendingStartTime
                    local grace = mission._gracePeriod or DISPATCHER_CONFIG.gracePeriod or 8
                    if pending and (timer.getTime() - pending) <= grace then
                        stillActive = true
                    end
                end
                if stillActive then
                    log("Active cargo mission found for " .. airbaseName .. " (" .. coalitionKey .. ")")
                    return true
                end
            end
        end
    end
    log("No active cargo mission for " .. airbaseName .. " (" .. coalitionKey .. ")")
    return false
end

--[[
    trackCargoMission(coalitionKey, mission)
    --------------------------------------------------------------------------
    Adds a new cargo mission to the tracking table and logs it.
]]
local function trackCargoMission(coalitionKey, mission)
    table.insert(cargoMissions[coalitionKey], mission)
    log("Tracking new cargo mission: " .. (mission.group and mission.group:GetName() or "nil group") .. " from " .. mission.origin .. " to " .. mission.destination)
end

--[[
    cleanupCargoMissions()
    --------------------------------------------------------------------------
    Removes completed or failed cargo missions from the tracking table if their group is no longer alive.
]]
local function cleanupCargoMissions()
    for _, coalitionKey in ipairs({"red", "blue"}) do
        for i = #cargoMissions[coalitionKey], 1, -1 do
            local m = cargoMissions[coalitionKey][i]
            if m.status == "failed" then
                if not (m.group and m.group:IsAlive()) then
                    log("Cleaning up failed cargo mission: " .. (m.group and m.group:GetName() or "nil group") .. " status: failed")
                    table.remove(cargoMissions[coalitionKey], i)
                end
            elseif m.status == "completed" then
                if not (m.group and m.group:IsAlive()) then
                    log("Cleaning up completed cargo mission: " .. (m.group and m.group:GetName() or "nil group") .. " status: completed")
                    table.remove(cargoMissions[coalitionKey], i)
                end
            end
        end
    end
end

--[[
    dispatchCargo(squadron, coalitionKey)
    --------------------------------------------------------------------------
    Spawns a cargo aircraft from a supply airfield to the destination squadron airbase.
    Uses static templates for each coalition, assigns a unique group name, and sets a custom route.
    Tracks the mission and schedules route assignment with a delay to ensure group is alive.
]]
local function dispatchCargo(squadron, coalitionKey)
    local config = CARGO_SUPPLY_CONFIG[coalitionKey]
    local origin = selectRandomAirfield(config.supplyAirfields)
    -- enforce cooldown per destination to avoid immediate retries
    lastDispatchAttempt[coalitionKey] = lastDispatchAttempt[coalitionKey] or {}
    local last = lastDispatchAttempt[coalitionKey][squadron.airbaseName]
    if last and (timer.getTime() - last) < CARGO_DISPATCH_COOLDOWN then
        log("Skipping dispatch to " .. squadron.airbaseName .. " (cooldown active)")
        return
    end
    if not origin then
        log("No origin airfield found for cargo dispatch.")
        return
    end
    local destination = squadron.airbaseName
    -- Safety: check if destination has suitable parking for larger transports. If not, warn in log.
    local okParking = true
    -- Only check for likely large transports (C-130 / An-26 are large-ish) — keep conservative
    if cargoTemplate and (string.find(cargoTemplate:upper(), "C130") or string.find(cargoTemplate:upper(), "C-17") or string.find(cargoTemplate:upper(), "C17") or string.find(cargoTemplate:upper(), "AN26") ) then
        okParking = destinationHasSuitableParking(destination)
        if not okParking then
            log("WARNING: Destination '" .. tostring(destination) .. "' may not have suitable parking for " .. tostring(cargoTemplate) .. ". This can cause immediate despawn on landing.")
        end
    end
    local cargoTemplate = config.cargoTemplate
    local groupName = cargoTemplate .. "_to_" .. destination .. "_" .. math.random(1000,9999)

    log("Dispatching cargo: " .. groupName .. " from " .. origin .. " to " .. destination)

    -- Spawn cargo aircraft at origin using the template name ONLY for SPAWN
    -- Note: cargoTemplate is a config string; script uses in-file Lua template tables (CARGO_AIRCRAFT_TEMPLATE_*)
    log("DEBUG: Attempting spawn for group: '" .. groupName .. "' at airbase: '" .. origin .. "' (using in-file Lua template)")
    local airbaseObj = AIRBASE:FindByName(origin)
    if not airbaseObj then
        log("ERROR: AIRBASE:FindByName failed for '" .. tostring(origin) .. "'. Airbase object is nil!")
    else
        log("DEBUG: AIRBASE object found for '" .. origin .. "'. Proceeding with spawn.")
    end
    -- Select the correct template based on coalition
    local templateBase, uniqueGroupName
    if coalitionKey == "blue" then
        templateBase = CARGO_AIRCRAFT_TEMPLATE_BLUE
        uniqueGroupName = "CARGO_C130_DYNAMIC_" .. math.random(1000,9999)
    else
        templateBase = CARGO_AIRCRAFT_TEMPLATE_RED
        uniqueGroupName = "CARGO_AN26_DYNAMIC_" .. math.random(1000,9999)
    end
    -- Clone the template and set the group/unit name
    -- Prepare a mission placeholder. We'll set the group and spawnPos after successful spawn.
    local mission = {
        group = nil,
        origin = origin,
        destination = destination,
        squadron = squadron,
        status = "pending",
        -- Anchor a pending start time now to avoid the monitor loop expiring a mission
        -- before MOOSE has a chance to finalize the OnSpawnGroup callback.
        _pendingStartTime = timer.getTime(),
        _spawnPos = nil,
        _gracePeriod = DISPATCHER_CONFIG.gracePeriod or 8
    }

    -- Helper to finalize mission after successful spawn
    local function finalizeMissionAfterSpawn(spawnedGroup, spawnPos)
        mission.group = spawnedGroup
        mission._spawnPos = spawnPos
        trackCargoMission(coalitionKey, mission)
        lastDispatchAttempt[coalitionKey][squadron.airbaseName] = timer.getTime()
    end

    -- MOOSE-only spawn-by-name flow
    if type(cargoTemplate) ~= 'string' or cargoTemplate == '' then
        log("ERROR: cargoTemplate for coalition '" .. tostring(coalitionKey) .. "' must be a valid mission template name string. Aborting dispatch.")
        announceToCoalition(coalitionKey, "Resupply mission to " .. destination .. " aborted (invalid cargo template)!")
        return
    end

    -- Use a per-dispatch RAT object to spawn and route cargo aircraft.
    -- Create a unique alias to avoid naming collisions and let RAT handle routing/landing.
    local alias = cargoTemplate .. "_TO_" .. destination .. "_" .. tostring(math.random(1000,9999))
    log("DEBUG: Attempting RAT spawn for template: '" .. cargoTemplate .. "' alias: '" .. alias .. "'")

    local okNew, rat = pcall(function() return RAT:New(cargoTemplate, alias) end)
    if not okNew or not rat then
        log("ERROR: RAT:New failed for template '" .. tostring(cargoTemplate) .. "'. Error: " .. tostring(rat))
        if debug and debug.traceback then
            log("TRACEBACK: " .. tostring(debug.traceback(rat)))
        end
        announceToCoalition(coalitionKey, "Resupply mission to " .. destination .. " failed (spawn init error)!")
        return
    end

    -- Configure RAT for a single, non-respawning dispatch
    rat:SetDeparture(origin)
    rat:SetDestination(destination)
    rat:NoRespawn()
    rat:SetSpawnLimit(1)
    rat:SetSpawnDelay(1)
    -- Ensure RAT takes off immediately from the runway (hot start) instead of staying parked
    if rat.SetTakeoffHot then rat:SetTakeoffHot() end
    -- Ensure RAT will look for parking and not despawn the group immediately on landing.
    -- This makes the group taxi to parking and come to a stop so other scripts (e.g. Load2nd)
    -- that detect parked/stopped cargo aircraft can register the delivery.
    if rat.SetParkingScanRadius then rat:SetParkingScanRadius(80) end
    if rat.SetParkingSpotSafeON then rat:SetParkingSpotSafeON() end
    if rat.SetDespawnAirOFF then rat:SetDespawnAirOFF() end
    -- Check on runway to ensure proper landing behavior (distance in meters)
    if rat.CheckOnRunway then rat:CheckOnRunway(true, 75) end

    rat:OnSpawnGroup(function(spawnedGroup)
        -- Mark the canonical start time when MOOSE reports the group exists
        mission._pendingStartTime = timer.getTime()

        local spawnPos = nil
        local dcsGroup = spawnedGroup:GetDCSObject()
        if dcsGroup then
            local units = dcsGroup:getUnits()
            if units and #units > 0 then
                spawnPos = units[1]:getPoint()
            end
        end

        log("RAT spawned cargo aircraft group: " .. tostring(spawnedGroup:GetName()))

        -- Temporary debug: log group state every 5s for 60s to trace landing/parking behavior
        local debugChecks = 12
        local checkInterval = 5
        local function debugLogState(iter)
            if iter > debugChecks then return end
            local ok, err = pcall(function()
                local name = spawnedGroup:GetName()
                local dcs = spawnedGroup:GetDCSObject()
                if dcs then
                    local units = dcs:getUnits()
                    if units and #units > 0 then
                        local u = units[1]
                        local pos = u:getPoint()
                        -- Use dot accessor to test for function existence; colon-call to invoke
                        local vel = (u.getVelocity and u:getVelocity()) or {x=0,y=0,z=0}
                        local speed = math.sqrt((vel.x or 0)^2 + (vel.y or 0)^2 + (vel.z or 0)^2)
                        local airbaseObj = AIRBASE:FindByName(destination)
                        local dist = nil
                        if airbaseObj then
                            local dest = airbaseObj:GetCoordinate():GetVec2()
                            local dx = pos.x - dest.x
                            local dz = pos.z - dest.y
                            dist = math.sqrt(dx*dx + dz*dz)
                        end
                        log(string.format("[TDAC DEBUG] %s state check %d: alive=%s pos=(%.1f,%.1f) speed=%.2f m/s distToDest=%s", name, iter, tostring(spawnedGroup:IsAlive()), pos.x or 0, pos.z or 0, speed, tostring(dist)))
                    else
                        log(string.format("[TDAC DEBUG] %s state check %d: DCS group has no units", tostring(spawnedGroup:GetName()), iter))
                    end
                else
                    log(string.format("[TDAC DEBUG] %s state check %d: no DCS group object", tostring(spawnedGroup:GetName()), iter))
                end
            end)
            if not ok then
                log("[TDAC DEBUG] Error during debugLogState: " .. tostring(err))
            end
            timer.scheduleFunction(function() debugLogState(iter + 1) end, {}, timer.getTime() + checkInterval)
        end
        timer.scheduleFunction(function() debugLogState(1) end, {}, timer.getTime() + checkInterval)

        -- RAT should handle routing/taxi/parking. Finalize mission tracking now.
        finalizeMissionAfterSpawn(spawnedGroup, spawnPos)
    end)

    local okSpawn, errSpawn = pcall(function() rat:Spawn(1) end)
    if not okSpawn then
        log("ERROR: rat:Spawn() failed for template '" .. tostring(cargoTemplate) .. "'. Error: " .. tostring(errSpawn))
        if debug and debug.traceback then
            log("TRACEBACK: " .. tostring(debug.traceback(errSpawn)))
        end
        announceToCoalition(coalitionKey, "Resupply mission to " .. destination .. " failed (spawn error)!")
        return
    end
    -- Assign route to destination using DCS-native AI tasking, with retries to handle slow registration
    local function assignRouteWithRetries(attempt, maxAttempts)
        attempt = attempt or 1
        maxAttempts = maxAttempts or 6
        if not (mission.group and mission.group:IsAlive()) then
            log(string.format("assignRouteWithRetries: mission.group invalid or dead (attempt %d/%d)", attempt, maxAttempts))
            if attempt >= maxAttempts then
                mission.status = "failed"
                log("Cargo mission failed: spawned group never registered/alive for mission to " .. destination)
                announceToCoalition(coalitionKey, "Resupply mission to " .. destination .. " failed (spawn issue)!")
                return
            end
            -- retry after backoff
            timer.scheduleFunction(function() assignRouteWithRetries(attempt + 1, maxAttempts) end, {}, timer.getTime() + (attempt * 2))
            return
        end

        local destAirbase = AIRBASE:FindByName(destination)
        if not destAirbase then
            log("assignRouteWithRetries: Destination airbase not found: " .. tostring(destination))
            mission.status = "failed"
            announceToCoalition(coalitionKey, "Resupply mission to " .. destination .. " failed (no airbase)!")
            return
        end
        local dcsGroup = mission.group:GetDCSObject()
        if not dcsGroup then
            log("assignRouteWithRetries: DCS group object not available yet (attempt " .. attempt .. ")")
            if attempt >= maxAttempts then
                mission.status = "failed"
                announceToCoalition(coalitionKey, "Resupply mission to " .. destination .. " failed (no DCS group)!")
                return
            end
            timer.scheduleFunction(function() assignRouteWithRetries(attempt + 1, maxAttempts) end, {}, timer.getTime() + (attempt * 2))
            return
        end

        local controller = dcsGroup:getController()
        if not controller then
            log("assignRouteWithRetries: Controller not available yet (attempt " .. attempt .. ")")
            if attempt >= maxAttempts then
                mission.status = "failed"
                announceToCoalition(coalitionKey, "Resupply mission to " .. destination .. " failed (no controller)!")
                return
            end
            timer.scheduleFunction(function() assignRouteWithRetries(attempt + 1, maxAttempts) end, {}, timer.getTime() + (attempt * 2))
            return
        end

        -- Build route now that we have positions. Use the spawn position captured earlier if available,
        -- otherwise read the current unit position from the DCS group.
        local cruiseAlt = 6096 -- 20,000 feet in meters
        local destCoord = destAirbase:GetCoordinate():GetVec2()
        local destElevation = destAirbase:GetCoordinate():GetLandHeight() or 0
        local landingAlt = destElevation + 10 -- 10m above ground
        local airdromeId = destAirbase:GetID() or 0
        local destX = destCoord.x
        local destZ = destCoord.y

        local pos = mission._spawnPos
        if not pos then
            local units = dcsGroup:getUnits()
            if units and #units > 0 then
                pos = units[1]:getPoint()
            end
        end
        if not pos or not pos.x or not pos.z then
            log("assignRouteWithRetries: Could not determine spawn position for route assignment (attempt " .. attempt .. ")")
            if attempt >= maxAttempts then
                mission.status = "failed"
                announceToCoalition(coalitionKey, "Resupply mission to " .. destination .. " failed (no position)!")
                return
            end
            timer.scheduleFunction(function() assignRouteWithRetries(attempt + 1, maxAttempts) end, {}, timer.getTime() + (attempt * 2))
            return
        end

        local route = {
            {
                x = pos.x,
                z = pos.z,
                alt = cruiseAlt,
                type = "Turning Point",
                action = "Turning Point",
                speed = 330
            },
            {
                x = destX,
                z = destZ,
                alt = cruiseAlt,
                type = "Turning Point",
                action = "Turning Point",
                speed = 330
            },
            {
                x = destX,
                z = destZ,
                alt = landingAlt,
                type = "Land",
                action = "Landing",
                speed = 70,
                airdromeId = airdromeId
            },
        }

        log("DEBUG: Route table assigned:")
        for i, wp in ipairs(route) do
            log(string.format("  WP%d: x=%.1f z=%.1f alt=%.1f type=%s action=%s speed=%.1f", i, wp.x, wp.z, wp.alt, wp.type, wp.action or "", wp.speed or 0))
        end

        local okSet, errSet = pcall(function()
            controller:setTask({ id = 'Mission', params = { route = { points = route } } })
        end)
        if not okSet then
            log("ERROR: controller:setTask failed: " .. tostring(errSet))
            if debug and debug.traceback then
                log("TRACEBACK: " .. tostring(debug.traceback(errSet)))
            end
        end
        log("Assigned custom route to airbase: " .. destination)
        if mission.group and mission.group:IsAlive() then
            mission.status = "enroute"
            mission._pendingStartTime = timer.getTime()
            announceToCoalition(coalitionKey, "CARGO aircraft departing (airborne) for " .. destination .. ". Defend it!")
        else
            mission.status = "failed"
            log("Cargo mission failed after route assignment: group not alive: " .. tostring(destination))
            announceToCoalition(coalitionKey, "Resupply mission to " .. destination .. " failed after assignment!")
        end
    end

    -- Start first attempt after short delay
    timer.scheduleFunction(function() assignRouteWithRetries(1, 5) end, {}, timer.getTime() + 2)
end


-- Parking diagnostics helper
-- Call from DCS console: _G.TDAC_LogAirbaseParking("Luostari Pechenga")
function _G.TDAC_LogAirbaseParking(airbaseName)
    if type(airbaseName) ~= 'string' then
        log("TDAC Parking helper: airbaseName must be a string", true)
        return false
    end
    local base = AIRBASE:FindByName(airbaseName)
    if not base then
        log("TDAC Parking helper: AIRBASE:FindByName returned nil for '" .. tostring(airbaseName) .. "'", true)
        return false
    end
    local function spotsFor(term)
        local ok, n = pcall(function() return base:GetParkingSpotsNumber(term) end)
        if not ok then return nil end
        return n
    end
    local openBig = spotsFor(AIRBASE.TerminalType.OpenBig)
    local openMed = spotsFor(AIRBASE.TerminalType.OpenMed)
    local openMedOrBig = spotsFor(AIRBASE.TerminalType.OpenMedOrBig)
    local runway = spotsFor(AIRBASE.TerminalType.Runway)
    log(string.format("TDAC Parking: %s -> OpenBig=%s OpenMed=%s OpenMedOrBig=%s Runway=%s", airbaseName, tostring(openBig), tostring(openMed), tostring(openMedOrBig), tostring(runway)), true)
    return true
end


-- Pre-dispatch safety check: ensure destination can accommodate larger transport types
local function destinationHasSuitableParking(destination, preferredTermTypes)
    local base = AIRBASE:FindByName(destination)
    if not base then return false end
    preferredTermTypes = preferredTermTypes or { AIRBASE.TerminalType.OpenBig, AIRBASE.TerminalType.OpenMedOrBig, AIRBASE.TerminalType.OpenMed }
    for _, term in ipairs(preferredTermTypes) do
        local ok, n = pcall(function() return base:GetParkingSpotsNumber(term) end)
        if ok and n and n > 0 then
            return true
        end
    end
    return false
end


--[[
    monitorSquadrons()
    --------------------------------------------------------------------------
    Checks all squadrons for each coalition. If a squadron is below the resupply threshold and has no active cargo mission,
    triggers a supply request and dispatches a cargo aircraft.
]]
local function monitorSquadrons()
    for _, coalitionKey in ipairs({"red", "blue"}) do
        local config = CARGO_SUPPLY_CONFIG[coalitionKey]
        local squadrons = (coalitionKey == "red") and RED_SQUADRON_CONFIG or BLUE_SQUADRON_CONFIG
        for _, squadron in ipairs(squadrons) do
            local current, max, ratio = getSquadronStatus(squadron, coalitionKey)
            log("Squadron status: " .. squadron.displayName .. " (" .. coalitionKey .. ") " .. current .. "/" .. max .. " ratio: " .. string.format("%.2f", ratio))
            if ratio <= config.threshold and not hasActiveCargoMission(coalitionKey, squadron.airbaseName) then
                log("Supply request triggered for " .. squadron.displayName .. " at " .. squadron.airbaseName)
                announceToCoalition(coalitionKey, "Supply requested for " .. squadron.airbaseName .. "! Squadron: " .. squadron.displayName)
                dispatchCargo(squadron, coalitionKey)
            end
        end
    end
end

--[[
    monitorCargoMissions()
    --------------------------------------------------------------------------
    Monitors all cargo missions, updates their status, and cleans up completed/failed ones.
    Handles mission failure after a grace period and mission completion when the group is near the destination airbase.
]]
local function monitorCargoMissions()
    for _, coalitionKey in ipairs({"red", "blue"}) do
        for _, mission in ipairs(cargoMissions[coalitionKey]) do
            if mission.group == nil then
                log("[DEBUG] Mission group object is nil for mission to " .. tostring(mission.destination))
            else
                log("[DEBUG] Mission group: " .. tostring(mission.group:GetName()) .. ", IsAlive(): " .. tostring(mission.group:IsAlive()))
                local dcsGroup = mission.group:GetDCSObject()
                if dcsGroup then
                    local units = dcsGroup:getUnits()
                    if units and #units > 0 then
                        local pos = units[1]:getPoint()
                        log(string.format("[DEBUG] Group position: x=%.1f y=%.1f z=%.1f", pos.x, pos.y, pos.z))
                    else
                        log("[DEBUG] No units found in DCS group for mission to " .. tostring(mission.destination))
                    end
                else
                    log("[DEBUG] DCS group object is nil for mission to " .. tostring(mission.destination))
                end
            end

            local graceElapsed = mission._pendingStartTime and (timer.getTime() - mission._pendingStartTime > (mission._gracePeriod or 8))

            -- Only allow mission to be failed after grace period, and only if group is truly dead.
            -- Some DCS/MOOSE group objects may momentarily report IsAlive() == false while units still exist, so
            -- also check DCS object/unit presence before declaring failure.
            if (mission.status == "pending" or mission.status == "enroute") and graceElapsed then
                local isAlive = mission.group and mission.group:IsAlive()
                local dcsGroup = mission.group and mission.group:GetDCSObject()
                local unitsPresent = false
                if dcsGroup then
                    local units = dcsGroup:getUnits()
                    unitsPresent = units and (#units > 0)
                end
                if not isAlive and not unitsPresent then
                    mission.status = "failed"
                    log("Cargo mission failed (after grace period): " .. (mission.group and mission.group:GetName() or "nil group") .. " to " .. mission.destination)
                    announceToCoalition(coalitionKey, "Resupply mission to " .. mission.destination .. " failed!")
                else
                    log("DEBUG: Mission appears to still have DCS units despite IsAlive=false; skipping failure for " .. tostring(mission.destination))
                end
            end

            -- Mission completion logic (unchanged)
            if mission.status == "enroute" and mission.group and mission.group:IsAlive() then
                local destAirbase = AIRBASE:FindByName(mission.destination)
                local reached = false
                if destAirbase then
                    -- Prefer native MOOSE helper if available
                    if mission.group.IsNearAirbase and type(mission.group.IsNearAirbase) == "function" then
                        reached = mission.group:IsNearAirbase(destAirbase, 3000)
                    else
                        -- Fallback: compute distance between group's first unit and airbase coordinate
                        local dcsGroup = mission.group and mission.group.GetDCSObject and mission.group:GetDCSObject()
                        if dcsGroup then
                            local units = dcsGroup:getUnits()
                            if units and #units > 0 then
                                local pos = units[1]:getPoint()
                                local destCoord = destAirbase:GetCoordinate():GetVec2()
                                local dx = pos.x - destCoord.x
                                local dz = pos.z - destCoord.y
                                local dist = math.sqrt(dx * dx + dz * dz)
                                if dist <= 3000 then
                                    reached = true
                                end
                            end
                        end
                    end
                end
                if reached then
                    mission.status = "completed"
                    local name = (mission.group and (mission.group.GetName and mission.group:GetName() or tostring(mission.group)) ) or "unknown"
                    log("Cargo mission completed: " .. name .. " delivered to " .. mission.destination)
                    announceToCoalition(coalitionKey, "Resupply delivered to " .. mission.destination .. "!")
                end
            end
        end
    end
    cleanupCargoMissions()
end

--[[
    MAIN DISPATCHER LOOP
    --------------------------------------------------------------------------
    Runs the main dispatcher logic on a timer interval.
]]
local function cargoDispatcherMain()
    log("═══════════════════════════════════════════════════════════════════════════════", true)
    log("Cargo Dispatcher main loop running.", true)
    monitorSquadrons()
    monitorCargoMissions()
    -- Schedule the next run inside a protected call to avoid unhandled errors
    timer.scheduleFunction(function()
        local ok, err = pcall(cargoDispatcherMain)
        if not ok then
            log("FATAL: cargoDispatcherMain crashed on scheduled run: " .. tostring(err))
            -- do not reschedule to avoid crash loops
        end
    end, {}, timer.getTime() + DISPATCHER_CONFIG.interval)
end

-- Start the dispatcher
local ok, err = pcall(cargoDispatcherMain)
if not ok then
    log("FATAL: cargoDispatcherMain crashed on startup: " .. tostring(err))
end

log("═══════════════════════════════════════════════════════════════════════════════", true)
-- End Moose_TDAC_CargoDispatcher.lua


-- Diagnostic helper: call from DCS console to test spawn-by-name and routing.
-- Example (paste into DCS Lua console):
-- _G.TDAC_CargoDispatcher_TestSpawn("CARGO_BLUE_C130_TEMPLATE", "Kittila", "Luostari Pechenga")
function _G.TDAC_CargoDispatcher_TestSpawn(templateName, originAirbase, destinationAirbase)
    env.info("[TDAC TEST] Starting test spawn for template: " .. tostring(templateName))
    local ok, err
    if type(templateName) ~= 'string' then
        env.info("[TDAC TEST] templateName must be a string")
        return false, "invalid templateName"
    end
    local spawnByName = nil
    ok, spawnByName = pcall(function() return SPAWN:New(templateName) end)
    if not ok or not spawnByName then
        env.info("[TDAC TEST] SPAWN:New failed for template " .. tostring(templateName) .. ". Error: " .. tostring(spawnByName))
        if debug and debug.traceback then env.info(debug.traceback(tostring(spawnByName))) end
        return false, "spawn_new_failed"
    end

    spawnByName:OnSpawnGroup(function(spawnedGroup)
        env.info("[TDAC TEST] OnSpawnGroup called for: " .. tostring(spawnedGroup:GetName()))
        local dcsGroup = spawnedGroup:GetDCSObject()
        if dcsGroup then
            local units = dcsGroup:getUnits()
            if units and #units > 0 then
                local pos = units[1]:getPoint()
                env.info(string.format("[TDAC TEST] Spawned pos x=%.1f y=%.1f z=%.1f", pos.x, pos.y, pos.z))
            end
        end
        if destinationAirbase then
            local okAssign, errAssign = pcall(function()
                local base = AIRBASE:FindByName(destinationAirbase)
                if base and spawnedGroup and spawnedGroup.RouteToAirbase then
                    spawnedGroup:RouteToAirbase(base, AI_Task_Land.Runway)
                    env.info("[TDAC TEST] RouteToAirbase assigned to " .. tostring(destinationAirbase))
                else
                    env.info("[TDAC TEST] RouteToAirbase not available or base not found")
                end
            end)
            if not okAssign then
                env.info("[TDAC TEST] RouteToAirbase pcall failed: " .. tostring(errAssign))
                if debug and debug.traceback then env.info(debug.traceback(tostring(errAssign))) end
            end
        end
    end)

    ok, err = pcall(function() spawnByName:Spawn() end)
    if not ok then
        env.info("[TDAC TEST] spawnByName:Spawn() failed: " .. tostring(err))
        if debug and debug.traceback then env.info(debug.traceback(tostring(err))) end
        return false, "spawn_failed"
    end
    env.info("[TDAC TEST] spawnByName:Spawn() returned successfully")
    return true
end


-- Global notify API: allow external scripts (e.g. Load2nd) to mark a cargo mission as delivered.
-- Usage: _G.TDAC_CargoDelivered(groupName, destination, coalitionKey)
function _G.TDAC_CargoDelivered(groupName, destination, coalitionKey)
    local ok, err = pcall(function()
        if type(groupName) ~= 'string' or type(destination) ~= 'string' or type(coalitionKey) ~= 'string' then
            log("TDAC notify: invalid parameters to _G.TDAC_CargoDelivered", true)
            return false
        end
        coalitionKey = coalitionKey:lower()
        if not cargoMissions or not cargoMissions[coalitionKey] then
            log("TDAC notify: no cargoMissions table for coalition '" .. tostring(coalitionKey) .. "'", true)
            return false
        end
        -- Find any mission matching destination and group name (or group name substring) and mark completed.
        for _, mission in ipairs(cargoMissions[coalitionKey]) do
            local mname = mission.group and (mission.group.GetName and mission.group:GetName() or tostring(mission.group)) or nil
            if mission.destination == destination then
                if mname and string.find(mname:upper(), groupName:upper(), 1, true) then
                    mission.status = 'completed'
                    log("TDAC notify: marked mission " .. tostring(mname) .. " as completed for " .. destination .. " (" .. coalitionKey .. ")")
                    return true
                end
            end
        end
        log("TDAC notify: no matching mission found for group='" .. tostring(groupName) .. "' dest='" .. tostring(destination) .. "' coal='" .. tostring(coalitionKey) .. "'")
        return false
    end)
    if not ok then
        log("ERROR: _G.TDAC_CargoDelivered failed: " .. tostring(err), true)
        return false
    end
    return true
end
