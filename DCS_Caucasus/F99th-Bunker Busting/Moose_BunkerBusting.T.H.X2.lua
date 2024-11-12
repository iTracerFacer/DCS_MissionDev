_SETTINGS:SetPlayerMenuOff()
  
  HQ = GROUP:FindByName( "HQ", "Bravo HQ" )

  CommandCenter = COMMANDCENTER:New( HQ, "Bravo" )

  Scoring = SCORING:New( "Bunker Busting" )
  
--------------Random Air Traffic--------------
--  local rat130 = RAT:New("RAT_130")
--  rat130:SetDeparture({"Senaki-Kolkhi", "Senaki-Kolkhi", "Sukhumi-Babushara", "Gudauta", "Sochi-Adler"})
--  rat130:SetDestination({"Senaki-Kolkhi", "Senaki-Kolkhi", "Sukhumi-Babushara", "Gudauta", "Sochi-Adler"})
--  rat130:ContinueJourney()
--  rat130:Spawn(1)
--  
--  local ratB52 = RAT:New("RAT_B52")
--  ratB52:SetDeparture({"Senaki-Kolkhi", "Senaki-Kolkhi", "Sukhumi-Babushara", "Gudauta", "Sochi-Adler"})
--  ratB52:SetDestination({"Senaki-Kolkhi", "Senaki-Kolkhi", "Sukhumi-Babushara", "Gudauta", "Sochi-Adler"})
--  ratB52:ContinueJourney()
--  ratB52:Spawn(1)
--  
--  local ratc17 = RAT:New("RAT_C17")
--  ratc17:SetDeparture({"Senaki-Kolkhi", "Senaki-Kolkhi", "Sukhumi-Babushara", "Gudauta", "Sochi-Adler"})
--  ratc17:SetDestination({"Senaki-Kolkhi", "Senaki-Kolkhi", "Sukhumi-Babushara", "Gudauta", "Sochi-Adler"})
--  ratc17:ContinueJourney()
--  ratc17:Spawn(1)
--  
--  local ratf117 = RAT:New("RAT_F117")
--  ratf117:SetDeparture({"Senaki-Kolkhi", "Senaki-Kolkhi", "Sukhumi-Babushara", "Gudauta", "Sochi-Adler"})
--  ratf117:SetDestination({"Senaki-Kolkhi", "Senaki-Kolkhi", "Sukhumi-Babushara", "Gudauta", "Sochi-Adler"})
--  ratf117:ContinueJourney()
--  ratf117:Spawn(1)
--  
--  local ratbch53 = RAT:New("RAT_CH53")
--  ratbch53:SetDeparture({"Senaki-Kolkhi", "Senaki-Kolkhi", "Sukhumi-Babushara", "Gudauta", "Sochi-Adler"})
--  ratbch53:SetDestination({"Senaki-Kolkhi", "Senaki-Kolkhi", "Sukhumi-Babushara", "Gudauta", "Sochi-Adler"})
--  ratbch53:ContinueJourney()
--  ratbch53:Spawn(1)
--  
--  local ratApache = RAT:New("RAT_APACHE")
--  ratApache:SetDeparture({"Senaki-Kolkhi", "Senaki-Kolkhi", "Sukhumi-Babushara", "Gudauta", "Sochi-Adler"})
--  ratApache:SetDestination({"Senaki-Kolkhi", "Senaki-Kolkhi", "Sukhumi-Babushara", "Gudauta", "Sochi-Adler"})
--  ratApache:ContinueJourney()
--  ratApache:Spawn(1)
--  
--  local ratCobra = RAT:New("RAT_COBRA")
--  ratCobra:SetDeparture({"Senaki-Kolkhi", "Senaki-Kolkhi", "Sukhumi-Babushara", "Gudauta", "Sochi-Adler"})
--  ratCobra:SetDestination({"Senaki-Kolkhi", "Senaki-Kolkhi", "Sukhumi-Babushara", "Gudauta", "Sochi-Adler"})
--  ratCobra:ContinueJourney()
--  ratCobra:Spawn(1)
--  
--  local ratF4 = RAT:New("RAT_F4")
--  ratF4:SetDeparture({"Senaki-Kolkhi", "Senaki-Kolkhi", "Sukhumi-Babushara", "Gudauta", "Sochi-Adler"})
--  ratF4:SetDestination({"Senaki-Kolkhi", "Senaki-Kolkhi", "Sukhumi-Babushara", "Gudauta", "Sochi-Adler"})
--  ratF4:ContinueJourney()
--  ratF4:Spawn(1)
--    
--  local ratS3b = RAT:New("RAT_S3B")
--  ratS3b:SetDeparture({"Senaki-Kolkhi","Senaki-Kolkhi", "Sukhumi-Babushara", "Gudauta", "Sochi-Adler"})
--  ratS3b:SetDestination({"Senaki-Kolkhi", "Senaki-Kolkhi", "Sukhumi-Babushara", "Gudauta", "Sochi-Adler"})
--  ratS3b:ContinueJourney()
--  ratS3b:Spawn(1)
--  
--  local ratHawk = RAT:New("RAT_HAWK")
--  ratHawk:SetDeparture({"Senaki-Kolkhi","Senaki-Kolkhi", "Sukhumi-Babushara", "Gudauta", "Sochi-Adler"})
--  ratHawk:SetDestination({"Senaki-Kolkhi", "Senaki-Kolkhi", "Sukhumi-Babushara", "Gudauta", "Sochi-Adler"})
--  ratHawk:ContinueJourney()
--  ratHawk:Spawn(1)
--  
--  local ratC101 = RAT:New("RAT_c101")
--  ratC101:SetDeparture({"Senaki-Kolkhi","Senaki-Kolkhi", "Sukhumi-Babushara", "Gudauta", "Sochi-Adler"})
--  ratC101:SetDestination({"Senaki-Kolkhi", "Senaki-Kolkhi", "Sukhumi-Babushara", "Gudauta", "Sochi-Adler"})
--  ratC101:ContinueJourney()
--  ratC101:Spawn(1)
--  
--  local ratL39 = RAT:New("RAT_l39")
--  ratL39:SetDeparture({"Senaki-Kolkhi","Senaki-Kolkhi", "Sukhumi-Babushara", "Gudauta", "Sochi-Adler"})
--  ratL39:SetDestination({"Senaki-Kolkhi", "Senaki-Kolkhi", "Sukhumi-Babushara", "Gudauta", "Sochi-Adler"})
--  ratL39:ContinueJourney()
--  ratL39:Spawn(1)
  

-----------Spawn AWACS------------------------------
  
--  -- Refueling
--  Spawn_KC135 = SPAWN:New("KC-135"):InitLimit( 1, 50 )
--  Spawn_KC135:InitRepeatOnLanding()
--  Spawn_KC135:SpawnScheduled(600,.1)
--  
--  Spawn_KC130 = SPAWN:New("KC-130"):InitLimit( 1, 50 )
--  Spawn_KC130:InitRepeatOnLanding()
--  Spawn_KC130:SpawnScheduled(600,.2)
  
  

------------------- CCCP SEAD Defenses------------------------------
  SEAD_RU_SAM_Defenses = SEAD:New( { 
    'AAA 6 #005', 
    'AAA 6 #003',
    'AAA 6 #004',
    'AAA 3',
    'AAA 4',
    'AAA 5',
    'AAA 5 #001',
    'AAA #006',
    'MISSION 6 DEF #001',
    'MISSION 6 DEF #002',  
    } )


  local TemplateTable = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N" } 

  
  local M1Z = ZONE_POLYGON:New( "MISSION 1 ZONE", GROUP:FindByName( "MISSION 1 ZONE" )) 
  local M2Z = ZONE_POLYGON:New( "MISSION 2 ZONE", GROUP:FindByName( "MISSION 2 ZONE" ))
  local M3Z = ZONE_POLYGON:New( "MISSION 3 ZONE", GROUP:FindByName( "MISSION 3 ZONE" ))
  local M4Z = ZONE_POLYGON:New( "MISSION 4 ZONE", GROUP:FindByName( "MISSION 4 ZONE" ))
  local M5Z = ZONE_POLYGON:New( "MISSION 5 ZONE", GROUP:FindByName( "MISSION 5 ZONE" ))
  local M6Z = ZONE_POLYGON:New( "MISSION 6 ZONE", GROUP:FindByName( "MISSION 6 ZONE" ))
                   
  local ZoneTable = { M1Z, M2Z, M3Z, M4Z, M5Z, M6Z }


  Spawn_Vehicle_1 = SPAWN:New( "RU GROUND FORCE" )
    :InitLimit( 80, 80 )
    :InitRandomizeZones( ZoneTable )
    :InitRandomizeTemplate( TemplateTable )
    :SpawnScheduled( .1, .2 )

  
  
  --Setup the BLUEA2A dispatcher, and initialize it.
  BLUEBorderZone = ZONE_POLYGON:New( "BLUE BORDER", GROUP:FindByName( "BLUE BORDER" ) )
  BLUEA2ADispatcher = AI_A2A_GCICAP:New( { "BLUE EWR" }, { "FIGHTER SWEEP BLUE" }, { "BLUE BORDER" }, 2 )  
  BLUEA2ADispatcher:SetDefaultLandingAtRunway()
  BLUEA2ADispatcher:SetDefaultTakeoffFromParkingCold()
  BLUEA2ADispatcher:SetBorderZone( BLUEBorderZone )
  BLUEA2ADispatcher:SetTacticalDisplay(false)
  BLUEA2ADispatcher:SetDefaultFuelThreshold( 0.20 )
  BLUEA2ADispatcher:SetRefreshTimeInterval( 240 )
  BLUEA2ADispatcher:SetDefaultOverhead(.25)
  BLUEA2ADispatcher:SetDefaultCapLimit(2)
  
   
  
  
  --Setup the RedA2A dispatcher, and initialize it.
  CCCPBorderZone = ZONE_POLYGON:New( "RED BORDER", GROUP:FindByName( "RED BORDER" ) )
  RedA2ADispatcher = AI_A2A_GCICAP:New( { "RED EWR" }, { "FIGHTER SWEEP RED" }, { "RED BORDER" }, 2 )
  RedA2ADispatcher:SetDefaultLandingAtRunway()
  RedA2ADispatcher:SetDefaultTakeoffFromParkingCold()
  RedA2ADispatcher:SetBorderZone( CCCPBorderZone )
  RedA2ADispatcher:SetTacticalDisplay(false)
  RedA2ADispatcher:SetDefaultFuelThreshold( 0.20 )
  RedA2ADispatcher:SetRefreshTimeInterval( 240 )
  RedA2ADispatcher:SetDefaultOverhead(.25)
  RedA2ADispatcher:SetDefaultCapLimit(4)
  --ADDED 2020 ATIS
--atisGudauta=ATIS:New("Gudauta", 126.50)
--atisGudauta:SetTowerFrequencies({259.000, 130.000})
--atisGudauta:Start(50)

--atisSochi=ATIS:New("Sochi-Adler", 126.00)
--atisSochi:SetTowerFrequencies({256.000, 127.000})
--atisSochi:AddILS(111.10, "6")
--atisSochi:Start(30)

--atisSenaki=ATIS:New("Senaki-Kolkhi", 125.50)
--atisSenaki:SetTowerFrequencies({261.000, 132.000})
--atisSenaki:AddILS(108.90, "9")
--atisSenaki:SetTACAN(31)
--atisSenaki:Start(60)

--atisSukhumi=ATIS:New("Sukhumi-Babushara", 125.00)
--atisSukhumi:SetTowerFrequencies({258.000, 129.000})
--atisSukhumi:Start(20)