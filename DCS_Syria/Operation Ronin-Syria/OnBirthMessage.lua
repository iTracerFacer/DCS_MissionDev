onEngineStart = {} 
function onEngineStart:onEvent(event)

	if world.event.S_EVENT_BIRTH == event.id and event.initiator:getPlayerName() ~= nil then 
		local playerGroup = event.initiator:getGroup()
		local playerUnit = playerGroup:getUnit(1)
		local playerName = playerUnit:getPlayerName()
		local playerSide = playerGroup:getCoalition()
		local playerID = playerGroup:getID()
		local playerAircraft = playerUnit:getTypeName()
		MissionStatus(30)
   
		local MissionName = 
		"===[ Operation Ronin over Syria ]===" .. 
		"\nFull PDF Mission Briefing found on F99th.com" 
		
		local TeamSpeak = 
		"Please join our TeamSpeak server @ teamspeak.f99th.com for improved comms and a better mission experience!"

		local ObjectiveRed = 
		"===============[ MISSION OBJECTIVE ]==============\n" ..
		"You primary objective is to maintain control over the air spaces. Shoot down any NATO planes you encounter.\n\n"


		local ObjectiveBlue = 
		"===============[ MISSION OBJECTIVE ]==============\n\n" ..
		"CAP - Escort Attack Aircraft and protect them whlie they destroy the comms towers at each way point in your nav systems.\n\n" ..

		"CAS - Destroy the comms towers located at each waypoint. Exact coordinates for targets are in the breifing (alt-b). This must be a coordinated attack!! You have 30 seconds to kill all 3 targets once one tower is damaged.\n\n" ..
		
		"Failure to destroy targets within the allotted time will result in enemy AA and CAP spawning at that location for the rest of the mission.\n\n" ..
		
		"Destroying all towers in the alloted time gains you that airbase with AA support.\n\n" ..
		
		"Do not loiter over any of the target bases. Once your presence is noticed some AA will engage but not the full complement\n\n" ..
		"This should be a coordinated precision strike. In and out like bam!\n\n" ..
		
		"You have 5 hours to complete the mission once any target is damaged!\n\n" ..
		
		"Teamwork and Coordination are key to completing this mission successfully.\n\n"
		
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
		
		-- trigger.action.outSoundForGroup(playerID, "l10n/DEFAULT/battlemusic.ogg")		 -- Damn Cry Babbies
	
	end

end

world.addEventHandler(onEngineStart)