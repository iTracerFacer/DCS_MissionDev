--[[
    Script: Moose_DynamicGroundBattle_Plugin.lua
    Written by: [F99th-TracerFacer]
    Version: 1.0.0
    Date: 15 November 2024
    Description: Warehouse-driven ground unit spawning system that works as a plugin
    with Moose_DualCoalitionZoneCapture.lua
    
    This script handles:
        - Warehouse-based reinforcement system
        - Dynamic spawn frequency based on warehouse survival
        - Automated AI tasking to patrol nearest enemy zones
        - Optional infantry patrol control
        - Warehouse status intel markers
        - CTLD troop integration
    
    What this script DOES NOT do:
        - Zone capture logic (handled by Moose_DualCoalitionZoneCapture.lua)
        - Win conditions (handled by Moose_DualCoalitionZoneCapture.lua)
        - Zone coloring/messaging (handled by Moose_DualCoalitionZoneCapture.lua)
    
    Load Order (in Mission Editor Triggers):
        1. DO SCRIPT FILE Moose_.lua
        2. DO SCRIPT FILE Moose_DualCoalitionZoneCapture.lua
        3. DO SCRIPT FILE Moose_DynamicGroundBattle_Plugin.lua  <-- This file
        4. DO SCRIPT FILE CTLD.lua (optional)
        5. DO SCRIPT FILE CSAR.lua (optional)

    Requirements:
        - MOOSE framework must be loaded first
        - Moose_DualCoalitionZoneCapture.lua must be loaded BEFORE this script
        - Zone configuration comes from DualCoalitionZoneCapture's ZONE_CONFIG
        - Groups and warehouses must exist in mission editor (see below)

    Warehouse System & Spawn Frequency Behavior:
        1. Each side has warehouses defined in `redWarehouses` and `blueWarehouses` tables
        2. Spawn frequency dynamically adjusts based on alive warehouses:
           - 100% alive = 100% spawn rate (base frequency)
           - 50% alive = 50% spawn rate (2x delay)
           - 0% alive = no spawns (critical attrition)
        3. Map markers show warehouse locations and nearby units
        4. Updated every UPDATE_MARK_POINTS_SCHED seconds

    AI Task Assignment:
        - Groups spawn in friendly zones, then patrol toward nearest enemy zone
        - Reassignment occurs every ASSIGN_TASKS_SCHED seconds
        - Only stationary units get new orders (moving units are left alone)
        - CTLD-dropped troops automatically integrate

    Groups to Create in Mission Editor (all LATE ACTIVATE):
        RED SIDE:
        - Infantry Templates: RedInfantry1, RedInfantry2, RedInfantry3, RedInfantry4, RedInfantry5, RedInfantry6
        - Armor Templates: RedArmor1, RedArmor2, RedArmor3, RedArmor4, RedArmor5, RedArmor6
        - Warehouses (Static Objects): RedWarehouse1-1, RedWarehouse2-1, RedWarehouse3-1, etc.
        
        BLUE SIDE:
        - Infantry Templates: BlueInfantry1, BlueInfantry2, BlueInfantry3, BlueInfantry4, BlueInfantry5, BlueInfantry6
        - Armor Templates: BlueArmor1, BlueArmor2, BlueArmor3, BlueArmor4, BlueArmor5
        - Warehouses (Static Objects): BlueWarehouse1-1, BlueWarehouse2-1, BlueWarehouse3-1, etc.

        NOTE: Warehouse names use the static "Unit Name" in mission editor, not the "Name" field!

    Integration with DualCoalitionZoneCapture:
        - This script reads zoneCaptureObjects and zoneNames from DualCoalitionZoneCapture
        - Spawns occur in zones controlled by the appropriate coalition
        - AI tasks units to patrol zones from DualCoalitionZoneCapture's ZONE_CONFIG
--]]

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- USER CONFIGURATION SECTION
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Infantry Patrol Settings
local MOVING_INFANTRY_PATROLS = false  -- Set to false to disable infantry movement (they spawn and hold position)

-- Warehouse Marker Settings
local ENABLE_WAREHOUSE_MARKERS = true  -- Enable/disable warehouse map markers (disabled by default if you have other marker systems)
local UPDATE_MARK_POINTS_SCHED = 300    -- Update warehouse markers every 300 seconds (5 minutes)
local MAX_WAREHOUSE_UNIT_LIST_DISTANCE = 5000  -- Max distance to search for units near warehouses for markers

-- Spawn Frequency and Limits
local INIT_RED_INFANTRY = 5            -- Initial number of Red Infantry groups
local MAX_RED_INFANTRY = 100           -- Maximum number of Red Infantry groups
local SPAWN_SCHED_RED_INFANTRY = 1800  -- Base spawn frequency for Red Infantry (seconds)

local INIT_RED_ARMOR = 25              -- Initial number of Red Armor groups
local MAX_RED_ARMOR = 200              -- Maximum number of Red Armor groups
local SPAWN_SCHED_RED_ARMOR = 300      -- Base spawn frequency for Red Armor (seconds)

local INIT_BLUE_INFANTRY = 5           -- Initial number of Blue Infantry groups
local MAX_BLUE_INFANTRY = 100          -- Maximum number of Blue Infantry groups
local SPAWN_SCHED_BLUE_INFANTRY = 1800 -- Base spawn frequency for Blue Infantry (seconds)

local INIT_BLUE_ARMOR = 25             -- Initial number of Blue Armor groups
local MAX_BLUE_ARMOR = 200             -- Maximum number of Blue Armor groups
local SPAWN_SCHED_BLUE_ARMOR = 300     -- Base spawn frequency for Blue Armor (seconds)

local ASSIGN_TASKS_SCHED = 600         -- How often to reassign tasks to idle groups (seconds)

-- Define warehouses for each side
local redWarehouses = {
    STATIC:FindByName("RedWarehouse1-1"),
    STATIC:FindByName("RedWarehouse2-1"),
    STATIC:FindByName("RedWarehouse3-1"),
    STATIC:FindByName("RedWarehouse4-1"),
    STATIC:FindByName("RedWarehouse5-1"),
    STATIC:FindByName("RedWarehouse6-1")
}

local blueWarehouses = {
    STATIC:FindByName("BlueWarehouse1-1"),
    STATIC:FindByName("BlueWarehouse2-1"),
    STATIC:FindByName("BlueWarehouse3-1"),
    STATIC:FindByName("BlueWarehouse4-1"),
    STATIC:FindByName("BlueWarehouse5-1"),
    STATIC:FindByName("BlueWarehouse6-1")
}

-- Define unit templates (these groups must exist in mission editor as LATE ACTIVATE)
local redInfantryTemplates = {
    "RedInfantry1",
    "RedInfantry2",
    "RedInfantry3",
    "RedInfantry4",
    "RedInfantry5",
    "RedInfantry6"
}

local redArmorTemplates = {
    "RedArmor1",
    "RedArmor2",
    "RedArmor3",
    "RedArmor4",
    "RedArmor5",
    "RedArmor6"
}

local blueInfantryTemplates = {
    "BlueInfantry1",
    "BlueInfantry2",
    "BlueInfantry3",
    "BlueInfantry4",
    "BlueInfantry5",
    "BlueInfantry6"
}

local blueArmorTemplates = {
    "BlueArmor1",
    "BlueArmor2",
    "BlueArmor3",
    "BlueArmor4",
    "BlueArmor5"
}

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DO NOT EDIT BELOW THIS LINE
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

env.info("[DGB PLUGIN] Dynamic Ground Battle Plugin initializing...")

-- Validate that DualCoalitionZoneCapture is loaded
if not zoneCaptureObjects or not zoneNames then
    env.error("[DGB PLUGIN] ERROR: Moose_DualCoalitionZoneCapture.lua must be loaded BEFORE this plugin!")
    env.error("[DGB PLUGIN] Make sure zoneCaptureObjects and zoneNames are available.")
    return
end

env.info("[DGB PLUGIN] Found " .. #zoneCaptureObjects .. " zones from DualCoalitionZoneCapture")

-- Track active markers to prevent memory leaks
local activeMarkers = {}

-- Reusable SET_GROUP to prevent memory leaks from repeated creation
local cachedAllGroups = nil
local function getAllGroups()
    if not cachedAllGroups then
        cachedAllGroups = SET_GROUP:New():FilterActive():FilterStart()
        env.info("[DGB PLUGIN] Created cached SET_GROUP for performance")
    end
    return cachedAllGroups
end

-- Function to get zones controlled by a specific coalition
local function GetZonesByCoalition(targetCoalition)
    local zones = {}
    
    for idx, zoneCapture in ipairs(zoneCaptureObjects) do
        if zoneCapture and zoneCapture:GetCoalition() == targetCoalition then
            local zone = zoneCapture:GetZone()
            if zone then
                table.insert(zones, zone)
            end
        end
    end
    
    env.info(string.format("[DGB PLUGIN] Found %d zones for coalition %d", #zones, targetCoalition))
    return zones
end

-- Function to calculate spawn frequency based on warehouse survival
local function CalculateSpawnFrequency(warehouses, baseFrequency)
    local totalWarehouses = #warehouses
    local aliveWarehouses = 0

    for _, warehouse in ipairs(warehouses) do
        if warehouse then
            local life = warehouse:GetLife()
            if life and life > 0 then
                aliveWarehouses = aliveWarehouses + 1
            end
        end
    end

    if totalWarehouses == 0 or aliveWarehouses == 0 then
        return math.huge -- Stop spawning if no warehouses remain
    end

    local frequency = baseFrequency * (totalWarehouses / aliveWarehouses)
    return frequency
end

-- Function to calculate spawn frequency as a percentage
local function CalculateSpawnFrequencyPercentage(warehouses)
    local totalWarehouses = #warehouses
    local aliveWarehouses = 0

    for _, warehouse in ipairs(warehouses) do
        if warehouse then
            local life = warehouse:GetLife()
            if life and life > 0 then
                aliveWarehouses = aliveWarehouses + 1
            end
        end
    end

    if totalWarehouses == 0 then
        return 0
    end

    local percentage = (aliveWarehouses / totalWarehouses) * 100
    return math.floor(percentage)
end

-- Function to add warehouse markers on the map
local function addMarkPoints(warehouses, coalition)
    for _, warehouse in ipairs(warehouses) do
        if warehouse then
            local warehousePos = warehouse:GetVec3()
            local details
            
            if coalition == 2 then  -- Blue viewing
                if warehouse:GetCoalition() == 2 then
                    details = "Warehouse: " .. warehouse:GetName() .. "\nThis warehouse needs to be protected.\n"
                else
                    details = "Warehouse: " .. warehouse:GetName() .. "\nThis is a primary target as it is directly supplying enemy units.\n"
                end
            elseif coalition == 1 then  -- Red viewing
                if warehouse:GetCoalition() == 1 then
                    details = "Warehouse: " .. warehouse:GetName() .. "\nThis warehouse needs to be protected.\n"
                else
                    details = "Warehouse: " .. warehouse:GetName() .. "\nThis is a primary target as it is directly supplying enemy units.\n"
                end
            end

            local coordinate = COORDINATE:NewFromVec3(warehousePos)
            local marker = MARKER:New(coordinate, details):ToCoalition(coalition):ReadOnly()
            table.insert(activeMarkers, marker)
        end
    end
end

-- Function to update warehouse markers
local function updateMarkPoints()
    -- Clean up old markers first
    for _, marker in ipairs(activeMarkers) do
        if marker then
            marker:Remove()
        end
    end
    activeMarkers = {}
    
    addMarkPoints(redWarehouses, 2)   -- Blue coalition sees red warehouses
    addMarkPoints(blueWarehouses, 2)  -- Blue coalition sees blue warehouses
    addMarkPoints(redWarehouses, 1)   -- Red coalition sees red warehouses
    addMarkPoints(blueWarehouses, 1)  -- Red coalition sees blue warehouses
    
    env.info("[DGB PLUGIN] Updated warehouse markers")
end

-- Function to check if a group contains infantry units
local function IsInfantryGroup(group)
    for _, unit in ipairs(group:GetUnits()) do
        local unitTypeName = unit:GetTypeName()
        if unitTypeName:find("Infantry") or unitTypeName:find("Soldier") or unitTypeName:find("Paratrooper") then
            return true
        end
    end
    return false
end

-- Function to assign tasks to a group
local function AssignTasks(group)
    if not group or not group.GetCoalition or not group.GetCoordinate or not group.GetVelocityVec3 then
        return
    end

    -- Don't reassign if already moving
    local velocity = group:GetVelocityVec3()
    local speed = math.sqrt(velocity.x^2 + velocity.y^2 + velocity.z^2)
    if speed > 0.5 then
        return
    end

    local groupCoalition = group:GetCoalition()
    local groupCoordinate = group:GetCoordinate()
    local closestZone = nil
    local closestDistance = math.huge

    -- Find nearest enemy zone
    for idx, zoneCapture in ipairs(zoneCaptureObjects) do
        local zoneCoalition = zoneCapture:GetCoalition()
        
        if zoneCoalition ~= groupCoalition and zoneCoalition ~= coalition.side.NEUTRAL then
            local zone = zoneCapture:GetZone()
            if zone then
                local zoneCoordinate = zone:GetCoordinate()
                local distance = groupCoordinate:Get2DDistance(zoneCoordinate)
                
                if distance < closestDistance then
                    closestDistance = distance
                    closestZone = zone
                end
            end
        end
    end

    if closestZone then
        env.info(string.format("[DGB PLUGIN] %s patrolling %s", group:GetName(), closestZone:GetName()))
        group:PatrolZones({closestZone}, 20, "Cone", 30, 60)
    end
end

-- Function to assign tasks to all groups
local function AssignTasksToGroups()
    env.info("[DGB PLUGIN] Starting task assignment cycle...")
    local allGroups = getAllGroups()
    local tasksAssigned = 0

    allGroups:ForEachGroup(function(group)
        if group and group:IsAlive() then
            -- Check if group is in a friendly zone
            local groupCoalition = group:GetCoalition()
            local inFriendlyZone = false
            
            for idx, zoneCapture in ipairs(zoneCaptureObjects) do
                if zoneCapture:GetCoalition() == groupCoalition then
                    local zone = zoneCapture:GetZone()
                    if zone and group:IsCompletelyInZone(zone) then
                        inFriendlyZone = true
                        break
                    end
                end
            end
            
            if inFriendlyZone then
                -- Skip infantry if movement is disabled
                if IsInfantryGroup(group) and not MOVING_INFANTRY_PATROLS then
                    return
                end
                
                AssignTasks(group)
                tasksAssigned = tasksAssigned + 1
            end
        end
    end)
    
    env.info(string.format("[DGB PLUGIN] Task assignment complete. %d groups tasked.", tasksAssigned))
end

-- Function to monitor and announce warehouse status
local function MonitorWarehouses()
    local blueWarehousesAlive = 0
    local redWarehousesAlive = 0

    for _, warehouse in ipairs(blueWarehouses) do
        if warehouse and warehouse:IsAlive() then
            blueWarehousesAlive = blueWarehousesAlive + 1
        end
    end

    for _, warehouse in ipairs(redWarehouses) do
        if warehouse and warehouse:IsAlive() then
            redWarehousesAlive = redWarehousesAlive + 1
        end
    end

    local redSpawnFrequencyPercentage = CalculateSpawnFrequencyPercentage(redWarehouses)
    local blueSpawnFrequencyPercentage = CalculateSpawnFrequencyPercentage(blueWarehouses)

    local msg = "[Warehouse Status]\n"
    msg = msg .. "Red warehouses alive: " .. redWarehousesAlive .. " Reinforcements: " .. redSpawnFrequencyPercentage .. "%\n"
    msg = msg .. "Blue warehouses alive: " .. blueWarehousesAlive .. " Reinforcements: " .. blueSpawnFrequencyPercentage .. "%\n"
    MESSAGE:New(msg, 30):ToAll()
    
    env.info(string.format("[DGB PLUGIN] Warehouse status - Red: %d/%d (%d%%), Blue: %d/%d (%d%%)",
        redWarehousesAlive, #redWarehouses, redSpawnFrequencyPercentage,
        blueWarehousesAlive, #blueWarehouses, blueSpawnFrequencyPercentage))
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INITIALIZATION
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Get initial zone lists for each coalition
local redZones = GetZonesByCoalition(coalition.side.RED)
local blueZones = GetZonesByCoalition(coalition.side.BLUE)

-- Calculate initial spawn frequencies
local redInfantrySpawnFrequency = CalculateSpawnFrequency(redWarehouses, SPAWN_SCHED_RED_INFANTRY)
local redArmorSpawnFrequency = CalculateSpawnFrequency(redWarehouses, SPAWN_SCHED_RED_ARMOR)
local blueInfantrySpawnFrequency = CalculateSpawnFrequency(blueWarehouses, SPAWN_SCHED_BLUE_INFANTRY)
local blueArmorSpawnFrequency = CalculateSpawnFrequency(blueWarehouses, SPAWN_SCHED_BLUE_ARMOR)

-- Calculate and display initial spawn frequency percentages
local redSpawnFrequencyPercentage = CalculateSpawnFrequencyPercentage(redWarehouses)
local blueSpawnFrequencyPercentage = CalculateSpawnFrequencyPercentage(blueWarehouses)

MESSAGE:New("Red reinforcement capacity: " .. redSpawnFrequencyPercentage .. "%", 30):ToRed()
MESSAGE:New("Blue reinforcement capacity: " .. blueSpawnFrequencyPercentage .. "%", 30):ToBlue()

-- Initialize spawners
env.info("[DGB PLUGIN] Initializing spawn systems...")

-- Note: Spawn zones will be dynamically updated based on zone capture states
-- We'll use a function to get current friendly zones on each spawn
local function GetRedZones()
    return GetZonesByCoalition(coalition.side.RED)
end

local function GetBlueZones()
    return GetZonesByCoalition(coalition.side.BLUE)
end

-- Red Infantry Spawner
redInfantrySpawn = SPAWN:New("RedInfantryGroup")
    :InitRandomizeTemplate(redInfantryTemplates)
    :InitLimit(INIT_RED_INFANTRY, MAX_RED_INFANTRY)

-- Red Armor Spawner
redArmorSpawn = SPAWN:New("RedArmorGroup")
    :InitRandomizeTemplate(redArmorTemplates)
    :InitLimit(INIT_RED_ARMOR, MAX_RED_ARMOR)

-- Blue Infantry Spawner
blueInfantrySpawn = SPAWN:New("BlueInfantryGroup")
    :InitRandomizeTemplate(blueInfantryTemplates)
    :InitLimit(INIT_BLUE_INFANTRY, MAX_BLUE_INFANTRY)

-- Blue Armor Spawner
blueArmorSpawn = SPAWN:New("BlueArmorGroup")
    :InitRandomizeTemplate(blueArmorTemplates)
    :InitLimit(INIT_BLUE_ARMOR, MAX_BLUE_ARMOR)

-- Custom spawn function that updates zones dynamically
local function SpawnWithDynamicZones()
    local currentRedZones = GetRedZones()
    local currentBlueZones = GetBlueZones()
    
    if #currentRedZones > 0 then
        local randomRedZone = currentRedZones[math.random(#currentRedZones)]
        redInfantrySpawn:SpawnInZone(randomRedZone, false)
        redArmorSpawn:SpawnInZone(randomRedZone, false)
    end
    
    if #currentBlueZones > 0 then
        local randomBlueZone = currentBlueZones[math.random(#currentBlueZones)]
        blueInfantrySpawn:SpawnInZone(randomBlueZone, false)
        blueArmorSpawn:SpawnInZone(randomBlueZone, false)
    end
end

-- Schedule spawns
SCHEDULER:New(nil, SpawnWithDynamicZones, {}, 10, math.max(SPAWN_SCHED_RED_INFANTRY, SPAWN_SCHED_BLUE_INFANTRY))

-- Schedule warehouse marker updates
if ENABLE_WAREHOUSE_MARKERS then
    SCHEDULER:New(nil, updateMarkPoints, {}, 10, UPDATE_MARK_POINTS_SCHED)
end

-- Schedule warehouse monitoring
SCHEDULER:New(nil, MonitorWarehouses, {}, 30, 120)

-- Schedule task assignments
SCHEDULER:New(nil, AssignTasksToGroups, {}, 120, ASSIGN_TASKS_SCHED)

-- Add F10 menu for manual checks
local missionMenu = MENU_MISSION:New("Ground Battle")
MENU_MISSION_COMMAND:New("Check Warehouse Status", missionMenu, MonitorWarehouses)

env.info("[DGB PLUGIN] Dynamic Ground Battle Plugin initialized successfully!")
env.info(string.format("[DGB PLUGIN] Infantry movement: %s", MOVING_INFANTRY_PATROLS and "ENABLED" or "DISABLED"))
env.info(string.format("[DGB PLUGIN] Warehouse markers: %s", ENABLE_WAREHOUSE_MARKERS and "ENABLED" or "DISABLED"))
