onEngineStart = {} 
function onEngineStart:onEvent(event)

  if world.event.S_EVENT_BIRTH == event.id and event.initiator:getPlayerName() ~= nil then 
    local playerGroup = event.initiator:getGroup()
    local playerUnit = playerGroup:getUnit(1)
    local playerName = playerUnit:getPlayerName()
    local playerSide = playerGroup:getCoalition()
    local playerID = playerGroup:getID()
    local playerAircraft = playerUnit:getTypeName()
    
   
    local MissionName = 
    "======[ Fighting 99th - Haifa Siege ]======" 
    
    local TeamSpeak = 
    "Please join our TeamSpeak server @ teamspeak.f99th.com for improved comms and a better mission experience!"

    local ObjectiveRed = 
    "===============[ MISSION OBJECTIVE ]==============\n" ..
    "U.S. intel has discovered our vast network of Command Bunkers located in the caucus mountains. We've hidden them deep in the valleys and small towns.\n\n" .. 
    "Your Primary objective is protecting the skies above our bunkers. Work closely with your teammates and focus on attack and AFAC aircraft.\n\n"


    local ObjectiveBlue = 
    "===============[ MISSION OBJECTIVE ]==============\n" ..
    "CAP - There is heavy enemy fighter presence over the 6 way points in your NAV systems. We need to keep the skies clear of enemy fighters so that CAS aircraft can destroy the Command Buunkers at each location.\n\n" ..
    "CAS - Destroy the Command Bunkers at each of the way points in your NAV systems. Expect random AAA resistance. See the Mission Briefing [ Alt-B ] for image of the Bunker.\n\n" ..
    "HELO - CAS and AFAC Helos are available. Help eliminate AAA units around each WP. There are multiple FARPS to take off from and land at for re-arm/re-pair.\n\n"
    
    -- local SmokeZones = 
    -- "=================[ SMOKE ZONES ]================\n" ..
    -- "RED SMOKE  :  OWNED BY RED FORCES.\n" ..
    -- "GREEN SMOKE:  EMPTY - READY FOR CAPTURE.\n" ..
    -- "BLUE SMOKE :  OWNED BY U.S. FORCES.\n\n" ..
    
    local EndBrief = "===============[ END MISSION BRIEF ]==============\n\n"

    -- Send appropriate message to each coalition.
    if playerSide == coalition.side.BLUE then --blue team
    
      trigger.action.outTextForGroup(playerID, "" .. MissionName .. "\n\n" .. "Welcome to a F99th DCS Server, " .. playerName .. "!" .. "\n\n"  .. TeamSpeak .. "\n\n" .. ObjectiveBlue .. EndBrief, 120)
    end 
    if playerSide == coalition.side.RED then -- red team
      
      trigger.action.outTextForGroup(playerID, "" .. MissionName .. "\n\n" .. "Welcome to a F99th DCS Server, " .. playerName .. "!" .. "\n\n"  .. TeamSpeak .. "\n\n" .. ObjectiveRed .. EndBrief, 120)
    end
    
    -- trigger.action.outSoundForGroup(playerID, "l10n/DEFAULT/battlemusic.ogg")     -- Damn Cry Babbies
  
  end
end

world.addEventHandler(onEngineStart)