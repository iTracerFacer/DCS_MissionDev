--Ops - Office of Military Intelligence.
--
--Main Features:
---Detect and track contacts consistently
---Detect and track clusters of contacts consistently
---Once detected and still alive, planes will be tracked 10 minutes, helicopters 20 minutes, ships and trains 1 hour, ground units 2 hours
-- Docs: https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Intel.html

-- Setup Detection Group
local msgTime = 15
Blue_Intel_Message_Setting = false
Red_Intel_Message_Setting = false 

Blue_Intel_DetectionGroup = SET_GROUP:New()
--Blue_Intel_DetectionGroup:FilterPrefixes( { "BLUE EWR", "BLUE RECON" } )
Blue_Intel_DetectionGroup:FilterCoalitions("blue"):FilterActive(true):FilterStart()


-- Setup the INTEL 
Blue_Intel = INTEL:New(Blue_Intel_DetectionGroup, "blue", "CIA")
Blue_Intel:SetClusterAnalysis(true, true)
Blue_Intel:SetClusterRadius(5)
Blue_Intel:SetVerbosity(2)
Blue_Intel:__Start(10)

-- On After New Contact
function Blue_Intel:OnAfterNewContact(From, Event, To, Contact)
 local text = string.format("NEW contact %s detected by %s", Contact.groupname, Contact.recce or "unknown")

  if (Blue_Intel_Message_Setting == true) then
    MESSAGE:New(text, msgTime, "CIA"):ToBlue() 
    USERSOUND:New("morsecode.ogg"):ToCoalition(coalition.side.BLUE)
  end
  
  if Contact.isground == true then
    smokeContact = COORDINATE:NewFromVec2(Contact.position,0)
    smokeContact:SmokeBlue()
  end  
end
-- On After New Cluster
function Blue_Intel:OnAfterNewCluster(From, Event, To, Cluster)
  local text = string.format("NEW cluster #%d of size %d", Cluster.index, Cluster.size)
  
  if (Blue_Intel_Message_Setting == true) then
    MESSAGE:New(text, msgTime,"CIA"):ToBlue()
    USERSOUND:New("morsecode.ogg"):ToCoalition(coalition.side.BLUE)
  end
end

function Blue_IntelMessageSettingOn()
  MESSAGE:New("Setting INTEL messages to ON", msgTime,"CIA"):ToBlue()
  USERSOUND:New("morsecode.ogg"):ToCoalition(coalition.side.BLUE)
  Blue_Intel_Message_Setting = true
end

function Blue_IntelMessageSettingOff()
  MESSAGE:New("Setting INTEL messages to OFF", msgTime,"CIA"):ToBlue()
  USERSOUND:New("morsecode.ogg"):ToCoalition(coalition.side.BLUE)
  Blue_Intel_Message_Setting = false
end

function Blue_A2ADispatcherDisplayOn()
  MESSAGE:New("Setting A2A Tac Display to ON", msgTime,"KGB"):ToBlue()
  USERSOUND:New("morsecode.ogg"):ToCoalition(coalition.side.BLUE)
  BLUEA2ADispatcher:SetTacticalDisplay(true)
end

function Blue_A2ADispatcherDisplayOff()
  MESSAGE:New("Setting A2A Tac Display to OFF", msgTime,"KGB"):ToBlue()
  USERSOUND:New("morsecode.ogg"):ToCoalition(coalition.side.BLUE)
  BLUEA2ADispatcher:SetTacticalDisplay(false)
end
local INTELMenu = MENU_COALITION:New(coalition.side.BLUE,"INTEL HQ")
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Dispaly Messages (ON)",INTELMenu,Blue_IntelMessageSettingOn)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Dispaly Messages (OFF)",INTELMenu,Blue_IntelMessageSettingOff)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "A2A Dispatcher Display (ON)",INTELMenu,Blue_A2ADispatcherDisplayOn)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "A2A Dispatcher Display (OFF)",INTELMenu,Blue_A2ADispatcherDisplayOff)



--Ops - Office of Military Intelligence.
--
--Main Features:
---Detect and track contacts consistently
---Detect and track clusters of contacts consistently
---Once detected and still alive, planes will be tracked 10 minutes, helicopters 20 minutes, ships and trains 1 hour, ground units 2 hours
-- Docs: https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Intel.html

--Set the inital state of the intel messages. Setting to false keeps the module quite but the map markers are still updating.
Red_Intel_Message_Setting = false 

-- Setup Detection Group
Red_Intel_DetectionGroup = SET_GROUP:New():FilterCoalitions("red"):FilterActive(true):FilterStart()
--Red_Intel_DetectionGroup:FilterPrefixes( { "RED EWR", "RED RECON" } )



-- Setup the INTEL 
Red_Intel = INTEL:New(Red_Intel_DetectionGroup, "red", "KGB")
Red_Intel:SetClusterAnalysis(true, true)
Red_Intel:SetClusterRadius(5)
Red_Intel:SetVerbosity(2)
Red_Intel:__Start(10)

-- On After New Contact
function Red_Intel:OnAfterNewContact(From, Event, To, Contact)
 local text = string.format("NEW contact %s detected by %s", Contact.groupname, Contact.recce or "unknown")
  if (Red_Intel_Message_Setting == true) then
    MESSAGE:New(text, msgTime, "KGB"):ToRed() 
    USERSOUND:New("morsecode.ogg"):ToCoalition(coalition.side.RED)
  end
  
  if Contact.isground == true then
    smokeContact = COORDINATE:NewFromVec2(Contact.position,LandHeightAdd)
    smokeContact:SmokeRed()
    
    
  end
  
end
-- On After New Cluster
function Red_Intel:OnAfterNewCluster(From, Event, To, Cluster)
  local text = string.format("NEW cluster #%d of size %d", Cluster.index, Cluster.size)
  if (Red_Intel_Message_Setting == true) then
    MESSAGE:New(text, msgTime,"KGB"):ToRed()
    USERSOUND:New("morsecode.ogg"):ToCoalition(coalition.side.RED)
  end
end

function Red_IntelMessageSettingOn()
  
    MESSAGE:New("Setting INTEL messages to ON.", msgTime,"KGB"):ToRed()
    USERSOUND:New("morsecode.ogg"):ToCoalition(coalition.side.RED)
    Red_Intel_Message_Setting = true
  
end

function Red_IntelMessageSettingOff()
 
    MESSAGE:New("Setting INTEL messages to OFF. Map Markers will continue to update.", msgTime,"KGB"):ToRed()
    USERSOUND:New("morsecode.ogg"):ToCoalition(coalition.side.RED)
    Red_Intel_Message_Setting = false

end

function Red_A2ADispatcherDisplayOn()
  MESSAGE:New("Setting A2A Tac Display to ON", msgTime,"KGB"):ToRed()
  USERSOUND:New("morsecode.ogg"):ToCoalition(coalition.side.RED)
  RedA2ADispatcher:SetTacticalDisplay(true)
end

function Red_A2ADispatcherDisplayOff()
  MESSAGE:New("Setting A2A Tac Display to OFF", msgTime,"KGB"):ToRed()
  USERSOUND:New("morsecode.ogg"):ToCoalition(coalition.side.RED)
  RedA2ADispatcher:SetTacticalDisplay(false)
end


local RedINTELMenu = MENU_COALITION:New(coalition.side.RED,"INTEL HQ")
MENU_COALITION_COMMAND:New(coalition.side.RED, "Dispaly Messages (ON)",RedINTELMenu,Red_IntelMessageSettingOn)
MENU_COALITION_COMMAND:New(coalition.side.RED, "Dispaly Messages (OFF)",RedINTELMenu,Red_IntelMessageSettingOff)
MENU_COALITION_COMMAND:New(coalition.side.RED,"A2A Dispatcher Display (ON)",RedINTELMenu,Red_A2ADispatcherDisplayOn)
MENU_COALITION_COMMAND:New(coalition.side.RED,"A2A Dispatcher Display (OFF)",RedINTELMenu,Red_A2ADispatcherDisplayOff)








