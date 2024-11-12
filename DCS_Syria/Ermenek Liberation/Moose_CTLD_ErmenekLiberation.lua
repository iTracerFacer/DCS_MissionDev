
  -- Instantiate and start a CTLD for the blue side, using helicopter groups named "Helicargo" and alias "Lufttransportbrigade I"
 my_ctld = CTLD:New(coalition.side.BLUE,{"Helicargo"},"Transport Helos")
 my_ctld:__Start(5)
 ----------------------------------------------------------------------------------------
 -- Options
 
 my_ctld.useprefix = true -- (DO NOT SWITCH THIS OFF UNLESS YOU KNOW WHAT YOU ARE DOING!) Adjust **before** starting CTLD. If set to false, *all* choppers of the coalition side will be enabled for CTLD.
 my_ctld.CrateDistance = 35 -- List and Load crates in this radius only.
 my_ctld.dropcratesanywhere = true -- Option to allow crates to be dropped anywhere.
 my_ctld.maximumHoverHeight = 15 -- Hover max this high to load.
 my_ctld.minimumHoverHeight = 4 -- Hover min this low to load.
 my_ctld.forcehoverload = true -- Crates (not: troops) can **only** be loaded while hovering.
 my_ctld.hoverautoloading = true -- Crates in CrateDistance in a LOAD zone will be loaded automatically if space allows.
 my_ctld.smokedistance = 5000 -- Smoke or flares can be request for zones this far away (in meters).
 my_ctld.movetroopstowpzone = true -- Troops and vehicles will move to the nearest MOVE zone...
 my_ctld.movetroopsdistance = 5000 -- .. but only if this far away (in meters)
 my_ctld.smokedistance = 2000 -- Only smoke or flare zones if requesting player unit is this far away (in meters)
 my_ctld.suppressmessages = false -- Set to true if you want to script your own messages.
 my_ctld.repairtime = 300 -- Number of seconds it takes to repair a unit.
 my_ctld.cratecountry = country.id.GERMANY -- ID of crates. Will default to country.id.RUSSIA for RED coalition setups.
 my_ctld.allowcratepickupagain = true  -- allow re-pickup crates that were dropped.
 my_ctld.enableslingload = false -- allow cargos to be slingloaded - might not work for all cargo types
 my_ctld.pilotmustopendoors = true -- -- force opening of doors
 


 CTLDLoadZone = ZONE:New("Loadzone"):MarkZone(20)
 CTLDForwardFarpZone = ZONE:New( "FORWARD FARP" ):MarkZone(20)
 


 ----------------------------------------------------------------------------------------
 -- Add cargo types available
 -- 
 -- add infantry unit called "Anti-Tank Small" using template "ATS", of type TROOP with size 3
 -- infantry units will be loaded directly from LOAD zones into the heli (matching number of free seats needed)
 my_ctld:AddTroopsCargo("Anti-Tank",{"Anti-Tank"},CTLD_CARGO.Enum.TROOPS,3)
 -- if you want to add weight to your Heli, troops can have a weight in kg **per person**. Currently no max weight checked. Fly carefully.
 --my_ctld:AddTroopsCargo("Anti-Tank Small",{"ATS"},CTLD_CARGO.Enum.TROOPS,3,80)

 -- add infantry unit called "Anti-Air" using templates "AA" and "AA"", of type TROOP with size 4. No weight. We only have 2 in stock:
 my_ctld:AddTroopsCargo("Anti-Air",{"Anti-Air"},CTLD_CARGO.Enum.TROOPS,4)
 
 my_ctld:AddTroopsCargo("Mortar Crew",{"Mortar Crew"},CTLD_CARGO.Enum.TROOPS,4)

 -- add an engineers unit called "Wrenches" using template "Engineers", of type ENGINEERS with size 2. Engineers can be loaded, dropped,
 -- and extracted like troops. However, they will seek to build and/or repair crates found in a given radius. Handy if you can\'t stay
 -- to build or repair or under fire.
 my_ctld:AddTroopsCargo("Engineers",{"Engineers"},CTLD_CARGO.Enum.ENGINEERS,4)
 my_ctld.EngineerSearch = 2000 -- teams will search for crates in this radius.

 -- add vehicle called "Humvee" using template "Humvee", of type VEHICLE, size 2, i.e. needs two crates to be build
 -- vehicles and FOB will be spawned as crates in a LOAD zone first. Once transported to DROP zones, they can be build into the objects
-- my_ctld:AddCratesCargo("Ammo Truck", {"Ammo Truck"},CTLD_CARGO.Enum.VEHICLE,1)
 my_ctld:AddCratesCargo("Scout Humvee",{"Scout Humvee"},CTLD_CARGO.Enum.VEHICLE,1)
 my_ctld:AddCratesCargo("ATGM Humvee",{"ATGM Humvee"},CTLD_CARGO.Enum.VEHICLE,1)
 my_ctld:AddCratesCargo("MBT M1A2 Abrams",{"MBT M1A2 Abrams"},CTLD_CARGO.Enum.VEHICLE,2)
 my_ctld:AddCratesCargo("SAM Chaparral M48", {"SAM Chaparral M48"}, CTLD_CARGO.Enum.VEHICLE, 2)
 my_ctld:AddCratesCargo("Roland Site", {"Roland Site"}, CTLD_CARGO.Enum.VEHICLE, 4)
 
 
-- -- if you want to add weight to your Heli, crates can have a weight in kg **per crate**. Currently no max weight checked. Fly carefully.
-- my_ctld:AddCratesCargo("Humvee",{"Humvee"},CTLD_CARGO.Enum.VEHICLE,2,2775)
-- -- if you want to limit your stock, add a number (here: 10) as parameter after weight. No parameter / nil means unlimited stock.
-- my_ctld:AddCratesCargo("Humvee",{"Humvee"},CTLD_CARGO.Enum.VEHICLE,2,2775,10)

 -- add infantry unit called "Forward Ops Base" using template "FOB", of type FOB, size 4, i.e. needs four crates to be build:
 my_ctld:AddCratesCargo("Forward Ops Base",{"FOB"},CTLD_CARGO.Enum.FOB,4)

 -- add crates to repair FOB or VEHICLE type units - the 2nd parameter needs to match the template you want to repair
-- my_ctld:AddCratesRepair("Repair Humvee - Abrams","MBT M1A2 Abrams",CTLD_CARGO.Enum.REPAIR,1)
-- my_ctld:AddCratesRepair("Repair Humvee - Chaparral M48","SAM Chaparral M48",CTLD_CARGO.Enum.REPAIR,1)
-- my_ctld:AddCratesRepair("Repair Humvee - Roland Site","Roland Site",CTLD_CARGO.Enum.REPAIR,1)
 my_ctld.repairtime = 300 -- takes 300 seconds to repair something

 -- add static cargo objects, e.g ammo chests - the name needs to refer to a STATIC object in the mission editor, 
 -- here: it\'s the UNIT name (not the GROUP name!), the second parameter is the weight in kg.
 -- my_ctld:AddStaticsCargo("Ammunition",500)
 
 ----------------------------------------------------------------------------------------
 --Add logistics zones
 
-- Add a zone of type LOAD to our setup. Players can load troops and crates.
 -- "Loadzone" is the name of the zone from the ME. Players can load, if they are inside the zone.
 -- Smoke and Flare color for this zone is blue, it is active (can be used) and has a radio beacon.
 my_ctld:AddCTLDZone("Loadzone",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
 

 -- Add a zone of type DROP. Players can drop crates here.
 -- Smoke and Flare color for this zone is blue, it is active (can be used) and has a radio beacon.
 -- NOTE: Troops can be unloaded anywhere, also when hovering in parameters.
 my_ctld:AddCTLDZone("FORWARD FARP",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
 
 
 -- Add two zones of type MOVE. Dropped troops and vehicles will move to the nearest one. See options.
 -- Smoke and Flare color for this zone is blue, it is active (can be used) and has a radio beacon.
 my_ctld:AddCTLDZone("CZ1",CTLD.CargoZoneType.MOVE,nil,true,false)
 my_ctld:AddCTLDZone("CZ2",CTLD.CargoZoneType.MOVE,nil,true,false)
 my_ctld:AddCTLDZone("CZ3",CTLD.CargoZoneType.MOVE,nil,true,false)
 my_ctld:AddCTLDZone("CZ4",CTLD.CargoZoneType.MOVE,nil,true,false)
 my_ctld:AddCTLDZone("CZ5",CTLD.CargoZoneType.MOVE,nil,true,false)
 my_ctld:AddCTLDZone("CZ6",CTLD.CargoZoneType.MOVE,nil,true,false)
 my_ctld:AddCTLDZone("CZ7",CTLD.CargoZoneType.MOVE,nil,true,false)
 my_ctld:AddCTLDZone("CZ8",CTLD.CargoZoneType.MOVE,nil,true,false)
 my_ctld:AddCTLDZone("CZ9",CTLD.CargoZoneType.MOVE,nil,true,false)
 my_ctld:AddCTLDZone("CZ10",CTLD.CargoZoneType.MOVE,nil,true,false)
 my_ctld:AddCTLDZone("CZ11",CTLD.CargoZoneType.MOVE,nil,true,false)
 my_ctld:AddCTLDZone("CZ12",CTLD.CargoZoneType.MOVE,nil,true,false)
 my_ctld:AddCTLDZone("CZ13",CTLD.CargoZoneType.MOVE,nil,true,false)


-- my_ctld:AddCTLDZone("Movezone2",CTLD.CargoZoneType.MOVE,SMOKECOLOR.White,true,true)

 -- Add a zone of type SHIP to our setup. Players can load troops and crates from this ship
 -- "Tarawa" is the unitname (callsign) of the ship from the ME. Players can load, if they are inside the zone.
 -- The ship is 240 meters long and 20 meters wide.
 -- Note that you need to adjust the max hover height to deck height plus 5 meters or so for loading to work.
 -- When the ship is moving, forcing hoverload might not be a good idea.
 -- my_ctld:AddCTLDZone("USS Tarawa",CTLD.CargoZoneType.SHIP,SMOKECOLOR.Blue,true,true,240,20)
 

 
 
 
 
 
 
 
 