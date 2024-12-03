--[[ Battle for Rayak Valley - Moose Script
Author: F9tth-TracerFacer

]]

local ENABLE_SAMS = true -- used for testing purposes. Set to true to enable SAMs, false to disable.
local TAC_DISPLAY = false -- Set to false to disable Tacview display for AI flights (default = false)

-- How many red/blue aircraft are in the air by default.
local RedA2ADefaultOverhead = 1.5
local RedDefaultCAP = 2
local BlueA2ADefaultOverhead = 1.5
local BlueDefaultCAP = 2

local shipName = "CVN-72 Abraham Lincoln" -- Replace with the actual name of your ship
local shipUnit = Unit.getByName(shipName)
shipID = shipUnit:getID()
env.info(shipName .. ": " .. shipID)

-- Create the main mission menu.
missionMenu = MENU_MISSION:New("Mission Menu")


--Build Command Center and Mission for Blue
US_CC = COMMANDCENTER:New( GROUP:FindByName( "BLUEHQ" ), "USA HQ" )
US_Mission = MISSION:New( US_CC, "Battle for Rayak Valley", "Primary", "Clear the front lines of enemy activity.", coalition.side.BLUE)    
US_Score = SCORING:New( "Battle for Rayak Valley - Blue" )
US_Mission:AddScoring( US_Score )
US_Mission:Start()
US_Score:SetMessagesHit(false)
US_Score:SetMessagesDestroy(false)
US_Score:SetMessagesScore(false)  
    
--Build Command Center and Mission Red
RU_CC = COMMANDCENTER:New( GROUP:FindByName( "REDHQ" ), "Russia HQ" )
RU_Mission = MISSION:New (RU_CC, "Battle for Rayak Valley", "Primary", "Destroy U.S. and NATO forces.", coalition.side.RED)
RU_Score = SCORING:New("Battle for Rayak Valley - Red")
RU_Mission:AddScoring( RU_Score)
RU_Mission:Start()
RU_Score:SetMessagesHit(false)
RU_Score:SetMessagesDestroy(false)
RU_Score:SetMessagesScore(false)


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



------------------------------------------------------------------------------------------------------------------------------------------------------
-- Setup SAM Systems
------------------------------------------------------------------------------------------------------------------------------------------------------

local RED_AA_ZONES = {
    ZONE:New("Red-SAM-Zone-1"),
    ZONE:New("Red-SAM-Zone-2"),
    ZONE:New("Red-SAM-Zone-3"),
    ZONE:New("Red-SAM-Zone-4"),
    ZONE:New("Red-SAM-Zone-5"),
    ZONE:New("Red-SAM-Zone-6"),
    ZONE:New("Red-SAM-Zone-7"),
    ZONE:New("Red-SAM-Zone-8"),
    ZONE:New("Red-SAM-Zone-9"),
    ZONE:New("Red-SAM-Zone-10"),
    ZONE:New("Red-SAM-Zone-11"),
    ZONE:New("Red-SAM-Zone-12"),
    ZONE:New("Red-SAM-Zone-13"),
    ZONE:New("Red-SAM-Zone-14"),
    ZONE:New("Red-SAM-Zone-15"),
    ZONE:New("Red-SAM-Zone-16"),
    ZONE:New("Red-SAM-Zone-17"),
    ZONE:New("Red-SAM-Zone-18"),
    ZONE:New("Red-SAM-Zone-19"),
    ZONE:New("Red-SAM-Zone-20"),
    ZONE:New("Red-SAM-Zone-21")
  }
  
  -- Schedule RED AA spawns using the calculated frequencies
  -- Must allow enough room for an entire group to spawn. If the group only has 1 unit and you put 5, 5 will spawn,
  -- but if the group has 5 units, and you put 5, only 1 will spawn..if you only put 4, it will never spawn. 
  -- If you put 10, 2 of them will spawn, etc etc. 
  
  if ENABLE_SAMS then
    RED_SA08 = SPAWN:New("RED SAM SA08")
      :InitRandomizeZones(RED_AA_ZONES)
      :InitLimit(8, 8)
      :SpawnScheduled(1800, 0.5)
  
    -- There are 18 units in this group. Need space for each one in the numbers. So if I want 3 SA10s i'm just rounding up to 60.
    RED_SA10 = SPAWN:New("RED SAM SA10")
      :InitRandomizeZones(RED_AA_ZONES)
      :InitLimit(60, 60)
      :SpawnScheduled(1900, 0.5)
  
    -- There are 12 units in this group. Need space for each one in the numbers. So if I want 4 SA11s i'm just rounding up to 48
    RED_SA11 = SPAWN:New("RED SAM SA11")
      :InitRandomizeZones(RED_AA_ZONES)
      :InitLimit(36, 36)
      :SpawnScheduled(2400, 0.5)
  
    -- There are 11 units in this group. Need space for each one in the numbers. So if I want 4 SA11s i'm just rounding up to 44
    RED_SA06 = SPAWN:New("RED SAM SA6")
      :InitRandomizeZones(RED_AA_ZONES)
      :InitLimit(33, 33)
      :SpawnScheduled(1200, 0.5)
  
    RED_SA02 = SPAWN:New("RED SAM SA2")
      :InitRandomizeZones(RED_AA_ZONES)
      :InitLimit(60, 60)
      :SpawnScheduled(2000, 0.5)
      
    RED_SA09 = SPAWN:New("RED SAM SA9")
      :InitRandomizeZones(RED_AA_ZONES)
      :InitLimit(3, 60)
      :SpawnScheduled(2700, 0.5)       

    RED_EWR = SPAWN:New("RED EWR")
    :InitRandomizeZones(RED_AA_ZONES)
    :InitLimit(10, 10)
    :SpawnScheduled(2100, 0.5)        


  end