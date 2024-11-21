------------------------------------------------------------------------------------------------------------------------------------------------
-- Red AWACS
------------------------------------------------------------------------------------------------------------------------------------------------

-- Define the event handler class for Red AWACS
RedAwacsEventHandler = EVENTHANDLER:New()

-- Handle the Birth event for Red AWACS
function RedAwacsEventHandler:OnEventBirth(EventData)
  if EventData.IniDCSGroupName == "RED EWR AWACS" then
    MESSAGE:New("AWACS has spawned!", 15):ToRed()
    
  end
end

-- Handle the Dead event for Red AWACS
function RedAwacsEventHandler:OnEventDead(EventData)
  if EventData.IniDCSGroupName == "RED EWR AWACS" then
    MESSAGE:New("AWACS has been destroyed!", 15):ToRed()
    
  end
end

-- Handle the Hit event for Red AWACS
function RedAwacsEventHandler:OnEventHit(EventData)
  if EventData.IniDCSGroupName == "RED EWR AWACS" then
    MESSAGE:New("AWACS is under attack!", 15):ToRed()
    
  end
end

-- Create the Red AWACS spawn object
Red_Awacs = SPAWN:New("RED EWR AWACS")
  :InitLimit(1, 99)
  :InitRepeatOnLanding()
  :SpawnScheduled(300, 0.5)

-- Add the event handler to the Red AWACS group
RedAwacsEventHandler:HandleEvent(EVENTS.Birth)
RedAwacsEventHandler:HandleEvent(EVENTS.Dead)
RedAwacsEventHandler:HandleEvent(EVENTS.Hit)

------------------------------------------------------------------------------------------------------------------------------------------------
-- Blue AWACS
------------------------------------------------------------------------------------------------------------------------------------------------

-- Define the event handler class for 
BlueAwacsEventHandler = EVENTHANDLER:New()

-- Handle the Birth event for Blue AWACS
function BlueAwacsEventHandler:OnEventBirth(EventData)
  if EventData.IniDCSGroupName == "BLUE EWR AWACS" then
    MESSAGE:New("AWACS has spawned!", 15):ToBlue()
    
  end
end

-- Handle the Dead event for Blue AWACS
function BlueAwacsEventHandler:OnEventDead(EventData)
  if EventData.IniDCSGroupName == "BLUE EWR AWACS" then
    MESSAGE:New("AWACS has been destroyed!", 15):ToBlue()
    
  end
end

-- Handle the Hit event for Blue AWACS
function BlueAwacsEventHandler:OnEventHit(EventData)
  if EventData.IniDCSGroupName == "BLUE EWR AWACS" then
    MESSAGE:New("AWACS is under attack!", 15):ToBlue()
    
  end
end

-- Create the Blue AWACS spawn object
Blue_Awacs = SPAWN:New("BLUE EWR AWACS")
  :InitLimit(1, 99)
  :InitRepeatOnLanding()
  :SpawnScheduled(300, 0.5)

-- Add the event handler to the Blue AWACS group
BlueAwacsEventHandler:HandleEvent(EVENTS.Birth)
BlueAwacsEventHandler:HandleEvent(EVENTS.Dead)
BlueAwacsEventHandler:HandleEvent(EVENTS.Hit)

-- function to destroy the AWACS if it's alive and then respawn it for the specified coalition.
function ResetAwacs(coalition)
  if coalition == "blue" then
    Blue_Awacs:Destroy()
    Blue_Awacs:Spawn()
  elseif coalition == "red" then
    Red_Awacs:Destroy()
    Red_Awacs:Spawn()
  end
end

RED_MANTIS = MANTIS:New("redmantis", "RED EWR", "RED EWR AWACS", nil, red, false)
RED_MANTIS:Start()
RED_MANTIS:Debug(true)

function mymantis:OnAfterSeadSuppressionPlanned(From, Event, To, Group, Name, SuppressionStartTime, SuppressionEndTime)
  -- your code here - SAM site shutdown and evasion planned, but not yet executed
  -- Time entries relate to timer.getTime() - see https://wiki.hoggitworld.com/view/DCS_func_getTime
  MESSAGE:New("SAM site " .. Group:GetName() .. " is planned to be shut down at " .. SuppressionStartTime .. " and evade at " .. SuppressionEndTime, 15):ToAll()

end

function mymantis:OnAfterSeadSuppressionStart(From, Event, To, Group, Name)
  --Annouce to player that SAM site is down
  MESSAGE:New("SAM site " .. Group:GetName() .. " is evading! Shutting down!", 15):ToAll()

end

function mymantis:OnAfterSeadSuppressionEnd(From, Event, To, Group, Name)
  MESSAGE:New("SAM site " .. Group:GetName() .. " is back online!", 15):ToAll()
end



-- Create a mission menu to reset the awacs for the specified coalition.
MenuCoalitionBlue = MENU_COALITION:New(coalition.side.BLUE, "Reset AWACS", missionMenu)
MenuCoalitionBlueAwacs = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Reset Blue AWACS", MenuCoalitionBlue, ResetAwacs, "blue")

MenuCoalitionRed = MENU_COALITION:New(coalition.side.RED, "Reset AWACS", missionMenu)
MenuCoalitionRedAwacs = MENU_COALITION_COMMAND:New(coalition.side.RED, "Reset Red AWACS", MenuCoalitionRed, ResetAwacs, "red")
