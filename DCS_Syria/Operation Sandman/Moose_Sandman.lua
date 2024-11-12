-- Setup Command Centers. See Moose_ErmenekLiberation_ZoneCapture.lua for remaining code.
-- Set SRS settings
  STTS.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone"
  STTS.SRS_PORT = "5002"
  
  --Control Number of SAMS on the map:
  -- If the group has 1 unit and you put 10 - you will have 10 groups spawn with 1 unit. 
  -- If the group has 10 units and you put 10 - you will only have 1 group spawn with 10 units. 
  -- If the group has 10 units, but you need 4 groups of them, you put 40 - for 4 groups of 10.
  -- See how the groups are formed in the mission editor for each type.
  local red_shilka = 6
  local red_SA8 = 10
  local red_SA10 = 60
  local red_SA19 = 5
  local red_SA2 = 45
  local red_SA11 = 48
  local red_SA3 = 36
  local red_SA6 = 44
  local red_1L13 = 8
  local red_55G6 = 8
  local red_AAAOnly = 80
  local red_Infantry = 80
  local red_ground = 100
  
  --Build Command Center and Mission for Blue
  US_CC = COMMANDCENTER:New( GROUP:FindByName( "BLUEHQ" ), "USA HQ" )
  US_Mission = MISSION:New( US_CC, "Operation Sandman", "Primary", "Free the city of Ushuaia from Chinese forces. ", coalition.side.BLUE)    
  US_Score = SCORING:New( "Operation Sandman Blue" )
  US_Mission:AddScoring( US_Score )
  US_Mission:Start()
  --Build Command Center and Mission Red
  RU_CC = COMMANDCENTER:New( GROUP:FindByName( "REDHQ" ), "Russia HQ" )
  RU_Mission = MISSION:New (RU_CC, "Operation Sandman", "Primary", "Destroy the Citry of Ushuaia and it's supporting FARPS", coalition.side.RED)
  RU_Score = SCORING:New("Operation Sandman Red")
  RU_Mission:AddScoring( RU_Score)
  RU_Mission:Start()
  
  
  
  ZoneTable = {
  --ZONE:FindByName("Haifa Airbase"), --belongs to blue
  --ZONE:FindByName("Haifa Area"), -- belongs to blue
  --ZONE:FindByName("Naqoura Airbase"), --belongs to blue
  --ZONE:FindByName("Naqoura Area"), --belongs to blue
  ZONE:FindByName("Eyn Shemer Airbase"), 
  ZONE:FindByName("Eyn Shemer Area"),
  ZONE:FindByName("Ramat Airbase"),
  ZONE:FindByName("Megiddo Airbase"),
  ZONE:FindByName("Megiddo Area"),
  ZONE:FindByName("Rosh Pina Airbase"),
  ZONE:FindByName("Rosh Pina Area"),
  ZONE:FindByName("Kiryat Shmona Airbase"),
  ZONE:FindByName("Kiryat Shmona Area"),
  --ZONE:FindByName("Beirut Airbase"), --belongs to blue
  --ZONE:FindByName("Beirut Area"), --belongs to blue
  ZONE:FindByName("Rayak Airbase"),
  ZONE:FindByName("Rayak Area"),
  ZONE:FindByName("Wujah Airbase"),
  ZONE:FindByName("Wujah Area"),
  ZONE:FindByName("An Nasiriyah Airbase"),
  ZONE:FindByName("An Nasiriyah Area"),
  ZONE:FindByName("Sayqal Airbase"),
  ZONE:FindByName("Sayqal Area"),
  ZONE:FindByName("Damascus Area"),
  ZONE:FindByName("Marj Ruhayyil Airbase"),
  ZONE:FindByName("Damascus Airbase"),
  ZONE:FindByName("Al Dumayr Area"),
  ZONE:FindByName("Al Dumayr Airbase"),
  ZONE:FindByName("Marj Sultan South Airbase"),
  ZONE:FindByName("Marj Sultan North Airbase"),
  ZONE:FindByName("Qabr as Sitt Airbase"),
  ZONE:FindByName("Mezzeh Airbase"),
  ZONE:FindByName("Khalkhalah Airbase"),
  ZONE:FindByName("Khalkhalah Area"),
  ZONE:FindByName("Thalah Airbase"),
  ZONE:FindByName("Thalah Area"),
  ZONE:FindByName("King Hussen Airbase"),
  ZONE:FindByName("King Hussen Area"),
  ZONE:FindByName("RZ-1"),
  ZONE:FindByName("RZ-2"),
  ZONE:FindByName("RZ-3"),
  ZONE:FindByName("RZ-4"),
  ZONE:FindByName("RZ-5"),
  ZONE:FindByName("RZ-6"),
  ZONE:FindByName("RZ-7"),
  ZONE:FindByName("RZ-8"),
  ZONE:FindByName("RZ-9"),
  ZONE:FindByName("RZ-10"),
  ZONE:FindByName("RZ-11"),
  ZONE:FindByName("RZ-12"),
  ZONE:FindByName("RZ-13"),
  ZONE:FindByName("RZ-14"),
  ZONE:FindByName("RZ-15"),
  ZONE:FindByName("RZ-16"),
  ZONE:FindByName("RZ-17"),
  ZONE:FindByName("RZ-18"),
  ZONE:FindByName("RZ-19"),
  ZONE:FindByName("RZ-20"),
  ZONE:FindByName("RZ-21"),
  ZONE:FindByName("RZ-22"),
  ZONE:FindByName("RZ-23"),
  ZONE:FindByName("RZ-24"),
  ZONE:FindByName("RZ-25"),
  ZONE:FindByName("RZ-26"),
  ZONE:FindByName("RZ-27"),
  ZONE:FindByName("RZ-28"),
  ZONE:FindByName("RZ-29"),
  ZONE:FindByName("RZ-30"),
  
}  
  
   -- Spawn SAM Networks
  
  Spawn_RED_SAM_Shilka = SPAWN:New("RED SAM Shilka")
  :InitLimit(red_shilka,red_shilka)
  :InitRandomizeZones(ZoneTable)
  :SpawnScheduled(1,.5)
  
  Spawn_RED_SAM_SA2 = SPAWN:New("RED SAM SA-2")
  :InitLimit(red_SA2,red_SA2)
  :InitRandomizeZones(ZoneTable)
  :SpawnScheduled(1,.5)
    
  Spawn_RED_SAM_SA19 = SPAWN:New("RED SAM SA-19")
  :InitLimit(red_SA19,red_SA19)
  :InitRandomizeZones(ZoneTable)
  :SpawnScheduled(1,.5)
    
  Spawn_RED_SAM_SA10 = SPAWN:New("RED SAM_SA10")
  :InitLimit(red_SA10,red_SA10)
  :InitRandomizeZones(ZoneTable)
  :SpawnScheduled(1,.5)
  
  Spawn_RED_SAM_SA8 = SPAWN:New("RED SAM SA-8")
  :InitLimit(red_SA8,red_SA8)
  :InitRandomizeZones(ZoneTable)
  :SpawnScheduled(1,.5)
  
  Spawn_RED_SAM_SA11 = SPAWN:New("RED SAM SA-11")
  :InitLimit(red_SA11,red_SA11)
  :InitRandomizeZones(ZoneTable)
  :SpawnScheduled(1,.5)
  
  Spawn_RED_SAM_SA3 = SPAWN:New("RED SAM SA-3")
  :InitLimit(red_SA3,red_SA3)
  :InitRandomizeZones(ZoneTable)
  :SpawnScheduled(1,.5)    
  
  Spawn_RED_SAM_SA3 = SPAWN:New("RED SAM SA-6")
  :InitLimit(red_SA6,red_SA6)
  :InitRandomizeZones(ZoneTable)
  :SpawnScheduled(1,.5)
  
  --Spawn EWR Network
  Spawn_RED_EWR_1L13 = SPAWN:New("RED EWR 1L13")
  :InitLimit(red_1L13,red_1L13)
  :InitRandomizeZones(ZoneTable)
  :SpawnScheduled(1,.5)

  Spawn_RED_EWR_55G6 = SPAWN:New("RED EWR 55G6")
  :InitLimit(red_55G6,red_55G6)
  :InitRandomizeZones(ZoneTable)
  :SpawnScheduled(1,.5)  

-- Build some stationary groups that we spread through out the zone table above.
  StationaryTemplateTable = { "RU_Ground-1", "RU_Ground-2", "RU_Ground-3", "RU_Ground-4", "RU_Ground-5", "RU_Ground-6", "RU_Ground-7", "RU_Ground-8", "RU_Ground-9", "RU_Ground-10", "RU_Ground-11", "RU_Ground-12" }

  Spawn_Vehicle_1 = SPAWN:New( "RU_Ground-1" )
  :InitLimit( red_ground, red_ground )
  :InitRandomizeTemplate( StationaryTemplateTable ) 
  :InitRandomizeZones( ZoneTable )
  :SpawnScheduled( .1, .5 )  


  Spawn_RED_RU_GroundMoving1 = SPAWN:New("RU_GroundMoving")
  :InitLimit(7,14)
  :InitRandomizeZones(ZoneTable)
  :SpawnScheduled(2300,.3) 
  
  Spawn_RED_RU_GroundMoving2 = SPAWN:New("RU_GroundMoving-1")
  :InitLimit(7,14)
  :InitRandomizeZones(ZoneTable)
  :SpawnScheduled(2300,.4)
  
  Spawn_RED_RU_GroundMoving3 = SPAWN:New("RU_GroundMoving-2")
  :InitLimit(7,14)
  :InitRandomizeZones(ZoneTable)
  :SpawnScheduled(2300,.5)  
  
  
  Spawn_RED_RU_GroundMoving4 = SPAWN:New("RU_GroundMoving-3")
  :InitLimit(7,14)
  --:InitRandomizeZones(ZoneTable)
  :SpawnScheduled(2300,.2)  
  
  Spawn_RED_RU_GroundMoving5 = SPAWN:New("RU_GroundMoving-4")
  :InitLimit(7,14)
  :InitRandomizeZones(ZoneTable)
  :SpawnScheduled(2300,.5)
  
  Spawn_RED_RU_GroundMoving6 = SPAWN:New("RU_GroundMoving-5")
  :InitLimit(7,14)
  :InitRandomizeZones(ZoneTable)
  :SpawnScheduled(2300,.1)
  
  Spawn_RED_RU_GroundMoving7 = SPAWN:New("RU_GroundMoving-6")
  :InitLimit(20,40)
  :InitRandomizeZones(ZoneTable)
  :SpawnScheduled(8500,.4)      

  
  --AWACS

  Spawn_RU_AWACS = SPAWN:New("RED EWR AWACS")
  :InitLimit(1,500)
  :InitRepeatOnLanding()
  :SpawnScheduled(30,.5)
  
  



-- S-3B Recovery Tanker spawning in air.
local tanker=RECOVERYTANKER:New("CVN-72 Abraham Lincoln", "Arco - CVN Recovery Tanker")
tanker:SetTakeoffHot()
tanker:SetRadio(252)
tanker:SetModex(511)
tanker:SetTACAN(2, "ARC")
tanker:SetRespawnOn()
tanker:__Start(600)
  
  
  -- Setup AI A2A Dispatchers
  --Red
  CCCPBorderZone = ZONE_POLYGON:New( "RED BORDER", GROUP:FindByName( "RED BORDER" ) )
  RedA2ADispatcher = AI_A2A_GCICAP:New( { "RED EWR" }, { "FIGHTER SWEEP RED" }, { "RED BORDER" }, 2 )
  RedA2ADispatcher:SetDefaultLandingAtEngineShutdown()
  RedA2ADispatcher:SetDefaultTakeoffFromParkingCold()
  RedA2ADispatcher:SetBorderZone( CCCPBorderZone )
  RedA2ADispatcher:SetTacticalDisplay(false)
  RedA2ADispatcher:SetDefaultFuelThreshold( 0.20 )
  RedA2ADispatcher:SetRefreshTimeInterval( 800 )
  --RedA2ADispatcher:SetDefaultOverhead(1.5)
  
  --Blue
  BLUEBorderZone = ZONE_POLYGON:New( "BLUE BORDER", GROUP:FindByName( "BLUE BORDER" ) )
  BLUEA2ADispatcher = AI_A2A_GCICAP:New( { "BLUE EWR" }, { "FIGHTER SWEEP BLUE" }, { "BLUE BORDER" }, 2 )  
  BLUEA2ADispatcher:SetDefaultLandingAtEngineShutdown()
  BLUEA2ADispatcher:SetDefaultTakeoffFromParkingCold()
  BLUEA2ADispatcher:SetBorderZone( BLUEBorderZone )
  BLUEA2ADispatcher:SetTacticalDisplay(false)
  BLUEA2ADispatcher:SetDefaultFuelThreshold( 0.20 )
  BLUEA2ADispatcher:SetRefreshTimeInterval( 800 )
  --BLUEA2ADispatcher:SetDefaultOverhead(1)
  
  mantisRed = MANTIS:New("mymantisRed","RED SAM","RED EWR","REDHQ","red",false)
  mantisRed:Start()

  mantisBlue = MANTIS:New("mymantisBlue","BLUE SAM","BLUE EWR","BLUEHQ","blue",false)
  mantisBlue:Start()
  
  CleanHaifaAirbase = CLEANUP_AIRBASE:New( AIRBASE.Syria.Haifa )
  CleanHaifaAirbase:SetCleanMissiles(false)
  
  CleanNaqouraAirbase = CLEANUP_AIRBASE:New( AIRBASE.Syria.Naqoura )
  CleanNaqouraAirbase:SetCleanMissiles(false)
  
  CleanBeirutAirbase = CLEANUP_AIRBASE:New( AIRBASE.Syria.Beirut_Rafic_Hariri )
  CleanBeirutAirbase:SetCleanMissiles(false)
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  