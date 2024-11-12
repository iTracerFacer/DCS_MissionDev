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
		"======[ Fighting 99th - Siege of Ushuaia ]======" 
		
		local TeamSpeak = 
		"Please join our TeamSpeak server @ teamspeak.f99th.com for improved comms and a better mission experience!"

		local ObjectiveRed = 
		"===============[ MISSION OBJECTIVE ]==============\n" ..
		"CAP - Keep skies over Southern Argentina clear.\n\n" ..
		"CAS - Destroy the FARPS and Take over the City of Ushuaia airfields at the waypoints on your map.\n\n"


		local ObjectiveBlue = 
		"===============[ MISSION OBJECTIVE ]==============\n" ..
		"CAP - Control the airspace above the waypoints marked on your map. Coordinate and Protect CAS and HELO aircraft.\n\n" ..
		"CAS - Advance on the waypoints marked on your map. Coordinate with CAS and SEAD to protect the helo squadrons.\n\n" ..
		"Transports - Load Troops and Equipment at the designated supply locations, move them to the waypoints marked on your map to capture and hold each location.\n\n" ..
		"*** WARNING *** \n\nCTLD has limited resources. Deploy wisely!\n\n *** CAPTURING AIRFIELDS REPLENISH SUPPLIES! ***\n\n"
		
		local SmokeZones = 
		"=================[ SMOKE ZONES ]================\n" ..
		"RED SMOKE  :  AFAC Targets for CAS or Supply Zones.\n" ..
		"BLUE SMOKE :  PICKUP OR DROP OFF LOCATION.\n" ..
		"GREEN SMOKE:  RETURN MEDEVACS TO THIS LOCATION.\n\n" 
		
		local EndBrief = "===============[ END MISSION BRIEF ]==============\n\n"

		-- Send appropriate message to each coalition.
		if playerSide == coalition.side.BLUE then --blue team
		
			trigger.action.outTextForGroup(playerID, "" .. MissionName .. "\n\n" .. "Welcome to a F99th DCS Server, " .. playerName .. "!" .. "\n\n"  .. TeamSpeak .. "\n\n" .. ObjectiveBlue .. EndBrief, 30)
		end	
		if playerSide == coalition.side.RED then -- red team
			
			trigger.action.outTextForGroup(playerID, "" .. MissionName .. "\n\n" .. "Welcome to a F99th DCS Server, " .. playerName .. "!" .. "\n\n"  .. TeamSpeak .. "\n\n" .. ObjectiveRed .. EndBrief, 30)
		end
		
		-- trigger.action.outSoundForGroup(playerID, "l10n/DEFAULT/battlemusic.ogg")		 -- Damn Cry Babbies
	end
end
world.addEventHandler(onEngineStart)