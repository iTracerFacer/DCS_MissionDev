-- Since DCS is dumb, and will let a plane spawn at an airbase it doesn't own...
-- We need to run this once at mission start up. Checks the airbases that are blue and unlocks or relocks 
-- the slots based on coalition. We need to run this right after SlotBlocker.lua so that we unlock only the planes
-- that should be unlocked.


  -- Base Capture Events & Functions
  local CaptureNalchik = AIRBASE:FindByName("Kobuleti")
  local coa = CaptureNalchik:GetCoalition()
  
  if coa == 1 then -- red
    local RadioMessage = MESSAGE:New("Nalchik is Red",5,"[ MISSION SETUP ]", false):ToBlue()
  elseif coa == 2 then -- blue
    local RadioMessage = MESSAGE:New("Enabling Nalchik for NATO",5,"[ MISSION SETUP ]", false):ToBlue()
    -- Disable Red
    trigger.action.setUserFlag("Nalchik-1",100)
    trigger.action.setUserFlag("Nalchik-2",100)
    trigger.action.setUserFlag("Nalchik-3",100)
    trigger.action.setUserFlag("Nalchik-4",100)
    trigger.action.setUserFlag("Nalchik-5",100)     
  end

  local CaptureKolkhi = AIRBASE:FindByName("Senaki-Kolkhi")
  local coa = CaptureKolkhi:GetCoalition()
  
  if coa == 1 then -- red
    local RadioMessage = MESSAGE:New("Kolkhi is Red",5,"[ MISSION SETUP ]", false):ToBlue()
  elseif coa == 2 then -- blue
    local RadioMessage = MESSAGE:New("Enabling Kolkhi for NATO",5,"[ MISSION SETUP ]", false):ToBlue()
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
  
  
  local CaptureKobuleti = AIRBASE:FindByName("Kobuleti")
  local coa = CaptureKobuleti:GetCoalition()
  
  if coa == 1 then -- red
    local RadioMessage = MESSAGE:New("Kobuleti is Red",5,"[ MISSION SETUP ]", false):ToBlue()
  elseif coa == 2 then -- blue
    local RadioMessage = MESSAGE:New("Enabling Kobuleti for NATO",5,"[ MISSION SETUP ]", false):ToBlue()
    trigger.action.setUserFlag("KOBULETI-MI8-1",0)
    trigger.action.setUserFlag("KOBULETI-MI8-2",0)
    trigger.action.setUserFlag("KOBULETI-UH1-1",0)
    trigger.action.setUserFlag("KOBULETI-UH1-2",0)
  end
  
  
  
  local CaptureMaykop = AIRBASE:FindByName("Maykop-Khanskaya")
  local coa = CaptureMaykop:GetCoalition()
  
  if coa == 1 then -- red
    local RadioMessage = MESSAGE:New("Maykop is Red",5,"[ MISSION SETUP ]", false):ToBlue()
  elseif coa == 2 then -- blue
    local RadioMessage = MESSAGE:New("Enabling Maykop for NATO",5,"[ MISSION SETUP ]", false):ToBlue()
    trigger.action.setUserFlag("Maykop-1",0)
    trigger.action.setUserFlag("Maykop-2",0)
    trigger.action.setUserFlag("Maykop-3",0)
    trigger.action.setUserFlag("Maykop-4",0)
    trigger.action.setUserFlag("Maykop-5",0)
    trigger.action.setUserFlag("Maykop-6",0)  
  end
  
  
  local CaptureVody = AIRBASE:FindByName("Mineralnye Vody") 
  local coa = CaptureVody:GetCoalition()
  
  if coa == 1 then -- red
    local RadioMessage = MESSAGE:New("Vody is Red",5,"[ MISSION SETUP ]", false):ToBlue()
  elseif coa == 2 then -- blue
    local RadioMessage = MESSAGE:New("Enabling Vody for NATO",5,"[ MISSION SETUP ]", false):ToBlue()
    --Enable Blue
    trigger.action.setUserFlag("Vody-1",0)
    trigger.action.setUserFlag("Vody-2",0)
    trigger.action.setUserFlag("Vody-3",0)
    trigger.action.setUserFlag("Vody-4",0)
    trigger.action.setUserFlag("Vody-5",0)
    trigger.action.setUserFlag("Vody-6",0)
    trigger.action.setUserFlag("Vody-7",0)
    trigger.action.setUserFlag("Vody-8",0)
    
    --Dsiable Red
    trigger.action.setUserFlag("Vody-9",100)
    trigger.action.setUserFlag("Vody-10",100)
    trigger.action.setUserFlag("Vody-11",100)

  end
  
  
  -- Sukhumi
  CaptureSukhumi = AIRBASE:FindByName("Sukhumi-Babushara")
  local coa = CaptureSukhumi:GetCoalition()

  -- To a specific coalition.       
  if coa == 1 then -- red
    local RadioMessage = MESSAGE:New("Sukhumi is Red",5,"[ MISSION SETUP ]", false):ToBlue()
  elseif coa == 2 then -- blue
    local RadioMessage = MESSAGE:New("Enabling Sukhumi for NATO",5,"[ MISSION SETUP ]", false):ToBlue()
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
  end    
  
  -- Gudauta
  CaptureGudauta = AIRBASE:FindByName("Gudauta")
  local coa = CaptureGudauta:GetCoalition()
  if coa == 1 then -- red
    local RadioMessage = MESSAGE:New("Gudauta is Red",5,"[ MISSION SETUP ]", false):ToBlue()
  elseif coa == 2 then -- blue
  --Enable Blue
    local RadioMessage = MESSAGE:New("Enabling Gudauta for NATO",5,"[ MISSION SETUP ]", false):ToBlue()
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
  
  
  -- Sochi
  CaptureSochi = AIRBASE:FindByName("Sochi-Adler")
  local coa = CaptureSochi:GetCoalition()
  if coa == 1 then -- red
    local RadioMessage = MESSAGE:New("Sochi is Red",5,"[ MISSION SETUP ]", false):ToBlue()
  elseif coa == 2 then -- blue
    local RadioMessage = MESSAGE:New("Enabling Sochi for NATO",5,"[ MISSION SETUP ]", false):ToBlue()
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
    
    --Disable Red

    trigger.action.setUserFlag("Sochi-9",100)
    trigger.action.setUserFlag("Sochi-10",100)
    trigger.action.setUserFlag("Sochi-11",100)
    
  end   
  
  
  
  -- Batumi
  CaptureBatumi = AIRBASE:FindByName("Batumi")
  local coa = CaptureBatumi:GetCoalition()
  if coa == 1 then -- red
    local RadioMessage = MESSAGE:New("Batumi is Red",5,"[ MISSION SETUP ]", false):ToBlue()
  elseif coa == 2 then -- blue
    local RadioMessage = MESSAGE:New("Enabling Batumi for NATO",5,"[ MISSION SETUP ]", false):ToBlue()
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
    
    --Block Red Planes

    trigger.action.setUserFlag("Batumi-5",100)
    trigger.action.setUserFlag("Batumi-6",100)
    
  end    
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  