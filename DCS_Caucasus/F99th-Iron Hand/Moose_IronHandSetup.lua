
--[[
  The purpose of this file is to setup the mission in support of the
  Persistance mod DSMC. This MOD requires that you strictly control the 
  spawning of new units to prevent subsequent luanches of the mission 
  from spawning more and more units on top of ones already spawned.
  
  
  1. Load mission in single player. 
  2. Let all objects load. 
  3. Use F10 Menu to DSMC Save.
  4. Open newly created mission in ME and remove this script from the mission.
  4. Upload your edited version to the server.
  
   

--]]


     -- Create zones to use later in the randomization.
  local BATUMI_COSTAL_DEF_1 = ZONE_POLYGON:New("RU_BATUMI_COSTAL_DEF_1", GROUP:FindByName("RU_BATUMI_COSTAL_DEF_1" ) )
  local BATUMI_COSTAL_DEF_2 = ZONE_POLYGON:New("RU_BATUMI_COSTAL_DEF_2", GROUP:FindByName("RU_BATUMI_COSTAL_DEF_2" ) )
  local BATUMI_COSTAL_DEF_Zones = { BATUMI_COSTAL_DEF_1, BATUMI_COSTAL_DEF_2 }
  local RU_BATUMI_COSTAL_DEF_TEMPLATES = {
    "RU_BATUMI_COSTAL_DEF_TEMPLATE_1", 
    "RU_BATUMI_COSTAL_DEF_TEMPLATE_2",
    "RU_BATUMI_COSTAL_DEF_TEMPLATE_3", }
    
  Spawn_Batumi_CostalDef = SPAWN:New("RU_BATUMI_COSTAL_DEF_TEMPLATE_1")
  :InitLimit( 100, 100 )
  :InitRandomizeZones( BATUMI_COSTAL_DEF_Zones )
  :InitRandomizeTemplate( RU_BATUMI_COSTAL_DEF_TEMPLATES )
  :SpawnScheduled( .1, .2 )
    
  
  
     
  local GROUND_ZONE_1 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_1", GROUP:FindByName( "RU_GRND_SPWN_ZONE_1" ) )
  local GROUND_ZONE_2 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_2", GROUP:FindByName( "RU_GRND_SPWN_ZONE_2" ) )
  local GROUND_ZONE_3 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_3", GROUP:FindByName( "RU_GRND_SPWN_ZONE_3" ) )
  local GROUND_ZONE_4 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_4", GROUP:FindByName( "RU_GRND_SPWN_ZONE_4" ) )
  local GROUND_ZONE_5 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_5", GROUP:FindByName( "RU_GRND_SPWN_ZONE_5" ) )
  local GROUND_ZONE_6 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_6", GROUP:FindByName( "RU_GRND_SPWN_ZONE_6" ) )
  local GROUND_ZONE_7 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_7", GROUP:FindByName( "RU_GRND_SPWN_ZONE_7" ) )
  local GROUND_ZONE_8 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_8", GROUP:FindByName( "RU_GRND_SPWN_ZONE_8" ) )
  local GROUND_ZONE_9 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_9", GROUP:FindByName( "RU_GRND_SPWN_ZONE_9" ) )
  local GROUND_ZONE_10 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_10", GROUP:FindByName( "RU_GRND_SPWN_ZONE_10" ) )
  local GROUND_ZONE_11 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_11", GROUP:FindByName( "RU_GRND_SPWN_ZONE_11" ) )
  local GROUND_ZONE_12 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_12", GROUP:FindByName( "RU_GRND_SPWN_ZONE_12" ) )
  local GROUND_ZONE_13 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_13", GROUP:FindByName( "RU_GRND_SPWN_ZONE_13" ) )
  local GROUND_ZONE_14 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_14", GROUP:FindByName( "RU_GRND_SPWN_ZONE_14" ) )
  local GROUND_ZONE_15 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_15", GROUP:FindByName( "RU_GRND_SPWN_ZONE_15" ) )
  local GROUND_ZONE_16 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_16", GROUP:FindByName( "RU_GRND_SPWN_ZONE_16" ) )
  local GROUND_ZONE_17 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_17", GROUP:FindByName( "RU_GRND_SPWN_ZONE_17" ) )
  local GROUND_ZONE_18 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_18", GROUP:FindByName( "RU_GRND_SPWN_ZONE_18" ) )
  local GROUND_ZONE_19 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_19", GROUP:FindByName( "RU_GRND_SPWN_ZONE_19" ) )
  local GROUND_ZONE_20 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_20", GROUP:FindByName( "RU_GRND_SPWN_ZONE_20" ) )
  local GROUND_ZONE_21 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_21", GROUP:FindByName( "RU_GRND_SPWN_ZONE_21" ) )
  local GROUND_ZONE_22 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_22", GROUP:FindByName( "RU_GRND_SPWN_ZONE_22" ) )
  local GROUND_ZONE_23 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_23", GROUP:FindByName( "RU_GRND_SPWN_ZONE_23" ) )
  local GROUND_ZONE_24 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_24", GROUP:FindByName( "RU_GRND_SPWN_ZONE_24" ) )
  local GROUND_ZONE_25 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_25", GROUP:FindByName( "RU_GRND_SPWN_ZONE_25" ) )
  local GROUND_ZONE_26 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_26", GROUP:FindByName( "RU_GRND_SPWN_ZONE_26" ) )
  local GROUND_ZONE_27 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_27", GROUP:FindByName( "RU_GRND_SPWN_ZONE_27" ) )
  local GROUND_ZONE_28 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_28", GROUP:FindByName( "RU_GRND_SPWN_ZONE_28" ) )
  local GROUND_ZONE_29 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_29", GROUP:FindByName( "RU_GRND_SPWN_ZONE_29" ) )
  local GROUND_ZONE_30 = ZONE_POLYGON:New( "RU_GRND_SPWN_ZONE_30", GROUP:FindByName( "RU_GRND_SPWN_ZONE_30" ) )
  
  -- Group all the above zones into an array to use later..
  local GROUND_Zones = { GROUND_ZONE_1, GROUND_ZONE_2, GROUND_ZONE_3, GROUND_ZONE_4, GROUND_ZONE_5, GROUND_ZONE_6,
     GROUND_ZONE_7, GROUND_ZONE_8, GROUND_ZONE_9, GROUND_ZONE_10, GROUND_ZONE_11, GROUND_ZONE_12, GROUND_ZONE_13, GROUND_ZONE_14,
     GROUND_ZONE_15, GROUND_ZONE_16, GROUND_ZONE_17, GROUND_ZONE_18, GROUND_ZONE_19, GROUND_ZONE_20, GROUND_ZONE_21, GROUND_ZONE_22,
     GROUND_ZONE_23, GROUND_ZONE_24, GROUND_ZONE_25, GROUND_ZONE_26, GROUND_ZONE_27, GROUND_ZONE_28, GROUND_ZONE_29, GROUND_ZONE_30 }
  
  -- These are the ground templates found in the mission editor.
  local GROUND_Templates = {
    "GROUND_Template1",
    "GROUND_Template2",
    "GROUND_Template3",
    "GROUND_Template4",
    "GROUND_Template5",
    "GROUND_Template6",
    "GROUND_Template7",
    "GROUND_Template8",
    "GROUND_Template9",
    "GROUND_Template10",
    "GROUND_Template11",
    "GROUND_Template12",
    "GROUND_Template13",
    "GROUND_Template14", }
  --Spawn the ground units using the zone and unit templates defined above.
  Spawn_Ground = SPAWN:New("RU_GROUND_TEMPLATE")
  :InitLimit( 200, 200 )
  :InitRandomizeZones( GROUND_Zones )
  :InitRandomizeTemplate( GROUND_Templates )
  :SpawnScheduled( .1, .2 )


  local AAA_Templates = { 
    "AAA_Template1",
    "AAA_Template2", 
    "AAA_Template3", 
    "AAA_Template4", 
    "AAA_Template5",  
    "AAA_Template6", 
    "AAA_Template7",
    "AAA_Template8" }

  Spawn_AAA = SPAWN:New("RED EWR-14")
  :InitLimit( 20, 30 )
  :InitRandomizeZones( GROUND_Zones )
  :InitRandomizeTemplate( AAA_Templates )
  :SpawnScheduled( .1, .2 )
  
  -- There are 10 units in this sam site. Spawning 40 at the beging and limit to 40 will produce 4 SA10 sam sites (max)
  local SA10_Templates = {"AAA_SA10_Template"}
  Spawn_SA10 = SPAWN:New("SA_10_SITE")
  :InitLimit( 40, 40 )
  :InitRandomizeZones( GROUND_Zones )
  :InitRandomizeTemplate( SA10_Templates )
  :SpawnScheduled( .1, .2 )
  
 
