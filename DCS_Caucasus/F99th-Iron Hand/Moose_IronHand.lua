--[[
  Iron Hand by F99Th-TracerFacer
  
  This is a DSMC Compatible Mission. Persitance will be enabled on servers with the 
  DSMC mod installed. No saving is done while players are on the server. All players must log off! 
  and the server shutdown before a new mission file is made. 
  
  Due to the way triggers don't work quiet right we have to come up with another way of
  loading the ground units ONLY ONCE - and never again on subsequent mission loads. I've tried
  various automated ways of doing this but in the end it has to be controlled manually by 1 of 2 ways.
  
  1. I run the mission, save the scenery once, open newly created mission file in ME and remove setup script.
      upload this to the server and this is what gets played on a daily basis. This causes several problems 
      but mostly with ground units who will lose their routes in the new mission. I don't like this.
      
  OR (THE WAY WE WILL DO IT FOR NOW UNTIL I GET SMARTER)
  
  2. We use some F10 menus to present 1 player (F99th-MISSION COMMANDER) with a special menu. Only F99th- players will be allowed into this slot.
  
      This menu will have 2 options:
      
      1. Warn the Players they should all log off. (shut down the server after this and a new 
        mission file will be created with time/date/weather reset) Do this on a populated server that
        you want to shut down.
        
      2. Populate the mission with initial objects. You must do this at least once on first mission run.
        This should only be done once. Once you use this option the menu item is removed, however on 
        subsequent mission loads .002, .003, .004, etc - this menu item will still show up. 
        
        DO NOT USE IT IF IT'S NOT THE FIRST RUN OF THE MISSION. IT WILL POPULATE THE MAP AGAIN.
        
        MENU WILL AUTOMATICALLY DISAPPEAR AFTER 5 MINS TO PREVENT IDIOCY.
        
        ** If you do this on accident, just load the previous mission file and don't be stupid twice. =] **
--]]


  _SETTINGS:SetPlayerMenuOff()
  HQ = GROUP:FindByName( "HQ", "Bravo HQ" )
  CommandCenter = COMMANDCENTER:New( HQ, "Bravo" )
  
  RedHQ = GROUP:FindByName( "RedHQ", "RedHQ" )
  RedCC = COMMANDCENTER:New( HQ, "RedHQ" )
  
  Scoring = SCORING:New( "Iron Hand" )
  SoundRadioMsg = USERSOUND:New("l10n/DEFAULT/beeps-and-clicks.wav")



--Setup the RedA2A dispatcher, and initialize it.
  CCCPBorderZone = ZONE_POLYGON:New( "RED BORDER", GROUP:FindByName( "RED BORDER" ) )
  RedA2ADispatcher = AI_A2A_GCICAP:New( { "RED EWR" }, { "FIGHTER SWEEP RED" }, { "RED BORDER" }, 6 )
  RedA2ADispatcher:SetDefaultLandingAtRunway()
  RedA2ADispatcher:SetDefaultTakeoffFromParkingCold()
  RedA2ADispatcher:SetBorderZone( CCCPBorderZone )
  RedA2ADispatcher:SetTacticalDisplay(false)
  RedA2ADispatcher:SetDefaultFuelThreshold( 0.35 )
  RedA2ADispatcher:SetRefreshTimeInterval( 420 )
  RedA2ADispatcher:SetDefaultOverhead(.75)
  RedA2ADispatcher:SetDefaultCapLimit(6)
  
    
  -- Spawn Some Trains
  Spawn_TanksFromTrainGudauta = SPAWN:New("TANKSFROMTRAINTOGUDAUTA")
  :InitLimit(6,6)
  
  Spawn_Train_TOGUDAUTA = SPAWN:New("TRAINTOGUDAUTA")
  :InitLimit(1,5)
  :SpawnScheduled( 8000, .3 ) 

  -- Spawned via mission trigger with :Spawn()
  Spawn_Train_ArtyKobuleti = SPAWN:New("Train_ArtyKobuleti")
  Spawn_ArtyKobuleti = SPAWN:New("ARTY-KOBULETI")
  :InitLimit(7,7)

  -- Spawn Batumi Speed Boat
  Spawn_Batumi_Speedboat = SPAWN:New("RU-BATUMI-SPEEDBOAT")
  :InitRandomizeRoute(1,103,1000)
  :InitLimit(5,25)
  
    
  --Spawn Moving Ground Units - Stop these from spawning if warehouse is blown up.
  Spawn_Moving_1 = SPAWN:New("WAREHOUSE CONVOY-1")
  :InitLimit(6, 50)
  :SpawnScheduled( 2400, .3 )

  
  --Spawn Moving Ground Units - Stop these from spawning if warehouse is blown up.
  Spawn_Moving_2 = SPAWN:New("WAREHOUSE CONVOY-2")
  :InitLimit(6, 50)
  :SpawnScheduled( 2400, .3 )
  
  --Spawn Moving Ground Units - Stop these from spawning if warehouse is blown up.
  Spawn_Moving_3 = SPAWN:New("WAREHOUSE CONVOY-3")
  :InitLimit(6, 50)
  :SpawnScheduled( 2400, .3 )
  
    
  --Spawn Moving Ground Units - Stop these from spawning if warehouse is blown up.
  Spawn_Moving_4 = SPAWN:New("WAREHOUSE CONVOY-4")
  :InitLimit(6, 50)
  :SpawnScheduled( 2400, .3 )
  
    --Spawn Moving Ground Units - Stop these from spawning if warehouse is blown up.
  Spawn_Moving_5 = SPAWN:New("WAREHOUSE CONVOY-5")
  :InitRandomizeRoute(0,14,2000)
  :InitLimit(6, 50)
  :SpawnScheduled( 2400, .3 )
    
    --Spawn Moving Ground Units - Stop these from spawning if warehouse is blown up.
  Spawn_Moving_6 = SPAWN:New("WAREHOUSE CONVOY-6")
  :InitRandomizeRoute(0,17,2000)
  :InitLimit(6, 50)
  :SpawnScheduled( 2400, .3 )

    --Spawn Moving Ground Units - Stop these from spawning if warehouse is blown up.
  Spawn_Moving_7 = SPAWN:New("WAREHOUSE CONVOY-7")
  :InitRandomizeRoute(0,14,2000)
  :InitLimit(6, 50)
  :SpawnScheduled( 2400, .3 )


      --Spawn Moving Ground Units - Stop these from spawning if warehouse is blown up.
  Spawn_Moving_8 = SPAWN:New("WAREHOUSE CONVOY-8")
  :InitRandomizeRoute(0,14,2000)
  :InitLimit(6, 50)
  :SpawnScheduled( 2400, .3 )

      --Spawn Moving Ground Units - Stop these from spawning if warehouse is blown up.
  Spawn_Moving_CONVOY_SOCHI_1 = SPAWN:New("CONVOY-SOCHI-1")
  :InitRandomizeRoute(0,14,2000)
  :InitLimit(6, 50)
  :SpawnScheduled( 5000, .3 )

  Spawn_Moving_CONVOY_SOCHI_2 = SPAWN:New("CONVOY-SOCHI-2")
  :InitRandomizeRoute(0,14,2000)
  :InitLimit(6, 50)
  :SpawnScheduled( 5000, .3 )
  
  Spawn_Moving_CONVOY_SUKUMI_1 = SPAWN:New("CONVOY-SUKHUMI-1")
  :InitRandomizeRoute(0,14,2000)
  :InitLimit(6, 50)
  :SpawnScheduled( 5000, .3 )  
  
  Spawn_Moving_CONVOY_SUKUMI_2 = SPAWN:New("CONVOY-SUKHUMI-2")
  :InitRandomizeRoute(0,14,2000)
  :InitLimit(6, 50)
  :SpawnScheduled( 5000, .3 )  
  
  Spawn_Moving_CONVOY_GUDAUTA_1 = SPAWN:New("CONVOY-GUDAUTA-1")
  :InitRandomizeRoute(0,14,2000)
  :InitLimit(6, 50)
  :SpawnScheduled( 5000, .3 )    

  Spawn_Moving_CONVOY_GUDAUTA_2 = SPAWN:New("CONVOY-GUDAUTA-2")
  :InitRandomizeRoute(0,14,2000)
  :InitLimit(6, 50)
  :SpawnScheduled( 5000, .3 )    
    
  
  -- C130 PROTECTION MISSION STATUS MESSAGES- this mission starts when Sochi, Gudauta and Sukumi are taken by Blue. 
  local TankerPilotSupply = UNIT:FindByName("TANKER PILOT SUPPLY")
  TankerPilotSupply:HandleEvent(EVENTS.Birth)
  function TankerPilotSupply:OnEventBirth(EventData)
    TankerPilotSupply:MessageToBlue("[ ESCORT MISSION ]\n\nTHIS IS CAPT. OBVIOUS, REQUESTING IMMEDIATE ESCORT FROM KRASNADOR TO SOCHI.\n\nCARGO ONBOARD: PILOTS FOR THE TANKERS LOCATED AT SOCHI!\n\n", 15)
    SoundRadioMsg:ToCoalition(coalition.side.BLUE)
  end
--  TankerPilotSupply:HandleEvent(EVENTS.EngineStartup)
--  function TankerPilotSupply:OnEventEngineStartup(EventData)
--    TankerPilotSupply:MessageToBlue("[ CAPT. OBVIOUS KRASNADOR C-130 ]\n\nEngines are running, we are taxing.\n\nETA: 30 mins.\nCargo: Tanker Pilots\nDestination: Sochi\n", 15)
--    SoundRadioMsg:ToCoalition(coalition.side.BLUE)
--  end
  TankerPilotSupply:HandleEvent(EVENTS.Hit)
  function TankerPilotSupply:OnEventHit(EventData)
    TankerPilotSupply:MessageToBlue("[ CAPT. OBVIOUS C-130 INBOUND TO SOCHI]\n\nWe are taking fire!! Mayday Mayday!", 15)
    SoundRadioMsg:ToCoalition(coalition.side.BLUE)
  end
  TankerPilotSupply:HandleEvent(EVENTS.Crash)
  function TankerPilotSupply:OnEventCrash(EventData)
    TankerPilotSupply:MessageToBlue("[ TANKER MISSION FAILURE ]\n\nThe C-130 that was carrying the pilots for our tankers has been shot down! No tankers will be available for the remainder of the mission!", 30)
    SoundRadioMsg:ToCoalition(coalition.side.BLUE)
  end
  TankerPilotSupply:HandleEvent(EVENTS.Land)
  function TankerPilotSupply:OnEventLand(EventData)
    TankerPilotSupply:MessageToBlue("[ CAPT. OBVIOUS C130 @ SOCHI ]\n\nWe have landed. Tanker pilots have been delivered. Tankers will be starting up soon!", 15)
    SoundRadioMsg:ToCoalition(coalition.side.BLUE)
  end
  

    
  
  
  
    -----------Spawn AWACS------------------------------
  Spawn_BlueEWR = SPAWN:New("BLUE EWR"):InitLimit( 1, 50 )
  :InitRepeatOnEngineShutDown()
  :InitCleanUp(120)  
  :SpawnScheduled(300,.3)
  
    -----------Spawn AWACS CVN---------------------------
  Spawn_BlueEWR = SPAWN:New("BLUE EWR MAGIC"):InitLimit( 1, 50 )
  :InitRepeatOnEngineShutDown()
  :InitCleanUp(120)  
  :SpawnScheduled(300,.3)  
     
  Spawn_RedEWR = SPAWN:New("RED EWR"):InitLimit( 1, 50 )
  :InitRepeatOnEngineShutDown()
  :InitCleanUp(120)
  :SpawnScheduled(300,.4)
  
  -- Spawn Tankers (after Sochi, Gudauta and Sukhumi are captured.
  Spawn_Blue135 = SPAWN:New("Shell SHL 42 X 253am"):InitLimit( 1, 50 )
  :InitRepeatOnEngineShutDown()
  :InitCleanUp(120)

  
  Spawn_Blue135MPRS = SPAWN:New("Texaco TEX 41 X 252am"):InitLimit( 1, 50 )
  :InitRepeatOnEngineShutDown()
  :InitCleanUp(120)
  --:SpawnScheduled(300,.3) -- TURN ON WITH MISSION TRIGGER INSTEAD      
  
  Spawn_MaykopBombers = SPAWN:New("MAYKOP BOMBER")
  :InitLimit(4, 50)
  :InitCleanUp(120)
  -- Spawn_MaykopBombers:SpawnScheduled(1200,.2) -- TURN ON IN ME WHEN MAYKOP IS TAKEN
  

  -- Recovery Tanker
  -- S-3B at USS Stennis spawning on deck.
  local CVNRecoveryTanker=RECOVERYTANKER:New("CVN-71 Theodore Roosevelt", "Arco ARC 43 Y 253am")
  
  -- Custom settings for radio frequency, TACAN, callsign and modex.
  CVNRecoveryTanker:SetRadio(253)
  CVNRecoveryTanker:SetTACAN(43, "ARC")
  CVNRecoveryTanker:SetCallsign(CALLSIGN.Tanker.Arco, 3)
  CVNRecoveryTanker:SetModex(0)  -- "Triple nuts"
  
  -- Start recovery tanker.
  -- NOTE: If you spawn on deck, it seems prudent to delay the spawn a bit after the mission starts.
  CVNRecoveryTanker:__Start(1)


  -- Base Capture Events & Functions
  -- Beslan
  CaptureBeslan = AIRBASE:FindByName("Beslan")
  CaptureBeslan:HandleEvent(EVENTS.BaseCaptured)
  function CaptureBeslan:OnEventBaseCaptured(EventData)
    local coa = CaptureBeslan:GetCoalition()

    -- To a specific coalition.       
    if coa == 1 then -- red
      --SoundRadioMsg:ToCoalition(coalition.side.RED)
      local RadioMessage = MESSAGE:New("Failure! Beslan has been captured by NATO!",5,"[ MISSION PROGRESS ]", false):ToRed()

    elseif coa == 2 then -- blue
      --SoundRadioMsg:ToCoalition(coalition.side.BLUE)  
      local RadioMessage = MESSAGE:New("Beslan has been captured by NATO! You may now use the Aircraft at this Airbase.    ",5,"[ MISSION PROGRESS ]", false):ToBlue()
    
      trigger.action.setUserFlag("Beslan-1",0)
      trigger.action.setUserFlag("Beslan-2",0)
      trigger.action.setUserFlag("Beslan-3",0)
      trigger.action.setUserFlag("Beslan-4",0)
      trigger.action.setUserFlag("Beslan-5",0)
      trigger.action.setUserFlag("Beslan-6",0)
      trigger.action.setUserFlag("Beslan-7",0)
      trigger.action.setUserFlag("Beslan-8",0)
      
      trigger.action.setUserFlag("BESLAN-UH1-1",0)
      trigger.action.setUserFlag("BESLAN-UH1-2",0)
      trigger.action.setUserFlag("BESLAN-MI8-1",0)
      trigger.action.setUserFlag("BESLAN-MI8-2",0)
      trigger.action.setUserFlag("BESLAN-HIND-1",0)
      trigger.action.setUserFlag("BESLAN-HIND-2",0)
      trigger.action.setUserFlag("BESLAN-APACHE-1",0)
      trigger.action.setUserFlag("BESLAN-APACHE-2",0)
      trigger.action.setUserFlag("BESLAN-GAZ-1",0)
      trigger.action.setUserFlag("BESLAN-GAZ-2",0)
      trigger.action.setUserFlag("BESLAN-GAZ-3",0)
      trigger.action.setUserFlag("BESLAN-GAZ-4",0)
      trigger.action.setUserFlag("BESLAN-KA50-1",0)
      trigger.action.setUserFlag("BESLAN-KA50-2",0)
      
      -- Figure out how to add smoke effects?
    end
  end   
  
  -- Kolkhi
  CaptureKolkhi = AIRBASE:FindByName("Senaki-Kolkhi")
  CaptureKolkhi:HandleEvent(EVENTS.BaseCaptured)
  function CaptureKolkhi:OnEventBaseCaptured(EventData)
    local coa = CaptureKolkhi:GetCoalition()
    if coa == 1 then -- red
      local RadioMessage = MESSAGE:New("Failure! Kolkhi has been captured by NATO!",5,"[ MISSION PROGRESS ]", false):ToRed()
    elseif coa == 2 then -- blue
      local RadioMessage = MESSAGE:New("Congratulations! Kolkhi has been captured by NATO! You may now use the Aircraft at this Airbase.",5,"[ MISSION PROGRESS ]", false):ToBlue()
      --Enable Blue
      trigger.action.setUserFlag("KOLKHI-MI8-1",0)
      trigger.action.setUserFlag("KOLKHI-MI8-2",0)
      trigger.action.setUserFlag("KOLKHI-UH1-1",0)
      trigger.action.setUserFlag("KOLKHI-UH1-2",0)
      --Disable Red
      trigger.action.setUserFlag("Kolkhi-1",100)
      trigger.action.setUserFlag("Kolkhi-2",100)
      trigger.action.setUserFlag("Kolkhi-3",100)
      trigger.action.setUserFlag("Kolkhi-4",100)
      trigger.action.setUserFlag("Kolkhi-5",100)
      trigger.action.setUserFlag("Kolkhi-6",100)
    end
  end   
  
  -- Kobuleti
  CaptureKobuleti = AIRBASE:FindByName("Kobuleti")
  CaptureKobuleti:HandleEvent(EVENTS.BaseCaptured)
  function CaptureKobuleti:OnEventBaseCaptured(EventData)
    local coa = CaptureKobuleti:GetCoalition()

    -- To a specific coalition.       
    if coa == 1 then -- red
      --SoundRadioMsg:ToCoalition(coalition.side.RED)
      local RadioMessage = MESSAGE:New("Failure! Kobuleti has been captured by NATO!",5,"[ MISSION PROGRESS ]", false):ToRed()

    elseif coa == 2 then -- blue
      --SoundRadioMsg:ToCoalition(coalition.side.BLUE)      
      local RadioMessage = MESSAGE:New("Congratulations! Kobuleti has been captured by NATO! You may now use the Aircraft at this Airbase.",5,"[ MISSION PROGRESS ]", false):ToBlue()

        trigger.action.setUserFlag("KOBULETI-MI8-1",0)
        trigger.action.setUserFlag("KOBULETI-MI8-2",0)
        trigger.action.setUserFlag("KOBULETI-UH1-1",0)
        trigger.action.setUserFlag("KOBULETI-UH1-2",0)
      
      -- Figure out how to add smoke effects?
    end
  end 

  -- Sukhumi
  CaptureSukhumi = AIRBASE:FindByName("Sukhumi-Babushara")
  CaptureSukhumi:HandleEvent(EVENTS.BaseCaptured)
  function CaptureSukhumi:OnEventBaseCaptured(EventData)
    local coa = CaptureSukhumi:GetCoalition()

    -- To a specific coalition.       
    if coa == 1 then -- red
      --SoundRadioMsg:ToCoalition(coalition.side.RED)
      local RadioMessage = MESSAGE:New("Failure! Sukhumi has been captured by NATO!",5,"[ MISSION PROGRESS ]", false):ToRed()

    elseif coa == 2 then -- blue
      --SoundRadioMsg:ToCoalition(coalition.side.BLUE)  
      local RadioMessage = MESSAGE:New("Sukhumi has been captured by NATO! You may now use the Aircraft at this Airbase.",5,"[ MISSION PROGRESS ]", false):ToBlue()
        trigger.action.setUserFlag("Sukhumi-1",0)
        trigger.action.setUserFlag("Sukhumi-2",0)
        trigger.action.setUserFlag("Sukhumi-3",0)
        trigger.action.setUserFlag("Sukhumi-4",0)
        trigger.action.setUserFlag("Sukhumi-5",0)
        trigger.action.setUserFlag("Sukhumi-6",0)
        trigger.action.setUserFlag("Sukhumi-7",0)
        trigger.action.setUserFlag("Sukhumi-8",0)
        trigger.action.setUserFlag("Sukhumi-9",0)
        trigger.action.setUserFlag("Sukhumi-10",0)
        trigger.action.setUserFlag("Sukhumi-11",0)
        
        trigger.action.setUserFlag("SUKHUMI-MI8-1",0)
        trigger.action.setUserFlag("SUKHUMI-MI8-2",0)
        
        trigger.action.setUserFlag("SUKHUMI-UH1-1",0)
        trigger.action.setUserFlag("SUKHUMI-UH1-2",0)
      
      -- Figure out how to add smoke effects?
    end
  end    
  
  -- Gudauta
  CaptureGudauta = AIRBASE:FindByName("Gudauta")
  CaptureGudauta:HandleEvent(EVENTS.BaseCaptured)
  function CaptureGudauta:OnEventBaseCaptured(EventData)
    local coa = CaptureGudauta:GetCoalition()

    -- To a specific coalition.       
    if coa == 1 then -- red
      --SoundRadioMsg:ToCoalition(coalition.side.RED)
      local RadioMessage = MESSAGE:New("Failure! Gudauta has been captured by NATO!",5,"[ MISSION PROGRESS ]", false):ToRed()

    elseif coa == 2 then -- blue
      --SoundRadioMsg:ToCoalition(coalition.side.BLUE)      
      local RadioMessage = MESSAGE:New("Gudauta has been captured by NATO! You may now use the Aircraft at this Airbase.",5,"[ MISSION PROGRESS ]", false):ToBlue()
      --Enable Blue
      trigger.action.setUserFlag("GUDAUTA-MI8-1",0)
      trigger.action.setUserFlag("GUDAUTA-MI8-2",0)
      trigger.action.setUserFlag("GUDAUTA-UH1-1",0)
      trigger.action.setUserFlag("GUDAUTA-UH1-2",0)
      trigger.action.setUserFlag("GUDAUTA-MIRAGE-1",0)
      trigger.action.setUserFlag("GUDAUTA-MIRAGE-2",0)

            --Diable Red
      trigger.action.setUserFlag("Gudauta-1",100)
      trigger.action.setUserFlag("Gudauta-2",100)
      trigger.action.setUserFlag("Gudauta-3",100)
      trigger.action.setUserFlag("Gudauta-4",100)
    end
  end  

  -- Sochi
  CaptureSochi = AIRBASE:FindByName("Sochi-Adler")
  CaptureSochi:HandleEvent(EVENTS.BaseCaptured)
  function CaptureSochi:OnEventBaseCaptured(EventData)
    local coa = CaptureSochi:GetCoalition()

    -- To a specific coalition.       
    if coa == 1 then -- red
      --SoundRadioMsg:ToCoalition(coalition.side.RED)
      local RadioMessage = MESSAGE:New("Failure! Sochi has been captured by NATO!",5,"[ MISSION PROGRESS ]", false):ToRed()

    elseif coa == 2 then -- blue
      --SoundRadioMsg:ToCoalition(coalition.side.BLUE)  
      local RadioMessage = MESSAGE:New("Sochi has been captured by NATO! You may now use the Aircraft at this Airbase.",5,"[ MISSION PROGRESS ]", false):ToBlue()
      
      trigger.action.setUserFlag("Sochi-1",0)
      trigger.action.setUserFlag("Sochi-2",0)
      trigger.action.setUserFlag("Sochi-3",0)
      trigger.action.setUserFlag("Sochi-4",0)
      trigger.action.setUserFlag("Sochi-5",0)
      trigger.action.setUserFlag("Sochi-6",0)
      trigger.action.setUserFlag("Sochi-7",0)
      trigger.action.setUserFlag("Sochi-8",0)
      trigger.action.setUserFlag("Sochi-9",0)
      trigger.action.setUserFlag("Sochi-10",0)
      trigger.action.setUserFlag("Sochi-11",0)
      
      trigger.action.setUserFlag("SOCHI-APACHE-1",0)
      trigger.action.setUserFlag("SOCHI-APACHE-2",0)
      trigger.action.setUserFlag("SOCHI-APACHE-3",0)
      trigger.action.setUserFlag("SOCHI-APACHE-4",0)
      
      trigger.action.setUserFlag("SOCHI-HIND-1",0)
      trigger.action.setUserFlag("SOCHI-HIND-2",0)
      trigger.action.setUserFlag("SOCHI-HIND-3",0)
      trigger.action.setUserFlag("SOCHI-HIND-4",0)

      trigger.action.setUserFlag("SOCHI-MI8-1",0)
      trigger.action.setUserFlag("SOCHI-MI8-2",0)
       
      trigger.action.setUserFlag("SOCHI-UH1-1",0)
      trigger.action.setUserFlag("SOCHI-UH1-2",0)
      
      trigger.action.setUserFlag("SOCHI-GAZ-1",0)
      trigger.action.setUserFlag("SOCHI-GAZ-2",0)
      trigger.action.setUserFlag("SOCHI-GAZ-3",0)
      trigger.action.setUserFlag("SOCHI-GAZ-4",0)
      
     
      trigger.action.setUserFlag("SOCHI-KA50-1",0)
      trigger.action.setUserFlag("SOCHI-KA50-2",0)
      trigger.action.setUserFlag("SOCHI-KA50-3",0)
      trigger.action.setUserFlag("SOCHI-KA50-4",0)
      
      -- Figure out how to add smoke effects?
    end
  end  
  
  


  -- Mozdok
  CaptureMozdok = AIRBASE:FindByName("Mozdok")
  CaptureMozdok:HandleEvent(EVENTS.BaseCaptured)
  function CaptureMozdok:OnEventBaseCaptured(EventData)
    local coa = CaptureMozdok:GetCoalition()
    if coa == 1 then -- red    
       local RadioMessage = MESSAGE:New("Failure! Mozdok has been captured by NATO!",5,"[ MISSION PROGRESS ]", false):ToRed()
    elseif coa == 2 then -- blue
      local RadioMessage = MESSAGE:New("Mozdok has been captured by NATO!",5,"[ MISSION PROGRESS ]", false):ToBlue()
    end
  end
  
  -- Nalchik
  CaptureNalchik = AIRBASE:FindByName("Nalchik")
  CaptureNalchik:HandleEvent(EVENTS.BaseCaptured)
  function CaptureNalchik:OnEventBaseCaptured(EventData)
    local coa = CaptureNalchik:GetCoalition()
    if coa == 1 then -- red    
       local RadioMessage = MESSAGE:New("Failure! Nalchik has been captured by NATO!",5,"[ MISSION PROGRESS ]", false):ToRed()
    elseif coa == 2 then -- blue
      local RadioMessage = MESSAGE:New("Nalchik has been captured by NATO!",5,"[ MISSION PROGRESS ]", false):ToBlue()
    end
  end
  
  -- Kobuleti
  CaptureKobuleti = AIRBASE:FindByName("Kobuleti")
  CaptureKobuleti:HandleEvent(EVENTS.BaseCaptured)
  function CaptureKobuleti:OnEventBaseCaptured(EventData)
    local coa = CaptureKobuleti:GetCoalition()
    if coa == 1 then -- red    
       local RadioMessage = MESSAGE:New("Failure! Kobuleti has been captured by NATO!",5,"[ MISSION PROGRESS ]", false):ToRed()
    elseif coa == 2 then -- blue
      local RadioMessage = MESSAGE:New("Kobuleti has been captured by NATO!",5,"[ MISSION PROGRESS ]", false):ToBlue()
      trigger.action.setUserFlag("KOBULETI-MI8-1",0)
      trigger.action.setUserFlag("KOBULETI-MI8-2",0)
      trigger.action.setUserFlag("KOBULETI-UH1-1",0)
      trigger.action.setUserFlag("KOBULETI-UH1-2",0)
    end
  end

  -- Maykop
  CaptureMaykop = AIRBASE:FindByName("Maykop-Khanskaya")
  CaptureMaykop:HandleEvent(EVENTS.BaseCaptured)
  function CaptureMaykop:OnEventBaseCaptured(EventData)
    local coa = CaptureMaykop:GetCoalition()
    if coa == 1 then -- red    
       local RadioMessage = MESSAGE:New("Failure! Maykop has been captured by NATO!",5,"[ MISSION PROGRESS ]", false):ToRed()
    elseif coa == 2 then -- blue
      local RadioMessage = MESSAGE:New("Maykop has been captured by NATO!",5,"[ MISSION PROGRESS ]", false):ToBlue()
      trigger.action.setUserFlag("Maykop-1",0)
      trigger.action.setUserFlag("Maykop-2",0)
      trigger.action.setUserFlag("Maykop-3",0)
      trigger.action.setUserFlag("Maykop-4",0)
      trigger.action.setUserFlag("Maykop-5",0)
      trigger.action.setUserFlag("Maykop-6",0)
    end
  end

  -- Kutaisi
  CaptureKutaisi = AIRBASE:FindByName("Kutaisi")
  CaptureKutaisi:HandleEvent(EVENTS.BaseCaptured)
  function CaptureKutaisi:OnEventBaseCaptured(EventData)
    local coa = CaptureKutaisi:GetCoalition()
    if coa == 1 then -- red    
       local RadioMessage = MESSAGE:New("Failure! Kutaisi has been captured by NATO!",5,"[ MISSION PROGRESS ]", false):ToRed()
    elseif coa == 2 then -- blue
      local RadioMessage = MESSAGE:New("Kutaisi has been captured by NATO!",5,"[ MISSION PROGRESS ]", false):ToBlue()
      trigger.action.setUserFlag("Kutaisi-1",0)
      trigger.action.setUserFlag("Kutaisi-2",0)
      trigger.action.setUserFlag("Kutaisi-3",0)
      trigger.action.setUserFlag("Kutaisi-4",0)
      trigger.action.setUserFlag("Kutaisi-5",0)
      trigger.action.setUserFlag("Kutaisi-6",0)
      trigger.action.setUserFlag("Kutaisi-7",0)
      trigger.action.setUserFlag("Kutaisi-8",0)
      trigger.action.setUserFlag("Kutaisi-9",0)
      trigger.action.setUserFlag("Kutaisi-10",0)
      trigger.action.setUserFlag("Kutaisi-11",0)
      trigger.action.setUserFlag("Kutaisi-12",0)
    end
  end


  -- Mineralnye Vody
  CaptureVody = AIRBASE:FindByName("Mineralnye Vody")
  CaptureVody:HandleEvent(EVENTS.BaseCaptured)
  function CaptureVody:OnEventBaseCaptured(EventData)
    local coa = CaptureVody:GetCoalition()
    if coa == 1 then -- red    
       local RadioMessage = MESSAGE:New("Failure! Mineralnye Vody has been captured by NATO!",5,"[ MISSION PROGRESS ]", false):ToRed()
    elseif coa == 2 then -- blue
      local RadioMessage = MESSAGE:New("Mineralnye Vody has been captured by NATO!",5,"[ MISSION PROGRESS ]", false):ToBlue()
    end
  end
  
  -- Batumi
  CaptureBatumi = AIRBASE:FindByName("Batumi")
  CaptureBatumi:HandleEvent(EVENTS.BaseCaptured)
  function CaptureBatumi:OnEventBaseCaptured(EventData)
    local coa = CaptureBatumi:GetCoalition()

    -- To a specific coalition.       
    if coa == 1 then -- red
      --SoundRadioMsg:ToCoalition(coalition.side.RED)
      local RadioMessage = MESSAGE:New("Failure! Batumi has been captured by NATO!",5,"[ MISSION PROGRESS ]", false):ToRed()

    elseif coa == 2 then -- blue
      --SoundRadioMsg:ToCoalition(coalition.side.BLUE)        
      local RadioMessage = MESSAGE:New("Batumi has been captured by NATO!",5,"[ MISSION PROGRESS ]", false):ToBlue()
      
      trigger.action.setUserFlag("Batumi-1",0)
      trigger.action.setUserFlag("Batumi-2",0)
      trigger.action.setUserFlag("Batumi-3",0)
      trigger.action.setUserFlag("Batumi-4",0)
      trigger.action.setUserFlag("Batumi-5",0)
      trigger.action.setUserFlag("Batumi-6",0)
      
      trigger.action.setUserFlag("BATUMI-APACHE-1",0)
      trigger.action.setUserFlag("BATUMI-APACHE-2",0)
      trigger.action.setUserFlag("BATUMI-APACHE-3",0)
      trigger.action.setUserFlag("BATUMI-APACHE-4",0)
      
      trigger.action.setUserFlag("BATUMI-HIND-1",0)
      trigger.action.setUserFlag("BATUMI-HIND-2",0)
      trigger.action.setUserFlag("BATUMI-HIND-3",0)
      trigger.action.setUserFlag("BATUMI-HIND-4",0)
      
      trigger.action.setUserFlag("BATUMI-UH1-1",0)
      trigger.action.setUserFlag("BATUMI-UH1-2",0)
      trigger.action.setUserFlag("BATUMI-UH1-3",0)
      trigger.action.setUserFlag("BATUMI-UH1-4",0)
      
      trigger.action.setUserFlag("BATUMI-GAZ-1",0)
      trigger.action.setUserFlag("BATUMI-GAZ-2",0)
      trigger.action.setUserFlag("BATUMI-GAZ-3",0)
      trigger.action.setUserFlag("BATUMI-GAZ-4",0)
      
      trigger.action.setUserFlag("BATUMI-MI8-1",0)
      trigger.action.setUserFlag("BATUMI-MI8-2",0)
      trigger.action.setUserFlag("BATUMI-MI8-3",0)
      trigger.action.setUserFlag("BATUMI-MI8-4",0)
      
      trigger.action.setUserFlag("BATUMI-KA50-1",0)
      trigger.action.setUserFlag("BATUMI-KA50-2",0)
      trigger.action.setUserFlag("BATUMI-KA50-3",0)
      trigger.action.setUserFlag("BATUMI-KA50-4",0)
      
      -- Figure out how to add smoke effects?
    end
  end  
  
  
--  Clean = CLEANUP_AIRBASE:New( AIRBASE.Caucasus.Batumi )
--  Clean:SetCleanMissiles( false )
  
  
-- I don't know why this crap doesn't work. Well it works, but the onbrith or startup events keep happening 
-- even though the plane is already alive. Update: happens when each new player logs in - all the events fire. =/ lame.  
  
---- Messages for AWACS  
--  Spawn_BlueEWR:HandleEvent(EVENTS.Birth)
--  function Spawn_BlueEWR:OnEventBirth(EventData)
--    local RadioMessage = MESSAGE:New("A new AWACS has spawned.",15,"[ AWACS STATUS ]", true):ToBlue()
--    SoundRadioMsg:ToCoalition(coalition.side.BLUE)
--  end
--      
--  Spawn_BlueEWR:HandleEvent(EVENTS.EngineStartup)
--  function Spawn_BlueEWR:OnEventEngineStartup(EventData)
--    local RadioMessage = MESSAGE:New("AWACS Startup Complete.",15,"[ AWACS STATUS ]", true):ToBlue()
--    SoundRadioMsg:ToCoalition(coalition.side.BLUE)
--  end
--  
--  Spawn_BlueEWR:HandleEvent(EVENTS.EngineShutdown)
--  function Spawn_BlueEWR:OnEventEngineShutdown(EventData)
--    local RadioMessage = MESSAGE:New("AWACS Shutdown. Swapping Pilots, restarting soon..",15,"[ AWACS STATUS ]", true):ToBlue()
--    SoundRadioMsg:ToCoalition(coalition.side.BLUE)
--  end
--  
--  Spawn_BlueEWR:HandleEvent(EVENTS.Land)
--  function Spawn_BlueEWR:OnEventLand(EventData)
--    local RadioMessage = MESSAGE:New("AWACS has landed. Taxing to parking.",15,"[ AWACS STATUS ]", true):ToBlue()
--    SoundRadioMsg:ToCoalition(coalition.side.BLUE)
--  end
--  
--  Spawn_BlueEWR:HandleEvent(EVENTS.Takeoff)
--  function Spawn_BlueEWR:OnEventTakeoff(EventData)
--    local RadioMessage = MESSAGE:New("AWACS has taken off, AWACS Services Online.",15,"[ AWACS STATUS ]", true):ToBlue()  
--    SoundRadioMsg:ToCoalition(coalition.side.BLUE)
--  end
--  
--  -- Messages for RED AWACS  
--  Spawn_RedEWR:HandleEvent(EVENTS.Birth)
--  function Spawn_RedEWR:OnEventBirth(EventData)
--    local RadioMessage = MESSAGE:New("A new AWACS has spawned..",15,"[ AWACS STATUS ]", true):ToRed()
--    SoundRadioMsg:ToCoalition(coalition.side.RED)
--  end
----  Spawn_RedEWR:HandleEvent(EVENTS.EngineStartup)
----  function Spawn_RedEWR:OnEventEngineStartup(EventData)
----    local RadioMessage = MESSAGE:New("AWACS Startup Complete.",15,"[ AWACS STATUS ]", true):ToRed()
----    SoundRadioMsg:ToCoalition(coalition.side.RED)
----  end
--  Spawn_RedEWR:HandleEvent(EVENTS.EngineShutdown)
--  function Spawn_RedEWR:OnEventEngineShutdown(EventData)
--    local RadioMessage = MESSAGE:New("AWACS Shuting down..",15,"[ AWACS STATUS ]", true):ToRed()
--    SoundRadioMsg:ToCoalition(coalition.side.RED)
--  end
--  Spawn_RedEWR:HandleEvent(EVENTS.Land)
--  function Spawn_RedEWR:OnEventLand(EventData)
--    local RadioMessage = MESSAGE:New("AWACS has landed..",15,"[ AWACS STATUS ]", true):ToRed()
--    SoundRadioMsg:ToCoalition(coalition.side.RED)
--  end
--  Spawn_RedEWR:HandleEvent(EVENTS.Takeoff)
--  function Spawn_RedEWR:OnEventTakeoff(EventData)
--    local RadioMessage = MESSAGE:New("AWACS has taken off..",15,"[ AWACS STATUS ]", true):ToRed()
--    SoundRadioMsg:ToCoalition(coalition.side.RED)
--  end
--  
---- Messages for Shell SHL 42 X 253 
--  Spawn_Blue135:HandleEvent(EVENTS.Birth)
--  function Spawn_Blue135:OnEventBirth(EventData)
--    local RadioMessage = MESSAGE:New("Tanker Shell on 42x 253am has spawned..",15,"[ 135 TANKER STATUS ]", true):ToBlue()
--    SoundRadioMsg:ToCoalition(coalition.side.BLUE)
--  end
----  Spawn_Blue135:HandleEvent(EVENTS.EngineStartup)
----  function Spawn_Blue135:OnEventEngineStartup(EventData)
----    local RadioMessage = MESSAGE:New("Tanker Shell on 42x 253am has started up..",15,"[ 135 TANKER STATUS ]", true):ToBlue()
----    SoundRadioMsg:ToCoalition(coalition.side.BLUE)
----  end
--  Spawn_Blue135:HandleEvent(EVENTS.EngineShutdown)
--  function Spawn_Blue135:OnEventEngineShutdown(EventData)
--    local RadioMessage = MESSAGE:New("Tanker Shell on 42x 253am has shut down..",15,"[ 135 TANKER STATUS ]", true):ToBlue()
--    SoundRadioMsg:ToCoalition(coalition.side.BLUE)
--  end
--  Spawn_Blue135:HandleEvent(EVENTS.Land)
--  function Spawn_Blue135:OnEventLand(EventData)
--    local RadioMessage = MESSAGE:New("Tanker Shell on 42x 253am has Landed..",15,"[ 135 TANKER STATUS ]", true):ToBlue()
--    SoundRadioMsg:ToCoalition(coalition.side.BLUE)
--  end
--  Spawn_Blue135:HandleEvent(EVENTS.Takeoff)
--  function Spawn_Blue135:OnEventTakeoff(EventData)
--    local RadioMessage = MESSAGE:New("Tanker Shell on 42x 253am has taken off..",15,"[ 135 TANKER STATUS ]", true):ToBlue()
--    SoundRadioMsg:ToCoalition(coalition.side.BLUE)
--  end
--  
--  -- Messages for Texaco TEX 41 X 252
--  Spawn_Blue135MPRS:HandleEvent(EVENTS.Birth)
--  function Spawn_Blue135MPRS:OnEventBirth(EventData)
--    local RadioMessage = MESSAGE:New("Tanker Texaco TEX 41x 252am has spawned..",15,"[ 135MPRS TANKER STATUS ]", true):ToBlue()
--    SoundRadioMsg:ToCoalition(coalition.side.BLUE)
--  end
----  Spawn_Blue135MPRS:HandleEvent(EVENTS.EngineStartup)
----  function Spawn_Blue135MPRS:OnEventEngineStartup(EventData)
----    local RadioMessage = MESSAGE:New("Tanker Texaco TEX 41x 252am has started up..",15,"[ 135MPRS TANKER STATUS ]", true):ToBlue()
----    SoundRadioMsg:ToCoalition(coalition.side.BLUE)
----  end
--  Spawn_Blue135MPRS:HandleEvent(EVENTS.EngineShutdown)
--  function Spawn_Blue135MPRS:OnEventEngineShutdown(EventData)
--    local RadioMessage = MESSAGE:New("Tanker Texaco TEX 41x 252am has shut down..",15,"[ 135MPRS TANKER STATUS ]", true):ToBlue()
--    SoundRadioMsg:ToCoalition(coalition.side.BLUE)
--  end
--  Spawn_Blue135MPRS:HandleEvent(EVENTS.Land)
--  function Spawn_Blue135MPRS:OnEventLand(EventData)
--    local RadioMessage = MESSAGE:New("Tanker Texaco TEX 41x 252am has Landed..",15,"[ 135MPRS TANKER STATUS ]", true):ToBlue()
--    SoundRadioMsg:ToCoalition(coalition.side.BLUE)
--  end
--  Spawn_Blue135MPRS:HandleEvent(EVENTS.Tkeoff)
--  function Spawn_Blue135MPRS:OnEventTakeoff(EventData)
--    local RadioMessage = MESSAGE:New("Tanker Texaco TEX 41x 252am has taken off..",15,"[ 135MPRS TANKER STATUS ]", true):ToBlue()
--    SoundRadioMsg:ToCoalition(coalition.side.BLUE)
--  end
    
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  