--[[
DCS FAC v2.1.25
-------

Authors: Pb_Magnet (github.com/jweisner), modified by Shadow

NOTE: Almost all of the hard stuff here is copied/adapted from CTLD: https://github.com/ciribob/DCS-CTLD
      This script was originally submitted as a PR to include in CTLD, but there didn't seem to be any interest from CTLD vOv
	  New features:
	  Required Scripts for this scrip to function:
		Mist
		markManager
	  Reworked Artillery control via F10
	  Auto Map Marking
	  RECCE Units --> Cant Lase but will mark all units in an area
	  Manual Targeting mode
	  Offset Mortar aimpoint to compensate for rounds falling short
	  Added arty fire type choice
	  Added AI Artillery Spotters
	  Added Air Ops Menu for TALD and Carpet Bomb Map Attack
	  Integrated Naval Fire Support
	  Added AI RECCE support
	  Readded MLRS support
	  ]]



local facPlayerSpawn ={}
fac = {} -- do not modify this line
local CrptBmbDesig = {}
local RECCEDesig = {}

function contains(t, e)
  for i = 1,#t do
    if t[i] == e then return true end
  end
  return false
end

function removebyKey(tab, val)
    for i, v in ipairs (tab) do 
        if (v.id == val) then
          tab[i] = nil
        end
    end
end

fac.facACTypes ={
"SA342L",
"UH-1H",
"Mi-8MTV2",
--"TF-51",
--"Hawk",
}

fac.artyDirectorTypes = { 
"Soldier M249",
--"Paratrooper AKS-74",
--"Soldier M4",
}
-- ***************** FAC CONFIGURATION *****************

fac.FAC_maxDistance = 18520 -- How far a FAC can "see" in meters (with Line of Sight)
fac.AutoOn = true -- when enabled turns auto on station for AFAC 
fac.FAC_smokeOn_RED  = true -- enables marking of target with smoke for RED forces
fac.FAC_smokeOn_BLUE = true -- enables marking of target with smoke for BLUE forces

fac.FAC_smokeColour_RED  = 0 -- RED  side smoke colour -- Green = 0 , Red = 1, White = 2, Orange = 3, Blue = 4 (if using flares limit to green and orange)
fac.FAC_smokeColour_BLUE = 3 -- BLUE side smoke colour -- Green = 0 , Red = 1, White = 2, Orange = 3, Blue = 4 (if using flares limit to green and orange)

fac.FAC_FACStatusF10 = true -- enables F10 FAC Status menu

fac.FAC_location = true -- shows location of target in FAC message

fac.FAC_lock = "all" -- "vehicle" OR "troop" OR "all" forces FAC to only lock vehicles or troops or all ground units

fac.FAC_laser_codes = { '1688', '1677', '1666', '1113','1115' ,'1111'}

fac.fireMissionRounds = 24 -- number of shells per fire mission request

fac.illumHeight = 500 --height for illumination bomb

fac.facOffsetDist = 5000

fac.markID = 1000 --intial MarkerID

fac.recceID = 50000 --Initial recce ID number

-- ******************** FAC names **********************
function fac.isAFAC(acUnit)
		local playerGroup = Unit.getGroup(acUnit)
		local playerGroupName = playerGroup:getName()
		local AFACmatch = 0
		
	if (string.find(playerGroupName, "AFAC") == nil) and (string.find(playerGroupName, "RECON") == nil)  then
		AFACmatch = 0
	else
		AFACmatch = 1
	end
	
	if contains(fac.facACTypes,acUnit:getTypeName()) then 
		AFACmatch = 1
	end
	
	return AFACmatch
end

function fac.isRECCE(acUnit)
		local playerGroup = Unit.getGroup(acUnit)
		local playerGroupName = playerGroup:getName()
		local RECCEmatch = 0
		--trigger.action.outText(acUnit:getTypeName(),5)
	if (string.find(playerGroupName, "RECCE") == nil) and (string.find(playerGroupName, "RECON") == nil) then
		RECCEmatch = 0
	
	else
		RECCEmatch = 1
	end
	
	if contains(fac.facACTypes,acUnit:getTypeName()) then
		RECCEmatch = 1
	end
	
	return RECCEmatch
end

function fac.isArtyD(acUnit)
	local adMatch = 0 
	local playerGroup = Unit.getGroup(acUnit)
	if playerGroup then
		local playerGroupName = playerGroup:getName()
		if playerGroupName then
			if contains(fac.artyDirectorTypes,acUnit:getTypeName()) then
				adMatch = 1
			end
		end
	end
	return adMatch
end

-- Use any of the predefined names or set your own ones
fac.facPilotNames =  {
	"Chevy 6-1",
	"Chevy 6-2",
	"Chevy 6-3",
	"Chevy 6-4",
	"Chevy 5-1",
	"Chevy 5-2",
	"Chevy 5-3",
	"Chevy 5-4",
	"Chevy 4-1",
	"Chevy 4-2",
	"Chevy 4-3",
	"Chevy 4-4",
	"Chevy 2-1",
	"Chevy 2-2",
	"Chevy 2-3",
	"Chevy 2-4",
	"Chevy 1-1",
	"Chevy 1-2",
	"Chevy 1-3",
	"Chevy 1-4",
	"837",
	"838",
	"839",
	"840",
	"841",
	"842",
	"843",
	"844",
    -- "Red AFAC #001",
	-- "Red AFAC #002",
	-- "Red AFAC #003",
	-- "Red AFAC #004",
	-- "Red AFAC #005",
	-- "Red AFAC #006",
	-- "Red AFAC #007",
	-- "Red AFAC #008",
	-- "Red AFAC #009",
	-- "Red AFAC #010",
	
	-- "Blue AFAC #001",
	-- "Blue AFAC #002",
	-- "Blue AFAC #003",
	-- "Blue AFAC #004",
	-- "Blue AFAC #005",
	-- "Blue AFAC #006",
	-- "Blue AFAC #007",
	-- "Blue AFAC #008",
	-- "Blue AFAC #009",
	-- "Blue AFAC #010",
	
	-- "helicargo4",
	-- "helicargo8",
	-- "FAC #001",
    -- "FAC #002",
    -- "FAC #003",
    -- "FAC #004",
    -- "FAC #005",
    -- "FAC #006",
    -- "FAC #007",
    -- "FAC #008",
	
	-- "RED Mobile FOB TRANSPORT #001",
	-- "RED Mobile FOB TRANSPORT #002",
	
	-- "BLUE Mobile FOB TRANSPORT #001",
	-- "BLUE Mobile FOB TRANSPORT #002",

}

--Define RECCE pilots 
fac.reccePilotNames =  {
--Enter RECCE pilot names here, 
	"RECCE1",
	"RECCE2",
}

fac.artDirectNames = {
	"RECCE1",
	"RECCE2",
	"RECCE3",
	"RECCE4",
}

--init FAC
-- Auto Detects Group names and adds unit to FAC and RECCE list
function facPlayerSpawn:onEvent(e)
	if e.id == world.event.S_EVENT_BIRTH then
		local objType = e.initiator:getDesc()
		if Object.getCategory(e.initiator) == 1 then
			if objType.category  < 2 then
				local AFAC = fac.isAFAC(e.initiator)
				local RECCE = fac.isRECCE(e.initiator)
				local test2 = Unit.getGroup(e.initiator)
				local gid = test2:getID()
				local afacUnitName = e.initiator:getName()
				local checkAFACName, afacIdx = contains(fac.facPilotNames,afacUnitName)
				local checkRECCEName, afacIdx = contains(fac.reccePilotNames,afacUnitName)
				--trigger.action.outText(RECCE .. afacUnitName,5)
				if AFAC == 1 then
					if contains(fac.facPilotNames,afacUnitName) == false then 
						table.insert(fac.facPilotNames, afacUnitName)
						trigger.action.outTextForGroup(gid,"Your A/C is an AFAC and added to AFAC List \nUse your F10 menu to spot targets for your team and call in artillery strikes", 15)
					else 
						trigger.action.outTextForGroup(gid,"Your A/C is an AFAC \nUse your F10 menu to spot targets for your team and call in artillery strikes", 15)
					end
					if fac.AutoOn == true then 
						fac.setFacOnStation({afacUnitName,true})
					end
					--trigger.action.outTextForGroup(gid,"Your A/C is an AFAC "..afacUnitName.." "..#fac.facPilotNames, 15)
				--trigger.action.outText(rampcheck,5)
				elseif checkAFACName == true then 
					trigger.action.outTextForGroup(gid,"Your A/C is an AFAC \nUse your F10 menu to spot targets for your team and call in artillery strikes", 15)
				end
				if RECCE == 1 then
					if  contains(fac.reccePilotNames,afacUnitName) == false then
						table.insert(fac.reccePilotNames, afacUnitName)
						trigger.action.outTextForGroup(gid,"Your A/C is an RECCE and added to RECCE List \nUse your F10 menu to spot all targets in an area for your team and mark them on the F10 map", 15)
					else 
						trigger.action.outTextForGroup(gid,"Your A/C is an Recon A/C \nUse your F10 menu to spot all targets in an area for your team and mark them on the F10 map", 15)
					end
				elseif checkRECCEName == true then 
					trigger.action.outTextForGroup(gid,"Your A/C is an RECCE \nUse your F10 menu to spot all targets in an area for your team and mark them on the F10 map", 15)
				end
			elseif  objType.category == 2 then 
				local artDirect = fac.isArtyD(e.initiator)
				local afacUnitName = e.initiator:getName()
				local test2 = Unit.getGroup(e.initiator)
				local gid = test2:getCoalition()
				if artDirect == 1 then 
					if  contains(fac.artDirectNames,afacUnitName) == false then
						table.insert(fac.artDirectNames, afacUnitName)
						--trigger.action.outText("Artillery Spotter has been deployed" .. e.initiator:getTypeName() , 15)
					end
				end
			end
		end
	end
end

world.addEventHandler(facPlayerSpawn)
--Arty properties from Mbot's AES script 

	fac.ArtilleryProperties = {
		["2B11 mortar"] = {
			minrange = 500,														--Minimal firing range
			maxrange = 7000,													--Maximal firing range
			FM_rounds = 24,														--The total amount of shots of a fire mission for a battery of this unit type
			minAmmo = 0,														--The amount of rounds left in a individual unit when switching from rapid fire to sustained fire
			displacementTime = 0												--Time the battery waits between firing and moving
		},
		["SAU 2-C9"] = {
			minrange = 500,														--Minimal firing range
			maxrange = 7000,													--Maximal firing range
			FM_rounds = 24,														--The total amount of shots of a fire mission for a battery of this unit type
			minAmmo = 0,														--The amount of rounds left in a individual unit when switching from rapid fire to sustained fire
			displacementTime = 10												--Time the battery waits between firing and moving
		},
		["M-109"] = {
			minrange = 300,														--Minimal firing range
			maxrange = 22000,													--Maximal firing range
			FM_rounds = 24,														--The total amount of shots of a fire mission for a battery of this unit type
			minAmmo = 160,														--The amount of rounds left in a individual unit when switching from rapid fire to sustained fire
			displacementTime = 10												--Time the battery waits between firing and moving
		},
		["SAU Gvozdika"] = {
			minrange = 300,														--Minimal firing range
			maxrange = 15000,													--Maximal firing range
			FM_rounds = 24,														--The total amount of shots of a fire mission for a battery of this unit type
			minAmmo = 0,														--The amount of rounds left in a individual unit when switching from rapid fire to sustained fire
			displacementTime = 10												--Time the battery waits between firing and moving
		},
		["SAU Akatsia"] = {
			minrange = 300,														--Minimal firing range
			maxrange = 17000,													--Maximal firing range
			FM_rounds = 24,														--The total amount of shots of a fire mission for a battery of this unit type
			minAmmo = 0,														--The amount of rounds left in a individual unit when switching from rapid fire to sustained fire
			displacementTime = 10												--Time the battery waits between firing and moving
		},
		["SAU Msta"] = {
			minrange = 300,														--Minimal firing range
			maxrange = 23500,													--Maximal firing range
			FM_rounds = 24,														--The total amount of shots of a fire mission for a battery of this unit type
			minAmmo = 300,														--The amount of rounds left in a individual unit when switching from rapid fire to sustained fire
			displacementTime = 10												--Time the battery waits between firing and moving
		},
		["MLRS"] = {
			minrange = 10000,													--Minimal firing range
			maxrange = 32000,													--Maximal firing range
			FM_rounds = 12,														--The total amount of shots of a fire mission for a battery of this unit type
			minAmmo = 12,														--The amount of rounds left in a individual unit when switching from rapid fire to sustained fire
			displacementTime = 10												--Time the battery waits between firing and moving
		},
		["Grad-URAL"] = {
			minrange = 5000,													--Minimal firing range
			maxrange = 19000,													--Maximal firing range
			FM_rounds = 120,													--The total amount of shots of a fire mission for a battery of this unit type
			minAmmo = 40,														--The amount of rounds left in a individual unit when switching from rapid fire to sustained fire
			displacementTime = 120												--Time the battery waits between firing and moving
		},
		["Smerch"] = {
			minrange = 20000,													--Minimal firing range
			maxrange = 70000,													--Maximal firing range
			FM_rounds = 24,														--The total amount of shots of a fire mission for a battery of this unit type
			minAmmo = 12,														--The amount of rounds left in a individual unit when switching from rapid fire to sustained fire
			displacementTime = 120												--Time the battery waits between firing and moving
		},
		["Uragan_BM-27"] = {
			minrange = 11500,													--Minimal firing range
			maxrange = 35800,													--Maximal firing range
			FM_rounds = 16,														--The total amount of shots of a fire mission for a battery of this unit type
			minAmmo = 12,														--The amount of rounds left in a individual unit when switching from rapid fire to sustained fire
			displacementTime = 120												--Time the battery waits between firing and moving
		},
		["SpGH_Dana"] = {
			minrange = 300,													--Minimal firing range
			maxrange = 18700,													--Maximal firing range
			FM_rounds = 16,														--The total amount of shots of a fire mission for a battery of this unit type
			minAmmo = 12,														--The amount of rounds left in a individual unit when switching from rapid fire to sustained fire
			displacementTime = 120												--Time the battery waits between firing and moving
		},
		["Smerch_HE"] = {
			minrange = 20000,													--Minimal firing range
			maxrange = 70000,													--Maximal firing range
			FM_rounds = 16,														--The total amount of shots of a fire mission for a battery of this unit type
			minAmmo = 12,														--The amount of rounds left in a individual unit when switching from rapid fire to sustained fire
			displacementTime = 120												--Time the battery waits between firing and moving
		},
		["T155_Firtina"] = {
			minrange = 300,													--Minimal firing range
			maxrange = 41000,													--Maximal firing range
			FM_rounds = 16,														--The total amount of shots of a fire mission for a battery of this unit type
			minAmmo = 12,														--The amount of rounds left in a individual unit when switching from rapid fire to sustained fire
			displacementTime = 120												--Time the battery waits between firing and moving
		},
		["PLZ05"] = {
			minrange = 300,													--Minimal firing range
			maxrange = 23500,													--Maximal firing range
			FM_rounds = 16,														--The total amount of shots of a fire mission for a battery of this unit type
			minAmmo = 12,														--The amount of rounds left in a individual unit when switching from rapid fire to sustained fire
			displacementTime = 120												--Time the battery waits between firing and moving
		},
		
		-- ["hy_launcher"] = { -- doesn't work do not use
			-- minrange = 3000,													--Minimal firing range 
			-- maxrange = 40000,													--Maximal firing range
			-- FM_rounds = 16,														--The total amount of shots of a fire mission for a battery of this unit type
			-- minAmmo = 12,														--The amount of rounds left in a individual unit when switching from rapid fire to sustained fire
			-- displacementTime = 120												--Time the battery waits between firing and moving
		-- },
		-- ["TomahawkLauncher"] = {
			-- minrange = 18520,													--Minimal firing range
			-- maxrange = 460000,													--Maximal firing range
			-- FM_rounds = 16,														--The total amount of shots of a fire mission for a battery of this unit type
			-- minAmmo = 12,														--The amount of rounds left in a individual unit when switching from rapid fire to sustained fire
			-- displacementTime = 120												--Time the battery waits between firing and moving
		-- }
	}
------------ FAC -----------

fac.facManTGT = {}
fac.facLaserPoints = {}
fac.facIRPoints = {}
fac.facSmokeMarks = {}
fac.facUnits = {} -- list of FAC units for f10 command
fac.facCurrentTargets = {}
fac.facAddedTo = {} -- keeps track of who's had the fac command menu added
fac.RECCEAddedTo = {} -- keeps track of who's had the RECCE command menu added
fac.facRadioAdded = {} -- keeps track of who's had the radio command added
fac.facLaserPointCodes = {} -- keeps track of what laser code is used by each fac
fac.facOnStation = {} -- keeps track of which facs are on station
fac.markerType = {} -- keeps track of marker type per FAC
fac.markerTypeColor = {} -- keeps track of marker color per FAC
fac.redArty = {} -- keeps track of available arty for Red
fac.bluArty = {} --keeps track of available arty for Blue
fac.ArtyTasked = {} --keeps track of Arty with current fire missions
fac.RECCETasked = {}
fac.AITgted = {}

-- search for activated FAC units and schedule facAutoLase
function fac.checkFacStatus()
    --env.info("FAC checkFacStatus")
    timer.scheduleFunction(fac.checkFacStatus, nil, timer.getTime() + 1.0)

    local _status, _result = pcall(function()

        for _, _facUnitName in ipairs(fac.facPilotNames) do

            local _facUnit = fac.getFacUnit(_facUnitName)

            if _facUnit ~= nil then

                --[[
                if fac.facOnStation[_facUnitName] == true then
                    env.info("FAC DEBUG: fac.checkFacStatus() " .. _facUnitName .. " on-station")
                end

                if fac.facOnStation[_facUnitName] == nil then
                    env.info("FAC DEBUG: fac.checkFacStatus() " .. _facUnitName .. " off-station")
                end
                ]]

                -- if fac is off-station and is AI, set onStation
                if fac.facUnits[_facUnitName] == nil and _facUnit:getPlayerName() == nil then
                    --env.info("FAC: setting onStation for AI fac unit " .. _facUnitName)
                    fac.setFacOnStation({_facUnitName, true})
                end

                -- start facAutoLase if the FAC is on station and not already scheduled
                if fac.facUnits[_facUnitName] == nil and fac.facOnStation[_facUnitName] == true then
                    env.info("FAC: found new FAC unit. Starting facAutoLase for " .. _facUnitName)
                    fac.facAutoLase(_facUnitName) --(_facUnitName, _laserCode, _smoke, _lock, _colour)
                end
            end
        end
    end)

    if (not _status) then
        env.error(string.format("FAC ERROR: %s", _result))
    end
end

-- gets the FAC status and displays to coalition units
function fac.getFacStatus(_args)

    --returns the status of all FAC units

    local _playerUnit = fac.getFacUnit(_args[1])
	
	local colorString = {["0"] = "GREEN" ,["1"] = "RED" ,["2"] = "WHITE", ["3"] = "ORANGE" , ["4"] = "BLUE"}
    if _playerUnit == nil then
        return
    end
    local _side = _playerUnit:getCoalition()
	local _mkrColor
	
	if _side == 1 then
		_mkrColor = fac.FAC_smokeColour_BLUE
	elseif _side == 2 then
		_mkrColor = fac.FAC_smokeColour_RED
	else
		_mkrColor = 2
	end
    
	local _facUnit = nil

    local _message = "FAC STATUS: \n\n"

    for _facUnitName, _facDetails in pairs(fac.facUnits) do

        --look up units
        _facUnit = Unit.getByName(_facDetails.name)

        if _facUnit ~= nil and _facUnit:getLife() > 0 and _facUnit:isActive() == true and _facUnit:getCoalition() == _side and fac.facOnStation[_facUnitName] == true then

            local _enemyUnit = fac.getCurrentFacUnit(_facUnit, _facUnitName)

            local _laserCode = fac.facLaserPointCodes[_facUnitName]


            -- get player name if available
            local _facName = _facUnitName
            if _facUnit:getPlayerName() ~= nil then
                _facName = _facUnit:getPlayerName()
            end
			
			if fac.markerTypeColor[_facName] ~= nil then 
				_mkrColor = fac.markerTypeColor[_facName]
			end
            if _laserCode == nil then
                _laserCode = "UNKNOWN"
            end
			if fac.markerType[_facUnitName]  == nil then 
				fac.markerType[_facUnitName] = "FLARES"
			end
            if _enemyUnit ~= nil and _enemyUnit:getLife() > 0 and _enemyUnit:isActive() == true then
                _message = _message .. "" .. _facName .. " targeting " .. _enemyUnit:getTypeName() .. " CODE: " .. _laserCode .. fac.getFacPositionString(_enemyUnit) .. "\nMarked with " .. colorString[tostring(_mkrColor)] .." ".. fac.markerType[_facUnitName].. "\n"
            else
                _message = _message .. "" .. _facName .. " on-station and searching for targets" .. " CODE: " .. _laserCode .. "\n"
            end
        end
    end

    if _message == "FAC STATUS: \n\n" then
        _message = "No Active FACs, Join a slot labeled RECON or AFAC to play as a flying JTAC and Artillery Spotter"
    end

    fac.notifyCoalition(_message, 60, _side)
end

function fac.getFacPositionString(_unit)

    if fac.FAC_location == false then
        return ""
    end

    local _lat, _lon = coord.LOtoLL(_unit:getPosition().p)
	local unitPos = _unit:getPoint()
	-- local _latDeg,_latMinf = math.modf(_lat)
	-- local _longDeg,_longMinf = math.modf(_lat)
	-- local _latMin, _latSecf = math.modf(_latMinf*60)
	-- local _longMin, _longSecf = math.modf(_longMinf*60)
	-- local _latSec = _latSecf*605
	-- local _longSec = _longSecf*60
    local _latLngStr = mist.tostringLL(_lat, _lon, 3, false)
	local _latLngSecStr = mist.tostringLL(_lat, _lon, 3, true)
    local _mgrsString = mist.tostringMGRS(coord.LLtoMGRS(coord.LOtoLL(_unit:getPosition().p)), 5)

    return " @\n- DD " .. _latLngStr .." \n- DMS: " .. _latLngSecStr  .. " \n- MGRS: " .. _mgrsString .."\nAltitude: ".. math.floor(unitPos.y) .."m/" .. math.floor(unitPos.y*3.28084) .."ft"
end

-- get currently selected unit and check if the FAC is still in range
function fac.getCurrentFacUnit(_facUnit, _facUnitName)


    local _unit = nil

    if fac.facCurrentTargets[_facUnitName] ~= nil then
        _unit = Unit.getByName(fac.facCurrentTargets[_facUnitName].name)
    end

    local _tempPoint = nil
    local _tempDist = nil
    local _tempPosition = nil

    local _facPosition = _facUnit:getPosition()
    local _facPoint = _facUnit:getPoint()

    if _unit ~= nil and _unit:getLife() > 0 and _unit:isActive() == true then

        -- calc distance
        _tempPoint = _unit:getPoint()
        --   tempPosition = unit:getPosition()

        _tempDist = fac.getDistance(_unit:getPoint(), _facUnit:getPoint())
        if _tempDist < fac.FAC_maxDistance then
            -- calc visible

            -- check slightly above the target as rounding errors can cause issues, plus the unit has some height anyways
            local _offsetEnemyPos = { x = _tempPoint.x, y = _tempPoint.y + 2.0, z = _tempPoint.z }
            local _offsetFacPos = { x = _facPoint.x, y = _facPoint.y + 2.0, z = _facPoint.z }

            if land.isVisible(_offsetEnemyPos, _offsetFacPos) then
                return _unit
            end
        end
    end
    return nil
end

function fac.getFacUnit(_facUnitName)

    if _facUnitName == nil then
        return nil
    end

    local _fac = Unit.getByName(_facUnitName)

    if _fac ~= nil and _fac:isActive() and _fac:getLife() > 0 then

        return _fac
    end

    return nil
end

-- gets the FAC player name if available
function fac.getFacName(_facUnitName)
    local _facUnit = Unit.getByName(_facUnitName)
    local _facName = _facUnitName

    if _facUnit == nil then
        --env.info('FAC: fac.getFacName: unit not found: '.._facUnitName)
        return _facUnitName
    end

    if _facUnit:getPlayerName() ~= nil then
        _facName = _facUnit:getPlayerName()
    end

    return _facName
end

function fac.facAutoLase(_facUnitName, _laserCode, _smoke, _lock, _colour,_knwnTarget)
	local colorString = { ["0"] = "GREEN" ,["1"] = "RED" ,["2"] = "WHITE", ["3"] = "ORANGE" ,["4"] = "BLUE"}
	
    --env.info('FAC DEBUG: ' .. _facUnitName .. ' autolase')
    if _lock == nil then

        _lock = fac.FAC_lock
    end
	local _mkrColor
    local _facUnit = Unit.getByName(_facUnitName)

	if _facUnit == nil then
        --env.info('FAC: ' .. _facUnitName .. ' dead.')
        -- FAC was in the list, now the unit is missing: probably dead
        if fac.facUnits[_facUnitName] ~= nil then
            fac.notifyCoalition("[Forward Air Controller \"" ..fac.getFacName(_facUnitName).. "\" MIA.]", 10, fac.facUnits[_facUnitName].side)
        end

        --remove fac
        fac.cleanupFac(_facUnitName)

        return
    end
	
	local side = _facUnit:getCoalition()
	if side == 1 then
		_mkrColor = fac.FAC_smokeColour_BLUE
	elseif side == 2 then
		_mkrColor = fac.FAC_smokeColour_RED
	else
		_mkrColor = 2
	end

    -- stop fac activity if fac is marked off-station CANCELS AUTO-LASE
    if fac.facOnStation[_facUnitName] == nil then
        env.info('FAC: ' .. _facUnitName .. ' is marked off-station, stopping autolase')
        fac.cancelFacLase(_facUnitName)
        fac.facCurrentTargets[_facUnitName] = nil
        return
    end

    if fac.facLaserPointCodes[_facUnitName] == nil then
        --env.info('FAC: fac.facAutoLase() ' .. _facUnitName .. ' has no laserCode, setting default')
        fac.facLaserPointCodes[_facUnitName] = fac.FAC_laser_codes[1]
    end
    _laserCode = fac.facLaserPointCodes[_facUnitName]
    --env.info('FAC: ' .. _facUnitName .. ' laser code: ' .. _laserCode)

    if fac.facUnits[_facUnitName] == nil then
        --env.info('FAC: ' .. _facUnitName .. ' not in fac.facUnits list, adding')
        --add to list
        fac.facUnits[_facUnitName] = { name = _facUnit:getName(), side = _facUnit:getCoalition() }

        -- work out smoke colour
        if _colour == nil then

            if _facUnit:getCoalition() == 1 then
                _colour = fac.FAC_smokeColour_RED
            else
                _colour = fac.FAC_smokeColour_BLUE
            end
        end
		if fac.markerTypeColor[_facUnitName] ~= nil then
			_colour = fac.markerTypeColor[_facUnitName]
		end

        if _smoke == nil then

            if _facUnit:getCoalition() == 1 then
                _smoke = fac.FAC_smokeOn_RED
            else
                _smoke = fac.FAC_smokeOn_BLUE
            end
        end
    end
	if fac.markerType[_facUnitName]  == nil then 
		fac.markerType[_facUnitName] = "FLARES"
	end
    -- search for current unit

    if _facUnit:isActive() == false then

        fac.cleanupFac(_facUnitName)

        env.info('FAC: ' .. _facUnitName .. ' Not Active - Waiting 30 seconds')
        timer.scheduleFunction(fac.timerFacAutoLase, { _facUnitName, _laserCode, _smoke, _lock, _colour }, timer.getTime() + 30)

        return
    end

    local _enemyUnit = fac.getCurrentFacUnit(_facUnit, _facUnitName)

    if _enemyUnit == nil and fac.facCurrentTargets[_facUnitName] ~= nil then

        local _tempUnitInfo = fac.facCurrentTargets[_facUnitName]

        local _tempUnit = Unit.getByName(_tempUnitInfo.name)

        if _tempUnit ~= nil and _tempUnit:getLife() > 0 and _tempUnit:isActive() == true then
            fac.notifyCoalition("["..fac.getFacName(_facUnitName) .. " target " .. _tempUnitInfo.unitType .. " lost. Scanning for Targets.]", 10, _facUnit:getCoalition())
        else
            fac.notifyCoalition("["..fac.getFacName(_facUnitName) .. " target " .. _tempUnitInfo.unitType .. " KIA. Good Job! Scanning for Targets.]", 10, _facUnit:getCoalition())
			--trigger.action.removeMark(fac.markID+_tempUnit:getID())
        end

        --remove from smoke list
        fac.facSmokeMarks[_tempUnitInfo.name] = nil

        -- remove from target list
        fac.facCurrentTargets[_facUnitName] = nil

        --stop lasing
        fac.cancelFacLase(_facUnitName)
    end


    if _enemyUnit == nil then
		if _knwnTarget == nil then 
			_enemyUnit = fac.findFacNearestVisibleEnemy(_facUnit, _lock)
		else
			_enemyUnit = _knwnTarget
		end
		
		if _enemyUnit ~= nil then
			local tgtMarkID = timer.getTime() * 1000
            -- store current target for easy lookup
            fac.facCurrentTargets[_facUnitName] = { name = _enemyUnit:getName(), unitType = _enemyUnit:getTypeName(), unitId = _enemyUnit:getID() }
			local _vel = _enemyUnit:getVelocity()
			local _spd = 0
			if _vel ~=nil then
				_spd = math.sqrt(_vel.x^2+_vel.z^2)
			end
			
			local unitPos = _enemyUnit:getPoint()
			local _lat, _lon = coord.LOtoLL(_enemyUnit:getPosition().p)
			local _latLngStr = mist.tostringLL(_lat, _lon, 3, false)
			local _latLngSecStr = mist.tostringLL(_lat, _lon, 3, true)
			local _mgrsString = mist.tostringMGRS(coord.LLtoMGRS(coord.LOtoLL(_enemyUnit:getPosition().p)), 5)
			local _eTypeName = _enemyUnit:getTypeName()
			trigger.action.markToCoalition(tgtMarkID,_eTypeName.. " - DMS: " .. _latLngSecStr .." Altitude: ".. math.floor(unitPos.y) .."m/" .. math.floor(unitPos.y*3.28084) .."ft".. "\nHeading: ".. math.floor(getHeading(_enemyUnit) * 180/math.pi) .. "\nSpeed: " .. math.floor(_spd*2)  .. " MPH" .."\nSpotted by: " .. fac.getFacName(_facUnitName), _enemyUnit:getPoint(), _facUnit:getCoalition(),false,fac.getFacName(_facUnitName).." marked a target")
			timer.scheduleFunction(removeSetMark,{tgtMarkID},timer.getTime() + 120)
            fac.notifyCoalition("["..fac.getFacName(_facUnitName) .. " lasing new target " .. _eTypeName .. '. CODE: ' .. _laserCode .. fac.getFacPositionString(_enemyUnit).."\nMarked with "..colorString[tostring(_colour)] .." "..fac.markerType[_facUnitName].."]" , 10, _facUnit:getCoalition())
			local tgtMark = fac.markID+1
			--local tgtMark = curMark
			fac.markID = tgtMark
            -- create smoke
            if _smoke == true then
				--trigger.action.removeMark(tgtMark)
				
				--timer.scheduleFunction(trigger.action.removeMark,{tgtMark},timer.getTime() + 30)
                --create first smoke
                fac.createSmokeMarker(_enemyUnit, _colour,_facUnitName)
            end
        end
    end

    if _enemyUnit ~= nil then

        fac.facLaseUnit(_enemyUnit, _facUnit, _facUnitName, _laserCode)

        -- DEBUG
        --env.info('FAC: Timer timerSparkleLase '.._facUnitName.." ".._laserCode.." ".._enemyUnit:getName())
        --
		local _vel = _enemyUnit:getVelocity()
		local _spd = 0
		if _vel ~=nil then
			_spd = math.sqrt(_vel.x^2+_vel.z^2)
		end
		local timeNext
		if _spd < 1 then
			timeNext = 1
		else
			timeNext = 1/(_spd)
		end
		--trigger.action.outText(timeNext,10)
        timer.scheduleFunction(fac.timerFacAutoLase, { _facUnitName, _laserCode, _smoke, _lock, _colour }, timer.getTime() + timeNext)


        if _smoke == true then
            local _nextSmokeTime = fac.facSmokeMarks[_enemyUnit:getName()]

            --recreate smoke marker after 5 mins
            if _nextSmokeTime ~= nil and _nextSmokeTime < timer.getTime() then
                fac.createSmokeMarker(_enemyUnit, _colour,_facUnitName)
            end
        end

    else
        --env.info('FAC: LASE: No Enemies Nearby')

        -- stop lazing the old spot
        fac.cancelFacLase(_facUnitName)

        timer.scheduleFunction(fac.timerFacAutoLase, { _facUnitName, _laserCode, _smoke, _lock, _colour }, timer.getTime() + 5)
    end
end

-- used by the timer function
function fac.timerFacAutoLase(_args)

    fac.facAutoLase(_args[1], _args[2], _args[3], _args[4], _args[5])
end

function fac.cleanupFac(_facUnitName)
    -- clear laser - just in case
    fac.cancelFacLase(_facUnitName)

    -- Cleanup
    fac.facLaserPoints[_facUnitName] = nil
    fac.facIRPoints[_facUnitName] = nil
    fac.facSmokeMarks[_facUnitName] = nil
    fac.facUnits[_facUnitName] = nil
    fac.facCurrentTargets[_facUnitName] = nil
    fac.facAddedTo[_facUnitName] = nil
    fac.facRadioAdded[_facUnitName] = nil
    fac.facLaserPointCodes[_facUnitName] = nil
    fac.facOnStation[_facUnitName] = nil
	fac.markerType[_facUnitName] = nil
end

function fac.createFacSmokeMarker(_enemyUnit, _colour,_facUnitName)

    --recreate in 5 mins
	if fac.markerType[_facUnitName] == "SMOKE" then
		fac.facSmokeMarks[_enemyUnit:getName()] = timer.getTime() + 300.0
	else
		fac.facSmokeMarks[_enemyUnit:getName()] = timer.getTime() + 5
	end
    -- move smoke 2 meters above target for ease
    local _enemyPoint = _enemyUnit:getPoint()
	
	if fac.markerType[_facUnitName] =="SMOKE" then
		trigger.action.smoke({ x = _enemyPoint.x + 5.0, y = _enemyPoint.y + 5.0, z = _enemyPoint.z }, _colour)
	else
		trigger.action.signalFlare({ x = _enemyPoint.x + 5.0, y = _enemyPoint.y + 5.0, z = _enemyPoint.z }, _colour,0)
	end
end

function fac.cancelFacLase(_facUnitName)

    local _tempLase = fac.facLaserPoints[_facUnitName]

    if _tempLase ~= nil then
        Spot.destroy(_tempLase)
        fac.facLaserPoints[_facUnitName] = nil

        _tempLase = nil
    end

    local _tempIR = fac.facIRPoints[_facUnitName]

    if _tempIR ~= nil then
        Spot.destroy(_tempIR)
        fac.facIRPoints[_facUnitName] = nil

        _tempIR = nil
    end
end

function fac.facLasePoint(_Point, _facUnit, _facUnitName, _laserCode)

    --cancelLase(_facUnitName)

    local _spots = {}

    local _enemyVector = _Point
    local _enemyVectorUpdated = { x = _enemyVector.x, y = _enemyVector.y + 2.0, z = _enemyVector.z }

    local _oldLase = fac.facLaserPoints[_facUnitName]
    local _oldIR = fac.facIRPoints[_facUnitName]

    if _oldLase == nil or _oldIR == nil then

        -- create lase

        local _status, _result = pcall(function()
            _spots['irPoint'] = Spot.createInfraRed(_facUnit, { x = 0, y = 2.0, z = 0 }, _enemyVectorUpdated)
            _spots['laserPoint'] = Spot.createLaser(_facUnit, { x = 0, y = 2.0, z = 0 }, _enemyVectorUpdated, _laserCode)
            return _spots
        end)

        if not _status then
            env.error('FAC: ERROR: ' .. _result, false)
        else
            if _result.irPoint then

                -- DEBUG
                --env.info('FAC:' .. _facUnitName .. ' placed IR Pointer on '.._enemyUnit:getName())

                fac.facIRPoints[_facUnitName] = _result.irPoint --store so we can remove after
            end
            if _result.laserPoint then

                --  DEBUG
                --env.info('FAC:' .. _facUnitName .. ' is Lasing '.._enemyUnit:getName()..'. CODE:'.._laserCode)

                fac.facLaserPoints[_facUnitName] = _result.laserPoint
            end
        end

    else

        -- update lase

        if _oldLase ~= nil then
            _oldLase:setPoint(_enemyVectorUpdated)
        end

        if _oldIR ~= nil then
            _oldIR:setPoint(_enemyVectorUpdated)
        end
    end
end

function fac.facLaseUnit(_enemyUnit, _facUnit, _facUnitName, _laserCode)

    --cancelLase(_facUnitName)

    local _spots = {}

    local _enemyVector = _enemyUnit:getPoint()
    local _enemyVectorUpdated = { x = _enemyVector.x, y = _enemyVector.y + 2.0, z = _enemyVector.z }

    local _oldLase = fac.facLaserPoints[_facUnitName]
    local _oldIR = fac.facIRPoints[_facUnitName]

    if _oldLase == nil or _oldIR == nil then

        -- create lase

        local _status, _result = pcall(function()
            _spots['irPoint'] = Spot.createInfraRed(_facUnit, { x = 0, y = 2.0, z = 0 }, _enemyVectorUpdated)
            _spots['laserPoint'] = Spot.createLaser(_facUnit, { x = 0, y = 2.0, z = 0 }, _enemyVectorUpdated, _laserCode)
            return _spots
        end)

        if not _status then
            env.error('FAC: ERROR: ' .. _result, false)
        else
            if _result.irPoint then

                -- DEBUG
                --env.info('FAC:' .. _facUnitName .. ' placed IR Pointer on '.._enemyUnit:getName())

                fac.facIRPoints[_facUnitName] = _result.irPoint --store so we can remove after
            end
            if _result.laserPoint then

                --  DEBUG
                --env.info('FAC:' .. _facUnitName .. ' is Lasing '.._enemyUnit:getName()..'. CODE:'.._laserCode)

                fac.facLaserPoints[_facUnitName] = _result.laserPoint
            end
        end

    else

        -- update lase

        if _oldLase ~= nil then
            _oldLase:setPoint(_enemyVectorUpdated)
        end

        if _oldIR ~= nil then
            _oldIR:setPoint(_enemyVectorUpdated)
        end
    end
end

-- Find nearest enemy to FAC that isn't blocked by terrain
function fac.findFacNearestVisibleEnemy(_facUnit, _targetType,_distance)

    -- DEBUG
    --local _facUnitName = _facUnit:getName()
    --env.info('FAC:' .. _facUnitName .. ' fac.findFacNearestVisibleEnemy() ')

    local _maxDistance = _distance or fac.FAC_maxDistance
    local _x = 1
    local _i = 1

    local _units = nil
    local _groupName = nil

    local _nearestUnit = nil
    local _nearestDistance = _maxDistance

    local _enemyGroups
	local _enemyStatic
	local _facSide = _facUnit:getCoalition()
    if _facUnit:getCoalition() == 1 then
        _enemyGroups = coalition.getGroups(2, Group.Category.GROUND)
		_enemyShips = coalition.getGroups(2, Group.Category.SHIP)
		_enemyStatic = coalition.getStaticObjects(2)
    else
        _enemyGroups = coalition.getGroups(1, Group.Category.GROUND)
		_enemyShips = coalition.getGroups(1, Group.Category.SHIP)
		_enemyStatic = coalition.getStaticObjects(1)
    end

    local _facPoint = _facUnit:getPoint()
    local _facPosition = _facUnit:getPosition()

    local _tempPoint = nil
    local _tempPosition = nil

    local _tempDist = nil
	
	local dist = {
		 id = world.VolumeType.SPHERE,
			params = {
			point = _facPoint,
			radius = fac.FAC_maxDistance --max range ARTY
			}
	 }
	
	local findClosest = function(foundItem, val) -- generic search for all scenery
		local _unit = foundItem
		local foundOutput = nil
		local foundObjectPos = nil
		local sideCheck = foundItem:getCoalition()
		if foundItem:getLife() > 1 and foundItem:inAir() == false  then
			if sideCheck ~= _facSide then
				local samFactor = 1
				local _unitPos = _unit:getPoint()
				if _unit:hasAttribute("SAM TR") then
					samFactor = 0.1
				elseif _unit:hasAttribute("IR Guided SAM") then
					samFactor = 0.5
				elseif _unit:hasAttribute("AA_flak") then
					samFactor = 0.7
				end
				local _tempADist = fac.getDistance(_unitPos,_facPoint)
				_tempDist = _tempADist*samFactor
				--trigger.action.outText("Found ".._tempDist.." " ..samFactor,10)
				
				local _offsetEnemyPos = { x = _unitPos.x, y = _unitPos.y + 2.0, z = _unitPos.z }
				local _offsetFacPos = { x = _facPoint.x, y = _facPoint.y + 2.0, z = _facPoint.z }
				if  land.isVisible(_offsetEnemyPos, _offsetFacPos) and _unit:isActive() then
					local _type = fac.tgtCatType(foundItem)
					if _tempADist < fac.FAC_maxDistance then 
						if _nearestDistance > _tempDist then
						
							_nearestDistance = _tempDist
							_nearestUnit = _unit
						end
					end
				end
			end
		end	
	end
	world.searchObjects(Object.Category.UNIT,dist,findClosest)
    
	-- -- finish this function
    -- local _vhpriority = false
    -- local _vpriority = false
    -- local _thpriority = false
    -- local _tpriority = false
    -- for _i = 1, #_enemyGroups do
        -- if _enemyGroups[_i] ~= nil then
            -- _groupName = _enemyGroups[_i]:getName()
            -- _units = fac.getGroup(_groupName)
            -- if #_units > 0 then
                -- for _y = 1, #_units do
                    -- local _targeted = false
                    -- local _targetedJTAC = false
                    -- if not _distance then
                        -- _targeted = fac.alreadyFacTarget(_facUnit, _units[_x])
                    -- end

                    -- -- calc distance
                    -- _tempPoint = _units[_y]:getPoint()
                    -- _tempDist = fac.getDistance(_tempPoint, _facPoint)

                    -- if _tempDist < _maxDistance and _tempDist < _nearestDistance then

                        -- local _offsetEnemyPos = { x = _tempPoint.x, y = _tempPoint.y + 2.0, z = _tempPoint.z }
                        -- local _offsetFacPos = { x = _facPoint.x, y = _facPoint.y + 2.0, z = _facPoint.z }
                        -- -- calc visible

                        -- if land.isVisible(_offsetEnemyPos, _offsetFacPos) and _targeted == false and _targetedJTAC == false then
                            -- if (string.match(_units[_y]:getName(), "hpriority") ~= nil) and fac.isVehicle(_units[_y]) then
                                -- _vhpriority = true
                            -- elseif (string.match(_units[_y]:getName(), "priority") ~= nil) and fac.isVehicle(_units[_y]) then
                                -- _vpriority = true
                            -- elseif (string.match(_units[_y]:getName(), "hpriority") ~= nil) and fac.isInfantry(_units[_y]) then
                                -- _thpriority = true
                            -- elseif (string.match(_units[_y]:getName(), "priority") ~= nil) and fac.isInfantry(_units[_y]) then
                                -- _tpriority = true
                            -- end
                        -- end
                    -- end
                -- end
            -- end
        -- end
    -- end

    -- for _i = 1, #_enemyGroups do
        -- if _enemyGroups[_i] ~= nil then
            -- _groupName = _enemyGroups[_i]:getName()
            -- _units = fac.getGroup(_groupName)
            -- if #_units > 0 then

                -- for _x = 1, #_units do

                    -- --check to see if a FAC has already targeted this unit only if a distance
                    -- --wasnt passed in
                    -- local _targeted = false
                    -- if not _distance then
                        -- _targeted = fac.alreadyFacTarget(_facUnit, _units[_x])
                    -- end

                    -- local _allowedTarget = true

                    -- if _targetType == "vehicle" and _vhpriority == true then
                        -- _allowedTarget = (string.match(_units[_x]:getName(), "hpriority") ~= nil) and fac.isVehicle(_units[_x])
                    -- elseif _targetType == "vehicle" and _vpriority == true then
                        -- _allowedTarget = (string.match(_units[_x]:getName(), "priority") ~= nil) and fac.isVehicle(_units[_x])
                    -- elseif _targetType == "vehicle" then
                        -- _allowedTarget = fac.isVehicle(_units[_x])
                    -- elseif _targetType == "troop" and _hpriority == true then
                        -- _allowedTarget = (string.match(_units[_x]:getName(), "hpriority") ~= nil) and fac.isInfantry(_units[_x])
                    -- elseif _targetType == "troop" and _priority == true then
                        -- _allowedTarget = (string.match(_units[_x]:getName(), "priority") ~= nil) and fac.isInfantry(_units[_x])
                    -- elseif _targetType == "troop" then
                        -- _allowedTarget = fac.isInfantry(_units[_x])
                    -- elseif _vhpriority == true or _thpriority == true then
                        -- _allowedTarget = (string.match(_units[_x]:getName(), "hpriority") ~= nil)
                    -- elseif _vpriority == true or _tpriority == true then
                        -- _allowedTarget = (string.match(_units[_x]:getName(), "priority") ~= nil)
                    -- else
                        -- _allowedTarget = true
                    -- end

                    -- if _units[_x]:isActive() == true and _targeted == false and _allowedTarget == true then

                        -- -- calc distance
                        -- _tempPoint = _units[_x]:getPoint()
                        -- _tempDist = fac.getDistance(_tempPoint, _facPoint)

                        -- if _tempDist < _maxDistance and _tempDist < _nearestDistance then

                            -- local _offsetEnemyPos = { x = _tempPoint.x, y = _tempPoint.y + 2.0, z = _tempPoint.z }
                            -- local _offsetFacPos = { x = _facPoint.x, y = _facPoint.y + 2.0, z = _facPoint.z }


                            -- -- calc visible
                            -- if land.isVisible(_offsetEnemyPos, _offsetFacPos) then

                                -- _nearestDistance = _tempDist
                                -- _nearestUnit = _units[_x]
                            -- end
                        -- end
                    -- end
                -- end
            -- end
        -- end
    -- end
	


    if _nearestUnit == nil then
        return nil
    end


    return _nearestUnit
end

-- tests whether the unit is targeted by another FAC
function fac.alreadyFacTarget(_facUnit, _enemyUnit)

    for _, _facTarget in pairs(fac.facCurrentTargets) do

        if _facTarget.unitId == _enemyUnit:getID() then
            -- env.info("FAC: ALREADY TARGET")
            return true
        end
    end

    return false
end
function fac.scanForTGToff(_args)
	--fac.facManTGT[_args[1]] = {}
	local _fac = Unit.getByName(_args[1])
	local _side = _fac:getCoalition()
	fac.setFacOnStation({_args[1], nil})
	--fac.cancelFacLase(_args[1])
	--fac.notifyCoalition("Forward Air Controller \"" .. fac.getFacName(_args[1]) .. "\" off-station.", 10, _fac:getCoalition())
end

function fac.scanForTGT (_args)
	--trigger.action.outText("scanning ",10)
	local _fac = Unit.getByName(_args[1])
	local _side = _fac:getCoalition()
	local _facPos = _fac:getPoint()
	local _facGID = fac.getGroupId(_fac)
	local _i
	local _j
	                            
    local _offsetFacPos = { x = _facPos.x, y = _facPos.y + 2.0, z = _facPos.z }
	local dist2 = {
		 id = world.VolumeType.SPHERE,
			params = {
			point = _fac:getPoint(),
			radius = fac.FAC_maxDistance --max range ARTY
			}
	 }
	--fac.cancelFacLase(_args[1])
	--fac.facCurrentTargets[_args[1]] = nil
	--trigger.action.outText("scanning ",10)
	fac.facManTGT[_args[1]] = {}
	local tempFound = {}
	local aaTempFound = {}
	local count = 0
	local getTGT = function(foundItemM, val) -- generic search for all scenery
	--trigger.action.outText("scanning ",10)
	--local _checkArty = fac.isArty(foundItem)
	--local _tempTGTGroup = foundItem:getGroup() 
		if _side ~= foundItemM:getCoalition() then -- check for friendly
			--if count <6 then
					--trigger.action.outText("scanning ",10)
					--trigger.action.outText("scanning "..foundItemM:getTypeName(),10)
				if foundItemM:inAir() == false and foundItemM:isActive() and foundItemM:getLife() > 1 then
					local _tempPoint= foundItemM:getPoint()
					local _offsetEnemyPos = { x = _tempPoint.x, y = _tempPoint.y + 2.0, z = _tempPoint.z }
					if land.isVisible(_offsetEnemyPos, _offsetFacPos) then
					--trigger.action.outText("scanning ",10)
						--trigger.action.outText("FOUND "..foundItemM:getTypeName(),10)
						if foundItemM:hasAttribute("SAM TR") or foundItemM:hasAttribute("IR Guided SAM") or foundItemM:hasAttribute("AA_flak") then
							table.insert(aaTempFound,foundItemM)
						else
							table.insert(tempFound,foundItemM)
							--count = count + 1
						end
					end
				end
			--end
			
		
			--return
		end
	end
	
	world.searchObjects(Object.Category.UNIT,dist2,getTGT)
	
	for count = 1,10 do
		if #aaTempFound >= count then
			table.insert(fac.facManTGT[_args[1]],aaTempFound[count])
		else
			table.insert(fac.facManTGT[_args[1]],tempFound[count])
		end
	end
	
	local _tgtList = fac.facManTGT[_args[1]]
	local count = 0
	for _i=1, #_tgtList do
		local tgtp = _tgtList[_i]:getPoint()
		local _TGTdist = math.sqrt(((tgtp.z-_facPos.z)^2)+((tgtp.x-_facPos.x)^2))
		-- local _TGTheading = math.atan((tp.z-_facPos.z)/(tp.x-_facPos.x))
		-- if _TGTheading > 0 then
			-- _TGTheading= _TGTheading + math.pi
		-- end
		-- _TGTheadDeg = _TGTheading*180/math.pi
		-- if _TGTheadDeg <0 then
			-- _TGTheadDeg = _TGTheadDeg +360
		-- end
		--trigger.action.outText("FOUND "..foundItem:getTypeName(),10)
		local dy = tgtp.z-_facPos.z
		local dx = tgtp.x-_facPos.x
		count = count + 1
		local _TGTheading = math.atan(dy/dx)

		--correcting for coordinate space
		local recceMarkID = timer.getTime()*1000 + count
		if dy < 0 then -- dy = -1 90-270
			if dx < 0 then  --dy/dx = 1 180-270
				--trigger.action.outText(_artyInRange:getName().." Firing SW:\n".. (_fireheading/math.pi)*180 .."\n", 300)
				_TGTheading= _TGTheading  + math.pi
			else
				--trigger.action.outText(_artyInRange:getName().." Firing SE:\n".. (_fireheading/math.pi)*180 .."\n", 300)
				_TGTheading= _TGTheading + math.pi
			end
		else  --dy = 1 270-90
			if dx < 0 then --dy/dx = -1 270-0
				--trigger.action.outText(_artyInRange:getName().." Firing NW:\n".. (_fireheading/math.pi)*180 .."\n", 300)
				_TGTheading= _TGTheading  + 2*math.pi
			else --dy/dx = 1 0-90
				--trigger.action.outText(_artyInRange:getName().." Firing NE:\n".. (_fireheading/math.pi)*180 .."\n", 300)
				_TGTheading= _TGTheading 
			end
		
		end
		local _TGTheadDeg =(_TGTheading)/math.pi*180
		--math.floor(_TGTdist) .."m/" .. math.floor(_TGTdist*3.28084) .."ft"
		trigger.action.outTextForGroup(_facGID,"Target ".._i .. ":" .. _tgtList[_i]:getTypeName() .. " Bearing:" ..math.floor(_TGTheadDeg) .. " Range:"..math.floor(_TGTdist) .."m/" .. math.floor(_TGTdist*3.28084) .."ft",30)
		trigger.action.markToGroup(recceMarkID,"Target ".._i ..":".. _tgtList[_i]:getTypeName(), _tgtList[_i]:getPoint(),_facGID,false,"")
		timer.scheduleFunction(removeSetMark,{recceMarkID},timer.getTime() + 60)
	end
	
end


function fac.scanForTGTai (_args)
	--trigger.action.outText("scanning 1" .. _args[1] ,10)
	local _fac = Unit.getByName(_args[1])
	local _tgtList = {}
	if _fac ~= nil then  
		local _side = _fac:getCoalition()
		local _facPos = _fac:getPoint()
		--local _facGID = fac.getGroupId(_fac)
		local _i
		local _j
									
		local _offsetFacPos = { x = _facPos.x, y = _facPos.y + 2.0, z = _facPos.z }
		local dist2 = {
			 id = world.VolumeType.SPHERE,
				params = {
				point = _fac:getPoint(),
				radius = fac.FAC_maxDistance/10 * 5 + _facPos.y --max range ARTY
				}
		 }
		--fac.cancelFacLase(_args[1])
		--fac.facCurrentTargets[_args[1]] = nil
		--trigger.action.outText("scanning 2",10)
		
		local tempFound = {}
		local aaTempFound = {}
		local count = 0
		local getTGT = function(foundItemM, val) -- generic search for all scenery
		--trigger.action.outText("scanning ",10)
		--local _checkArty = fac.isArty(foundItem)
		--local _tempTGTGroup = foundItem:getGroup() 
			if _side ~= foundItemM:getCoalition() then -- check for friendly
				--if count <6 then
						--trigger.action.outText("scanning ",10)
						--trigger.action.outText("scanning "..foundItemM:getTypeName(),10)
					if foundItemM:inAir() == false and foundItemM:isActive() and foundItemM:getLife() > 1 then
						local _tempPoint= foundItemM:getPoint()
						local _offsetEnemyPos = { x = _tempPoint.x, y = _tempPoint.y + 2.0, z = _tempPoint.z }
						if land.isVisible(_offsetEnemyPos, _offsetFacPos) then
						--trigger.action.outText("scanning ",10)
							--trigger.action.outText("FOUND "..foundItemM:getTypeName(),10)
							local _vel = foundItemM:getVelocity() 
							local _spd
							if _vel ~=nil then
								_spd = math.sqrt(_vel.x^2+_vel.z^2)
							end
							if _spd == 0 then
								if foundItemM:hasAttribute("SAM TR") or foundItemM:hasAttribute("IR Guided SAM") or foundItemM:hasAttribute("AA_flak") then
									table.insert(aaTempFound,foundItemM)
								else
									table.insert(tempFound,foundItemM)
									--count = count + 1
								end
							end
						end
					end
				--end
				
			
				--return
			end
		end
		
		world.searchObjects(Object.Category.UNIT,dist2,getTGT)
		
		for count = 1,10 do
			if #aaTempFound >= count then
				table.insert(_tgtList,aaTempFound[count])
			else
				table.insert(_tgtList,tempFound[count])
			end
		end
		
		--local _tgtList = fac.facManTGT[_args[1]]
		
	end
	return _tgtList
end



	
function fac.setManualTgt(_args)
	fac.cancelFacLase(_args[1])
	local _fac = Unit.getByName(_args[1])
	local _facGID = fac.getGroupId(_fac)
	fac.notifyCoalition("[Forward Air Controller \"" .. fac.getFacName(_args[1]) .. "\" starting manual laze. Reseting to new target]", 10, _fac:getCoalition())
	--fac.facCurrentTargets[_args[1]] = nil
	fac.setFacOnStation({_args[1],true})
	--fac.cancelFacLase(_args[1])
	--fac.facCurrentTargets[_facUnitName]
	--fac.facCurrentTargets[_args[1]] = nil
	--fac.facUnits[_facUnitName] = nil
	local _tgtList = fac.facManTGT[_args[1]]
	if _tgtList == nil then
		trigger.action.outTextForGroup(_facGID,"Error loading tgts, please reset FAC",10)
		return
	end
	local _enemyUnit = _tgtList[_args[2]]
	fac.facCurrentTargets[_args[1]] = { name = _enemyUnit:getName(), unitType = _enemyUnit:getTypeName(), unitId = _enemyUnit:getID() }
	
	local _lock = "all"
	
	if _fac:getCoalition() == 1 then
		local _colour = fac.FAC_smokeColour_RED
		local _smoke = fac.FAC_smokeOn_RED   
	else
		local _colour = fac.FAC_smokeColour_BLUE
		local _smoke = fac.FAC_smokeOn_BLUE
	end
	if fac.markerTypeColor[_args[1]] ~= nil then
		_colour = fac.markerTypeColor[_args[1]] 
	end
	  
	
	local _laserCode = fac.facLaserPointCodes[_args[1]]
	if _laserCode == nil then
		fac.setFacLaserCode({_args[1], fac.FAC_laser_codes[1]})
		_laserCode = fac.facLaserPointCodes[_args[1]]+1
	end		
	--local _facGroup =
	
	trigger.action.outTextForGroup(_facGID,"Designating Target ".._args[2]..": ".._tgtList[_args[2]]:getTypeName(),10)

	if _args[2] > #_tgtList then
		trigger.action.outTextForGroup(_facGID,"Invalid Target",10)
	elseif _tgtList[_args[2]]:getLife() > 0 then
		fac.notifyCoalition("[Forward Air Controller \"" .. fac.getFacName(_args[1]) .. "\" starting manual laze.]", 10, _fac:getCoalition())
		fac.facAutoLase(_args[1],  _laserCode, _smoke, _lock, _colour)
		fac.createSmokeMarker(_tgtList[_args[2]], _colour,_args[1])
		--fac.facLaseUnit(_tgtList[_args[2]], _fac, _args[1], _laserCode)
			-- --fac.notifyCoalition(fac.getFacName(_args[1]) .. " lasing new target " .. _tgtList[_args[2]]:getTypeName() .. '. CODE: ' .. _laserCode .. fac.getFacPositionString(_tgtList[_args[2]]), 10, _fac:getCoalition())
			-- --trigger.action.outTextForGroup(_facGID,"Designated Target ".._args[2].. " " .. _tgtList[_args[2]]:getTypeName().." for attack",10)
		-- if _smoke == true then
			-- local _nextSmokeTime = fac.facSmokeMarks[_tgtList[_args[2]]:getName()]
             -- --recreate smoke marker after 5 mins
			-- if _nextSmokeTime ~= nil and _nextSmokeTime < timer.getTime() then
				-- fac.createSmokeMarker(_tgtList[_args[2]], _colour,_args[1])
			-- end
		-- end
		trigger.action.outTextForGroup(_facGID,"Designated Target ".._args[2].. " " .. _tgtList[_args[2]]:getTypeName().." for attack",10)
	elseif _tgtList[_args[2]]:getLife() < 1 then
		trigger.action.outTextForGroup(_facGID,"Designated Target ".._args[2].. " " .. _tgtList[_args[2]]:getTypeName().." is already dead",10)
	end
end
	
-- Adds menuitem to all FAC units that are active
function fac.addFacF10MenuOptions()
    -- Loop through all FAC units

    timer.scheduleFunction(fac.addFacF10MenuOptions, nil, timer.getTime() + 10)

    for _, _facUnitName in pairs(fac.facPilotNames) do

        local status, error = pcall(function()

            local _unit = fac.getFacUnit(_facUnitName)

            if _unit ~= nil then

                local _groupId = fac.getGroupId(_unit)
				
                if _groupId then

                    if fac.facAddedTo[tostring(_groupId)] == nil then
                        local _rootPath = missionCommands.addSubMenuForGroup(_groupId, "FAC")
						local _TGTModePath = missionCommands.addSubMenuForGroup(_groupId, "Targeting Mode",_rootPath)
						local _AutoTGTModePath = missionCommands.addSubMenuForGroup(_groupId, "Auto Mode",_TGTModePath)
						local _ManTGTModePath = missionCommands.addSubMenuForGroup(_groupId, "Manual Mode",_TGTModePath)
							missionCommands.addCommandForGroup(_groupId, "Auto Laze On",  _AutoTGTModePath, fac.setFacOnStation, { _facUnitName, true})
							missionCommands.addCommandForGroup(_groupId, "Auto Laze Off", _AutoTGTModePath, fac.setFacOnStation, { _facUnitName, nil})
							missionCommands.addCommandForGroup(_groupId, "Scan for Close Targets",  _ManTGTModePath, fac.scanForTGT, { _facUnitName})
							missionCommands.addCommandForGroup(_groupId, "Stop Manual Designating",  _ManTGTModePath, fac.scanForTGToff, { _facUnitName})
							local _TGTSelectPath = missionCommands.addSubMenuForGroup(_groupId, "Select Found Target",_ManTGTModePath)
								missionCommands.addCommandForGroup(_groupId, "Target 1",  _TGTSelectPath, fac.setManualTgt, { _facUnitName, 1})
								missionCommands.addCommandForGroup(_groupId, "Target 2",  _TGTSelectPath, fac.setManualTgt, { _facUnitName, 2})
								missionCommands.addCommandForGroup(_groupId, "Target 3",  _TGTSelectPath, fac.setManualTgt, { _facUnitName, 3})
								missionCommands.addCommandForGroup(_groupId, "Target 4",  _TGTSelectPath, fac.setManualTgt, { _facUnitName, 4})
								missionCommands.addCommandForGroup(_groupId, "Target 5",  _TGTSelectPath, fac.setManualTgt, { _facUnitName, 5})
								missionCommands.addCommandForGroup(_groupId, "Target 6",  _TGTSelectPath, fac.setManualTgt, { _facUnitName, 6})
								missionCommands.addCommandForGroup(_groupId, "Target 7",  _TGTSelectPath, fac.setManualTgt, { _facUnitName, 7})
								missionCommands.addCommandForGroup(_groupId, "Target 8",  _TGTSelectPath, fac.setManualTgt, { _facUnitName, 8})
								missionCommands.addCommandForGroup(_groupId, "Target 9",  _TGTSelectPath, fac.setManualTgt, { _facUnitName, 9})
								missionCommands.addCommandForGroup(_groupId, "Target 10",  _TGTSelectPath, fac.setManualTgt, { _facUnitName, 10})
							missionCommands.addCommandForGroup(_groupId, "Call artillery strikes on all manual targets",  _ManTGTModePath, fac.multiStrike, { _facUnitName})
                        -- add each possible laser code as a menu option
						local _lzrpath = missionCommands.addSubMenuForGroup(_groupId, "Avaliable Laser Codes",_rootPath)
                        for _, _laserCode in pairs(fac.FAC_laser_codes) do
                            missionCommands.addCommandForGroup(_groupId, string.format("Laser code: %s", _laserCode), _lzrpath, fac.setFacLaserCode, { _facUnitName, _laserCode})
                        end
						local _lzerCustPath =	missionCommands.addSubMenuForGroup(_groupId, "Custom Laser Code", _lzrpath)
						local _digCount
						local _lzerCode1Path = missionCommands.addSubMenuForGroup(_groupId, "Digit 1", _lzerCustPath)
							for _digCount = 1 ,1 do
								missionCommands.addCommandForGroup(_groupId, _digCount,  _lzerCode1Path, fac.setCustCode, { _facUnitName, 1,_digCount})
							end
						local _lzerCode2Path = missionCommands.addSubMenuForGroup(_groupId, "Digit 2", _lzerCustPath)
							for  _digCount = 1 ,6 do
								missionCommands.addCommandForGroup(_groupId, _digCount,  _lzerCode2Path, fac.setCustCode, { _facUnitName, 2,_digCount})
							end
						local _lzerCode3Path = missionCommands.addSubMenuForGroup(_groupId, "Digit 3", _lzerCustPath)
							for  _digCount = 1 ,8 do
								missionCommands.addCommandForGroup(_groupId, _digCount,  _lzerCode3Path, fac.setCustCode, { _facUnitName, 3,_digCount})
							end
						local _lzerCode4Path = missionCommands.addSubMenuForGroup(_groupId, "Digit 4", _lzerCustPath)
							for  _digCount = 1 ,8 do
								missionCommands.addCommandForGroup(_groupId, _digCount,  _lzerCode4Path, fac.setCustCode, { _facUnitName, 4,_digCount})
							end
						local _artyPath = missionCommands.addSubMenuForGroup(_groupId, "Artillery Control",_rootPath)
							missionCommands.addCommandForGroup(_groupId, "Check Avaliable Arty Groups", _artyPath , fac.checkTask, {_facUnitName})
							missionCommands.addCommandForGroup(_groupId, "Call Artillery Fire Mission", _artyPath , fac.callFireMission, { _facUnitName,fac.fireMissionRounds,0})
							missionCommands.addCommandForGroup(_groupId, "Call Illummination", _artyPath , fac.callFireMission, { _facUnitName,fac.fireMissionRounds,1})
							missionCommands.addCommandForGroup(_groupId, "Call Mortar Strike Only(Anti-infantry)", _artyPath , fac.callFireMission, { _facUnitName,fac.fireMissionRounds,2})
							missionCommands.addCommandForGroup(_groupId, "Call Heavy Artillery Strike Only <No Smart Munition> (Anti-Material)", _artyPath , fac.callFireMission, { _facUnitName,10,3})
						
						local _cMissilePath = missionCommands.addSubMenuForGroup(_groupId, "Air/Naval THAWK Strike Menu",_artyPath)
							missionCommands.addCommandForGroup(_groupId, "Single Target", _cMissilePath , fac.callFireMission, { _facUnitName,1,4})
							missionCommands.addCommandForGroup(_groupId, "Multi Target (Manual Targeting Required), GPS weapons only", _cMissilePath , fac.callFireMissionMulti, { _facUnitName,1,4})
							--missionCommands.addCommandForGroup(_groupId, "Carpet Bomb (Define on F10 Map with syntax: AttackAz CBRQT), Dumb bombs only", _cMissilePath , world.addEventHandler, CrptBmbDesig)
							
							missionCommands.addCommandForGroup(_groupId, "Carpet Bomb (Turn your aircraft to desired attack azimuth), Dumb bombs only", _cMissilePath , fac.callFireMissionCarpet2, { _facUnitName,1,5})
						local _mkrpath = missionCommands.addSubMenuForGroup(_groupId, "Marker Type",_rootPath)
							local _colorSmokePath = missionCommands.addSubMenuForGroup(_groupId, "Smoke",_mkrpath)
								missionCommands.addCommandForGroup(_groupId, "GREEN", _colorSmokePath,  fac.setMarkerColor, { _facUnitName, "SMOKE",0})
								missionCommands.addCommandForGroup(_groupId, "RED", _colorSmokePath , fac.setMarkerColor, { _facUnitName, "SMOKE",1})
								missionCommands.addCommandForGroup(_groupId, "ORANGE", _colorSmokePath , fac.setMarkerColor, { _facUnitName, "SMOKE",3})
								missionCommands.addCommandForGroup(_groupId, "BLUE", _colorSmokePath , fac.setMarkerColor, { _facUnitName, "SMOKE",4})
								missionCommands.addCommandForGroup(_groupId, "WHITE", _colorSmokePath , fac.setMarkerColor, { _facUnitName, "SMOKE",2})
							local _colorFlarePath = missionCommands.addSubMenuForGroup(_groupId, "FLARES",_mkrpath)
								missionCommands.addCommandForGroup(_groupId, "GREEN", _colorFlarePath,  fac.setMarkerColor, { _facUnitName, "FLARES",0})
								missionCommands.addCommandForGroup(_groupId, "WHITE", _colorFlarePath , fac.setMarkerColor, { _facUnitName, "FLARES",2})
								missionCommands.addCommandForGroup(_groupId, "ORANGE", _colorFlarePath , fac.setMarkerColor, { _facUnitName, "FLARES",3})
							--missionCommands.addCommandForGroup(_groupId, "Smoke", _mkrpath,  fac.setMarkerType, { _facUnitName, "SMOKE"})
							--missionCommands.addCommandForGroup(_groupId, "FLARES", _mkrpath , fac.setMarkerType, { _facUnitName, "FLARES"})
							missionCommands.addCommandForGroup(_groupId, "Map Marker", _mkrpath , fac.setMapMarker, { _facUnitName})
							--missionCommands.addCommandForGroup(_groupId, "RECCE", _mkrpath , fac.recceDetect, { _facUnitName})
                        fac.facAddedTo[tostring(_groupId)] = true
                    end

                end
            --[[else
                env.info(string.format("FAC DEBUG: unit nil %s",_facUnitName)) ]]
            end
        end)
	end
	
	for _, _facUnitName in pairs(fac.reccePilotNames) do

        local status, error = pcall(function()

            local _unitR = fac.getFacUnit(_facUnitName)

            if _unitR ~= nil then

                local _groupIdR = fac.getGroupId(_unitR)

                if _groupIdR then

                    if fac.RECCEAddedTo[tostring(_groupIdR)] == nil then
                        local _rootPathR = missionCommands.addSubMenuForGroup(_groupIdR, "RECCE")
                        missionCommands.addCommandForGroup(_groupIdR, "RECCE",  _rootPathR, fac.recceDetect, { _facUnitName})
						missionCommands.addCommandForGroup(_groupIdR, "Strategic Strike",  _rootPathR, fac.stratStrike, { _facUnitName})
                        --missionCommands.addCommandForGroup(_groupId, "Go Off-Station", _rootPathR, fac.recceDetect, { _facUnitName, nil})
						fac.RECCEAddedTo[tostring(_groupIdR)] = true
					end
                end
            --[[else
                env.info(string.format("FAC DEBUG: unit nil %s",_facUnitName)) ]]
            end
        end)

        if (not status) then
            env.error(string.format("Error adding f10 to RECCE: %s", error), false)
        end
    end

	
    local status, error = pcall(function()

        -- now do any player controlled aircraft that ARENT FAC units
        if fac.FAC_FACStatusF10 then
            -- get all BLUE players
            fac.addFacRadioCommand(2)

            -- get all RED players
            fac.addFacRadioCommand(1)
        end

    end)

    if (not status) then
        env.error(string.format("Error adding f10 to other players: %s", error), false)
    end


end

function fac.setMapMarker(_args)
	local _facUnitName = _args[1]
	local _unit = nil
	local _facUnit = fac.getFacUnit(_facUnitName)
	local _groupId = fac.getGroupId(_facUnit)
	local tgtMarkID = timer.getTime()*1000
	local recceMarkID = timer.getTime()*1000
	trigger.action.outTextForGroup(_groupId,"Processing Mark",10)
    if fac.facCurrentTargets[_facUnitName] ~= nil then
        _unit = Unit.getByName(fac.facCurrentTargets[_facUnitName].name)
		tempMarkID = tgtMarkID
		--fac.markID = tgtMarkID + 1
    elseif _args[2] ~= nil then 
		_unit = _args[2]
		tempMarkID = recceMarkID
		--fac.recceID = recceMarkID + 1
	else
		trigger.action.outTextForGroup(_groupId,"No Target to Mark",10)
	end
	if _unit ~=nil  and _unit:isActive() then
		local _vel = _unit:getVelocity()
		local _spd = 0
		if _vel ~=nil then
			_spd = math.sqrt(_vel.x^2+_vel.z^2)
		end
		local unitPos = _unit:getPoint()
		local _lat, _lon = coord.LOtoLL(_unit:getPosition().p)
		local _latLngStr = mist.tostringLL(_lat, _lon, 3, false)
		local _latLngSecStr = mist.tostringLL(_lat, _lon, 3, true)
		local _mgrsString = mist.tostringMGRS(coord.LLtoMGRS(coord.LOtoLL(_unit:getPosition().p)), 5)
		trigger.action.markToCoalition(tgtMarkID,_unit:getTypeName().. " - DMS: " .. _latLngSecStr .." Altitude: ".. math.floor(unitPos.y) .."m/" .. math.floor(unitPos.y*3.28084) .."ft".. "\nHeading: ".. math.floor(getHeading(_unit) * 180/math.pi) .. "\nSpeed: " .. math.floor(_spd*2)  .. " MPH" .."\nSpotted by: " .. fac.getFacName(_facUnitName), _unit:getPoint(), _facUnit:getCoalition(),false,fac.getFacName(_facUnitName).." marked a target")
		timer.scheduleFunction(removeSetMark,{tgtMarkID},timer.getTime() + 300)
	end 
end

function fac.setMarkerColor(_args)
	
	
	local _facUnitName  = _args[1]
	local _mkrType = _args[2]
	fac.cancelFacLase(_facUnitName)
	fac.setFacOnStation({_args[1],nil})
	fac.markerType[_facUnitName] = _mkrType
	fac.markerTypeColor[_facUnitName] = _args[3]
	fac.setMarkerType(_args)
	fac.setFacOnStation({_args[1],true})
end

function fac.setMarkerType(_args)
   local _facUnitName  = _args[1]
	local _mkrType = _args[2]
	
	local _facUnit = fac.getFacUnit(_facUnitName)
	local _groupId = fac.getGroupId(_facUnit)
	local colorString = { ["0"] = "GREEN" ,["1"] = "RED" ,["2"] = "WHITE", ["3"] = "ORANGE" ,["4"] = "BLUE"}
	local _mkrColor
    local _facUnit = Unit.getByName(_facUnitName)
	local side = _facUnit:getCoalition()
	
	if side == 1 then
		_mkrColor = fac.FAC_smokeColour_BLUE
	elseif side == 2 then
		_mkrColor = fac.FAC_smokeColour_RED
	else
		_mkrColor = 2
	end
	
	if _args[3]~=nil then 
		_mkrColor = _args[3]
		
	end
	
	if _facUnit == nil then
		--env.info('FAC DEBUG: fac.setFacLaserCode() _facUnit is null, aborting.')
		return
	end
	fac.markerTypeColor[_facUnitName] = _args[3]
	fac.markerType[_facUnitName] = _mkrType
	if fac.facOnStation[_facUnitName] == true then
		fac.notifyCoalition("[Forward Air Controller \"" .. fac.getFacName(_facUnitName) .. "\" on-station marking with: "..colorString[tostring(_mkrColor)].." "..fac.markerType[_facUnitName]..".]", 10, _facUnit:getCoalition())
	else
		trigger.action.outTextForGroup(_groupId,"Marker set to ".. colorString[tostring(_mkrColor)].." "..fac.markerType[_facUnitName],10)
	end
	--fac.setFacOnStation({ _facUnitName, nil})
	--fac.setFacOnStation( {_facUnitName, true})

	end

function fac.addFacRadioCommand(_side)

    local _players = coalition.getPlayers(_side)
    if _players ~= nil then

        for _, _playerUnit in pairs(_players) do

            local _groupId = fac.getGroupId(_playerUnit)

            if _groupId then
                --   env.info("adding command for "..index)
                if fac.facRadioAdded[tostring(_groupId)] == nil then
                    -- env.info("about command for "..index)
                    missionCommands.addCommandForGroup(_groupId, "FAC Status", nil, fac.getFacStatus, { _playerUnit:getName() })
					local _airstrikeMenu =  missionCommands.addSubMenuForGroup(_groupId, "Air OPS Menu")
						missionCommands.addCommandForGroup(_groupId, "Map Attack (Define on F10 Map with syntax: AttackAz CBRQT or TDRQT), CB for Carpet/TD for TALD", _airstrikeMenu , fac.carpetMapDesignate, {nil})
						missionCommands.addCommandForGroup(_groupId, "RECCE FLT (Define on F10 Map with syntax: RECCE)", _airstrikeMenu , fac.RECCEDesignate, {nil})
						--missionCommands.addCommandForGroup(_groupId, "TALD Strike (Define on F10 Map with syntax: AttackAz TDRQT)", _airstrikeMenu , fac.carpetMapDesignate, {nil})
					--local _cMissilePath = missionCommands.addSubMenuForGroup(_groupId, "Air Strike Menu",_airstrikeMenu)
                    fac.facRadioAdded[tostring(_groupId)] = true
                    -- env.info("Added command for " .. index)
                end
            end


        end
    end
end

function fac.setFacLaserCode(_args)
    local _facUnitName  = _args[1]
    local _laserCode = _args[2]
    local _facUnit = fac.getFacUnit(_facUnitName)
	--fac.setFacOnStation( {_facUnitName, nil})
	--fac.setFacOnStation( {_facUnitName, true})
    if _facUnit == nil then
        --env.info('FAC DEBUG: fac.setFacLaserCode() _facUnit is null, aborting.')
        return
    end

    fac.facLaserPointCodes[_facUnitName] = _laserCode

    if fac.facOnStation[_facUnitName] == true then
        fac.notifyCoalition("[Forward Air Controller \"" .. fac.getFacName(_facUnitName) .. "\" on-station using CODE: "..fac.facLaserPointCodes[_facUnitName]..".]", 10, _facUnit:getCoalition())
    end
end

function fac.setCustCode(_args)
	local _facUnitName = _args[1]
	local _facUnit = fac.getFacUnit(_facUnitName)
	if fac.facLaserPointCodes[_facUnitName] == nil then
		fac.facLaserPointCodes[_facUnitName] = "1688"
	end
	local tempCode = fac.facLaserPointCodes[_facUnitName]
	tempCode = fac.replace_char(_args[2],tempCode,_args[3])
	fac.facLaserPointCodes[_facUnitName] = tempCode
	fac.notifyCoalition("[Forward Air Controller \"" .. fac.getFacName(_facUnitName) .. "\" on-station using CODE: "..fac.facLaserPointCodes[_facUnitName]..".]", 10, _facUnit:getCoalition())
end

function fac.replace_char(pos, str, r)
    return str:sub(1, pos-1) .. r .. str:sub(pos+1)
end

function fac.setFacOnStation(_args)
    local _facUnitName  = _args[1]
    local _onStation = _args[2]
    local _facUnit = fac.getFacUnit(_facUnitName)
	local colorString = { ["0"] = "GREEN" ,["1"] = "RED" ,["2"] = "WHITE", ["3"] = "ORANGE" ,["4"] = "BLUE"}
	local _mkrColor = tostring(fac.markerTypeColor[_facUnitName])
    -- going on-station
    if _facUnit == nil then
        --env.info('FAC DEBUG: fac.setFacOnStation() _facUnit is null, aborting.')
        return
    end

    if fac.facLaserPointCodes[_facUnitName] == nil then
        -- set default laser code
        --env.info('FAC: ' .. _facUnitName .. ' no laser code, assigning default ' .. fac.FAC_laser_codes[1])
        fac.setFacLaserCode( {_facUnitName, fac.FAC_laser_codes[1]} )
    end

    -- going on-station from off-station
    if fac.facOnStation[_facUnitName] == nil and _onStation == true then
        env.info('FAC: ' .. _facUnitName .. ' going on-station')
		fac.cancelFacLase(_facUnitName)
		--fac.scanForTGToff({_facUnitName})
        fac.notifyCoalition("[Forward Air Controller \"" .. fac.getFacName(_facUnitName) .. "\" on-station using CODE: "..fac.facLaserPointCodes[_facUnitName]..".]", 10, _facUnit:getCoalition())
        fac.setFacLaserCode( {_facUnitName, fac.facLaserPointCodes[_facUnitName]} )
		
    end

    -- going off-station from on-station
    if fac.facOnStation[_facUnitName] == true and _onStation == nil then
        env.info('FAC: ' .. _facUnitName .. ' going off-station')
        fac.notifyCoalition("[Forward Air Controller \"" .. fac.getFacName(_facUnitName) .. "\" off-station.]", 10, _facUnit:getCoalition())
        fac.cancelFacLase(_facUnitName)
        fac.facUnits[_facUnitName] = nil
		--fac.scanForTGToff({_facUnitName})
    end

    fac.facOnStation[_facUnitName] = _onStation
end

--get distance in meters assuming a Flat world
function fac.getDistance(_point1, _point2)
    local xUnit = _point1.x
    local yUnit = _point1.z
    local xZone = _point2.x
    local yZone = _point2.z

    local xDiff = xUnit - xZone
    local yDiff = yUnit - yZone

    return math.sqrt(xDiff * xDiff + yDiff * yDiff)
end

function fac.notifyCoalition(_message, _displayFor, _side)
    trigger.action.outTextForCoalition(_side, _message, _displayFor)
    trigger.action.outSoundForCoalition(_side, "radiobeep.ogg")
end

-- Returns only alive units from group but the group / unit may not be active
function fac.getGroup(groupName)
    local _groupUnits = Group.getByName(groupName)

    local _filteredUnits = {} --contains alive units
    local _x = 1

    if _groupUnits ~= nil and _groupUnits:isExist() then

        _groupUnits = _groupUnits:getUnits()

        if _groupUnits ~= nil and #_groupUnits > 0 then
            for _x = 1, #_groupUnits do
                if _groupUnits[_x]:getLife() > 0  then -- removed and _groupUnits[_x]:isExist() as isExist doesnt work on single units!
                table.insert(_filteredUnits, _groupUnits[_x])
                end
            end
        end
    end

    return _filteredUnits
end

function fac.isInfantry(_unit)

    local _typeName = _unit:getTypeName()

    --type coerce tostring
    _typeName = string.lower(_typeName .. "")

    local _soldierType = { "infantry", "paratrooper", "stinger", "manpad", "mortar" }

    for _key, _value in pairs(_soldierType) do
        if string.match(_typeName, _value) then
            return true
        end
    end

    return false
end

function fac.isArty(_Aunit)
    
	local _typeName = _Aunit:getTypeName()

    -- --type coerce tostring
   -- _typeName = string.lower(_typeName .. "")
	 --trigger.action.outText( _typeName.." found",10)
    -- local _artyType = { "mrls", "sph", "mortar" }

    -- for _key, _value in pairs(_artyType) do
        -- if string.match(_typeName, _value) then
            -- return true
        -- end
    -- end
	--trigger.action.outText( _typeName.." found",10)
	
	if _Aunit:hasAttribute('Artillery') or _Aunit:hasAttribute('Strategic bombers') or _Aunit:hasAttribute('Cruisers') or _Aunit:hasAttribute('Frigates')  or _Aunit:hasAttribute('Corvettes') or _Aunit:hasAttribute('Landing Ships') then --or _Aunit:hasAttribute('MLRS') or  _Aunit:hasAttribute('Bombers') or _Aunit:hasAttribute('Multirole fighters')  then
		if _typeName == "Silkworm_SR" or _typeName  ==  "hy_launcher" then -- or _Aunit:hasAttribute('MLRS') then
			
			return false
		else
			--trigger.action.outText( _typeName.." found",10)
			return true
		end
	else
		return false
	end
end

function fac.isBomber(_Aunit)
    
	local _typeName = _Aunit:getTypeName()

    -- --type coerce tostring
   -- _typeName = string.lower(_typeName .. "")
	 --trigger.action.outText( _typeName.." found",10)
    -- local _artyType = { "mrls", "sph", "mortar" }

    -- for _key, _value in pairs(_artyType) do
        -- if string.match(_typeName, _value) then
            -- return true
        -- end
    -- end
	if _Aunit:hasAttribute('Strategic bombers') or  _Aunit:hasAttribute('Bombers') or _Aunit:hasAttribute('Multirole fighters')  then
		return true
	else
		return false
	end
end

-- assume anything that isnt soldier is vehicle
function fac.isVehicle(_unit)

    if fac.isInfantry(_unit) then
        return false
    end

    return true
end

-- copied from CTLD
function fac.getGroupId(_unit)

    local _unitDB =  mist.DBs.unitsById[tonumber(_unit:getID())]
	local _gID = _unit:getGroup():getID()
    if _unitDB ~= nil and _unitDB.groupId then
        return _unitDB.groupId
    elseif _gID ~= nil then 
		return _gID
	end

    return nil
end

function fac.createSmokeMarker(_enemyUnit, _colour,_facUnitName)

    --recreate in 5 mins
	if fac.markerType[_facUnitName] == "SMOKE" then
		fac.facSmokeMarks[_enemyUnit:getName()] = timer.getTime() + 300.0
	else
		fac.facSmokeMarks[_enemyUnit:getName()] = timer.getTime() + 2
	end

    -- move smoke 2 meters above target for ease
    local _enemyPoint = _enemyUnit:getPoint()
	if fac.markerType[_facUnitName] == "SMOKE" then
		trigger.action.smoke({ x = _enemyPoint.x, y = _enemyPoint.y + 2.0, z = _enemyPoint.z }, _colour)
	else
		trigger.action.signalFlare({ x = _enemyPoint.x, y = _enemyPoint.y + 2.0, z = _enemyPoint.z }, _colour,0)
	end
end

--fire mission control

-- function fac.checkArty(_side, _artyTable)
	-- --trigger.action.outText( "Found " ..#_artyTable.." arty units".._side,10)
	-- local _artyIDX = 1
	
	-- local _artyGroups = coalition.getGroups(_side, Group.Category.GROUND)
	
	-- if #_artyGroups == 0 then
		-- trigger.action.outText( "ERROR no Units",10)
		-- --_artyGroups = coalition.getGroups(_side, Group.Category.GROUND)
	-- elseif _artyGroups[1] == nil then
		-- trigger.action.outText( "ERROR ground returned Nil",10)
	-- end	
	
	-- for _artyIDX = 1, #_artyGroups do
		-- local _artyunits = _artyGroups[_artyIDX]:getUnits()
		-- if _artyunits[1] ~= nil then 
			-- if fac.isArty(_artyunits[1]) == true then 
				-- if contains(_artyTable,_artyGroups[_artyIDX]:getName()) == false then
					-- table.insert(_artyTable,_artyGroups[_artyIDX]:getName())
					-- --trigger.action.outText( "Found " ..#_artyTable.." arty units out of" ..#_artyGroups ,10)
				-- end
			-- end
		-- end
	-- end
-- end

function getHeading(unit)
	local unitpos = unit:getPosition()
	if unitpos then
		local Heading = math.atan2(unitpos.x.z, unitpos.x.x)
		Heading = Heading + getNorthCorrection(unitpos.p)
		
		if Heading < 0 then
			Heading = Heading + 2*math.pi  -- put heading in range of 0 to 2*pi
		end
		return Heading
	end
end

getNorthCorrection = function(point)  --gets the correction needed for true north
	if not point.z then --Vec2; convert to Vec3
		point.z = point.y
		point.y = 0
	end
	local lat, lon = coord.LOtoLL(point)
	local north_posit = coord.LLtoLO(lat + 1, lon)
	return math.atan2(north_posit.z - point.z, north_posit.x - point.x)
end


function fac.facOffsetMaker(_fac)
		local _facOffset = {}
	    local angle = getHeading(_fac)
		local xofs = math.cos(angle) * fac.facOffsetDist
        local yofs = math.sin(angle) * fac.facOffsetDist 
		local _facPoint = _fac:getPoint()
		_facOffset.x = _facPoint.x + xofs
		_facOffset.y = _facPoint.y
		_facOffset.z = _facPoint.z +yofs
		return _facOffset
end

function fac.getBomber(_mapPt,_col,_artyType)
	
	local _attackPoint = _mapPt
	
	local _i = 1
	local _j = 1
	local _k = 1
	--local _gndGroups =  {}
    local _tempPoint = nil
    local _tempDist = nil
    local _tempPosition = nil
	local _lastArty = {ammo = 0,  group = {}}
	local _chosenArty = nil
	local _tempArty = {}
	local _tempList = {}
	local _artyGroups = {} 
	local side = _col
	local lastAmmo = 0
	local tempFound = {}
	local _foundArty = {}
	
	local dist = {
		 id = world.VolumeType.SPHERE,
			params = {
			point = _attackPoint,
			radius = 4600000 --max range ARTY
			}
	 }

	local getArty = function(foundItem, val) -- generic search for all scenery
		local _checkArty = fac.isBomber(foundItem)
		local _tempArtyGroup = foundItem:getGroup()
		local _tGC = _tempArtyGroup:getController()
		if side == foundItem:getCoalition() and foundItem:getPlayerName() == nil then -- check for friendly and not a player
			if contains(tempFound,_tempArtyGroup:getName()) == false then --check for redundant groups
				if _checkArty == true then
					--trigger.action.outText(foundItem:getTypeName(),10)
					--if _tGC:hasTask() == false then -- check for tasked arty
					--if contains(fac.ArtyTasked,_tempArtyGroup:getName()) == false then -- check for tasked arty
					if fac.ArtyTasked[_tempArtyGroup:getName()] == nil then
							fac.ArtyTasked[_tempArtyGroup:getName()] = { name = _tempArtyGroup:getName(), tasked = 0, timeTasked = nil,tgt = nil}
					end
					--trigger.action.outText(_tempArtyGroup:getName() .. " " .. fac.ArtyTasked[_tempArtyGroup:getName()].tasked,10)
					if fac.ArtyTasked[_tempArtyGroup:getName()].tasked == 0 then
						_tempPoint = foundItem:getPoint()
						_tempDist = fac.getDistance(_tempPoint, _attackPoint)
					--foundItem

						--trigger.action.outText(_tempArtyGroup:getName() .. " " .. fac.ArtyTasked[_tempArtyGroup:getName()].tasked,10)
						local _type = Unit.getTypeName(foundItem)
						if fac.artyGetAmmo(_tempArtyGroup:getUnits()) > 0 and foundItem:isActive() == true then
						--trigger.action.outText(_tempDist.. " "..fac.ArtilleryProperties[_type].minrange .. " " .. fac.ArtilleryProperties[_type].maxrange,10)
							if foundItem:hasAttribute('Strategic bombers') or foundItem:hasAttribute('Bombers') or foundItem:hasAttribute('Multirole fighters')  then 
								--trigger.action.outText(foundItem:getTypeName().." "..fac.artyGetAmmo(_tempArtyGroup:getUnits()),10)
								table.insert(tempFound,_tempArtyGroup:getName())						
							end
						end
					end
				elseif  foundItem:getTypeName() == "USS_Arleigh_Burke_IIa" or foundItem:getTypeName() == "TICONDEROG" and _artyType == 4 then
					table.insert(tempFound,_tempArtyGroup:getName())
				end
			end
		end
	end
	
	
	world.searchObjects(Object.Category.UNIT,dist,getArty)
	
	if _artyType == 5 then 
		for _i = 1, #tempFound do
			if Group.getByName(tempFound[_i]):getUnit(1):hasAttribute('Strategic bombers') or Group.getByName(tempFound[_i]):getUnit(1):hasAttribute('Bombers') then 
		--trigger.action.outText(Group.getByName(tempFound[_i]):getUnit(1):getTypeName() .." ".._artyFilter,10)
				local payloadCheck = Group.getByName(tempFound[_i]):getUnit(1):getAmmo()
				if payloadCheck ~= nil then
					if payloadCheck[1].desc.guidance == 1 then 
						--trigger.action.outText(Group.getByName(tempFound[_i]):getUnit(1):getTypeName() .. " " .. payloadCheck[1].desc.guidance,10)
					else
						--trigger.action.outText(Group.getByName(tempFound[_i]):getUnit(1):getTypeName() .. " unguided bombs",10)
						table.insert(_foundArty,tempFound[_i])
					end
				end
			end
		end
	elseif _artyType == 4 then 
		for _i = 1, #tempFound do
		--trigger.action.outText(Group.getByName(tempFound[_i]):getUnit(1):getTypeName() .." ".._artyFilter,10)
			if Group.getByName(tempFound[_i]):getUnit(1):hasAttribute('Strategic bombers') or Group.getByName(tempFound[_i]):getUnit(1):hasAttribute('Bombers') or  Group.getByName(tempFound[_i]):getUnit(1):hasAttribute('Multirole fighters') then 

				local payloadCheck = Group.getByName(tempFound[_i]):getUnit(1):getAmmo()
				if payloadCheck ~= nil then 
					if payloadCheck[1].desc.guidance == 1 then
						table.insert(_foundArty,tempFound[_i])
						--trigger.action.outText(Group.getByName(tempFound[_i]):getUnit(1):getTypeName() .. " " .. payloadCheck[1].desc.guidance,10)
					else
						--trigger.action.outText(Group.getByName(tempFound[_i]):getUnit(1):getTypeName() .. " unguided bombs",10)
						
					end
				end
			elseif Unit.getByName(tempFound[_i]):getTypeName() == "USS_Arleigh_Burke_IIa" or  Unit.getByName(tempFound[_i]):getTypeName() == "TICONDEROG" then
				--trigger.action.outText( Unit.getByName(tempFound[_i]):getTypeName() .." Found",10)
				if fac.artyGetGuidedAmmo(Group.getByName(tempFound[_i]):getUnits()) > 0 then 
					table.insert(_foundArty,tempFound[_i])
				end
			end
		end
	elseif _artyType == 3 then 
		for _i = 1, #tempFound do
		--trigger.action.outText(Group.getByName(tempFound[_i]):getUnit(1):getTypeName() .." ".._artyFilter,10)
			if  Group.getByName(tempFound[_i]):getUnit(1):hasAttribute('Multirole fighters') then 
				local payloadCheck = Group.getByName(tempFound[_i]):getUnit(1):getAmmo()
				if payloadCheck ~= nil then
					for _k = 1,#payloadCheck do 
						--trigger.action.outText(payloadCheck[_k].desc.typeName,10)
						if payloadCheck[_k].desc.typeName == "weapons.missiles.ADM_141A" then
							table.insert(_foundArty,tempFound[_i])
							--trigger.action.outText(Group.getByName(tempFound[_i]):getUnit(1):getTypeName() .. " " .. payloadCheck[1].desc.guidance,10)
						else
							--trigger.action.outText(Group.getByName(tempFound[_i]):getUnit(1):getTypeName() .. " unguided bombs",10)
							
						end
					end
				end
			end
		end
	else 
		_foundArty = tempFound
	end
	 
	

	for _j = 1, #_foundArty do -- find arty with most ammo
		--trigger.action.outText(_foundArty[_j] .. " unguided bombs",10)
		--trigger.action.outText(#Group.getByName(_foundArty[_j]):getUnits().. " unguided bombs",10)
		
		local curAmmo = fac.artyGetAmmo(Group.getByName(_foundArty[_j]):getUnits())
		if curAmmo > lastAmmo then
			_chosenArty = _foundArty[_j]
		end
	end
	

	if _chosenArty ~=nil then
		--trigger.action.outText(_chosenArty,10)
		return Group.getByName(_chosenArty)
		-- if retask == true then
			-- trigger.action.outTextForCoalition(side,fac.getFacName(_fac:getName()) .. " is re-tasking ".. _chosenArty .. "(".. Group.getByName(tempFound[_j]):getUnit(1) ..") to a new target",10)
		-- end
		
	else
		return nil
	end


end

function fac.getArty(_enemyUnit,_fac,_artyType)
	local _attackPoint = {}
	if _enemyUnit == nil then
		_attackPoint = fac.facOffsetMaker(_fac)
	else
		_attackPoint = _enemyUnit:getPoint()
	end
	local _i = 1
	local _j = 1
	--local _gndGroups =  {}
    local _tempPoint = nil
    local _tempDist = nil
    local _tempPosition = nil
	local _lastArty = {ammo = 0,  group = {}}
	local _chosenArty = nil
	local _tempArty = {}
	local _tempList = {}
	local _artyGroups = {} 
	local side = _fac:getCoalition()
	local lastAmmo = 0
	
	-- if overide == 2 then
		-- local retask = true
		-- --trigger.action.outText("retask",10)
	-- else 
		-- local retask = false
	-- end
	-- finds all avaliable arty and chooses any untasked arty for firemission
	
	-- NEW arty check
	local dist = {
		 id = world.VolumeType.SPHERE,
			params = {
			point = _attackPoint,
			radius = 4600000 --max range ARTY
			}
	 }
	local tempFound = {}
	local _foundArty = {}
	
	local getArty = function(foundItem, val) -- generic search for all scenery
	
		--trigger.action.outTextForCoalition(side,foundItem:getTypeName() .. " found1 ",10)
		if side == foundItem:getCoalition() and foundItem:isActive() == true and foundItem:getPlayerName() == nil then -- check for friendly and not a player
			local _checkArty = fac.isArty(foundItem)
			local _tempArtyGroup = foundItem:getGroup()
			local _tGC = _tempArtyGroup:getController()
			--trigger.action.outText(_tempArtyGroup:getName() .. " found ",10)
			--trigger.action.outTextForCoalition(side,foundItem:getTypeName() .. " found1 ",10)
			if contains(tempFound,_tempArtyGroup:getName()) == false  then --check for redundant groups
				--trigger.action.outTextForCoalition(side,foundItem:getTypeName() .. " found2 ",10)
				if _checkArty == true then
					--trigger.action.outTextForCoalition(side,foundItem:getTypeName() .. " found3 ",10)
					--trigger.action.outText(foundItem:getTypeName(),10)
					--if _tGC:hasTask() == false then -- check for tasked arty
					--if contains(fac.ArtyTasked,_tempArtyGroup:getName()) == false then -- check for tasked arty
					if fac.ArtyTasked[_tempArtyGroup:getName()] == nil then
							fac.ArtyTasked[_tempArtyGroup:getName()] = { name = _tempArtyGroup:getName(), tasked = 0, timeTasked = nil,tgt = nil, requestor = nil}
					end
					--trigger.action.outText(_tempArtyGroup:getName() .. " " .. fac.ArtyTasked[_tempArtyGroup:getName()].tasked,10)
					if fac.ArtyTasked[_tempArtyGroup:getName()].tasked == 0 then
						_tempPoint = foundItem:getPoint()
						_tempDist = fac.getDistance(_tempPoint, _attackPoint)
					--foundItem

						--trigger.action.outText(_tempArtyGroup:getName() .. " " .. fac.ArtyTasked[_tempArtyGroup:getName()].requestor,10)
						local _type = Unit.getTypeName(foundItem)
						if fac.artyGetAmmo(_tempArtyGroup:getUnits()) > 0 and foundItem:isActive() == true then
						--trigger.action.outText(_tempDist.. " "..fac.ArtilleryProperties[_type].minrange .. " " .. fac.ArtilleryProperties[_type].maxrange,10)
							if foundItem:hasAttribute('Strategic bombers') or foundItem:hasAttribute('Bombers') then 
								--trigger.action.outText(foundItem:getTypeName().." "..fac.artyGetAmmo(_tempArtyGroup:getUnits()),10)
								table.insert(tempFound,_tempArtyGroup:getName())
							elseif foundItem:hasAttribute('Naval') then
								if _artyType == 4 then 
									if foundItem:getTypeName() == "USS_Arleigh_Burke_IIa" or foundItem:getTypeName() == "TICONDEROG" then 
										table.insert(tempFound,_tempArtyGroup:getName())
									end
								else
									local gunStats = {}
									gunStats = fac.artyGetNavalGunAmmo(_tempArtyGroup:getUnits())
									--trigger.action.outText(foundItem:getTypeName().." "..gunStats[2],10)
									if gunStats[2] >= _tempDist then
										table.insert(tempFound,_tempArtyGroup:getName())
									end
								end
							elseif (_tempDist > fac.ArtilleryProperties[_type].minrange and _tempDist < fac.ArtilleryProperties[_type].maxrange)  then --check if in arty params
								--trigger.action.outText(foundItem:getTypeName().." "..fac.artyGetAmmo(_tempArtyGroup:getUnits()),10)
							 -- check for ammo and if arty is active
								--if foundItem:getLife() > 1 then 
								table.insert(tempFound,_tempArtyGroup:getName())
								
								--end
							end
						end
					elseif fac.ArtyTasked[_tempArtyGroup:getName()].requestor == "AI Spotter" and _artyType ~= -1 then
						_tempPoint = foundItem:getPoint()
						_tempDist = fac.getDistance(_tempPoint, _attackPoint)
					--foundItem
						--trigger.action.outText(_tempArtyGroup:getName() .. " " .. fac.ArtyTasked[_tempArtyGroup:getName()].requestor,10)
						--trigger.action.outText(_tempArtyGroup:getName() .. " " .. fac.ArtyTasked[_tempArtyGroup:getName()].tasked,10)
						local _type = Unit.getTypeName(foundItem)
						if fac.artyGetAmmo(_tempArtyGroup:getUnits()) > 0 and foundItem:isActive() == true then
						trigger.action.outText(_tempDist.. " "..fac.ArtilleryProperties[_type].minrange .. " " .. fac.ArtilleryProperties[_type].maxrange,10)
							if foundItem:hasAttribute('Strategic bombers') or foundItem:hasAttribute('Bombers') then 
								--trigger.action.outText(foundItem:getTypeName().." "..fac.artyGetAmmo(_tempArtyGroup:getUnits()),10)
								table.insert(tempFound,_tempArtyGroup:getName())
							elseif (_tempDist > fac.ArtilleryProperties[_type].minrange and _tempDist < fac.ArtilleryProperties[_type].maxrange)  then --check if in arty params
								--trigger.action.outText(foundItem:getTypeName().." "..fac.artyGetAmmo(_tempArtyGroup:getUnits()),10)
							 -- check for ammo and if arty is active
								--if foundItem:getLife() > 1 then 
								table.insert(tempFound,_tempArtyGroup:getName())
								
								--end
							end
						end										
					end
				end
			end
		end
	end
	
	world.searchObjects(Object.Category.UNIT,dist,getArty)
	
	--trigger.action.outTextForCoalition(side,#tempFound .. " found ",10)
	
	
	local _artyFilter = "2B11 mortar"
	if _artyType == 2 then
		--trigger.action.outText(Group.getByName(tempFound[_i]):getUnit(1):getTypeName().. " ".._artyFilter,10)
		for _i = 1, #tempFound do
			if Group.getByName(tempFound[_i]):getUnit(1):getTypeName() == _artyFilter then 
				table.insert(_foundArty,tempFound[_i])
			end
		end
	elseif _artyType == 3 then 
		for _i = 1, #tempFound do
		--trigger.action.outText(Group.getByName(tempFound[_i]):getUnit(1):getTypeName() .." ".._artyFilter,10)
			if Group.getByName(tempFound[_i]):getUnit(1):getTypeName() ~= _artyFilter and (not  Group.getByName(tempFound[_i]):getUnit(1):hasAttribute('MissilesSS')) then 
				local payloadCheck = Group.getByName(tempFound[_i]):getUnit(1):getAmmo()
				if payloadCheck[1].desc.guidance ~= nil then 
					--trigger.action.outText(Group.getByName(tempFound[_i]):getUnit(1):getTypeName() .. " " .. payloadCheck[1].desc.guidance,10)
				else
					--trigger.action.outText(Group.getByName(tempFound[_i]):getUnit(1):getTypeName() .. " unguided bombs",10)
					table.insert(_foundArty,tempFound[_i])
				end
			end
		end
	elseif _artyType == 5 then 
		for _i = 1, #tempFound do
			if Group.getByName(tempFound[_i]):getUnit(1):hasAttribute('Strategic bombers') or Group.getByName(tempFound[_i]):getUnit(1):hasAttribute('Bombers') then 
		--trigger.action.outText(Group.getByName(tempFound[_i]):getUnit(1):getTypeName() .." ".._artyFilter,10)
				local payloadCheck = Group.getByName(tempFound[_i]):getUnit(1):getAmmo()
				if payloadCheck[1].desc.guidance == 1 then 
					--trigger.action.outText(Group.getByName(tempFound[_i]):getUnit(1):getTypeName() .. " " .. payloadCheck[1].desc.guidance,10)
				else
					--trigger.action.outText(Group.getByName(tempFound[_i]):getUnit(1):getTypeName() .. " unguided bombs",10)
					table.insert(_foundArty,tempFound[_i])
				end
			end
		end
	elseif _artyType == 4 then 
		for _i = 1, #tempFound do
		--trigger.action.outText(Group.getByName(tempFound[_i]):getUnit(1):getTypeName() .." ".._artyFilter,10)
			if Group.getByName(tempFound[_i]):getUnit(1):hasAttribute('Strategic bombers') or Group.getByName(tempFound[_i]):getUnit(1):hasAttribute('Bombers') then 
				local payloadCheck = Group.getByName(tempFound[_i]):getUnit(1):getAmmo()
				if payloadCheck[1].desc.guidance == 1 then
					table.insert(_foundArty,tempFound[_i])
					--trigger.action.outText(Group.getByName(tempFound[_i]):getUnit(1):getTypeName() .. " " .. payloadCheck[1].desc.guidance,10)
				else
					--trigger.action.outText(Group.getByName(tempFound[_i]):getUnit(1):getTypeName() .. " unguided bombs",10)
					
				end
			elseif Group.getByName(tempFound[_i]):getUnit(1):hasAttribute('Naval') then
				table.insert(_foundArty,tempFound[_i])
			end
		end
	elseif _artyType == -1 then 
		for _i = 1, #tempFound do
			if Group.getByName(tempFound[_i]):getUnit(1):hasAttribute('Strategic bombers') == false or Group.getByName(tempFound[_i]):getUnit(1):hasAttribute('Bombers') == false then 
					--local payloadCheck = Group.getByName(tempFound[_i]):getUnit(1):getAmmo()
					--if payloadCheck[1].desc.guidance == 1 then
						table.insert(_foundArty,tempFound[_i])
			end
		end
	else 
		_foundArty = tempFound
	end
	
	

	for _j = 1, #_foundArty do -- find arty with most ammo
		--trigger.action.outText(_foundArty[_j] .. " unguided bombs",10)
		--trigger.action.outText(#Group.getByName(_foundArty[_j]):getUnits().. " unguided bombs",10)
		
		local curAmmo = fac.artyGetAmmo(Group.getByName(_foundArty[_j]):getUnits())
		if curAmmo > lastAmmo then
			_chosenArty = _foundArty[_j]
		end
	end
	

	if _chosenArty ~=nil then
		return Group.getByName(_chosenArty)
		-- if retask == true then
			-- trigger.action.outTextForCoalition(side,fac.getFacName(_fac:getName()) .. " is re-tasking ".. _chosenArty .. "(".. Group.getByName(tempFound[_j]):getUnit(1) ..") to a new target",10)
		-- end
		
	else
		return nil
	end
		
end

function fac.artyGetAmmo(_units)
	local BatteryAmmo = 0 
	local n
	for n = 1, #_units do														--Iterate through all units of the battery
			--if _units[n]:getTypeName() == groupType then								--Check if a unit is of the same type as the battery
				local ammo = _units[n]:getAmmo()										--Get ammo for this unit
				if ammo ~= nil then 
					if ammo[1] then														--Check if ammo[1] exists. If the ammo is used up, it returns nil...
						local UnitAmmo = ammo[1].count									--Get the shell count for this unit
						--if UnitAmmo > minAmmo then										--Check if there is ready ammo left
							local UnitReadyAmmo = UnitAmmo
							BatteryAmmo = BatteryAmmo + UnitReadyAmmo					--Add unit ready ammo to total of group
						--end
					end
				end
			--end
	end
	return BatteryAmmo
end

function fac.artyGetNavalGunAmmo(_units)
	local BatteryAmmo = 0 
	local n
	local i
	local MaxRange = 0
	local tempMaxRange = 0
	for n = 1, #_units do														--Iterate through all units of the battery
			--if _units[n]:getTypeName() == groupType then								--Check if a unit is of the same type as the battery
				local ammo = _units[n]:getAmmo()										--Get ammo for this unit
				if ammo ~= nil then 
					for i = 1, #ammo do 
						if ammo[i] then														--Check if ammo[1] exists. If the ammo is used up, it returns nil...
							if ammo[i].desc.warhead.caliber >=75 and ammo[i].desc.category == 0 then 
								local UnitAmmo = ammo[i].count									--Get the shell count for this unit
								--if UnitAmmo > minAmmo then										--Check if there is ready ammo left
									local UnitReadyAmmo = UnitAmmo
									BatteryAmmo = BatteryAmmo + UnitReadyAmmo					--Add unit ready ammo to total of group
								if ammo[i].desc.warhead.caliber >= 120 then 
									tempMaxRange = 	22222
									if tempMaxRange > MaxRange then 
										MaxRange = tempMaxRange
									end
								else
									tempMaxRange = 	18000
									if tempMaxRange > MaxRange then 
										MaxRange = tempMaxRange
									end
								end
							end
						end
					end
				end
			--end
	end
	
	return {BatteryAmmo, MaxRange}
end

function fac.artyGetGuidedAmmo(_units)
	local BatteryAmmo = 0 
	local n
	local i
	for n = 1, #_units do														--Iterate through all units of the battery
			--if _units[n]:getTypeName() == groupType then								--Check if a unit is of the same type as the battery
				local ammo = _units[n]:getAmmo()										--Get ammo for this unit
				if ammo ~= nil then 
					for i = 1, #ammo do 
						if ammo[i].desc.guidance == 1 then														--Check if ammo[1] exists. If the ammo is used up, it returns nil...
							if ammo[i].desc.category == 1 then 
								if  ammo[i].desc.missileCategory == 5 then 
									local UnitAmmo = ammo[i].count									--Get the shell count for this unit
								--if UnitAmmo > minAmmo then										--Check if there is ready ammo left
									local UnitReadyAmmo = UnitAmmo
									BatteryAmmo = BatteryAmmo + UnitReadyAmmo					--Add unit ready ammo to total of group
								end
							else
									local UnitAmmo = ammo[i].count									--Get the shell count for this unit
								--if UnitAmmo > minAmmo then										--Check if there is ready ammo left
									local UnitReadyAmmo = UnitAmmo
									BatteryAmmo = BatteryAmmo + UnitReadyAmmo					--Add unit ready ammo to total of group

							end
						end
					end
				end
			--end
	end
	
	return BatteryAmmo
end



function fac.purgeArtList(_args)
	-- local element = fac.ArtyTasked[_args[1]]
	-- local tempTbl = {} 
	--local I = 1
	-- fac.ArtyTasked[_args[1]] = nil
	
	-- for I = 1, #fac.ArtyTasked do
        -- if(fac.ArtyTasked[I] ~= nil) then
            -- table.insert(tempTbl, fac.ArtyTasked[I])
        -- end
    -- end
	-- fac.ArtyTasked = {}
	-- trigger.action.outText("clear" .. #fac.ArtyTasked,10)
	-- fac.ArtyTasked = tempTbl
	-- trigger.action.outText(_args[1].."clearing " .. #fac.ArtyTasked,10)
	-- local test, outIdx = contains(fac.ArtyTasked,_args[1])
		-- trigger.action.outText(_args[1].."clearing " .. fac.ArtyTasked[outIdx],10)
		-- if test == true and fac.ArtyTasked[outIdx] == _args[1] then 
			-- table.remove(fac.ArtyTasked,outIdx)
			-- trigger.action.outText(_args[1].." cleared " .. #fac.ArtyTasked,10)
		-- elseif test == true and fac.ArtyTasked[outIdx] ~= _args[1] then 
			-- trigger.action.outText(" error clearing ".._args[1],10)
			-- for I = 1, #fac.ArtyTasked do
				-- if fac.ArtyTasked[I] ~= nil then
					-- trigger.action.outText(I .. " ".. fac.ArtyTasked[I],10)
				-- end
			-- end
			-- fac.purgeArtList(_args[1])
		-- end
	--table.remove(fac.ArtyTasked)
	
	local curTime = timer.getTime()
	--trigger.action.outText(curTime .. " " .. fac.ArtyTasked[_args[1]].timeTasked,5)
	if  Group.getByName(_args[1]):getCategory() >= 2 then
		if fac.ArtyTasked[_args[1]].timeTasked ~= nil then 
			if fac.ArtyTasked[_args[1]].tasked == _args[2] then 
				fac.ArtyTasked[_args[1]].tasked = 0
				fac.ArtyTasked[_args[1]].tgt = nil
				fac.ArtyTasked[_args[1]].timeTasked = nil
				local leaderType = Group.getByName(_args[1]):getUnit(1):getDesc()
				trigger.action.outTextForCoalition(Group.getByName(_args[1]):getCoalition(),leaderType.displayName .. " time out, canceling tasking ",0.5)
				Group.getByName(_args[1]):getController():popTask()
			elseif 	fac.artyGetAmmo(Group.getByName(_args[1]):getUnits()) < fac.ArtyTasked[_args[1]].tasked then 
				fac.ArtyTasked[_args[1]].tasked = 0
				fac.ArtyTasked[_args[1]].tgt = nil
				fac.ArtyTasked[_args[1]].timeTasked = nil
				local leaderType = Group.getByName(_args[1]):getUnit(1):getDesc()
				trigger.action.outTextForCoalition(Group.getByName(_args[1]):getCoalition(),leaderType.displayName .. " insufficent ammo, canceling tasking ",0.5)
				Group.getByName(_args[1]):getController():popTask()
			end
		end
	end
end


function fac.tgtCatType(target)
	--trigger.action.outText("Assessing Type "..target:getName(), 15)
	--local _TGT_Type = Group.getByName(target:getName()):getCategory()
	local _TGT_Type = target:getCategory()
	--trigger.action.outText(_TGT_Type, 15)
	
	if _TGT_Type == 3 then	
		--trigger.action.outText("TGT is Static Object", 15)
		return "Static"
	elseif _TGT_Type == 1 then
		--local _leadUnit = Group.getByName(target):getUnit(1)
		local _unitType = target:getCategory()
		--trigger.action.outText("TGT is Unit Object " .. _unitType, 15)
		return "Unit"
	end
		--end

end

function removeSetMark(_args)
	trigger.action.removeMark(_args[1])
end

function fac.recceDetect(_args)
	local _facUnitName = _args[1]
	local _unit = nil
	fac.facManTGT[_args[1]] = {}
	local recceUnit = fac.getFacUnit(_facUnitName)
	local recceSide = recceUnit:getCoalition()
	local reccePos = recceUnit:getPoint()
	local _groupId = fac.getGroupId(recceUnit)
	local tempFound = {}
	
	local dist = {
		 id = world.VolumeType.SPHERE,
			params = {
			 point = reccePos,
			 radius = 40000
			}
	 }

	--trigger.action.outText("FINDING STUFF", 15)
	--remove old Marks
	local _i
	--local recceMarkID = timer.getTime() * 1000
	--for _i = 5000, fac.recceID do
		--trigger.action.removeMark(_i)
	--end
	local count = 0
	local recceMarkTagets = function(foundItem, val) -- generic search for all scenery
		local foundOutput = nil
		local foundObjectPos = nil
		local sideCheck = foundItem:getCoalition()
		count = count + 1
		if foundItem:getLife() >= 1  then
			if sideCheck ~= recceSide then
				_unit = foundItem
				local _unitPos = _unit:getPoint()
				local _offsetEnemyPos = { x = _unitPos.x, y = _unitPos.y + 2.0, z = _unitPos.z }
				local _offsetFacPos = { x = reccePos.x, y = reccePos.y + 2.0, z = reccePos.z }
				--trigger.action.outText("FOUND STUFF ".. foundItem:getLife(), 15)
				local _type = fac.tgtCatType(foundItem)
				
				if  land.isVisible(_offsetEnemyPos, _offsetFacPos) then
					if  _type == "Static" or _unit:isActive()  then
						local recceMarkID = timer.getTime() * 1000 + count
						
						--trigger.action.outText("FOUND STUFF "..  _unit:getTypeName() .. recceMarkID .." "..fID, 15)
						local _vel = _unit:getVelocity()
						local _spd = 0
						if _vel ~=nil then
							_spd = math.sqrt(_vel.x^2+_vel.z^2)
						end
						local unitPos = _unit:getPosition()
						local head = math.atan2(unitPos.x.z, unitPos.x.x)
						local _unitPos = _unit:getPosition().p
						--trigger.action.outText("FOUND STUFF ".. _unitPos.z, 15)
						if _unit:getTypeName() == "outpost_road" then
							_unitPos.x = _unitPos.x + math.cos(head+math.pi/2)*18
							_unitPos.z = _unitPos.z + math.sin(head+math.pi/2)*18
						end
						
						local _lat, _lon = coord.LOtoLL(_unitPos)

						local _latLngStr = mist.tostringLL(_lat, _lon, 3, false)
						local _latLngSecStr = mist.tostringLL(_lat, _lon, 3, true)
						local _mgrsString = mist.tostringMGRS(coord.LLtoMGRS(coord.LOtoLL(_unit:getPosition().p)), 5)
						--timer.scheduleFunction(fac.msgDraw, {_unit,recceSide,_facUnitName},timer.getTime() + 0.1)
						trigger.action.markToCoalition(recceMarkID,_unit:getTypeName() .." - DMS: " .. _latLngSecStr .." Altitude: ".. math.floor(_unitPos.y) .."m/" .. math.floor(_unitPos.y*3.28084) .."ft" .. "\nHeading: ".. math.floor(getHeading(_unit) * 180/math.pi) .. "\nSpeed: " .. math.floor(_spd*2)  .. " MPH" .."\nSpotted by: " .. fac.getFacName(_facUnitName), _unitPos, recceSide, false,"")
						timer.scheduleFunction(removeSetMark,{recceMarkID},timer.getTime() + 300)
						table.insert(tempFound,_unit)
						fac.recceID = recceMarkID +1
					end
				end
			end
		end	
	end
	world.searchObjects(1,dist,recceMarkTagets)
	--world.searchObjects(Group.Category.GROUND,dist,recceMarkTagets)
	count = 0
	world.searchObjects(3,dist,recceMarkTagets)
	--timer.scheduleFunction(fac.recceDetect, {_args,true}, timer.getTime() + 180)
	fac.facManTGT[_args[1]] = tempFound
end

function fac.stratStrike(_args)
	local i = 0
	local _tgtList = fac.facManTGT[_args[1]]
	--local roundsExpended = fac.callFireMissionMulti({_args[1],1,4,_tgtList})
	
	local roundsExpended = 1
	--trigger.action.outText("FOUND STUFF "..#_tgtList .. " " .. roundsExpended, 30)
	while roundsExpended ~= nil do
		local tempList = {}
		for i = roundsExpended+1, #_tgtList do
			table.insert(tempList,_tgtList[i])
		end
		_tgtList = {}
		_tgtList = tempList
		--trigger.action.outText(i .. " Targeting "..#_tgtList .. " " .. roundsExpended , 30)
		if #_tgtList >0 then 
			roundsExpended = fac.callFireMissionMulti({_args[1],1,4,_tgtList})
		else
			roundsExpended = nil
		end
	end

end

function fac.multiStrike(_args)
	local i = 0
	local _tgtList = fac.facManTGT[_args[1]]
	--local roundsExpended = fac.callFireMissionMulti({_args[1],1,4,_tgtList})
	local roundsExpended = 1
	--trigger.action.outText("FOUND STUFF "..#_tgtList .. " " .. roundsExpended, 30)
	for i = 1, #_tgtList do
		if _tgtList[i]:isExist() then
			fac.callFireMission({_args[1],10,0,_tgtList[i]})
		end
	end
end


function fac.msgDraw(_args)
	local _unit = _args[1]
	local recceSide = _args[2]
	local _facUnitName = _args[3]
	local recceMarkID = timer.getTime() * 1000
	local _unitPos = _unit:getPoint()
	local _vel = _unit:getVelocity()
	local _spd = 0
	if _vel ~=nil then
		_spd = math.sqrt(_vel.x^2+_vel.z^2)
	end
			--local unitPos = _unit:getPoint()
	local _lat, _lon = coord.LOtoLL(_unit:getPosition().p)
	local _latLngStr = mist.tostringLL(_lat, _lon, 3, false)
	local _latLngSecStr = mist.tostringLL(_lat, _lon, 3, true)
	local _mgrsString = mist.tostringMGRS(coord.LLtoMGRS(coord.LOtoLL(_unit:getPosition().p)), 5)
	trigger.action.outText("Trying to draw mark ".. curMark, 15)
	trigger.action.markToCoalition(recceMarkID,_unit:getTypeName() .." - DMS: " .. _latLngSecStr .." Altitude: ".. math.floor(_unitPos.y) .."m/" .. math.floor(_unitPos.y*3.28084) .."ft" .. "\nHeading: ".. math.floor(getHeading(_unit) * 180/math.pi) .. "\nSpeed: " .. math.floor(_spd*2)  .. " MPH" .."\nSpotted by: " .. fac.getFacName(_facUnitName), _unitPos, recceSide, false,"")
	timer.scheduleFunction(removeSetMark,{recceMarkID},timer.getTime() + 180)
	--timer.scheduleFunction(awacs.removeSetMark,{facMarkID,_args[2]:getUnit(1):getName()},timer.getTime() + awacs.setAWACSscanRate [_args[3]]-.25)
	--awacs.trackID = AWACSMarkID +1
	return
end
function fac.callFireMissionMulti(_args)
	local _facUnitName = _args[1]
	local _tgtList
	--trigger.action.outText("FOUND STUFF "..#_args[4], 15)
	local _facUnit = Unit.getByName(_facUnitName)
	if _args[4] == nil then 
		 _tgtList = fac.facManTGT[_args[1]]
	else
		 _tgtList = _args[4]
	end
	
	local _artyRounds = _args[2] 
	local _roundType = _args[3]
	local _groupId = fac.getGroupId(_facUnit)
	local _artyInRange = nil
	local _artyPos = {}
	local comboShoot = {}
	local comboTasker = {}
	local tp
	local _i
	if _tgtList == nil then
		trigger.action.outTextForGroup(_groupId,"Unable to process fire mission",10)
		trigger.action.outTextForGroup(_groupId,"No Valid Target, please create target list with manual scan",10)
		return nil
	end
	for _i = 1, #_tgtList do
		if _tgtList[_i]:isExist() then 
			_artyInRange = fac.getArty(_tgtList[_i],_facUnit,_roundType)
			--if _artyInRange ~=nil then
				--_artyPos = _artyInRange:getUnit(1):getPoint()
			--else
				--return
			--end
		else
			trigger.action.outTextForGroup(_groupId,"Invalid target detected, please rescan for more current target list with manual scan",10)
			return 
		end
		
		if _tgtList[_i] == nil  or _artyInRange == nil then
			if _tgtList[_i] == nil and _artyInRange ~= nil then
				trigger.action.outTextForGroup(_groupId,"Unable to process fire mission",10)
				trigger.action.outTextForGroup(_groupId,"No Valid Target",10)
				return nil
			elseif _artyInRange == nil then
				trigger.action.outTextForGroup(_groupId,"Unable to process fire mission",10)
				trigger.action.outTextForGroup(_groupId,"No untasked active artillery/bomber in range of target",10)
				return nil
			else
				_artyPos = _artyInRange:getUnit(1):getPoint()
			end
		else
			tp = _tgtList[_i]:getPoint()
			local firepoint = {}
			firepoint.x = tp.x --+ _fireOffset.x
			firepoint.y = tp.z --+ _fireOffset.z
			--firepoint.radius = 10
			firepoint.expend = "One"	
			--firepoint.attackQty = 1
			firepoint.attackQty = 1
			firepoint.altitude = _artyPos.y
			firepoint.altitudeEnabled = true
			firepoint.weaponType = 268402702 
			--firepoint.expendQty = _artyRounds
			--firepoint.expendQtyEnabled = true
			local firemission = {id = 'Bombing', params = firepoint}
			if _artyInRange:getUnit(1):hasAttribute('Naval') then
				firepoint.expendQty = 1
				firepoint.expendQtyEnabled = true
				firemission = {id = 'FireAtPoint', params = firepoint}
			end
			--_artyInRange:getController():pushTask(firemission)
			
			if (fac.artyGetGuidedAmmo(_artyInRange:getUnits())-_i) >= 0 then
				--trigger.action.outTextForGroup(_groupId,"Target processed " .. _tgtList[_i]:getTypeName(),10)
				table.insert (comboTasker,firemission)
			end
			-- timer.scheduleFunction(fac.launchMulti,{_artyInRange:getController(),firemission},timer.getTime()+ 45)
			
		end
		--tasks = { _i = 
		
	end
	comboShoot = {id = 'ComboTask', params = {tasks = comboTasker}}
	_artyInRange:getController():setOption(1,1)
	_artyInRange:getController():pushTask(comboShoot)
	_artyInRange:getController():setOption(10,3221225470)
	--if fac.ArtyTasked[_artyInRange:getName()] == nil  or fac.ArtyTasked[_artyInRange:getName()].tasked == 0 then 
					--table.insert (fac.ArtyTasked, _artyInRange:getName())
					--fac.ArtyTasked[_artyInRange:getName()]
	fac.ArtyTasked[_artyInRange:getName()]= {name = _artyInRange:getName(), tasked = #comboTasker,timeTasked = nil}
		--timer.scheduleFunction(fac.purgeArtList,{_artyInRange:getName()},timer.getTime()+ 45*#_tgtList)
	--end
	--timer.scheduleFunction(fac.clearTask,{_artyInRange:getController(),#_tgtList},timer.getTime()+ 20*#_tgtList)
	trigger.action.outTextForCoalition(_facUnit:getCoalition(),"Fire mission order sent, " .._artyInRange:getUnit(1):getTypeName() .. " ("..fac.artyGetGuidedAmmo(_artyInRange:getUnits())-#comboTasker .. " rounds remaining"..") firing ".._artyRounds.." rounds at " .. #comboTasker .. " target(s). Requestor: " .. fac.getFacName(_facUnitName) ,10)
	return fac.artyGetGuidedAmmo(_artyInRange:getUnits())
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function CrptBmbDesig:onEvent(e)
	local t ={}
	local pwdCheckList = {}
	local tgtHead
	local i
	local j
	--local str
	if e.id == 26 then
		if string.find(e.text, "CBRQT") or string.find(e.text, "TDRQT") then

			--trigger.action.outText(e.initiator:getName() .. " " .. e.groupID, 25) 
			
			--local pwdCheckList =world.getMarkPanels()
			
			for i in string.gmatch(e.text, "%S+") do
				table.insert(t, i)
			end
			
			--trigger.action.outText(pwdCheckList[1].groupID..e.coalition, 25) 
			if string.find(e.text, "CBRQT") then 
				fac.carpetMapExecute({e.pos,t[1],e.coalition,"CARPET BOMB"})
				world.removeEventHandler(CrptBmbDesig)
				trigger.action.removeMark(e.idx)
			else 
				fac.carpetMapExecute({e.pos,t[1],e.coalition,"TALD"})
				world.removeEventHandler(CrptBmbDesig)
				trigger.action.removeMark(e.idx)
			--trigger.action.removeMark(pwdCheckList[j].idx)
			
			-- for j =1, #pwdCheckList do
				-- if string.find(pwdCheckList[j].text,t[2]) and pwdCheckList[j].coalition ~=-1 then

				-- end
			end
		    
		end
	
	end
end

function fac.carpetMapDesignate(_args)

	--local _unitR = fac.getFacUnit(_args[1])
	--local _groupId = fac.getGroupId(_unitR)
	world.addEventHandler(CrptBmbDesig)
	--local pw = "Password is A"..timer.getTime()
	--trigger.action.markToGroup(timer.getTime()+_groupId,pw,_unitR:getPoint(),_groupId)

end


function RECCEDesig:onEvent(e)
	local t ={}
	local pwdCheckList = {}
	local tgtHead
	local i
	local j
	--local str
	if e.id == 26 then
		if string.find(e.text, "RECCE") then

			--trigger.action.outText(e.initiator:getName() .. " " .. e.groupID, 25) 
			
			--local pwdCheckList =world.getMarkPanels()
			
			for i in string.gmatch(e.text, "%S+") do
				table.insert(t, i)
			end
			fac.RECCEMapExecute({e.pos,t[1],e.coalition,"TALD"})
			world.removeEventHandler(RECCEDesig)
			trigger.action.removeMark(e.idx)		    
		end
	
	end
end

function fac.RECCEDesignate(_args)

	--local _unitR = fac.getFacUnit(_args[1])
	--local _groupId = fac.getGroupId(_unitR)
	world.addEventHandler(RECCEDesig)
	--local pw = "Password is A"..timer.getTime()
	--trigger.action.markToGroup(timer.getTime()+_groupId,pw,_unitR:getPoint(),_groupId)

end

function fac.RECCEMapExecute(_args)
	
	local blueRECCEac = " "
	local redRECCEEac = " "
	local reccePont = _args[1]
	local side = _args[3]
	local avaliAB =  {}
	local dist2RECCE = 1000000000
	local RECCEmission = {}
	local _facUnitName = nil
	local selectRECCE = nil
	local selectRECCEgroup
	local selectRECCEpos
	for _, _facUnitName in pairs(fac.reccePilotNames) do
		--trigger.action.outText("Found " .. _facUnitName, 25)
		local recceAC = Unit.getByName(_facUnitName)
		if recceAC ~= nil then
			if recceAC:getPlayerName() == nil  and fac.RECCETasked[_facUnitName] ~= 1 then
				--trigger.action.outText("Found " .. _facUnitName, 25)
				if side == recceAC:getCoalition() and recceAC:isExist() then
					local tempSelectRECCE = _facUnitName
					local tempSelectRECCEgroup = Unit.getByName(_facUnitName) :getGroup()
					local tempSelectRECCEpos = Unit.getByName(_facUnitName):getPoint()
					local tempdist = math.sqrt((tempSelectRECCEpos.x-reccePont.x)^2 + (tempSelectRECCEpos.z-reccePont.z)^2)
					--trigger.action.outText("Found " .. tempdist, 25)
					if dist2RECCE > tempdist then 
					--	trigger.action.outText("Found " .. _facUnitName .." " ..tempdist.." " .. dist2RECCE, 25)
						selectRECCE = tempSelectRECCE
						selectRECCEgroup = tempSelectRECCEgroup
						selectRECCEpos = tempSelectRECCEpos
						dist2RECCE = tempdist
					end
				end
			end
		end
	end
	if selectRECCE ~= nil then 
		local scriptSTR = "fac.recceDetect({"..'"' .. selectRECCE .. '"'.."})\nfac.RECCETasked["..'"'..selectRECCE..'"'.."] = 0\ntrigger.action.outTextForCoalition(" .. side ..","..'"'.."RECCE Misson Complete, " .. selectRECCE .." returning to holding orbit" .. '"'..",10)"
		local scriptSTR2 = "fac.RECCETasked["..'"'..selectRECCE..'"'.."] = 0\ntrigger.action.outTextForCoalition(" .. side ..","..'"'.. selectRECCE .." avaliable for retasking" .. '"'..",10)"
		--trigger.action.outText(scriptSTR, 25) 
		--removebyKey(fac.RECCETasked,selectRECCE)
		RECCEmission = {
								id = 'Mission', 
								
								params = {
											airborne = true,
											route = {
														points = {
																	
																	[1] = {
																			["x"] = selectRECCEpos.x, --bombIP.x + math.cos(ipAngle+_FH*math.pi/4)*radTurn,
																			["y"] = selectRECCEpos.z, --bombIP.y + math.sin(ipAngle+_FH*math.pi/4)*radTurn,
																			["type"] = "Turning Point",
																			["action"] = "Turning Point",
																			["alt"] = selectRECCEpos.y,
																			["speed"] =  544,
																			--["task"] = {},
																		},															
																	
																	[2] = {
																			["x"] = reccePont.x, --bombIP.x + math.cos(ipAngle+_FH*math.pi/4)*radTurn,
																			["y"] = reccePont.z, --bombIP.y + math.sin(ipAngle+_FH*math.pi/4)*radTurn,
																			["type"] = "Turning Point",
																			["action"] = "Fly Over Point",
																			["alt"] = 20000,
																			["speed"] =  544,
																			--["ETA"] = timer.getTime()+time2IP, 
																			["ETA_locked"] = false,
																			--["alt_type"] =
																			["task"] = 
																				{
																					["id"] = "ComboTask",
																					["params"] = 
																					{
																						["tasks"] = 
																						{
																							--[1]  = {},
																							[1] = 
																							{
																								["enabled"] = true,
																								["auto"] = false,
																								["id"] = "WrappedAction",
																								["number"] = 2,
																								["params"] = 
																								{
																									["action"] = 
																									{
																										["id"] = "Script",
																										["params"] = 
																										{
																											["command"] = scriptSTR,
																										}, -- end of ["params"]
																									}, -- end of ["action"]
																								}, -- end of ["params"]
																							}, -- end of [1]
																						}, -- end of ["tasks"]
																					}, -- end of ["params"]
																				}, -- end of ["task"]
																			},
																	[3] = {
																			["x"] = selectRECCEpos.x, --bombIP.x + math.cos(ipAngle+_FH*math.pi/4)*radTurn,
																			["y"] = selectRECCEpos.z, --bombIP.y + math.sin(ipAngle+_FH*math.pi/4)*radTurn,
																			["type"] = "Turning Point",
																			["action"] = "Turning Point",
																			["alt"] = selectRECCEpos.y,
																			["speed"] =  544,
																			["task"] = {
																						["id"] = "ComboTask",
																						["params"] = 
																						{
																							["tasks"] = 
																							{
																								[1] = 
																								{
																									["enabled"] = true,
																									["auto"] = false,
																									["id"] = "Orbit",
																									["number"] = 1,
																									["params"] = 
																									{
																										["altitude"] = selectRECCEpos.y,
																										["pattern"] = "Circle",
																										["speed"] = 424.98611111111,
																										["speedEdited"] = true,
																									}, -- end of ["params"]
																								}, -- end of [1]
																								[2] = 
																								{
																									["enabled"] = true,
																									["auto"] = false,
																									["id"] = "WrappedAction",
																									["number"] = 2,
																									["params"] = 
																									{
																										["action"] = 
																										{
																											["id"] = "Script",
																											["params"] = 
																											{
																												["command"] = scriptSTR,
																											}, -- end of ["params"]
																										}, -- end of ["action"]
																									}, -- end of ["params"]
																								}, -- end of [2]
																							}, -- end of ["tasks"]
																						}, -- end of ["params"]
																					}, -- end of ["task"]
																		},	
																}
													}
											}
						}
		local recceController = selectRECCEgroup:getController()
		recceController:setTask(RECCEmission)
		recceController:setOption(1,1)
		trigger.action.outTextForCoalition(_args[3], selectRECCE .. " a " .. Unit.getByName(selectRECCE):getTypeName() .. " has been dispatched to RECCE a Map Mark", 10)
		if contains(fac.RECCETasked,selectRECCE) == false then 
			table.insert(fac.RECCETasked,selectRECCE)
			fac.RECCETasked[selectRECCE] = 1 
		else
			fac.RECCETasked[selectRECCE] = 1 
		end
	else
		trigger.action.outTextForCoalition(_args[3], "No AI RECCE Assets available", 10)
	end
	-- --RECCE spawner wip
	-- avaliAB = coalition.getAirbases(enum coalitionId )
	-- for abCount = 1, #avaliAB do
		-- if Airbase.getCategory(avaliAB[abCount]) == 0 then
						-- -- --trigger.action.outTextForCoalition(Group.getByName(fireGroup):getCoalition(),Group.getByName(fireGroup):getUnit(1):getTypeName() .. " is winchester and RTB for rearm at " .. Airbase.getCallsign((avaliAB[abCount]),10)
			-- avaliAB[abCount].getPoint
		-- end
	-- end
		-- local group = {
			-- ["visible"] = false,
			-- ["taskSelected"] = true,
			-- --["groupId"] = HVA.tempGroupSpawnedcounter,
			-- ["hidden"] = false,
			-- ["units"] = {},
			-- ["frequency"] = "",
			-- ["y"] =  yofs,
			-- ["x"] =  xofs,
			-- ["name"] = {},
			-- ["start_time"] = 0,
			-- ["task"] = {},
			-- ["route"] = {
				-- ["points"] = 
				-- {
					-- [1] = 
					-- {
						-- ["alt"] = rPos.y,
						-- ["type"] = "Turning Point",
						-- ["ETA"] = 0,
						-- ["alt_type"] = "RADIO",
						-- ["formation_template"] = "",
						-- ["y"] = yofs,
						-- ["x"] = xofs,
						-- ["ETA_locked"] = true,
						-- ["speed"] = _spd,
						-- ["action"] = "Cone",
						-- ["task"] = {
							-- ["id"] = "ComboTask",
							-- ["params"] = 
							-- {
								-- ["tasks"] = 
								-- {
									-- [1] ={},
									-- [2] =
										-- {
										
											-- ["number"] = 2,
											-- ["auto"] = true,
											-- ["id"] = "Follow",
											-- ["enabled"] = true,
											-- ["params"] = 
											-- {
												-- ["lastWptIndexFlagChangedManually"] = false,
												-- ["groupId"] = rId,
												-- ["lastWptIndex"] = 4,
												-- ["lastWptIndexFlag"] = false,
												-- ["pos"] = 
												-- {
													-- ["y"] = math.random(0,200),
													-- ["x"] = 200,
													-- ["z"] = 200,
												-- }, -- end of ["pos"]
											-- },
										-- },
																		
								-- }, -- end of ["tasks"]
							-- }, -- end of ["params"]
						-- }, -- end of ["task"],
						-- ["speed_locked"] = false,
					-- }, -- end of [1]
					
				-- }
			-- }
		-- }

end


function fac.carpetMapExecute(_args)

	local _enemyUnit = nil
	local _artyInRange = nil
	local _artyPos = {}
	local comboShoot = {}
	local previousTask = {}
	local comboTasker = {}
	local firemission = {}
	local firePointTask = {}
	local firePointWpt = {}
	local firepoint = {}
	local firepointFormTask ={}
	local firepointForm ={}
	local tpENV ={}
	local _i
	local bombIP ={}
	local ipTurnPt = {}
	local combatClimb = {}
	local combatTurn = {}
	local tp = {}
	local _k
	local comboTasker = {}
	--local tp = _args[4]
	local _i

	--trigger.action.outText(_args[1],_args[3], 25) 
	local attackAz = 0
	local directATTACK = true
	if _args[2] ~= "CBRQT" and _args[2] ~= "TDRQT"  then  --and type(_args[2]) ~= "string" and _args[2] > 360
		--trigger.action.outText(_args[2], 25) 
		local inAz = tonumber(_args[2])
		if  inAz ~= nil and  inAz < 360 then 
			attackAz = math.rad(inAz)
			directATTACK = false
		end
	else
		trigger.action.outTextForCoalition(_args[3],"Attack Heading not selected or is invalid, Defaulting to direct attack",10)
	end 
	if _args[4] == "CARPET BOMB" then
		_artyInRange = fac.getBomber(_args[1],_args[3],5)
	else
		_artyInRange = fac.getBomber(_args[1],_args[3],3)
	end

--if _enemyUnit == nil  or _artyInRange == nil then
			-- if _enemyUnit == nil and _artyInRange ~= nil then
				-- trigger.action.outTextForGroup(_groupId,"Unable to process fire mission",10)
				-- trigger.action.outTextForGroup(_groupId,"No Valid Target",10)
				-- return
	if _artyInRange == nil then
			trigger.action.outTextForCoalition(_args[3],"Unable to process fire mission",10)
			trigger.action.outTextForCoalition(_args[3],"No untasked active bomber in range of target",10)
			return	
		--else
	else
		_artyPos = _artyInRange:getUnit(1):getPoint()
		local ammoType = _artyInRange:getUnit(1):getAmmo()
		local weapStation = 1
		if _args[4] == "TALD" then 
			for _k = 1,#ammoType do 
						--trigger.action.outText(payloadCheck[_k].desc.typeName,10)
						if ammoType[_k].desc.typeName == "weapons.missiles.ADM_141A" then
							weapStation = _k
							--table.insert(_foundArty,tempFound[_i])
							--trigger.action.outText(Group.getByName(tempFound[_i]):getUnit(1):getTypeName() .. " " .. payloadCheck[1].desc.guidance,10)
						--else
							--trigger.action.outText(Group.getByName(tempFound[_i]):getUnit(1):getTypeName() .. " unguided bombs",10)
							break
						end
			end
		end
		tp = _args[1]
		
		-- firePointWpt.x = tp.x + math.cos(getHeading(_facUnit)+math.pi)*5000
		-- firePointWpt.y = tp.z + math.sin(getHeading(_facUnit)+math.pi)*5000
		-- firePointWpt.type = "Turning Point"
		-- firePointWpt.action = "Turning Point"
		-- firePointWpt.alt = _artyPos.y

		firepoint.x = tp.x --+ _fireOffset.x
		firepoint.y = tp.z --+ _fireOffset.z
		firepoint.attackType = 'Carpet' 
		firepoint.carpetLength  = ammoType[weapStation].count*10
		firepoint.expend = "All"	
		firepoint.direction  = attackAz + math.pi
		firepoint.directionEnabled = true
		firepoint.attackQty = 1
		firepoint.groupAttack = true
		--firepoint.weaponType  = 2147485694 
		if _args[4] == "TALD" then
		    firepoint.weaponType  = 8589934592  
			firepoint.altitude = 10000
			firepoint.altitudeEnabled = false
		else 
			firepoint.weaponType  = 2147485694  
			firepoint.altitude = _artyPos.y
			firepoint.altitudeEnabled = true
		end
		--firepoint.expendQty = _artyRounds
		--firepoint.expendQtyEnabled = true
		--["params"] = 
		TALDmission2 = {id = 'Bombing', params = 
                                                            {
                                                                ["direction"] = firepoint.direction,
                                                                ["attackQtyLimit"] = false,
                                                                ["attackQty"] = 1,
                                                                ["expend"] = "All",
                                                                ["altitudeEdited"] = true,
                                                                ["directionEnabled"] = false,
                                                                ["groupAttack"] = true,
                                                                ["altitude"] = firepoint.altitude,
                                                                ["altitudeEnabled"] = true,
                                                                ["y"] = firepoint.y,
                                                                ["weaponType"] = firepoint.weaponType,
                                                                ["x"] = firepoint.x,
                                                            }, -- end of ["params"]
					}
		
		firePointTask = {id = 'CarpetBombing', params = firepoint}
		--TALDmission = {id = 'Bombing', params = firepoint}
		-- firePointWpt.task = firepointTask
		
		-- firepointForm.variantIndex = 2
		-- firepointForm.formationIndex = 2                                                   
		-- firepointForm.value = 131074 
		
		-- firePointFormTask = {id = 'Formation', params = firepointForm}
		
		-- previousTask = mist.getGroupRoute(_artyInRange:getName())
		-- --table.insert (comboTasker,firepointFormTask)
		-- table.insert (comboTasker,firepointTask)
		-- --trigger.action.outText(mist.utils.tableShow(previousTask), 25) 
		-- table.insert (comboTasker,previousTask)
		local _vel = _artyInRange:getUnit(1):getVelocity()
		_spd = math.sqrt(_vel.x^2+_vel.z^2)
		local atkSpd = _spd
		-- if _args[4] == "TALD" then 
			-- atkSpd = 500
		-- end
		local radTurn = (2*atkSpd)^2/(11.8*math.tan(25*math.pi/180))
		radTurn = 20000
		if _args[4] == "TALD" then
			radTurn = 64820
		end
		local combatClimb =
						   {
								["alt"] = 2000,
								["action"] = "Turning Point",
								["alt_type"] = "BARO",
								["speed"] = 220.97222222222,
								["task"] = 
								{
									["id"] = "ComboTask",
									["params"] = 
									{
										["tasks"] = 
										{
											[1] = 
											{
												["enabled"] = true,
												["auto"] = false,
												["id"] = "Aerobatics",
												["number"] = 1,
												["params"] = 
												{
													["maneuversSequency"] = 
													{
														[1] = 
														{
															["name"] = "CLIMB",
															["params"] = 
															{
																["InitSpeed"] = 
																{
																	["order"] = 3,
																	["value"] = 444,
																}, -- end of ["InitSpeed"]
																["InitAltitude"] = 
																{
																	["order"] = 2,
																	["value"] = 2000,
																}, -- end of ["InitAltitude"]
																["StartImmediatly"] = 
																{
																	["order"] = 5,
																	["value"] = 1,
																}, -- end of ["StartImmediatly"]
																["RepeatQty"] = 
																{
																	["min_v"] = 1,
																	["max_v"] = 10,
																	["value"] = 1,
																	["order"] = 1,
																}, -- end of ["RepeatQty"]
																["UseSmoke"] = 
																{
																	["order"] = 4,
																	["value"] = 0,
																}, -- end of ["UseSmoke"]
																["Angle"] = 
																{
																	["min_v"] = 15,
																	["max_v"] = 90,
																	["value"] = 45,
																	["step"] = 5,
																	["order"] = 6,
																}, -- end of ["Angle"]
																["FinalAltitude"] = 
																{
																	["order"] = 7,
																	["value"] = 10000,
																}, -- end of ["FinalAltitude"]
															}, -- end of ["params"]
														}, -- end of [1]
													}, -- end of ["maneuversSequency"]
												}, -- end of ["params"]
											}, -- end of [1]
										},
									},
								},
							}
		local combatTurn = 	{
										["enabled"] = true,
										["auto"] = false,
										["id"] = "Aerobatics",
										["number"] = 2,
										["params"] = 
										{
											["maneuversSequency"] = 
											{
												[1] = 
												{
													["name"] = "TURN",
													["params"] = 
													{
														["Ny_req"] = 
														{
															["order"] = 6,
															["value"] = 2,
														}, -- end of ["Ny_req"]
														["InitAltitude"] = 
														{
															["order"] = 2,
															["value"] = 2000,
														}, -- end of ["InitAltitude"]
														["StartImmediatly"] = 
														{
															["order"] = 5,
															["value"] = 1,
														}, -- end of ["StartImmediatly"]
														["UseSmoke"] = 
														{
															["order"] = 4,
															["value"] = 0,
														}, -- end of ["UseSmoke"]
														["SIDE"] = 
														{
															["order"] = 9,
															["value"] = 0,
														}, -- end of ["SIDE"]
														["InitSpeed"] = 
														{
															["order"] = 3,
															["value"] = 795.49999999999,
														}, -- end of ["InitSpeed"]
														["ROLL"] = 
														{
															["order"] = 7,
															["value"] = 60,
														}, -- end of ["ROLL"]
														["SECTOR"] = 
														{
															["order"] = 8,
															["value"] = 90,
														}, -- end of ["SECTOR"]
														["RepeatQty"] = 
														{
															["min_v"] = 1,
															["max_v"] = 10,
															["value"] = 1,
															["order"] = 1,
														}, -- end of ["RepeatQty"]
													}, -- end of ["params"]
												}, -- end of [1]
											},
										},
								}
								                                                             
		bombIP.x = tp.x + math.cos(attackAz+math.pi)*radTurn*1
		bombIP.z = tp.z + math.sin(attackAz+math.pi)*radTurn*1
		local dx = -(_artyPos.x-bombIP.x)
		local dy = -(_artyPos.z-bombIP.z)
		local ipAngle = math.atan(dy/dx)
		--trigger.action.outText("IPANGLE = " .. (ipAngle)/math.pi*180 .."\n", 300)
		-- if ipAngle < 0 then
			-- ipAngle = ipAngle + 2*math.pi
		-- end
		local d2TGT = math.sqrt((_artyPos.x-tp.x)^2 + (_artyPos.z-tp.z)^2)
		local d2TP =  math.sqrt((dx)^2 + (dy)^2)
		local time2TGT = d2TGT/411.6
		local time2IP = d2TP/411.6
		-- if d2TGT < d2TP then
			-- bombIP.x = tp.x + math.cos(attackAz)*radTurn*1
			-- bombIP.z = tp.z + math.sin(attackAz)*radTurn*1
		-- end
		local _FH = 1
		if dy < 0 then -- dy = -1 90-270
			if dx < 0 then  --dy/dx = 1 180-270
				--trigger.action.outText(_artyInRange:getName().." Firing SW:\n".. (ipAngle/math.pi)*180 .."\n", 300)
				--ipAngle= ipAngle  + 2*math.pi -- math.pi/4
				_FH = 0
			else
				--trigger.action.outText(_artyInRange:getName().." Firing SE:\n".. (ipAngle/math.pi)*180 .."\n", 300)
				--ipAngle= ipAngle + math.pi --+ math.pi/4
				_FH = -1
			end
			
		elseif dy > 0 then --dy = 1 270-90
			if dx < 0 then --dy/dx = -1 270-0
				--trigger.action.outText(_artyInRange:getName().." Firing NW:\n".. (ipAngle/math.pi)*180 .."\n", 300)
				_FH = 0
				--ipAngle= ipAngle  + 2*math.pi -- math.pi/4
			else --dy/dx = 1 0-90
				--trigger.action.outText(_artyInRange:getName().." Firing NE:\n".. (ipAngle/math.pi)*180 .."\n", 300)
				--ipAngle= ipAngle -- + math.pi/4
				_FH = 1
				
			end
		end
		local taskedMission = {}
		
		if _args[4] == "TALD" then
			taskedMission = TALDmission2
		else 
			taskedMission = firePointTask
		end
		
		local IPoffset = {}
			IPoffset.x = bombIP.x + math.cos(ipAngle+math.pi*_FH)*d2TP/2
			IPoffset.z = bombIP.z + math.sin(ipAngle+math.pi*_FH)*d2TP/2
		if math.sqrt(dx^2+dy^2) < radTurn then
			IPoffset.x = bombIP.x
			IPoffset.z = bombIP.z
		end	
			--_artyInRange
			
		local headingDeg = (ipAngle)/math.pi*180
		if headingDeg >= 360 then
			headingDeg = headingDeg-360
		end
		local scriptSTR = "trigger.action.outTextForCoalition(" .. _args[3] ..","..'"'.. _artyInRange:getUnit(1):getTypeName() .." is IP Inbound for " .._args[4] .. " attack" .. '"'..",10)"
		local ipSTR = {}
		ipstr ={
				["enabled"] = true,
				["auto"] = false,
				["id"] = "WrappedAction",
				["number"] = 2,
				["params"] = 
				{
					["action"] = 
					{
						["id"] = "Script",
						["params"] = 
						{
							["command"] = scriptSTR,
						}, -- end of ["params"]
					}, -- end of ["action"]
				}, -- end of ["params"]
			} -- end of [1]
					
																					
		table.insert(comboTasker,ipstr)
		--table.insert(comboTasker,combatClimb)
		table.insert(comboTasker,taskedMission)
		comboMission = {id = 'ComboTask', params = {tasks = comboTasker}}
		--trigger.action.outText(scriptSTR, 25) 
		--trigger.action.outText(radTurn.."\n"..IPoffset.x .. " ".. IPoffset.z .."\n" ..bombIP.x .. " ".. bombIP.z .."\n".. headingDeg.."\n", 300)			
		--trigger.action.markToCoalition(timer.getTime()+100,"TP ".. headingDeg .. "\nETA " .. time2IP, IPoffset,_args[3])
		--trigger.action.markToCoalition(timer.getTime()+200,"IP".. headingDeg, bombIP,_args[3])
			firemission = {
							id = 'Mission', 
							
							params = {
										airborne = true,
										route = {
													points = {--firePointWpt--,previousTask
																[1] = {
																			["x"] = _artyPos.x, --bombIP.x + math.cos(ipAngle+_FH*math.pi/4)*radTurn,
																			["y"] = _artyPos.z, --bombIP.y + math.sin(ipAngle+_FH*math.pi/4)*radTurn,
																			["type"] = "Turning Point",
																			["action"] = "Turning Point",
																			["alt"] = firepoint.altitude,
																			["speed"] =  atkSpd,
																			--["task"] = {},
																		},															
																	
																
																-- [2] = {
																		-- ["x"] = IPoffset.x, --bombIP.x + math.cos(ipAngle+_FH*math.pi/4)*radTurn,
																		-- ["y"] = IPoffset.z, --bombIP.y + math.sin(ipAngle+_FH*math.pi/4)*radTurn,
																		-- ["type"] = "Turning Point",
																		-- ["action"] = "Turning Point",
																		-- ["alt"] = firepoint.altitude,
																		-- ["speed"] =  atkSpd,
																		-- ["ETA"] = timer.getTime()+time2IP, 
																		-- ["ETA_locked"] = false,
																		-- --["alt_type"] =
																		-- ["task"] = {}, -- end of ["task"]
																		-- },
																																		
																-- [2] = {
																		-- ["x"] = tp.x + math.cos(getHeading(_facUnit)+math.pi)*50*_spd*2,
																		-- ["y"] = tp.z + math.sin(getHeading(_facUnit)+math.pi)*50*_spd*2,
																		-- ["type"] = "Turning Point",
																		-- ["action"] = "Turning Point",
																		-- ["alt"] = _artyPos.y,
																		-- --["speed"] =  _artyInRange:getUnit(1):getVelocity(),
																		-- --["task"] = {}
																		-- },
																 [2] = {																		
																		["x"] = bombIP.x ,
																		["y"] = bombIP.z,
																		["type"] = "Turning Point",
																		["action"] = "Fly Over Point",
																		["alt"] = firepoint.altitude,
																		--["alt_type"] =
																		["speed"] = atkSpd,
																		["task"] = comboMission,
																		["ETA"] = timer.getTime() + time2IP*2, 
																		["ETA_locked"] = false,
																		},
																[3] = {
																		["x"] = IPoffset.x,
																		["y"] = IPoffset.z,
																		["type"] = "Turning Point",
																		["action"] = "Turning Point",
																		["alt"] = firepoint.altitude,
																		["speed"] =  atkSpd,
																		--["alt_type"] =
																		--["task"] = {}
																		},
																		
															}
												}
									}
						}
				--_artyInRange:getController():pushTask(firemission)
				
				
				-- timer.scheduleFunction(fac.launchMulti,{_artyInRange:getController(),firemission},timer.getTime()+ 45)
				
			--end
			--tasks = { _i = 
			
		--end
		--comboShoot = {id = 'ComboTask', params = {tasks = comboTasker}}

		--_artyInRange:getController():setOption(5,65539)
		--_artyInRange:getController():pushTask(firePointTask)
		_artyInRange:getController():setOption(1,1)
		
		if _args[4] == "TALD" then 
			_artyInRange:getController():setOption(5,131074)
			if directATTACK == true then 
				_artyInRange:getController():setTask(comboMission)
			else 
				_artyInRange:getController():setTask(firemission)
			end
		else
			_artyInRange:getController():setOption(5,786435)
			if directATTACK == true then 
				_artyInRange:getController():setTask(comboMission)
			else 
				_artyInRange:getController():setTask(firemission)
			end		
		end
		_artyInRange:getController():setOption(10,3221225470)

		if fac.ArtyTasked[_artyInRange:getName()] == nil  or fac.ArtyTasked[_artyInRange:getName()].tasked == 0 then 
			if fac.ArtyTasked[_artyInRange:getName()] == nil then
				table.insert (fac.ArtyTasked, _artyInRange:getName())
			end
			--fac.ArtyTasked[_artyInRange:getName()]
			--fac.ArtyTasked[_artyInRange:getName()]= {name = _artyInRange:getName(), tasked = 1,timeTasked = nil}
			fac.ArtyTasked[_artyInRange:getName()]= {name = _artyInRange:getName(), tasked = ammoType[weapStation].count *#_artyInRange:getUnits() ,timeTasked = timer.getTime() ,tgt = nil}
			--timer.scheduleFunction(fac.purgeArtList,{_artyInRange:getName()},timer.getTime()+ 45*1)
		end
		
		--timer.scheduleFunction(fac.clearTask,{_artyInRange:getController(),#_tgtList},timer.getTime()+ 20*#_tgtList)
		trigger.action.outTextForCoalition(_args[3],"Fire mission order sent, " .._artyInRange:getUnit(1):getTypeName() .. "(".. ammoType[weapStation].count *#_artyInRange:getUnits() .." Rounds)".." will carpet bomb using ATK Az of ".. math.floor(attackAz/math.pi*180) .. " degrees on Map Mark" ,10)
	end

end

function fac.callFireMissionCarpet(_args)
	--local _facUnitName = _args[1]
	local _facUnit =_args[1]
	--local _tgtList = fac.facManTGT[_args[1]]
	local _artyRounds = _args[2] 
	local _roundType = _args[3]
	local _groupId = _args[6]
	local _enemyUnit = nil
	local _artyInRange = nil
	local _artyPos = {}
	local comboShoot = {}
	local previousTask = {}
	local comboTasker = {}
	local firemission = {}
	local firePointTask = {}
	local firePointWpt = {}
	local firepoint = {}
	local firepointFormTask ={}
	local firepointForm ={}
	local tp = _args[4]
	local _i
	local attackHead = _args[5]
	
	if attackHead == nil or attackHead == "CBRQT" then
		trigger.action.outTextForGroup(_groupId,"No Heading defined, defaulting to 0 az",10)
		--trigger.action.outTextForGroup(_groupId,"No Valid Target, please create target list with manual scan",10)
		--return
		attackHead = 0
	end
	--for _i = 1, #_tgtList do
		--if _tgtList[_i]:isExist() then 
	--_enemyUnit = fac.getCurrentFacUnit(_facUnit, _facUnitName)
	_artyInRange = fac.getArty(tp,nil,_roundType,_args[7])
			--if _artyInRange ~=nil then
				--_artyPos = _artyInRange:getUnit(1):getPoint()
			--else
				--return
			--end
		--else
			--trigger.action.outTextForGroup(_groupId,"Invalid target detected, please rescan for more current target list with manual scan",10)
			--return 
		--end
		
		if _artyInRange == nil then
				trigger.action.outTextForGroup(_groupId,"Unable to process fire mission",10)
				trigger.action.outTextForGroup(_groupId,"No untasked active artillery/bomber in range of target",10)
				return	
			--else
				
		else
			_artyPos = _artyInRange:getUnit(1):getPoint()
			
			tp = _enemyUnit:getPoint()
			
			firePointWpt.x = tp.x + math.cos(attackHead+math.pi)*5000
			firePointWpt.y = tp.z + math.sin(attackHead+math.pi)*5000
			firePointWpt.type = "Turning Point"
			firePointWpt.action = "Turning Point"
			firePointWpt.alt = _artyPos.y

			firepoint.x = tp.x --+ _fireOffset.x
			firepoint.y = tp.z --+ _fireOffset.z
			firepoint.attackType = 'Carpet' 
			firepoint.carpetLength  = 500
			firepoint.expend = "All"	
			--firepoint.direction  = getHeading(_facUnit)--+math.pi
			firepoint.directionEnabled = true
			firepoint.attackQty = 1
			firepoint.altitude = _artyPos.y
			firepoint.altitudeEnabled = true
			--firepoint.expendQty = _artyRounds
			--firepoint.expendQtyEnabled = true
			firepoint.groupAttack = true
			
			firePointTask = {id = 'CarpetBombing', params = firepoint}
			
			firePointWpt.task = firepointTask
			
			-- firepointForm.variantIndex = 2
			-- firepointForm.formationIndex = 2                                                   
            -- firepointForm.value = 131074 
			
			-- firePointFormTask = {id = 'Formation', params = firepointForm}
			
			previousTask = mist.getGroupRoute(_artyInRange:getName())
			--table.insert (comboTasker,firepointFormTask)
			table.insert (comboTasker,firePointWpt)
			--trigger.action.outText(mist.utils.tableShow(previousTask), 25) 
			table.insert (comboTasker,previousTask)
			
			
			
			
			--_artyInRange
			firemission = {
							id = 'Mission', 
							params = {
										route = {
													points = {--firePointWpt--,previousTask
																[1] = {
																		["x"] = tp.x + math.cos(attackHead+math.pi)*20000,
																		["y"] = tp.z + math.sin(attackHead+math.pi)*20000,
																		["type"] = "Turning Point",
																		["action"] = "Turning Point",
																		["alt"] = _artyPos.y,
																		["task"] = firePointTask
																		},
																 -- [2] = {																		
																		-- ["x"] = tp.x + math.cos(getHeading(_facUnit)+math.pi)*5000,
																		-- ["y"] = tp.z + math.sin(getHeading(_facUnit)+math.pi)*5000,
																		-- ["type"] = "Turning Point",
																		-- ["action"] = "Turning Point",
																		-- ["alt"] = _artyPos.y,
																		-- ["task"] = firePointTask
																		-- }
															}
												}
									}
						}
			--_artyInRange:getController():pushTask(firemission)
			
			
			-- timer.scheduleFunction(fac.launchMulti,{_artyInRange:getController(),firemission},timer.getTime()+ 45)
			
		end
		--tasks = { _i = 
		
	--end
	--comboShoot = {id = 'ComboTask', params = {tasks = comboTasker}}
	_artyInRange:getController():setOption(1,1)
	--_artyInRange:getController():pushTask(firePointTask)
	_artyInRange:getController():setOption(5,65539)
	_artyInRange:getController():setTask(firemission)
	_artyInRange:getController():setOption(10,3221225470)

	--if fac.ArtyTasked[_artyInRange:getName()] == nil  or fac.ArtyTasked[_artyInRange:getName()].tasked > 0 then 
					--table.insert (fac.ArtyTasked, _artyInRange:getName())
					--fac.ArtyTasked[_artyInRange:getName()]
	fac.ArtyTasked[_artyInRange:getName()]= {name = _artyInRange:getName(), tasked = 1,timeTasked = nil}
		--timer.scheduleFunction(fac.purgeArtList,{_artyInRange:getName()},timer.getTime()+ 45*1)
	--end
	local ammoType = _artyInRange:getUnit(1):getAmmo()
	--timer.scheduleFunction(fac.clearTask,{_artyInRange:getController(),#_tgtList},timer.getTime()+ 20*#_tgtList)
	trigger.action.outTextForCoalition(_facUnit:getCoalition(),"Fire mission order sent, " .._artyInRange:getUnit(1):getTypeName() .. "(".. ammoType[1].count .." Rounds)".." will carpet bomb using ATK Az of ".. math.floor(attackHead/math.pi*180).. " degrees on target:" .. _enemyUnit:getTypeName() ,10)
end

function fac.callFireMissionCarpet2(_args)
	local _facUnitName = _args[1]
	local _facUnit = Unit.getByName(_facUnitName)
	local _tgtList = fac.facManTGT[_args[1]]
	local _artyRounds = _args[2] 
	local _roundType = _args[3]
	local _groupId = fac.getGroupId(_facUnit)
	local _enemyUnit = nil
	local _artyInRange = nil
	local _artyPos = {}
	local comboShoot = {}
	local previousTask = {}
	local comboTasker = {}
	local firemission = {}
	local firePointTask = {}
	local firePointWpt = {}
	local firepoint = {}
	local firepointFormTask ={}
	local firepointForm ={}
	local tpENV ={}
	local _i
	local bombIP ={}
	local ipTurnPt = {}
	--if _tgtList == nil then
		--trigger.action.outTextForGroup(_groupId,"Unable to process fire mission",10)
		--trigger.action.outTextForGroup(_groupId,"No Valid Target, please create target list with manual scan",10)
		--return
	--end
	--for _i = 1, #_tgtList do
		--if _tgtList[_i]:isExist() then 
	_enemyUnit = fac.getCurrentFacUnit(_facUnit, _facUnitName)
	_artyInRange = fac.getArty(_enemyUnit,_facUnit,_roundType)
			--if _artyInRange ~=nil then
				--_artyPos = _artyInRange:getUnit(1):getPoint()
			--else
				--return
			--end
		--else
			--trigger.action.outTextForGroup(_groupId,"Invalid target detected, please rescan for more current target list with manual scan",10)
			--return 
		--end
		
		if _enemyUnit == nil  or _artyInRange == nil then
			if _enemyUnit == nil and _artyInRange ~= nil then
				trigger.action.outTextForGroup(_groupId,"Unable to process fire mission",10)
				trigger.action.outTextForGroup(_groupId,"No Valid Target",10)
				return
			elseif _artyInRange == nil then
				trigger.action.outTextForGroup(_groupId,"Unable to process fire mission",10)
				trigger.action.outTextForGroup(_groupId,"No untasked active artillery/bomber in range of target",10)
				return	
			--else
				
			end
		else
			_artyPos = _artyInRange:getUnit(1):getPoint()
			
			tp = _enemyUnit:getPoint()
			
			firePointWpt.x = tp.x + math.cos(getHeading(_facUnit)+math.pi)*5000
			firePointWpt.y = tp.z + math.sin(getHeading(_facUnit)+math.pi)*5000
			firePointWpt.type = "Turning Point"
			firePointWpt.action = "Turning Point"
			firePointWpt.alt = _artyPos.y

			firepoint.x = tp.x --+ _fireOffset.x
			firepoint.y = tp.z --+ _fireOffset.z
			firepoint.attackType = 'Carpet' 
			firepoint.carpetLength  = 1000
			firepoint.expend = "All"	
			--firepoint.direction  = getHeading(_facUnit)--+math.pi
			--firepoint.directionEnabled = true
			firepoint.attackQty = 1
			firepoint.altitude = _artyPos.y
			firepoint.altitudeEnabled = true
			--firepoint.expendQty = _artyRounds
			--firepoint.expendQtyEnabled = true
			firepoint.groupAttack = true
			
			firePointTask = {id = 'CarpetBombing', params = firepoint}
			
			firePointWpt.task = firepointTask
			
			-- firepointForm.variantIndex = 2
			-- firepointForm.formationIndex = 2                                                   
            -- firepointForm.value = 131074 
			
			-- firePointFormTask = {id = 'Formation', params = firepointForm}
			
			previousTask = mist.getGroupRoute(_artyInRange:getName())
			--table.insert (comboTasker,firepointFormTask)
			table.insert (comboTasker,firepointTask)
			--trigger.action.outText(mist.utils.tableShow(previousTask), 25) 
			table.insert (comboTasker,previousTask)
			local _vel = _artyInRange:getUnit(1):getVelocity()
			_spd = math.sqrt(_vel.x^2+_vel.z^2)
			
			local radTurn = (2*_spd)^2/(11.8*math.tan(25*math.pi/180))
			
			bombIP.x = tp.x + math.cos(getHeading(_facUnit)+math.pi)*radTurn*1
			bombIP.y = tp.z + math.sin(getHeading(_facUnit)+math.pi)*radTurn*1
			local dx = -(_artyPos.x-bombIP.x)
			local dy = -(_artyPos.z-bombIP.y)
			local ipAngle = math.atan(dy/dx)
			
			
			
			local _FH = 1
		if dy < 0 then -- dy = -1 90-270
			if dx < 0 then  --dy/dx = 1 180-270
				--trigger.action.outText(_artyInRange:getName().." Firing SW:\n".. (_fireheading/math.pi)*180 .."\n", 300)
				ipAngle= ipAngle  + 2*math.pi
			else
				--trigger.action.outText(_artyInRange:getName().." Firing SE:\n".. (_fireheading/math.pi)*180 .."\n", 300)
				ipAngle= ipAngle + math.pi
			end
		elseif dy > 0 then --dy = 1 270-90
			if dx < 0 then --dy/dx = -1 270-0
				--trigger.action.outText(_artyInRange:getName().." Firing NW:\n".. (_fireheading/math.pi)*180 .."\n", 300)
				ipAngle= ipAngle  + 2*math.pi
			else --dy/dx = 1 0-90
				--trigger.action.outText(_artyInRange:getName().." Firing NE:\n".. (_fireheading/math.pi)*180 .."\n", 300)
				ipAngle= ipAngle
				_FH = -1
			end
			
		end
		
		local IPoffset = {}
		IPoffset.x = radTurn
		IPoffset.y = radTurn
		if math.sqrt(dx^2+dy^2) < radTurn then
			IPoffset.x = 1
			IPoffset.y = 1
		end	
			--_artyInRange
			firemission = {
							id = 'Mission', 
							
							params = {
										airborne = true,
										route = {
													points = {--firePointWpt--,previousTask
																[1] = {
																		["x"] = bombIP.x + math.cos(ipAngle)*radTurn,
																		["y"] = bombIP.y + math.sin(ipAngle)*radTurn,
																		["type"] = "Turning Point",
																		["action"] = "Turning Point",
																		["alt"] = _artyPos.y,
																		["speed"] =  _artyInRange:getUnit(1):getVelocity(),
																		--["alt_type"] =
																		--["task"] = {}
																		},
																		
																-- [2] = {
																		-- ["x"] = tp.x + math.cos(getHeading(_facUnit)+math.pi)*50*_spd*2,
																		-- ["y"] = tp.z + math.sin(getHeading(_facUnit)+math.pi)*50*_spd*2,
																		-- ["type"] = "Turning Point",
																		-- ["action"] = "Turning Point",
																		-- ["alt"] = _artyPos.y,
																		-- --["speed"] =  _artyInRange:getUnit(1):getVelocity(),
																		-- --["task"] = {}
																		-- },
																 [2] = {																		
																		["x"] = tp.x + math.cos(getHeading(_facUnit)+math.pi)*radTurn*1,
																		["y"] = tp.z + math.sin(getHeading(_facUnit)+math.pi)*radTurn*1,
																		["type"] = "Turning Point",
																		["action"] = "Turning Point",
																		["alt"] = _artyPos.y,
																		--["alt_type"] =
																		["speed"] =  _artyInRange:getUnit(1):getVelocity(),
																		
																		["task"] = firePointTask
																		
																		}
															}
												}
									}
						}
			--_artyInRange:getController():pushTask(firemission)
			
			
			-- timer.scheduleFunction(fac.launchMulti,{_artyInRange:getController(),firemission},timer.getTime()+ 45)
			
		end
		--tasks = { _i = 
		
	--end
	--comboShoot = {id = 'ComboTask', params = {tasks = comboTasker}}
	_artyInRange:getController():setOption(1,1)
	
	_artyInRange:getController():setOption(5,65539)
	--_artyInRange:getController():pushTask(firePointTask)
	 _artyInRange:getController():setTask(firemission)
	_artyInRange:getController():setOption(10,3221225470)

	--if fac.ArtyTasked[_artyInRange:getName()] == nil  or fac.ArtyTasked[_artyInRange:getName()].tasked > 0 then 
					--table.insert (fac.ArtyTasked, _artyInRange:getName())
					--fac.ArtyTasked[_artyInRange:getName()]
	fac.ArtyTasked[_artyInRange:getName()]= {name = _artyInRange:getName(), tasked = 1,timeTasked = nil}
		--timer.scheduleFunction(fac.purgeArtList,{_artyInRange:getName()},timer.getTime()+ 45*1)
	--end
	local ammoType = _artyInRange:getUnit(1):getAmmo()
	--timer.scheduleFunction(fac.clearTask,{_artyInRange:getController(),#_tgtList},timer.getTime()+ 20*#_tgtList)
	trigger.action.outTextForCoalition(_facUnit:getCoalition(),"Fire mission order sent, " .._artyInRange:getUnit(1):getTypeName() .. "(".. ammoType[1].count .." Rounds)".." will carpet bomb using ATK Az of ".. math.floor(getHeading(_facUnit)/math.pi*180).. " degrees on target:" .. _enemyUnit:getTypeName() .. ". Requestor: " .. fac.getFacName(_facUnitName) ,10)
end

function fac.launchMulti(_args)
	_args[1]:pushTask(_args[2])
end

function fac.taskedArty(_args)
	
	

	_args[1]:pushTask(_args[2])
end

local facArtyFireDetect ={}

function facArtyFireDetect:onEvent(e)
	if e.id == world.event.S_EVENT_SHOT then
		local fireGroup = Unit.getGroup(e.initiator):getName()
		local displayUnitName = e.initiator:getDesc()
		if fac.ArtyTasked[fireGroup] ~= nil and fac.ArtyTasked[fireGroup].tasked > 0 then
			fac.ArtyTasked[fireGroup].tasked = fac.ArtyTasked[fireGroup].tasked - 1
			trigger.action.outTextForCoalition(Group.getByName(fireGroup):getCoalition(),displayUnitName.displayName .. " has commenced attack at designated target, tasked rounds remaining "..fac.ArtyTasked[fireGroup].tasked,0.5)
			if fac.ArtyTasked[fireGroup].tasked == 0 then 
			--fac.ArtyTasked[fireGroup].tasked = false
			local leaderType = Group.getByName(fireGroup):getUnit(1):getDesc()
				trigger.action.outTextForCoalition(Group.getByName(fireGroup):getCoalition(), leaderType.displayName .. " Task Group available for re-tasking ",20)
			end
			if Unit.getGroup(e.initiator):getCategory() > 1 and e.weapon:getCategory() == 0 then
				if fac.ArtyTasked[fireGroup].tgt:isExist() then
					local tgtPnt = fac.ArtyTasked[fireGroup].tgt:getPoint() 
					local _tempDist = fac.getDistance(e.initiator:getPoint(), tgtPnt)
					timer.scheduleFunction(fac.explosions, {tgtPnt}, timer.getTime() + _tempDist/264)
				else
					Group.getByName(fireGroup):getController():popTask()
					fac.ArtyTasked[fireGroup].tasked = 0
					trigger.action.outTextForCoalition(Group.getByName(fireGroup):getCoalition(),Group.getByName(fireGroup):getUnit(1):getTypeName() .. " Task Group tasked target destroyed, available for re-tasking ",20)
				end
			end
		elseif fac.ArtyTasked[fireGroup] ~= nil then
			fac.ArtyTasked[fireGroup].tasked = 0
			if Unit.getGroup(e.initiator):getCategory() == 0 then
				--trigger.action.outTextForCoalition(Group.getByName(fireGroup):getCoalition(),Group.getByName(fireGroup):getUnit(1):getTypeName() .. " BOMBS AWAY!!! ",0.25)
			end
		end
		if   fac.ArtyTasked[fireGroup] ~= nil and Unit.getGroup(e.initiator):getCategory() == 0 then
			--trigger.action.outTextForCoalition(Group.getByName(fireGroup):getCoalition(),Group.getByName(fireGroup):getUnit(1):getTypeName() .. " has ammo remaining " .. fac.artyGetAmmo(Unit.getGroup(e.initiator):getUnits()),10)
			if fac.artyGetAmmo(Unit.getGroup(e.initiator):getUnits()) == 0 then
				trigger.action.outTextForCoalition(Group.getByName(fireGroup):getCoalition(),displayUnitName.displayName .. " is winchester and RTB",10)
				-- local avaliAB = coalition.getAirbases(Group.getByName(fireGroup):getCoalition())
				-- for abCount = 1, #avaliAB do
					
					-- if Airbase.getCategory(avaliAB[abCount]) == 0 then
					-- --trigger.action.outTextForCoalition(Group.getByName(fireGroup):getCoalition(),Group.getByName(fireGroup):getUnit(1):getTypeName() .. " is winchester and RTB for rearm at " .. Airbase.getCallsign((avaliAB[abCount]),10)
					-- local rearm = {} 
					-- rearm = {
						-- id = 'Mission', 
						
						-- params = {
									-- airborne = true,
									-- route = {
												-- points = {--firePointWpt--,previousTask
															-- [1] = {
																	-- ["x"] = 0,
																	-- ["y"] = 0,
																	-- ["type"] =  "LandingReFuAr",
																	-- ["action"] =  "LandingReFuAr",
																	-- ["alt"] =0,
																	-- ["speed"] =  e.initiator:getUnit(1):getVelocity(),
																	-- ["airdromeId"] = Airbase.getID(avaliAB[abCount]),
																	-- ["timeReFuAr"] = 10,
																	-- --["alt_type"] =
																	-- --["task"] = {}
																	-- },
														-- }
											-- }
								-- },
					-- }
					
					
					-- trigger.action.outTextForCoalition(Group.getByName(fireGroup):getCoalition(),Group.getByName(fireGroup):getUnit(1):getTypeName() .. " is winchester and RTB for rearm at " .. Airbase.getCallsign(avaliAB[abCount]),10)
						-- break
					-- end
				-- end
				-- Unit.getGroup(e.initiator):getController():pushTask(rearm)			
			end
		end
	end
end

function fac.explosions(args)
	local tgtPnt = args[1]
	local explodePnt = {}

	explodePnt.x = tgtPnt.x + math.random(-15,15) 
	explodePnt.z = tgtPnt.z + math.random(-15,15)
	explodePnt.y = tgtPnt.y

	trigger.action.explosion(explodePnt, 10)

end

world.addEventHandler(facArtyFireDetect)

function fac.checkTask(_args)
	local _i
	local _j	
	local _facUnitName = _args[1]
	local _facUnit = Unit.getByName(_facUnitName)
	local _facGroup = _facUnit:getGroup()
	local _groupId = fac.getGroupId(_facUnit)
	trigger.action.outTextForCoalition(_facGroup:getCoalition(), "Checking artillery/bomber units" ,10)
	local _enemyUnit = fac.getCurrentFacUnit(_facUnit, _facUnitName)
	local _artyInRange = fac.getArty(_enemyUnit,_facUnit,1)
	local artyList = fac.ArtyTasked
	
	local tp 
	local _TGTdist = -1

	--trigger.action.outTextForCoalition(_facGroup:getCoalition(), tablelength(fac.ArtyTasked),10)
	for _i, _j in pairs(fac.ArtyTasked) do
		if tablelength(fac.ArtyTasked) > 0 then 
			local fireGroup = _i
			if _facGroup:getCoalition() == Group.getByName(fireGroup):getCoalition() and  Group.getByName(fireGroup):getUnit(1):isActive() and  Group.getByName(fireGroup):isExist() then
				local _artyPos = Group.getByName(fireGroup):getUnit(1):getPoint()
				if _enemyUnit ~= nil then 
					tp = _enemyUnit:getPoint()
					_TGTdist = math.sqrt(((tp.z-_artyPos.z)^2)+((tp.x-_artyPos.x)^2))
				end
				local ammoCount = fac.artyGetAmmo(Group.getByName(fireGroup):getUnits())
				trigger.action.outTextForCoalition(Group.getByName(fireGroup):getCoalition(),Group.getByName(fireGroup):getUnit(1):getTypeName() .. " Tasked rounds remaining: "..fac.ArtyTasked[fireGroup].tasked .. " Current Ammo: " .. ammoCount .." " .. math.floor(_TGTdist) ,10)
			end
		else
			trigger.action.outTextForCoalition(_facGroup:getCoalition(), "No active artillery detected, build some artillery units with CTLD!!" ,10)
		end
	end
end

function fac.callFireMission(_args)
	local _facUnitName = _args[1]
	local _artyRounds = _args[2] 
	local _roundType = _args[3]
	local _enemyUnit = nil
	local _artyInRange = nil 
	local _facUnit = Unit.getByName(_facUnitName)
	local _groupId = fac.getGroupId(_facUnit)
	local _illumPoint = {}
	local tp
	local spotterName
	local msgTime = 10
	
	
	
	if fac.getFacName(_facUnitName) == nil then
		spotterName = "AI Spotter"
	else
		spotterName = fac.getFacName(_facUnitName)
	end
	
	if _args[4] == nil then 
		_enemyUnit = fac.getCurrentFacUnit(_facUnit, _facUnitName)
	else
		 _enemyUnit = _args[4]
	end
	
	if  _roundType < 4 then
		_artyInRange = fac.getArty(_enemyUnit,_facUnit,_roundType)
	else 
		_artyInRange = fac.getBomber(_enemyUnit,_facUnit,_roundType)
	end
	
	if _enemyUnit == nil  or _artyInRange == nil then
		if _enemyUnit == nil and _artyInRange ~= nil then
			if _roundType ~= 1 then
				if _roundType ~= -1 then
					trigger.action.outTextForGroup(_groupId,"Unable to process fire mission",10)
					trigger.action.outTextForGroup(_groupId,"No Valid Target",10)
				end
			else
				tp = fac.facOffsetMaker(_facUnit)
				_illumPoint.x = tp.x
				_illumPoint.y = tp.y + fac.illumHeight
				_illumPoint.z = tp.z
				trigger.action.illuminationBomb(_illumPoint,500)
				trigger.action.outTextForCoalition(_facUnit:getCoalition(),"Fire mission order sent, " .._artyInRange:getUnit(1):getTypeName() .. " Task Group is firing illumination rounds " .. fac.facOffsetDist .. " m from " ..spotterName,10)
			end
		elseif _artyInRange == nil then
			if _roundType ~= -1 then
				trigger.action.outTextForGroup(_groupId,"Unable to process fire mission",10)
				trigger.action.outTextForGroup(_groupId,"No untasked active artillery/bomber in range of target",10)
			end
		end
	else
		--if _enemyUnit:getCoalition() == 1 then
			if _roundType ~= 1 then
				if fac.ArtyTasked[_artyInRange:getName()] == nil  or fac.ArtyTasked[_artyInRange:getName()].tasked == 0 then 
					--table.insert (fac.ArtyTasked, _artyInRange:getName())
					--fac.ArtyTasked[_artyInRange:getName()]
					fac.ArtyTasked[_artyInRange:getName()]= {name = _artyInRange:getName(), tasked = 0}
					if _artyInRange:getUnit(1):hasAttribute('Strategic bombers') or _artyInRange:getUnit(1):hasAttribute('Bombers') then
				--local firemission = {id = 'Bombing', params = firepoint}
						--timer.scheduleFunction(fac.purgeArtList,{_artyInRange:getName()},timer.getTime()+ 20)
					else
						--timer.scheduleFunction(fac.purgeArtList,{_artyInRange:getName()},timer.getTime()+ 600)
					end
					--timer.scheduleFunction(fac.clearTask,{_artyInRange:getController(),1},timer.getTime()+ 20*_artyRounds+180)
				end
			end
			--trigger.action.outText(table.getn(fac.redArty) .. "insert blu" ,10)
		-- else
			-- if _roundType ~= 1 then 
				-- table.insert (fac.ArtyTasked, _artyInRange:getName())
				-- timer.scheduleFunction(fac.purgeArtList,{_artyInRange:getName()},timer.getTime()+ 180)
			-- end
			-- --trigger.action.outText(table.getn(fac.redArty) .. "insert red" ,10)
		-- end
		
		local _artyPos = _artyInRange:getUnit(1):getPoint()
		 
		
		local firepoint = {}
		tp = _enemyUnit:getPoint()
		local _fireOffset = {x = 0,y = 0,z =0}
		--local _fireOffset.y = 0
		local dx = tp.x-_artyPos.x
		local dy = tp.z-_artyPos.z
		local fpNorthOffset = getNorthCorrection(tp)
		
		local _fireheading = math.atan(dy/dx)

		--correcting for coordinate space
		local _FH = 1
		if dy < 0 then -- dy = -1 90-270
			if dx < 0 then  --dy/dx = 1 180-270
				--trigger.action.outText(_artyInRange:getName().." Firing SW:\n".. (_fireheading/math.pi)*180 .."\n", 300)
				_fireheading= _fireheading  + 2*math.pi
			else
				--trigger.action.outText(_artyInRange:getName().." Firing SE:\n".. (_fireheading/math.pi)*180 .."\n", 300)
				_fireheading= _fireheading + math.pi
			end
		elseif dy > 0 then --dy = 1 270-90
			if dx < 0 then --dy/dx = -1 270-0
				--trigger.action.outText(_artyInRange:getName().." Firing NW:\n".. (_fireheading/math.pi)*180 .."\n", 300)
				_fireheading= _fireheading  + 2*math.pi
			else --dy/dx = 1 0-90
				--trigger.action.outText(_artyInRange:getName().." Firing NE:\n".. (_fireheading/math.pi)*180 .."\n", 300)
				_fireheading= _fireheading
				_FH = -1
			end
			
		end
		local headingDeg =(_fireheading)/math.pi*180
		if headingDeg >= 360 then
			headingDeg = headingDeg-360
		end
		--trigger.action.outText(_artyInRange:getName().."\ndY ".. dy .."\ndX ".. dx .."\ndy/dx" .. dy/dx .."\nrad ".. _fireheading/math.pi .."\ndeg " .. headingDeg,120)

		--_fireheading = _fireheading 
		
		
		local _TGTdist = math.sqrt(((tp.z-_artyPos.z)^2)+((tp.x-_artyPos.x)^2))
		local _TGThghtD = math.abs(tp.y-_artyPos.y)
		if _artyInRange:getUnit(1):getTypeName() == "2B11 mortar" then
			
			_fireOffset.x = math.cos(_fireheading)*(-(100+_TGThghtD/10))*_FH
			_fireOffset.z = math.sin(_fireheading)*(-(100+_TGThghtD/10))*_FH
			
		elseif _artyInRange:getUnit(1):hasAttribute('Strategic bombers') or _artyInRange:getUnit(1):hasAttribute('Bombers') then
			_artyRounds = 1
		end
		firepoint.x = tp.x + _fireOffset.x
		firepoint.y = tp.z + _fireOffset.z
		--firepoint.radius = 10
		
		local firemission = {}
		
		local ammoRemain = fac.artyGetAmmo(_artyInRange:getUnits())
		if _artyInRange:getUnit(1):hasAttribute('Naval') then
			local tempAmmoRemain = {}
			tempAmmoRemain = fac.artyGetNavalGunAmmo(_artyInRange:getUnits())
			ammoRemain = tempAmmoRemain[1]
		end
		if ammoRemain < _artyRounds then
			_artyRounds = ammoRemain
		end
		
		if _artyInRange:getUnit(1):hasAttribute('Strategic bombers') or _artyInRange:getUnit(1):hasAttribute('Bombers') then
			local bomberTasked = _artyInRange:getUnit(1)
			local payloadCheck = {}
			payloadCheck = bomberTasked:getAmmo()
			if payloadCheck[1].desc.guidance == nil or payloadCheck[1].desc.guidance == 7 then
				--trigger.action.outText(bomberTasked:getTypeName(),10)
				--trigger.action.outText(#payloadCheck,10)				
				firepoint.expend = "Quarter"
			else
				--trigger.action.outText( payloadCheck[1].desc.guidance,120)
				firepoint.expend = "One"
			end
			firepoint.attackQty = 1
			firepoint.altitude = _artyPos.y
			firepoint.altitudeEnabled = true
			firemission = {id = 'Bombing', params = firepoint}
			_artyInRange:getController():setOption(1,1)
			_artyInRange:getController():setOption(10,3221225470)
		elseif _artyInRange:getUnit(1):hasAttribute('MLRS') or (_artyInRange:getUnit(2) ~= nil and _artyInRange:getUnit(2):hasAttribute('MLRS')) then
			firepoint.expendQty = _artyRounds		
			firepoint.expendQtyEnabled = true
			firepoint.weaponType = 30720 
			firemission = {id = 'FireAtPoint', params = firepoint}
		
		else
			firepoint.expendQty = _artyRounds		
			firepoint.expendQtyEnabled = true
			firepoint.weaponType = 258503344128
			firemission = {id = 'FireAtPoint', params = firepoint}
			
		end
		

		

		
		-- local firepoint2 ={}
		-- firepoint2.groupId = fac.getGroupId(_enemyUnit)
		-- firepoint2.expend = "Quarter"	
		-- local firemission = {id = 'AttackGroup', params = firepoint2}

		if _roundType ~= 1 then
			--_artyInRange:getController():setOption(9,2)
			local artyController = _artyInRange:getController()
			--timer.scheduleFunction(fac.fireArty,{artyController,firemission},timer.getTime() + .5)
			artyController:pushTask(firemission)
			--_artyInRange:getController():setOption(9,0)
			--if _roundType ~= -1 then 
				fac.ArtyTasked[_artyInRange:getName()]= {name = _artyInRange:getName(), tasked = _artyRounds ,timeTasked = timer.getTime() ,tgt = _enemyUnit, requestor = spotterName}
			--end
			--Controller.knowTarget(_artyInRange:getUnit(3):getController(),_enemyUnit)
			trigger.action.outTextForGroup(_artyInRange:getID(),"Az: "..math.floor(headingDeg).." Range: ".._TGTdist,30)
			--trigger.action.outTextForGroup(_groupId,"Az: "..math.floor(headingDeg).." Range: ".._TGTdist,60)
			--local ammoRemain = fac.artyGetAmmo(_artyInRange:getUnits())

			local displayUnitName = _artyInRange:getUnit(1):getDesc()
			if _roundType == -1 then
				msgTime = 1
			end
			trigger.action.outTextForCoalition(_facUnit:getCoalition(),"Fire mission order sent, " .. displayUnitName.displayName .. " Task Group(".. ammoRemain .. " rounds remaining"..") firing ".._artyRounds.." rounds at " .. _enemyUnit:getTypeName() .. ". Requestor: " .. spotterName ,msgTime)
			timer.scheduleFunction(fac.purgeArtList,{_artyInRange:getName(),_artyRounds}, timer.getTime() + 200)
		else
			
			_illumPoint.x = tp.x
			_illumPoint.y = tp.y + fac.illumHeight
			_illumPoint.z = tp.z
			trigger.action.illuminationBomb(_illumPoint,500)
			trigger.action.outTextForCoalition(_facUnit:getCoalition(),"Fire mission order sent, " .. displayUnitName.displayName .. "Task Group is firing illumination rounds at " .. _enemyUnit:getTypeName() .. ". Requestor: " .. spotterName,10)
		end
		
	end
end

function fac.fireArty(_args)
_args[1]:pushTask(_args[2])
end

function fac.artyAICall()
	--local atyDunitName
	--trigger.action.outText("Tasking AI to call ARTY", 10)
	fac.AITgted = {}
	local aiARTYmultiTgt = {}
	for _, atyDunitName in pairs(fac.artDirectNames) do
		--trigger.action.outText(atyDunitName.. " found", 10)
        local status, error = pcall(function()

            local _unitR = fac.getFacUnit(atyDunitName)

            if _unitR ~= nil then
				--trigger.action.outText(atyDunitName.. " calling ARTY", 10)
                local _groupIdR = fac.getGroupId(_unitR)
				
                if _groupIdR then
					--trigger.action.outText(atyDunitName.. " calling ARTY2", 10)
					aiARTYmultiTgt = fac.scanForTGTai({atyDunitName})
	--				local i
					for  i = 1, #aiARTYmultiTgt do
					
						if contains(fac.AITgted,aiARTYmultiTgt[i]:getName()) == false then 
							table.insert(fac.AITgted, aiARTYmultiTgt[i]:getName())
							if aiARTYmultiTgt[i]:isExist() then
								--trigger.action.outText(atyDunitName.. " calling ARTY on " .. aiARTYmultiTgt[i]:getName(), 10)
								fac.callFireMission({atyDunitName,10,-1,aiARTYmultiTgt[i]})
							end
						end
					end
				end
            --[[else
                env.info(string.format("FAC DEBUG: unit nil %s",_facUnitName)) ]]
            end
        end)

        if (not status) then
            env.error(string.format("Error adding f10 to ARTY Spotter: %s", error), false)
        end
    end
	if ctld then
		local troopTypeIDX
		local transportIDX
		local onboardArtD = false
		for _i, transportIDX in pairs(ctld.inTransitTroops) do
			--trigger.action.outText(transportIDX.. " found", 10)
			--local onboardTroops = ctld.inTransitTroops[_i]
			--trigger.action.outText(transportIDX.troops.type .. " found", 10)
			if transportIDX.troops ~= nil then
				--trigger.action.outText(transportIDX.troops .. " found", 10)
				for _j, troopTypeIDX in pairs(transportIDX.troops.units) do
					--trigger.action.outText(troopTypeIDX.type .. "on" .. _i .. " found", 10)
					if contains(fac.artyDirectorTypes,troopTypeIDX.type) then
						onboardArtD = true
						break
					end
				end
				if onboardArtD == true then 
					aiARTYmultiTgt = fac.scanForTGTai({_i})
	--				local i
					for  i = 1, #aiARTYmultiTgt do
					
						if contains(fac.AITgted,aiARTYmultiTgt[i]:getName()) == false then 
							table.insert(fac.AITgted, aiARTYmultiTgt[i]:getName())
							if aiARTYmultiTgt[i]:isExist() then
								--trigger.action.outText(atyDunitName.. " calling ARTY on " .. aiARTYmultiTgt[i]:getName(), 10)
								fac.callFireMission({_i,10,-1,aiARTYmultiTgt[i]})
							end
						end
					end
				end
			end
		end
	end
	--fac.AITgted = {}
	timer.scheduleFunction(fac.artyAICall, nil, timer.getTime() + 30)
end


-- Scheduled functions (run cyclically)

timer.scheduleFunction(fac.addFacF10MenuOptions, nil, timer.getTime() + 5.5)
timer.scheduleFunction(fac.checkFacStatus, nil, timer.getTime() + 5.4)
timer.scheduleFunction(fac.artyAICall, nil, timer.getTime() + 5)
