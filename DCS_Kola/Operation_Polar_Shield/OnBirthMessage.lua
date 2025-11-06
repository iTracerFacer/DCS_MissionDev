-- Immediate test to confirm script is loading
env.info("=== OnBirthMessage.lua LOADING ===")
trigger.action.outText("OnBirthMessage script is loading...", 10)

-- Player preferences storage
local playerWelcomeSettings = {}
local processedPlayers = {} -- Track players to prevent double processing
local DUP_TTL_SECONDS = 10  -- window to ignore duplicate events for the same player

-- F10 Menu Functions
local function enableWelcomeMessage(playerUnitID, playerName)
	env.info("OnBirthMessage: enableWelcomeMessage called for " .. playerName)
	playerWelcomeSettings[playerName] = true
	trigger.action.outTextForUnit(playerUnitID, "✅ Welcome messages ENABLED", 10)
	env.info("OnBirthMessage: Enabled for " .. playerName)
end

local function disableWelcomeMessage(playerUnitID, playerName)
	env.info("OnBirthMessage: disableWelcomeMessage called for " .. playerName)
	playerWelcomeSettings[playerName] = false
	trigger.action.outTextForUnit(playerUnitID, "❌ Welcome messages DISABLED", 10)
	env.info("OnBirthMessage: Disabled for " .. playerName)
end

local function addWelcomeMenuForPlayer(playerUnit, playerName)
	env.info("OnBirthMessage: Adding menu for " .. playerName)
	
	local success, errorMsg = pcall(function()
		local playerGroup = playerUnit:getGroup()
		local playerUnitID = playerUnit:getID()
		local groupID = playerGroup:getID()
		
		env.info("OnBirthMessage: Group ID: " .. groupID .. ", Unit ID: " .. playerUnitID)
		
		-- Remove existing menus to prevent duplicates
		env.info("OnBirthMessage: Cleaning up existing menus")
		missionCommands.removeItemForGroup(groupID, {"Welcome Messages", "Enable Welcome Message"})
		missionCommands.removeItemForGroup(groupID, {"Welcome Messages", "Disable Welcome Message"})
		missionCommands.removeItemForGroup(groupID, {"Welcome Messages", "Test Menu Works"})
		missionCommands.removeItemForGroup(groupID, {"Welcome Messages"})
		
		-- Create main menu
		env.info("OnBirthMessage: Creating new menu")
		missionCommands.addSubMenuForGroup(groupID, "Welcome Messages")
		
		-- Add commands with simpler functions to avoid freezing
		missionCommands.addCommandForGroup(groupID, "Enable Welcome Message", {"Welcome Messages"}, 
			function() 
				playerWelcomeSettings[playerName] = true
				trigger.action.outTextForGroup(groupID, "✅ Welcome messages ENABLED for " .. playerName, 10)
			end)
			
		missionCommands.addCommandForGroup(groupID, "Disable Welcome Message", {"Welcome Messages"}, 
			function() 
				playerWelcomeSettings[playerName] = false
				trigger.action.outTextForGroup(groupID, "❌ Welcome messages DISABLED for " .. playerName, 10)
			end)
			
		-- Add a test command
		missionCommands.addCommandForGroup(groupID, "Test Menu Works", {"Welcome Messages"}, 
			function() 
				trigger.action.outTextForGroup(groupID, "✅ F10 Menu is working for " .. playerName, 10)
			end)
		
		env.info("OnBirthMessage: Menu added successfully for " .. playerName)
	end)
	
	if not success then
		env.info("OnBirthMessage: Menu creation failed: " .. tostring(errorMsg))
	end
end

onPlayerJoin = {}
function onPlayerJoin:onEvent(event)
	-- Only log events we actually process to avoid log spam
	if (event.id == world.event.S_EVENT_BIRTH or event.id == world.event.S_EVENT_ENGINE_STARTUP) then
		env.info("OnBirthMessage: Event triggered - ID: " .. tostring(event.id))
        
		local initiator = event.initiator
		if initiator and initiator.getPlayerName then
			local playerName = initiator:getPlayerName()
			if playerName and playerName ~= '' then
				env.info("OnBirthMessage: Player name found: " .. playerName)
				
				-- Check if we've already processed this player to prevent doubles (within TTL)
				local now = (event.time or timer.getTime())
				local last = processedPlayers[playerName]
				if last and (now - last) < DUP_TTL_SECONDS then
					env.info("OnBirthMessage: Duplicate event for " .. playerName .. " within TTL - skipping")
					return
				end
				processedPlayers[playerName] = now
				
				-- Add error handling to prevent script crashes
				local success, errorMsg = pcall(function()
					local playerGroup = initiator.getGroup and initiator:getGroup()
					if not playerGroup then return end
					local playerUnit = initiator -- the actual player unit that generated the event
					local playerSide = playerGroup:getCoalition()
					local playerID = playerGroup:getID()
					local playerAircraft = playerUnit and playerUnit.getTypeName and playerUnit:getTypeName() or 'Unknown'
					local playerUnitID = playerUnit and playerUnit.getID and playerUnit:getID() or nil
					
					-- Debug message to confirm script is running
					env.info("OnBirthMessage: Player " .. playerName .. " joined in " .. tostring(playerAircraft) .. " (Coalition: " .. tostring(playerSide) .. ")")
					
					-- Send immediate test message
					if playerUnitID then
						trigger.action.outTextForUnit(playerUnitID, "OnBirthMessage: Script detected you joining as " .. playerName, 15)
					end
					
					-- Initialize player preference if not set (default to enabled)
					if playerWelcomeSettings[playerName] == nil then
						playerWelcomeSettings[playerName] = true
					end
					
					-- Add F10 menu for welcome message control (only once per player)
					env.info("OnBirthMessage: About to create menu for " .. playerName)
					addWelcomeMenuForPlayer(playerUnit, playerName)
					
					-- Only show welcome message if player has it enabled
					if not playerWelcomeSettings[playerName] then
						env.info("OnBirthMessage: Skipping welcome message for " .. playerName .. " (disabled by player)")
						return
					end

					-- Prepare welcome message content
			local MissionName = 
			"=====[ Fighting 99th - Operation Polar Shield / Polar Hammer]====" 
			
			local Discord = 
			"Please join our Discord Server @ https://discord.gg/WDZqAzAs for improved comms and a better mission experience!\n" ..
			"You can turn off this message in the F10 menu under 'Welcome Messages'.\n"
	
			local ObjectiveRed = 
			"==============[ OPERATION POLAR SHIELD ]=============\n" ..
			"🛡️ DEFENSIVE MISSION - HOLD THE ARCTIC FRONTIER 🛡️\n\n" ..
			"SITUATION: Russian forces have secured key strategic positions across the Kola Peninsula. Your mission is to maintain this defensive shield against NATO's 'Polar Hammer' offensive operations.\n\n" ..
			"PRIMARY OBJECTIVES:\n" ..
			"🎯 CAP - Maintain air superiority over the RED BORDER zone\n" ..
			"🎯 INTERCEPT - Eliminate all NATO penetrations of Russian airspace\n" ..
			"🎯 DEFEND - Protect airbases: Severomorsk, Murmansk, Olenya, Kilpyavr, Monchegorsk, Afrikanda\n\n" ..
			"⚠️ INTELLIGENCE BRIEFING ⚠️\n" ..
			"• Advanced TADC system provides automated threat response\n" ..
			"• Persistent CAP flights maintain 24/7 border patrol\n" ..
			"• AI squadrons will launch coordinated intercepts\n" ..
			"• EWR network provides early warning coverage\n\n" ..
			"WEATHER: Arctic conditions - limited visibility, icing risk\n" ..
			"TERRAIN: Mountainous, frozen terrain - emergency landing sites scarce\n\n"
	
			local ObjectiveBlue = 
			"==============[ OPERATION POLAR HAMMER ]=============\n" ..
			"⚔️ OFFENSIVE MISSION - BREAK THE RUSSIAN SHIELD ⚔️\n\n" ..
			"SITUATION: Russian forces have established a defensive 'Polar Shield' across the Kola Peninsula. NATO forces must execute 'Polar Hammer' - a coordinated offensive to break Russian air superiority and penetrate their defensive perimeter.\n\n" ..
			"PRIMARY OBJECTIVES:\n" ..
			"🎯 CAP - Establish air superiority within the RED BORDER zone\n" ..
			"🎯 SWEEP - Clear Russian interceptors and defensive CAP flights\n" ..
			"🎯 SEAD - Suppress Russian EWR network and SAM systems\n" ..
			"🎯 STRIKE - Attack Russian airbases and defensive positions\n\n" ..
			"⚠️ INTELLIGENCE BRIEFING ⚠️\n" ..
			"• Enemy operates advanced Tactical Air Defense Controller (TADC)\n" ..
			"• Expect coordinated multi-squadron intercepts\n" ..
			"• Russians maintain persistent CAP along border zones\n" ..
			"• Enemy response times: ~15 seconds from detection\n" ..
			"• Multiple threats will trigger proportional defensive response\n\n" ..
			"WEATHER: Arctic conditions - limited visibility, icing risk\n" ..
			"TERRAIN: Mountainous, frozen terrain - plan fuel carefully\n\n" ..
			"🔥 BREAK THE SHIELD - EXECUTE POLAR HAMMER! 🔥\n\n"
			
			local TacticalInfo = 
			"================[ TACTICAL NOTES ]===============\n" ..
			"RED SMOKE  :  Target areas or supply zones\n" ..
			"BLUE SMOKE :  Friendly pickup/drop zones\n" ..
			"GREEN SMOKE:  Medical evacuation points\n\n" ..
			"COMMS: Use proper brevity codes for air-to-air combat\n" ..
			"FUEL: Monitor fuel carefully in Arctic conditions\n\n"
			
			local EndBrief = "==============[ END MISSION BRIEF ]==============\n\n"

			-- Send appropriate message to each coalition (only to the individual player)
			env.info("OnBirthMessage: Sending welcome message to " .. playerName)
			
			if playerSide == coalition.side.BLUE then --blue team
				trigger.action.outTextForUnit(playerUnitID, "" .. MissionName .. "\n\n" .. "Welcome to the Arctic Theater, " .. playerName .. "!" .. "\n\n"  .. Discord .. "\n\n" .. ObjectiveBlue .. TacticalInfo .. EndBrief, 45)
				env.info("OnBirthMessage: Blue team message sent to " .. playerName)
			elseif playerSide == coalition.side.RED then -- red team
				trigger.action.outTextForUnit(playerUnitID, "" .. MissionName .. "\n\n" .. "Добро пожаловать, " .. playerName .. "!" .. "\n\n"  .. Discord .. "\n\n" .. ObjectiveRed .. TacticalInfo .. EndBrief, 45)
				env.info("OnBirthMessage: Red team message sent to " .. playerName)
			else
				env.info("OnBirthMessage: Unknown coalition for " .. playerName .. " (coalition=" .. playerSide .. ")")
			end
		
			-- trigger.action.outSoundForGroup(playerID, "l10n/DEFAULT/battlemusic.ogg")		 -- Damn Cry Babbies
		end)
		
				if not success then
					env.info("OnBirthMessage Error: " .. tostring(errorMsg))
				end
			else
				-- No player name (AI or non-player object); ignore
			end
		else
			-- No initiator or not a Unit; ignore
		end
	end
end

-- Register event handler
env.info("OnBirthMessage: Registering event handler...")
world.addEventHandler(onPlayerJoin)
env.info("OnBirthMessage: Event handler registered successfully")
env.info("=== OnBirthMessage.lua LOADED SUCCESSFULLY ===")
trigger.action.outText("OnBirthMessage script loaded - check for welcome messages when joining aircraft", 15)