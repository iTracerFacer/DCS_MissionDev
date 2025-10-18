--[[
═══════════════════════════════════════════════════════════════════════════════
                Moose_TDAC_CargoDispatcher.lua
    Automated Logistics System for TADC Squadron Replenishment
═══════════════════════════════════════════════════════════════════════════════

DESCRIPTION:
    This script monitors RED and BLUE squadrons for low aircraft counts and automatically dispatches CARGO aircraft from a list of supply airfields to replenish them. It spawns cargo aircraft and routes them to destination airbases. Delivery detection and replenishment is handled by the main TADC system.

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

--[[
    CARGO SUPPLY CONFIGURATION
    --------------------------------------------------------------------------
    Set supply airfields, cargo template names, and resupply thresholds for each coalition.
]]
local CARGO_SUPPLY_CONFIG = {
    red = {
        supplyAirfields = { "Sochi-Adler", "Gudauta", "Sukhumi-Babushara", "Nalchik", "Beslan", "Maykop-Khanskaya" }, -- replace with your RED supply airbase names
        cargoTemplate = "CARGO_RED_AN26",    -- replace with your RED cargo aircraft template name
        threshold = 0.90                              -- ratio below which to trigger resupply (testing)
    },
    blue = {
        supplyAirfields = { "Batumi", "Kobuleti", "Senaki-Kolkhi", "Kutaisi", "Soganlug" }, -- replace with your BLUE supply airbase names
        cargoTemplate = "CARGO_BLUE_C130",   -- replace with your BLUE cargo aircraft template name
        threshold = 0.90                              -- ratio below which to trigger resupply (testing)
    }
}



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
    logPrefix = "[TADC Cargo]"
}

-- Logging function (must be defined before any log() calls)
local function log(message, detailed)
    if not detailed or ADVANCED_LOGGING.enableDetailedLogging then
        env.info(ADVANCED_LOGGING.logPrefix .. " " .. message)
    end
end

log("═══════════════════════════════════════════════════════════════════════════════", true)
log("Moose_TDAC_CargoDispatcher.lua loaded.", true)
log("═══════════════════════════════════════════════════════════════════════════════", true)

-- Dispatch cooldown per airbase (seconds) to avoid repeated immediate retries
local CARGO_DISPATCH_COOLDOWN = DISPATCHER_CONFIG and DISPATCHER_CONFIG.cooldown or 300 -- default 5 minutes
local lastDispatchAttempt = { red = {}, blue = {} }

-- Forward-declare parking check helper so functions defined earlier can call it
local destinationHasSuitableParking

-- Validate dispatcher configuration: check that supply airfields exist and templates appear valid
local function validateDispatcherConfig()
    local problems = {}

    -- Check supply airfields exist
    for coalitionKey, cfg in pairs(CARGO_SUPPLY_CONFIG) do
        if cfg and cfg.supplyAirfields and type(cfg.supplyAirfields) == 'table' then
            for _, abName in ipairs(cfg.supplyAirfields) do
                local ok, ab = pcall(function() return AIRBASE:FindByName(abName) end)
                if not ok or not ab then
                    table.insert(problems, string.format("Missing airbase for %s supply list: '%s'", tostring(coalitionKey), tostring(abName)))
                end
            end
        else
            table.insert(problems, string.format("Missing or invalid supplyAirfields for coalition '%s'", tostring(coalitionKey)))
        end

        -- Check cargo template presence (best-effort using SPAWN:New if available)
        if cfg and cfg.cargoTemplate and type(cfg.cargoTemplate) == 'string' and cfg.cargoTemplate ~= '' then
            local okSpawn, spawnObj = pcall(function() return SPAWN:New(cfg.cargoTemplate) end)
            if not okSpawn or not spawnObj then
                -- SPAWN:New may not be available at load time; warn but don't fail hard
                table.insert(problems, string.format("Cargo template suspicious or missing: '%s' (coalition: %s)", tostring(cfg.cargoTemplate), tostring(coalitionKey)))
            end
        else
            table.insert(problems, string.format("Missing cargoTemplate for coalition '%s'", tostring(coalitionKey)))
        end
    end

    if #problems == 0 then
        log("TADC Dispatcher config validation passed ✓", true)
        MESSAGE:New("TADC Dispatcher config validation passed ✓", 15):ToAll()
        return true, {}
    else
        log("TADC Dispatcher config validation found issues:", true)
        MESSAGE:New("TADC Dispatcher config validation found issues:" .. table.concat(problems, ", "), 15):ToAll()
        for _, p in ipairs(problems) do
            log("  ✗ " .. p, true)
        end
        return false, problems
    end
end

-- Expose console helper to run the check manually
function _G.TDAC_RunConfigCheck()
    local ok, problems = validateDispatcherConfig()
    if ok then
        return true, "OK"
    else
        return false, problems
    end
end



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
    Removes failed cargo missions from the tracking table if their group is no longer alive.
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
    local origin
    local attempts = 0
    local maxAttempts = 10
    repeat
        origin = selectRandomAirfield(config.supplyAirfields)
        attempts = attempts + 1
        -- Ensure origin is not the same as destination
        if origin == squadron.airbaseName then
            origin = nil
        end
    until origin or attempts >= maxAttempts
    
    -- enforce cooldown per destination to avoid immediate retries
    lastDispatchAttempt[coalitionKey] = lastDispatchAttempt[coalitionKey] or {}
    local last = lastDispatchAttempt[coalitionKey][squadron.airbaseName]
    if last and (timer.getTime() - last) < CARGO_DISPATCH_COOLDOWN then
        log("Skipping dispatch to " .. squadron.airbaseName .. " (cooldown active)")
        return
    end
    if not origin then
        log("No valid origin airfield found for cargo dispatch to " .. squadron.airbaseName .. " (avoiding same origin/destination)")
        return
    end
    local destination = squadron.airbaseName
    local cargoTemplate = config.cargoTemplate
    -- Safety: check if destination has suitable parking for larger transports. If not, warn in log.
    local okParking = true
    -- Only check for likely large transports (C-130 / An-26 are large-ish) — keep conservative
    if cargoTemplate and (string.find(cargoTemplate:upper(), "C130") or string.find(cargoTemplate:upper(), "C-17") or string.find(cargoTemplate:upper(), "C17") or string.find(cargoTemplate:upper(), "AN26") ) then
        okParking = destinationHasSuitableParking(destination)
        if not okParking then
            log("WARNING: Destination '" .. tostring(destination) .. "' may not have suitable parking for " .. tostring(cargoTemplate) .. ". Skipping dispatch to prevent despawn.")
            return
        end
    end
    local groupName = cargoTemplate .. "_to_" .. destination .. "_" .. math.random(1000,9999)

    log("Dispatching cargo: " .. groupName .. " from " .. origin .. " to " .. destination)

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
    log("DEBUG: Attempting RAT spawn for template: '" .. cargoTemplate .. "' alias: '" .. alias .. "'", true)

    -- Check if destination airbase exists and is controlled by the correct coalition
    local destAirbase = AIRBASE:FindByName(destination)
    if not destAirbase then
        log("ERROR: Destination airbase '" .. destination .. "' does not exist. Skipping dispatch.")
        return
    end
    if destAirbase:GetCoalition() ~= getCoalitionSide(coalitionKey) then
        log("ERROR: Destination airbase '" .. destination .. "' is not controlled by " .. coalitionKey .. " coalition. Skipping dispatch.")
        return
    end

    local okNew, rat = pcall(function() return RAT:New(cargoTemplate, alias) end)
    if not okNew or not rat then
        log("ERROR: RAT:New failed for template '" .. tostring(cargoTemplate) .. "'. Error: " .. tostring(rat))
        if debug and debug.traceback then
            log("TRACEBACK: " .. tostring(debug.traceback(rat)), true)
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

        -- Temporary debug: log group state every 10s for 10 minutes to trace landing/parking behavior
        local debugChecks = 60 -- 60 * 10s = 10 minutes
        local checkInterval = 10
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
                        local controller = dcs:getController()
                        local airbaseObj = AIRBASE:FindByName(destination)
                        local dist = nil
                        if airbaseObj then
                            local dest = airbaseObj:GetCoordinate():GetVec2()
                            local dx = pos.x - dest.x
                            local dz = pos.z - dest.y
                            dist = math.sqrt(dx*dx + dz*dz)
                        end
                        log(string.format("[TADC DEBUG] %s state check %d: alive=%s pos=(%.1f,%.1f) speed=%.2f m/s distToDest=%s", name, iter, tostring(spawnedGroup:IsAlive()), pos.x or 0, pos.z or 0, speed, tostring(dist)), true)
                    else
                        log(string.format("[TADC DEBUG] %s state check %d: DCS group has no units", tostring(spawnedGroup:GetName()), iter), true)
                    end
                else
                    log(string.format("[TADC DEBUG] %s state check %d: no DCS group object", tostring(spawnedGroup:GetName()), iter), true)
                end
            end)
            if not ok then
                log("[TADC DEBUG] Error during debugLogState: " .. tostring(err), true)
            end
            timer.scheduleFunction(function() debugLogState(iter + 1) end, {}, timer.getTime() + checkInterval)
        end
        timer.scheduleFunction(function() debugLogState(1) end, {}, timer.getTime() + checkInterval)

        -- RAT should handle routing/taxi/parking. Finalize mission tracking now.
        finalizeMissionAfterSpawn(spawnedGroup, spawnPos)
        mission.status = "enroute"
        mission._pendingStartTime = timer.getTime()
        announceToCoalition(coalitionKey, "CARGO aircraft departing (airborne) for " .. destination .. ". Defend it!")
    end)

    local okSpawn, errSpawn = pcall(function() rat:Spawn(1) end)
    if not okSpawn then
        log("ERROR: rat:Spawn() failed for template '" .. tostring(cargoTemplate) .. "'. Error: " .. tostring(errSpawn))
        if debug and debug.traceback then
            log("TRACEBACK: " .. tostring(debug.traceback(errSpawn)), true)
        end
        return
    end
end


-- Parking diagnostics helper
-- Call from DCS console: _G.TDAC_LogAirbaseParking("Luostari Pechenga")
function _G.TDAC_LogAirbaseParking(airbaseName)
    if type(airbaseName) ~= 'string' then
        log("TADC Parking helper: airbaseName must be a string", true)
        return false
    end
    local base = AIRBASE:FindByName(airbaseName)
    if not base then
        log("TADC Parking helper: AIRBASE:FindByName returned nil for '" .. tostring(airbaseName) .. "'", true)
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
    log(string.format("TADC Parking: %s -> OpenBig=%s OpenMed=%s OpenMedOrBig=%s Runway=%s", airbaseName, tostring(openBig), tostring(openMed), tostring(openMedOrBig), tostring(runway)), true)
    return true
end


-- Pre-dispatch safety check: ensure destination can accommodate larger transport types
destinationHasSuitableParking = function(destination, preferredTermTypes)
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
    Monitors all cargo missions, updates their status, and cleans up failed ones.
    Handles mission failure after a grace period.
]]
local function monitorCargoMissions()
    for _, coalitionKey in ipairs({"red", "blue"}) do
        for _, mission in ipairs(cargoMissions[coalitionKey]) do
            if mission.group == nil then
                log("[DEBUG] Mission group object is nil for mission to " .. tostring(mission.destination), true)
            else
                log("[DEBUG] Mission group: " .. tostring(mission.group:GetName()) .. ", IsAlive(): " .. tostring(mission.group:IsAlive()), true)
                local dcsGroup = mission.group:GetDCSObject()
                if dcsGroup then
                    local units = dcsGroup:getUnits()
                    if units and #units > 0 then
                        local pos = units[1]:getPoint()
                        log(string.format("[DEBUG] Group position: x=%.1f y=%.1f z=%.1f", pos.x, pos.y, pos.z), true)
                    else
                        log("[DEBUG] No units found in DCS group for mission to " .. tostring(mission.destination), true)
                    end
                else
                    log("[DEBUG] DCS group object is nil for mission to " .. tostring(mission.destination), true)
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
                    log("DEBUG: Mission appears to still have DCS units despite IsAlive=false; skipping failure for " .. tostring(mission.destination), true)
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
    log("[TADC TEST] Starting test spawn for template: " .. tostring(templateName), true)
    local ok, err
    if type(templateName) ~= 'string' then
        env.info("[TADC TEST] templateName must be a string")
        return false, "invalid templateName"
    end
    local spawnByName = nil
    ok, spawnByName = pcall(function() return SPAWN:New(templateName) end)
    if not ok or not spawnByName then
    log("[TADC TEST] SPAWN:New failed for template " .. tostring(templateName) .. ". Error: " .. tostring(spawnByName), true)
    if debug and debug.traceback then log("TRACEBACK: " .. tostring(debug.traceback(tostring(spawnByName))), true) end
        return false, "spawn_new_failed"
    end

    spawnByName:OnSpawnGroup(function(spawnedGroup)
    log("[TADC TEST] OnSpawnGroup called for: " .. tostring(spawnedGroup:GetName()), true)
        local dcsGroup = spawnedGroup:GetDCSObject()
        if dcsGroup then
            local units = dcsGroup:getUnits()
            if units and #units > 0 then
                local pos = units[1]:getPoint()
                log(string.format("[TADC TEST] Spawned pos x=%.1f y=%.1f z=%.1f", pos.x, pos.y, pos.z), true)
            end
        end
        if destinationAirbase then
            local okAssign, errAssign = pcall(function()
                local base = AIRBASE:FindByName(destinationAirbase)
                if base and spawnedGroup and spawnedGroup.RouteToAirbase then
                    spawnedGroup:RouteToAirbase(base, AI_Task_Land.Runway)
                    log("[TADC TEST] RouteToAirbase assigned to " .. tostring(destinationAirbase), true)
                else
                    log("[TADC TEST] RouteToAirbase not available or base not found", true)
                end
            end)
            if not okAssign then
                log("[TADC TEST] RouteToAirbase pcall failed: " .. tostring(errAssign), true)
                if debug and debug.traceback then log("TRACEBACK: " .. tostring(debug.traceback(tostring(errAssign))), true) end
            end
        end
    end)

    ok, err = pcall(function() spawnByName:Spawn() end)
    if not ok then
        log("[TADC TEST] spawnByName:Spawn() failed: " .. tostring(err), true)
        if debug and debug.traceback then log("TRACEBACK: " .. tostring(debug.traceback(tostring(err))), true) end
        return false, "spawn_failed"
    end
    log("[TADC TEST] spawnByName:Spawn() returned successfully", true)
    return true
end


log("═══════════════════════════════════════════════════════════════════════════════", true)
-- End Moose_TDAC_CargoDispatcher.lua

