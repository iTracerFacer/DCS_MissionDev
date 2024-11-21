local ENABLE_SAMS = true -- used for testing purposes. Set to true to enable SAMs, false to disable.
local TAC_DISPLAY = false -- Set to false to disable Tacview display for AI flights (default = false)

-- How many red/blue aircraft are in the air by default.
local RedA2ADefaultOverhead = 1.5
local RedDefaultCAP = 2
local BlueA2ADefaultOverhead = 1.5
local BlueDefaultCAP = 2

-- Create the main mission menu.
missionMenu = MENU_MISSION:New("Mission Menu")

--Build Command Center and Mission for Blue
US_CC = COMMANDCENTER:New( GROUP:FindByName( "BLUEHQ" ), "USA HQ" )
US_Mission = MISSION:New( US_CC, "Insurgent Sandstorm", "Primary", "Clear the front lines of enemy activity.", coalition.side.BLUE)    
US_Score = SCORING:New( "Insurgent Sandstorm - Blue" )
US_Mission:AddScoring( US_Score )
US_Mission:Start()
US_Score:SetMessagesHit(false)
US_Score:SetMessagesDestroy(false)
US_Score:SetMessagesScore(false)  
    
--Build Command Center and Mission Red
RU_CC = COMMANDCENTER:New( GROUP:FindByName( "REDHQ" ), "Russia HQ" )
RU_Mission = MISSION:New (RU_CC, "Insurgent Sandstorm", "Primary", "Destroy U.S. and NATO forces.", coalition.side.RED)
RU_Score = SCORING:New("Insurgent Sandstorm - Red")
RU_Mission:AddScoring( RU_Score)
RU_Mission:Start()
RU_Score:SetMessagesHit(false)
RU_Score:SetMessagesDestroy(false)
RU_Score:SetMessagesScore(false)

------------------------------------------------------------------------------------------------------------------------------------------------------
-- Setup SAM Systems
------------------------------------------------------------------------------------------------------------------------------------------------------

local RED_AA_ZONES = {
  ZONE:New("RED-AA-1"),
  ZONE:New("RED-AA-2"),
  ZONE:New("RED-AA-3"),
  ZONE:New("RED-AA-4"),
  ZONE:New("RED-AA-5"),
  ZONE:New("RED-AA-6"),
  ZONE:New("RED-AA-7"),
  ZONE:New("RED-AA-8"),
  ZONE:New("RED-AA-9"),
  ZONE:New("RED-AA-10"),
  ZONE:New("RED-AA-11"),
  ZONE:New("RED-AA-12"),
  ZONE:New("RED-AA-13"),
  ZONE:New("RED-AA-14"),
  ZONE:New("RED-AA-15"),
  ZONE:New("RED-AA-16"),
  ZONE:New("RED-AA-17"),
  ZONE:New("RED-AA-18"),
  ZONE:New("RED-AA-19"),
  ZONE:New("RED-AA-20"),
  ZONE:New("RED-AA-21"),
  ZONE:New("RED-AA-22"),
  ZONE:New("RED-AA-23"),
  ZONE:New("RED-AA-24"),
  ZONE:New("RED-AA-25"),
  ZONE:New("RED-AA-26"),
  ZONE:New("RED-AA-27"),
  ZONE:New("RED-AA-28"),
  ZONE:New("RED-AA-29"),
  ZONE:New("RED-AA-30")

}

-- Schedule RED AA spawns using the calculated frequencies
-- Must allow enough room for an entire group to spawn. If the group only has 1 unit and you put 5, 5 will spawn,
-- but if the group has 5 units, and you put 5, only 1 will spawn..if you only put 4, it will never spawn. 
-- If you put 10, 2 of them will spawn, etc etc. 

if ENABLE_SAMS then
  RED_SA08 = SPAWN:New("RED EWR SA08")
    :InitRandomizeZones(RED_AA_ZONES)
    :InitLimit(8, 8)
    :SpawnScheduled(120, 0.5)

  -- There are 18 units in this group. Need space for each one in the numbers. So if I want 3 SA10s i'm just rounding up to 60.
  RED_SA10 = SPAWN:New("RED EWR AA-SA10-1")
    :InitRandomizeZones(RED_AA_ZONES)
    :InitLimit(60, 60)
    :SpawnScheduled(120, 0.5)

  -- There are 12 units in this group. Need space for each one in the numbers. So if I want 4 SA11s i'm just rounding up to 48
  RED_SA11 = SPAWN:New("RED EWR AA SA112-1")
    :InitRandomizeZones(RED_AA_ZONES)
    :InitLimit(36, 36)
    :SpawnScheduled(120, 0.5)

  -- There are 11 units in this group. Need space for each one in the numbers. So if I want 4 SA11s i'm just rounding up to 44
  RED_SA06 = SPAWN:New("RED EWR SA6")
    :InitRandomizeZones(RED_AA_ZONES)
    :InitLimit(33, 33)
    :SpawnScheduled(120, 0.5)

  RED_SA02 = SPAWN:New("RED EWR SA2")
    :InitRandomizeZones(RED_AA_ZONES)
    :InitLimit(60, 60)
    :SpawnScheduled(120, 0.5)  
end

------------------------------------------------------------------------------------------------------------------------------------------------------
-- Setup Air Dispatchers for RED and BLUE
------------------------------------------------------------------------------------------------------------------------------------------------------

BLUEBorderZone = ZONE_POLYGON:New( "BLUE BORDER", GROUP:FindByName( "BLUE BORDER" ) )
BLUEA2ADispatcher = AI_A2A_GCICAP:NewWithBorder( { "BLUE EWR" }, { "FIGHTER SWEEP BLUE" }, 'BLUE BORDER', 'BLUE BORDER', BlueDefaultCAP, 10000, 50000, 75000, 100)  
BLUEA2ADispatcher:SetDefaultLandingAtRunway()
BLUEA2ADispatcher:SetDefaultTakeoffInAir()
BLUEA2ADispatcher:SetTacticalDisplay(TAC_DISPLAY)
BLUEA2ADispatcher:SetDefaultFuelThreshold( 0.20 )
BLUEA2ADispatcher:SetRefreshTimeInterval( 300 )
BLUEA2ADispatcher:SetDefaultOverhead(BlueA2ADefaultOverhead)
BLUEA2ADispatcher:SetDisengageRadius( 100000 )
BLUEA2ADispatcher:SetEngageRadius( 50000 )
BLUEA2ADispatcher:SetGciRadius( 75000 )

CCCPBorderZone = ZONE_POLYGON:New( "RED BORDER", GROUP:FindByName( "RED BORDER" ) )
RedA2ADispatcher = AI_A2A_GCICAP:NewWithBorder( { "RED EWR" }, { "FIGHTER SWEEP RED" }, "RED BORDER", "RED BORDER", RedDefaultCAP, 10000, 50000, 75000, 100)
RedA2ADispatcher:SetDefaultLandingAtRunway()
RedA2ADispatcher:SetDefaultTakeoffInAir()
RedA2ADispatcher:SetTacticalDisplay(TAC_DISPLAY)
RedA2ADispatcher:SetDefaultFuelThreshold( 0.20 )
RedA2ADispatcher:SetRefreshTimeInterval( 300 )
RedA2ADispatcher:SetDefaultOverhead(RedA2ADefaultOverhead)
RedA2ADispatcher:SetDisengageRadius( 100000 )
RedA2ADispatcher:SetEngageRadius( 50000 )
RedA2ADispatcher:SetGciRadius( 75000 )



DwyerBorderZone = ZONE_POLYGON:New( "DwyerBorderZone", GROUP:FindByName( "DwyerBorderZone" ) )
DwyerDispatcher = AI_A2A_GCICAP:NewWithBorder( { "RED EWR" }, { "DwyerBorderCAP" }, "DwyerBorderZone",  "DwyerBorderZone", RedDefaultCAP, 10000, 50000, 75000, 100)
DwyerDispatcher:SetDefaultLandingAtRunway()
DwyerDispatcher:SetDefaultTakeoffInAir()
DwyerDispatcher:SetBorderZone( DwyerBorderZone )
DwyerDispatcher:SetTacticalDisplay(TAC_DISPLAY)
DwyerDispatcher:SetDefaultFuelThreshold( 0.20 )
DwyerDispatcher:SetRefreshTimeInterval( 300 )
DwyerDispatcher:SetDefaultOverhead(RedA2ADefaultOverhead)
DwyerDispatcher:SetDisengageRadius( 100000 )
DwyerDispatcher:SetEngageRadius( 50000 )
DwyerDispatcher:SetGciRadius( 75000 )


BostZone = ZONE_POLYGON:New( "BostBorderZone", GROUP:FindByName( "BostBorderZone" ) )
BostDispatcher = AI_A2A_GCICAP:NewWithBorder( { "RED EWR" }, { "BostBorderCAP" }, "BostBorderZone", "BostBorderZone", RedDefaultCAP, 10000, 50000, 75000, 100)
BostDispatcher:SetDefaultLandingAtRunway()
BostDispatcher:SetDefaultTakeoffInAir()
BostDispatcher:SetBorderZone(BostZone)
BostDispatcher:SetTacticalDisplay(TAC_DISPLAY)
BostDispatcher:SetDefaultFuelThreshold( 0.20 )
BostDispatcher:SetRefreshTimeInterval( 300 )
BostDispatcher:SetDefaultOverhead(RedA2ADefaultOverhead)
BostDispatcher:SetDisengageRadius( 100000 )
BostDispatcher:SetEngageRadius( 50000 )
BostDispatcher:SetGciRadius( 75000 )

------------------------------------------------------------------------------------------------------------------------------------------------------
-- Clean up the airbases of debris and stuck aircraft.
------------------------------------------------------------------------------------------------------------------------------------------------------

CleanUpAirports = CLEANUP_AIRBASE:New( { 
 AIRBASE.Afghanistan.Kandahar, 
 AIRBASE.Afghanistan.Camp_Bastion
 
} )


------------------------------------------------------------------------------------------------------------------------------------------------------
-- Misc Spawns
------------------------------------------------------------------------------------------------------------------------------------------------------

-- Spawn the RED Bunker Buster
Red_Bunker_Buster = SPAWN:New("BUNKER BUSTER")
  :InitLimit(1, 99)
  :SpawnScheduled(900, 0.5)


Red_Bunker_Buster2 = SPAWN:New("BUNKER BUSTER-1")
  :InitLimit(1, 99)
  :SpawnScheduled(1800, 0.5)



