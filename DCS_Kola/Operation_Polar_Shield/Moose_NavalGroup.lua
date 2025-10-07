-- Expected Behavior
-- CVN Will patrol designated patrol zones. Staying in the zone assigned.
-- Player can designate which zone to move to. 
-- Player can request turning into the wind. 
-- After turning into the wind, CVN should return to original coord then resume waypoints.

  -- 
  ---
local msgTime = 15
local SetCVNActivePatrolZone = 1 --if active waypoint is 1, steam between 1 and 2, if active is 2, steam between 2 and 3.

-- Dynamic patrol zone configuration based on ship's waypoints
local PatrolZones = {} -- Will store patrol zone configurations dynamically
local TotalWaypoints = 0 -- Will be set when the ship is initialized


local CVN_carrier_group = GROUP:FindByName("CVN-72 Abraham Lincoln") -- put the exact GROUP name of your carrier-group as set in the mission editor within the " "
local CVN_beacon_unit = UNIT:FindByName("CVN-72 Abraham Lincoln")-- -- put the exact UNIT name of your carrier-unit as set in the mission editor within the " "

-- Check if the unit was found
if not CVN_beacon_unit then
  env.warning("CVN beacon unit 'CVN-72 Abraham Lincoln' not found - trying group leader instead")
  if CVN_carrier_group then
    CVN_beacon_unit = CVN_carrier_group:GetUnit(1) -- Get the first unit of the group
  end
end
local CVN_ICLS_Channel = 5  -- replace with the ICLS channel you want
local CVN_ICLS_Name = "CVN"   -- put the 3-letter ICLS identifier you want to use for the ICLS channel
local CVN_TACAN_Channel = 1  -- replace with the TACAN channel you want
local CVN_TACAN_Name = "CVN"   -- put the 3-letter TACAN identifier you want to use for the TACAN channel
local CVN_RecoveryWindowTime = 20  -- time in minutes for how long recovery will be open, feel free to change the number


-- Functions to move ship to designated waypoint/zones
local msgCVNPatrol = "Sending Carrier Group to Patrol Zone: "

-- Dynamic function to set patrol zone based on available waypoints
function SetCVNPatrolZone(zoneNumber)
  if PatrolZones[zoneNumber] then
    SetCVNActivePatrolZone = zoneNumber
    MESSAGE:New(msgCVNPatrol .. SetCVNActivePatrolZone .. " (Waypoints " .. PatrolZones[zoneNumber].startWP .. "-" .. PatrolZones[zoneNumber].endWP .. ")", msgTime):ToBlue()
    USERSOUND:New("ping.ogg"):ToCoalition(coalition.side.BLUE)
    BlueCVNGroup:GotoWaypoint(PatrolZones[zoneNumber].startWP)
  else
    MESSAGE:New("Invalid patrol zone: " .. zoneNumber, msgTime):ToBlue()
  end
end

-- Initialize patrol zones based on ship's waypoints
function InitializePatrolZones()
  PatrolZones = {}
  -- Use GetWaypoints() method instead of CountWaypoints()
  local waypoints = BlueCVNGroup:GetWaypoints()
  TotalWaypoints = #waypoints
  
  -- Create patrol zones dynamically based on available waypoints
  -- Each patrol zone consists of 2 consecutive waypoints
  local zoneNumber = 1
  for i = 1, TotalWaypoints - 1 do
    PatrolZones[zoneNumber] = {
      startWP = i,
      endWP = i + 1
    }
    zoneNumber = zoneNumber + 1
  end
  
  -- If we have enough waypoints, add a patrol zone that loops back to the beginning
  if TotalWaypoints > 2 then
    PatrolZones[zoneNumber] = {
      startWP = TotalWaypoints,
      endWP = 1
    }
  end
  
  local text = string.format("Initialized %d patrol zones based on %d waypoints", #PatrolZones, TotalWaypoints)
  MESSAGE:New(text, msgTime):ToBlue()
  env.info(text)
end

if CVN_beacon_unit then
  BlueCVNGroup_Beacon = CVN_beacon_unit:GetBeacon()
  BlueCVNGroup_Beacon:ActivateICLS(CVN_ICLS_Channel,CVN_ICLS_Name)
end
SCHEDULER:New(nil,function()
  if CVN_beacon_unit then
    BlueCVNGroup_Beacon = CVN_beacon_unit:GetBeacon()
    BlueCVNGroup_Beacon:ActivateTACAN(CVN_TACAN_Channel,"X",CVN_TACAN_Name,true)
  end
end,{},5,5*60)

-- Function to turn ship into the wind.
function start_recovery()
  
  if BlueCVNGroup:IsSteamingIntoWind() == true then
    local unitName = CVN_beacon_unit and CVN_beacon_unit:GetName() or "CVN-72 Abraham Lincoln"
    MESSAGE:New(unitName .. " is currently launching/recovering aircraft, currently active recovery window closes at time " .. timerecovery_end, msgTime, "CVNNAVINFO",false):ToBlue()
    USERSOUND:New("ping.ogg"):ToCoalition(coalition.side.BLUE)
  else
    local timenow=timer.getAbsTime( )
    local timeend=timenow+CVN_RecoveryWindowTime*60 -- this sets the recovery window to 45 minutes, you can change the numbers as you wish
    local timerecovery_start = UTILS.SecondsToClock(timenow,true)
    timerecovery_end = UTILS.SecondsToClock(timeend,true)
    BlueCVNGroup:AddTurnIntoWind(timerecovery_start,timerecovery_end,25,true,-9)
    local unitName = CVN_beacon_unit and CVN_beacon_unit:GetName() or "CVN-72 Abraham Lincoln"
    MESSAGE:New(unitName.." is turning into the wind to begin " .. CVN_RecoveryWindowTime .. " mins of aircraft operations.\nLaunch/Recovery Window will be open from time " .. timerecovery_start .. " until " .. timerecovery_end, msgTime, "CVNNAVINFO",false):ToBlue()
    USERSOUND:New("ping.ogg"):ToCoalition(coalition.side.BLUE)
  end
end


  
  -- AWACS functionality - only initialize if the group exists in the mission
  BlueAwacs = nil
  Spawn_US_AWACS = nil
  
  -- Check if AWACS group exists before trying to spawn it
  local awacsGroupName = "BLUE-EWR E-3 Focus Group"
  local awacsTemplate = GROUP:FindByName(awacsGroupName)
  
  if awacsTemplate then
    Spawn_US_AWACS = SPAWN:New(awacsGroupName)
    :InitLimit(1,500)
    :InitRepeatOnLanding()
    
    :OnSpawnGroup( function (SpawnGroup)
      BlueAwacs = SpawnGroup
    end
    ):SpawnScheduled(30,.5)
    
    env.info("AWACS system initialized successfully")
  else
    env.warning("AWACS group '" .. awacsGroupName .. "' not found in mission - AWACS functionality disabled")
  end

function ResetAwacs()
  if BlueAwacs then
    BlueAwacs:Destroy()
    MESSAGE:New("Resetting AWACS...", msgTime, "CVNNAVINFO",false):ToBlue()
    USERSOUND:New("ping.ogg"):ToCoalition(coalition.side.BLUE)
  else
    MESSAGE:New("No AWACS to reset - AWACS functionality not available", msgTime):ToBlue()
  end
end




-- Build the Menu (will be populated dynamically after initialization)
local CVNMenu = MENU_COALITION:New(coalition.side.BLUE,"CVN Command")

-- Function to build dynamic patrol zone menu
function BuildPatrolMenu()
  -- Clear existing patrol zone menus (if any)
  
  -- Add patrol zone options based on available waypoints
  for zoneNum = 1, #PatrolZones do
    local menuText = string.format("Patrol Zone %d (WP %d-%d)", zoneNum, PatrolZones[zoneNum].startWP, PatrolZones[zoneNum].endWP)
    MENU_COALITION_COMMAND:New(coalition.side.BLUE, menuText, CVNMenu, function() SetCVNPatrolZone(zoneNum) end)
  end
  
  -- Add AWACS reset option only if AWACS is available
  if Spawn_US_AWACS then
    MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Reset AWACS",CVNMenu,ResetAwacs)
  end
  
  -- Add carrier operations menu
  MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Launch/Recover Aircraft (Turn carrier into the wind)",CVNMenu,start_recovery)
end







-- Create a NAVYGROUP object and activate the late activated group.
BlueCVNGroup=NAVYGROUP:New("CVN-72 Abraham Lincoln")  
BlueCVNGroup:SetVerbosity(1)
BlueCVNGroup:MarkWaypoints()

-- Initialize patrol zones based on ship's actual waypoints
SCHEDULER:New(nil, function()
  InitializePatrolZones()
  BuildPatrolMenu()
end, {}, 2) -- Delay to ensure the group is properly initialized



--- Function called each time the group passes a waypoint.
function BlueCVNGroup:OnAfterPassingWaypoint(From, Event, To, Waypoint)
  local waypoint=Waypoint --Ops.OpsGroup#OPSGROUP.Waypoint
  
  -- Debug info.
  local unitName = CVN_beacon_unit and CVN_beacon_unit:GetName() or "CVN-72 Abraham Lincoln"
  local text=string.format(unitName.." passed waypoint ID=%d (Index=%d) %d times", waypoint.uid, BlueCVNGroup:GetWaypointIndex(waypoint.uid), waypoint.npassed)
  MESSAGE:New(text, msgTime):ToBlue()
  USERSOUND:New("ping.ogg"):ToCoalition(coalition.side.BLUE)
  env.info(text)
  
  -- Dynamic patrol logic based on current patrol zone
  if PatrolZones[SetCVNActivePatrolZone] then
    local currentZone = PatrolZones[SetCVNActivePatrolZone]
    local currentWaypointID = waypoint.uid
    
    -- If we reached the end waypoint of current patrol zone, go to start waypoint
    if currentWaypointID == currentZone.endWP then
      BlueCVNGroup:GotoWaypoint(currentZone.startWP)
      local patrolText = string.format("Patrolling: Going to waypoint %d (Zone %d)", currentZone.startWP, SetCVNActivePatrolZone)
      MESSAGE:New(patrolText, msgTime):ToBlue()
      env.info(patrolText)
    -- If we reached the start waypoint of current patrol zone, go to end waypoint  
    elseif currentWaypointID == currentZone.startWP then
      BlueCVNGroup:GotoWaypoint(currentZone.endWP)
      local patrolText = string.format("Patrolling: Going to waypoint %d (Zone %d)", currentZone.endWP, SetCVNActivePatrolZone)
      MESSAGE:New(patrolText, msgTime):ToBlue()
      env.info(patrolText)
    end
  end
     
end

--- Function called when the group is cruising. This is the "normal" state when the group follows its waypoints.
function BlueCVNGroup:OnAfterCruise(From, Event, To)
  local unitName = CVN_beacon_unit and CVN_beacon_unit:GetName() or "CVN-72 Abraham Lincoln"
  local text=unitName.." is cruising straight and steady."
  MESSAGE:New(text, msgTime):ToBlue()
  USERSOUND:New("ping.ogg"):ToCoalition(coalition.side.BLUE)
  env.info(text)
end

--- Function called when the groups starts to turn.
function BlueCVNGroup:OnAfterTurningStarted(From, Event, To)
  local unitName = CVN_beacon_unit and CVN_beacon_unit:GetName() or "CVN-72 Abraham Lincoln"
  local text=unitName.." has started turning!"
  MESSAGE:New(text, msgTime):ToBlue()
  USERSOUND:New("ping.ogg"):ToCoalition(coalition.side.BLUE)
  env.info(text)
end  

--- Function called when the group stopps to turn.
function BlueCVNGroup:OnAfterTurningStopped(From, Event, To)
  local unitName = CVN_beacon_unit and CVN_beacon_unit:GetName() or "CVN-72 Abraham Lincoln"
  local text=unitName.." has stopped turning..proceeding to next waypoint."
  MESSAGE:New(text, msgTime):ToBlue()
  USERSOUND:New("ping.ogg"):ToCoalition(coalition.side.BLUE)
  env.info(text)
end

-- Turn the carrier into the wind for a few mins
-- This function is called by other parts of the script
-- BlueCVNGroup:AddTurnIntoWind() is called from start_recovery() 



-- Monitor entering and leaving zones. There are four zones named "Zone Leg 1", "Zone Leg 2", ...
local ZoneSet=SET_ZONE:New():FilterPrefixes("CVN Patrol"):FilterOnce()

-- Set zones which are checked if the group enters or leaves it.
BlueCVNGroup:SetCheckZones(ZoneSet)

--- Function called when the group enteres a zone.
function BlueCVNGroup:OnAfterEnterZone(From, Event, To, Zone)
  local unitName = CVN_beacon_unit and CVN_beacon_unit:GetName() or "CVN-72 Abraham Lincoln"
  local text=string.format(unitName.." has entered patrol zone %s.", Zone:GetName())
  MESSAGE:New(text, msgTime):ToBlue()
  USERSOUND:New("ping.ogg"):ToCoalition(coalition.side.BLUE)
  env.info(text)    
end

--- Function called when the group leaves a zone.
function BlueCVNGroup:OnAfterLeaveZone(From, Event, To, Zone)
  local unitName = CVN_beacon_unit and CVN_beacon_unit:GetName() or "CVN-72 Abraham Lincoln"
  local text=string.format(unitName.." left patrol zone %s.", Zone:GetName())
  MESSAGE:New(text, msgTime):ToBlue()
  USERSOUND:New("ping.ogg"):ToCoalition(coalition.side.BLUE)
  env.info(text)    
end