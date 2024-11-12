
-- This file contains the MOOSE missions. 

local RoadBlockDesc = "Build a road block using concreate barriers scattered about the city. \n\n" .. 
  "Sling Load the barriers to the northern side of the city where the road leads into the valley. Place the barriers in the marked location." ..
  "Each barrier deployed will spawn a group of M1 Abrams for use in the defense of they city." ..  
  "You may use the TASK CONTROL option in the F10 Menu to request bearing and range to zone."

US_Mission_BuildRoadBlock = MISSION:New( US_CC, "Build Road Block", "Logistics", RoadBlockDesc , coalition.side.BLUE )
US_TransportGroups = SET_GROUP:New():FilterCoalitions( "blue" ):FilterPrefixes( "Transport" ):FilterStart()
US_TaskDispatcher_BuildRoadBlock = TASK_CARGO_DISPATCHER:New( US_Mission_BuildRoadBlock, US_TransportGroups )
US_TaskDispatcher_BuildRoadBlock:SetDefaultDeployZone( ZONE:New( "Ushuaia Northern Road Block" ) )

  Spawn_BlueRoadBlock = SPAWN:New("Ushuaia Northern Tanks")
  :InitLimit(100,100) -- Spawn these later after cargo is moved. 
  

  

-- Now we add cargo into the battle scene.
local CrateStatic1 = STATIC:FindByName( "Static F-shape barrier-1" )
local CrateStatic2 = STATIC:FindByName( "Static F-shape barrier-2" )
local CrateStatic3 = STATIC:FindByName( "Static F-shape barrier-3" )
local CrateStatic4 = STATIC:FindByName( "Static F-shape barrier-4" )
local CrateStatic5 = STATIC:FindByName( "Static F-shape barrier-5" )
local CrateStatic6 = STATIC:FindByName( "Static F-shape barrier-6" )
local CrateStatic7 = STATIC:FindByName( "Static F-shape barrier-7" )
local CrateStatic8 = STATIC:FindByName( "Static F-shape barrier-8" )
local CrateStatic9 = STATIC:FindByName( "Static F-shape barrier-9" )

-- CARGO_SLINGLOAD can be used to setup cargo as a crate or any other static cargo object.
-- We name this group "Important Concrete", and is of type "Road Block".
-- The cargoset "CargoSet" will embed all defined cargo of type Crates into its set.
local CrateCargo1 = CARGO_SLINGLOAD:New( CrateStatic1, "Road Block", "Concrete", 1000, 25 )
local CrateCargo2 = CARGO_SLINGLOAD:New( CrateStatic2, "Road Block", "Concrete", 1000, 25 )
local CrateCargo3 = CARGO_SLINGLOAD:New( CrateStatic3, "Road Block", "Concrete", 1000, 25 )
local CrateCargo4 = CARGO_SLINGLOAD:New( CrateStatic4, "Road Block", "Concrete", 1000, 25 )
local CrateCargo5 = CARGO_SLINGLOAD:New( CrateStatic5, "Road Block", "Concrete", 1000, 25 )
local CrateCargo6 = CARGO_SLINGLOAD:New( CrateStatic6, "Road Block", "Concrete", 1000, 25 )
local CrateCargo7 = CARGO_SLINGLOAD:New( CrateStatic7, "Road Block", "Concrete", 1000, 25 )
local CrateCargo8 = CARGO_SLINGLOAD:New( CrateStatic8, "Road Block", "Concrete", 1000, 25 )
local CrateCargo9 = CARGO_SLINGLOAD:New( CrateStatic9, "Road Block", "Concrete", 1000, 25 )


-- Here we define the "cargo set", which is a collection of cargo objects.
-- The cargo set will be the input for the cargo transportation task.
-- So a transportation object is handling a cargo set, which is automatically refreshed when new cargo is added/deleted.
local CargoSet = SET_CARGO:New():FilterTypes( "Road Block" ):FilterStart()

---- Now we add cargo into the battle scene.
--local WorkerGroup = GROUP:FindByName( "Workers" )
--
---- CARGO_GROUP can be used to setup cargo with a GROUP object underneath.
---- We name this group "Workers", and is of type "Road Block".
---- The cargoset "CargoSet" will embed all defined cargo of type Road Block (prefix) into its set.
--local WorkerCargoGroup = CARGO_GROUP:New( WorkerGroup, "Road Block", "Workers", 500 )



local BuildRoadBlockTask = US_TaskDispatcher_BuildRoadBlock:AddTransportTask( "Transport", CargoSet, RoadBlockDesc )


function US_TaskDispatcher_BuildRoadBlock:OnAfterCargoDeployed( From, Event, To, Task, TaskPrefix, TaskUnit, Cargo, DeployZone )

  MESSAGE:NewType( "Unit " .. TaskUnit:GetName().. " has deployed cargo " .. Cargo:GetName() .. " at zone " .. DeployZone:GetName() .. " for task " .. Task:GetName() .. ".", MESSAGE.Type.Information ):ToAll()
  Spawn_BlueRoadBlock:Spawn()
  
end

--
-----------------------------------------------------------------------------------------------------------------------------
--
-- Logistic Mission to bring fuel to a forward AI FARP. Once fuel is delivered, AI choppers will take off and patrol the area. 
-- 1 Chopper for every barrel of fuel. 
-- 
--
  Spawn_Rotary1 = SPAWN:New("Rotary-1")
  :InitLimit(100,100) -- Spawn these later after cargo is moved. 

local DeliverFuel = "Deliver Fuel to the Ushuaia airport so our aircraft can start!. "
  
US_Mission_DeliverFuel = MISSION:New( US_CC, "Deliver Fuel", "Logistics", DeliverFuel, coalition.side.BLUE )
US_TaskDispatcher_DeliverFuel = TASK_CARGO_DISPATCHER:New( US_Mission_DeliverFuel, US_TransportGroups )
US_TaskDispatcher_DeliverFuel:SetDefaultDeployZone( ZONE:New( "Deliver Fuel" ) )

-- Create the Barrels
local CrateStaticBarrel1 = STATIC:FindByName( "Static Barrels-1" )
local CrateStaticBarrel2 = STATIC:FindByName( "Static Barrels-2" )
local CrateStaticBarrel3 = STATIC:FindByName( "Static Barrels-3" )
local CrateStaticBarre14 = STATIC:FindByName( "Static Barrels-4" )
local CrateStaticBarrel5 = STATIC:FindByName( "Static Barrels-5" )
local CrateStaticBarrel6 = STATIC:FindByName( "Static Barrels-6" )
local CrateStaticBarrel7 = STATIC:FindByName( "Static Barrels-7" )
local CrateStaticBarrel8 = STATIC:FindByName( "Static Barrels-8" )
local CrateStaticBarrel9 = STATIC:FindByName( "Static Barrels-9" )
local CrateStaticBarrel10 = STATIC:FindByName( "Static Barrels-10" )
-- Make Barrles into slingload cargo.
local CrateFuelCargo1 = CARGO_SLINGLOAD:New( CrateStaticBarrel1, "Logistics", "Fuel", 1000, 25 )
local CrateFuelCargo2 = CARGO_SLINGLOAD:New( CrateStaticBarrel2, "Logistics", "Fuel", 1000, 25 )
local CrateFuelCargo3 = CARGO_SLINGLOAD:New( CrateStaticBarrel3, "Logistics", "Fuel", 1000, 25 )
local CrateFuelCargo4 = CARGO_SLINGLOAD:New( CrateStaticBarre14, "Logistics", "Fuel", 1000, 25 )
local CrateFuelCargo5 = CARGO_SLINGLOAD:New( CrateStaticBarrel5, "Logistics", "Fuel", 1000, 25 )
local CrateFuelCargo6 = CARGO_SLINGLOAD:New( CrateStaticBarrel6, "Logistics", "Fuel", 1000, 25 )
local CrateFuelCargo7 = CARGO_SLINGLOAD:New( CrateStaticBarrel7, "Logistics", "Fuel", 1000, 25 )
local CrateFuelCargo8 = CARGO_SLINGLOAD:New( CrateStaticBarrel8, "Logistics", "Fuel", 1000, 25 )
local CrateFuelCargo9 = CARGO_SLINGLOAD:New( CrateStaticBarrel9, "Logistics", "Fuel", 1000, 25 )
local CrateFuelCargo10 = CARGO_SLINGLOAD:New( CrateStaticBarrel10, "Logistics", "Fuel", 1000, 25 )

-- Group the cargo into a set.
local CargoSetAmmo = SET_CARGO:New():FilterTypes("Logistics"):FilterStart()

-- Create the Dispatcher which contorls the menu items and directs the player to the source and destination for cargo. 
US_TaskDispatcher_DeliverFuel:AddTransportTask("Transport Fuel", CargoSetAmmo, DeliverFuel)

-- Cargo deployed successfully
function US_TaskDispatcher_DeliverFuel:OnAfterCargoDeployed( From, Event, To, Task, TaskPrefix, TaskUnit, Cargo, DeployZone )

  MESSAGE:NewType( "Unit " .. TaskUnit:GetName().. " has deployed cargo " .. Cargo:GetName() .. " at zone " .. DeployZone:GetName() .. " for task " .. Task:GetName() .. ".", MESSAGE.Type.Information ):ToAll()
  Spawn_Rotary1:Spawn()
  
end






