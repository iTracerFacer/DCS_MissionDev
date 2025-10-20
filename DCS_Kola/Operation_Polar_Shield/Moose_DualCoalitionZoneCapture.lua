-- Setup Capture Missions & Zones 
-- Refactored version with configurable zone ownership

-- ==========================================
-- ZONE CONFIGURATION
-- ==========================================
-- Mission makers: Edit this table to define zones and their initial ownership
-- Just list the zone names under RED, BLUE, or NEUTRAL coalition
-- The script will automatically create and configure all zones

local ZONE_CONFIG = {
  -- Zones that start under RED coalition control
  RED = {
    "Kilpyavr",
    "Severomorsk-1",
    "Severomorsk-3",
    "Murmansk International",
    "Monchegorsk",
    "Olenya",
    "Afrikanda",
    "The Mountain",
    "The River",
    "The Gulf",
    "The Lakes"
  },
  
  -- Zones that start under BLUE coalition control
  BLUE = {
    -- Add zone names here for BLUE starting zones
    -- Example: "Banak", "Kirkenes"
  },
  
  -- Zones that start neutral (empty/uncontrolled)
  NEUTRAL = {
    -- Add zone names here for neutral starting zones
    -- Example: "Contested Valley"
  }
}

-- Advanced settings (usually don't need to change these)
local ZONE_SETTINGS = {
  guardDelay = 1,        -- Delay before entering Guard state after capture
  scanInterval = 30,     -- How often to scan for units in the zone (seconds)
  captureScore = 200     -- Points awarded for capturing a zone
}

-- ==========================================
-- END OF CONFIGURATION
-- ==========================================


-- Setup BLUE Missions 
do -- BLUE Mission
  
  US_Mission_Capture_Airfields = MISSION:New( US_CC, "Capture the Airfields", "Primary",
    "Capture the Air Bases marked on your F10 map.\n" ..
    "Destroy enemy ground forces in the surrounding area, " ..
    "then occupy each capture zone with a platoon.\n " .. 
    "Your orders are to hold position until all capture zones are taken.\n" ..
    "Use the map (F10) for a clear indication of the location of each capture zone.\n" ..
    "Note that heavy resistance can be expected at the airbases!\n"
    , coalition.side.BLUE)
    
  --US_Score = SCORING:New( "Capture Airfields" )
    
  --US_Mission_Capture_Airfields:AddScoring( US_Score )
  
  US_Mission_Capture_Airfields:Start()

end

-- Setup RED Missions
do -- RED Mission
  
  RU_Mission_Capture_Airfields = MISSION:New( RU_CC, "Defend the Motherland", "Primary",
    "Defend Russian airfields and recapture lost territory.\n" ..
    "Eliminate enemy forces in capture zones and " ..
    "maintain control with ground units.\n" .. 
    "Your orders are to prevent the enemy from capturing all strategic zones.\n" ..
    "Use the map (F10) for a clear indication of the location of each capture zone.\n" ..
    "Expect heavy NATO resistance!\n"
    , coalition.side.RED)
    
  --RU_Score = SCORING:New( "Defend Territory" )
    
  --RU_Mission_Capture_Airfields:AddScoring( RU_Score )
  
  RU_Mission_Capture_Airfields:Start()

end


-- Logging configuration: toggle logging behavior for this module
-- Set `CAPTURE_ZONE_LOGGING.enabled = false` to silence module logs
if not CAPTURE_ZONE_LOGGING then
  CAPTURE_ZONE_LOGGING = { enabled = true, prefix = "[CAPTURE Module]" }
end

local function log(message, detailed)
  if CAPTURE_ZONE_LOGGING.enabled then
    -- Preserve the previous prefixing used across the module
    if CAPTURE_ZONE_LOGGING.prefix then
      env.info(tostring(CAPTURE_ZONE_LOGGING.prefix) .. " " .. tostring(message))
    else
      env.info(tostring(message))
    end
  end
end


-- ==========================================
-- ZONE INITIALIZATION SYSTEM
-- ==========================================

-- Storage for all zone capture objects and metadata
local zoneCaptureObjects = {}
local zoneNames = {}
local zoneMetadata = {} -- Stores coalition ownership info

-- Function to initialize all zones from configuration
local function InitializeZones()
  log("[INIT] Starting zone initialization from configuration...")
  
  local totalZones = 0
  
  -- Process each coalition's zones
  for coalitionName, zones in pairs(ZONE_CONFIG) do
    local coalitionSide = nil
    
    -- Map coalition name to DCS coalition constant
    if coalitionName == "RED" then
      coalitionSide = coalition.side.RED
    elseif coalitionName == "BLUE" then
      coalitionSide = coalition.side.BLUE
    elseif coalitionName == "NEUTRAL" then
      coalitionSide = coalition.side.NEUTRAL
    else
      log(string.format("[INIT] WARNING: Unknown coalition '%s' in ZONE_CONFIG", coalitionName))
    end
    
    if coalitionSide then
      for _, zoneName in ipairs(zones) do
        log(string.format("[INIT] Creating zone: %s (Coalition: %s)", zoneName, coalitionName))
        
        -- Create the MOOSE zone object
        local zone = ZONE:New("Capture " .. zoneName)
        
        if zone then
          -- Create the zone capture coalition object
          local zoneCapture = ZONE_CAPTURE_COALITION:New(zone, coalitionSide)
          
          if zoneCapture then
            -- Configure the zone
            zoneCapture:__Guard(ZONE_SETTINGS.guardDelay)
            zoneCapture:Start(ZONE_SETTINGS.scanInterval, ZONE_SETTINGS.scanInterval)
            
            -- Store in our data structures
            table.insert(zoneCaptureObjects, zoneCapture)
            table.insert(zoneNames, zoneName)
            zoneMetadata[zoneName] = {
              coalition = coalitionSide,
              index = #zoneCaptureObjects
            }
            
            totalZones = totalZones + 1
            log(string.format("[INIT] ✓ Zone '%s' initialized successfully", zoneName))
          else
            log(string.format("[INIT] ✗ ERROR: Failed to create ZONE_CAPTURE_COALITION for '%s'", zoneName))
          end
        else
          log(string.format("[INIT] ✗ ERROR: Zone 'Capture %s' not found in mission editor!", zoneName))
          log(string.format("[INIT]    Make sure you have a trigger zone named: 'Capture %s'", zoneName))
        end
      end
    end
  end
  
  log(string.format("[INIT] Zone initialization complete. Total zones created: %d", totalZones))
  return totalZones
end

-- Initialize all zones
local totalZones = InitializeZones()


-- Helper functions for tactical information

-- Global cached unit set - created once and maintained automatically by MOOSE
local CachedUnitSet = nil

-- Initialize the cached unit set once
local function InitializeCachedUnitSet()
  if not CachedUnitSet then
    CachedUnitSet = SET_UNIT:New()
      :FilterCategories({"ground", "plane", "helicopter"}) -- Only scan relevant unit types
      :FilterOnce() -- Don't filter continuously, we'll use the live set
    log("[PERFORMANCE] Initialized cached unit set for zone scanning")
  end
end

local function GetZoneForceStrengths(ZoneCapture)
  local zone = ZoneCapture:GetZone()
  if not zone then return {red = 0, blue = 0, neutral = 0} end
  
  local redCount = 0
  local blueCount = 0  
  local neutralCount = 0
  
  -- Get all units in the zone using MOOSE's zone scanning
  local unitsInZone = SET_UNIT:New()
    :FilterZones({zone})
    :FilterOnce()
  
  if unitsInZone then
    unitsInZone:ForEachUnit(function(unit)
      if unit and unit:IsAlive() then
        local unitCoalition = unit:GetCoalition()
        if unitCoalition == coalition.side.RED then
          redCount = redCount + 1
        elseif unitCoalition == coalition.side.BLUE then
          blueCount = blueCount + 1
        elseif unitCoalition == coalition.side.NEUTRAL then
          neutralCount = neutralCount + 1
        end
      end
    end)
  end
  
  log(string.format("[TACTICAL] Zone %s scan result: R:%d B:%d N:%d", 
    ZoneCapture:GetZoneName(), redCount, blueCount, neutralCount))
  
  return {
    red = redCount,
    blue = blueCount,
    neutral = neutralCount
  }
end

local function GetEnemyUnitMGRSCoords(ZoneCapture, enemyCoalition)
  local zone = ZoneCapture:GetZone()
  if not zone then return {} end
  
  local coords = {}
  
  -- Get all units in the zone using MOOSE's zone scanning
  local unitsInZone = SET_UNIT:New()
    :FilterZones({zone})
    :FilterOnce()
  
  local totalUnits = 0
  local enemyUnits = 0
  local unitsWithCoords = 0
  
  if unitsInZone then
    unitsInZone:ForEachUnit(function(unit)
      totalUnits = totalUnits + 1
      if unit and unit:IsAlive() then
        local unitCoalition = unit:GetCoalition()
        
        -- Process units of the specified enemy coalition
        if unitCoalition == enemyCoalition then
          enemyUnits = enemyUnits + 1
          local coord = unit:GetCoordinate()
          
          if coord then
            -- Try multiple methods to get coordinates
            local mgrs = nil
            local success_mgrs = false
            
            -- Method 1: Try ToStringMGRS
            success_mgrs, mgrs = pcall(function()
              return coord:ToStringMGRS(5)
            end)
            
            -- Method 2: Try ToStringMGRS without precision parameter
            if not success_mgrs or not mgrs then
              success_mgrs, mgrs = pcall(function()
                return coord:ToStringMGRS()
              end)
            end
            
            -- Method 3: Try ToMGRS
            if not success_mgrs or not mgrs then
              success_mgrs, mgrs = pcall(function()
                return coord:ToMGRS()
              end)
            end
            
            -- Method 4: Fallback to Lat/Long
            if not success_mgrs or not mgrs then
              success_mgrs, mgrs = pcall(function()
                local lat, lon = coord:GetLLDDM()
                return string.format("N%s E%s", lat, lon)
              end)
            end
        
            if success_mgrs and mgrs then
              unitsWithCoords = unitsWithCoords + 1
              local unitType = unit:GetTypeName() or "Unknown"
              table.insert(coords, {
                name = unit:GetName(),
                type = unitType,
                mgrs = mgrs
              })
            else
              log(string.format("[TACTICAL DEBUG] All coordinate methods failed for unit %s", unit:GetName() or "unknown"))
            end
          else
            log(string.format("[TACTICAL DEBUG] No coordinate for unit %s", unit:GetName() or "unknown"))
          end
        end
      end
    end)
  end
  
  log(string.format("[TACTICAL DEBUG] %s - Total units scanned: %d, Enemy units: %d, units with MGRS: %d", 
    ZoneCapture:GetZoneName(), totalUnits, enemyUnits, unitsWithCoords))
  
  log(string.format("[TACTICAL] Found %d enemy units with coordinates in %s", 
    #coords, ZoneCapture:GetZoneName()))
  
  return coords
end

local function CreateTacticalInfoMarker(ZoneCapture)
  local zone = ZoneCapture:GetZone() 
  if not zone then return end
  
  local forces = GetZoneForceStrengths(ZoneCapture)
  local zoneName = ZoneCapture:GetZoneName()
  local zoneCoalition = ZoneCapture:GetCoalition()
  
  -- Build tactical info text  
  local tacticalText = string.format("TACTICAL: %s\nForces: R:%d B:%d", 
    zoneName, forces.red, forces.blue)
  
  if forces.neutral > 0 then
    tacticalText = tacticalText .. string.format(" C:%d", forces.neutral)
  end
  
  -- Determine enemy coalition based on zone ownership
  local enemyCoalition = nil
  if zoneCoalition == coalition.side.BLUE then
    enemyCoalition = coalition.side.RED
  elseif zoneCoalition == coalition.side.RED then
    enemyCoalition = coalition.side.BLUE
  end
  
  -- Add MGRS coordinates if enemy forces <= 10
  if enemyCoalition then
    local enemyCount = (enemyCoalition == coalition.side.RED) and forces.red or forces.blue
    
    if enemyCount > 0 and enemyCount <= 10 then
      local enemyCoords = GetEnemyUnitMGRSCoords(ZoneCapture, enemyCoalition)
      log(string.format("[TACTICAL DEBUG] Building marker text for %d enemy units", #enemyCoords))
      if #enemyCoords > 0 then
        tacticalText = tacticalText .. "\nTGTS:"
        for i, unit in ipairs(enemyCoords) do
          if i <= 10 then -- Show up to 10 units (the threshold)
            -- Shorten unit type names to fit better
            local shortType = unit.type:gsub("^%w+%-", ""):gsub("%s.*", "")
            -- Clean up MGRS string - remove "MGRS " prefix and compress spacing
            local cleanMgrs = unit.mgrs:gsub("^MGRS%s+", ""):gsub("%s+", " ")
            -- Ultra-compact: comma-separated on same line
            if i == 1 then
              tacticalText = tacticalText .. string.format(" %s@%s", shortType, cleanMgrs)
            else
              tacticalText = tacticalText .. string.format(", %s@%s", shortType, cleanMgrs)
            end
            log(string.format("[TACTICAL DEBUG] Added unit %d: %s at %s", i, shortType, cleanMgrs))
          end
        end
        if #enemyCoords > 10 then
          tacticalText = tacticalText .. string.format(" (+%d)", #enemyCoords - 10)
        end
      end
    end
  end
  
  -- Debug: Log the complete marker text that will be displayed
  log(string.format("[TACTICAL DEBUG] Complete marker text for %s:\n%s", zoneName, tacticalText))
  log(string.format("[TACTICAL DEBUG] Marker text length: %d characters", string.len(tacticalText)))
  
  -- Create tactical marker offset from zone center
  local coord = zone:GetCoordinate()
  if coord then
    -- Offset the tactical marker slightly northeast of the main zone marker
    local offsetCoord = coord:Translate(200, 45) -- 200m northeast
    
    -- Remove any existing tactical marker first
    if ZoneCapture.TacticalMarkerID then
      log(string.format("[TACTICAL] Removing old marker ID %d for %s", ZoneCapture.TacticalMarkerID, zoneName))
      -- Try multiple removal methods
      local success1 = pcall(function()
        offsetCoord:RemoveMark(ZoneCapture.TacticalMarkerID)
      end)
      if not success1 then
        local success2 = pcall(function()
          trigger.action.removeMark(ZoneCapture.TacticalMarkerID)
        end)
        if not success2 then
          -- Try using coordinate removal
          pcall(function()
            coord:RemoveMark(ZoneCapture.TacticalMarkerID)
          end)
        end
      end
      ZoneCapture.TacticalMarkerID = nil
    end
    
    -- Create tactical markers for BOTH coalitions
    -- Each coalition sees their enemies marked
    
    -- BLUE Coalition Marker
    if ZoneCapture.TacticalMarkerID_BLUE then
      log(string.format("[TACTICAL] Removing old BLUE marker ID %d for %s", ZoneCapture.TacticalMarkerID_BLUE, zoneName))
      pcall(function()
        offsetCoord:RemoveMark(ZoneCapture.TacticalMarkerID_BLUE)
      end)
      ZoneCapture.TacticalMarkerID_BLUE = nil
    end
    
    local successBlue, markerIDBlue = pcall(function()
      return offsetCoord:MarkToCoalition(tacticalText, coalition.side.BLUE)
    end)
    
    if successBlue and markerIDBlue then
      ZoneCapture.TacticalMarkerID_BLUE = markerIDBlue
      pcall(function()
        offsetCoord:SetMarkReadOnly(markerIDBlue, true)
      end)
      log(string.format("[TACTICAL] Created BLUE marker for %s", zoneName))
    else
      log(string.format("[TACTICAL] Failed to create BLUE marker for %s", zoneName))
    end
    
    -- RED Coalition Marker  
    if ZoneCapture.TacticalMarkerID_RED then
      log(string.format("[TACTICAL] Removing old RED marker ID %d for %s", ZoneCapture.TacticalMarkerID_RED, zoneName))
      pcall(function()
        offsetCoord:RemoveMark(ZoneCapture.TacticalMarkerID_RED)
      end)
      ZoneCapture.TacticalMarkerID_RED = nil
    end
    
    local successRed, markerIDRed = pcall(function()
      return offsetCoord:MarkToCoalition(tacticalText, coalition.side.RED)
    end)
    
    if successRed and markerIDRed then
      ZoneCapture.TacticalMarkerID_RED = markerIDRed
      pcall(function()
        offsetCoord:SetMarkReadOnly(markerIDRed, true)
      end)
      log(string.format("[TACTICAL] Created RED marker for %s", zoneName))
    else
      log(string.format("[TACTICAL] Failed to create RED marker for %s", zoneName))
    end
  end
end

-- Event handler functions - define them separately for each zone
local function OnEnterGuarded(ZoneCapture, From, Event, To)
  if From ~= To then
    local Coalition = ZoneCapture:GetCoalition()
    if Coalition == coalition.side.BLUE then
      ZoneCapture:Smoke( SMOKECOLOR.Blue )
      -- Update zone visual markers to BLUE
      ZoneCapture:UndrawZone()
      ZoneCapture:DrawZone(-1, {0, 0, 1}, 0.5, {0, 0, 1}, 0.2, 2, true) -- Blue zone boundary
      US_CC:MessageTypeToCoalition( string.format( "%s is under protection of the USA", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
      RU_CC:MessageTypeToCoalition( string.format( "%s is under protection of the USA", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
    else
      ZoneCapture:Smoke( SMOKECOLOR.Red )
      -- Update zone visual markers to RED
      ZoneCapture:UndrawZone()
      ZoneCapture:DrawZone(-1, {1, 0, 0}, 0.5, {1, 0, 0}, 0.2, 2, true) -- Red zone boundary
      RU_CC:MessageTypeToCoalition( string.format( "%s is under protection of Russia", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
      US_CC:MessageTypeToCoalition( string.format( "%s is under protection of Russia", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
    end
    -- Create/update tactical information marker
    CreateTacticalInfoMarker(ZoneCapture)
  end
end

local function OnEnterEmpty(ZoneCapture)
  ZoneCapture:Smoke( SMOKECOLOR.Green )
  -- Update zone visual markers to GREEN (neutral)
  ZoneCapture:UndrawZone()
  ZoneCapture:DrawZone(-1, {0, 1, 0}, 0.5, {0, 1, 0}, 0.2, 2, true) -- Green zone boundary
  US_CC:MessageTypeToCoalition( string.format( "%s is unprotected, and can be captured!", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
  RU_CC:MessageTypeToCoalition( string.format( "%s is unprotected, and can be captured!", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
  -- Create/update tactical information marker
  CreateTacticalInfoMarker(ZoneCapture)
end

local function OnEnterAttacked(ZoneCapture)
  ZoneCapture:Smoke( SMOKECOLOR.White )
  -- Update zone visual markers to ORANGE (contested)
  ZoneCapture:UndrawZone()
  ZoneCapture:DrawZone(-1, {1, 0.5, 0}, 0.5, {1, 0.5, 0}, 0.2, 2, true) -- Orange zone boundary for contested
  local Coalition = ZoneCapture:GetCoalition()
  if Coalition == coalition.side.BLUE then
    US_CC:MessageTypeToCoalition( string.format( "%s is under attack by Russia", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
    RU_CC:MessageTypeToCoalition( string.format( "We are attacking %s", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
  else
    RU_CC:MessageTypeToCoalition( string.format( "%s is under attack by the USA", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
    US_CC:MessageTypeToCoalition( string.format( "We are attacking %s", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
  end
  -- Create/update tactical information marker
  CreateTacticalInfoMarker(ZoneCapture)
end

-- Victory condition monitoring for BOTH coalitions
local function CheckVictoryCondition()
  local blueZonesCount = 0
  local redZonesCount = 0
  local totalZones = #zoneCaptureObjects
  
  for i, zoneCapture in ipairs(zoneCaptureObjects) do
    if zoneCapture then
      local zoneCoalition = zoneCapture:GetCoalition()
      if zoneCoalition == coalition.side.BLUE then
        blueZonesCount = blueZonesCount + 1
      elseif zoneCoalition == coalition.side.RED then
        redZonesCount = redZonesCount + 1
      end
    end
  end
  
  log(string.format("[VICTORY CHECK] Blue owns %d/%d zones, Red owns %d/%d zones", 
    blueZonesCount, totalZones, redZonesCount, totalZones))
  
  -- Check for BLUE victory
  if blueZonesCount >= totalZones then
    log("[VICTORY] All zones captured by BLUE! Triggering victory sequence...")
    
    US_CC:MessageTypeToCoalition( 
      "VICTORY! All capture zones have been secured by coalition forces!\n\n" ..
      "Operation Polar Shield is complete. Outstanding work!\n" ..
      "Mission will end in 60 seconds.", 
      MESSAGE.Type.Information, 30 
    )
    
    RU_CC:MessageTypeToCoalition( 
      "DEFEAT! All strategic positions have been lost to coalition forces.\n\n" ..
      "Operation Polar Shield has failed. Mission ending in 60 seconds.", 
      MESSAGE.Type.Information, 30 
    )
    
    -- Add victory celebration effects
    for _, zoneCapture in ipairs(zoneCaptureObjects) do
      if zoneCapture then
        zoneCapture:Smoke( SMOKECOLOR.Blue )
        local zone = zoneCapture:GetZone()
        if zone then
          zone:FlareZone( FLARECOLOR.Blue, 90, 60 )
        end
      end
    end
    
    SCHEDULER:New( nil, function()
      log("[VICTORY] Ending mission due to complete zone capture by BLUE")
      trigger.action.setUserFlag("BLUE_VICTORY", 1)
      
      US_CC:MessageTypeToCoalition( 
        string.format("Mission Complete! Congratulations on your victory!\nFinal Status: All %d strategic zones secured.", totalZones), 
        MESSAGE.Type.Information, 10 
      )
    end, {}, 60 )
    
    return true
  end
  
  -- Check for RED victory
  if redZonesCount >= totalZones then
    log("[VICTORY] All zones captured by RED! Triggering victory sequence...")
    
    RU_CC:MessageTypeToCoalition( 
      "VICTORY! All strategic positions secured for the Motherland!\n\n" ..
      "NATO forces have been repelled. Outstanding work!\n" ..
      "Mission will end in 60 seconds.", 
      MESSAGE.Type.Information, 30 
    )
    
    US_CC:MessageTypeToCoalition( 
      "DEFEAT! All capture zones have been lost to Russian forces.\n\n" ..
      "Operation Polar Shield has failed. Mission ending in 60 seconds.", 
      MESSAGE.Type.Information, 30 
    )
    
    -- Add victory celebration effects
    for _, zoneCapture in ipairs(zoneCaptureObjects) do
      if zoneCapture then
        zoneCapture:Smoke( SMOKECOLOR.Red )
        local zone = zoneCapture:GetZone()
        if zone then
          zone:FlareZone( FLARECOLOR.Red, 90, 60 )
        end
      end
    end
    
    SCHEDULER:New( nil, function()
      log("[VICTORY] Ending mission due to complete zone capture by RED")
      trigger.action.setUserFlag("RED_VICTORY", 1)
      
      RU_CC:MessageTypeToCoalition( 
        string.format("Mission Complete! Congratulations on your victory!\nFinal Status: All %d strategic zones secured.", totalZones), 
        MESSAGE.Type.Information, 10 
      )
    end, {}, 60 )
    
    return true
  end
  
  return false -- Victory not yet achieved by either side
end

local function OnEnterCaptured(ZoneCapture)
  local Coalition = ZoneCapture:GetCoalition()
  if Coalition == coalition.side.BLUE then
    -- Update zone visual markers to BLUE for captured
    ZoneCapture:UndrawZone()
    ZoneCapture:DrawZone(-1, {0, 0, 1}, 0.5, {0, 0, 1}, 0.2, 2, true) -- Blue zone boundary
    RU_CC:MessageTypeToCoalition( string.format( "%s is captured by the USA, we lost it!", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
    US_CC:MessageTypeToCoalition( string.format( "We captured %s, Excellent job!", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
  else
    -- Update zone visual markers to RED for captured
    ZoneCapture:UndrawZone()
    ZoneCapture:DrawZone(-1, {1, 0, 0}, 0.5, {1, 0, 0}, 0.2, 2, true) -- Red zone boundary
    US_CC:MessageTypeToCoalition( string.format( "%s is captured by Russia, we lost it!", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
    RU_CC:MessageTypeToCoalition( string.format( "We captured %s, Excellent job!", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
  end
  
  ZoneCapture:AddScore( "Captured", "Zone captured: Extra points granted.", ZONE_SETTINGS.captureScore )    
  ZoneCapture:__Guard( 30 )
  
  -- Create/update tactical information marker
  CreateTacticalInfoMarker(ZoneCapture)
  
  -- Check victory condition after any zone capture
  CheckVictoryCondition()
end

-- Set up event handlers for each zone with proper MOOSE methods and debugging
for i, zoneCapture in ipairs(zoneCaptureObjects) do
  if zoneCapture then
    local zoneName = zoneNames[i] or ("Zone " .. i)
    
    -- Proper MOOSE event handlers for ZONE_CAPTURE_COALITION
    zoneCapture.OnEnterGuarded = OnEnterGuarded
    zoneCapture.OnEnterEmpty = OnEnterEmpty  
    zoneCapture.OnEnterAttacked = OnEnterAttacked
    zoneCapture.OnEnterCaptured = OnEnterCaptured
    
    -- Debug: Check if the underlying zone exists
    local success, zone = pcall(function() return zoneCapture:GetZone() end)
    if success and zone then
      log("✓ Zone 'Capture " .. zoneName .. "' successfully created and linked")
      
      -- Get initial coalition color for this zone
      local initialCoalition = zoneCapture:GetCoalition()
      local colorRGB = {0, 1, 0} -- Default green for neutral
      
      if initialCoalition == coalition.side.RED then
        colorRGB = {1, 0, 0} -- Red
      elseif initialCoalition == coalition.side.BLUE then
        colorRGB = {0, 0, 1} -- Blue
      end
      
      -- Initialize zone borders with appropriate initial color
      local drawSuccess, drawError = pcall(function()
        zone:DrawZone(-1, colorRGB, 0.5, colorRGB, 0.2, 2, true)
      end)
      
      if not drawSuccess then
        log("⚠ Zone 'Capture " .. zoneName .. "' border drawing failed: " .. tostring(drawError))
        -- Alternative: Try simpler zone marking
        pcall(function()
          if initialCoalition == coalition.side.RED then
            zone:SmokeZone(SMOKECOLOR.Red, 30)
          elseif initialCoalition == coalition.side.BLUE then
            zone:SmokeZone(SMOKECOLOR.Blue, 30)
          else
            zone:SmokeZone(SMOKECOLOR.Green, 30)
          end
        end)
      else
        local coalitionName = "NEUTRAL"
        if initialCoalition == coalition.side.RED then
          coalitionName = "RED"
        elseif initialCoalition == coalition.side.BLUE then
          coalitionName = "BLUE"
        end
        log("✓ Zone 'Capture " .. zoneName .. "' border drawn successfully with " .. coalitionName .. " initial color")
      end
    else
      log("✗ ERROR: Zone 'Capture " .. zoneName .. "' not found in mission editor!")
      log("   Make sure you have a trigger zone named exactly: 'Capture " .. zoneName .. "'")
    end
  else
    log("✗ ERROR: Zone capture object " .. i .. " (" .. (zoneNames[i] or "Unknown") .. ") is nil!")
  end
end

-- ==========================================
-- VICTORY MONITORING SYSTEM
-- ==========================================

-- Function to get current zone ownership status
local function GetZoneOwnershipStatus()
  local status = {
    blue = 0,
    red = 0,
    neutral = 0,
    total = #zoneCaptureObjects,
    zones = {}
  }
  
  -- Explicitly reference the global coalition table to avoid parameter shadowing
  local coalitionTable = _G.coalition or coalition
  
  for i, zoneCapture in ipairs(zoneCaptureObjects) do
    if zoneCapture then
      local zoneCoalition = zoneCapture:GetCoalition()
      local zoneName = zoneNames[i] or ("Zone " .. i)
      
      -- Get the current state of the zone
      local currentState = zoneCapture:GetCurrentState()
      local stateString = ""
      
      -- Determine status based on coalition and state
      if zoneCoalition == coalitionTable.side.BLUE then
        status.blue = status.blue + 1
        if currentState == "Attacked" then
          status.zones[zoneName] = "BLUE (Under Attack)"
        else
          status.zones[zoneName] = "BLUE"
        end
      elseif zoneCoalition == coalitionTable.side.RED then
        status.red = status.red + 1
        if currentState == "Attacked" then
          status.zones[zoneName] = "RED (Under Attack)"
        else
          status.zones[zoneName] = "RED"
        end
      else
        status.neutral = status.neutral + 1
        if currentState == "Attacked" then
          status.zones[zoneName] = "NEUTRAL (Under Attack)"
        else
          status.zones[zoneName] = "NEUTRAL"
        end
      end
    end
  end
  
  return status
end

-- Function to broadcast zone status report to BOTH coalitions
local function BroadcastZoneStatus()
  local status = GetZoneOwnershipStatus()
  
  -- Build coalition-neutral report
  local reportMessage = string.format(
    "ZONE CONTROL REPORT:\n" ..
    "Blue Coalition: %d/%d zones\n" ..
    "Red Coalition: %d/%d zones\n" ..
    "Neutral: %d/%d zones",
    status.blue, status.total,
    status.red, status.total,
    status.neutral, status.total
  )
  
  -- Add detailed zone status
  local detailMessage = "\nZONE DETAILS:\n"
  for zoneName, owner in pairs(status.zones) do
    detailMessage = detailMessage .. string.format("• %s: %s\n", zoneName, owner)
  end
  
  local fullMessage = reportMessage .. detailMessage
  
  -- Broadcast to BOTH coalitions with their specific victory progress
  local blueProgressPercent = math.floor((status.blue / status.total) * 100)
  local blueFullMessage = fullMessage .. string.format("\n\nYour Progress to Victory: %d%%", blueProgressPercent)
  US_CC:MessageTypeToCoalition( blueFullMessage, MESSAGE.Type.Information, 15 )
  
  local redProgressPercent = math.floor((status.red / status.total) * 100)
  local redFullMessage = fullMessage .. string.format("\n\nYour Progress to Victory: %d%%", redProgressPercent)
  RU_CC:MessageTypeToCoalition( redFullMessage, MESSAGE.Type.Information, 15 )
  
  log("[ZONE STATUS] " .. reportMessage:gsub("\n", " | "))
  
  return status
end

-- Periodic zone monitoring (every 5 minutes) for BOTH coalitions
local ZoneMonitorScheduler = SCHEDULER:New( nil, function()
  local status = BroadcastZoneStatus()
  
  -- Check if BLUE is close to victory (80% or more zones captured)
  if status.blue >= math.floor(status.total * 0.8) and status.blue < status.total then
    US_CC:MessageTypeToCoalition( 
      string.format("APPROACHING VICTORY! %d more zone(s) needed for complete success!", 
        status.total - status.blue), 
      MESSAGE.Type.Information, 10 
    )
    
    RU_CC:MessageTypeToCoalition( 
      string.format("CRITICAL SITUATION! Coalition forces control %d/%d zones! We must recapture territory!", 
        status.blue, status.total), 
      MESSAGE.Type.Information, 10 
    )
  end
  
  -- Check if RED is close to victory (80% or more zones captured)
  if status.red >= math.floor(status.total * 0.8) and status.red < status.total then
    RU_CC:MessageTypeToCoalition( 
      string.format("APPROACHING VICTORY! %d more zone(s) needed for complete success!", 
        status.total - status.red), 
      MESSAGE.Type.Information, 10 
    )
    
    US_CC:MessageTypeToCoalition( 
      string.format("CRITICAL SITUATION! Russian forces control %d/%d zones! We must recapture territory!", 
        status.red, status.total), 
      MESSAGE.Type.Information, 10 
    )
  end
  
end, {}, 10, 300 ) -- Start after 10 seconds, repeat every 300 seconds (5 minutes)

-- Periodic zone color verification system (every 2 minutes)
local ZoneColorVerificationScheduler = SCHEDULER:New( nil, function()
  log("[ZONE COLORS] Running periodic zone color verification...")
  
  -- Verify each zone's visual marker matches its CURRENT STATE (not just coalition)
  for i, zoneCapture in ipairs(zoneCaptureObjects) do
    if zoneCapture then
      local zoneCoalition = zoneCapture:GetCoalition()
      local zoneName = zoneNames[i] or ("Zone " .. i)
      local currentState = zoneCapture:GetCurrentState()
      
      -- Force redraw the zone with correct color based on CURRENT STATE
      zoneCapture:UndrawZone()
      
      -- Color priority: State (Attacked/Empty) overrides coalition ownership
      if currentState == "Attacked" then
        -- Orange for contested zones (highest priority)
        zoneCapture:DrawZone(-1, {1, 0.5, 0}, 0.5, {1, 0.5, 0}, 0.2, 2, true)
        log(string.format("[ZONE COLORS] %s: Set to ORANGE (Attacked)", zoneName))
      elseif currentState == "Empty" then
        -- Green for neutral/empty zones
        zoneCapture:DrawZone(-1, {0, 1, 0}, 0.5, {0, 1, 0}, 0.2, 2, true)
        log(string.format("[ZONE COLORS] %s: Set to GREEN (Empty)", zoneName))
      elseif zoneCoalition == coalition.side.BLUE then
        -- Blue for BLUE-owned zones (Guarded or Captured state)
        zoneCapture:DrawZone(-1, {0, 0, 1}, 0.5, {0, 0, 1}, 0.2, 2, true)
        log(string.format("[ZONE COLORS] %s: Set to BLUE (Owned)", zoneName))
      elseif zoneCoalition == coalition.side.RED then
        -- Red for RED-owned zones (Guarded or Captured state)
        zoneCapture:DrawZone(-1, {1, 0, 0}, 0.5, {1, 0, 0}, 0.2, 2, true)
        log(string.format("[ZONE COLORS] %s: Set to RED (Owned)", zoneName))
      else
        -- Fallback to green for any other state
        zoneCapture:DrawZone(-1, {0, 1, 0}, 0.5, {0, 1, 0}, 0.2, 2, true)
        log(string.format("[ZONE COLORS] %s: Set to GREEN (Fallback)", zoneName))
      end
    end
  end
  
end, {}, 60, 120 ) -- Start after 60 seconds, repeat every 120 seconds (2 minutes)

-- Periodic tactical marker update system (every 1 minute)
local TacticalMarkerUpdateScheduler = SCHEDULER:New( nil, function()
  log("[TACTICAL] Running periodic tactical marker update...")
  
  -- Update tactical markers for all zones
  for i, zoneCapture in ipairs(zoneCaptureObjects) do
    if zoneCapture then
      CreateTacticalInfoMarker(zoneCapture)
    end
  end
  
end, {}, 30, 60 ) -- Start after 30 seconds, repeat every 60 seconds (1 minute)

-- Function to refresh all zone colors based on current ownership
local function RefreshAllZoneColors()
  log("[ZONE COLORS] Refreshing all zone visual markers...")
  
  for i, zoneCapture in ipairs(zoneCaptureObjects) do
    if zoneCapture then
      local zoneCoalition = zoneCapture:GetCoalition()
      local zoneName = zoneNames[i] or ("Zone " .. i)
      local currentState = zoneCapture:GetCurrentState()
      
      -- Clear existing drawings
      zoneCapture:UndrawZone()
      
      -- Redraw with correct color based on CURRENT STATE (priority over coalition)
      if currentState == "Attacked" then
        zoneCapture:DrawZone(-1, {1, 0.5, 0}, 0.5, {1, 0.5, 0}, 0.2, 2, true) -- Orange
        log(string.format("[ZONE COLORS] %s: Set to ORANGE (Attacked)", zoneName))
      elseif currentState == "Empty" then
        zoneCapture:DrawZone(-1, {0, 1, 0}, 0.5, {0, 1, 0}, 0.2, 2, true) -- Green
        log(string.format("[ZONE COLORS] %s: Set to GREEN (Empty)", zoneName))
      elseif zoneCoalition == coalition.side.BLUE then
        zoneCapture:DrawZone(-1, {0, 0, 1}, 0.5, {0, 0, 1}, 0.2, 2, true) -- Blue
        log(string.format("[ZONE COLORS] %s: Set to BLUE (Owned)", zoneName))
      elseif zoneCoalition == coalition.side.RED then
        zoneCapture:DrawZone(-1, {1, 0, 0}, 0.5, {1, 0, 0}, 0.2, 2, true) -- Red
        log(string.format("[ZONE COLORS] %s: Set to RED (Owned)", zoneName))
      else
        zoneCapture:DrawZone(-1, {0, 1, 0}, 0.5, {0, 1, 0}, 0.2, 2, true) -- Green (neutral)
        log(string.format("[ZONE COLORS] %s: Set to NEUTRAL/GREEN (Fallback)", zoneName))
      end
    end
  end
  
  -- Notify BOTH coalitions
  US_CC:MessageTypeToCoalition("Zone visual markers have been refreshed!", MESSAGE.Type.Information, 5)
  RU_CC:MessageTypeToCoalition("Zone visual markers have been refreshed!", MESSAGE.Type.Information, 5)
end

-- Manual zone status commands for players (F10 radio menu) - BOTH COALITIONS
local function SetupZoneStatusCommands()
  -- Add F10 radio menu commands for BLUE coalition
  if US_CC then
    local USMenu = MENU_COALITION:New( coalition.side.BLUE, "Zone Control" )
    MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Get Zone Status Report", USMenu, BroadcastZoneStatus )
    
    MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Check Victory Progress", USMenu, function()
      local status = GetZoneOwnershipStatus()
      local progressPercent = math.floor((status.blue / status.total) * 100)
      
      US_CC:MessageTypeToCoalition( 
        string.format(
          "VICTORY PROGRESS: %d%%\n" ..
          "Zones Captured: %d/%d\n" ..
          "Remaining: %d zones\n\n" ..
          "%s",
          progressPercent,
          status.blue, status.total,
          status.total - status.blue,
          progressPercent >= 100 and "MISSION COMPLETE!" or 
          progressPercent >= 80 and "ALMOST THERE!" or
          progressPercent >= 50 and "GOOD PROGRESS!" or
          "KEEP FIGHTING!"
        ), 
        MESSAGE.Type.Information, 10 
      )
    end )
    
    -- Add command to refresh zone colors (troubleshooting tool)
    MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Refresh Zone Colors", USMenu, RefreshAllZoneColors )
  end
  
  -- Add F10 radio menu commands for RED coalition
  if RU_CC then
    local RUMenu = MENU_COALITION:New( coalition.side.RED, "Zone Control" )
    MENU_COALITION_COMMAND:New( coalition.side.RED, "Get Zone Status Report", RUMenu, BroadcastZoneStatus )
    
    MENU_COALITION_COMMAND:New( coalition.side.RED, "Check Victory Progress", RUMenu, function()
      local status = GetZoneOwnershipStatus()
      local progressPercent = math.floor((status.red / status.total) * 100)
      
      RU_CC:MessageTypeToCoalition( 
        string.format(
          "VICTORY PROGRESS: %d%%\n" ..
          "Zones Captured: %d/%d\n" ..
          "Remaining: %d zones\n\n" ..
          "%s",
          progressPercent,
          status.red, status.total,
          status.total - status.red,
          progressPercent >= 100 and "MISSION COMPLETE!" or 
          progressPercent >= 80 and "ALMOST THERE!" or
          progressPercent >= 50 and "GOOD PROGRESS!" or
          "KEEP FIGHTING!"
        ), 
        MESSAGE.Type.Information, 10 
      )
    end )
    
    -- Add command to refresh zone colors (troubleshooting tool)
    MENU_COALITION_COMMAND:New( coalition.side.RED, "Refresh Zone Colors", RUMenu, RefreshAllZoneColors )
  end
end

-- Initialize zone status monitoring
SCHEDULER:New( nil, function()
  log("[VICTORY SYSTEM] Initializing zone monitoring system...")
  
  -- Initialize performance optimization caches
  InitializeCachedUnitSet()
  
  SetupZoneStatusCommands()
  
  -- Initial status report
  SCHEDULER:New( nil, function()
    log("[VICTORY SYSTEM] Broadcasting initial zone status...")
    BroadcastZoneStatus()
  end, {}, 30 ) -- Initial report after 30 seconds
  
end, {}, 5 ) -- Initialize after 5 seconds

log("[VICTORY SYSTEM] Zone capture victory monitoring system loaded successfully!")
log(string.format("[CONFIG] Loaded %d zones from configuration", totalZones))
