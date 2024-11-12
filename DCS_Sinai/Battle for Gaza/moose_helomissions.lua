---
-- Name: TAD-CGO-004 - Transport Test - Infantry and Slingload
-- Author: FlightControl
-- Date Created: 05 Apr 2018
--
-- # Situation:
-- 
-- This mission demonstrates the dynamic task dispatching for cargo Transport operations of a crate and infantry.
-- Slingload the concrete and board the infantry.
-- 

RefugeeMission = MISSION:New( US_CC, "Battle for Gaza", "Tactical", "Transport Cargo", coalition.side.RED )
RefugeeMissionTransportGroups = SET_GROUP:New():FilterCoalitions( "blue" ):FilterPrefixes( "TRANSPORT" ):FilterStart()
RefugeeMissionTaskDispatcher = TASK_CARGO_DISPATCHER:New( RefugeeMission, RefugeeMissionTransportGroups )
RefugeeMissionTaskDispatcher:SetDefaultDeployZone( ZONE:New( "Refugee Camp 1" ) )


-- Now we add cargo into the battle scene.
local Medical_Supplies_1 = STATIC:FindByName( "Medical Supplies-1" )
local Medical_Supplies_2 = STATIC:FindByName( "Medical Supplies-2" )
local Medical_Supplies_3 = STATIC:FindByName( "Medical Supplies-3" )
local Medical_Supplies_4 = STATIC:FindByName( "Medical Supplies-4" )

-- CARGO_SLINGLOAD can be used to setup cargo as a crate or any other static cargo object.
-- We name this group "Important Concrete", and is of type "Workmaterials".
-- The cargoset "CargoSet" will embed all defined cargo of type Crates into its set.
local Medical_Supply_Cargo_1 = CARGO_SLINGLOAD:New( Medical_Supplies_1, "Container", "Medical Supplies", 1000, 25 )
local Medical_Supply_Cargo_2 = CARGO_SLINGLOAD:New( Medical_Supplies_2, "Container", "Medical Supplies", 1000, 25 )
local Medical_Supply_Cargo_3 = CARGO_SLINGLOAD:New( Medical_Supplies_3, "Container", "Medical Supplies", 1000, 25 )
local Medical_Supply_Cargo_4 = CARGO_SLINGLOAD:New( Medical_Supplies_4, "Container", "Medical Supplies", 1000, 25 )

-- Here we define the "cargo set", which is a collection of cargo objects.
-- The cargo set will be the input for the cargo transportation task.
-- So a transportation object is handling a cargo set, which is automatically refreshed when new cargo is added/deleted.
local Medical_Supply_CargoSet = SET_CARGO:New():FilterTypes( "Medical Supplies" ):FilterStart()

local Medical_Supply_Task = RefugeeMissionTaskDispatcher:AddTransportTask( "Transport Medical Supplies", Medical_Supply_CargoSet, "Refugee camps are running low on medical supplies. Search for medical supplies and deliver to the refugee camp." )

