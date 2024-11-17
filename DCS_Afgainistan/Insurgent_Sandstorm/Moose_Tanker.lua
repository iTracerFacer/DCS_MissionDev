-- Define the event handler class for Blue TANKER
BlueTankerEventHandler = EVENTHANDLER:New()

-- Handle the Birth event for Blue TANKER
function BlueTankerEventHandler:OnEventBirth(EventData)
  if EventData.IniDCSGroupName == "TANKER 135" then
    MESSAGE:New("TANKER has spawned!", 15):ToBlue()
  elseif EventData.IniDCSGroupName == "TANKER 135 MPRS" then
    MESSAGE:New("TANKER 135 MPRS has spawned!", 15):ToBlue()
  end
end

-- Handle the Dead event for Blue TANKER
function BlueTankerEventHandler:OnEventDead(EventData)
  if EventData.IniDCSGroupName == "TANKER 135" then
    MESSAGE:New("TANKER has been destroyed!", 15):ToBlue()
  elseif EventData.IniDCSGroupName == "TANKER 135 MPRS" then
    MESSAGE:New("TANKER 135 MPRS has been destroyed!", 15):ToBlue()
  end
end

-- Handle the Hit event for Blue TANKER
function BlueTankerEventHandler:OnEventHit(EventData)
  if EventData.IniDCSGroupName == "TANKER 135" then
    MESSAGE:New("TANKER is under attack!", 15):ToBlue()
  elseif EventData.IniDCSGroupName == "TANKER 135 MPRS" then
    MESSAGE:New("TANKER 135 MPRS is under attack!", 15):ToBlue()
  end
end

-- Create the Blue TANKER spawn objects
Blue_Tanker = SPAWN:New("TANKER 135")
  :InitLimit(1, 99)

Blue_Tanker_MPRS = SPAWN:New("TANKER 135 MPRS")
  :InitLimit(1, 99)

-- Function to spawn the tankers
function SpawnTanker()
  Blue_Tanker:Spawn()
end

function SpawnTankerMPRS()
  Blue_Tanker_MPRS:Spawn()
end

-- Create a mission menu for requesting the tankers
MenuCoalitionBlue = MENU_COALITION:New(coalition.side.BLUE, "Request TANKER", missionMenu)
MenuCoalitionBlueTanker = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Launch TANKER 135", MenuCoalitionBlue, SpawnTanker)
MenuCoalitionBlueTankerMPRS = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Launch TANKER 135 MPRS", MenuCoalitionBlue, SpawnTankerMPRS)

-- Add the event handler to the Blue TANKER group
BlueTankerEventHandler:HandleEvent(EVENTS.Birth)
BlueTankerEventHandler:HandleEvent(EVENTS.Dead)
BlueTankerEventHandler:HandleEvent(EVENTS.Hit)