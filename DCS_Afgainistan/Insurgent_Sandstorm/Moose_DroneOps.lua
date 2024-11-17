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

-- Create a detection area using the Blue_Drone group and the combined zones
local droneDetection = DETECTION_UNITS:New(Blue_Drone)
droneDetection:SetAcceptZones(combinedZones)
droneDetection:Start()

-- Function to present target options to the player
local function RequestTargetOptions()
  if not droneDetection then
    MESSAGE:New("Drone detection is not initialized", 10):ToAll()
    return
  end

  local detectedTargets = droneDetection:GetDetectedSet()
  if not detectedTargets or #detectedTargets == 0 then
    MESSAGE:New("No targets detected", 10):ToAll()
    return
  end
  MESSAGE:New("Targets Detected, use menu again to select.", 10):ToAll()
  local targetMenu = MENU_COALITION:New(coalition.side.BLUE, "Select Target", nil)
  
  for i, target in ipairs(detectedTargets) do
    local targetName = target:GetName()
    MENU_COALITION_COMMAND:New(coalition.side.BLUE, targetName, targetMenu, function()
      PresentActionOptions(target)
    end)
  end
end

-- Function to present action options for a selected target
local function PresentActionOptions(target)
  local actionMenu = MENU_COALITION:New(coalition.side.BLUE, "Select Action for " .. target:GetName(), nil)
  
  MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Smoke (Red)", actionMenu, function()
    target:SmokeTarget(SMOKECOLOR.Red)
  end)
  MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Smoke (Green)", actionMenu, function()
    target:SmokeTarget(SMOKECOLOR.Green)
  end)
  MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Lase (Code 1688)", actionMenu, function()
    target:LaseTarget(1688)
  end)
  MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Flare (Red)", actionMenu, function()
    target:FlareTarget(FLARECOLOR.Red)
  end)
  MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Flare (Green)", actionMenu, function()
    target:FlareTarget(FLARECOLOR.Green)
  end)
end

-- Create the main mission menu
missionMenu = MENU_MISSION:New("Mission Menu")

-- Create the Drone Menu for the player to interact with the drone
local DroneMenu = MENU_COALITION:New(coalition.side.BLUE, "Drone Ops", missionMenu)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Request Target Options", DroneMenu, RequestTargetOptions)