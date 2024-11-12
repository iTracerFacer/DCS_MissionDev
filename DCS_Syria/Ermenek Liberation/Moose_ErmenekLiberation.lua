-- _SETTINGS:SetPlayerMenuOff()



----------------------------------------------------------------------------------------
-- Adjust Scoring   
  
--Points granted
  ScoreRequiredToWin = 100  -- duh
  CapturePoints = 5 -- Set the number of points granted for a control point capture.
  RescuePoints = 5 -- Set the number of points granted for a medevac rescue. 

--Stats
  BlueCurrentScore = 0
  RedCurrentScore = 0
  StatBlueCratesMoved = 0
  StatRedCratesMoved = 0
  StatBlueRescued = 0
  StatRedRescued = 0
  StatRedCAPDead = 0
  StatBlueCAPDead = 0
  StatBlueCapturePoints = 0
  StatRedCapturePoints = 0

----------------------------------------------------------------------------------------
-- Setup Command Centers. See Moose_ErmenekLiberation_ZoneCapture.lua for remaining code.
-- 


  
  RU_CC = COMMANDCENTER:New( GROUP:FindByName( "REDHQ" ), "Russia HQ" )
  US_CC = COMMANDCENTER:New( GROUP:FindByName( "BLUEHQ" ), "USA HQ" )




  
  US_Mission = MISSION:New( US_CC, "Ermenek Liberation", "Primary",
    "Capture the Zones marked on your map..\n", coalition.side.BLUE)
    
  US_Score = SCORING:New( "Ermenek Liberation" )
    
  US_Mission:AddScoring( US_Score )
  
  US_Mission:Start()




----------------------------------------------------------------------------------------
-- Setup AI A2A Dispatchers
  
  --Blue
  BLUEBorderZone = ZONE_POLYGON:New( "BLUE BORDER", GROUP:FindByName( "BLUE BORDER" ) )
  BLUEA2ADispatcher = AI_A2A_GCICAP:New( { "BLUE EWR" }, { "FIGHTER SWEEP BLUE" }, { "BLUE BORDER" }, 2 )  
  --BLUEA2ADispatcher:SetDefaultLandingAtRunway()
  BLUEA2ADispatcher:SetDefaultLandingAtEngineShutdown()
  BLUEA2ADispatcher:SetDefaultTakeoffInAir()
  BLUEA2ADispatcher:SetBorderZone( BLUEBorderZone )
  BLUEA2ADispatcher:SetTacticalDisplay(false)
  BLUEA2ADispatcher:SetDefaultFuelThreshold( 0.20 )
  BLUEA2ADispatcher:SetRefreshTimeInterval( 300 )

  
  
  --Red
  CCCPBorderZone = ZONE_POLYGON:New( "RED BORDER", GROUP:FindByName( "RED BORDER" ) )
  RedA2ADispatcher = AI_A2A_GCICAP:New( { "RedSam" }, { "FIGHTER SWEEP RED" }, { "RED BORDER" }, 3 )
  --RedA2ADispatcher:SetDefaultLandingAtRunway()
  RedA2ADispatcher:SetDefaultLandingAtEngineShutdown()
  RedA2ADispatcher:SetDefaultTakeoffFromParkingHot()
  RedA2ADispatcher:SetBorderZone( CCCPBorderZone )
  RedA2ADispatcher:SetTacticalDisplay(false)
  RedA2ADispatcher:SetDefaultFuelThreshold( 0.20 )
  RedA2ADispatcher:SetRefreshTimeInterval( 600 )
  RedA2ADispatcher:SetDefaultOverhead(.50)
  
-- Keep the air bases clean since using take off from ground.  
CleanIncirlik = CLEANUP_AIRBASE:New( AIRBASE.Syria.Incirlik )
CleanIncirlik:SetCleanMissiles( false )
  
CleanAdana = CLEANUP_AIRBASE:New( AIRBASE.Syria.Adana_Sakirpasa )
CleanAdana:SetCleanMissiles( false )

CleanGazipasa = CLEANUP_AIRBASE:New( AIRBASE.Syria.Gazipasa )
CleanGazipasa:SetCleanMissiles( false )
  
 
  ---------Spawn AWACS------------------------------
  Spawn_BlueEWR = SPAWN:New("BLUE EWR"):InitLimit( 1, 50 )
  :InitRepeatOnEngineShutDown()
  :InitCleanUp(120)  
  :SpawnScheduled(300,.3)

  Spawn_RedEWR = SPAWN:New("RedSam_EWR")
  :InitLimit( 1, 50 )
  :InitRepeatOnEngineShutDown()
  :InitCleanUp(120)
  :SpawnScheduled(300,.4)
  
  
  Spawn_Blue135 = SPAWN:New("Shell SHL 42 X 253")
  :InitLimit( 1, 50 )
  :InitRepeatOnEngineShutDown()
  :InitCleanUp(120)
  :SpawnScheduled(300,.3)
  
  Spawn_Blue135MPRS = SPAWN:New("Texaco TEX 41 X 252")
  :InitLimit( 1, 50 )
  :InitRepeatOnEngineShutDown()
  :InitCleanUp(120)
  :SpawnScheduled(300,.3)

  Spawn_RU_Recce = SPAWN:New("CCCP Recce-4")
  :InitLimit( 1, 50 )
  :InitRepeatOnEngineShutDown()
  :InitCleanUp(120)
  :SpawnScheduled(600,.3)
  
  


----------------------------------------------------------------------------------------
-- Spawn Templates, Zones, Groups
-- 
ZoneTable = { ZONE:New( "s1" ), ZONE:New( "s2" ), ZONE:New( "s3" ), ZONE:New( "s4" ), ZONE:New( "s5" ), ZONE:New( "s6" ), ZONE:New( "s7" ), ZONE:New( "s8" ), ZONE:New( "s9" ), ZONE:New( "s10" ), ZONE:New( "s11" ), ZONE:New( "s12" ), ZONE:New( "s13" ), ZONE:New( "s14" ) }
StationarySamZoneTable = { ZONE:New( "ss1"), ZONE:New( "ss2" ) }

-- This section controls the randomized moving red ground vehicals. 
TemplateTable = { "Ground-Template-A", "Ground-Template-B", "Ground-Template-C", "Ground-Template-D", "Ground-Template-E" }
Spawn_Vehicle_1 = SPAWN:New( "GROUND PATH" )
  :InitLimit( 30, 60 )
  :InitRandomizeTemplate( TemplateTable ) 
  :InitRandomizeZones( StationarySamZoneTable ) -- test
  :InitRandomizeRoute( 2, 1, 2000 )
  :SpawnScheduled( 300, .5 )
  
-- This section controls the randomized moving red sam vehicals. 
TemplateTable = { "RedSam-Template-1", "RedSam-Template-2", "RedSam-Template-3", "RedSam-Template-4" }
Spawn_Vehicle_1 = SPAWN:New( "GROUND PATH" )
  :InitLimit( 3, 10 )
  :InitRandomizeTemplate( TemplateTable ) 
  :InitRandomizeZones( StationarySamZoneTable ) -- test
  :InitRandomizeRoute( 2, 1, 2000 )
  :SpawnScheduled( 300, .5 )  




  

-- This section controls the randomized non moving red sam vehicals. 
--
StationarySamTemplateTable = { "RedSam-Stationary-Template-1", "RedSam-Stationary-Template-2", "RedSam-Stationary-Template-3", "RedSam-Stationary-Template-4", "RedSam-Stationary-Template-5", "RedSam-Stationary-Template-6", "RedSam-Stationary-Template-7", "RedSam-Stationary-Template-8" }
Spawn_Vehicle_2 = SPAWN:New( "NO PATH" )
  :InitLimit( 15, 15 )
  :InitRandomizeTemplate( StationarySamTemplateTable ) 
  :InitRandomizeZones( StationarySamZoneTable )
  :InitRandomizeRoute( 2, 1, 2000 )
  :SpawnScheduled( 120, .5 )  

-- Populate the capture zones with enmey ground and aa
--
CaptureZoneSamTemplateTable = { "RU_MANPADS", "RedSam-Template-1", "RedSam-Template-2", "RedSam-Template-3", "RedSam-Template-4", "Ground-Template-A", "Ground-Template-B", "Ground-Template-C", "Ground-Template-D", "Ground-Template-E" }
CaptureZonesTable = { ZONE:New("CZ1"), ZONE:New("CZ2"), ZONE:New("CZ3"), ZONE:New("CZ4"), ZONE:New("CZ5"), ZONE:New("CZ6"), ZONE:New("CZ7"), ZONE:New("CZ8"), ZONE:New("CZ9"), ZONE:New("CZ10"), ZONE:New("CZ11"), ZONE:New("CZ12"), ZONE:New("CZ13"), ZONE:New("CZ14"), ZONE:New("CZ15"), ZONE:New("CZ16") }
Spawn_Vehicle_3 = SPAWN:New( "NO PATH" )
  :InitLimit( 100, 100 )
  :InitRandomizeTemplate( CaptureZoneSamTemplateTable ) 
  :InitRandomizeZones( CaptureZonesTable )
  :SpawnScheduled( 1, .5 )  




----------------------------------------------------------------------------------------
-- Player Scoring:
-- When a player dies the other side gains 1 point. 
-- This happens regardless how the player is killed (shot down vs crashed makes no diff). 
----------------------------------------------------------------------------------------

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
      env.info("**** We should not have gotten here! Moose_ErmenekLiberation.lua ****")
    end    
        
  end
  
  
  function ScoreAddBlue(AddScore)
  
    BlueCurrentScore = BlueCurrentScore + AddScore
    MissionStatus(10)
    
  end 
 
  function ScoreAddRed(AddScore)
  
    RedCurrentScore = RedCurrentScore + AddScore
    MissionStatus(10)
    
  end  
  
  function MissionStatus(MsgTime)
  
    MissionStatusMsg = MESSAGE:New(
       "\n\n\nBlue Score: " .. BlueCurrentScore .. 
       "\nRed Score : " .. RedCurrentScore .. "\n\n" .. 
       "Required to win: " .. ScoreRequiredToWin .. "\n\n", MsgTime, "Mission Status", false):ToAll()
       
  end

------------------------------------------------------------------------------------------
---- MANTIS - Modular, Automatic and Network capable Targeting and Interception System.
------------------------------------------------------------------------------------------

mantisRed = MANTIS:New("mymantisRed","RedSam","RedSam",nil,"red",false)
mantisRed:Start()

mantisBlue = MANTIS:New("mymantisBlue","BlueSam","BlueSam",nil,"blue",false)
mantisBlue:Start()


------------------------------------------------------------------------------------------
-- Monitor for win condition.
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

------------------------------------------------------------------------------------------
----
---- Air Boss: Amb
----
------------------------------------------------------------------------------------------
--
-- S-3B Recovery Tanker spawning in air.
local tanker=RECOVERYTANKER:New("Abraham Lincoln", "Arco - CVN Recovery Tanker")
tanker:SetTakeoffAir()
tanker:SetRadio(250)
tanker:SetModex(511)
tanker:SetTACAN(1, "ARC")
tanker:SetRespawnOn()
tanker:__Start(1)

-- E-2D AWACS spawning on Abraham Lincoln.
local awacs=RECOVERYTANKER:New("Abraham Lincoln", "BLUE EWR E-2D Wizard Group")
awacs:SetAWACS()
awacs:SetRadio(253)
awacs:SetAltitude(20000)
awacs:SetCallsign(CALLSIGN.AWACS.Wizard)
awacs:SetRacetrackDistances(30, 15)
awacs:SetModex(611)
awacs:SetTACAN(2, "WIZ")
awacs:SetRespawnOn()
awacs:__Start(1)




---- Rescue Helo with home base Lake Erie. Has to be a global object!
--rescuehelo=RESCUEHELO:New("Abraham Lincoln", "Rescue Helo")
--rescuehelo:SetHomeBase(AIRBASE:FindByName("USS Dicksburg"))
--rescuehelo:SetModex(42)
--rescuehelo:__Start(1)
  
---- Create AIRBOSS object.
--local AirbossStennis=AIRBOSS:New("Abraham Lincoln")
--
---- Add recovery windows:
---- Case I from 9 to 10 am.
--local window1=AirbossStennis:AddRecoveryWindow( "9:00", "10:00", 1, nil, true, 25)
---- Case II with +15 degrees holding offset from 15:00 for 60 min.
--local window2=AirbossStennis:AddRecoveryWindow("15:00", "16:00", 2,  15, true, 23)
---- Case III with +30 degrees holding offset from 2100 to 2200.
--local window3=AirbossStennis:AddRecoveryWindow("21:00", "22:00", 3,  30, true, 21)
--
---- Set folder of airboss sound files within miz file.
--AirbossStennis:SetSoundfilesFolder("Airboss Soundfiles/")
--
---- Single carrier menu optimization.
----AirbossStennis:SetMenuSingleCarrier()
--
---- Skipper menu.
--AirbossStennis:SetMenuRecovery(30, 20, false)
--
---- Remove landed AI planes from flight deck.
--AirbossStennis:SetDespawnOnEngineShutdown()
--
---- Load all saved player grades from your "Saved Games\DCS" folder (if lfs was desanitized).
--AirbossStennis:Load()
--
---- Automatically save player results to your "Saved Games\DCS" folder each time a player get a final grade from the LSO.
--AirbossStennis:SetAutoSave()
--
---- Enable trap sheet.
--AirbossStennis:SetTrapSheet()
--
---- Start airboss class.
--AirbossStennis:Start()
--
--
----- Function called when recovery tanker is started.
--function tanker:OnAfterStart(From,Event,To)
--
--  -- Set recovery tanker.
--  AirbossStennis:SetRecoveryTanker(tanker)  
--
--  -- Use tanker as radio relay unit for LSO transmissions.
--  AirbossStennis:SetRadioRelayLSO(self:GetUnitName())
--  
--end
--
----- Function called when AWACS is started.
--function awacs:OnAfterStart(From,Event,To)
--  -- Set AWACS.
--  AirbossStennis:SetAWACS(awacs)
--end
--
--
----- Function called when rescue helo is started.
--function rescuehelo:OnAfterStart(From,Event,To)
--  -- Use rescue helo as radio relay for Marshal.
--  AirbossStennis:SetRadioRelayMarshal(self:GetUnitName())
--end
--
----- Function called when a player gets graded by the LSO.
--function AirbossStennis:OnAfterLSOGrade(From, Event, To, playerData, grade)
--  local PlayerData=playerData --Ops.Airboss#AIRBOSS.PlayerData
--  local Grade=grade --Ops.Airboss#AIRBOSS.LSOgrade
--
--  ----------------------------------------
--  --- Interface your Discord bot here! ---
--  ----------------------------------------
--  
--  local score=tonumber(Grade.points)
--  local name=tostring(PlayerData.name)
--  
--  -- Report LSO grade to dcs.log file.
--  env.info(string.format("Player %s scored %.1f", name, score))
--end
--
-- 
------------------------------------------------------------------------------------------
----
---- Air Boss: Tarawa
----
------------------------------------------------------------------------------------------
--
---- No MOOSE settings menu. Comment out this line if required.
--_SETTINGS:SetPlayerMenuOff()
--
---- Rescue Helo with home base USS Viksburg. Has to be a global object!
--rescuehelo=RESCUEHELO:New("USS Tarawa", "Rescue Helo")
--rescuehelo:SetHomeBase(AIRBASE:FindByName("USS Hugh Mungus"))
--rescuehelo:SetModex(42)
--  
---- Create AIRBOSS object.
--local AirbossTarawa=AIRBOSS:New("USS Tarawa")
--
---- Add recovery windows:
---- Case I from 9:00 to 10:00 am.
--local window1=AirbossTarawa:AddRecoveryWindow( "9:00", "10:00", 1, nil, true, 25)
---- Case II with +15 degrees holding offset from 15:00 for 60 min.
--local window2=AirbossTarawa:AddRecoveryWindow("15:00", "16:00", 2, 15, true, 20)
---- Case III with +30 degrees holding offset from 2100 to 2200.
--local window3=AirbossTarawa:AddRecoveryWindow("21:00", "22:00", 3, 30, true, 20)
--
---- Set TACAN.
--AirbossTarawa:SetTACAN(73, "X", "LHA")
--
---- Not sure if Tarawa has ICLS?
----AirbossTarawa:SetICLSoff()
--
---- Load all saved player grades from your "Saved Games\DCS" folder (if lfs was desanitized).
--AirbossTarawa:Load()
--
---- Automatically save player results to your "Saved Games\DCS" folder each time a player get a final grade from the LSO.
--AirbossTarawa:SetAutoSave()
--
---- Set radio relay units in order to properly send transmissions with subtitles only visible if correct frequency is tuned in.
--AirbossTarawa:SetRadioRelayLSO("CH-53E Radio Relay")
--AirbossTarawa:SetRadioRelayMarshal("SH-60B Radio Relay")
--
---- Radios.
--AirbossTarawa:SetMarshalRadio(243)
--AirbossTarawa:SetLSORadio(265)
--
----Set folder of airboss sound files within miz file.
--AirbossTarawa:SetSoundfilesFolder("Airboss Soundfiles/")
--
---- Remove landed AI planes from flight deck.
--AirbossTarawa:SetDespawnOnEngineShutdown()
--
---- Single carrier menu optimization.
----AirbossTarawa:SetMenuSingleCarrier()
--
---- Add Skipper menu to start recovery via F10 radio menu.
--AirbossTarawa:SetMenuRecovery(30, 20, true)
--
---- Start Airboss.
--AirbossTarawa:Start()
--
--
----- Function called when a recovery starts.
--function AirbossTarawa:OnAfterRecoveryStart(From, Event, To, Case, Offset)
--  -- Start helo.
--  rescuehelo:Start()
--end
--
----- Function called when a recovery ends.
--function AirbossTarawa:OnAfterRecoveryStop(From,Event,To)
--  -- Send helo RTB.
--  rescuehelo:RTB()
--end
--
----- Function called when the rescue helo has returned to base.
--function rescuehelo:OnAfterReturned(From, Event, To, airbase)
--  -- Stop helo.
--  self:__Stop(3)
--end
--
----- Function called when a player gets graded by the LSO.
--function AirbossTarawa:OnAfterLSOGrade(From, Event, To, playerData, grade)
--  local PlayerData=playerData --Ops.Airboss#AIRBOSS.PlayerData
--  local Grade=grade --Ops.Airboss#AIRBOSS.LSOgrade
--
--  ----------------------------------------
--  --- Interface your Discord bot here! ---
--  ----------------------------------------
--  
--  local score=tonumber(Grade.points)
--  local name=tostring(PlayerData.name)
--  
--  -- Report LSO grade to dcs.log file.
--  env.info(self.lid..string.format("Player %s scored %.1f", name, score))
--end
--
--
--  
--  
--  
--  
--  
--  
--
