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
  :SpawnScheduled(300, 0.5)

-- Add the event handler to the Red AWACS group
RedAwacsEventHandler:HandleEvent(EVENTS.Birth)
RedAwacsEventHandler:HandleEvent(EVENTS.Dead)
RedAwacsEventHandler:HandleEvent(EVENTS.Hit)

-- Define the event handler class for Blue AWACS
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
  :SpawnScheduled(300, 0.5)

-- Add the event handler to the Blue AWACS group
BlueAwacsEventHandler:HandleEvent(EVENTS.Birth)
BlueAwacsEventHandler:HandleEvent(EVENTS.Dead)
BlueAwacsEventHandler:HandleEvent(EVENTS.Hit)