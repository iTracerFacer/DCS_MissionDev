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
		"======[ Fighting 99th - Battle of Marianas ]======" 
		
		local TeamSpeak = 
		"Please join our TeamSpeak server @ teamspeak.f99th.com for improved comms and a better mission experience!"

		local ObjectiveRed = 
		"===============[ MISSION OBJECTIVE ]==============\n\n" ..
		"CAP - Keep skies over the Mariana Islands clear of NATO aircraft.\n\n"


		local ObjectiveBlue = 
		"===============[ MISSION OBJECTIVE ]==============\n\n" ..
		"CAP - Control the airspace above the Mariana Islands. Protect CAS and HELO aircraft as they attempt to destroy enemy ground positions and retrieve medvacs from the city.\n\n" ..
		"CAS - Destroy Russian AAA and SAM units around the Marians Islands. Clear a path for helo operations as they attempt to rescue our people. Leave no one behind!\n\n" ..
		"HELO - CAS and AFAC Helos are available. Fly to islands, Search & Destroy the various targets marked on your F10 map. Troop Transport, CSAR, Capture and sling load missions are avail.\n\n" .. 
		"CSAR - Rescues can be returned to the air bases or any of the platforms CLOSEST to the shore.\n\n"
		
		local SmokeZones = 
		"=================[ SMOKE & FLARES ]================\n\n" ..
		"RED SMOKE  :  AFAC Targets for CAS.\n" ..
		"BLUE SMOKE :  PICKUP TROOPS & EQUIPMENT.\n" ..
		"GREEN SMOKE:  DELIVER TROOPS TO CAPTURE.\n" .. 
		"WHITE FLARES at Airfields: Deliver Cargo for capture and extra points.\n\n"
		
		local ScoringDesc =
		"====[ HOW POINTS ARE AWARDED - " .. PointsRequiredToWin .. " REQUIRED TO WIN ]====\n" ..
		"\nPlayer Kill / Death..........: " .. PointsPlayerDeaths ..
		"\nCSAR Complete..............: " .. PointsCSAR ..
		"\nComplete Side Mission...: " .. PointsSideMission ..
		"\nDeliver Cargo.................: " .. PointsDeliverCargo .. "\n\n"
		
--		"===================[ CURRENT SOCRES ]==================\n" ..
--		  "Blue........................: " .. BlueCurrentScore .. 
--		"\nRed.........................: " .. RedCurrentScore .. 
--		"\nBlue Deaths.................: " .. StatBlueCAPDead ..
--    "\nRed Deaths..................: " .. StatRedCAPDead ..
--		"\nBlue Crates Moved...........: " .. StatBlueCratesMoved .. 
--		"\nRed Crates Moved............: " .. StatRedCratesMoved .. 
--		"\nRed CSARs Completed.........: " .. StatRedRescued ..
--		"\nBlue CSARs Completed........: " .. StatRedRescued ..
		 
		 
		
		local EndBrief = "===============[ END MISSION BRIEF ]==============\n\n"

		-- Send appropriate message to each coalition.
		if playerSide == coalition.side.BLUE then --blue team
		
			trigger.action.outTextForGroup(playerID, "" .. MissionName .. "\n\n" .. "Welcome to a F99th DCS Server, " .. playerName .. "!" .. "\n\n"  .. TeamSpeak .. "\n\n" .. ObjectiveBlue .. SmokeZones .. ScoringDesc .. EndBrief, 120)
		end	
		if playerSide == coalition.side.RED then -- red team
			
			trigger.action.outTextForGroup(playerID, "" .. MissionName .. "\n\n" .. "Welcome to a F99th DCS Server, " .. playerName .. "!" .. "\n\n"  .. TeamSpeak .. "\n\n" .. ObjectiveRed .. EndBrief, 120)
		end
		
		-- trigger.action.outSoundForGroup(playerID, "l10n/DEFAULT/battlemusic.ogg")	-- Play a sound everytime a player gets in new AC
		MissionStatus(30) -- Display Scores for this mission. Lua found in Moose_Island_Capture.lua
	
	end
end

world.addEventHandler(onEngineStart)