-- Debugging flag
local DEBUG = true

-- Define AWACS and its escorts
local awacsGroupName = "BLUE EWR AWACS"
local escortGroup1Name = "BlueAWACS_Escort_Group1"

-- Configuration parameters
local patrolAltMin = 5000
local patrolAltMax = 8000
local escortFollowDistance = 1000
local respawnCheckInterval = 10
local maxEscortSpawns = 10 -- maximum number of escort spawns - might take this out.

-- Function to print debug messages if DEBUG is enabled
local function DebugMessage(message)
    if DEBUG and message then
        env.info("[AWACS DEBUG] " .. tostring(message))
    end
end

-- Function to send a message to all players
local function Announce(message, soundFile)
    if message then
        MESSAGE:New(message, 15):ToAll()
    end
    if soundFile then
        --local sound = SOUND:New(soundFile)
        --sound:ToAll()
    end
end

-- Define the patrol zone
local patrolZone = ZONE:New("AWACS_PatrolZone")
if patrolZone then
    DebugMessage("Patrol zone created: " .. patrolZone:GetName())
else
    DebugMessage("ERROR: Patrol zone 'AWACS_PatrolZone' not found. Check the mission editor.")
    return  -- Exit if the patrol zone is not defined
end



-- Define the AWACS spawn
local awacsSpawn = SPAWN:New(awacsGroupName):InitLimit(1, 0)

-- Function to spawn and attach escorts to AWACS
function spawnEscort(escortGroupName, awacsGroup)
    if not escortGroupName or not awacsGroup then
        DebugMessage("ERROR: Invalid escort group name or AWACS group.")
        return
    end

    DebugMessage("Spawning escort: " .. escortGroupName)
    Announce("Spawning escort for AWACS.", "escort_spawn.ogg")

    local escortSpawn = SPAWN:New(escortGroupName):InitLimit(1, maxEscortSpawns)

    escortSpawn:OnSpawnGroup(function(escortGroup)
        if not escortGroup then
            DebugMessage("ERROR: Escort group failed to spawn.")
            return
        end

        DebugMessage("Escort spawned: " .. escortGroup:GetName())

        -- Set the escort group to follow the AWACS
        SCHEDULER:New(nil, function()
            if awacsGroup:IsAlive() and escortGroup:IsAlive() then
                escortGroup:TaskFollow(awacsGroup, escortFollowDistance)
                DebugMessage("Escort assigned to follow AWACS.")
            else
                DebugMessage("AWACS or escort is not alive.")
            end
        end, {}, 3, respawnCheckInterval)
    end):Spawn()
end

-- Start AWACS in a patrol pattern within the patrol zone
awacsSpawn:InitRepeatOnEngineShutDown()
    :OnSpawnGroup(function(awacsGroup)
        if not awacsGroup then
            DebugMessage("ERROR: AWACS group failed to spawn.")
            return
        end

        DebugMessage("AWACS spawned: " .. awacsGroup:GetName())
        Announce("AWACS is now airborne and patrolling.", "awacs_spawn.ogg")

        -- Create a patrol task for the AWACS in the defined zone
        local patrolTask = AI_PATROL_ZONE:New(patrolZone, patrolAltMin, patrolAltMax)
        patrolTask:SetControllable(awacsGroup)
        patrolTask:__Start(1)
        DebugMessage("Patrol task assigned to AWACS.")

        -- Spawn and manage escorts
        spawnEscort(escortGroup1Name, awacsGroup)
    end)
    :Spawn()

-- Create a scheduled task to check if AWACS is alive and respawn if destroyed
SCHEDULER:New(nil, function()
    local awacsGroup = awacsSpawn:GetLastAliveGroup()
    if not awacsGroup or not awacsGroup:IsAlive() then
        DebugMessage("AWACS destroyed. Respawning...")
        Announce("AWACS has been destroyed! Respawning...", "awacs_destroyed.ogg")
        awacsSpawn:Spawn()
    end
end, {}, 0, respawnCheckInterval)
