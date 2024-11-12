

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
		"======[ Fighting 99th - Ermenek Liberation ]======" 
		
		local TeamSpeak = 
		"Please join our TeamSpeak server @ teamspeak.f99th.com for improved comms and a better mission experience!"

		local ObjectiveRed = 
		"===============[ MISSION OBJECTIVE ]==============\n" ..
		"CAP - Keep skies over Ermenek clear of NATO aircraft.\n\n"


		local ObjectiveBlue = 
		"===============[ MISSION OBJECTIVE ]==============\n" ..
    "Insurgents have taken over the Ermenek Valley & Lake. Fly to the red smoke points around the lake nears bulls, destroy enemy fortifications, insert ground forces to turn the zone blue. Capture all zones to win the mission.\n\n" ..
		"CAP - Control the airspace above the Ermenek Valley. Protect CAS and HELO aircraft as the attempt to destroy enemy ground positions and retrieve medvacs from the area.\n\n" ..
		"CAS - Destroy Russian AAA and artillery units surrounding Ermenek Lake & surrounding valley.\n\n"
		
		
		local SmokeZones = 
		"=================[ SMOKE ZONES ]================\n" ..
		"RED SMOKE  :  CONTROLLED BY RED.\n" ..
		"BLUE SMOKE :  CONTROLLED BY BLUE OR POSSIBLE MEDEVAC.\n" ..
		"GREEN SMOKE:  CONTROLLED BY NO ONE.\n" ..
		"WHITE SMOKE:  CONTESTED.\n\n"
		
		local EndBrief = "===============[ END MISSION BRIEF ]==============\n\n"

		-- Send appropriate message to each coalition.
		if playerSide == coalition.side.BLUE then --blue team
		
			trigger.action.outTextForGroup(playerID, "" .. MissionName .. "\n\n" .. "Welcome to a F99th DCS Server, " .. playerName .. "!" .. "\n\n"  .. TeamSpeak .. "\n\n" .. ObjectiveBlue .. SmokeZones .. EndBrief, 120)
		end	
		if playerSide == coalition.side.RED then -- red team
			
			trigger.action.outTextForGroup(playerID, "" .. MissionName .. "\n\n" .. "Welcome to a F99th DCS Server, " .. playerName .. "!" .. "\n\n"  .. TeamSpeak .. "\n\n" .. ObjectiveRed .. EndBrief, 120)
		end
		
		-- trigger.action.outSoundForGroup(playerID, "l10n/DEFAULT/battlemusic.ogg")		 -- Damn Cry Babbies
	
	end
end

world.addEventHandler(onEngineStart)