awacs = {}
local awacsPlayerSpawn ={}

function awacs.contains(t, e)
  for i = 1,#t do
    if t[i] == e then return true , i end
  end
  return false
end

awacs.awacsACTypes ={
--"SA342L",
"TF-51D",
"Hawk",
}

awacs.Sight_maxDistance = 129640 -- How far an awacs can "see" in meters (with Line of Sight) Default 70 NM
awacs.trackID = 200000 --Initial track ID number

awacs.setAWACSscanRate = {}
awacs.activeTracks = {}

function awacs.isAWACS(acUnit)
	if acUnit == nil then
		return
	end
		local playerGroup = Unit.getGroup(acUnit)
		local playerGroupName = playerGroup:getName()
		local Aawacsmatch = 0
		
	if string.find(playerGroupName, "AWACS") == nil then
		Aawacsmatch = 0
	else
		Aawacsmatch = 1
	end
	
	if awacs.contains(awacs.awacsACTypes,acUnit:getTypeName()) then 
		Aawacsmatch = 1
	end
	
	return Aawacsmatch
end

world.addEventHandler(awacsPlayerSpawn)
--world.addEventHandler(awacsPlayerDeath)

awacs.CommandAdded = {}
awacs.onStation = {}
awacs.scanRate = 1

function awacsPlayerSpawn:onEvent(e)
	if e.id == world.event.S_EVENT_BIRTH then
		if Unit.getCategory(e.initiator) <3 then 
			local AWACS =  awacs.isAWACS(e.initiator)
			
			local test2 = Unit.getGroup(e.initiator)
			local gid = test2:getID()
			local awacsUnitName = e.initiator:getName()
			--trigger.action.outText(AWACS .. aawacsUnitName,5)
			if AWACS == 1 then
				trigger.action.outTextForGroup(gid,"Your A/C is an AWACS, use to your F10 map to direct CAP flights to targets. Use the F10 menu to go on station ", 15)
				if awacs.contains(awacs.CommandAdded, awacsUnitName) == false then 
					table.insert(awacs.CommandAdded, awacsUnitName)
					trigger.action.outTextForGroup(gid,"Your A/C is an AWACS and loading AWACS Menu", 15)
					local _rootPath = missionCommands.addSubMenuForGroup(gid, "AWACS")
					missionCommands.addCommandForGroup(gid, "Go On-Station",  _rootPath, awacs.setAWACSOnStation, { test2, true})
					missionCommands.addCommandForGroup(gid, "Go Off-Station", _rootPath, awacs.setAWACSOnStation, { test2, false})
					local _mkrpath = missionCommands.addSubMenuForGroup(gid, "Scan Rate",_rootPath)
					missionCommands.addCommandForGroup(gid, "1 scan per 3 sec ",  _mkrpath, awacs.setScanRate, { test2,3})
					missionCommands.addCommandForGroup(gid, "1 scan per 5 sec ",  _mkrpath, awacs.setScanRate, { test2,5})
					missionCommands.addCommandForGroup(gid, "1 scan per 10 sec ", _mkrpath, awacs.setScanRate, {test2,10})
				else 
					trigger.action.outTextForGroup(gid,"AWACS Menu loaded ", 15)
					local test, outIdx = awacs.contains(awacs.onStation,awacsName)
					if test == true then 
						table.remove(awacs.onStation,outIdx)
					end
				end

			end
		end
	end
end




function awacs.setScanRate(_args)
	local _group = _args[1]
	local _scanRate = _args[2]
	local awacsGID = _group:getID()
	trigger.action.outTextForGroup(awacsGID,"Setting scan rate to 1 scan per ".. _scanRate.." second(s)", 15)
	local awacsName = _group:getName()
	awacs.setAWACSscanRate [awacsName] = _scanRate
end 

function awacs.setAWACSOnStation(_args)
	local awacsGroup = _args[1]
	local awacsGID = awacsGroup:getID()
	local onStation = _args[2]
	local awacsSide = awacsGroup:getCoalition()
	local awacsName = awacsGroup:getName()
	local awacsPlayer = _args[1]:getUnit(1):getPlayerName()
	local onCheck, outIdx = awacs.contains(awacs.onStation,awacsName)
	if onStation == true then
		if  onCheck == false then 
			trigger.action.outTextForGroup(awacsGID,"Going On Station", 15)
			if awacsPlayer ~=nil then 
				trigger.action.outTextForCoalition(awacsSide,awacsPlayer .. " Going On Station as AWACS ",10)
			end
			--trigger.action.outTextForGroup(awacsGroup:getID(),"Setting default scanrate to 1 scan per ".. 5 .." second(s)", 15)
			awacs.setScanRate({awacsGroup,5})
			table.insert(awacs.onStation,awacsName)
			awacs.awacsSweep({_args[1],awacsName,_args[1]:getUnit(1):getName()})
		else
			table.remove(awacs.onStation,outIdx)
			trigger.action.outTextForGroup(awacsGID,"Going On Station", 15)
			if awacsPlayer ~=nil then 
				trigger.action.outTextForCoalition(awacsSide,awacsPlayer .. " Going On Station as AWACS ",10)
			end
			awacs.setScanRate({awacsGroup,5})
			table.insert(awacs.onStation,awacsName)
			awacs.awacsSweep({_args[1],awacsName,_args[1]:getUnit(1):getName()})
		end
	else
		--local test, outIdx = awacs.contains(awacs.onStation,awacsName)
		trigger.action.outTextForGroup(awacsGID,"Going Off Station", 15)
		if awacsPlayer ~=nil then 
			trigger.action.outTextForCoalition(awacsSide,_args[1]:getUnit(1):getPlayerName() .. " Going Off Station as AWACS ",10)
		end
		table.remove(awacs.onStation,outIdx)
	end
	-- end
end

function awacs.removeSetMark(_args)
	if  Unit.getByName( _args[2]) ~= nil then
		trigger.action.removeMark(_args[1])
	else
		return 
	end
	return
end

function awacs.getHeading(unit)
	local unitpos = unit:getPosition()
	if unitpos then
		local Heading = math.atan2(unitpos.x.z, unitpos.x.x)
		Heading = Heading + awacs.getNorthCorrection(unitpos.p)
		
		if Heading < 0 then
			Heading = Heading + 2*math.pi  -- put heading in range of 0 to 2*pi
		end
		return Heading
	end
end

awacs.getNorthCorrection = function(point)  --gets the correction needed for true north
	if not point.z then --Vec2; convert to Vec3
		point.z = point.y
		point.y = 0
	end
	local lat, lon = coord.LOtoLL(point)
	local north_posit = coord.LLtoLO(lat + 1, lon)
	return math.atan2(north_posit.z - point.z, north_posit.x - point.x)
end

function awacs.msgDraw(_args)
	local tgtUnit = _args[1]
	local awacsGID = _args[2]:getID()
	--local numMark = world.getMarkPanels()
	local AWACSMarkID = timer.getTime()*1000--curMark
	local _unitPos = tgtUnit:getPoint()
	local _vel = tgtUnit:getVelocity()
	local _spd = 0
	if _vel ~=nil then
		_spd = math.sqrt(_vel.x^2+_vel.z^2)
	end
	--trigger.action.outText("Trying to draw mark" .. AWACSMarkID, 15)
	trigger.action.markToGroup(AWACSMarkID,tgtUnit:getTypeName() .. "\nHeading: ".. math.floor(awacs.getHeading(tgtUnit) * 180/math.pi).."\nSpeed: " .. math.floor(_spd*1.94384)  .. " Knts/".. math.floor(_spd*3.6) .. " KPH" .."\nAltitude: ".. math.floor(_unitPos.y) .."m/" .. math.floor(_unitPos.y*3.28084) .."ft", _unitPos, awacsGID, false,"")
	timer.scheduleFunction(awacs.removeSetMark,{AWACSMarkID,_args[2]:getUnit(1):getName()},timer.getTime() + awacs.setAWACSscanRate [_args[3]]+_spd/120)
	--awacs.trackID = AWACSMarkID +1
	return
end


function awacs.awacsSweep(_args)
	local awacsGroup = _args[1]

	--local onStation = _args[2]
	local awacsName = _args[2]
	--trigger.action.outText( _args[3] .." found",10)
	local checkActive =  Unit.getByName( _args[3])
	if checkActive == nil then
		local test, outIdx = awacs.contains(awacs.onStation,awacsName)
		trigger.action.outText(awacsName .." KIA/MIA", 15)
		--trigger.action.outTextForCoalition(awacsSide,_args[1]:getUnit(1):getPlayerName() .. " Going Off Station/MIA as AWACS ",10)
		table.remove(awacs.onStation,outIdx)
		return
	end
	
	if awacsGroup:getUnit(1)  ~= nil and  checkActive ~= nil then 

		local awacsGID = awacsGroup:getID()
		local awacsSide = awacsGroup:getCoalition()
		local awacsPos = awacsGroup:getUnit(1):getPoint()
		local activeMarks = {}
		local dist = {
			 id = world.VolumeType.SPHERE,
				params = {
				 point = awacsPos,
				 radius = awacs.Sight_maxDistance
				}
		 }
		--trigger.action.outText( awacsGID.." found",10)
		local count = 0
		local awacsMarkTagets = function(foundItem, val) -- generic search for all scenery
			local foundOutput = nil
			local foundObjectPos = nil
			local sideCheck = foundItem:getCoalition()
				if sideCheck ~= awacsSide then
					local _unit = foundItem
					local tgrType = Object.getCategory(_unit)
					local activeCheck = true
					--trigger.action.outText( tgrType.." cat found ".._unit:getTypeName(),10)
					if tgrType == 1 then
						activeCheck = _unit:isActive()
					elseif tgrType == 2 then
						local weaponType = _unit:getDesc()
						--trigger.action.outText( tgrType.." weapon found "..weaponType.RCS,10)
						if weaponType.category ~= 1 then--and weaponType.RCS < 0.1 then
							activeCheck = false
						end
					else
						activeCheck = false
					end
					if _unit:inAir() == true  and activeCheck then  --check for aircraft
						local _unitPos = _unit:getPoint()
						local _offsetEnemyPos = { x = _unitPos.x, y = _unitPos.y + 2.0, z = _unitPos.z }
						local _offsetAWACSPos = { x = awacsPos.x, y = awacsPos.y + 2.0, z = awacsPos.z }
						if  land.isVisible(_offsetEnemyPos, _offsetAWACSPos) then
							--local type = awacs.tgtCatType(foundItem)
							--trigger.action.outText("FOUND STUFF "..count.." ", 15)
							count = count + 1
							--awacs.msgDraw({_unit})
							--local delay = 60
							--if count <= 50 then 
								--awacs.activeTrack[awacsName] = 
								activeMarks[count] =  _unit--timer.scheduleFunction(awacs.msgDraw, {_unit,awacsGID,awacsName},timer.getTime() + count/(delay))
							--end
							--table.insert(awacs.activeTracks[awacsName],_unit)
							--trigger.action.outText("FOUND STUFF "..count.." ", 15)
							--local activeTracks[count] =  _unit
							--local msg = _unit:getTypeName() .. "\nHeading: ".. math.floor(awacs.getHeading(_unit) * 180/math.pi) .. "\nSpeed: " .. math.floor(_spd*2)  .. " MPH" .."\nAltitude: ".. math.floor(_unitPos.y) .."m/" .. math.floor(_unitPos.y*3.28084) .."ft",

							
						end
						--trigger.action.outText( awacs.trackID.." found",10)
					end
				end
				--timer.scheduleFunction(removeSetMark,{AWACSMarkID,true},timer.getTime() + 1)

		end

		world.searchObjects(1,dist,awacsMarkTagets)
		world.searchObjects(2,dist,awacsMarkTagets)
		
		local test = awacs.contains(awacs.onStation,awacsName)

		trigger.action.outTextForGroup(awacsGroup:getID(),"Detecting ".. count .." contact(s)", 15)
		
		if test == true then
			awacs.activeTracks[awacsName] ={}
			local tempMarkID = {}
			for num_track = 1,#activeMarks do
				tempMarkID[num_track] = timer.scheduleFunction(awacs.msgDraw, {activeMarks[num_track],awacsGroup,awacsName,num_track},timer.getTime() + num_track/60)
				table.insert(awacs.activeTracks[awacsName] ,tempMarkID[num_track] )
				--trigger.action.outText("next scan in 1 sec "..#awacs.activeTracks[awacsName] ,10)
			end
			
			timer.scheduleFunction(awacs.awacsSweep, {_args[1], awacsName,_args[3]}, timer.getTime() + awacs.setAWACSscanRate [awacsName] )
			return
		end
	else

		-- for _, _scheduledMark in ipairs(awacs.activeTracks[awacsName]) do
			-- trigger.action.outText("removing Mark ".._scheduledMark ,10)
			-- timer.removeFunction(_scheduledMark)
		-- end
		--awacs.activeTracks[awacsName] = {}
	end
	
	--for num_track = 1,#awacs.activeTracks[awacsName] do
	--	local aTracks = awacs.activeTracks[awacsName] 
	--	timer.scheduleFunction(awacs.msgDraw, {aTracks[num_track]},timer.getTime() + num_track)
	--end
end	