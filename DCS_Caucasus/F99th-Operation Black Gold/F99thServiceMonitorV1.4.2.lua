--Verion 1.4.2

ProviderChecker = {}

-- Best to leave this on for the most part.
ProviderChecker.TankerFuelChecking = true
-- Only necessary to set if you don't set them to invicible
ProviderChecker.TankerKilledTimer = 60
-- Good to set even if you are using Fuel Check, in case it lands for some weird AI reason. 
ProviderChecker.TankerRTBTimer = 60

-- If you want it to respawn when fuel state reaches 20%, instead of having it RTB all the way to base.
ProviderChecker.AWACFuelChecking = true
-- Killed Timer is the time delay to respawn for killed in seconds. Minimum of 5 seconds, anything less will default to 5 seconds
ProviderChecker.AWACKilledTimer = 600
-- RTB Timer is time delay to respawn from landing. Can be 0
ProviderChecker.AWACRTBTimer = 60

ProviderChecker.AWACSeventHandler = {}
ProviderChecker.TankereventHandler = {}

ProviderChecker.TankerTable = {}
ProviderChecker.AwacsTable = {}

ProviderChecker.TankerRefuelingCountBlueFor = 0
ProviderChecker.TankerRefuelingCountRedFor = 0

--Tankers waiting for respawn
ProviderChecker.TankerStandbyTable= {}

function ProviderChecker.TankerRadioStatus(radio_coalition)

	local coalition_side = ""

	if radio_coalition == 1 then 
		coalition_side = coalition_side .. "red"
	elseif radio_coalition == 2 then
		coalition_side = coalition_side .. "blue"
	end

	local tanker_status_start = "===========================\n"
	local tanker_status_end = "==========================="
	local tanker_status_mid = ""

	for fueler, params in pairs(ProviderChecker.TankerTable) do
		if params.coalition == coalition_side then
			if params.has_tasking then
				local m_tanker_id = Group.getByName(params.name)
				local m_tanker_radio = params.radio_freqeuncy
				local m_tanker_units = m_tanker_id:getUnits()
				local m_tanker_unit = m_tanker_units[1]
				local m_tanker_callsign = m_tanker_unit:getCallsign()
				local m_tanker_channel = params.channel
				local m_tanker_mode = params.modeChannel
				local m_tanker_ac_type = m_tanker_unit:getTypeName()

				tanker_status_mid = tanker_status_mid .. "Tanker: " .. m_tanker_callsign .. "     Radio: " .. m_tanker_radio .. 
					"     TACAN: " .. m_tanker_channel .. m_tanker_mode .. "     Aircraft: " .. m_tanker_ac_type .. "\n"
			else
				local m_tanker_id = Group.getByName(params.name)
				local m_tanker_radio = params.radio_freqeuncy
				local m_tanker_units = m_tanker_id:getUnits()
				local m_tanker_unit = m_tanker_units[1]
				local m_tanker_callsign = m_tanker_unit:getCallsign()

				tanker_status_mid = tanker_status_mid .. "Tanker: " .. m_tanker_callsign .. "     Radio: " .. m_tanker_radio .. 
					"     TACAN: N/A" .. "     Aircraft: " .. m_tanker_ac_type ..  "\n"
				
			end
		end
	end

	local out_message = tanker_status_start .. tanker_status_mid .. tanker_status_end
	trigger.action.outTextForCoalition(radio_coalition, out_message, 30, true)
end

function ProviderChecker.RefreshTACAN(_nil,time)
	for fueler, params in pairs(ProviderChecker.TankerTable) do
		if params.has_tasking then
			local tanker_id = Group.getByName(params.name)
			if tanker_id then 
				local tanker_controller = tanker_id:getController()

				local tanker_tacan = { 
					id = 'ActivateBeacon', 
					params = { 
						["type"] = params.type,
						["AA"] = params.AA,
						["unitId"] = tanker_id,
						["modeChannel"] = params.modeChannel,
						["channel"] = params.channel,
						["system"] = params.system,
						["callsign"] = params.callsign,
						["bearing"] = params.bearing,
						["frequency"] = params.frequency,
						} 
				}
				tanker_controller:setCommand(tanker_tacan)
			end
		end
	end
	return time + 10
end

--Will Eventually consoldate these to one function. Pass type (awacs or tanker) as argument. 
function ProviderChecker.SpawnNewTanker(_unit, time)

	--respawn uses the same name, and tankers are tracked by name instead of ID. Will change this for AWACS in future update.
	NewGroup = mist.respawnGroup(_unit,true)
	NewName = NewGroup.units[1].name
	NewUnit = Unit.getByName(NewName)

	tanker_controller = NewUnit:getController()

	for tanker, params in pairs(ProviderChecker.TankerTable) do
		if params.name == NewName then
			local frequency = tonumber(params.radio_freqeuncy) * 1000000

			SetFrequency = { 
		  		id = 'SetFrequency', 
		  		params = { 
		    	frequency = frequency, 
		    	modulation = 0, 
		  		} 
			}

			tanker_controller:setCommand(SetFrequency)
			trigger.action.outTextForCoalition(NewUnit:getCoalition(),"Tanker " ..NewUnit:getCallsign().. " is back online!", 10, false)
		end
	end
	
	return nil
end

function ProviderChecker.SpawnNewAwacs(_unit, time)

	NewGroup = mist.respawnGroup(_unit,true)
	NewName = NewGroup.units[1].name
	NewUnit = Unit.getByName(NewName)

	awacs_controller = NewUnit:getController()

	for awacs, params in pairs(ProviderChecker.AwacsTable) do
		if params.name == NewName then
			local frequency = tonumber(params.radio_freqeuncy) * 1000000

			SetFrequency = { 
		  		id = 'SetFrequency', 
		  		params = { 
		    	frequency = frequency, 
		    	modulation = 0, 
		  		} 
			}

			awacs_controller:setCommand(SetFrequency)
			trigger.action.outTextForCoalition(NewUnit:getCoalition(),"AWACS " .. NewUnit:getCallsign() .. " is back online!", 10, false)
		end
	end

	return nil
end

--due to how scheduled functions work, I need to create a class to handle this. Will upgrade later next revision. 
function ProviderChecker.checkTankerFuel(_nil,time)

	for fueler, params in pairs(ProviderChecker.TankerTable) do
		local fueler_group_name = params.name
		local fueler_group = Group.getByName(fueler_group_name)
		if fueler_group then
			local fueler_units = fueler_group:getUnits()
			local fueler_id = fueler_units[1]
			local fueler_fuel = fueler_id:getFuel()

			if fueler_fuel < 0.20 then
				if params.coalition == "blue" then
					if ProviderChecker.TankerRefuelingCountBlueFor < 1 then
						trigger.action.outTextForCoalition(
							fueler_id:getCoalition(),
							"Tanker " .. fueler_id:getCallsign() .. " Is out of Fuel. Respawning in 5 seconds",
							10
							)

						timer.scheduleFunction(ProviderChecker.SpawnNewTanker, fueler_group_name, timer.getTime() + 5)
					elseif  ProviderChecker.TankerRefuelingCountBlueFor > 0 then
						trigger.action.outTextForCoalition(
							fueler_id:getCoalition(),
							"Tanker " .. fueler_id:getCallsign() .. " fuel at less than 20%. Will respawn when no aircraft are refueling",
							10
							)
					end
				elseif params.coalition == "red" then
					if ProviderChecker.TankerRefuelingCountRedFor < 1 then
						trigger.action.outTextForCoalition(
							fueler_id:getCoalition(),
							"Tanker " .. fueler_id:getCallsign() .. " Is out of Fuel. Respawning in 5 seconds",
							10
							)

						timer.scheduleFunction(ProviderChecker.SpawnNewTanker, fueler_group_name, timer.getTime() + 5)
					elseif  ProviderChecker.TankerRefuelingCountRedFor > 0 then
						trigger.action.outTextForCoalition(
							fueler_id:getCoalition(),
							"Tanker " .. fueler_id:getCallsign() .. " fuel at less than 20%. Will respawn when no aircraft are refueling",
							10
							)
					end
				end
			elseif fueler_fuel < 0.22 then
				trigger.action.outTextForCoalition(
					fueler_id:getCoalition(),
					"Tanker " .. fueler_id:getCallsign() .. " at 25%. Will respawn at 20% if no aircraft are refueling",
					10
					)
			end
		end
	end
	return time + 120
end

function ProviderChecker.checkAWACSFuel(_nil,time)
	--Due to the respawn and scheduledFunction limitations, Checking Refuel requires imediate respawn, else it would loop to respawn again and again. 

	for awacs, params in pairs(ProviderChecker.AwacsTable) do
		local awacs_group_name = params.name
		local awacs_group = Group.getByName(awacs_group_name)
		if awacs_group then
			local awacs_units = awacs_group:getUnits()
			local awacs_id = awacs_units[1]
			local awacs_fuel = awacs_id:getFuel()

			if awacs_fuel < 0.30 then
				if params.coalition == "blue" then
					trigger.action.outTextForCoalition(
						awacs_id:getCoalition(),
						"AWACS " .. awacs_id:getCallsign() .. " Is out of Fuel. Respawning in 5 seconds",
						10
						)

					timer.scheduleFunction(ProviderChecker.SpawnNewAwacs, awacs_group_name, timer.getTime() + 5)

				elseif params.coalition == "red" then
					trigger.action.outTextForCoalition(
						awacs_id:getCoalition(),
						"AWACS " .. awacs_id:getCallsign() .. " Is out of Fuel. Respawning in 5 seconds",
						10
						)

					timer.scheduleFunction(ProviderChecker.SpawnNewAwacs, awacs_group_name, timer.getTime() + 5)
				end
			end
		end
	end
	return time + 120
end

function ProviderChecker.TankereventHandler:onEvent(_event)

	-- Adds up the number of units taking fuel because the event handler is based on unit taking fuel, not giving fuel
	-- Solution to this later will be check nearest unit of type tanker and create a "class" out of that.
	if (_event.id == 7) and _event.initiator then
		local refueling_unit = _event.initiator
		local refueling_unit_coalition = refueling_unit:getCoalition()
		if refueling_unit_coalition == 2 then
			ProviderChecker.TankerRefuelingCountBlueFor = ProviderChecker.TankerRefuelingCountBlueFor + 1
		elseif refueling_unit_coalition == 1 then
			ProviderChecker.TankerRefuelingCountRedFor = ProviderChecker.TankerRefuelingCountRedFor + 1
		end
	end
	-- Removes the number of units taking fuel
	if (_event.id == 14) and _event.initiator then
		local refueling_unit = _event.initiator
		local refueling_unit_coalition = refueling_unit:getCoalition()
		if refueling_unit_coalition == 2 then
			ProviderChecker.TankerRefuelingCountBlueFor = ProviderChecker.TankerRefuelingCountBlueFor - 1
		elseif refueling_unit_coalition == 1 then
			ProviderChecker.TankerRefuelingCountRedFor = ProviderChecker.TankerRefuelingCountRedFor - 1
		end
	end
	-- Checks if tanker landed. 
	if (_event.id == 4) and _event.initiator then
		if _event.initiator then
			local LandedUnit = _event.initiator
			local LandedUnitName = LandedUnit:getName()
			local LandedUnitInfo = Unit.getGroup(LandedUnit)
			local LandedUnitGroupName = LandedUnitInfo:getName()
			for fueler, params in pairs(ProviderChecker.TankerTable) do 
				if LandedUnitGroupName == params.name then
					if ProviderChecker.TankerRTBTimer > 5 then
						trigger.action.outTextForCoalition(
							LandedUnit:getCoalition(),
							"Tanker " .. LandedUnit:getCallsign() .. " Landed - Respawning in " .. (ProviderChecker.TankerRTBTimer / 60) ..  " minutes", 10, false)
						timer.scheduleFunction(ProviderChecker.SpawnNewTanker, LandedUnitGroupName, timer.getTime() + ProviderChecker.TankerRTBTimer)
					else
						trigger.action.outTextForCoalition(
							LandedUnit:getCoalition(),
							"Tanker " .. LandedUnit:getCallsign() .. " Landed - Respawning", 10, false)
						timer.scheduleFunction(ProviderChecker.SpawnNewTanker, LandedUnitGroupName, timer.getTime() + 5)
					end
				end
			end
		end
	end

	if (_event.id == 5) and _event.initiator then
		local DeadUnit = _event.initiator
		local DeadUnitName = DeadUnit:getName()
		local DeadUnitInfo = Unit.getGroup(DeadUnit)
		local DeadUnitGroupName = DeadUnitInfo:getName()
		for fueler, params in pairs(ProviderChecker.TankerTable) do
			if DeadUnitGroupName == params.name then
				if ProviderChecker.TankerKilledTimer > 5 then
					trigger.action.outTextForCoalition(
						DeadUnit:getCoalition(),
						"Tanker " .. DeadUnit:getCallsign() .. " has crashed! Replacement will be on station in " .. (ProviderChecker.TankerKilledTimer / 60) .. " minutes", 10, false)
				timer.scheduleFunction(ProviderChecker.SpawnNewTanker, DeadUnitGroupName, timer.getTime() + ProviderChecker.TankerKilledTimer)
				else
					trigger.action.outTextForCoalition(
						DeadUnit:getCoalition(),
						"Tanker " .. LandedUnit:getCallsign() .. " has crashed! Replacement will be on station in 5 Seconds", 10,false)
					timer.scheduleFunction(ProviderChecker.SpawnNewTanker, DeadUnitGroupName, timer.getTime() + 5)
				end
			end
		end
	end
end

function ProviderChecker.AWACSeventHandler:onEvent(_event)

	-- Checks if tanker landed. 
	if (_event.id == 4) and _event.initiator then
		local LandedUnit = _event.initiator
		local LandedUnitName = LandedUnit:getName()
		local LandedUnitInfo = Unit.getGroup(LandedUnit)
		local LandedUnitGroupName = LandedUnitInfo:getName()
		for awacs, params in pairs(ProviderChecker.AwacsTable) do 
			if LandedUnitGroupName == params.name then
				if ProviderChecker.AWACRTBTimer > 5 then
					trigger.action.outTextForCoalition(
						LandedUnit:getCoalition(),
						"AWACS " .. LandedUnit:getCallsign() .. " Landed - Respawning in " .. (ProviderChecker.AWACRTBTimer / 60) ..  " minutes", 10, false)
					timer.scheduleFunction(ProviderChecker.SpawnNewAwacs, LandedUnitGroupName, timer.getTime() + ProviderChecker.AWACRTBTimer)
				else
					trigger.action.outTextForCoalition(
						LandedUnit:getCoalition(),
						"AWACS " .. LandedUnit:getCallsign() .. " Landed - Respawning", 10, false)
					timer.scheduleFunction(ProviderChecker.SpawnNewAwacs, LandedUnitGroupName, timer.getTime() + 5)
				end
			end
		end
	end

	if (_event.id == 5) and _event.initiator then
		local DeadUnit = _event.initiator
		local DeadUnitName = DeadUnit:getName()
		local DeadUnitInfo = Unit.getGroup(DeadUnit)
		local DeadUnitGroupName = DeadUnitInfo:getName()
		for awacs, params in pairs(ProviderChecker.AwacsTable) do
			if DeadUnitGroupName == params.name then
				if ProviderChecker.AWACKilledTimer > 5 then
					trigger.action.outTextForCoalition(
						DeadUnit:getCoalition(),
						"AWACS " .. DeadUnit:getCallsign() .. " has been shot down! Replacement will be on station in " .. (ProviderChecker.AWACKilledTimer / 60) .. " minutes", 10, false)
				timer.scheduleFunction(ProviderChecker.SpawnNewAwacs, DeadUnitGroupName, timer.getTime() + ProviderChecker.AWACKilledTimer)
				else
					trigger.action.outTextForCoalition(
						DeadUnit:getCoalition(),
						"AWACS " .. DeadUnit:getCallsign() .. " has been shot down! Replacement will be on station in 5 Seconds", 10,false)
					timer.scheduleFunction(ProviderChecker.SpawnNewAwacs, DeadUnitGroupName, timer.getTime() + 5)
				end
			end
		end
	end
end

-- function ProviderChecker.ServiceCheckerMsg()


function ProviderChecker.GetServicesList()

-- You can -only- get TACAN data from the mission file. So since MIST respawn uses the same TACANs on respawn, 
-- I can pull from the mission file and refresh that way
	for coa_name, coa_data in pairs(env.mission.coalition) do
		if (coa_name == 'red' or coa_name == 'blue') and type(coa_data) == 'table' then
			if coa_data.country then --there is a country table
				for cntry_id, cntry_data in pairs(coa_data.country) do
					for obj_type_name, obj_type_data in pairs(cntry_data) do
						if obj_type_name == "plane" then
							if ((type(obj_type_data) == 'table') and obj_type_data.group and (type(obj_type_data.group) == 'table') and (#obj_type_data.group > 0)) then	--there's a group!
								for group_num, group_data in pairs(obj_type_data.group) do
									group_Id = group_data.groupId
									group_radio = group_data.frequency
									group_name = env.getValueDictByKey(group_data.name)
									if group_data.task == "Refueling" then
										if group_data["units"][1]["type"] ~= "IL-78M" then
											if group_data.tasks and group_data.tasks.parmas then
												for tasks_id, tasks_data in pairs(group_data.tasks) do
													if tasks_data.params and tasks_data.params.action and tasks_data.params.action.params then
														tasks_data.params.action.params["coalition"] = coa_name
														tasks_data.params.action.params["radio_freqeuncy"] = group_radio
														tasks_data.params.action.params["name"] = group_name
														tasks_data.params.action.params["has_tasking"] = true
														ProviderChecker.TankerTable[group_Id] = tasks_data.params.action.params
													end --if task_data.params
												end -- for tasks_id, tasks_data
												-- Because for some weird ass reason, the tasks will be blank so I need to pull them from waypoints instead
											elseif group_data.route.points then
												for point_id, point_params in pairs(group_data.route.points) do
													if point_params.task then
														for tasks_id, tasks_data in pairs(point_params.task.params.tasks) do
															if tasks_data.params and tasks_data.params.action and tasks_data.params.action.id == "ActivateBeacon" then
																tasks_data.params.action.params["coalition"] = coa_name
																tasks_data.params.action.params["radio_freqeuncy"] = group_radio
																tasks_data.params.action.params["name"] = group_name
																tasks_data.params.action.params["has_tasking"] = true
																ProviderChecker.TankerTable[group_Id] = tasks_data.params.action.params
															end -- if tasks_data.params and 
														end -- for tasks_id, tasks_data in
													end --if point_params.task
												end -- for point_id, point_params
											end -- if group_data.tasks then
										else
											ProviderChecker.TankerTable[group_Id] = {}
											ProviderChecker.TankerTable[group_Id]["coalition"] = coa_name
											ProviderChecker.TankerTable[group_Id]["radio_freqeuncy"] = group_radio
											ProviderChecker.TankerTable[group_Id]["name"] = group_name 
											ProviderChecker.TankerTable[group_Id]["has_tasking"] = false
										end -- group_data["units"][1]["type"] ~= "IL-78M" then
									elseif group_data.task == "AWACS" then
										ProviderChecker.AwacsTable[group_Id] = {}
										ProviderChecker.AwacsTable[group_Id]["coalition"] = coa_name
										ProviderChecker.AwacsTable[group_Id]["radio_freqeuncy"] = group_radio
										ProviderChecker.AwacsTable[group_Id]["name"] = group_name 
										ProviderChecker.AwacsTable[group_Id]["modeChannel"] = "N/A"
										ProviderChecker.AwacsTable[group_Id]["callsign"] = "N/A" 
									end --if group_data.tas == "Refueling then"
								end --for group_num, group_data in pairs(obj_type_data.group) do
							end --if ((type(obj_type_data) == 'table') and obj_type_data.group and (type(obj_type_data.group) == 'table') and (#obj_type_data.group > 0)) then
						end --if obj_type_name == "helicopter" or obj_type_name == "ship" or obj_type_name == "plane" or obj_type_name == "vehicle" or obj_type_name == "static" then
					end --for obj_type_name, obj_type_data in pairs(cntry_data) do
				end --for cntry_id, cntry_data in pairs(coa_data.country) do
			end --if coa_data.country then --there is a country table
		end --if coa_name == 'red' or coa_name == 'blue' and type(coa_data) == 'table' then
	end --for coa_name, coa_data in pairs(mission.coalition) do
end

world.addEventHandler(ProviderChecker.AWACSeventHandler)
env.info("F99th AWACS Checker event handler added")
world.addEventHandler(ProviderChecker.TankereventHandler)
env.info("F99th Tanker Checker event handler added")

ProviderChecker.GetServicesList()

timer.scheduleFunction(ProviderChecker.RefreshTACAN, nil, timer.getTime() + 10)

missionCommands.addCommandForCoalition(2,"Get Tanker Info",nil, ProviderChecker.TankerRadioStatus,2)
missionCommands.addCommandForCoalition(1,"Get Tanker Info",nil, ProviderChecker.TankerRadioStatus,1)

if ProviderChecker.TankerFuelChecking then
	timer.scheduleFunction(ProviderChecker.checkTankerFuel, nil, timer.getTime() + 120)
end

if ProviderChecker.AWACFuelChecking then
	timer.scheduleFunction(ProviderChecker.checkAWACSFuel, nil, timer.getTime() + 120)
end