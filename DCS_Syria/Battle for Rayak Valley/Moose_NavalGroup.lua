-- Expected Behavior
-- CVN Will patrol designated patrol zones. Staying in the zone assigned.
-- Player can designate which zone to move to. 
-- Plyaer can request turning into the wind. 
-- After turning into the wind, CVN should return to orignal coord then resume waypoints.

  -- 
  ---
local msgTime = 15
local SetCVNActivePatrolZone = 1 --if active waypoint is 1, steam between 1 and 2, if active is 2, steam between 2 and 3.


local CVN_carrier_group = GROUP:FindByName("CVN-72 Abraham Lincoln Carrier Group") -- put the exact GROUP name of your carrier-group as set in the mission editor within the " "
local CVN_beacon_unit = UNIT:FindByName("CVN-72 Abraham Lincoln")-- -- put the exact UNIT name of your carrier-unit as set in the mission editor within the " "
local CVN_ICLS_Channel = 1  -- replace with the ICLS channel you want
local CVN_ICLS_Name = "CVN"   -- put the 3-letter ICLS identifier you want to use for the ICLS channel
local CVN_TACAN_Channel = 72  -- replace with the TACAN channel you want
local CVN_TACAN_Name = "CVN"   -- put the 3-letter TACAN identifier you want to use for the TACAN channel
local CVN_RecoveryWindowTime = 20  -- time in minutes for how long recovery will be open, feel free to change the number


-- Functions to move ship to designated waypoint/zones
local msgCVNPatrol = "Sending Carrier Group to Patrol Zone: "
function SetCVNWayPoint1()
  SetCVNActivePatrolZone = 1
  MESSAGE:New(msgCVNPatrol .. SetCVNActivePatrolZone, msgTime):ToBlue()
  USERSOUND:New("ping.ogg"):ToCoalition(coalition.side.BLUE)
  BlueCVNGroup:GotoWaypoint(1)
end

function SetCVNWayPoint2()
  SetCVNActivePatrolZone = 2
  MESSAGE:New(msgCVNPatrol .. SetCVNActivePatrolZone, msgTime):ToBlue()
  USERSOUND:New("ping.ogg"):ToCoalition(coalition.side.BLUE)
  BlueCVNGroup:GotoWaypoint(3)
end

function SetCVNWayPoint3()
  SetCVNActivePatrolZone = 3
  MESSAGE:New(msgCVNPatrol .. SetCVNActivePatrolZone, msgTime):ToBlue()
  USERSOUND:New("ping.ogg"):ToCoalition(coalition.side.BLUE)
  BlueCVNGroup:GotoWaypoint(5)
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
    MESSAGE:New(CVN_beacon_unit:GetName() .. " is currently launching/recovering aircraft, currently active recovery window closes at time " .. timerecovery_end, msgTime, "CVNNAVINFO",false):ToBlue()
    USERSOUND:New("ping.ogg"):ToCoalition(coalition.side.BLUE)
  else
    local timenow=timer.getAbsTime( )
    local timeend=timenow+CVN_RecoveryWindowTime*60 -- this sets the recovery window to 45 minutes, you can change the numbers as you wish
    local timerecovery_start = UTILS.SecondsToClock(timenow,true)
    timerecovery_end = UTILS.SecondsToClock(timeend,true)
    BlueCVNGroup:AddTurnIntoWind(timerecovery_start,timerecovery_end,25,true,-9)
    MESSAGE:New(CVN_beacon_unit:GetName().." is turning into the wind to begin " .. CVN_RecoveryWindowTime .. " mins of aircraft operations.\nLaunch/Recovery Window will be open from time " .. timerecovery_start .. " until " .. timerecovery_end, msgTime, "CVNNAVINFO",false):ToBlue()
    USERSOUND:New("ping.ogg"):ToCoalition(coalition.side.BLUE)
  end
end


  
  BlueAwacs = nil
  Spawn_US_AWACS = SPAWN:New("BLUE EWR AWACS")
  :InitLimit(1,500)
  :InitRepeatOnLanding()
  
  :OnSpawnGroup( function (SpawnGroup)
    BlueAwacs = SpawnGroup
  end
  ):SpawnScheduled(30,.5)

function ResetAwacs()
  BlueAwacs:Destroy()
  MESSAGE:New("Resetting AWACS...", msgTime, "CVNNAVINFO",false):ToBlue()
  USERSOUND:New("ping.ogg"):ToCoalition(coalition.side.BLUE)
end

-- Build the Menu
local CarrierMovement = MENU_COALITION:New(coalition.side.BLUE, "Carrier Movement", CarrierMenu)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "CVN Group - Patrol Zone 1", CarrierMovement, SetCVNWayPoint1)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "CVN Group - Patrol Zone 2", CarrierMovement, SetCVNWayPoint3)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "CVN Group - Patrol Zone 3", CarrierMovement, SetCVNWayPoint5)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Reset AWACS", CarrierMovement,ResetAwacs)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Launch/Recover Aircraft (Turn carrier into the wind)", CarrierMovement, start_recovery)







-- Create a NAVYGROUP object and activate the late activated group.
BlueCVNGroup=NAVYGROUP:New("CVN-72 Abraham Lincoln Carrier Group")  
BlueCVNGroup:SetVerbosity(1)
BlueCVNGroup:MarkWaypoints()



--- Function called each time the group passes a waypoint.
function BlueCVNGroup:OnAfterPassingWaypoint(From, Event, To, Waypoint)
  local waypoint=Waypoint --Ops.OpsGroup#OPSGROUP.Waypoint
  
  -- Debug info.
  local text=string.format(CVN_beacon_unit:GetName().." passed waypoint ID=%d (Index=%d) %d times", waypoint.uid, BlueCVNGroup:GetWaypointIndex(waypoint.uid), waypoint.npassed)
  MESSAGE:New(text, msgTime):ToBlue()
  USERSOUND:New("ping.ogg"):ToCoalition(coalition.side.BLUE)
  env.info(text)
--- Patrol zone 1  
  if SetCVNActivePatrolZone == 1 and waypoint == 1 then
    BlueCVNGroup:GotoWaypoint(2)
  end
  
  if SetCVNActivePatrolZone == 1 and waypoint == 2 then 
    BlueCVNGroup:GotoWaypoint(1)
  end
---- Patrol zone 2  
  if SetCVNActivePatrolZone == 2 and waypoint == 3 then 
    BlueCVNGroup:GotoWaypoint(4)
  end
  
  if SetCVNActivePatrolZone == 2 and waypoint == 4 then 
    BlueCVNGroup:GotoWaypoint(3)
  end
---- Patrol Zone 3  
  if SetCVNActivePatrolZone == 3 and waypoint == 5 then 
    BlueCVNGroup:GotoWaypoint(6)
  end
  
  if SetCVNActivePatrolZone == 3 and waypoint == 6 then 
    BlueCVNGroup:GotoWaypoint(5)
  end
     
end

--- Function called when the group is cruising. This is the "normal" state when the group follows its waypoints.
function BlueCVNGroup:OnAfterCruise(From, Event, To)
  local text=CVN_beacon_unit:GetName().." is cruising straight and steady."
  MESSAGE:New(text, msgTime):ToBlue()
  USERSOUND:New("ping.ogg"):ToCoalition(coalition.side.BLUE)
  env.info(text)
end

--- Function called when the groups starts to turn.
function BlueCVNGroup:OnAfterTurningStarted(From, Event, To)
  local text=CVN_beacon_unit:GetName().." has started turning!"
  MESSAGE:New(text, msgTime):ToBlue()
  USERSOUND:New("ping.ogg"):ToCoalition(coalition.side.BLUE)
  env.info(text)
end  

--- Function called when the group stopps to turn.
function BlueCVNGroup:OnAfterTurningStopped(From, Event, To)
  local text=CVN_beacon_unit:GetName().." has stopped turning..proceeding to next waypoint."
  MESSAGE:New(text, msgTime):ToBlue()
  USERSOUND:New("ping.ogg"):ToCoalition(coalition.side.BLUE)
  env.info(text)
end

-- Turn the carrier into the wind for a few mins
function 
  BlueCVNGroup:AddTurnIntoWind()
  USERSOUND:New("ping.ogg"):ToCoalition(coalition.side.BLUE)
end 



-- Monitor entering and leaving zones.
local ZoneSet=SET_ZONE:New():FilterPrefixes("CVN Patrol"):FilterOnce()

-- Set zones which are checked if the group enters or leaves it.
BlueCVNGroup:SetCheckZones(ZoneSet)

--- Function called when the group enteres a zone.
function BlueCVNGroup:OnAfterEnterZone(From, Event, To, Zone)
  local text=string.format(CVN_beacon_unit:GetName().." has entered patrol zone %s.", Zone:GetName())
  MESSAGE:New(text, msgTime):ToBlue()
  USERSOUND:New("ping.ogg"):ToCoalition(coalition.side.BLUE)
  env.info(text)    
end

--- Function called when the group leaves a zone.
function BlueCVNGroup:OnAfterLeaveZone(From, Event, To, Zone)
  local text=string.format(CVN_beacon_unit:GetName().." left patrol zone %s.", Zone:GetName())
  MESSAGE:New(text, msgTime):ToBlue()
  USERSOUND:New("ping.ogg"):ToCoalition(coalition.side.BLUE)
  env.info(text)    
end