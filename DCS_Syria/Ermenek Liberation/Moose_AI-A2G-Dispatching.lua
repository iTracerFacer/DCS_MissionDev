--- Detect and attack a set of enemy units using helicopters.
-- Name: AID-A2G-001 - Detection and Attack Helicopters
-- Author: FlightControl
-- Date Created: 02 Nov 2018
-- 
-- Modified by TracerFacer 11/5/2021 for Ermenek Liberation.

-- Create the Recce groups


-- Define a SET_GROUP object that builds a collection of groups that define the recce network.
-- Here we build the network with all the groups that have a name starting with CCCP Recce.
local DetectionSetGroup = SET_GROUP:New()
DetectionSetGroup:FilterPrefixes( { "CCCP Recce" } )
DetectionSetGroup:FilterStart()



local Detection = DETECTION_AREAS:New( DetectionSetGroup, 2000 )

-- Setup the A2A dispatcher, and initialize it.
A2GDispatcher = AI_A2G_DISPATCHER:New( Detection )

-- The Command Center (HQ) is the defense point and will also handle the communication to the coalition.
local HQ_Group = GROUP:FindByName( "REDHQ" )
local HQ_CC = COMMANDCENTER:New( HQ_Group, "REDHQ" )

-- Add defense coordinates.
A2GDispatcher:AddDefenseCoordinate( "REDHQ", HQ_Group:GetCoordinate() )
A2GDispatcher:SetDefenseReactivityHigh() -- High defense reactivity. So far proximity of a threat will trigger a defense action.
A2GDispatcher:SetDefenseRadius( 200000 ) -- Defense radius wide enough to also trigger defenses far away.

-- Communication to the players within the coalition. The HQ services the communication of the defense actions.
A2GDispatcher:SetCommandCenter( HQ_CC )

-- Show a tactical display.
A2GDispatcher:SetTacticalDisplay( false ):SetTacticalMenu("Red A2G Dispatcher Testing","Display Tactical Overview")


-- Setup the patrols.

-- The patrol zone.
local PatrolZone = ZONE:New( "PatrolZone" )

-- SEADing from Incirlik.
A2GDispatcher:SetSquadron( "SQ-CCCP SU-25TM", AIRBASE.Syria.Incirlik, { "CCCP SU-25TM" }, 25 )
A2GDispatcher:SetSquadronSeadPatrol2( "SQ-CCCP SU-25TM", PatrolZone, 500, 550, 2000, 3000, "BARO", 750, 800, 2000, 3000, "RADIO" ) -- New API
A2GDispatcher:SetSquadronSeadPatrolInterval( "SQ-CCCP SU-25TM", 1, 300, 600, 1 )
A2GDispatcher:SetSquadronSead2( "SQ-CCCP SU-25TM", 500, 500, 1500, 2500, "RADIO")
A2GDispatcher:SetSquadronTakeoffFromParkingHot( "SQ-CCCP SU-25TM" )
A2GDispatcher:SetSquadronOverhead( "SQ-CCCP SU-25TM", 0.2 )
A2GDispatcher:SetSquadronEngageProbability("SQ-CCCP SU-25TM", 0.75)


---- Close Air Support Incirlik
--A2GDispatcher:SetSquadron( "SQ-CCCP SU-25", AIRBASE.Syria.Incirlik, { "CCCP SU-25" }, 25 )
----A2GDispatcher:SetSquadronCasPatrol2( "SQ-CCCP SU-25", PatrolZone, 500, 500, 1500, 2000, "RADIO", 200, 230, 500, 1000, "RADIO" ) -- New API
----A2GDispatcher:SetSquadronCasPatrolInterval( "SQ-CCCP SU-25", 1, 300, 600, 1 )
--A2GDispatcher:SetSquadronCas2("SQ-CCCP SU-25",500,500,1500,2500,"RADIO")
--A2GDispatcher:SetSquadronOverhead( "SQ-CCCP SU-25", 0.25 )


-- Close Air Support from the CAS farp.
A2GDispatcher:SetSquadron( "SQ-CCCP KA-50", AIRBASE.Syria.Gazipasa, { "CCCP KA-50" }, 25 )
A2GDispatcher:SetSquadronCasPatrol2( "SQ-CCCP KA-50", PatrolZone, 500, 500, 1500, 2000, "RADIO", 200, 230, 500, 1000, "RADIO" ) -- New API
A2GDispatcher:SetSquadronCasPatrolInterval( "SQ-CCCP KA-50", 2, 300, 600, 1 )
A2GDispatcher:SetSquadronCas2("SQ-CCCP KA-50",500,500,500,1500,"RADIO")
A2GDispatcher:SetSquadronOverhead( "SQ-CCCP KA-50", 0.50 )
A2GDispatcher:SetSquadronEngageProbability("SQ-CCCP KA-50", 0.75)

-- Battlefield Air Interdiction from the BAI farp.
A2GDispatcher:SetSquadron( "SQ-CCCP Mi-24P", AIRBASE.Syria.Gazipasa, { "CCCP Mi-24P" }, 25 )
A2GDispatcher:SetSquadronBaiPatrol2( "SQ-CCCP Mi-24P", PatrolZone, 500, 500, 1500, 2000, "RADIO", 200, 230, 800, 900, "RADIO" ) -- New API
A2GDispatcher:SetSquadronBaiPatrolInterval( "SQ-CCCP Mi-24P", 2, 300, 600, 1 )
A2GDispatcher:SetSquadronBai2("SQ-CCCP Mi-24P",300,300,1000,2000,"RADIO")
A2GDispatcher:SetSquadronOverhead( "SQ-CCCP Mi-24P", 0.50 )
A2GDispatcher:SetSquadronEngageProbability("SQ-CCCP Mi-24P", 0.75)

-- We set for each squadron a takeoff interval, as each helicopter will launch from a FARP.
-- This to prevent helicopters to clutter.
-- Each helicopter group is taking off the FARP in hot start.
A2GDispatcher:SetSquadronTakeoffInterval( "SQ-CCCP SU-25TM", 10 )
--A2GDispatcher:SetSquadronTakeoffInterval( "SQ-CCCP SU-25", 10 )
A2GDispatcher:SetSquadronTakeoffInterval( "SQ-CCCP KA-50", 10 )
A2GDispatcher:SetSquadronTakeoffInterval( "SQ-CCCP Mi-24P", 10 )
