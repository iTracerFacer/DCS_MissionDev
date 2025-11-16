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
Blue_Drone = SPAWN:New("FAC DRONE")
    :InitLimit(1, 99)
    :InitRepeatOnLanding()
    :SpawnScheduled(1, 0.5)


-- Define FAC Set
BlueFACSet = SET_GROUP:New():FilterPrefixes("FAC"):FilterStart()
BlueDetectionSet = DETECTION_AREAS:New(BlueFACSet, 5000)
BlueAttackSet = SET_GROUP:New():FilterCoalitions("blue"):FilterStart()
BlueDesignator = DESIGNATE:New(US_CC, BlueDetectionSet, BlueAttackSet)
BlueDesignator:SetAutoLase(false)
BlueDesignator:SetThreatLevelPrioritization(true)
BlueDesignator:GenerateLaserCodes(true)





