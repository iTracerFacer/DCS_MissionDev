--[[
    AWACS Management System using MOOSE OPS
    
    This script provides a full-featured AWACS system with:
    - Automatic spawning and management
    - TACAN beacons
    - Radio frequencies
    - Proper callsigns
    - Automatic respawning when destroyed
    - F10 menu for information
    
    Requirements in Mission Editor:
    1. Aircraft groups named "BLUE EWR AWACS" and "RED EWR AWACS" (set to Late Activation)
    2. Trigger zones named "BLUE AWACS ZONE" and "RED AWACS ZONE"
    3. Airbases for each coalition (or use warehouses)
]]--

------------------------------------------------------------------------------------------------------------------
-- Configuration
------------------------------------------------------------------------------------------------------------------
local AWACS_CONFIG = {
    BLUE = {
        AIRBASE_NAME = "Kandahar",
        SQUADRON_TEMPLATE = "BLUE EWR AWACS",
        TACAN_CHANNEL = 29,
        TACAN_ID = "DXS",
        RADIO_FREQ = 251,
        CALLSIGN_TYPE = CALLSIGN.AWACS.Darkstar,
        CALLSIGN_NUM = 1,
        ORBIT_ZONE = "BLUE AWACS ZONE",
        ORBIT_ALTITUDE = 22000, -- in feet
        ORBIT_SPEED = 350, -- in knots
        ORBIT_HEADING = 270,
        ORBIT_RACETRACK = 20 -- in NM
    },
    RED = {
        AIRBASE_NAME = "Camp Bastion",
        SQUADRON_TEMPLATE = "RED EWR AWACS",
        TACAN_CHANNEL = 30,
        TACAN_ID = "RXS",
        RADIO_FREQ = 252,
        CALLSIGN_TYPE = CALLSIGN.AWACS.Magic,
        CALLSIGN_NUM = 1,
        ORBIT_ZONE = "RED AWACS ZONE",
        ORBIT_ALTITUDE = 22000, -- in feet
        ORBIT_SPEED = 350, -- in knots
        ORBIT_HEADING = 90,
        ORBIT_RACETRACK = 20 -- in NM
    }
}
------------------------------------------------------------------------------------------------------------------

env.info("========================================")
env.info("AWACS SYSTEM: Initializing")
env.info("========================================")

------------------------------------------------------------------------------------------------------------------
-- Blue Coalition AWACS System
------------------------------------------------------------------------------------------------------------------

env.info("AWACS SYSTEM: Setting up Blue Coalition AWACS")

-- Spawn the AWACS aircraft
local BlueAWACSSpawn = SPAWN:New(AWACS_CONFIG.BLUE.SQUADRON_TEMPLATE)
    :InitLimit(1, 99)
    :InitRepeatOnLanding()
    :SpawnScheduled(1, 0.5)

-- Create patrol zone
local BlueAwacsZone = ZONE:New(AWACS_CONFIG.BLUE.ORBIT_ZONE)
if not BlueAwacsZone then
    env.error("AWACS SYSTEM: Blue AWACS Zone NOT FOUND - check mission editor for zone named '" .. AWACS_CONFIG.BLUE.ORBIT_ZONE .. "'")
end

-- AWACS mission. Orbit at specified altitude, speed, heading, and racetrack length
local BlueAWACSMission = AUFTRAG:NewAWACS(BlueAwacsZone:GetCoordinate(), AWACS_CONFIG.BLUE.ORBIT_ALTITUDE, AWACS_CONFIG.BLUE.ORBIT_SPEED, AWACS_CONFIG.BLUE.ORBIT_HEADING, AWACS_CONFIG.BLUE.ORBIT_RACETRACK)
BlueAWACSMission:SetTime("8:00", "24:00")
BlueAWACSMission:SetTACAN(AWACS_CONFIG.BLUE.TACAN_CHANNEL, AWACS_CONFIG.BLUE.TACAN_ID)
BlueAWACSMission:SetRadio(AWACS_CONFIG.BLUE.RADIO_FREQ)
env.info("AWACS SYSTEM: Blue AWACS mission created - TACAN " .. AWACS_CONFIG.BLUE.TACAN_CHANNEL .. "Y, Radio " .. AWACS_CONFIG.BLUE.RADIO_FREQ .. " MHz")

-- Create a flightgroup and set default callsign
local BlueAWACSFlightGroup = FLIGHTGROUP:New(AWACS_CONFIG.BLUE.SQUADRON_TEMPLATE)
BlueAWACSFlightGroup:SetDefaultCallsign(AWACS_CONFIG.BLUE.CALLSIGN_TYPE, AWACS_CONFIG.BLUE.CALLSIGN_NUM)

-- Assign mission to flightgroup
BlueAWACSFlightGroup:AddMission(BlueAWACSMission)
env.info("AWACS SYSTEM: Blue AWACS Flightgroup created and mission assigned")

------------------------------------------------------------------------------------------------------------------
-- Red Coalition AWACS System
------------------------------------------------------------------------------------------------------------------

env.info("AWACS SYSTEM: Setting up Red Coalition AWACS")

-- Spawn the AWACS aircraft
local RedAWACSSpawn = SPAWN:New(AWACS_CONFIG.RED.SQUADRON_TEMPLATE)
    :InitLimit(1, 99)
    :InitRepeatOnLanding()
    :SpawnScheduled(1, 0.5)

-- Create patrol zone
local RedAwacsZone = ZONE:New(AWACS_CONFIG.RED.ORBIT_ZONE)
if not RedAwacsZone then
    env.error("AWACS SYSTEM: Red AWACS Zone NOT FOUND - check mission editor for zone named '" .. AWACS_CONFIG.RED.ORBIT_ZONE .. "'")
end

-- AWACS mission. Orbit at specified altitude, speed, heading, and racetrack length
local RedAWACSMission = AUFTRAG:NewAWACS(RedAwacsZone:GetCoordinate(), AWACS_CONFIG.RED.ORBIT_ALTITUDE, AWACS_CONFIG.RED.ORBIT_SPEED, AWACS_CONFIG.RED.ORBIT_HEADING, AWACS_CONFIG.RED.ORBIT_RACETRACK)
RedAWACSMission:SetTime("8:00", "24:00")
RedAWACSMission:SetTACAN(AWACS_CONFIG.RED.TACAN_CHANNEL, AWACS_CONFIG.RED.TACAN_ID)
RedAWACSMission:SetRadio(AWACS_CONFIG.RED.RADIO_FREQ)
env.info("AWACS SYSTEM: Red AWACS mission created - TACAN " .. AWACS_CONFIG.RED.TACAN_CHANNEL .. "Y, Radio " .. AWACS_CONFIG.RED.RADIO_FREQ .. " MHz")

-- Create a flightgroup and set default callsign
local RedAWACSFlightGroup = FLIGHTGROUP:New(AWACS_CONFIG.RED.SQUADRON_TEMPLATE)
RedAWACSFlightGroup:SetDefaultCallsign(AWACS_CONFIG.RED.CALLSIGN_TYPE, AWACS_CONFIG.RED.CALLSIGN_NUM)

-- Assign mission to flightgroup
RedAWACSFlightGroup:AddMission(RedAWACSMission)
env.info("AWACS SYSTEM: Red AWACS Flightgroup created and mission assigned")

------------------------------------------------------------------------------------------------------------------
-- F10 Menu - AWACS Information
------------------------------------------------------------------------------------------------------------------

env.info("AWACS SYSTEM: Creating F10 menus")

-- Blue Coalition Menu (nested under Mission Options)
local BlueAwacsMenu = MenuManager.CreateCoalitionMenu(coalition.side.BLUE, "AWACS Information")
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Show AWACS Details", BlueAwacsMenu, function()
    local msg = "=== BLUE AWACS INFORMATION ===\n\n"
    msg = msg .. "Callsign: Darkstar 1-1\n"
    msg = msg .. "Radio Frequency: " .. AWACS_CONFIG.BLUE.RADIO_FREQ .. ".000 MHz AM\n"
    msg = msg .. "TACAN: " .. AWACS_CONFIG.BLUE.TACAN_CHANNEL .. "Y (" .. AWACS_CONFIG.BLUE.TACAN_ID .. ")\n"
    msg = msg .. "Orbit Altitude: " .. AWACS_CONFIG.BLUE.ORBIT_ALTITUDE .. " ft\n"
    msg = msg .. "Operational Hours: 08:00 - 24:00\n"
    msg = msg .. "Pattern: " .. AWACS_CONFIG.BLUE.ORBIT_RACETRACK .. " NM racetrack, heading " .. AWACS_CONFIG.BLUE.ORBIT_HEADING .. "\n\n"
    msg = msg .. "Usage: Tune to " .. AWACS_CONFIG.BLUE.RADIO_FREQ .. " MHz AM and contact Darkstar for tactical picture and vectors."
    MESSAGE:New(msg, 30, "INFO"):ToCoalition(coalition.side.BLUE)
end)

-- Red Coalition Menu (nested under Mission Options)
local RedAwacsMenu = MenuManager.CreateCoalitionMenu(coalition.side.RED, "AWACS Information")
MENU_COALITION_COMMAND:New(coalition.side.RED, "Show AWACS Details", RedAwacsMenu, function()
    local msg = "=== RED AWACS INFORMATION ===\n\n"
    msg = msg .. "Callsign: Magic 1-1\n"
    msg = msg .. "Radio Frequency: " .. AWACS_CONFIG.RED.RADIO_FREQ .. ".000 MHz AM\n"
    msg = msg .. "TACAN: " .. AWACS_CONFIG.RED.TACAN_CHANNEL .. "Y (" .. AWACS_CONFIG.RED.TACAN_ID .. ")\n"
    msg = msg .. "Orbit Altitude: " .. AWACS_CONFIG.RED.ORBIT_ALTITUDE .. " ft\n"
    msg = msg .. "Operational Hours: 08:00 - 24:00\n"
    msg = msg .. "Pattern: " .. AWACS_CONFIG.RED.ORBIT_RACETRACK .. " NM racetrack, heading " .. AWACS_CONFIG.RED.ORBIT_HEADING .. "\n\n"
    msg = msg .. "Usage: Tune to " .. AWACS_CONFIG.RED.RADIO_FREQ .. " MHz AM and contact Magic for tactical picture and vectors."
    MESSAGE:New(msg, 30, "INFO"):ToCoalition(coalition.side.RED)
end)

env.info("AWACS SYSTEM: F10 menus created")

env.info("========================================")
env.info("AWACS SYSTEM: Initialization Complete")
env.info("========================================")
