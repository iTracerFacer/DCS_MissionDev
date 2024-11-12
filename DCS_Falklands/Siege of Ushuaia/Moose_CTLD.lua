-- Switch the tracing On
--BASE:TraceOnOff( true )



local msgTime = 15

ctld_blue = CTLD:New( coalition.side.BLUE, {"Transport", "APACHE", "TRANSPORT", "BLACKSHARK"}, "Transport Helos")
ctld_red = CTLD:New( coalition.side.RED, {"Transport"}, "Transport Helos")
ctld_blue:__Start(5)
ctld_red:__Start(5)
--ctld_blue:TraceAll()
--- Scores Awared for Dropping, Building and Repairing logistics.

local pointsAwardedTroopsDeployed = 1
local pointsAwardedTroopsExtracted = 1
local pointsAwardedTroopsPickedup = 1
local pointsAwardedTroopsRTB = 2
local pointsAwardedCrateDropped = 5
local pointsAwardedCrateBuilt = 2
local pointsAwardedCrateRepair = 5

--Add (normal, round!) zones for loading troops and crates and dropping, building crates

   ctld_blue:AddCTLDZone("Ushuaia Supply",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
   ctld_blue:AddCTLDZone("FARP LONDON SUPPLY",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
   ctld_blue:AddCTLDZone("FARP ROME SUPPLY",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
   ctld_blue:AddCTLDZone("FARP DALLAS SUPPLY",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
   ctld_blue:AddCTLDZone("De Tolhuin",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
   ctld_blue:AddCTLDZone("Rio Grande",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
   ctld_blue:AddCTLDZone("Pampa",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
   ctld_blue:AddCTLDZone("Puerto Williams",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
   
   ctld_red:AddCTLDZone("De Tolhuin",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Red,true,true)
   ctld_red:AddCTLDZone("Rio Grande",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Red,true,true)
   ctld_red:AddCTLDZone("Pampa",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Red,true,true)
   ctld_red:AddCTLDZone("Puerto Williams",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Red,true,true)

-- Set CTLD Options for Blue Side
ctld_blue.useprefix = true -- (DO NOT SWITCH THIS OFF UNLESS YOU KNOW WHAT YOU ARE DOING!) Adjust **before** starting CTLD. If set to false, *all* choppers of the coalition side will be enabled for CTLD.
     ctld_blue.CrateDistance = 100 -- List and Load crates in this radius only.
     ctld_blue.dropcratesanywhere = true -- Option to allow crates to be dropped anywhere.
     ctld_blue.maximumHoverHeight = 15 -- Hover max this high to load.
     ctld_blue.minimumHoverHeight = 4 -- Hover min this low to load.
     ctld_blue.forcehoverload = false -- Crates (not: troops) can **only** be loaded while hovering.
     ctld_blue.hoverautoloading = true -- Crates in CrateDistance in a LOAD zone will be loaded automatically if space allows.
     ctld_blue.smokedistance = 10000 -- Smoke or flares can be request for zones this far away (in meters).
     ctld_blue.movetroopstowpzone = true -- Troops and vehicles will move to the nearest MOVE zone...
     ctld_blue.movetroopsdistance = 2000 -- .. but only if this far away (in meters)
     ctld_blue.smokedistance = 10000 -- Only smoke or flare zones if requesting player unit is this far away (in meters)
     ctld_blue.suppressmessages = false -- Set to true if you want to script your own messages.
     ctld_blue.repairtime = 300 -- Number of seconds it takes to repair a unit.
     ctld_blue.buildtime = 20 -- Number of seconds it takes to build a unit. Set to zero or nil to build instantly.
     ctld_blue.cratecountry = country.id.USA -- ID of crates. Will default to country.id.RUSSIA for RED coalition setups.
     ctld_blue.allowcratepickupagain = true  -- allow re-pickup crates that were dropped.
     ctld_blue.enableslingload = false -- allow cargos to be slingloaded - might not work for all cargo types
     ctld_blue.pilotmustopendoors = false -- force opening of doors
     ctld_blue.SmokeColor = SMOKECOLOR.Blue -- default color to use when dropping smoke from heli 
     ctld_blue.FlareColor = FLARECOLOR.Green -- color to use when flaring from heli
     ctld_blue.basetype = "container_cargo" -- default shape of the cargo container
     ctld_blue.droppedbeacontimeout = 600 -- dropped beacon lasts 10 minutes
     ctld_blue.usesubcats = true -- use sub-category names for crates, adds an extra menu layer in "Get Crates", useful if you have > 10 crate types.
     ctld_blue.placeCratesAhead = true -- place crates straight ahead of the helicopter, in a random way. If true, crates are more neatly sorted.
     ctld_blue.nobuildinloadzones = true -- forbid players to build stuff in LOAD zones if set to `true`
     ctld_blue.movecratesbeforebuild = false -- crates must be moved once before they can be build. Set to false for direct builds.
     ctld_blue.surfacetypes = {land.SurfaceType.LAND,land.SurfaceType.ROAD,land.SurfaceType.RUNWAY,land.SurfaceType.SHALLOW_WATER} -- surfaces for loading back objects

   
-- Set CTLD Options for Blue Red  
ctld_red.useprefix = true -- (DO NOT SWITCH THIS OFF UNLESS YOU KNOW WHAT YOU ARE DOING!) Adjust **before** starting CTLD. If set to false, *all* choppers of the coalition side will be enabled for CTLD.
     ctld_red.CrateDistance = 100 -- List and Load crates in this radius only.
     ctld_red.dropcratesanywhere = true -- Option to allow crates to be dropped anywhere.
     ctld_red.maximumHoverHeight = 15 -- Hover max this high to load.
     ctld_red.minimumHoverHeight = 4 -- Hover min this low to load.
     ctld_red.forcehoverload = false -- Crates (not: troops) can **only** be loaded while hovering.
     ctld_red.hoverautoloading = true -- Crates in CrateDistance in a LOAD zone will be loaded automatically if space allows.
     ctld_red.smokedistance = 10000 -- Smoke or flares can be request for zones this far away (in meters).
     ctld_red.movetroopstowpzone = true -- Troops and vehicles will move to the nearest MOVE zone...
     ctld_red.movetroopsdistance = 2000 -- .. but only if this far away (in meters)
     ctld_red.smokedistance = 10000 -- Only smoke or flare zones if requesting player unit is this far away (in meters)
     ctld_red.suppressmessages = false -- Set to true if you want to script your own messages.
     ctld_red.repairtime = 300 -- Number of seconds it takes to repair a unit.
     ctld_red.buildtime = 20 -- Number of seconds it takes to build a unit. Set to zero or nil to build instantly.
     ctld_red.cratecountry = country.id.RUSSIA -- ID of crates. Will default to country.id.RUSSIA for RED coalition setups.
     ctld_red.allowcratepickupagain = true  -- allow re-pickup crates that were dropped.
     ctld_red.enableslingload = false -- allow cargos to be slingloaded - might not work for all cargo types
     ctld_red.pilotmustopendoors = false -- force opening of doors
     ctld_red.SmokeColor = SMOKECOLOR.Red -- default color to use when dropping smoke from heli 
     ctld_red.FlareColor = FLARECOLOR.Red -- color to use when flaring from heli
     ctld_red.basetype = "container_cargo" -- default shape of the cargo container
     ctld_red.droppedbeacontimeout = 600 -- dropped beacon lasts 10 minutes
     ctld_red.usesubcats = true -- use sub-category names for crates, adds an extra menu layer in "Get Crates", useful if you have > 10 crate types.
     ctld_red.placeCratesAhead = true -- place crates straight ahead of the helicopter, in a random way. If true, crates are more neatly sorted.
     ctld_red.nobuildinloadzones = true -- forbid players to build stuff in LOAD zones if set to `true`
     ctld_red.movecratesbeforebuild = false -- crates must be moved once before they can be build. Set to false for direct builds.
     ctld_red.surfacetypes = {land.SurfaceType.LAND,land.SurfaceType.ROAD,land.SurfaceType.RUNWAY,land.SurfaceType.SHALLOW_WATER} -- surfaces for loading back objects     


-- add infantry unit called "Anti-Tank Small" using template "ATS", of type TROOP with size 3
   -- infantry units will be loaded directly from LOAD zones into the heli (matching number of free seats needed)
   
   ctld_blue:AddTroopsCargo("2 Recon",{"BLUE RECON INFANTRY"},CTLD_CARGO.Enum.TROOPS,2,nil,10)
   ctld_blue:AddTroopsCargo("4 Anti-Air",{"BLUE-AA-2"},CTLD_CARGO.Enum.TROOPS,4,nil,10)
   ctld_blue:AddTroopsCargo("6 Anti-Tank",{"BLUE-ATS"},CTLD_CARGO.Enum.TROOPS,6,nil,12)
   ctld_blue:AddTroopsCargo("6 Mortar Crew",{"Mortar Crew"},CTLD_CARGO.Enum.TROOPS,6,nil,12)
   ctld_blue:AddTroopsCargo("10 Spec Ops",{"SpecOps"},CTLD_CARGO.Enum.TROOPS,10,nil,16)
--   ctld_blue:AddTroopsCargo("4 Crate Repair Crew",{"Blue-Engineers"},CTLD_CARGO.Enum.ENGINEERS,4,nil,8)
   ctld_blue.EngineerSearch = 2000 -- teams will search for crates in this radius.

   ctld_blue:AddCratesCargo("ATGM HMMWV",{"ATGM HMMWV"},CTLD_CARGO.Enum.VEHICLE,1,nil,10,"Anti-Tank")
   ctld_blue:AddCratesCargo("IFV M2A2 Bradley",{"APC"},CTLD_CARGO.Enum.VEHICLE,1,nil,10,"Anti-Tank")
   ctld_blue:AddCratesCargo("MBT M1A2 Abrams",{"Abrams"},CTLD_CARGO.Enum.VEHICLE,2,nil,10,"Anti-Tank")
   
   ctld_blue:AddCratesCargo("SAM Avenger",{"BLUE SAM Avenger"},CTLD_CARGO.Enum.VEHICLE,2,nil,8,"Anti-Air")
   ctld_blue:AddCratesCargo("SAM Hawk Site",{"BLUE SAM Hawk Site"},CTLD_CARGO.Enum.VEHICLE,4,nil,3,"Anti-Air")
   ctld_blue:AddCratesCargo("SAM Patriot Site",{"BLUE SAM Patriot Site"},CTLD_CARGO.Enum.VEHICLE,8,nil,2,"Anti-Air")
   ctld_blue:AddCratesCargo("EWR Roland",{"BLUE EWR ROLAND"},CTLD_CARGO.Enum.VEHICLE,1,nil,5,"Anti-Air")

   ctld_blue:AddCratesCargo("Recon HMMWV",{"BLUE RECON"},CTLD_CARGO.Enum.VEHICLE,1,nil,10,"Ground Ops")
   ctld_blue:AddCratesCargo("Supply Truck",{"Supply Truck"},CTLD_CARGO.Enum.VEHICLE,1,nil,10,"Ground Ops")
   --ctld_blue:AddCratesCargo("Repair Truck",{"Repair Truck"},CTLD_CARGO.Enum.ENGINEERS,1,nil,10,"Ground Ops")
   ctld_blue:AddCratesCargo("FARP Equipment",{"FARP Template"},CTLD_CARGO.Enum.VEHICLE,4,nill,4,"Ground Ops")
   ctld_blue:AddCratesCargo("FOB Site",{"FOB Template"},CTLD_CARGO.Enum.FOB,4,nil,4,"Ground Ops")

   -- Add troops and crates for RED
   ctld_red:AddTroopsCargo("2 Saboteurs",{"RED-SABATOURS"},CTLD_CARGO.Enum.TROOPS,2,nil,50)
   ctld_red:AddTroopsCargo("4 Anti-Air",{"RED-AA-1"},CTLD_CARGO.Enum.TROOPS,4,nil,50)
   ctld_red:AddTroopsCargo("6 Anti-Tank",{"RED-ATS"},CTLD_CARGO.Enum.TROOPS,6,nil,50)
   ctld_red:AddTroopsCargo("6 Mortar Crew",{"RED Mortar Crew"},CTLD_CARGO.Enum.TROOPS,6,nil,50)
   ctld_red:AddTroopsCargo("10 Infantry",{"Red Specops"},CTLD_CARGO.Enum.TROOPS,10,nil,50)
--   ctld_red:AddTroopsCargo("4 Crate Repair Crew",{"RED-ENGINEERS"},CTLD_CARGO.Enum.ENGINEERS,4,nil,50)
   ctld_red.EngineerSearch = 2000 -- teams will search for crates in this radius.

   ctld_red:AddCratesCargo("ATGM BTR-RD",{"APC BTR-RD"},CTLD_CARGO.Enum.VEHICLE,1,nil,50,"Anti-Tank")
   ctld_red:AddCratesCargo("APC IFV BMP",{"IFV BMP"},CTLD_CARGO.Enum.VEHICLE,1,nil,50,"Anti-Tank")
   ctld_red:AddCratesCargo("MBT T-90",{"RED TANK"},CTLD_CARGO.Enum.VEHICLE,2,nil,50,"Anti-Tank")
   
   ctld_red:AddCratesCargo("SA-8",{"RED SAM SA-8"},CTLD_CARGO.Enum.VEHICLE,2,nil,10,"Anti-Air")
   ctld_red:AddCratesCargo("SA-11",{"RED SAM SA-11"},CTLD_CARGO.Enum.VEHICLE,4,nil,10,"Anti-Air")
   ctld_red:AddCratesCargo("SA-10 Site",{"RED SAM SA-10"},CTLD_CARGO.Enum.VEHICLE,8,nil,5,"Anti-Air")

   ctld_red:AddCratesCargo("Supply Truck",{"RED SUPPLY TRUCK"},CTLD_CARGO.Enum.VEHICLE,1,nil,50,"Ground Ops")
   --ctld_red:AddCratesCargo("FARP Equipment",{"FARP Template"},CTLD_CARGO.Enum.VEHICLE,4,nill,3,"Ground Ops")
   --ctld_red:AddCratesCargo("FOB Site",{"FOB Template"},CTLD_CARGO.Enum.FOB,4,nil,3,"Ground Ops")




 -- If Base is captured, we add this code to a missiong trigger to add stock to CTLD

function addStockBlue() -- used in the ME when a base is captured. 

  local addRecon = 10
  local addAntiAir = 8
  local addAntiTank = 12
  local addMortorCrew = 12
  local addInfantry = 16
  local addRepair = 8
  
  local addCrateReconHMMV = 5
  local addCrateHMMV = 5
  local addAPC = 5
  local addMBT = 5
  local addSAMAvenger = 8
  local addSAMHawk = 3
  local addSAMPatriot = 2
  local addTrackRadar = 3
  local addSupplyTruck = 5
  local addFARPEquip = 3
  local addFOBSite = 3
   

  ctld_blue:AddStockTroops("2 Recon",addRecon)
  ctld_blue:AddStockTroops("4 Anti-Air",addAntiAir)
  ctld_blue:AddStockTroops("6 Anti-Tank",addAntiTank)
  ctld_blue:AddStockTroops("6 Mortar Crew",addMortorCrew)
  ctld_blue:AddStockTroops("10 Infantry",addInfantry)
  --ctld_blue:AddStockTroops("4 Crate Repair Crew",addRepair)

  ctld_blue:AddStockCrates("Recon HMMWV",addCrateReconHMMV)
  ctld_blue:AddStockCrates("ATGM HMMWV",addCrateHMMV)  
  ctld_blue:AddStockCrates("IFV M2A2 Bradley",addAPC)
  ctld_blue:AddStockCrates("MBT M1A2 Abrams",addMBT)
  ctld_blue:AddStockCrates("SAM Avenger",addSAMAvenger)
  ctld_blue:AddStockCrates("SAM Hawk Site",addSAMHawk)
  ctld_blue:AddStockCrates("SAM Patriot Site",addSAMPatriot)
  ctld_blue:AddStockCrates("EWR Roland",addTrackRadar )
  ctld_blue:AddStockCrates("Supply Truck",addSupplyTruck)
  ctld_blue:AddStockCrates("FARP Equipment",addFARPEquip)
  ctld_blue:AddStockCrates("FOB Site",addFOBSite)

  local msg = "\nRecon: " .. addRecon .. "\n" ..
              "Anti-Air: " .. addAntiAir .. "\n" ..
              "Anti-Tank: " .. addAntiTank .. "\n" ..
              "Mortar Crews: " .. addMortorCrew .. "\n" ..
              "Infantry: " .. addInfantry .. "\n" ..
--              "Repair Crews: " .. addRepair .. "\n\n" ..
              
              "Recon HMMWV: " .. addCrateReconHMMV .. "\n" ..
              "ATGM HMMWV: " .. addCrateHMMV .. "\n" ..
              "IFV M2A2 Bradley: " .. addAPC .. "\n" ..
              "MBT M1A2 Abrams: " .. addMBT .. "\n" ..
              "SAM Avengers: " .. addSAMAvenger .. "\n" ..
              "SAM Hawk Sites: " .. addSAMHawk .. "\n" ..
              "SAM Patriot Sites: " .. addSAMPatriot .. "\n" ..
              "EWR Roland: " .. addTrackRadar .. "\n" .. 
              "Supply Trucks: " .. addSupplyTruck .. "\n" ..
              "FARP Equipment: " .. addFARPEquip .. "\n" ..
              "FOB Sites: " .. addFOBSite .. "\n"
              
   MESSAGE:New(msg, msgTime, "[ SUPPLIES ADDED ]", false):ToBlue()       
                 
end

function ctld_blue:OnAfterTroopsDeployed(From,Event,To,Group,Unit,Troops)
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

function ctld_blue:OnAfterTroopsExtracted(From,Event,To,Group,Unit,Cargo)
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

function ctld_blue:OnAfterTroopsPickedUp(From,Event,To,Group,Unit,Cargo)
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

function ctld_blue:OnAfterTroopsRTB(From,Event,To,Group,Unit)
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
function ctld_blue:OnAfterCratesDropped(From, Event, To, Group, Unit, Cargotable)
  if Unit then
    local points = pointsAwardedCrateDropped
    local PlayerName = Unit:GetPlayerName()
    US_Score:_AddPlayerFromUnit( Unit )
    US_Score:AddGoalScore(Unit, "CTLD", string.format("Pilot %s has been awarded %d points for transporting cargo crates!", PlayerName, points), points)
  end
end


function ctld_blue:OnAfterCratesBuild(From, Event, To, Group, Unit, Vehicle)
  if Unit then
    local points = pointsAwardedCrateBuilt
    local PlayerName = Unit:GetPlayerName()
    local vname = Vehicle:GetName()

    USERSOUND:New("construction.ogg"):ToCoalition(coalition.side.BLUE) 
    MESSAGE:New("Pilot " .. PlayerName .. " has deployed " .. vname .. " to the field!", msgTime, "[ Mission Info ]", false):ToBlue()
    US_Score:_AddPlayerFromUnit( Unit )
    US_Score:AddGoalScore(Unit, "CTLD", string.format("Pilot %s has been awarded %d points for the construction of Units!", PlayerName, points), points)

    -- Is this a FOB being built? If so add a Load Zone around the deployed crate.     
    env.info("CRATEBUILD: Is this a fob?: " .. vname,false)
    if string.match(vname,"FOB",1,true) then
      env.info("CRATEBUILD: Yes, this is a FOB, building: " .. vname,false)
      local Coord = Vehicle:GetCoordinate():GetVec2()
      local mCoord = Vehicle:GetCoordinate()
      local zonename = "FOB-" .. math.random(1,10000)
      local fobzone = ZONE_RADIUS:New(zonename,Coord,1000)
      local fobmarker = MARKER:New(mCoord, "FORWARD OPERATING BASE:\nBUILT BY: " .. PlayerName .. "\n\nTransport Helos may pick up troops and equipment from this location."):ReadOnly():ToCoalition(coalition.side.BLUE)
      fobzone:DrawZone(2,{.25,.63,.79},1,{0,0,0},0.25,2,true)
      ctld_blue:AddCTLDZone(zonename,CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
      MESSAGE:New("Pilot " .. PlayerName .. " has created a new loading zone for troops and equipment! See your F10 Map for marker!", msgTime, "[ Mission Info ]", false):ToBlue()
    else
      env.info("CRATEBUILD: No! Not a FOB: " .. vname,false)
    end
    
  end
end

function ctld_blue:OnBeforeCratesRepaired(From, Event, To, Group, Unit, Vehicle)
  if Unit then
    local points = pointsAwardedCrateRepair
    local GroupCategory = Group:GetCategoryName()
    local PlayerName = Unit:GetPlayerName()
 
    MESSAGE:New("Pilot " .. PlayerName .. " has started repairs on " .. GroupCategory .. "! Nice Job!", msgTime, "[ Mission Info ]", false):ToBlue()
    
  end
end

function ctld_blue:OnAfterCratesRepaired(From, Event, To, Group, Unit, Vehicle)
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



function ctld_red:OnAfterTroopsDeployed(From,Event,To,Group,Unit,Troops)
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

function ctld_red:OnAfterTroopsExtracted(From,Event,To,Group,Unit,Cargo)
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

function ctld_red:OnAfterTroopsPickedUp(From,Event,To,Group,Unit,Cargo)
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

function ctld_red:OnAfterTroopsRTB(From,Event,To,Group,Unit)
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
function ctld_red:OnAfterCratesDropped(From, Event, To, Group, Unit, Cargotable)
  if Unit then
    local points = pointsAwardedCrateDropped
    local PlayerName = Unit:GetPlayerName()
    US_Score:_AddPlayerFromUnit( Unit )
    US_Score:AddGoalScore(Unit, "CTLD", string.format("Pilot %s has been awarded %d points for transporting cargo crates!", PlayerName, points), points)
  end
end


function ctld_red:OnAfterCratesBuild(From, Event, To, Group, Unit, Vehicle)
  if Unit then
    local points = pointsAwardedCrateBuilt
    local PlayerName = Unit:GetPlayerName()
    local vname = Vehicle:GetName()

    USERSOUND:New("construction.ogg"):ToCoalition(coalition.side.RED) 
    MESSAGE:New("Pilot " .. PlayerName .. " has deployed " .. vname .. " to the field!", msgTime, "[ Mission Info ]", false):ToRed()
    US_Score:_AddPlayerFromUnit( Unit )
    US_Score:AddGoalScore(Unit, "CTLD", string.format("Pilot %s has been awarded %d points for the construction of Units!", PlayerName, points), points)

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
      ctld_red:AddCTLDZone(zonename,CTLD.CargoZoneType.LOAD,SMOKECOLOR.Red,true,true)
      MESSAGE:New("Pilot " .. PlayerName .. " has created a new loading zone for troops and equipment! See your F10 Map for marker!", msgTime, "[ Mission Info ]", false):ToRed()
    else
      env.info("CRATEBUILD: No! Not a FOB: " .. vname,false)
    end
    
  end
end

function ctld_red:OnBeforeCratesRepaired(From, Event, To, Group, Unit, Vehicle)
  if Unit then
    local points = pointsAwardedCrateRepair
    local GroupCategory = Group:GetCategoryName()
    local PlayerName = Unit:GetPlayerName()
 
    MESSAGE:New("Pilot " .. PlayerName .. " has started repairs on " .. GroupCategory .. "! Nice Job!", msgTime, "[ Mission Info ]", false):ToRed()
    
  end
end

function ctld_red:OnAfterCratesRepaired(From, Event, To, Group, Unit, Vehicle)
  if Unit then
    local points = pointsAwardedCrateRepair
    local PlayerName = Unit:GetPlayerName()   
    USERSOUND:New("repair.ogg"):ToCoalition(coalition.side.RED)
    MESSAGE:New("Pilot " .. PlayerName .. " has conducted repears on " .. Vehicle "! Nice Job!", msgTime, "[ Mission Info ]", false):ToRed()
    US_Score:_AddPlayerFromUnit( Unit )
    US_Score:AddGoalScore(Unit, "CTLD", string.format("Pilot %s has been awarded %d points for the repair of Units!", PlayerName, points), points)
  end
end