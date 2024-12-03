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

--- *** Step 2: Setup Artillery and Naval Units ***
local ArtilleryUnit = GROUP:FilterPrefixes("Blue-MT"):FilterStart() -- Replace with your artillery unit name
local NavalUnit = GROUP:FindByName("BlueShip")         -- Replace with your naval unit name

--- *** Step 3: Function to Call Artillery Fire ***
local function CallArtilleryFire(targetCoord)
    if ArtilleryUnit and ArtilleryUnit:IsAlive() then
        ArtilleryUnit:FireAtPoint(targetCoord, "HE") -- Use High-Explosive rounds
        MESSAGE:New("Artillery fire called on target!", 15):ToAll()
    else
        MESSAGE:New("Artillery unit is not available.", 15):ToAll()
    end
end

--- *** Step 4: Function to Call Naval Strike ***
local function CallNavalStrike(targetCoord)
    if NavalUnit and NavalUnit:IsAlive() then
        NavalUnit:EngageTargetsInArea(targetCoord, 500) -- Engage within 500-meter radius
        MESSAGE:New("Naval strike ordered on target!", 15):ToAll()
    else
        MESSAGE:New("Naval unit is not available.", 15):ToAll()
    end
end

--- *** Step 5: Handle Target Detection ***
local function OnTargetDetected(DetectedSet)
    DetectedSet:ForEachUnit(function(Unit)
        local targetCoord = Unit:GetCoordinate()
        local targetType = Unit:GetTypeName()

        -- Inform players of detected target
        MESSAGE:New("Target detected: " .. targetType, 15):ToAll()

        -- Example: Automatically call artillery fire
        CallArtilleryFire(targetCoord)
    end)
end

BlueDetectionSet:OnAfterDetected(OnTargetDetected)

--- *** Step 6: F10 Menu for Player Interaction ***
local FACMenu = MENU_COALITION:New(coalition.side.BLUE, "Arty Commands")

local function RequestArtilleryFire()
    local detectedTargets = BlueDetectionSet:GetDetectedTargets()
    if #detectedTargets > 0 then
        local target = detectedTargets[1] -- Example: Select the first target
        CallArtilleryFire(target:GetCoordinate())
    else
        MESSAGE:New("No targets detected by FAC.", 15):ToAll()
    end
end

local function RequestNavalStrike()
    local detectedTargets = BlueDetectionSet:GetDetectedTargets()
    if #detectedTargets > 0 then
        local target = detectedTargets[1] -- Example: Select the first target
        CallNavalStrike(target:GetCoordinate())
    else
        MESSAGE:New("No targets detected by FAC.", 15):ToAll()
    end
end

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Request Artillery Fire", FACMenu, RequestArtilleryFire)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Request Naval Strike", FACMenu, RequestNavalStrike)

--- *** Step 7: Enhance Realism ***
local function MarkTargetWithSmoke(targetCoord)
    targetCoord:SmokeBlue()
    MESSAGE:New("Target marked with blue smoke!", 15):ToAll()
end

BlueDetectionSet:OnAfterDetected(function(DetectedSet)
    DetectedSet:ForEachUnit(function(Unit)
        MarkTargetWithSmoke(Unit:GetCoordinate())
    end)
end)

--- *** Debug Messages ***
MESSAGE:New("FAC and fire support scripts initialized!", 15):ToAll()
