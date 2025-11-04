-- Setup Capture Missions & Zones 

-- ================================================================================
-- ZONE COLOR CONFIGURATION
-- Mission makers can easily customize zone colors here
-- Colors are in RGB format: {Red, Green, Blue} where each value is 0.0 to 1.0
-- ================================================================================
local ZONE_COLORS = {
  -- Blue coalition zones
  BLUE_CAPTURED = {0, 0, 1},        -- Blue (owned by Blue)
  BLUE_ATTACKED = {0, 1, 1},        -- Cyan (owned by Blue, under attack)
  
  -- Red coalition zones  
  RED_CAPTURED = {1, 0, 0},         -- Red (owned by Red)
  RED_ATTACKED = {1, 0.5, 0},       -- Orange (owned by Red, under attack)
  
  -- Neutral/Empty zones
  EMPTY = {0, 1, 0}                 -- Green (no owner)
}

-- Helper function to get the appropriate color for a zone
local function GetZoneColor(zoneCapture)
  local zoneCoalition = zoneCapture:GetCoalition()
  local state = zoneCapture:GetCurrentState()
  
  -- Priority 1: Check if zone is under attack
  if state == "Attacked" then
    if zoneCoalition == coalition.side.BLUE then
      return ZONE_COLORS.BLUE_ATTACKED
    elseif zoneCoalition == coalition.side.RED then
      return ZONE_COLORS.RED_ATTACKED
    end
  end
  
  -- Priority 2: Check if zone is empty/neutral
  if state == "Empty" then
    return ZONE_COLORS.EMPTY
  end
  
  -- Priority 3: Show ownership color (Guarded or Captured states)
  if zoneCoalition == coalition.side.BLUE then
    return ZONE_COLORS.BLUE_CAPTURED
  elseif zoneCoalition == coalition.side.RED then
    return ZONE_COLORS.RED_CAPTURED
  end
  
  -- Fallback to green
  return ZONE_COLORS.EMPTY
end

-- Setup BLUE Missions 
do -- Missions
  
  US_Mission_Capture_Airfields = MISSION:New( US_CC, "Capture the Airfields", "Primary",
    "Capture the Air Bases marked on your F10 map.\n" ..
    "Destroy enemy ground forces in the surrounding area, " ..
    "then occupy each capture zone with a platoon.\n " .. 
    "Your orders are to hold position until all capture zones are taken.\n" ..
    "Use the map (F10) for a clear indication of the location of each capture zone.\n" ..
    "Note that heavy resistance can be expected at the airbases!\n\n" ..
    "VICTORY CONDITION: Capture ALL 14 strategic zones to achieve total victory.\n" ..
    "CRITICAL: Do NOT lose all three of your starting bases (Luostari Pechenga, Ivalo, Alakurtti) or the mission will be lost!\n"
    , coalition.side.BLUE)
    
  --US_Score = SCORING:New( "Capture Airfields" )
    
  --US_Mission_Capture_Airfields:AddScoring( US_Score )
  
  US_Mission_Capture_Airfields:Start()

end


-- Logging configuration: toggle logging behavior for this module
-- Set `CAPTURE_ZONE_LOGGING.enabled = false` to silence module logs
if not CAPTURE_ZONE_LOGGING then
  CAPTURE_ZONE_LOGGING = { enabled = false, prefix = "[CAPTURE Module]" }
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



-- Red Airbases (from TADC configuration)
log("[DEBUG] Initializing Capture Zone: Kilpyavr")
CaptureZone_Kilpyavr = ZONE:New( "Capture Kilpyavr" )
ZoneCapture_Kilpyavr = ZONE_CAPTURE_COALITION:New( CaptureZone_Kilpyavr, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_Kilpyavr:__Guard( 1 )
ZoneCapture_Kilpyavr:Start( 30, 30 )
log("[DEBUG] Kilpyavr zone initialization complete")

log("[DEBUG] Initializing Capture Zone: Severomorsk-1")
CaptureZone_Severomorsk_1 = ZONE:New( "Capture Severomorsk-1" )
ZoneCapture_Severomorsk_1 = ZONE_CAPTURE_COALITION:New( CaptureZone_Severomorsk_1, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_Severomorsk_1:__Guard( 1 )
ZoneCapture_Severomorsk_1:Start( 30, 30 )
log("[DEBUG] Severomorsk-1 zone initialization complete")

log("[DEBUG] Initializing Capture Zone: Severomorsk-3")
CaptureZone_Severomorsk_3 = ZONE:New( "Capture Severomorsk-3" )
ZoneCapture_Severomorsk_3 = ZONE_CAPTURE_COALITION:New( CaptureZone_Severomorsk_3, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_Severomorsk_3:__Guard( 1 )
ZoneCapture_Severomorsk_3:Start( 30, 30 )
log("[DEBUG] Severomorsk-3 zone initialization complete")

log("[DEBUG] Initializing Capture Zone: Murmansk International")
CaptureZone_Murmansk_International = ZONE:New( "Capture Murmansk International" )
ZoneCapture_Murmansk_International = ZONE_CAPTURE_COALITION:New( CaptureZone_Murmansk_International, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_Murmansk_International:__Guard( 1 )
ZoneCapture_Murmansk_International:Start( 30, 30 )
log("[DEBUG] Murmansk International zone initialization complete")

log("[DEBUG] Initializing Capture Zone: Monchegorsk")
CaptureZone_Monchegorsk = ZONE:New( "Capture Monchegorsk" )
ZoneCapture_Monchegorsk = ZONE_CAPTURE_COALITION:New( CaptureZone_Monchegorsk, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_Monchegorsk:__Guard( 1 )
ZoneCapture_Monchegorsk:Start( 30, 30 )
log("[DEBUG] Monchegorsk zone initialization complete")

log("[DEBUG] Initializing Capture Zone: Olenya")
CaptureZone_Olenya = ZONE:New( "Capture Olenya" )
ZoneCapture_Olenya = ZONE_CAPTURE_COALITION:New( CaptureZone_Olenya, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_Olenya:__Guard( 1 )
ZoneCapture_Olenya:Start( 30, 30 )
log("[DEBUG] Olenya zone initialization complete")

log("[DEBUG] Initializing Capture Zone: Afrikanda")
CaptureZone_Afrikanda = ZONE:New( "Capture Afrikanda" )
ZoneCapture_Afrikanda = ZONE_CAPTURE_COALITION:New( CaptureZone_Afrikanda, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_Afrikanda:__Guard( 1 )
ZoneCapture_Afrikanda:Start( 30, 30 )
log("[DEBUG] Afrikanda zone initialization complete")

log("[DEBUG] Initializing Capture Zone: The Mountain")
CaptureZone_The_Mountain = ZONE:New( "Capture The Mountain" )
ZoneCapture_The_Mountain = ZONE_CAPTURE_COALITION:New( CaptureZone_The_Mountain, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_The_Mountain:__Guard( 1 )
ZoneCapture_The_Mountain:Start( 30, 30 )
log("[DEBUG] The Mountain zone initialization complete")

log("[DEBUG] Initializing Capture Zone: The River")
CaptureZone_The_River = ZONE:New( "Capture The River" )
ZoneCapture_The_River = ZONE_CAPTURE_COALITION:New( CaptureZone_The_River, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_The_River:__Guard( 1 )  
ZoneCapture_The_River:Start( 30, 30 )
log("[DEBUG] The River zone initialization complete")

log("[DEBUG] Initializing Capture Zone: The Gulf")
CaptureZone_The_Gulf = ZONE:New( "Capture The Gulf" )
ZoneCapture_The_Gulf = ZONE_CAPTURE_COALITION:New( CaptureZone_The_Gulf, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_The_Gulf:__Guard( 1 )
ZoneCapture_The_Gulf:Start( 30, 30 )
log("[DEBUG] The Gulf zone initialization complete")

log("[DEBUG] Initializing Capture Zone: The Lakes")
CaptureZone_The_Lakes = ZONE:New( "Capture The Lakes" )
ZoneCapture_The_Lakes = ZONE_CAPTURE_COALITION:New( CaptureZone_The_Lakes, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_The_Lakes:__Guard( 1 )
ZoneCapture_The_Lakes:Start( 30, 30 )
log("[DEBUG] The Lakes zone initialization complete")

log("[DEBUG] Initializing Capture of Zone: Capture Luostari Pechenga")
CaptureZone_Luostari_Pechenga = ZONE:New( "Capture Luostari Pechenga" )
ZoneCapture_Luostari_Pechenga = ZONE_CAPTURE_COALITION:New( CaptureZone_Luostari_Pechenga, coalition.side.BLUE )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_Luostari_Pechenga:__Guard( 1 )
ZoneCapture_Luostari_Pechenga:Start( 30, 30 )
log("[DEBUG] Luostari Pechenga zone initialization complete")

log("[DEBUG] Initializing Capture of Zone: Capture Ivalo")
CaptureZone_Ivalo = ZONE:New( "Capture Ivalo" )
ZoneCapture_Ivalo = ZONE_CAPTURE_COALITION:New( CaptureZone_Ivalo, coalition.side.BLUE )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_Ivalo:__Guard( 1 )
ZoneCapture_Ivalo:Start( 30, 30 )
log("[DEBUG] Ivalo zone initialization complete")

log("[DEBUG] Initializing Capture of Zone: Capture Alakurtti")
CaptureZone_Alakurtti = ZONE:New( "Capture Alakurtti" )
ZoneCapture_Alakurtti = ZONE_CAPTURE_COALITION:New( CaptureZone_Alakurtti, coalition.side.BLUE )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_Alakurtti:__Guard( 1 )
ZoneCapture_Alakurtti:Start( 30, 30 )
log("[DEBUG] Alakurtti zone initialization complete")





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
  if not ZoneCapture then 
    return {red = 0, blue = 0, neutral = 0} 
  end
  
  local success, zone = pcall(function() return ZoneCapture:GetZone() end)
  if not success or not zone then 
    return {red = 0, blue = 0, neutral = 0} 
  end
  
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

local function GetRedUnitMGRSCoords(ZoneCapture)
  if not ZoneCapture then 
    return {} 
  end
  
  local success, zone = pcall(function() return ZoneCapture:GetZone() end)
  if not success or not zone then 
    return {} 
  end
  
  local coords = {}
  
  -- Get all units in the zone using MOOSE's zone scanning
  local unitsInZone = SET_UNIT:New()
    :FilterZones({zone})
    :FilterOnce()
  
  local totalUnits = 0
  local redUnits = 0
  local unitsWithCoords = 0
  
  if unitsInZone then
    unitsInZone:ForEachUnit(function(unit)
      totalUnits = totalUnits + 1
      if unit and unit:IsAlive() then
        local unitCoalition = unit:GetCoalition()
        
        -- Only process RED units
        if unitCoalition == coalition.side.RED then
          redUnits = redUnits + 1
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
  
  log(string.format("[TACTICAL DEBUG] %s - Total units scanned: %d, RED units: %d, units with MGRS: %d", 
    ZoneCapture:GetZoneName(), totalUnits, redUnits, unitsWithCoords))
  
  log(string.format("[TACTICAL] Found %d RED units with coordinates in %s", 
    #coords, ZoneCapture:GetZoneName()))
  
  return coords
end

local function CreateTacticalInfoMarker(ZoneCapture)
  -- Validate ZoneCapture object
  if not ZoneCapture then 
    log("[TACTICAL ERROR] ZoneCapture object is nil")
    return 
  end
  
  -- Safely get the zone with error handling
  local success, zone = pcall(function() return ZoneCapture:GetZone() end)
  if not success or not zone then 
    log("[TACTICAL ERROR] Failed to get zone from ZoneCapture object")
    return 
  end
  
  local forces = GetZoneForceStrengths(ZoneCapture)
  local zoneName = ZoneCapture:GetZoneName()
  
  -- Build tactical info text  
  local tacticalText = string.format("TACTICAL: %s\nForces: R:%d B:%d", 
    zoneName, forces.red, forces.blue)
  
  if forces.neutral > 0 then
    tacticalText = tacticalText .. string.format(" C:%d", forces.neutral)
  end
  
  -- Add MGRS coordinates if RED forces <= 10
  if forces.red > 0 and forces.red <= 10 then
    local redCoords = GetRedUnitMGRSCoords(ZoneCapture)
    log(string.format("[TACTICAL DEBUG] Building marker text for %d RED units", #redCoords))
    if #redCoords > 0 then
      tacticalText = tacticalText .. "\nTGTS:"
      for i, unit in ipairs(redCoords) do
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
      if #redCoords > 10 then
        tacticalText = tacticalText .. string.format(" (+%d)", #redCoords - 10)
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
    
    -- Create new tactical marker for BLUE coalition only
    local success, markerID = pcall(function()
      return offsetCoord:MarkToCoalition(tacticalText, coalition.side.BLUE)
    end)
    
    if success and markerID then
      ZoneCapture.TacticalMarkerID = markerID
      
      -- Try to make the marker read-only (if available in this MOOSE version)
      pcall(function()
        offsetCoord:SetMarkReadOnly(markerID, true)
      end)
      
      log(string.format("[TACTICAL] Created read-only marker for %s with %d RED, %d BLUE units", zoneName, forces.red, forces.blue))
    else
      log(string.format("[TACTICAL] Failed to create marker for %s", zoneName))
    end
  end
end

-- Event handler functions - define them separately for each zone
local function OnEnterGuarded(ZoneCapture, From, Event, To)
  if From ~= To then
    local Coalition = ZoneCapture:GetCoalition()
    if Coalition == coalition.side.BLUE then
      ZoneCapture:Smoke( SMOKECOLOR.Blue )
      -- Update zone visual markers to BLUE (captured)
      ZoneCapture:UndrawZone()
      local color = ZONE_COLORS.BLUE_CAPTURED
      ZoneCapture:DrawZone(-1, color, 0.5, color, 0.2, 2, true)
      US_CC:MessageTypeToCoalition( string.format( "%s is under protection of the USA", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
      RU_CC:MessageTypeToCoalition( string.format( "%s is under protection of the USA", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
    else
      ZoneCapture:Smoke( SMOKECOLOR.Red )
      -- Update zone visual markers to RED (captured)
      ZoneCapture:UndrawZone()
      local color = ZONE_COLORS.RED_CAPTURED
      ZoneCapture:DrawZone(-1, color, 0.5, color, 0.2, 2, true)
      RU_CC:MessageTypeToCoalition( string.format( "%s is under protection of Russia", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
      US_CC:MessageTypeToCoalition( string.format( "%s is under protection of Russia", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
    end
    -- Create/update tactical information marker
    CreateTacticalInfoMarker(ZoneCapture)
  end
end

local function OnEnterEmpty(ZoneCapture)
  ZoneCapture:Smoke( SMOKECOLOR.Green )
  -- Update zone visual markers to GREEN (neutral/empty)
  ZoneCapture:UndrawZone()
  local color = ZONE_COLORS.EMPTY
  ZoneCapture:DrawZone(-1, color, 0.5, color, 0.2, 2, true)
  US_CC:MessageTypeToCoalition( string.format( "%s is unprotected, and can be captured!", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
  RU_CC:MessageTypeToCoalition( string.format( "%s is unprotected, and can be captured!", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
  -- Create/update tactical information marker
  CreateTacticalInfoMarker(ZoneCapture)
end

local function OnEnterAttacked(ZoneCapture)
  ZoneCapture:Smoke( SMOKECOLOR.White )
  -- Update zone visual markers based on who owns it (attacked state)
  ZoneCapture:UndrawZone()
  local Coalition = ZoneCapture:GetCoalition()
  local color
  if Coalition == coalition.side.BLUE then
    color = ZONE_COLORS.BLUE_ATTACKED  -- Light blue for Blue zone under attack
    US_CC:MessageTypeToCoalition( string.format( "%s is under attack by Russia", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
    RU_CC:MessageTypeToCoalition( string.format( "We are attacking %s", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
  else
    color = ZONE_COLORS.RED_ATTACKED  -- Orange for Red zone under attack
    RU_CC:MessageTypeToCoalition( string.format( "%s is under attack by the USA", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
    US_CC:MessageTypeToCoalition( string.format( "We are attacking %s", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
  end
  ZoneCapture:DrawZone(-1, color, 0.5, color, 0.2, 2, true)
  -- Create/update tactical information marker
  CreateTacticalInfoMarker(ZoneCapture)
end

-- Apply event handlers to all zone capture objects
local zoneCaptureObjects = {
  ZoneCapture_Kilpyavr,
  ZoneCapture_Severomorsk_1,
  ZoneCapture_Severomorsk_3,
  ZoneCapture_Murmansk_International,
  ZoneCapture_Monchegorsk,
  ZoneCapture_Olenya,
  ZoneCapture_Afrikanda,
  ZoneCapture_The_Mountain,
  ZoneCapture_The_River,
  ZoneCapture_The_Gulf,
  ZoneCapture_The_Lakes,
  ZoneCapture_Luostari_Pechenga,
  ZoneCapture_Ivalo,
  ZoneCapture_Alakurtti
}

-- Victory condition monitoring
local function CheckVictoryCondition()
  local blueZonesCount = 0
  local totalZones = #zoneCaptureObjects
  
  -- Count BLUE zone ownership
  for i, zoneCapture in ipairs(zoneCaptureObjects) do
    if zoneCapture and zoneCapture:GetCoalition() == coalition.side.BLUE then
      blueZonesCount = blueZonesCount + 1
    end
  end
  
  -- Check if RED owns all 3 critical BLUE starting bases
  local redOwnsLuostari = ZoneCapture_Luostari_Pechenga:GetCoalition() == coalition.side.RED
  local redOwnsIvalo = ZoneCapture_Ivalo:GetCoalition() == coalition.side.RED
  local redOwnsAlakurtti = ZoneCapture_Alakurtti:GetCoalition() == coalition.side.RED
  
  log(string.format("[VICTORY CHECK] Blue owns %d/%d zones | RED critical bases: Luostari=%s, Ivalo=%s, Alakurtti=%s", 
    blueZonesCount, totalZones, tostring(redOwnsLuostari), tostring(redOwnsIvalo), tostring(redOwnsAlakurtti)))
  
  -- RED VICTORY CONDITION: Owns all 3 BLUE starting bases
  if redOwnsLuostari and redOwnsIvalo and redOwnsAlakurtti then
    log("[VICTORY] RED has eliminated BLUE's foothold! Triggering RED victory sequence...")
    
    -- RED Victory messages
    RU_CC:MessageTypeToCoalition( 
      "VICTORY! All coalition forward operating bases have been eliminated!\n\n" ..
      "BLUE forces have lost their strategic foothold in the region.\n" ..
      "Operation Polar Shield is complete. Excellent work!\n" ..
      "Mission will end in 60 seconds.", 
      MESSAGE.Type.Information, 30 
    )
    
    US_CC:MessageTypeToCoalition( 
      "DEFEAT! All forward operating bases have been lost!\n\n" ..
      "We have been driven from the region. Mission failed.\n" ..
      "Mission ending in 60 seconds.", 
      MESSAGE.Type.Information, 30 
    )
    
    -- Victory celebration effects for the 3 critical zones
    ZoneCapture_Luostari_Pechenga:Smoke( SMOKECOLOR.Red )
    ZoneCapture_Ivalo:Smoke( SMOKECOLOR.Red )
    ZoneCapture_Alakurtti:Smoke( SMOKECOLOR.Red )
    
    -- Schedule mission end after 60 seconds
    SCHEDULER:New( nil, function()
      log("[VICTORY] Ending mission due to RED eliminating BLUE's foothold")
      trigger.action.setUserFlag("RED_VICTORY", 1)
      
      RU_CC:MessageTypeToCoalition( 
        "Mission Complete! Congratulations on your victory!\n" ..
        "Final Status: Coalition forces eliminated from the region.", 
        MESSAGE.Type.Information, 10 
      )
    end, {}, 60 )
    
    return true -- RED Victory achieved
  end
  
  -- BLUE VICTORY CONDITION: Owns all zones
  if blueZonesCount >= totalZones then
    log("[VICTORY] All zones captured by BLUE! Triggering BLUE victory sequence...")
    
    -- BLUE Victory messages
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
    
    -- Victory celebration effects
    for _, zoneCapture in ipairs(zoneCaptureObjects) do
      if zoneCapture then
        zoneCapture:Smoke( SMOKECOLOR.Blue )
        local zone = zoneCapture:GetZone()
        if zone then
          zone:FlareZone( FLARECOLOR.Blue, 90, 60 )
        end
      end
    end
    
    -- Schedule mission end after 60 seconds
    SCHEDULER:New( nil, function()
      log("[VICTORY] Ending mission due to complete zone capture by BLUE")
      trigger.action.setUserFlag("BLUE_VICTORY", 1)
      
      US_CC:MessageTypeToCoalition( 
        "Mission Complete! Congratulations on your victory!\n" ..
        "Final Status: All 14 strategic zones secured.", 
        MESSAGE.Type.Information, 10 
      )
    end, {}, 60 )
    
    return true -- BLUE Victory achieved
  end
  
  return false -- Victory not yet achieved
end

local function OnEnterCaptured(ZoneCapture)
  local Coalition = ZoneCapture:GetCoalition()
  local zoneName = ZoneCapture:GetZoneName()
  
  -- Check if this is one of the critical BLUE starting bases
  local isCriticalBase = (zoneName == "Capture Luostari Pechenga" or 
                          zoneName == "Capture Ivalo" or 
                          zoneName == "Capture Alakurtti")
  
  if Coalition == coalition.side.BLUE then
    -- Update zone visual markers to BLUE (captured)
    ZoneCapture:UndrawZone()
    local color = ZONE_COLORS.BLUE_CAPTURED
    ZoneCapture:DrawZone(-1, color, 0.5, color, 0.2, 2, true)
    
    -- Enhanced messaging for critical bases
    if isCriticalBase then
      RU_CC:MessageTypeToCoalition( string.format( "%s is captured by the USA, we lost it!", zoneName ), MESSAGE.Type.Information )
      US_CC:MessageTypeToCoalition( string.format( "We recaptured %s! Critical base secured.", zoneName ), MESSAGE.Type.Information )
    else
      RU_CC:MessageTypeToCoalition( string.format( "%s is captured by the USA, we lost it!", zoneName ), MESSAGE.Type.Information )
      US_CC:MessageTypeToCoalition( string.format( "We captured %s, Excellent job!", zoneName ), MESSAGE.Type.Information )
    end
  else
    -- Update zone visual markers to RED (captured)
    ZoneCapture:UndrawZone()
    local color = ZONE_COLORS.RED_CAPTURED
    ZoneCapture:DrawZone(-1, color, 0.5, color, 0.2, 2, true)
    
    -- Enhanced messaging for critical bases
    if isCriticalBase then
      -- Count how many critical bases RED now owns
      local criticalBasesOwned = 0
      if ZoneCapture_Luostari_Pechenga:GetCoalition() == coalition.side.RED then criticalBasesOwned = criticalBasesOwned + 1 end
      if ZoneCapture_Ivalo:GetCoalition() == coalition.side.RED then criticalBasesOwned = criticalBasesOwned + 1 end
      if ZoneCapture_Alakurtti:GetCoalition() == coalition.side.RED then criticalBasesOwned = criticalBasesOwned + 1 end
      
      US_CC:MessageTypeToCoalition( 
        string.format( "⚠️ CRITICAL: %s captured by Russia! %d/3 starting bases lost!", zoneName, criticalBasesOwned ), 
        MESSAGE.Type.Information 
      )
      RU_CC:MessageTypeToCoalition( 
        string.format( "Excellent! %s captured. %d/3 critical bases secured!", zoneName, criticalBasesOwned ), 
        MESSAGE.Type.Information 
      )
    else
      US_CC:MessageTypeToCoalition( string.format( "%s is captured by Russia, we lost it!", zoneName ), MESSAGE.Type.Information )
      RU_CC:MessageTypeToCoalition( string.format( "We captured %s, Excellent job!", zoneName ), MESSAGE.Type.Information )
    end
  end
  
  ZoneCapture:AddScore( "Captured", "Zone captured: Extra points granted.", 200 )    
  ZoneCapture:__Guard( 30 )
  
  -- Create/update tactical information marker
  CreateTacticalInfoMarker(ZoneCapture)
  
  -- Check victory condition after any zone capture
  CheckVictoryCondition()
end

-- Set up event handlers for each zone with proper MOOSE methods and debugging
local zoneNames = {
  "Kilpyavr", "Severomorsk-1", "Severomorsk-3", "Murmansk International", 
  "Monchegorsk", "Olenya", "Afrikanda", "The Mountain", "The River", "The Gulf",
  "The Lakes", "Luostari Pechenga", "Ivalo", "Alakurtti"
}

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
      
      -- Initialize zone borders with initial RED color (all zones start as RED coalition)
      local drawSuccess, drawError = pcall(function()
        local color = ZONE_COLORS.RED_CAPTURED
        zone:DrawZone(-1, color, 0.5, color, 0.2, 2, true)
      end)
      
      if not drawSuccess then
  log("⚠ Zone 'Capture " .. zoneName .. "' border drawing failed: " .. tostring(drawError))
        -- Alternative: Try simpler zone marking
        pcall(function()
          zone:SmokeZone(SMOKECOLOR.Red, 30)
        end)
      else
  log("✓ Zone 'Capture " .. zoneName .. "' border drawn successfully with RED initial color")
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

-- Function to broadcast zone status report
local function BroadcastZoneStatus()
  local status = GetZoneOwnershipStatus()
  
  local reportMessage = string.format(
    "ZONE CONTROL REPORT:\n" ..
    "Blue Coalition: %d/%d zones\n" ..
    "Red Coalition: %d/%d zones\n" ..
    "Neutral: %d/%d zones\n\n" ..
    "Progress to Victory: %d%%",
    status.blue, status.total,
    status.red, status.total,
    status.neutral, status.total,
    math.floor((status.blue / status.total) * 100)
  )
  
  -- Add detailed zone status
  local detailMessage = "\nZONE DETAILS:\n"
  for zoneName, owner in pairs(status.zones) do
    detailMessage = detailMessage .. string.format("• %s: %s\n", zoneName, owner)
  end
  
  local fullMessage = reportMessage .. detailMessage
  
  US_CC:MessageTypeToCoalition( fullMessage, MESSAGE.Type.Information, 15 )
  
  log("[ZONE STATUS] " .. reportMessage:gsub("\n", " | "))
  
  return status
end

-- Periodic zone monitoring (every 5 minutes)
local ZoneMonitorScheduler = SCHEDULER:New( nil, function()
  local status = BroadcastZoneStatus()
  
  -- Check if we're close to victory (80% or more zones captured)
  if status.blue >= math.floor(status.total * 0.8) and status.blue < status.total then
    US_CC:MessageTypeToCoalition( 
      string.format("APPROACHING VICTORY! %d more zone(s) needed for complete success!", 
        status.total - status.blue), 
      MESSAGE.Type.Information, 10 
    )
    
    RU_CC:MessageTypeToCoalition( 
      string.format("CRITICAL SITUATION! Only %d zone(s) remain under our control!", 
        status.red), 
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
      
      -- Get the appropriate color for this zone's current state
      local zoneColor = GetZoneColor(zoneCapture)
      
      -- Force redraw the zone with correct color based on CURRENT STATE
      zoneCapture:UndrawZone()
      zoneCapture:DrawZone(-1, zoneColor, 0.5, zoneColor, 0.2, 2, true)
      
      -- Log the color assignment for debugging
      local colorName = "UNKNOWN"
      if currentState == "Attacked" then
        colorName = (zoneCoalition == coalition.side.BLUE) and "LIGHT BLUE (Blue Attacked)" or "ORANGE (Red Attacked)"
      elseif currentState == "Empty" then
        colorName = "GREEN (Empty)"
      elseif zoneCoalition == coalition.side.BLUE then
        colorName = "BLUE (Blue Captured)"
      elseif zoneCoalition == coalition.side.RED then
        colorName = "RED (Red Captured)"
      else
        colorName = "GREEN (Fallback)"
      end
      log(string.format("[ZONE COLORS] %s: Set to %s", zoneName, colorName))
    end
  end
  
end, {}, 60, 240 ) -- Start after 60 seconds, repeat every 240 seconds (4 minutes)

-- Periodic tactical marker update system with change detection (every 3 minutes)
local __lastForceCountsByZone = {}
local TacticalMarkerUpdateScheduler = SCHEDULER:New( nil, function()
  log("[TACTICAL] Running periodic tactical marker update (change-detected)...")

  for i, zoneCapture in ipairs(zoneCaptureObjects) do
    if zoneCapture then
      local zoneName = zoneNames and zoneNames[i] or (zoneCapture.GetZoneName and zoneCapture:GetZoneName()) or ("Zone " .. i)
      local counts = GetZoneForceStrengths(zoneCapture)
      local last = __lastForceCountsByZone[zoneName]
      local changed = (not last) or (last.red ~= counts.red) or (last.blue ~= counts.blue) or (last.neutral ~= counts.neutral)

      if changed then
        __lastForceCountsByZone[zoneName] = { red = counts.red, blue = counts.blue, neutral = counts.neutral }
        CreateTacticalInfoMarker(zoneCapture)
      else
        -- unchanged: skip marker churn
      end
    end
  end

end, {}, 30, 180 ) -- Start after 30 seconds, repeat every 180 seconds (3 minutes)

-- Function to refresh all zone colors based on current ownership
local function RefreshAllZoneColors()
  log("[ZONE COLORS] Refreshing all zone visual markers...")
  
  for i, zoneCapture in ipairs(zoneCaptureObjects) do
    if zoneCapture then
      local zoneCoalition = zoneCapture:GetCoalition()
      local zoneName = zoneNames[i] or ("Zone " .. i)
      local currentState = zoneCapture:GetCurrentState()
      
      -- Get the appropriate color for this zone's current state
      local zoneColor = GetZoneColor(zoneCapture)
      
      -- Clear existing drawings
      zoneCapture:UndrawZone()
      
      -- Redraw with correct color
      zoneCapture:DrawZone(-1, zoneColor, 0.5, zoneColor, 0.2, 2, true)
      
      -- Log the color assignment for debugging
      local colorName = "UNKNOWN"
      if currentState == "Attacked" then
        colorName = (zoneCoalition == coalition.side.BLUE) and "LIGHT BLUE (Blue Attacked)" or "ORANGE (Red Attacked)"
      elseif currentState == "Empty" then
        colorName = "GREEN (Empty)"
      elseif zoneCoalition == coalition.side.BLUE then
        colorName = "BLUE (Blue Captured)"
      elseif zoneCoalition == coalition.side.RED then
        colorName = "RED (Red Captured)"
      else
        colorName = "GREEN (Fallback)"
      end
      log(string.format("[ZONE COLORS] %s: Set to %s", zoneName, colorName))
    end
  end
  
  US_CC:MessageTypeToCoalition("Zone visual markers have been refreshed!", MESSAGE.Type.Information, 5)
end

-- Manual zone status command for players (F10 radio menu)
local function SetupZoneStatusCommands()
  -- Add F10 radio menu commands for zone status
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

