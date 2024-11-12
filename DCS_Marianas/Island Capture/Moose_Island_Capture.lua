_SETTINGS:SetPlayerMenuOff()
  
  
  
  -- Settings - How many points for each activity?
  PointsRequiredToWin = 100
  PointsPlayerDeaths = 1
  PointsDeliverCargo = 2
  PointsSideMission = 3
  PointsCSAR = 5
  
  
  --Not Used Yet
  -- PointsDeliverPilot
  -- PointsEscort
  
  SoundRadioMsg = USERSOUND:New("l10n/DEFAULT/beeps-and-clicks.wav")
  SoundMash = USERSOUND:New("l10n/DEFAULT/beacon.ogg")
  
  
 -- Settings - Difficulty - Set each category as you see fit. A setting of 0 for the 'units' var will disable that type from showing up in the mission. 
 -- For example if you wanted to disable sams in this mission you would set:
 --   NumberOfNonMovingSAMUnits = 0
 --   NumberofMovingSAMUnits = 0
-----------------------------------------------------------------------------
  NumberOfNonMovingArmorUnits = 50 --Initial Number of non moving armor units to put on the map.
  NumberOfNonMovingArmorUnitsMax = 0 --Max Reinforcments
 
  NumberofMovingArmorUnits = 6 -- There are 5 paths in this mission for the ground units to follow. A setting of 1 will put 5 vehicals on the roads and setting of 2 will put 10 on the roads. 
  NumberofMovingArmorUnitsMax = 25 --Max Reinforcments
  MovingArmorRespawnTime = 1200 
  
  NumberOfNonMovingSAMUnits = 1  -- There are 2 paths in this misson for SAM units to follow. Increments of 2 only.  
  NumberOfNonMovingSAMUnitsMax = 16 --Max Reinforcments 
  NonMovingSAMRespawnTime = 1200
  
  NumberofMovingSAMUnits = 1 -- Increments of 2 only
  NumberofMovingSAMUnitsMax = 10 -- Max Reinforcments
  MovingSAMRespawnTime = 1200
  
  NumberofNonMovingAAAUnits = 1 -- Increments of 2 only
  NumberofNonMovingAAAUnitsMax = 10  --Max Reinforcements
  NonMovingAAAUnitsRespawnTime = 1200
  
  NumberofMovingAAAUnits = 2 -- Increments of 2 only
  NumberofMovingAAAUnitsMax = 10  -- Max Reinforcements
  MovingAAAUnitsRespawnTime = 1200
  
    
--- Change anything below at your own risk :) --------------------------------

 

  
  BlueCurrentScore = 0
  RedCurrentScore = 0
  StatBlueCratesMoved = 0
  StatRedCratesMoved = 0
  StatBlueRescued = 0
  StatRedRescued = 0
  StatRedCAPDead = 0
  StatBlueCAPDead = 0
  
  -- Add these some day:
  -- StatBlueDeliverPilot
  -- StatRedDeliverPilot
  -- StatBlueEscort
  -- StatRedEscort
  
  
  
 
  BlueSideMissionsComplete = 0
  BlueCSARComplete = 0
  RedConvoysDestroyed = 0
  
  
  
  -- Populate the Island With Ground Vechs (no AA)
  -- Create Table of Zones
  ZoneTable = { ZONE:New( "Zone1" ), ZONE:New( "Zone2" ), ZONE:New( "Zone3" ), ZONE:New( "Zone4" ), ZONE:New( "Zone5" ), ZONE:New( "Zone6" ), ZONE:New( "Zone7" ), ZONE:New( "Zone8" ), ZONE:New( "Zone9" ), ZONE:New( "Zone10" ), ZONE:New( "Zone11" ), ZONE:New( "Zone12" ), ZONE:New( "Zone13" ), ZONE:New( "Zone14" ), ZONE:New( "Zone15" ), ZONE:New( "Zone16" ), ZONE:New( "Zone17" ), ZONE:New( "Zone18" ), ZONE:New( "Zone19" ), ZONE:New( "Zone20" ), ZONE:New( "Zone21" ), ZONE:New( "Zone22" ), ZONE:New( "Zone23" ), ZONE:New( "Zone24" ) }
  
  TemplateTable = { "Ground-Template-A", "Ground-Template-B", "Ground-Template-C", "Ground-Template-D", "Ground-Template-E", "Ground-Template-F", "Ground-Template-G" }
  SamTemplateTable = { "Sam-Template-A", "Sam-Template-B", "Sam-Template-C", "Sam-Template-D" }
  AAATemplateTable = { "AAA-Template-A", "AAA-Template-B", "AAA-Template-C", "AAA-Template-D", "AAA-Template-E" }
   
  
  --Spawn AAA
  
   Spawn_AAA_NotMoving = SPAWN:New( "ArmorNo Path" )
  :InitLimit( NumberofNonMovingAAAUnits, NumberofNonMovingAAAUnitsMax )
  :InitRandomizeTemplate( AAATemplateTable )
  :InitRandomizeZones( ZoneTable )
  :SpawnScheduled( NonMovingAAAUnitsRespawnTime, .5 )
  
   Spawn_AAA_Moving1 = SPAWN:New( "AAAMoving1" )
  :InitLimit( NumberofMovingAAAUnits, NumberofMovingAAAUnitsMax )
  :InitRandomizeTemplate( AAATemplateTable )
  :InitRandomizeZones( ZoneTable )
  :SpawnScheduled( MovingAAAUnitsRespawnTime, .5 )
  
  --- Spawn SAMS 
   Spawn_Sam_NotMoving = SPAWN:New( "SamNo Path" )
  :InitLimit( NumberOfNonMovingSAMUnits, NumberOfNonMovingSAMUnitsMax )
  :InitRandomizeTemplate( SamTemplateTable )
  :InitRandomizeZones( ZoneTable )
  :SpawnScheduled( NonMovingSAMRespawnTime, .5 )
  
  Spawn_Sam_Moving1 = SPAWN:New( "SAMMoving1" )
  :InitLimit( NumberofMovingSAMUnits, NumberofMovingSAMUnitsMax )
  :InitRandomizeTemplate( SamTemplateTable )
  :InitRandomizeZones( ZoneTable )
  :SpawnScheduled( MovingSAMRespawnTime, .5 )

  
  -- Spawn Armor 

  -- Spawn Static Vehicals 
  Spawn_Vehicle_NotMoving = SPAWN:New( "AAANo Path" )
  :InitLimit( NumberOfNonMovingArmorUnits, NumberOfNonMovingArmorUnitsMax )
  :InitRandomizeTemplate( TemplateTable )
  :InitRandomizeZones( ZoneTable )
  :SpawnScheduled( .1, .2 )
  
  -- Spawn Moving Vehicals 
  Spawn_Vehicle_Moving1 = SPAWN:New( "Moving1" )
  :InitLimit( NumberofMovingArmorUnits, NumberofMovingArmorUnitsMax )
  :InitRandomizeTemplate( TemplateTable )
  :InitRandomizeZones( ZoneTable )
  :SpawnScheduled( MovingArmorRespawnTime, .2 )  
  
  -- Spawn Moving Vehicals 
  Spawn_Vehicle_Moving2 = SPAWN:New( "Moving2" )
  :InitLimit( NumberofMovingArmorUnits, NumberofMovingArmorUnitsMax )
  :InitRandomizeTemplate( TemplateTable )
  :InitRandomizeZones( ZoneTable )
  :SpawnScheduled( MovingArmorRespawnTime, .4 )
  
  -- Spawn Moving Vehicals 
  Spawn_Vehicle_Moving3 = SPAWN:New( "Moving3" )
  :InitLimit( NumberofMovingArmorUnits, NumberofMovingArmorUnitsMax )
  :InitRandomizeTemplate( TemplateTable )
  :InitRandomizeZones( ZoneTable )
  :SpawnScheduled( MovingArmorRespawnTime, .5 )
  
  -- Spawn Moving Vehicals 
  Spawn_Vehicle_Moving4 = SPAWN:New( "Moving4" )
  :InitLimit( NumberofMovingArmorUnits, NumberofMovingArmorUnitsMax )
  :InitRandomizeTemplate( TemplateTable )
  :InitRandomizeZones( ZoneTable )
  :SpawnScheduled( MovingArmorRespawnTime, .3 )
  
  -- Spawn Moving Vehicals 
  Spawn_Vehicle_Moving5 = SPAWN:New( "Moving5" )
  :InitLimit( NumberofMovingArmorUnits, NumberofMovingArmorUnitsMax )
  :InitRandomizeTemplate( TemplateTable )
  :InitRandomizeZones( ZoneTable )
  :SpawnScheduled( MovingArmorRespawnTime, .1 )





    -- Mission Status msg - used in F10 menu and when certain units are killed. 
  function MissionStatus(MsgTime)
  
    MissionStatusMsg = MESSAGE:New(
       "\n\n\nBlue Score: " .. BlueCurrentScore .. 
       "\nRed Score : " .. RedCurrentScore .. "\n\n" .. 
       "Required to win: " .. PointsRequiredToWin .. "\n\n", MsgTime, "Mission Status", false):ToAll()
       
  end
  
  function ScoreBreakDown(MsgTime)
    
  ScoreBreakDownMsg = MESSAGE:New(
  "\n\nRed Players Killed: " .. StatRedCAPDead .. 
  "\nBlue Players Killed: " .. StatBlueCAPDead .. 
  "\nBlue Cargo Delivered: " .. StatBlueCratesMoved .. 
  "\nBlue Side Missions Complete: " .. BlueSideMissionsComplete .. 
  "\nBlue CSARs Rescued: " .. BlueCSARComplete .. "\n\n", MsgTime, "[ Score Stats ]\n", true ):ToAll()
   
  
  
  end
  

-- Scoring Functions --------------------------------------------
  function ScoreAddBlue(AddScore)
  
    BlueCurrentScore = BlueCurrentScore + AddScore
    MissionStatus(10)
    
  end 
  
  function ScoreAddRed(AddScore)
  
    RedCurrentScore = RedCurrentScore + AddScore
    MissionStatus(10)
    
  end  


function AddScoreStatBlueCratesMoved()

  StatBlueCratesMoved = StatBlueCratesMoved + 1 
  ScoreAddBlue(PointsDeliverCargo)
  MsgCargoDelivered = MESSAGE:New("NATO Forces have moved cargo! " .. PointsDeliverCargo .. " points to blue!", 10, "Mission Status", false):ToAll()
  SoundRadioMsg:ToAll()
  
end

function AddScoreBlueSideMissionComplete()

  BlueSideMissionsComplete = BlueSideMissionsComplete + 1 
  ScoreAddBlue(PointsSideMission)
  MsgCargoDelivered = MESSAGE:New("NATO Forces have completed a side mission! " .. PointsSideMission .. " points to blue!", 10, "Mission Status", false):ToAll()
  SoundRadioMsg:ToAll()
  
end

function AddScoreBlueCSARComplete()

  BlueCSARComplete = BlueCSARComplete + 1 
  ScoreAddBlue(PointsCSAR)
  MsgCargoDelivered = MESSAGE:New("NATO Forces have completed a CSAR Mission! " .. PointsCSAR .. " points to blue!", 10, "Mission Status", false):ToAll()
  SoundMash:ToAll()
    
end





-- Player Death Event Functions -----------------------------------------------------------
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
          StatRedCAPDead = StatRedCAPDead + PointsPlayerDeaths
        
        end
 
    elseif coal == 2 then 
     
      side = 'BLUE'
      oside = 'RED'
      GoriPlayerName = EventData.initiator:getPlayerName() 
      if  GoriPlayerName ~= nil then
          MESSAGE:New("\n\nA " .. side .. " player ( " .. GoriPlayerName .. " ) has crashed! " .. oside .. " Team gains 1 point!", 10, "Alert!"):ToAll()
          ScoreAddRed(1)
          StatBlueCAPDead = StatBlueCAPDead + PointsPlayerDeaths
      end
    else
      env.info("**** We should not have gotten here! Moose_IslandBattle.lua ****")
    end    
        
  end
  
---- Monitor Win condition---------- 
    MonitorWinCondition = SCHEDULER:New( nil,
     
    function()

        if BlueCurrentScore >= PointsRequiredToWin then
          MsgTime = 218
          MESSAGE:New("NATO Forces have won the day!!\n\nMission will restart shortly.\n\n", MsgTime, "Winner!", true):ToAll()
          MissionStatus(MsgTime)
          MsgScorePercent(MsgTime)
          trigger.action.setUserFlag(66, true)
        end
              
        if RedCurrentScore >= PointsRequiredToWin then         
          MsgTime = 218
          MESSAGE:New("Russian Forces have won the day!!\n\nMission will restart shortly.\n\n", MsgTime, "Winner!", true):ToAll()
          MissionStatus(MsgTime)
          MsgScorePercent(MsgTime)  
          trigger.action.setUserFlag(66, true)
                  
        end

    end, {}, 10, 1, 0
  )  