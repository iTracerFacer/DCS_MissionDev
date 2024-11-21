-- Define the red and blue zones

  

local redZones = {
    ZONE:New("FrontLine1"),
    ZONE:New("FrontLine2"),
    ZONE:New("FrontLine3"),
    ZONE:New("FrontLine4"),
    ZONE:New("FrontLine5"),
    ZONE:New("FrontLine6"),
    ZONE:New("FrontLine7"),
    ZONE:New("FrontLine8")
}

local blueZones = {
    ZONE:New("FrontLine9"),
    ZONE:New("FrontLine10"),
    ZONE:New("FrontLine11"),
    ZONE:New("FrontLine12"),
    ZONE:New("FrontLine13"),
    ZONE:New("FrontLine14"),
    ZONE:New("FrontLine15"),
    ZONE:New("FrontLine16")
}

-- Combine the redZones and blueZones tables into one table
local combinedZones = {}
for _, zone in ipairs(redZones) do
    table.insert(combinedZones, zone)
end
for _, zone in ipairs(blueZones) do
    table.insert(combinedZones, zone)
end

-- Define the drone using the MOOSE SPAWN class
Blue_Drone = SPAWN:New("BLUE DRONE")
    :InitLimit(1, 99)
    :SpawnScheduled(1, 0.5)

-- Function to set the drone as a FAC after it spawns
Blue_Drone:OnSpawnGroup(function(spawnGroup)
    local droneGroup = spawnGroup -- Reference to the spawned group
    local droneUnit = droneGroup:GetUnit(1) -- Get the first unit in the group

    if droneUnit then
        -- Define a FAC task for the drone
        local facTask = {
            id = "FAC",
            params = {
                callsign = 1, -- Arbitrary callsign (e.g., "Enfield")
                frequency = 255.0, -- Frequency for communication
            }
        }

        -- Set the FAC task to the drone
        droneUnit:SetTask(facTask)

        env.info("Blue Drone is now a FAC and ready to designate targets.")
    else
        env.info("No valid unit found in Blue Drone group.")
    end
end)

