--  The Battle of Gori by F99Th-TracerFacer

_SETTINGS:SetPlayerMenuOff()
  
  ScoreRequiredToWin = 100
  BlueCurrentScore = 0
  RedCurrentScore = 0
  StatBlueCratesMoved = 0
  StatBlueRescued = 0
  StatRedArtyUnitsDead = 0
  StatRedCAPDead = 0
  StatBlueCAPDead = 0
  
  
  
  PlayerClients = SET_PLAYER:New():FilterStart()
    :HandleEvent( EVENTS.Crash )
  function PlayerClients:OnEventCrash( EventData )
    
    local coal = EventData.initiator:getCoalition()
    local side, oside
    if coal == 1 then
        side = 'RED'
        oside = 'BLUE'
        GoriPlayerName = EventData.initiator:getPlayerName() 
        if GoriPlayerName ~= nil then
  
          MESSAGE:New("\n\nA " .. side .. " player ( " .. GoriPlayerName .. " ) has crashed! " .. oside .. " Team gains 1 point!", 10, "Alert!"):ToAll()
          ScoreAddBlue(1)
          StatRedCAPDead = StatRedCAPDead + 1
        
        end
 
    elseif coal == 2 then 
     
      side = 'BLUE'
      oside = 'RED'
      GoriPlayerName = EventData.initiator:getPlayerName() 
      if  GoriPlayerName ~= nil then
          MESSAGE:New("\n\nA " .. side .. " player ( " .. GoriPlayerName .. " ) has crashed! " .. oside .. " Team gains 1 point!", 10, "Alert!"):ToAll()
          ScoreAddRed(1)
          StatBlueCAPDead = StatBlueCAPDead + 1
      end
    else
      env.info("**** We should not have gotten here! Moose_BattleofGori.lua ****")
    end    
      	
  end
 
 
 
  -- Setup Shelling Zones
  local BombZone1 = ZONE_POLYGON:New("BombZone1", GROUP:FindByName( "BombZone1"))
  local HighAirShellingZone = ZONE:New("HIGH AIR SHELLING ZONE")

  -- Setup Arty Zone  
  local ArtyTemplate = { "RU_ARTY", "RU_ARTY #001", "RU_ARTY #002", "RU_ARTY_SA8", "RU_ARTY_SA9", "RU_ARTY_SA11" }
  local ArtyZone = ZONE_POLYGON:New( "ARTY LOCATIONS", GROUP:FindByName( "ARTY LOCATIONS" ))
  local ArtyZoneTable = { ArtyZone }

  -- Setup SA10 Zone
  local SA10Zone = ZONE_POLYGON:New( "SA10 LOCATIONS", GROUP:FindByName( "SA10 LOCATIONS" ))
  local SA10ZoneTable = { SA10Zone }

  -- Setup Arty Spawns (Thanks to GoreUncle for helping with the OnEventDead stuff :)
  ArtySpawns = SPAWN:New( "Arty Force" )
    :InitLimit( 60, 0 )
    :InitHeading(260,280)
    :InitRandomizeZones( ArtyZoneTable )
    :InitRandomizeTemplate( ArtyTemplate )
    :OnSpawnGroup(
    function(SpawnedGroup) 

       SpawnedGroup:HandleEvent( EVENTS.Dead )    
 
       function SpawnedGroup:OnEventDead( EventData )
          
          MESSAGE:New("NATO Forces have destroyed an Artillery Unit! Blue Team gets 1 point!\n\n", 10, "Alert!", true):ToAll()
          ScoreAddBlue(1)
          StatRedArtyUnitsDead = StatRedArtyUnitsDead + 1
          
       end
    end
    ):SpawnScheduled( .1, .2 )
  
    -- Mission Status msg - used in F10 menu and when certain units are killed. 
  function MissionStatus(MsgTime)
  
    MissionStatusMsg = MESSAGE:New(
       "\n\n\nBlue Score: " .. BlueCurrentScore .. 
       "\nRed Score : " .. RedCurrentScore .. "\n\n" .. 
       "Required to win: " .. ScoreRequiredToWin .. "\n\n", MsgTime, "Mission Status", false):ToAll()
       
  end
  
  function ScoreAddBlue(AddScore)
  
    BlueCurrentScore = BlueCurrentScore + AddScore
    MissionStatus(10)
    
  end 
  
  function ScoreAddRed(AddScore)
  
    RedCurrentScore = RedCurrentScore + AddScore
    MissionStatus(10)
    
  end  


  local SA10Template = { "SA10_" }    
  -- Setup SA10 Spawns
  SA10Spawns = SPAWN:New( "SA10_" )
    :InitLimit( 24, 48 )
    :InitHeading(260,280)
    :InitRandomizeZones( SA10ZoneTable )
    :InitRandomizeTemplate( SA10Template )
    :SpawnScheduled( 500, .2 )    

-- Different Schedulers are configured for different senarios. Ground Shelling, Low Air Shelling, and High Air Shelling.
-- This shelling works independantly of the actual arty units above.  

-- Example:
-- ShellingScheduler = SCHEDULER:New(SchedulerObject,SchedulerFunction,SchedulerArguments,Start,Repeat,RandomizeFactor,Stop)
  
  
  -- Setup Shelling Zones
  local BombZone1 = ZONE_POLYGON:New("BombZone1", GROUP:FindByName( "BombZone1"))
  local HighAirShellingZone = ZONE:New("HIGH AIR SHELLING ZONE")
  
  GroundShellingScheduler = SCHEDULER:New( nil,
     
    function()

      Exp_Strength = math.random(300, 1000)
      Exp_Zone = BombZone1
      Blast_Location = Exp_Zone:GetRandomVec2()
      Explode = COORDINATE:NewFromVec2( Blast_Location,0)
      Explode:Explosion( Exp_Strength )

    end, {}, 10, 15, .5
  )

  
  AirLowShellingScheduler = SCHEDULER:New( nil,
     
    function()

      Exp_Strength = math.random(300, 700)
      Exp_Alt = math.random(50, 500)
      Exp_Zone = BombZone1
      Blast_Location = Exp_Zone:GetRandomVec2()
      Explode = COORDINATE:NewFromVec2( Blast_Location, Exp_Alt)
      Explode:Explosion( Exp_Strength )
      

    end, {}, 10, 1, .2
  )
  
--  HighAirShellingScheduler = SCHEDULER:New( nil,
--     
--    function()
--
--      Exp_Strength = math.random(300, 700)
--      Exp_Alt = math.random(50, 15000)
--      Exp_Zone = HighAirShellingZone
--      Blast_Location = Exp_Zone:GetRandomVec2()
--      Explode = COORDINATE:NewFromVec2( Blast_Location, Exp_Alt)
--      Explode:Explosion( Exp_Strength )
--      
--
--    end, {}, 10, 1, .8
--  )
  
  MonitorWinCondition = SCHEDULER:New( nil,
     
    function()

        if BlueCurrentScore >= ScoreRequiredToWin then
          MsgTime = 218
          MESSAGE:New("NATO Forces have won the day!!\n\nMission will restart shortly.\n\n", MsgTime, "Winner!", true):ToAll()
          MissionStatus(MsgTime)
          MsgScorePercent(MsgTime)
          trigger.action.setUserFlag(66, true)
        end
              
        if RedCurrentScore >= ScoreRequiredToWin then         
          MsgTime = 218
          MESSAGE:New("Russian Forces have won the day!!\n\nMission will restart shortly.\n\n", MsgTime, "Winner!", true):ToAll()
          MissionStatus(MsgTime)
          MsgScorePercent(MsgTime)  
          trigger.action.setUserFlag(66, true)
                  
        end

    end, {}, 10, 1, 0
  )  
  
  function MsgScorePercent(MsgTime)  
            
    MESSAGE:New("\n\n\nRed:\n" ..
                "------Blue Shot Down:      " .. StatBlueCAPDead .. "%\n\n" .. 
                "Blue:\n" .. 
                "------Red Shot Down:       " .. StatRedCAPDead .. "%\n" ..
                "------Blue Crates Moved:  " .. StatBlueCratesMoved .. "%\n" ..
                "------Blue Rescues:           " .. StatBlueRescued .. "%\n\n", MsgTime, "Stat Breakdown Percentages", false):ToAll()
  end
  
  
  SEAD_RU_SAM_Defenses = SEAD:New( { 
    
    'SA10_#001',
    'SA10_#002',
    'SA10_#003',
    'SA10_#004',
    'RU_AAA #001', 
    'RU_AAA #002',   
    'RU_AAA #003',
    'RU_AAA #004',
    'RU_AAA #005',
    'RED EWR #003'
  } )
  
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



  --Setup the BLUEA2A dispatcher, and initialize it.
  BLUEBorderZone = ZONE_POLYGON:New( "BLUE BORDER", GROUP:FindByName( "BLUE BORDER" ) )
  BLUEA2ADispatcher = AI_A2A_GCICAP:New( { "BLUE EWR" }, { "FIGHTER SWEEP BLUE" }, { "BLUE BORDER" }, 1 )  
  BLUEA2ADispatcher:SetDefaultLandingAtRunway()
  BLUEA2ADispatcher:SetDefaultTakeoffInAir()
  BLUEA2ADispatcher:SetBorderZone( BLUEBorderZone )
  BLUEA2ADispatcher:SetTacticalDisplay(false)
  BLUEA2ADispatcher:SetDefaultFuelThreshold( 0.20 )
  BLUEA2ADispatcher:SetRefreshTimeInterval( 300 )
  
  
  --Setup the RedA2A dispatcher, and initialize it.
  CCCPBorderZone = ZONE_POLYGON:New( "RED BORDER", GROUP:FindByName( "RED BORDER" ) )
  RedA2ADispatcher = AI_A2A_GCICAP:New( { "RED EWR" }, { "FIGHTER SWEEP RED" }, { "RED BORDER" }, 2 )
  RedA2ADispatcher:SetDefaultLandingAtRunway()
  RedA2ADispatcher:SetDefaultTakeoffInAir()
  RedA2ADispatcher:SetBorderZone( CCCPBorderZone )
  RedA2ADispatcher:SetTacticalDisplay(false)
  RedA2ADispatcher:SetDefaultFuelThreshold( 0.20 )
  RedA2ADispatcher:SetRefreshTimeInterval( 300 )


  --Setup the VazianiDispatcher and initialize it.
  VazianiBorderZone = ZONE_POLYGON:New( "VAZIANI DEFENSE ZONE", GROUP:FindByName( "VAZIANI DEFENSE ZONE" ) )
  VazianiDispatcher = AI_A2A_GCICAP:New( { "RED EWR" }, { "FIGHTER SWEEP RED" }, { "VAZIANI DEFENSE ZONE" }, 0 )
  VazianiDispatcher:SetDefaultLandingAtRunway()
  VazianiDispatcher:SetDefaultTakeoffInAir()
  VazianiDispatcher:SetBorderZone( VazianiBorderZone )
  VazianiDispatcher:SetTacticalDisplay(false)
  VazianiDispatcher:SetDefaultFuelThreshold( 0.20 )
  VazianiDispatcher:SetRefreshTimeInterval( 60 )
  VazianiDispatcher:SetDefaultOverhead(2)
  
  
  --Setup the Kutasi Dispatcher and initialize it.
  KutasiBorderZone = ZONE_POLYGON:New( "KUTASI DEFENSE ZONE", GROUP:FindByName( "KUTASI DEFENSE ZONE" ) )
  KutasiDispatcher = AI_A2A_GCICAP:New( { "BLUE EWR" }, { "FIGHTER SWEEP BLUE" }, { "KUTASI DEFENSE ZONE" }, 0 )
  KutasiDispatcher:SetDefaultLandingAtRunway()
  KutasiDispatcher:SetDefaultTakeoffInAir()
  KutasiDispatcher:SetBorderZone( KutasiBorderZone )
  KutasiDispatcher:SetTacticalDisplay(false)
  KutasiDispatcher:SetDefaultFuelThreshold( 0.20 )
  KutasiDispatcher:SetRefreshTimeInterval( 60 )
  KutasiDispatcher:SetDefaultOverhead(2)

  -- Random RU Troop Zones
  local T1Z = ZONE_POLYGON:New("RU_TROOPS_ZONE_1", GROUP:FindByName("RU_TROOPS_ZONE_1"))
  
  local TroopZoneTable = { T1Z, T1Z, T1Z, T1Z, T1Z, BombZone1 }
  
  local TroopTemplate = { "RU_TROOPS #001", "RU_TROOPS #002", "RU_TROOPS #003", "RU_TROOPS #004" }
  
  RU_TroopSpawns_Initial = SPAWN:New("Troops")
    :InitLimit(150, 1000)
    :InitHeading(290, 250)
    :InitRandomizeTemplate( TroopTemplate )
    :InitRandomizeZones( TroopZoneTable )
    :SpawnScheduled( 600, .2 )
    
        
  -----------US Troops------------------------------
  SpawnUSTroops1 = SPAWN:New("US_INFANTRY #001")
  :InitLimit( 10, 500 )
  :SpawnScheduled(120, .1)
  :InitRandomizeRoute( 1, 1, 800)
  :InitCleanUp(120)
  
  SpawnUSTroops2 = SPAWN:New("US_INFANTRY #002")
  :InitLimit( 10, 500 )
  :SpawnScheduled(120, .3)
  :InitRandomizeRoute( 1, 1, 800)
  :InitCleanUp(120)
 
  SpawnUSTroops3 = SPAWN:New("US_INFANTRY #003")
  :InitLimit( 10, 500 )
  :SpawnScheduled(120, .2)
  :InitRandomizeRoute( 1, 1, 800)
  :InitCleanUp(120) 
  
    
 
    
    
  
