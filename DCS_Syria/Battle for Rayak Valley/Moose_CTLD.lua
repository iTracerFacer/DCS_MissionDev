--[ MOOSE CTLD v1.0]
--[ Created by: F99th-TracerFacer
--[ Date: Nov2024

local pointsAwardedTroopsDeployed = 1
local pointsAwardedTroopsExtracted = 1
local pointsAwardedTroopsPickedup = 1
local pointsAwardedTroopsRTB = 1
local pointsAwardedCrateDropped = 1
local pointsAwardedCrateBuilt = 1
local pointsAwardedCrateRepair = 1
local msgTime = 10


-- Setup CTLD for Red and Blue Coalitions
local red_helos = SET_GROUP:New():FilterCoalitions("red"):FilterCategoryHelicopter():FilterStart()
local red_ctld = CTLD:New(coalition.side.RED)
red_ctld.SetOwnSetPilotGroups(red_helos)


local blue_helos = SET_GROUP:New():FilterCoalitions("blue"):FilterCategoryHelicopter():FilterStart()
local blue_ctld = CTLD:New(coalition.side.BLUE)
blue_ctld.SetOwnSetPilotGroups(blue_helos)


red_ctld.useprefix = false -- (DO NOT SWITCH THIS OFF UNLESS YOU KNOW WHAT YOU ARE DOING!) Adjust **before** starting CTLD. If set to false, *all* choppers of the coalition side will be enabled for CTLD.
red_ctld.CrateDistance = 50 -- List and Load crates in this radius only.
red_ctld.PackDistance = 50 -- Pack crates in this radius only
red_ctld.dropcratesanywhere = true -- Option to allow crates to be dropped anywhere.
red_ctld.dropAsCargoCrate = false -- Parachuted herc cargo is not unpacked automatically but placed as crate to be unpacked. Needs a cargo with the same name defined like the cargo that was dropped.
red_ctld.maximumHoverHeight = 15 -- Hover max this high to load.
red_ctld.minimumHoverHeight = 4 -- Hover min this low to load.
red_ctld.forcehoverload = false -- Crates (not: troops) can **only** be loaded while hovering.
red_ctld.hoverautoloading = true -- Crates in CrateDistance in a LOAD zone will be loaded automatically if space allows.
red_ctld.smokedistance = 10000 -- Smoke or flares can be request for zones this far away (in meters).
red_ctld.movetroopstowpzone = true -- Troops and vehicles will move to the nearest MOVE zone...
red_ctld.movetroopsdistance = 5000 -- .. but only if this far away (in meters)
red_ctld.suppressmessages = false -- Set to true if you want to script your own messages.
red_ctld.repairtime = 300 -- Number of seconds it takes to repair a unit.
red_ctld.buildtime = 300 -- Number of seconds it takes to build a unit. Set to zero or nil to build instantly.
red_ctld.cratecountry = country.id.GERMANY -- ID of crates. Will default to country.id.RUSSIA for RED coalition setups.
red_ctld.allowcratepickupagain = true  -- allow re-pickup crates that were dropped.
red_ctld.enableslingload = true -- allow cargos to be slingloaded - might not work for all cargo types
red_ctld.pilotmustopendoors = true -- force opening of doors
red_ctld.SmokeColor = SMOKECOLOR.Red -- default color to use when dropping smoke from heli 
red_ctld.FlareColor = FLARECOLOR.Red -- color to use when flaring from heli
red_ctld.basetype = "ammo_cargo" -- default shape of the cargo container
red_ctld.droppedbeacontimeout = 600 -- dropped beacon lasts 10 minutes
red_ctld.usesubcats = false -- use sub-category names for crates, adds an extra menu layer in "Get Crates", useful if you have > 10 crate types.
red_ctld.placeCratesAhead = true -- place crates straight ahead of the helicopter, in a random way. If true, crates are more neatly sorted.
red_ctld.nobuildinloadzones = true -- forbid players to build stuff in LOAD zones if set to `true`
red_ctld.movecratesbeforebuild = false -- crates must be moved once before they can be build. Set to false for direct builds.
red_ctld.surfacetypes = {land.SurfaceType.LAND,land.SurfaceType.ROAD,land.SurfaceType.RUNWAY,land.SurfaceType.SHALLOW_WATER} -- surfaces for loading back objects.
red_ctld.nobuildmenu = false -- if set to true effectively enforces to have engineers build/repair stuff for you.
red_ctld.RadioSound = "beaconsilent.ogg" -- -- this sound will be hearable if you tune in the beacon frequency. Add the sound file to your miz.
red_ctld.RadioSoundFC3 = "beaconsilent.ogg" -- this sound will be hearable by FC3 users (actually all UHF radios); change to something like "beaconsilent.ogg" and add the sound file to your miz if you don't want to annoy FC3 pilots.
red_ctld.enableChinookGCLoading = true -- this will effectively suppress the crate load and drop for CTLD_CARGO.Enum.STATIc types for CTLD for the Chinook
red_ctld.TroopUnloadDistGround = 5 -- If hovering, spawn dropped troops this far away in meters from the helo
red_ctld.TroopUnloadDistHover = 1.5 -- If grounded, spawn dropped troops this far away in meters from the helo
red_ctld.TroopUnloadDistGroundHerc = 25 -- On the ground, unload troops this far behind the Hercules
red_ctld.TroopUnloadDistGroundHook = 15 -- On the ground, unload troops this far behind the Chinook
red_ctld.EngineerSearch = 2000 -- Search radius for engineers. 

blue_ctld.useprefix = false -- (DO NOT SWITCH THIS OFF UNLESS YOU KNOW WHAT YOU ARE DOING!) Adjust **before** starting CTLD. If set to false, *all* choppers of the coalition side will be enabled for CTLD.
blue_ctld.CrateDistance = 50 -- List and Load crates in this radius only.
blue_ctld.PackDistance = 50 -- Pack crates in this radius only
blue_ctld.dropcratesanywhere = true -- Option to allow crates to be dropped anywhere.
blue_ctld.dropAsCargoCrate = false -- Parachuted herc cargo is not unpacked automatically but placed as crate to be unpacked. Needs a cargo with the same name defined like the cargo that was dropped.
blue_ctld.maximumHoverHeight = 15 -- Hover max this high to load.
blue_ctld.minimumHoverHeight = 4 -- Hover min this low to load.
blue_ctld.forcehoverload = false -- Crates (not: troops) can **only** be loaded while hovering.
blue_ctld.hoverautoloading = true -- Crates in CrateDistance in a LOAD zone will be loaded automatically if space allows.
blue_ctld.smokedistance = 10000 -- Smoke or flares can be request for zones this far away (in meters).
blue_ctld.movetroopstowpzone = true -- Troops and vehicles will move to the nearest MOVE zone...
blue_ctld.movetroopsdistance = 5000 -- .. but only if this far away (in meters)
blue_ctld.suppressmessages = false -- Set to true if you want to script your own messages.
blue_ctld.repairtime = 120 -- Number of seconds it takes to repair a unit.
blue_ctld.buildtime = 120 -- Number of seconds it takes to build a unit. Set to zero or nil to build instantly.
blue_ctld.cratecountry = country.id.GERMANY -- ID of crates. Will default to country.id.RUSSIA for RED coalition setups.
blue_ctld.allowcratepickupagain = true  -- allow re-pickup crates that were dropped.
blue_ctld.enableslingload = true -- allow cargos to be slingloaded - might not work for all cargo types
blue_ctld.pilotmustopendoors = true -- force opening of doors
blue_ctld.SmokeColor = SMOKECOLOR.Blue -- default color to use when dropping smoke from heli 
blue_ctld.FlareColor = FLARECOLOR.Blue -- color to use when flaring from heli
blue_ctld.basetype = "ammo_cargo" -- default shape of the cargo container
blue_ctld.droppedbeacontimeout = 600 -- dropped beacon lasts 10 minutes
blue_ctld.usesubcats = false -- use sub-category names for crates, adds an extra menu layer in "Get Crates", useful if you have > 10 crate types.
blue_ctld.placeCratesAhead = true -- place crates straight ahead of the helicopter, in a random way. If true, crates are more neatly sorted.
blue_ctld.nobuildinloadzones = true -- forbid players to build stuff in LOAD zones if set to `true`
blue_ctld.movecratesbeforebuild = false -- crates must be moved once before they can be build. Set to false for direct builds.
blue_ctld.surfacetypes = {land.SurfaceType.LAND,land.SurfaceType.ROAD,land.SurfaceType.RUNWAY,land.SurfaceType.SHALLOW_WATER} -- surfaces for loading back objects.
blue_ctld.nobuildmenu = false -- if set to true effectively enforces to have engineers build/repair stuff for you.
blue_ctld.RadioSound = "beaconsilent.ogg" -- -- this sound will be hearable if you tune in the beacon frequency. Add the sound file to your miz.
blue_ctld.RadioSoundFC3 = "beaconsilent.ogg" -- this sound will be hearable by FC3 users (actually all UHF radios); change to something like "beaconsilent.ogg" and add the sound file to your miz if you don't want to annoy FC3 pilots.
blue_ctld.enableChinookGCLoading = true -- this will effectively suppress the crate load and drop for CTLD_CARGO.Enum.STATIc types for CTLD for the Chinook
blue_ctld.TroopUnloadDistGround = 5 -- If hovering, spawn dropped troops this far away in meters from the helo
blue_ctld.TroopUnloadDistHover = 1.5 -- If grounded, spawn dropped troops this far away in meters from the helo
blue_ctld.TroopUnloadDistGroundHerc = 25 -- On the ground, unload troops this far behind the Hercules
blue_ctld.TroopUnloadDistGroundHook = 15 -- On the ground, unload troops this far behind the Chinook
blue_ctld.EngineerSearch = 2000 -- Search radius for engineers.

--[[]
-- Default unit type capabilities are: 
["SA342Mistral"] = {type="SA342Mistral", crates=false, troops=true, cratelimit = 0, trooplimit = 4, length = 12, cargoweightlimit = 400},
["SA342L"] = {type="SA342L", crates=false, troops=true, cratelimit = 0, trooplimit = 2, length = 12, cargoweightlimit = 400},
["SA342M"] = {type="SA342M", crates=false, troops=true, cratelimit = 0, trooplimit = 4, length = 12, cargoweightlimit = 400},
["SA342Minigun"] = {type="SA342Minigun", crates=false, troops=true, cratelimit = 0, trooplimit = 2, length = 12, cargoweightlimit = 400},
["UH-1H"] = {type="UH-1H", crates=true, troops=true, cratelimit = 1, trooplimit = 8, length = 15, cargoweightlimit = 700},
["Mi-8MT"] = {type="Mi-8MT", crates=true, troops=true, cratelimit = 2, trooplimit = 12, length = 15, cargoweightlimit = 3000},
["Mi-8MTV2"] = {type="Mi-8MTV2", crates=true, troops=true, cratelimit = 2, trooplimit = 12, length = 15, cargoweightlimit = 3000},
["Ka-50"] = {type="Ka-50", crates=false, troops=false, cratelimit = 0, trooplimit = 0, length = 15, cargoweightlimit = 0},
["Mi-24P"] = {type="Mi-24P", crates=true, troops=true, cratelimit = 2, trooplimit = 8, length = 18, cargoweightlimit = 700},
["Mi-24V"] = {type="Mi-24V", crates=true, troops=true, cratelimit = 2, trooplimit = 8, length = 18, cargoweightlimit = 700},
["Hercules"] = {type="Hercules", crates=true, troops=true, cratelimit = 7, trooplimit = 64, length = 25, cargoweightlimit = 19000},
["UH-60L"] = {type="UH-60L", crates=true, troops=true, cratelimit = 2, trooplimit = 20, length = 16, cargoweightlimit = 3500},
["AH-64D_BLK_II"] = {type="AH-64D_BLK_II", crates=false, troops=true, cratelimit = 0, trooplimit = 2, length = 17, cargoweightlimit = 200}, 
["MH-60R"] = {type="MH-60R", crates=true, troops=true, cratelimit = 2, trooplimit = 20, length = 16, cargoweightlimit = 3500}, -- 4t cargo, 20 (unsec) seats
["SH-60B"] = {type="SH-60B", crates=true, troops=true, cratelimit = 2, trooplimit = 20, length = 16, cargoweightlimit = 3500}, -- 4t cargo, 20 (unsec) seats
["Bronco-OV-10A"] = {type="Bronco-OV-10A", crates= false, troops=true, cratelimit = 0, trooplimit = 5, length = 13, cargoweightlimit = 1450},
["Bronco-OV-10A"] = {type="Bronco-OV-10A", crates= false, troops=true, cratelimit = 0, trooplimit = 5, length = 13, cargoweightlimit = 1450},
["OH-6A"] = {type="OH-6A", crates=false, troops=true, cratelimit = 0, trooplimit = 4, length = 7, cargoweightlimit = 550},
["OH58D"] = {type="OH58D", crates=false, troops=false, cratelimit = 0, trooplimit = 0, length = 14, cargoweightlimit = 400},
["CH-47Fbl1"] = {type="CH-47Fbl1", crates=true, troops=true, cratelimit = 4, trooplimit = 31, length = 20, cargoweightlimit = 8000},
--]]

-- Start the CTLD Instances
red_ctld:Start(5)
blue_ctld:Start(5)

-- Add Anti Tank Teams
red_ctld:AddTroopsCargo("Anti-Tank Team Small (3)",{"Red-ATS"}, CTLD_CARGO.Enum.TROOPS, 3, 80)
red_ctld:AddTroopsCargo("Anti-Tank Team Medium (10)",{"Red-ATM"}, CTLD_CARGO.Enum.TROOPS, 10, 80)

blue_ctld:AddTroopsCargo("Anti-Tank Team Small (3)",{"Blue-ATS"}, CTLD_CARGO.Enum.TROOPS, 3, 80)
blue_ctld:AddTroopsCargo("Anti-Tank Team Medium (10)",{"Blue-ATM"}, CTLD_CARGO.Enum.TROOPS, 10, 80)

-- Add Mortar Teams
red_ctld:AddTroopsCargo("Mortar Team (3)",{"Red-MTS"}, CTLD_CARGO.Enum.TROOPS, 3, 80)
red_ctld:AddTroopsCargo("Mortar Team (10)",{"Red-MTM"}, CTLD_CARGO.Enum.TROOPS, 10, 80)

blue_ctld:AddTroopsCargo("Mortar Team (3)",{"Blue-MTS"}, CTLD_CARGO.Enum.TROOPS, 3, 80)
blue_ctld:AddTroopsCargo("Mortar Team (10)",{"Blue-MTM"}, CTLD_CARGO.Enum.TROOPS, 10, 80)

-- Add Anti Air Teams
red_ctld:AddTroopsCargo("Anti-Air (4)",{"Red-AA"},CTLD_CARGO.Enum.TROOPS, 4, 80, 10)

blue_ctld:AddTroopsCargo("Anti-Air(4)",{"Blue-AA"},CTLD_CARGO.Enum.TROOPS, 4, 80, 10)

-- Add Engineers
--red_ctld:AddTroopsCargo("Engineer Team (3)",{"Red-Eng"},CTLD_CARGO.Enum.ENGINEERS, 3, 80)
--blue_ctld:AddTroopsCargo("Engineer Team (3)",{"Blue-Eng"},CTLD_CARGO.Enum.ENGINEERS, 3, 80)

-- Add Ammo Trucks
red_ctld:AddCratesCargo("Ammo Truck",{"Red-Ammo"},CTLD_CARGO.Enum.VEHICLE, 2, 500, 10)
blue_ctld:AddCratesCargo("Ammo Truck",{"Blue-Ammo"},CTLD_CARGO.Enum.VEHICLE, 2, 500, 10)

-- Add JTACs
--red_ctld:AddCratesCargo("JTAC",{"Red-JTAC"},CTLD_CARGO.Enum.VEHICLE, 1, 2775, 10) -- no soup for you commie bitches!
blue_ctld:AddCratesCargo("JTAC",{"FAC GROUND"},CTLD_CARGO.Enum.VEHICLE, 1, 500, 10)

-- Add HUMVEE
-- blue_ctld:AddCratesCargo("HUMVEE",{"Blue-HUMVEE"},CTLD_CARGO.Enum.VEHICLE, 1, 500, 25)  

-- Add Tanks
red_ctld:AddCratesCargo("T-90",{"Red-T90"},CTLD_CARGO.Enum.VEHICLE, 1, 8500, 25)
blue_ctld:AddCratesCargo("M1A2",{"Blue-M1A2"},CTLD_CARGO.Enum.VEHICLE, 1, 8500, 25)

-- Add FOBs
red_ctld:AddCratesCargo("Forward Ops Base",{"Red-FOB"},CTLD_CARGO.Enum.FOB, 4, 500, 5)
blue_ctld:AddCratesCargo("Forward Ops Base",{"Blue-FOB"},CTLD_CARGO.Enum.FOB, 4, 500, 5)

-- AA Crates
red_ctld:AddCratesCargo("SA-8",{"SA8"},CTLD_CARGO.Enum.CRATE, 4, 500, 10)
red_ctld:AddCratesCargo("SA-6",{"SA6"},CTLD_CARGO.Enum.CRATE, 4, 500, 10)
red_ctld:AddCratesCargo("SA-10",{"SA10"},CTLD_CARGO.Enum.CRATE, 6, 500, 10)

blue_ctld:AddCratesCargo("Linebacker",{"LINEBACKER"},CTLD_CARGO.Enum.CRATE, 2, 500, 5)
blue_ctld:AddCratesCargo("Hawk Site",{"HAWK"},CTLD_CARGO.Enum.CRATE, 4, 500, 4)
blue_ctld:AddCratesCargo("Patriot Site",{"PATRIOT"},CTLD_CARGO.Enum.CRATE, 12, 500, 4)




-- Add 6 Red Load Zones that are active but have no beacon.
red_ctld:AddCTLDZone("RedLoadZone1", CTLD.CargoZoneType.LOAD, SMOKECOLOR.Red, true, false) 
red_ctld:AddCTLDZone("RedLoadZone2", CTLD.CargoZoneType.LOAD, SMOKECOLOR.Red, true, false)
red_ctld:AddCTLDZone("RedLoadZone3", CTLD.CargoZoneType.LOAD, SMOKECOLOR.Red, true, false)
red_ctld:AddCTLDZone("RedLoadZone4", CTLD.CargoZoneType.LOAD, SMOKECOLOR.Red, true, false)
red_ctld:AddCTLDZone("RedLoadZone5", CTLD.CargoZoneType.LOAD, SMOKECOLOR.Red, true, false)
red_ctld:AddCTLDZone("RedLoadZone6", CTLD.CargoZoneType.LOAD, SMOKECOLOR.Red, true, false)

-- Add 6 Blue Load Zones that are active but have no beacon.
blue_ctld:AddCTLDZone("BlueLoadZone1", CTLD.CargoZoneType.LOAD, SMOKECOLOR.Blue, true, false)
blue_ctld:AddCTLDZone("BlueLoadZone2", CTLD.CargoZoneType.LOAD, SMOKECOLOR.Blue, true, false)
blue_ctld:AddCTLDZone("BlueLoadZone3", CTLD.CargoZoneType.LOAD, SMOKECOLOR.Blue, true, false)
blue_ctld:AddCTLDZone("BlueLoadZone4", CTLD.CargoZoneType.LOAD, SMOKECOLOR.Blue, true, false)
blue_ctld:AddCTLDZone("BlueLoadZone5", CTLD.CargoZoneType.LOAD, SMOKECOLOR.Blue, true, false)
blue_ctld:AddCTLDZone("BlueLoadZone6", CTLD.CargoZoneType.LOAD, SMOKECOLOR.Blue, true, false)
blue_ctld:AddCTLDZone("BlueLoadZone7", CTLD.CargoZoneType.LOAD, SMOKECOLOR.Blue, true, false)
blue_ctld:AddCTLDZone("BlueLoadZone8", CTLD.CargoZoneType.LOAD, SMOKECOLOR.Blue, true, false)
blue_ctld:AddCTLDZone("BlueLoadZone9", CTLD.CargoZoneType.LOAD, SMOKECOLOR.Blue, true, false)
blue_ctld:AddCTLDZone("BlueLoadZone10", CTLD.CargoZoneType.LOAD, SMOKECOLOR.Blue, true, false)



------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DO NOT EDIT BELOW THIS LINE
------------------------------------------------------------------------------------------------------------------------------------------------------------------

function blue_ctld:OnAfterTroopsDeployed(From,Event,To,Group,Unit,Troops)
    if Unit then
      local PlayerName = Unit:GetPlayerName()
      local vname = Troops:GetName()
      local points = pointsAwardedTroopsDeployed
      MESSAGE:New("Pilot " .. PlayerName .. " has deployed " .. vname .. " to the field!", msgTime, "[ Mission Info ]", false):ToBlue()
      USERSOUND:New("combatAudio5.ogg"):ToCoalition(coalition.side.BLUE)
      US_Score:_AddPlayerFromUnit( Unit )
      US_Score:AddGoalScore(Unit, "CTLD", string.format("Pilot %s has been awarded %d points for deploying troops!", PlayerName, points), points)
    end
end
  
  function blue_ctld:OnAfterTroopsExtracted(From,Event,To,Group,Unit,Cargo)
    if Unit then
      local PlayerName = Unit:GetPlayerName()
      local vname = Cargo:GetName() 
      local points = pointsAwardedTroopsExtracted
      MESSAGE:New("Pilot " .. PlayerName .. " has extracted " .. vname .. " from the field!", msgTime, "[ Mission Info ]", false):ToBlue()
      USERSOUND:New("getToTheChoppa.ogg"):ToCoalition(coalition.side.BLUE)
      US_Score:_AddPlayerFromUnit( Unit )
      US_Score:AddGoalScore(Unit, "CTLD", string.format("Pilot %s has been awarded %d points for extracting troops!", PlayerName, points), points)
    end
end
  
  function blue_ctld:OnAfterTroopsPickedUp(From,Event,To,Group,Unit,Cargo)
    if Unit then
      local PlayerName = Unit:GetPlayerName()
      local vname = Cargo:GetName()  
      local points = pointsAwardedTroopsPickedup
      MESSAGE:New("Pilot " .. PlayerName .. " has picked up " .. vname .. " from a supply base!", msgTime, "[ Mission Info ]", false):ToBlue()
      USERSOUND:New("JoinTheArmy.ogg"):ToCoalition(coalition.side.BLUE)
      US_Score:_AddPlayerFromUnit( Unit )
      US_Score:AddGoalScore(Unit, "CTLD", string.format("Pilot %s has been awarded %d points for picking up troops!", PlayerName, points), points)
    end
end
  
  function blue_ctld:OnAfterTroopsRTB(From,Event,To,Group,Unit)
    if Unit then
      local PlayerName = Unit:GetPlayerName()
      local points = pointsAwardedTroopsRTB
      MESSAGE:New("Pilot " .. PlayerName .. " returned troops to home base!", msgTime, "[ Mission Info ]", false):ToBlue()
      USERSOUND:New("cheering.ogg"):ToCoalition(coalition.side.BLUE)
      US_Score:_AddPlayerFromUnit( Unit )
      US_Score:AddGoalScore(Unit, "CTLD", string.format("Pilot %s has been awarded %d points for returning troops!", PlayerName, points), points)
    end
end
  
  
  -- Scoring and messaging
function blue_ctld:OnAfterCratesDropped(From, Event, To, Group, Unit, Cargotable)
  if Unit then
    local points = pointsAwardedCrateDropped
    local PlayerName = Unit:GetPlayerName()
    US_Score:_AddPlayerFromUnit( Unit )
    US_Score:AddGoalScore(Unit, "CTLD", string.format("Pilot %s has been awarded %d points for transporting cargo crates!", PlayerName, points), points)
  end
end
  

function blue_ctld:OnAfterCratesBuild(From, Event, To, Group, Unit, Vehicle)
  if Unit then
      local points = pointsAwardedCrateBuilt
      local PlayerName = Unit:GetPlayerName()
      local vname = Vehicle:GetName()
      local coalitionSide = Unit:GetCoalition()

      if coalitionSide == coalition.side.BLUE then
          USERSOUND:New("construction.ogg"):ToCoalition(coalition.side.BLUE)
          MESSAGE:New("Pilot " .. PlayerName .. " has deployed " .. vname .. " to the field!", msgTime, "[ Mission Info ]", false):ToBlue()
          US_Score:_AddPlayerFromUnit(Unit)
          US_Score:AddGoalScore(Unit, "CTLD", string.format("Pilot %s has been awarded %d points for the construction of Units!", PlayerName, points), points)
      elseif coalitionSide == coalition.side.RED then
          USERSOUND:New("construction.ogg"):ToCoalition(coalition.side.RED)
          MESSAGE:New("Pilot " .. PlayerName .. " has deployed " .. vname .. " to the field!", msgTime, "[ Mission Info ]", false):ToRed()
          US_Score:_AddPlayerFromUnit(Unit)
          US_Score:AddGoalScore(Unit, "CTLD", string.format("Pilot %s has been awarded %d points for the construction of Units!", PlayerName, points), points)
      end

      -- Debugging information
      env.info("DEBUG: OnAfterCratesBuild called for Unit: " .. PlayerName .. ", Vehicle: " .. vname)

      -- Is this a FOB being built? If so add a Load Zone around the deployed crate.
      env.info("CRATEBUILD: Is this a fob?: " .. vname, false)
      if string.match(vname, "FOB", 1, true) then
          env.info("CRATEBUILD: Yes, this is a FOB, building: " .. vname, false)
          local Coord = Vehicle:GetCoordinate():GetVec2()
          local mCoord = Vehicle:GetCoordinate()
          local zonename = "FOB-" .. math.random(1, 10000)
          local fobzone = ZONE_RADIUS:New(zonename, Coord, 1000)
          local fobmarker = MARKER:New(mCoord, "FORWARD OPERATING BASE:\nBUILT BY: " .. PlayerName .. "\n\nTransport Helos may pick up troops and equipment from this location."):ReadOnly():ToCoalition(coalitionSide)
          fobzone:DrawZone(2, {.25, .63, .79}, 1, {0, 0, 0}, 0.25, 2, true)
          if coalitionSide == coalition.side.BLUE then
              blue_ctld:AddCTLDZone(zonename, CTLD.CargoZoneType.LOAD, SMOKECOLOR.Blue, true, true)
              MESSAGE:New("Pilot " .. PlayerName .. " has created a new loading zone for troops and equipment! See your F10 Map for marker!", msgTime, "[ Mission Info ]", false):ToBlue()
          elseif coalitionSide == coalition.side.RED then
              red_ctld:AddCTLDZone(zonename, CTLD.CargoZoneType.LOAD, SMOKECOLOR.Red, true, true)
              MESSAGE:New("Pilot " .. PlayerName .. " has created a new loading zone for troops and equipment! See your F10 Map for marker!", msgTime, "[ Mission Info ]", false):ToRed()
          end
      else
          env.info("CRATEBUILD: No! Not a FOB: " .. vname, false)
      end
  end
end

function blue_ctld:OnBeforeCratesRepaired(From, Event, To, Group, Unit, Vehicle)
  if Unit then
    local points = pointsAwardedCrateRepair
    local GroupCategory = Group:GetCategoryName()
    local PlayerName = Unit:GetPlayerName()
  
    MESSAGE:New("Pilot " .. PlayerName .. " has started repairs on " .. GroupCategory .. "! Nice Job!", msgTime, "[ Mission Info ]", false):ToBlue()
    
  end
end

function blue_ctld:OnAfterCratesRepaired(From, Event, To, Group, Unit, Vehicle)
  if Unit then
    local points = pointsAwardedCrateRepair
    local PlayerName = Unit:GetPlayerName()   
    USERSOUND:New("repair.ogg"):ToCoalition(coalition.side.BLUE)
    MESSAGE:New("Pilot " .. PlayerName .. " has conducted repears on " .. Vehicle "! Nice Job!", msgTime, "[ Mission Info ]", false):ToRed()
    US_Score:_AddPlayerFromUnit( Unit )
    US_Score:AddGoalScore(Unit, "CTLD", string.format("Pilot %s has been awarded %d points for the repair of Units!", PlayerName, points), points)
  end
end



------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Red CTLD Functions
------------------------------------------------------------------------------------------------------------------------------------------------------------
    
function red_ctld:OnAfterTroopsDeployed(From,Event,To,Group,Unit,Troops)
  if Unit then
    local PlayerName = Unit:GetPlayerName()
    local vname = Troops:GetName()
    local points = pointsAwardedTroopsDeployed
    MESSAGE:New("Pilot " .. PlayerName .. " has deployed " .. vname .. " to the field!", msgTime, "[ Mission Info ]", false):ToRed()
    USERSOUND:New("combatAudio5.ogg"):ToCoalition(coalition.side.RED)
    US_Score:_AddPlayerFromUnit( Unit )
    US_Score:AddGoalScore(Unit, "CTLD", string.format("Pilot %s has been awarded %d points for deploying troops!", PlayerName, points), points)
  end
end

function red_ctld:OnAfterTroopsExtracted(From,Event,To,Group,Unit,Cargo)
  if Unit then
    local PlayerName = Unit:GetPlayerName()
    local vname = Cargo:GetName() 
    local points = pointsAwardedTroopsExtracted
    MESSAGE:New("Pilot " .. PlayerName .. " has extracted " .. vname .. " from the field!", msgTime, "[ Mission Info ]", false):ToRed()
    USERSOUND:New("getToTheChoppa.ogg"):ToCoalition(coalition.side.RED)
    US_Score:_AddPlayerFromUnit( Unit )
    US_Score:AddGoalScore(Unit, "CTLD", string.format("Pilot %s has been awarded %d points for extracting troops!", PlayerName, points), points)
  end
end

function red_ctld:OnAfterTroopsPickedUp(From,Event,To,Group,Unit,Cargo)
  if Unit then
    local PlayerName = Unit:GetPlayerName()
    local vname = Cargo:GetName()  
    local points = pointsAwardedTroopsPickedup
    MESSAGE:New("Pilot " .. PlayerName .. " has picked up " .. vname .. " from a supply base!", msgTime, "[ Mission Info ]", false):ToRed()
    USERSOUND:New("JoinTheArmy.ogg"):ToCoalition(coalition.side.RED)
    US_Score:_AddPlayerFromUnit( Unit )
    US_Score:AddGoalScore(Unit, "CTLD", string.format("Pilot %s has been awarded %d points for picking up troops!", PlayerName, points), points)
  end
end

function red_ctld:OnAfterTroopsRTB(From,Event,To,Group,Unit)
  if Unit then
    local PlayerName = Unit:GetPlayerName()
    local points = pointsAwardedTroopsRTB
    MESSAGE:New("Pilot " .. PlayerName .. " returned troops to home base!", msgTime, "[ Mission Info ]", false):ToRed()
    USERSOUND:New("cheering.ogg"):ToCoalition(coalition.side.RED)
    US_Score:_AddPlayerFromUnit( Unit )
    US_Score:AddGoalScore(Unit, "CTLD", string.format("Pilot %s has been awarded %d points for returning troops!", PlayerName, points), points)
  end
end


  -- Scoring and messaging
function red_ctld:OnAfterCratesDropped(From, Event, To, Group, Unit, Cargotable)
  if Unit then
    local points = pointsAwardedCrateDropped
    local PlayerName = Unit:GetPlayerName()
    US_Score:_AddPlayerFromUnit( Unit )
    US_Score:AddGoalScore(Unit, "CTLD", string.format("Pilot %s has been awarded %d points for transporting cargo crates!", PlayerName, points), points)
  end
end


function red_ctld:OnAfterCratesBuild(From, Event, To, Group, Unit, Vehicle)
  if Unit then
    local points = pointsAwardedCrateBuilt
    local PlayerName = Unit:GetPlayerName()
    local vname = Vehicle:GetName()

    USERSOUND:New("construction.ogg"):ToCoalition(coalition.side.RED) 
    MESSAGE:New("Pilot " .. PlayerName .. " has deployed " .. vname .. " to the field!", msgTime, "[ Mission Info ]", false):ToRed()
    US_Score:_AddPlayerFromUnit( Unit )
    US_Score:AddGoalScore(Unit, "CTLD", string.format("Pilot %s has been awarded %d points for the construction of Units!", PlayerName, points), points)

    -- Debugging information
    env.info("DEBUG: OnAfterCratesBuild called for Unit: " .. PlayerName .. ", Vehicle: " .. vname)

    -- Is this a FOB being built? If so add a Load Zone around the deployed crate.     
    env.info("CRATEBUILD: Is this a fob?: " .. vname,false)
    if string.match(vname,"FOB",1,true) then
      env.info("CRATEBUILD: Yes, this is a FOB, building: " .. vname,false)
      local Coord = Vehicle:GetCoordinate():GetVec2()
      local mCoord = Vehicle:GetCoordinate()
      local zonename = "FOB-" .. math.random(1,10000)
      local fobzone = ZONE_RADIUS:New(zonename,Coord,1000)
      local fobmarker = MARKER:New(mCoord, "FORWARD OPERATING BASE:\nBUILT BY: " .. PlayerName .. "\n\nTransport Helos may pick up troops and equipment from this location."):ReadOnly():ToCoalition(coalition.side.RED)
      fobzone:DrawZone(2,{.25,.63,.79},1,{0,0,0},0.25,2,true)
      red_ctld:AddCTLDZone(zonename,CTLD.CargoZoneType.LOAD,SMOKECOLOR.Red,true,true)
      MESSAGE:New("Pilot " .. PlayerName .. " has created a new loading zone for troops and equipment! See your F10 Map for marker!", msgTime, "[ Mission Info ]", false):ToRed()
    else
      env.info("CRATEBUILD: No! Not a FOB: " .. vname,false)
    end
    
  end
end

function red_ctld:OnBeforeCratesRepaired(From, Event, To, Group, Unit, Vehicle)
  if Unit then
    local points = pointsAwardedCrateRepair
    local GroupCategory = Group:GetCategoryName()
    local PlayerName = Unit:GetPlayerName()
  
    MESSAGE:New("Pilot " .. PlayerName .. " has started repairs on " .. GroupCategory .. "! Nice Job!", msgTime, "[ Mission Info ]", false):ToRed()
    
  end
end

function red_ctld:OnAfterCratesRepaired(From, Event, To, Group, Unit, Vehicle)
  if Unit then
    local points = pointsAwardedCrateRepair
    local PlayerName = Unit:GetPlayerName()   
    USERSOUND:New("repair.ogg"):ToCoalition(coalition.side.RED)
    MESSAGE:New("Pilot " .. PlayerName .. " has conducted repears on " .. Vehicle "! Nice Job!", msgTime, "[ Mission Info ]", false):ToRed()
    US_Score:_AddPlayerFromUnit( Unit )
    US_Score:AddGoalScore(Unit, "CTLD", string.format("Pilot %s has been awarded %d points for the repair of Units!", PlayerName, points), points)
  end
end
