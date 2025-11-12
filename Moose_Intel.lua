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
Blue_Intel_Sound_Setting = true

Blue_Intel_DetectionGroup = SET_GROUP:New()
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
    if (Blue_Intel_Sound_Setting == true) then
      USERSOUND:New("morsecode.ogg"):ToCoalition(coalition.side.BLUE)
    end
  end
end

-- On After New Cluster
function Blue_Intel:OnAfterNewCluster(From, Event, To, Cluster)
  local text = string.format("NEW cluster #%d of size %d", Cluster.index, Cluster.size)
  
  if (Blue_Intel_Message_Setting == true) then
    MESSAGE:New(text, msgTime,"CIA"):ToBlue()
    if (Blue_Intel_Sound_Setting == true) then
      USERSOUND:New("morsecode.ogg"):ToCoalition(coalition.side.BLUE)
    end
  end
end

function Blue_IntelMessageSettingOn()
  if (Blue_Intel_Message_Setting == true) then
    MESSAGE:New("Setting INTEL messages to ON", msgTime,"CIA"):ToBlue()
    Blue_Intel_Message_Setting = true
  end
end

function Blue_IntelMessageSettingOff()
  if (Blue_Intel_Message_Setting == true) then 
    MESSAGE:New("Setting INTEL messages to OFF", msgTime,"CIA"):ToBlue()
    Blue_Intel_Message_Setting = false
  end
end

function Blue_IntelSoundSettingOff()
  MESSAGE:New("Disabling morse code sound", msgTime, "CIA"):ToBlue()
  Blue_Intel_Sound_Setting = false
end

function Blue_IntelSoundSettingOn()
  MESSAGE:New("Enabling morse code sound", msgTime, "CIA"):ToBlue()
  Blue_Intel_Sound_Setting = true
end

local INTELMenu = MENU_COALITION:New(coalition.side.BLUE,"INTEL HQ", missionMenu)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Display Messages (ON)", INTELMenu, Blue_IntelMessageSettingOn)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Display Messages (OFF)", INTELMenu, Blue_IntelMessageSettingOff)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Disable Morse Code Sound", INTELMenu, Blue_IntelSoundSettingOff)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Enable Morse Code Sound", INTELMenu, Blue_IntelSoundSettingOn)


Red_Intel_Message_Setting = false
Red_Intel_Sound_Setting = true

Red_Intel_DetectionGroup = SET_GROUP:New()
--Red_Intel_DetectionGroup:FilterPrefixes( { "RED EWR", "RED RECON" } )
Red_Intel_DetectionGroup:FilterCoalitions("red"):FilterActive(true):FilterStart()


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
  if (Red_Intel_Message_Setting == true) then
    MESSAGE:New("Setting INTEL messages to ON", msgTime,"KGB"):ToRed()
    USERSOUND:New("morsecode.ogg"):ToCoalition(coalition.side.RED)
    Red_Intel_Message_Setting = true
  end
end

function Red_IntelMessageSettingOff()
  if (Red_Intel_Message_Setting == true) then 
    MESSAGE:New("Setting INTEL messages to OFF", msgTime,"KGB"):ToRed()
    Red_Intel_Message_Setting = false
  end
end

function Red_IntelSoundSettingOff()
  MESSAGE:New("Disabling morse code sound", msgTime, "KGB"):ToRed()
  Red_Intel_Sound_Setting = false
end

function Red_IntelSoundSettingOn()
  MESSAGE:New("Enabling morse code sound", msgTime, "KGB"):ToRed()
  Red_Intel_Sound_Setting = true
end

-- Create the "INTEL HQ" submenu under "Tanker & Other Settings"
local RedINTELMenu = MENU_COALITION:New(coalition.side.RED, "INTEL HQ", missionMenu)

-- Add menu items to the "INTEL HQ" submenu
MENU_COALITION_COMMAND:New(coalition.side.RED, "Display Messages (ON)", RedINTELMenu, Red_IntelMessageSettingOn)
MENU_COALITION_COMMAND:New(coalition.side.RED, "Display Messages (OFF)", RedINTELMenu, Red_IntelMessageSettingOff)
MENU_COALITION_COMMAND:New(coalition.side.RED, "Disable Morse Code Sound", RedINTELMenu, Red_IntelSoundSettingOff)
MENU_COALITION_COMMAND:New(coalition.side.RED, "Enable Morse Code Sound", RedINTELMenu, Red_IntelSoundSettingOn)