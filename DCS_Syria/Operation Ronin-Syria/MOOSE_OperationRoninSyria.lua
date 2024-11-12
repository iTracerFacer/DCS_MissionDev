--  Operation Ronin Syria by F99Th-TracerFacer
_SETTINGS:SetPlayerMenuOff()

  --Setup the ASSAD dispatcher, and initialize it.
  AssadGCICAPZone = ZONE_POLYGON:New( "AssadGCICAPZone", GROUP:FindByName( "AssadGCICAPZone" ) )
  AssadDispatcher = AI_A2A_GCICAP:New( { "RED EWR ASSAD" }, { "ASSAD CAP" }, { "AssadGCICAPZone" }, 0 )
  AssadDispatcher:SetDefaultLandingAtRunway()
  AssadDispatcher:SetDefaultTakeoffFromParkingHot()
  AssadDispatcher:SetBorderZone( AssadGCICAPZone )
  AssadDispatcher:SetTacticalDisplay(false)
  AssadDispatcher:SetDefaultFuelThreshold( 0.20 )
  AssadDispatcher:SetRefreshTimeInterval( 300 )
  AssadDispatcher:SetDefaultOverhead(.25)

  
  --Setup the DUHUR dispatcher, and initialize it.
  DuhurGCICAPZone = ZONE_POLYGON:New( "DuhurGCICAPZone", GROUP:FindByName( "DuhurGCICAPZone" ) )
  DuhurDispatcher = AI_A2A_GCICAP:New( { "RED EWR DUHUR" }, { "DUHUR CAP" }, { "DuhurGCICAPZone" }, 0 )
  DuhurDispatcher:SetDefaultLandingAtRunway()
  DuhurDispatcher:SetDefaultTakeoffFromParkingHot()
  DuhurDispatcher:SetBorderZone( DuhurGCICAPZone )
  DuhurDispatcher:SetTacticalDisplay(false)
  DuhurDispatcher:SetDefaultFuelThreshold( 0.20 )
  DuhurDispatcher:SetRefreshTimeInterval( 300 )
  DuhurDispatcher:SetDefaultOverhead(.25)
  
  --Setup the DUHUR dispatcher, and initialize it.
  TabqaGCICAPZone = ZONE_POLYGON:New( "TabqaGCICAPZone", GROUP:FindByName( "TabqaGCICAPZone" ) )
  TabqaDispatcher = AI_A2A_GCICAP:New( { "RED EWR TABQA" }, { "TABQA CAP" }, { "TabqaGCICAPZone" }, 0 )
  TabqaDispatcher:SetDefaultLandingAtRunway()
  TabqaDispatcher:SetDefaultTakeoffFromParkingHot()
  TabqaDispatcher:SetBorderZone( TabqaGCICAPZone )
  TabqaDispatcher:SetTacticalDisplay(false)
  TabqaDispatcher:SetDefaultFuelThreshold( 0.20 )
  TabqaDispatcher:SetRefreshTimeInterval( 300 )
  TabqaDispatcher:SetDefaultOverhead(.25)
  
    -----------Spawn AWACS------------------------------

  Spawn_BlueEWR = SPAWN:New("BLUE EWR"):InitLimit( 1, 50 )
  :InitRepeatOnEngineShutDown()
  :InitCleanUp(120)  
  :SpawnScheduled(300,.3)

 
  --Types of Status:
  -- Inactive - No one has attack this zone yet.
  -- Loiter Alert -- The loiter trigger has fired - some aa present
  -- Active -- One or more towers have been damaged
  -- Active Failed -- 30 second timer exceeded - more towers need destroying
  -- Complete Failed -- All towers are down - base is Red.
  -- Complete Success -- All towers are down - Base is blue.
  


  function MissionStatus(MsgTime)
    
    WP1 = AIRBASE:FindByName("Bassel Al-Assad")
    WP1Coa = WP1:GetCoalitionName()
    WP1Tower1 = STATIC:FindByName("WP1 TV TOWER-1")
    WP1Tower2 = STATIC:FindByName("WP1 TV TOWER-2")
    WP1Tower3 = STATIC:FindByName("WP1 TV TOWER-3")

    WP2 = AIRBASE:FindByName("Abu al-Duhur")
    WP2Coa = WP1:GetCoalitionName()
    WP2Tower1 = STATIC:FindByName("WP2 TV TOWER-1")
    WP2Tower2 = STATIC:FindByName("WP2 TV TOWER-2")
    WP2Tower3 = STATIC:FindByName("WP2 TV TOWER-3")
        
    WP3 = AIRBASE:FindByName("Abu al-Duhur")
    WP3Coa = WP1:GetCoalitionName()
    WP3Tower1 = STATIC:FindByName("WP3 TV TOWER-1")
    WP3Tower2 = STATIC:FindByName("WP3 TV TOWER-2")
    WP3Tower3 = STATIC:FindByName("WP3 TV TOWER-3")        

    WP1TowerCount = 0
    WP2TowerCount = 0
    WP3TowerCount = 0
    
    if WP1Coa == "Blue" then
      WP1StatusMsg = "WP1: Complete Success - Base is Blue"
    end   
    
    if WP1Coa == "Red" then
    
      if WP1Tower1:IsAlive() == true then 
        WP1TowerCount = WP1TowerCount + 1
      end
      if WP1Tower2:IsAlive() == true then
        WP1TowerCount = WP1TowerCount + 1
      end
      if WP1Tower3:IsAlive() == true then
        WP1TowerCount = WP1TowerCount + 1
      end
      
      if WP1TowerCount == 0 then 
        WP1StatusMsg = "WP1: Complete Failed - Base is Red"
      else            
        WP1StatusMsg = "WP1: " .. WP1TowerCount .. " towers remaining!"
      end
    
    end
    
    
    if WP2Coa == "Blue" then
      WP2StatusMsg = "WP2: Complete Success - Base is Blue"
    end   
    
    if WP2Coa == "Red" then
    
      if WP2Tower1:IsAlive() == true then 
        WP2TowerCount = WP2TowerCount + 1
      end
      if WP2Tower2:IsAlive() == true then
        WP2TowerCount = WP2TowerCount + 1
      end
      if WP2Tower3:IsAlive() == true then
        WP2TowerCount = WP2TowerCount + 1
      end
      
      if WP2TowerCount == 0 then 
        WP2StatusMsg = "WP2: Complete Failed - Base is Red"
      else            
        WP2StatusMsg = "WP2: " .. WP2TowerCount .. " towers remaining!"
      end
    
    end   


    if WP3Coa == "Blue" then
      WP3StatusMsg = "WP3: Complete Success - Base is Blue"
    end   
    
    if WP3Coa == "Red" then
    
      if WP3Tower1:IsAlive() == true then 
        WP3TowerCount = WP3TowerCount + 1
      end
      if WP3Tower2:IsAlive() == true then
        WP3TowerCount = WP3TowerCount + 1
      end
      if WP3Tower3:IsAlive() == true then
        WP3TowerCount = WP3TowerCount + 1
      end
      
      if WP3TowerCount == 0 then 
        WP3StatusMsg = "WP3: Complete Failed - Base is Red"
      else            
        WP3StatusMsg = "WP3: " .. WP3TowerCount .. " towers remaining!"
      end
    
    end  
    
  
    MissionStatusMsg = MESSAGE:New(
       "\n\n" .. 
       "\n" .. WP1StatusMsg ..
       "\n" .. WP2StatusMsg ..  
       "\n" .. WP3StatusMsg .. "\n\n", MsgTime, "[ Mission Status ]", false):ToAll()
  
  end
  