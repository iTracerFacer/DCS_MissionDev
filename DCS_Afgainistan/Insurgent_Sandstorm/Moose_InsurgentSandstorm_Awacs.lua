------------------------------------------------------------------------------------------------------------------
-- Blue AWACS
------------------------------------------------------------------------------------------------------------------

env.info("AWACS SCRIPT: Starting Blue AWACS initialization")

-- Simple SPAWN approach - spawns immediately and respawns on landing
BlueAWACS = SPAWN:New("BLUE EWR AWACS")
    :InitLimit(1, 99)
    :InitRepeatOnLanding()
    :SpawnScheduled(1, 0.5)
    
env.info("AWACS SCRIPT: Blue AWACS spawned")

------------------------------------------------------------------------------------------------------------------
-- Red AWACS
------------------------------------------------------------------------------------------------------------------

env.info("AWACS SCRIPT: Starting Red AWACS initialization")

-- Simple SPAWN approach - spawns immediately and respawns on landing
RedAWACS = SPAWN:New("RED EWR AWACS")
    :InitLimit(1, 99)
    :InitRepeatOnLanding()
    :SpawnScheduled(1, 0.5)
    
env.info("AWACS SCRIPT: Red AWACS spawned")

------------------------------------------------------------------------------------------------------------------
-- F10 Menu - AWACS Information
------------------------------------------------------------------------------------------------------------------

env.info("AWACS SCRIPT: Creating F10 menus")

-- Blue Coalition Menu (nested under Mission Options)
local BlueAwacsMenu = MenuManager.CreateCoalitionMenu(coalition.side.BLUE, "AWACS Information")
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Show AWACS Details", BlueAwacsMenu, function()
    local msg = "=== BLUE AWACS INFORMATION ===\n\n"
    msg = msg .. "Callsign: Darkstar 1-1\n"
    msg = msg .. "Radio Frequency: 251.000 MHz AM\n"
    msg = msg .. "TACAN: 29Y (DXS)\n"
    msg = msg .. "Orbit Altitude: 22,000 ft\n"
    msg = msg .. "Operational Hours: 08:00 - 24:00\n\n"
    msg = msg .. "Usage: Tune to 251 MHz AM and contact Darkstar for tactical picture and vectors."
    MESSAGE:New(msg, 30, "INFO"):ToCoalition(coalition.side.BLUE)
end)

-- Red Coalition Menu (nested under Mission Options)
local RedAwacsMenu = MenuManager.CreateCoalitionMenu(coalition.side.RED, "AWACS Information")
MENU_COALITION_COMMAND:New(coalition.side.RED, "Show AWACS Details", RedAwacsMenu, function()
    local msg = "=== RED AWACS INFORMATION ===\n\n"
    msg = msg .. "Callsign: Magic 1-1\n"
    msg = msg .. "Radio Frequency: 252.000 MHz AM\n"
    msg = msg .. "TACAN: 30Y (RXS)\n"
    msg = msg .. "Orbit Altitude: 22,000 ft\n"
    msg = msg .. "Operational Hours: 08:00 - 24:00\n\n"
    msg = msg .. "Usage: Tune to 252 MHz AM and contact Magic for tactical picture and vectors."
    MESSAGE:New(msg, 30, "INFO"):ToCoalition(coalition.side.RED)
end)

env.info("AWACS SCRIPT: Initialization complete")