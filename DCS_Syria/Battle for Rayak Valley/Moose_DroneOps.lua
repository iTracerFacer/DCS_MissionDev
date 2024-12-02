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





