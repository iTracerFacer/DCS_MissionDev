-- Setup Command Centers. See Moose_ErmenekLiberation_ZoneCapture.lua for remaining code.
-- Set SRS settings
  STTS.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone"
  STTS.SRS_PORT = "5002"
  
  --Control Number of SAMS on the map:
  -- If the group has 1 unit and you put 10 - you will have 10 groups spawn with 1 unit. 
  -- If the group has 10 units and you put 10 - you will only have 1 group spawn with 10 units. 
  -- If the group has 10 units, but you need 4 groups of them, you put 40 - for 4 groups of 10.
  -- See how the groups are formed in the mission editor for each type.
  local red_SA8 = 15 
  local red_SA10 = 80
  local red_SA19 = 5
  local red_SA2 = 60
  local red_SA11 = 48
  local red_1L13 = 8
  local red_55G6 = 8
  local red_AAAOnly = 80
  local red_Infantry = 60
  local red_ground = 100
  
  --Build Command Center and Mission for Blue
  US_CC = COMMANDCENTER:New( GROUP:FindByName( "BLUEHQ" ), "USA HQ" )
  US_Mission = MISSION:New( US_CC, "Siege of Ushuaia", "Primary", "Free the city of Ushuaia from Chinese forces. ", coalition.side.BLUE)    
  US_Score = SCORING:New( "Siege of Ushuaia" )
  US_Mission:AddScoring( US_Score )
  US_Mission:Start()
  --Build Command Center and Mission Red
  RU_CC = COMMANDCENTER:New( GROUP:FindByName( "REDHQ" ), "Russia HQ" )
  RU_Mission = MISSION:New (RU_CC, "Destruction of Ushuaia", "Primary", "Destroy the Citry of Ushuaia and it's supporting FARPS", coalition.side.RED)
  RU_Score = SCORING:New("Destruction of Ushuaia")
  RU_Mission:AddScoring( RU_Score)
  RU_Mission:Start()
  
  --Menu

-- Used a mission trigger for these.  
--    -- SPAWN RU SEAD ATTACK MISSION 
--  Spawn_RU_SEAD_1 = SPAWN:New("RU_SEAD_ATTACK_1")
--  :InitLimit(4,100)
--  :SpawnScheduled(15000,.5)
--
--  Spawn_RU_SEAD_2 = SPAWN:New("RU_SEAD_ATTACK_2")
--  :InitLimit(4,100)
--  :SpawnScheduled(15000,.5)  
  
  -- Setup Spawn Zones
  ZoneTable = { 
  ZONE_POLYGON:New("s1", GROUP:FindByName("S1")), 
  ZONE_POLYGON:New("s2", GROUP:FindByName("S2")), 
  ZONE_POLYGON:New("s3", GROUP:FindByName("S3")), 
  ZONE_POLYGON:New("s4", GROUP:FindByName("S4")),
  ZONE_POLYGON:New("s5", GROUP:FindByName("S5")),
  ZONE_POLYGON:New("s6", GROUP:FindByName("S6")),
  ZONE_POLYGON:New("s7", GROUP:FindByName("S7")),
  ZONE_POLYGON:New("s8", GROUP:FindByName("S8")),
  ZONE_POLYGON:New("s9", GROUP:FindByName("S9")),
  ZONE_POLYGON:New("s10", GROUP:FindByName("S10")),
  ZONE_POLYGON:New("s11", GROUP:FindByName("S11")),
  ZONE_POLYGON:New("s12", GROUP:FindByName("S12")),
  ZONE_POLYGON:New("s13", GROUP:FindByName("S13")),
  ZONE_POLYGON:New("s14", GROUP:FindByName("S14")),
  ZONE_POLYGON:New("s15", GROUP:FindByName("S15")),
  ZONE_POLYGON:New("s16", GROUP:FindByName("S16")),
  ZONE_POLYGON:New("s17", GROUP:FindByName("S17")),
  ZONE_POLYGON:New("s18", GROUP:FindByName("S18")),
  ZONE_POLYGON:New("s19", GROUP:FindByName("S19")),
  ZONE_POLYGON:New("s20", GROUP:FindByName("S20")),
  ZONE_POLYGON:New("s21", GROUP:FindByName("S21")),
  ZONE_POLYGON:New("s22", GROUP:FindByName("S22")),
  ZONE_POLYGON:New("s23", GROUP:FindByName("S23")),
  ZONE_POLYGON:New("s24", GROUP:FindByName("S24")),
  ZONE_POLYGON:New("s25", GROUP:FindByName("S25")),
  ZONE_POLYGON:New("s26", GROUP:FindByName("S26")),
  ZONE_POLYGON:New("s27", GROUP:FindByName("S27")),
  ZONE_POLYGON:New("s28", GROUP:FindByName("S28")),
  ZONE_POLYGON:New("s29", GROUP:FindByName("S29")),
  ZONE_POLYGON:New("s30", GROUP:FindByName("S30")),
  ZONE_POLYGON:New("s31", GROUP:FindByName("S31")),
  ZONE_POLYGON:New("s32", GROUP:FindByName("S32")),
  ZONE_POLYGON:New("s33", GROUP:FindByName("S33")),
  ZONE_POLYGON:New("s34", GROUP:FindByName("S34")),
  ZONE_POLYGON:New("s35", GROUP:FindByName("S35")),
  ZONE_POLYGON:New("s36", GROUP:FindByName("S36")),
  ZONE_POLYGON:New("s37", GROUP:FindByName("S37")),
  ZONE_POLYGON:New("s38", GROUP:FindByName("S38")),
  ZONE_POLYGON:New("s39", GROUP:FindByName("S39")),
  ZONE_POLYGON:New("s40", GROUP:FindByName("S40")),
  ZONE_POLYGON:New("s41", GROUP:FindByName("S41")),
  ZONE_POLYGON:New("s42", GROUP:FindByName("S42")),
  ZONE_POLYGON:New("s43", GROUP:FindByName("S43")),
  ZONE_POLYGON:New("s44", GROUP:FindByName("S44")),
  ZONE_POLYGON:New("s45", GROUP:FindByName("S45")),
  ZONE_POLYGON:New("s46", GROUP:FindByName("S46")),
  ZONE_POLYGON:New("s47", GROUP:FindByName("S47")),
  ZONE_POLYGON:New("s48", GROUP:FindByName("S48")),
  ZONE_POLYGON:New("s49", GROUP:FindByName("S49")),
  ZONE_POLYGON:New("s50", GROUP:FindByName("S50")),
  ZONE_POLYGON:New("s51", GROUP:FindByName("S51")),
  ZONE_POLYGON:New("s52", GROUP:FindByName("S52")),
  ZONE_POLYGON:New("s53", GROUP:FindByName("S53")),
  ZONE_POLYGON:New("s54", GROUP:FindByName("S54")),
  ZONE_POLYGON:New("s55", GROUP:FindByName("S55")),
  ZONE_POLYGON:New("s56", GROUP:FindByName("S56")),
  
  } --End ZoneTable
  
  
  -- Build some stationary groups that we spread through out the zone table above.
  StationaryTemplateTable = { "RU_Ground-1", "RU_Ground-2", "RU_Ground-3", "RU_Ground-4", "RU_Ground-5", "RU_Ground-6", "RU_Ground-7", "RU_Ground-8" }
  
  Spawn_Vehicle_2 = SPAWN:New( "RU_Ground-1" )
  :InitLimit( red_ground, red_ground )
  :InitRandomizeTemplate( StationaryTemplateTable ) 
  :InitRandomizeZones( ZoneTable )
  :SpawnScheduled( .1, .5 )  
  
  Spawn_SpeedBoat1 = SPAWN:New("RU_Speedboat-1")
  :InitLimit(2,25)
  :SpawnScheduled(1200, .5)
  
  Spawn_SpeedBoat2 = SPAWN:New("RU_Speedboat-2")
  :InitLimit(2,25)
  :SpawnScheduled(1300, .5)
  
  Spawn_SpeedBoat2 = SPAWN:New("RU_Speedboat-3")
  :InitLimit(2,25)
  :SpawnScheduled(1300, .5)

  
  -- Spawn SAM Networks
  Spawn_RED_SAM_SA2 = SPAWN:New("RED SAM SA-2")
  :InitLimit(red_SA2,red_SA2)
  :InitRandomizeZones(ZoneTable)
  :SpawnScheduled(1,.5)
    
  Spawn_RED_SAM_SA19 = SPAWN:New("RED SAM SA-19")
  :InitLimit(red_SA19,red_SA19)
  :InitRandomizeZones(ZoneTable)
  :SpawnScheduled(1,.5)
    
  Spawn_RED_SAM_SA10 = SPAWN:New("RED SAM SA-10")
  :InitLimit(red_SA10,red_SA10)
  :InitRandomizeZones(ZoneTable)
  :SpawnScheduled(1,.5)
  
  Spawn_RED_SAM_SA8 = SPAWN:New("RED SAM SA-8")
  :InitLimit(red_SA8,red_SA8)
  :InitRandomizeZones(ZoneTable)
  :SpawnScheduled(1,.5)
  
  Spawn_RED_SAM_SA8 = SPAWN:New("RED SAM SA-11")
  :InitLimit(red_SA11,red_SA11)
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
  
  Spawn_RED_RU_GroundMoving1 = SPAWN:New("RU_GroundMoving")
  :InitLimit(8,16)
  :InitRandomizeZones(ZoneTable)
  :SpawnScheduled(2300,.5) 
  
  Spawn_RED_RU_GroundMoving2 = SPAWN:New("RU_GroundMoving-1")
  :InitLimit(8,16)
  :InitRandomizeZones(ZoneTable)
  :SpawnScheduled(2300,.5)
  
  Spawn_RED_RU_GroundMoving3 = SPAWN:New("RU_GroundMoving-2")
  :InitLimit(8,16)
  :InitRandomizeZones(ZoneTable)
  :SpawnScheduled(2300,.5)  
  
  
  Spawn_RED_RU_GroundMoving4 = SPAWN:New("RU_GroundMoving-3")
  :InitLimit(20,100)
  --:InitRandomizeZones(ZoneTable)
  :SpawnScheduled(1200,.5)  
  
  Spawn_RED_RU_GroundMoving5 = SPAWN:New("RU_GroundMoving-4")
  :InitLimit(3,100)
  :InitRandomizeZones(ZoneTable)
  :SpawnScheduled(2,.5)    

  Spawn_RED_RU_Arty1 = SPAWN:New("RU_Arty-1")
  :InitLimit(4,10)
  :SpawnScheduled(1800,.5)  

  Spawn_RED_RU_Arty2 = SPAWN:New("RU_Arty-2")
  :InitLimit(4,10)
  :SpawnScheduled(1800,.3)
  
  WestAttackTemplate = {"RU_AshuaWestAttack-1", "RU_AshuaWestAttack-2", "RU_AshuaWestAttack-3", "RU_AshuaWestAttack-4", "RU_AshuaWestAttack-5"}
  Spawn_WestAttack = SPAWN:New( "RU_AshuaWestAttack-1" )
  :InitLimit( 3, 30 )
  :InitRandomizeTemplate( WestAttackTemplate ) 
  :SpawnScheduled( 5600, .2 )  
 
  -- Table of Zones to spread out AA Guns Only
  AAOnlyZoneTable = {
    ZONE:New("AA-ONLY-1"),
    ZONE:New("AA-ONLY-2"),
    ZONE:New("AA-ONLY-3"),
    ZONE:New("AA-ONLY-4"),
    ZONE:New("AA-ONLY-5"),
    ZONE:New("AA-ONLY-6"),
    ZONE:New("AA-ONLY-7"),
    ZONE:New("AA-ONLY-8"),
    ZONE:New("AA-ONLY-9"),
    ZONE:New("AA-ONLY-10"),
    ZONE:New("AA-ONLY-11"),
    ZONE:New("AA-ONLY-12"),
    ZONE:New("AA-ONLY-13"),
    ZONE:New("AA-ONLY-14"),
    ZONE:New("AA-ONLY-15"),
    ZONE:New("AA-ONLY-16"),
    ZONE:New("AA-ONLY-17"),  
    ZONE:New("AA-ONLY-18"),
    ZONE:New("AA-ONLY-19"),
    ZONE:New("AA-ONLY-20"),
    ZONE:New("AA-ONLY-21"),
    ZONE:New("AA-ONLY-22"),
    ZONE:New("AA-ONLY-23"),
    ZONE:New("AA-ONLY-24"),
    ZONE:New("AA-ONLY-25"),
    ZONE:New("AA-ONLY-26"),
    ZONE:New("AA-ONLY-27"),
    ZONE:New("AA-ONLY-28"),
    ZONE:New("AA-ONLY-29"),
    ZONE:New("AA-ONLY-30"),
    ZONE:New("AA-ONLY-31"),    
    ZONE:New("AA-ONLY-32"),
    ZONE:New("AA-ONLY-33"),
    ZONE:New("AA-ONLY-34"),
    ZONE:New("AA-ONLY-35"),
    ZONE:New("AA-ONLY-36"),
    ZONE:New("AA-ONLY-37"),
    ZONE:New("AA-ONLY-38"),
    ZONE:New("AA-ONLY-39"),
    ZONE:New("AA-ONLY-40"),
    ZONE:New("AA-ONLY-41"),
    ZONE:New("AA-ONLY-42"),
    ZONE:New("AA-ONLY-43"),
    ZONE:New("AA-ONLY-44"),
    ZONE:New("AA-ONLY-45"),
    ZONE:New("AA-ONLY-46"),
    ZONE:New("AA-ONLY-47"),
    ZONE:New("AA-ONLY-48"),
    ZONE:New("AA-ONLY-49"),
    ZONE:New("AA-ONLY-50"),
    ZONE:New("AA-ONLY-51"),
    ZONE:New("AA-ONLY-52"),
    ZONE:New("AA-ONLY-53"),
    ZONE:New("AA-ONLY-54"),
    ZONE:New("AA-ONLY-55"),
    ZONE:New("AA-ONLY-56"),
    ZONE:New("AA-ONLY-57"),
    ZONE:New("AA-ONLY-58"),
    ZONE:New("AA-ONLY-59"),
    ZONE:New("AA-ONLY-60"),
    ZONE:New("AA-ONLY-61"),
    ZONE:New("AA-ONLY-62"),
    ZONE:New("AA-ONLY-63"),
    ZONE:New("AA-ONLY-64"),
    ZONE:New("AA-ONLY-65"),
    ZONE:New("AA-ONLY-66"),
    ZONE:New("AA-ONLY-67"),
    ZONE:New("AA-ONLY-68"),
    ZONE:New("AA-ONLY-69"),
    ZONE:New("AA-ONLY-70"),
    ZONE:New("AA-ONLY-71"),
    ZONE:New("AA-ONLY-72"),
    ZONE:New("AA-ONLY-73"),
    ZONE:New("AA-ONLY-74"),
    ZONE:New("AA-ONLY-75"),
    ZONE:New("AA-ONLY-76"),
    ZONE:New("AA-ONLY-77"),
    ZONE:New("AA-ONLY-78"),
    ZONE:New("AA-ONLY-79"),
    ZONE:New("AA-ONLY-80"),
    ZONE:New("AA-ONLY-81"),
    ZONE:New("AA-ONLY-82"),
    ZONE:New("AA-ONLY-83"),
    ZONE:New("AA-ONLY-84"),
    ZONE:New("AA-ONLY-85"),
    ZONE:New("AA-ONLY-86"),
    ZONE:New("AA-ONLY-87"),
    ZONE:New("AA-ONLY-88"),
    ZONE:New("AA-ONLY-89"),
    ZONE:New("AA-ONLY-90"),
    ZONE:New("AA-ONLY-91"),
    ZONE:New("AA-ONLY-92"),
    ZONE:New("AA-ONLY-93"),
    ZONE:New("AA-ONLY-94"),
    ZONE:New("AA-ONLY-95"),
    ZONE:New("AA-ONLY-96"),
    ZONE:New("AA-ONLY-97"),
    ZONE:New("AA-ONLY-98"),
    ZONE:New("AA-ONLY-99"),
    ZONE:New("AA-ONLY-100"),
    ZONE:New("AA-ONLY-101"),
    ZONE:New("AA-ONLY-102"),
    ZONE:New("AA-ONLY-103"),
    ZONE:New("AA-ONLY-104"),
    ZONE:New("AA-ONLY-105"),
    ZONE:New("AA-ONLY-106"),
    ZONE:New("AA-ONLY-107"),
    ZONE:New("AA-ONLY-108"),
    ZONE:New("AA-ONLY-109"),
    ZONE:New("AA-ONLY-110"),
    ZONE:New("AA-ONLY-111"),
    ZONE:New("AA-ONLY-112"),
    ZONE:New("AA-ONLY-113"),
    ZONE:New("AA-ONLY-114"),
    ZONE:New("AA-ONLY-115"),
    ZONE:New("AA-ONLY-116"),
    ZONE:New("AA-ONLY-117"),
    ZONE:New("AA-ONLY-118"),
    ZONE:New("AA-ONLY-119"),
    ZONE:New("AA-ONLY-120"),
    ZONE:New("AA-ONLY-121"),
    ZONE:New("AA-ONLY-122"),
    ZONE:New("AA-ONLY-123"),
    ZONE:New("AA-ONLY-124"),
    ZONE:New("AA-ONLY-125"),
    ZONE:New("AA-ONLY-126"),
    ZONE:New("AA-ONLY-127"),
    ZONE:New("AA-ONLY-128"),
    ZONE:New("AA-ONLY-129"),
    ZONE:New("AA-ONLY-130"),
    ZONE:New("AA-ONLY-131"),
    ZONE:New("AA-ONLY-132"),
    ZONE:New("AA-ONLY-133"),
    ZONE:New("AA-ONLY-134"),
    ZONE:New("AA-ONLY-135"),
    ZONE:New("AA-ONLY-136"),
    ZONE:New("AA-ONLY-137"),
    ZONE:New("AA-ONLY-138"),
    ZONE:New("AA-ONLY-139"),
    ZONE:New("AA-ONLY-140"),
    ZONE:New("AA-ONLY-141"),
    ZONE:New("AA-ONLY-142"),
    ZONE:New("AA-ONLY-143"),
    ZONE:New("AA-ONLY-144"),
    ZONE:New("AA-ONLY-145"),
    ZONE:New("AA-ONLY-146"),
    ZONE:New("AA-ONLY-147"),
    ZONE:New("AA-ONLY-148"),
    ZONE:New("AA-ONLY-149"),
    ZONE:New("AA-ONLY-150"),
    ZONE:New("AA-ONLY-151"),
    ZONE:New("AA-ONLY-152"),
    ZONE:New("AA-ONLY-153"),
    ZONE:New("AA-ONLY-154"),
    ZONE:New("AA-ONLY-155"),
    ZONE:New("AA-ONLY-156"),
    ZONE:New("AA-ONLY-157"),
    ZONE:New("AA-ONLY-158"),
    ZONE:New("AA-ONLY-159"),
    ZONE:New("AA-ONLY-160"),
    
  }
  
  Spawn_RU_AAOnly = SPAWN:New( "AAA-Only-1" )  
  :InitLimit(red_AAAOnly,red_AAAOnly)
  :InitRandomizeZones( AAOnlyZoneTable )
  :SpawnScheduled(.1,.5)
  
  -- Table of zones that only infantry spawn at.
  InfantryZoneTable = {
    ZONE_POLYGON:New("is5", GROUP:FindByName("S5")),
    ZONE_POLYGON:New("is8", GROUP:FindByName("S8")),
    ZONE_POLYGON:New("is9", GROUP:FindByName("S9")),
    ZONE_POLYGON:New("is10", GROUP:FindByName("S10")),
    ZONE_POLYGON:New("is11", GROUP:FindByName("S11")),
    ZONE_POLYGON:New("is12", GROUP:FindByName("S12")),
    ZONE_POLYGON:New("is12", GROUP:FindByName("S13")),
    ZONE_POLYGON:New("is19", GROUP:FindByName("S19")),
    ZONE_POLYGON:New("is21", GROUP:FindByName("S21")),
    ZONE_POLYGON:New("is24", GROUP:FindByName("S24")),
    ZONE_POLYGON:New("is26", GROUP:FindByName("S26")),
    ZONE_POLYGON:New("is27", GROUP:FindByName("S27")),
    ZONE_POLYGON:New("RU_InfantrySpawnZone1", GROUP:FindByName("RU_InfantrySpawnZone-1"))
    
   
    }
    
  InfantryTemplateTable = {"RU_Platoon-1", "RU_Platoon-2", "RU_Platoon-3", "RU_Platoon-4", "RU_Platoon-5" }
    
  Spawn_RU_Platoon1 = SPAWN:New("RU_Platoon-1")  
  :InitLimit(red_Infantry,red_Infantry)
  :InitRandomizeTemplate(InfantryTemplateTable) 
  :InitRandomizeZones(InfantryZoneTable)
  :SpawnScheduled(1, .2)
  
-----------------------------------------------------------------------------
--AWACS

  Spawn_RU_AWACS = SPAWN:New("RED EWR AWACS")
  :InitLimit(1,500)
  :InitRepeatOnLanding()
  :SpawnScheduled(30,.5)
  
  
  
--  Spawn_US_AWACS = SPAWN:New("BLUE EWR E-2D Wizard Group")
--  :InitLimit(1,500)
--  :InitRepeatOnLanding()
--  :SpawnScheduled(30,.5)

  
  
  


-- S-3B Recovery Tanker spawning in air.
local tanker=RECOVERYTANKER:New("CVN-72 Abraham Lincoln", "Arco - CVN Recovery Tanker")
tanker:SetTakeoffAir()
tanker:SetRadio(250)
tanker:SetModex(511)
tanker:SetTACAN(1, "ARC")
tanker:SetRespawnOn()
tanker:__Start(600)



------------------------------------------------------------------------------------------
---- MANTIS - Modular, Automatic and Network capable Targeting and Interception System.
------------------------------------------------------------------------------------------


mantisRed = MANTIS:New("mymantisRed","RED SAM","RED EWR","RED HQ","red",false)
mantisRed:Start()

mantisBlue = MANTIS:New("mymantisBlue","BLUE SAM","BLUE EWR","BLUE HQ","blue",false)
mantisBlue:Start()



---- Random Air Traffic 
---- Create RAT object. The only required parameter is the name of the template group in the mission editor.
--local RAT_Helo1 = RAT:New("RAT_Helo-1")
--RAT_Helo1:Spawn(3) -- Spawn 1
--RAT_Helo1:ATC_Messages(false)
--RAT_Helo1:SetCoalition("sameonly")
-- 
--
--local RAT_Helo2 = RAT:New("RAT_Helo-2")
--RAT_Helo2:Spawn(3) -- Spawn 1
--RAT_Helo2:ATC_Messages(false) 
--RAT_Helo2:SetCoalition("sameonly")
--
--
--local RAT_RU_Helo1 = RAT:New("RAT_RU_Helo-1")
--RAT_RU_Helo1:Spawn(3) -- Spawn 1
--RAT_RU_Helo1:ATC_Messages(false)
--RAT_RU_Helo1:SetCoalition("sameonly")
--
--local RAT_RU_TransportPlane1 = RAT:New("RAT_RU_TransportPlane-1")
--RAT_RU_TransportPlane1:Spawn(3) -- Spawn 1
--RAT_RU_TransportPlane1:ATC_Messages(false)
--RAT_RU_TransportPlane1:SetCoalition("sameonly")



----------------------------------------------------------------------------------------
-- Setup AI A2A Dispatchers
  
    --Red
  CCCPBorderZone = ZONE_POLYGON:New( "RED BORDER", GROUP:FindByName( "RED BORDER" ) )
  RedA2ADispatcher = AI_A2A_GCICAP:New( { "RED EWR" }, { "FIGHTER SWEEP RED" }, { "RED BORDER" }, 2 )
  RedA2ADispatcher:SetDefaultLandingAtEngineShutdown()
  RedA2ADispatcher:SetDefaultTakeoffFromParkingCold()
  RedA2ADispatcher:SetBorderZone( CCCPBorderZone )
  RedA2ADispatcher:SetTacticalDisplay(false)
  RedA2ADispatcher:SetDefaultFuelThreshold( 0.20 )
  RedA2ADispatcher:SetRefreshTimeInterval( 1200 )
  --RedA2ADispatcher:SetDefaultOverhead(1.5)
  
  --Blue
  BLUEBorderZone = ZONE_POLYGON:New( "BLUE BORDER", GROUP:FindByName( "BLUE BORDER" ) )
  BLUEA2ADispatcher = AI_A2A_GCICAP:New( { "BLUE EWR" }, { "FIGHTER SWEEP BLUE" }, { "BLUE BORDER" }, 2 )  
  BLUEA2ADispatcher:SetDefaultLandingAtEngineShutdown()
  BLUEA2ADispatcher:SetDefaultTakeoffInAirAltitude(100)
  BLUEA2ADispatcher:SetBorderZone( BLUEBorderZone )
  BLUEA2ADispatcher:SetTacticalDisplay(false)
  BLUEA2ADispatcher:SetDefaultFuelThreshold( 0.20 )
  BLUEA2ADispatcher:SetRefreshTimeInterval( 1200 )
  --BLUEA2ADispatcher:SetDefaultOverhead(1)
  
  
    --Blue
function BorderStartDetolhuin()  
  DeTolhuinBorder = ZONE_POLYGON:New( "De TolHuin Border Patrol", GROUP:FindByName( "De TolHuin Border Patrol" ) )
  DeTolhuinBorderBLUEA2ADispatcher = AI_A2A_GCICAP:New( { "BLUE EWR" }, { "DE TOLHUIN FIGHTER SWEEP" }, { "De TolHuin Border Patrol" }, 1 )  
  DeTolhuinBorderBLUEA2ADispatcher:SetDefaultLandingAtEngineShutdown()
  DeTolhuinBorderBLUEA2ADispatcher:SetDefaultTakeoffFromParkingCold()
  DeTolhuinBorderBLUEA2ADispatcher:SetBorderZone( DeTolhuinBorder )
  DeTolhuinBorderBLUEA2ADispatcher:SetTacticalDisplay(false)
  DeTolhuinBorderBLUEA2ADispatcher:SetDefaultFuelThreshold( 0.20 )
  DeTolhuinBorderBLUEA2ADispatcher:SetRefreshTimeInterval( 600 )
end
    --Blue
function BorderStartRioGrand()
  RioGrandBorder = ZONE_POLYGON:New( "Rio Grand Patrol Zone", GROUP:FindByName( "Rio Grand Patrol Zone" ) )
  RioGrandBorderBLUEA2ADispatcher = AI_A2A_GCICAP:New( { "BLUE EWR" }, { "RIO GRANDE FIGHTER SWEEP" }, { "Rio Grand Patrol Zone" }, 1 )  
  RioGrandBorderBLUEA2ADispatcher:SetDefaultLandingAtEngineShutdown()
  RioGrandBorderBLUEA2ADispatcher:SetDefaultTakeoffFromParkingCold()
  RioGrandBorderBLUEA2ADispatcher:SetBorderZone( RioGrandBorder )
  RioGrandBorderBLUEA2ADispatcher:SetTacticalDisplay(false)
  RioGrandBorderBLUEA2ADispatcher:SetDefaultFuelThreshold( 0.20 )
  RioGrandBorderBLUEA2ADispatcher:SetRefreshTimeInterval( 600 )
end
      --Blue
function BorderStartAlmirante()      
  AlmiranteBorder = ZONE_POLYGON:New( "ALMIRANTE PATROL ZONE", GROUP:FindByName( "ALMIRANTE PATROL ZONE" ) )
  AlmiranteBorderBLUEA2ADispatcher = AI_A2A_GCICAP:New( { "BLUE EWR" }, { "ALMIRANTE FIGHTER SWEEP" }, { "ALMIRANTE PATROL ZONE" }, 1 )  
  AlmiranteBorderBLUEA2ADispatcher:SetDefaultLandingAtEngineShutdown()
  AlmiranteBorderBLUEA2ADispatcher:SetDefaultTakeoffFromParkingCold()
  AlmiranteBorderBLUEA2ADispatcher:SetBorderZone( AlmiranteBorder )
  AlmiranteBorderBLUEA2ADispatcher:SetTacticalDisplay(false)
  AlmiranteBorderBLUEA2ADispatcher:SetDefaultFuelThreshold( 0.20 )
  AlmiranteBorderBLUEA2ADispatcher:SetRefreshTimeInterval( 600 )
end  
  
      --Blue
function BorderStartPunta()
  PuntaBorder = ZONE_POLYGON:New( "PUNTA PATROL ZONE", GROUP:FindByName( "PUNTA PATROL ZONE" ) )
  PuntaBorderBLUEA2ADispatcher = AI_A2A_GCICAP:New( { "BLUE EWR" }, { "PUNTA FIGHTER SWEEP" }, { "PUNTA PATROL ZONE" }, 1 )  
  PuntaBorderBLUEA2ADispatcher:SetDefaultLandingAtEngineShutdown()
  PuntaBorderBLUEA2ADispatcher:SetDefaultTakeoffFromParkingCold()
  PuntaBorderBLUEA2ADispatcher:SetBorderZone( PuntaBorder )
  PuntaBorderBLUEA2ADispatcher:SetTacticalDisplay(false)
  PuntaBorderBLUEA2ADispatcher:SetDefaultFuelThreshold( 0.20 )
  PuntaBorderBLUEA2ADispatcher:SetRefreshTimeInterval( 600 )
end
  
      --Blue
function BorderStartPuertoWilliams()
  PuertoWilliamsBorder = ZONE_POLYGON:New( "BLUE BORDER", GROUP:FindByName( "BLUE BORDER" ) )
  PuertoWilliamsBorderBLUEA2ADispatcher = AI_A2A_GCICAP:New( { "BLUE EWR" }, { "PUERTO WILLIAMS PATROL" }, { "BLUE BORDER" }, 1 )  
  PuertoWilliamsBorderBLUEA2ADispatcher:SetDefaultLandingAtEngineShutdown()
  PuertoWilliamsBorderBLUEA2ADispatcher:SetDefaultTakeoffFromParkingCold()
  PuertoWilliamsBorderBLUEA2ADispatcher:SetBorderZone( PuertoWilliamsBorder )
  PuertoWilliamsBorderBLUEA2ADispatcher:SetTacticalDisplay(false)
  PuertoWilliamsBorderBLUEA2ADispatcher:SetDefaultFuelThreshold( 0.20 )
  PuertoWilliamsBorderBLUEA2ADispatcher:SetRefreshTimeInterval( 600 )
end



Ushuaia_Helo_Port_Clean = CLEANUP_AIRBASE:New( AIRBASE.SouthAtlantic.Ushuaia_Helo_Port )
Ushuaia_Helo_Port_Clean:SetCleanMissiles(false)

Ushuaia_Clean = CLEANUP_AIRBASE:New( AIRBASE.SouthAtlantic.Ushuaia )
Ushuaia_Clean:SetCleanMissiles(false)

Puerto_Williams_Clean = CLEANUP_AIRBASE:New( AIRBASE.SouthAtlantic.Puerto_Williams )
Puerto_Williams_Clean:SetCleanMissiles(false)

Aerodromo_De_Tolhuin_Clean = CLEANUP_AIRBASE:New( AIRBASE.SouthAtlantic.Aerodromo_De_Tolhuin )
Aerodromo_De_Tolhuin_Clean:SetCleanMissiles(false)

Rio_Grande_Clean = CLEANUP_AIRBASE:New( AIRBASE.SouthAtlantic.Rio_Grande )
Rio_Grande_Clean:SetCleanMissiles(false)

Pampa_Guanaco_Clean = CLEANUP_AIRBASE:New( AIRBASE.SouthAtlantic.Pampa_Guanaco )
Pampa_Guanaco_Clean:SetCleanMissiles(false)

Almirante_Schroeders_Clean = CLEANUP_AIRBASE:New( AIRBASE.SouthAtlantic.Almirante_Schroeders )
Almirante_Schroeders_Clean:SetCleanMissiles(false)

Porvenir_Airfield_Clean = CLEANUP_AIRBASE:New( AIRBASE.SouthAtlantic.Porvenir_Airfield )
Porvenir_Airfield_Clean:SetCleanMissiles(false)

Punta_Arenas_Clean = CLEANUP_AIRBASE:New( AIRBASE.SouthAtlantic.Punta_Arenas )
Punta_Arenas_Clean:SetCleanMissiles(false)
