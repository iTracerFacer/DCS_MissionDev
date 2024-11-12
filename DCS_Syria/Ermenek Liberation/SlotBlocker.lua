trigger.action.setUserFlag("SSB",100)

    trigger.action.setUserFlag("GAZIPAS F16-1",0)
    trigger.action.setUserFlag("GAZIPAS F16-2",0)
    trigger.action.setUserFlag("GAZIPAS F16-3",0)
    trigger.action.setUserFlag("GAZIPAS F16-4",0)
    
    trigger.action.setUserFlag("GAZIPAS A10C II-1",0)
    trigger.action.setUserFlag("GAZIPAS A10C II-2",0)
    trigger.action.setUserFlag("GAZIPAS A10C II-3",0)
    trigger.action.setUserFlag("GAZIPAS A10C II-4",0)
    
    trigger.action.setUserFlag("GAZIPAS A10C-1",0)
    trigger.action.setUserFlag("GAZIPAS A10C-2",0)
    trigger.action.setUserFlag("GAZIPAS A10C-3",0)
    trigger.action.setUserFlag("GAZIPAS A10C-4",0)
    
    trigger.action.setUserFlag("GAZIPAS VIGGEN-1",0)
    trigger.action.setUserFlag("GAZIPAS VIGGEN-2",0)
    
    trigger.action.setUserFlag("GAZIPASA JF17-1",100)
    trigger.action.setUserFlag("GAZIPASA JF17-2",100)
    
    
   -- Base Capture Events & Functions
  local CaptureGazipasa = AIRBASE:FindByName("Gazipasa")
  local coa = CaptureGazipasa:GetCoalition()
  
  if coa == 1 then -- red
    local RadioMessage = MESSAGE:New("Gazipasa is Red",5,"[ MISSION SETUP ]", false):ToBlue()

    trigger.action.setUserFlag("GAZIPAS F16-1",0)
    trigger.action.setUserFlag("GAZIPAS F16-2",0)
    trigger.action.setUserFlag("GAZIPAS F16-3",0)
    trigger.action.setUserFlag("GAZIPAS F16-4",0)
    
    trigger.action.setUserFlag("GAZIPAS A10C II-1",0)
    trigger.action.setUserFlag("GAZIPAS A10C II-2",0)
    trigger.action.setUserFlag("GAZIPAS A10C II-3",0)
    trigger.action.setUserFlag("GAZIPAS A10C II-4",0)
    
    trigger.action.setUserFlag("GAZIPAS A10C-1",0)
    trigger.action.setUserFlag("GAZIPAS A10C-2",0)
    trigger.action.setUserFlag("GAZIPAS A10C-3",0)
    trigger.action.setUserFlag("GAZIPAS A10C-4",0)
    
    trigger.action.setUserFlag("GAZIPAS VIGGEN-1",0)
    trigger.action.setUserFlag("GAZIPAS VIGGEN-2",0)
    
    trigger.action.setUserFlag("GAZIPASA JF17-1",100)
    trigger.action.setUserFlag("GAZIPASA JF17-2",100)
 
    
  
  elseif coa == 2 then -- blue
    local RadioMessage = MESSAGE:New("Enabling Gazipasa for NATO",5,"[ MISSION SETUP ]", false):ToBlue()
    -- Disable Red

    trigger.action.setUserFlag("GAZIPAS F16-1",100)
    trigger.action.setUserFlag("GAZIPAS F16-2",100)
    trigger.action.setUserFlag("GAZIPAS F16-3",100)
    trigger.action.setUserFlag("GAZIPAS F16-4",100)
    
    trigger.action.setUserFlag("GAZIPAS A10C II-1",100)
    trigger.action.setUserFlag("GAZIPAS A10C II-2",100)
    trigger.action.setUserFlag("GAZIPAS A10C II-3",100)
    trigger.action.setUserFlag("GAZIPAS A10C II-4",100)
    
    trigger.action.setUserFlag("GAZIPAS A10C-1",100)
    trigger.action.setUserFlag("GAZIPAS A10C-2",100)
    trigger.action.setUserFlag("GAZIPAS A10C-3",100)
    trigger.action.setUserFlag("GAZIPAS A10C-4",100)
    
    trigger.action.setUserFlag("GAZIPAS VIGGEN-1",100)
    trigger.action.setUserFlag("GAZIPAS VIGGEN-2",100)
    
    trigger.action.setUserFlag("GAZIPASA JF17-1",0)
    trigger.action.setUserFlag("GAZIPASA JF17-2",0)
    
    
       
 
  end



