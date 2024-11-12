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
		"======[ Fighting 99th - Battle of Gori ]======" 
		
		local TeamSpeak = 
		"Please join our TeamSpeak server @ teamspeak.f99th.com for improved comms and a better mission experience!"

		local ObjectiveRed = 
		"===============[ MISSION OBJECTIVE ]==============\n" ..
		"CAP - Keep skies over Gori clear of NATO aircraft.\n\n"


		local ObjectiveBlue = 
		"===============[ MISSION OBJECTIVE ]==============\n" ..
		"CAP - Control the airspace above the Gori Valley. Protect CAS and HELO aircraft as the attempt to destroy artillery positions and retrieve medvacs from the city.\n\n" ..
		"CAS - Destroy Russian AAA and artillery units surrounding the City of Gori. Clear a path for helo operations as they attempt to rescue our people. Leave no one behind!\n\n" ..
		"HELO - CAS and AFAC Helos are available. Fly to the town of Gori, land near the blue smoke zones. Use CDLD F10 Menu to pick up MEDVACS. Fly to the green smoke and unload the troops using the same menu.\n\n"
		
		local SmokeZones = 
		"=================[ SMOKE ZONES ]================\n" ..
		"RED SMOKE  :  AFAC Targets for CAS.\n" ..
		"BLUE SMOKE :  PICKUP MEDEVACS FROM THIS LOCATION.\n" ..
		"GREEN SMOKE:  RETURN MEDEVACS TO THIS LOCATION.\n\n" 
		
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