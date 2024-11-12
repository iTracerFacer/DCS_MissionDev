--  Training Day by F99Th-TracerFacer

    _SETTINGS:SetPlayerMenuOff()
      HQ = GROUP:FindByName( "HQ", "Bravo HQ" )
      CommandCenter = COMMANDCENTER:New( HQ, "Bravo" )
      Scoring = SCORING:New( "Training Day" )
  
    
  -- Create IADS network
    SEAD_RU_SAM_Defenses = SEAD:New( { 
      'SAM_TEMPLATE_SA11',
      'SAM_TEMPLATE_SA10',
      'SAM_TEMPLATE_SA2',
      'SAM_TEMPLATE_SA6',
      'SAM_TEMPLATE_SA15',
      'SAM_TEMPLATE_SA8', } )
      
  -- Spawn SAMS
  local SAM_Zone1 = ZONE_POLYGON:New( "AREA_SAM_TRAINING", GROUP:FindByName("AREA_SAM_TRAINING"))
  local SAM_Zones = { SAM_Zone1 } 
  local SAM_Templates = { 
    "SAM_TEMPLATE_SA11",
    "SAM_TEMPLATE_SA10",
    "SAM_TEMPLATE_SA2",
    "SAM_TEMPLATE_SA6",
    'SAM_TEMPLATE_SA15',
    'SAM_TEMPLATE_SA8', }
    
  Spawn_Sams = SPAWN:New( "RU SAM SITE" )
    :InitLimit( 80, 200 )
    :InitRandomizeZones( SAM_Zones )
    :InitRandomizeTemplate( SAM_Templates )
    :SpawnScheduled( .1, .2 )
    
    
  -- Spawn AG Training Area
  local GROUND_Zone1 = ZONE_POLYGON:New( "AREA_AG_TRAINING_1", GROUP:FindByName( "AREA_AG_TRAINING_1" ) )
  local GROUND_Zone2 = ZONE_POLYGON:New( "AREA_AG_TRAINING_2", GROUP:FindByName( "AREA_AG_TRAINING_2" ) )
  local GROUND_Zone3 = ZONE_POLYGON:New( "AREA_AG_TRAINING_3", GROUP:FindByName( "AREA_AG_TRAINING_3" ) )
  local GROUND_Zone4 = ZONE_POLYGON:New( "AREA_AG_TRAINING_4", GROUP:FindByName( "AREA_AG_TRAINING_4" ) )
  local GROUND_Zone5 = ZONE_POLYGON:New( "AREA_AG_TRAINING_5", GROUP:FindByName( "AREA_AG_TRAINING_5" ) )
  local GROUND_Zone6 = ZONE_POLYGON:New( "AREA_AG_TRAINING_6", GROUP:FindByName( "AREA_AG_TRAINING_6" ) )
  local GROUND_Zone7 = ZONE_POLYGON:New( "AREA_AG_TRAINING_7", GROUP:FindByName( "AREA_AG_TRAINING_7" ) )
  local GROUND_Zone8 = ZONE_POLYGON:New( "AREA_AG_TRAINING_8", GROUP:FindByName( "AREA_AG_TRAINING_8" ) )
  local GROUND_Zone9 = ZONE_POLYGON:New( "AREA_AG_TRAINING_9", GROUP:FindByName( "AREA_AG_TRAINING_9" ) )
  local GROUND_Zone10 = ZONE_POLYGON:New( "AREA_AG_TRAINING_10", GROUP:FindByName( "AREA_AG_TRAINING_10" ) )
  local GROUND_Zone11 = ZONE_POLYGON:New( "AREA_AG_TRAINING_11", GROUP:FindByName( "AREA_AG_TRAINING_11" ) )
  local GROUND_Zone12 = ZONE_POLYGON:New( "AREA_AG_TRAINING_12", GROUP:FindByName( "AREA_AG_TRAINING_12" ) )
  local GROUND_Zone13 = ZONE_POLYGON:New( "AREA_AG_TRAINING_13", GROUP:FindByName( "AREA_AG_TRAINING_13" ) )
  local GROUND_Zone14 = ZONE_POLYGON:New( "AREA_AG_TRAINING_14", GROUP:FindByName( "AREA_AG_TRAINING_14" ) )
  local GROUND_Zone15 = ZONE_POLYGON:New( "AREA_AG_TRAINING_15", GROUP:FindByName( "AREA_AG_TRAINING_15" ) )
  local GROUND_Zone16 = ZONE_POLYGON:New( "AREA_AG_TRAINING_16", GROUP:FindByName( "AREA_AG_TRAINING_16" ) )
  
  
  local GROUND_Zones = { GROUND_Zone1, GROUND_Zone2, GROUND_Zone3, GROUND_Zone4, GROUND_Zone5, GROUND_Zone6, GROUND_Zone7, GROUND_Zone8, GROUND_Zone9, GROUND_Zone10, GROUND_Zone11, GROUND_Zone12, GROUND_Zone13, GROUND_Zone14, GROUND_Zone15, GROUND_Zone16  }
  local GROUND_Templates = {
    "GROUND_Template1",
    "GROUND_Template2",
    "GROUND_Template3",
    "GROUND_Template4",
    "GROUND_Template5" }
    
  Spawn_Ground = SPAWN:New("RU_GROUND_TEMPLATE")
    :InitLimit( 80, 500 )
    :InitRandomizeZones( GROUND_Zones )
    :InitRandomizeTemplate( GROUND_Templates )
    :SpawnScheduled( .1, .2 )
  
      
    

--Setup the RedA2A dispatcher, and initialize it.
  CCCPBorderZone = ZONE_POLYGON:New( "AREA_AA_TRAINING", GROUP:FindByName( "AREA_AA_TRAINING" ) )
  RedA2ADispatcher = AI_A2A_GCICAP:New( { "RED EWR" }, { "FIGHTER SWEEP RED" }, { "RED BORDER" }, 12 )
  RedA2ADispatcher:SetDefaultLandingAtRunway()
 
  --RedA2ADispatcher:SetDefaultTakeoffFromParkingCold()
  RedA2ADispatcher:SetBorderZone( CCCPBorderZone )
  RedA2ADispatcher:SetTacticalDisplay(false)
  RedA2ADispatcher:SetDefaultFuelThreshold( 0.20 )
  RedA2ADispatcher:SetRefreshTimeInterval( 120 )
  RedA2ADispatcher:SetDefaultOverhead(2)
  RedA2ADispatcher:SetDefaultCapLimit(12)
    
  
    -----------Spawn AWACS------------------------------
  Spawn_BlueEWR = SPAWN:New("BLUE EWR"):InitLimit( 1, 50 )
  :InitRepeatOnEngineShutDown()
  :InitCleanUp(120)  
  :SpawnScheduled(300,.3)

  Spawn_RedEWR = SPAWN:New("RED EWR"):InitLimit( 1, 50 )
  :InitRepeatOnEngineShutDown()
  :InitCleanUp(120)
  :SpawnScheduled(300,.4)
  
  Spawn_Blue135 = SPAWN:New("Shell SHL 42 X 253"):InitLimit( 1, 50 )
  :InitRepeatOnEngineShutDown()
  :InitCleanUp(120)
  :SpawnScheduled(300,.3)
  
  Spawn_Blue135MPRS = SPAWN:New("Texaco TEX 41 X 252"):InitLimit( 1, 50 )
  :InitRepeatOnEngineShutDown()
  :InitCleanUp(120)
  :SpawnScheduled(300,.3)    