-- Setup Capture Missions & Zones 


-- Setup BLUE Missions 
do -- Missions
  
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



-- Red Airbases (from TADC configuration)
env.info("[CAPTURE Module] [DEBUG] Initializing Capture Zone: Kilpyavr")
CaptureZone_Kilpyavr = ZONE:New( "Capture Kilpyavr" )
ZoneCapture_Kilpyavr = ZONE_CAPTURE_COALITION:New( CaptureZone_Kilpyavr, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_Kilpyavr:__Guard( 1 )
ZoneCapture_Kilpyavr:Start( 30, 30 )
env.info("[CAPTURE Module] [DEBUG] Kilpyavr zone initialization complete")

env.info("[CAPTURE Module] [DEBUG] Initializing Capture Zone: Severomorsk-1")
CaptureZone_Severomorsk_1 = ZONE:New( "Capture Severomorsk-1" )
ZoneCapture_Severomorsk_1 = ZONE_CAPTURE_COALITION:New( CaptureZone_Severomorsk_1, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_Severomorsk_1:__Guard( 1 )
ZoneCapture_Severomorsk_1:Start( 30, 30 )
env.info("[CAPTURE Module] [DEBUG] Severomorsk-1 zone initialization complete")

env.info("[CAPTURE Module] [DEBUG] Initializing Capture Zone: Severomorsk-3")
CaptureZone_Severomorsk_3 = ZONE:New( "Capture Severomorsk-3" )
ZoneCapture_Severomorsk_3 = ZONE_CAPTURE_COALITION:New( CaptureZone_Severomorsk_3, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_Severomorsk_3:__Guard( 1 )
ZoneCapture_Severomorsk_3:Start( 30, 30 )
env.info("[CAPTURE Module] [DEBUG] Severomorsk-3 zone initialization complete")

env.info("[CAPTURE Module] [DEBUG] Initializing Capture Zone: Murmansk International")
CaptureZone_Murmansk_International = ZONE:New( "Capture Murmansk International" )
ZoneCapture_Murmansk_International = ZONE_CAPTURE_COALITION:New( CaptureZone_Murmansk_International, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_Murmansk_International:__Guard( 1 )
ZoneCapture_Murmansk_International:Start( 30, 30 )
env.info("[CAPTURE Module] [DEBUG] Murmansk International zone initialization complete")

env.info("[CAPTURE Module] [DEBUG] Initializing Capture Zone: Monchegorsk")
CaptureZone_Monchegorsk = ZONE:New( "Capture Monchegorsk" )
ZoneCapture_Monchegorsk = ZONE_CAPTURE_COALITION:New( CaptureZone_Monchegorsk, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_Monchegorsk:__Guard( 1 )
ZoneCapture_Monchegorsk:Start( 30, 30 )
env.info("[CAPTURE Module] [DEBUG] Monchegorsk zone initialization complete")

env.info("[CAPTURE Module] [DEBUG] Initializing Capture Zone: Olenya")
CaptureZone_Olenya = ZONE:New( "Capture Olenya" )
ZoneCapture_Olenya = ZONE_CAPTURE_COALITION:New( CaptureZone_Olenya, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_Olenya:__Guard( 1 )
ZoneCapture_Olenya:Start( 30, 30 )
env.info("[CAPTURE Module] [DEBUG] Olenya zone initialization complete")

env.info("[CAPTURE Module] [DEBUG] Initializing Capture Zone: Afrikanda")
CaptureZone_Afrikanda = ZONE:New( "Capture Afrikanda" )
ZoneCapture_Afrikanda = ZONE_CAPTURE_COALITION:New( CaptureZone_Afrikanda, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_Afrikanda:__Guard( 1 )
ZoneCapture_Afrikanda:Start( 30, 30 )
env.info("[CAPTURE Module] [DEBUG] Afrikanda zone initialization complete")

env.info("[CAPTURE Module] [DEBUG] Initializing Capture Zone: The Mountain")
CaptureZone_The_Mountain = ZONE:New( "Capture The Mountain" )
ZoneCapture_The_Mountain = ZONE_CAPTURE_COALITION:New( CaptureZone_The_Mountain, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_The_Mountain:__Guard( 1 )
ZoneCapture_The_Mountain:Start( 30, 30 )
env.info("[CAPTURE Module] [DEBUG] The Mountain zone initialization complete")

env.info("[CAPTURE Module] [DEBUG] Initializing Capture Zone: The River")
CaptureZone_The_River = ZONE:New( "Capture The River" )
ZoneCapture_The_River = ZONE_CAPTURE_COALITION:New( CaptureZone_The_River, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_The_River:__Guard( 1 )  
ZoneCapture_The_River:Start( 30, 30 )
env.info("[CAPTURE Module] [DEBUG] The River zone initialization complete")

env.info("[CAPTURE Module] [DEBUG] Initializing Capture Zone: The Gulf")
CaptureZone_The_Gulf = ZONE:New( "Capture The Gulf" )
ZoneCapture_The_Gulf = ZONE_CAPTURE_COALITION:New( CaptureZone_The_Gulf, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_The_Gulf:__Guard( 1 )
ZoneCapture_The_Gulf:Start( 30, 30 )
env.info("[CAPTURE Module] [DEBUG] The Gulf zone initialization complete")

env.info("[CAPTURE Module] [DEBUG] Initializing Capture Zone: The Lakes")
CaptureZone_The_Lakes = ZONE:New( "Capture The Lakes" )
ZoneCapture_The_Lakes = ZONE_CAPTURE_COALITION:New( CaptureZone_The_Lakes, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_The_Lakes:__Guard( 1 )
ZoneCapture_The_Lakes:Start( 30, 30 )
env.info("[CAPTURE Module] [DEBUG] The Lakes zone initialization complete")



-- Helper functions for tactical information
local function GetZoneForceStrengths(ZoneCapture)
  local zone = ZoneCapture:GetZone()
  if not zone then return {red = 0, blue = 0, neutral = 0} end
  
  local redCount = 0
  local blueCount = 0  
  local neutralCount = 0
  
  -- Simple approach: scan all units and check if they're in the zone
  local coord = zone:GetCoordinate()
  local radius = zone:GetRadius() or 1000
  
  local allUnits = SET_UNIT:New():FilterStart()
  allUnits:ForEachUnit(function(unit)
    if unit and unit:IsAlive() then
      local unitCoord = unit:GetCoordinate()
      if unitCoord and coord:Get2DDistance(unitCoord) <= radius then
        local unitCoalition = unit:GetCoalition()
        if unitCoalition == coalition.side.RED then
          redCount = redCount + 1
        elseif unitCoalition == coalition.side.BLUE then
          blueCount = blueCount + 1
        elseif unitCoalition == coalition.side.NEUTRAL then
          neutralCount = neutralCount + 1
        end
      end
    end
  end)
  
  env.info(string.format("[CAPTURE Module] [TACTICAL] Zone %s scan result: R:%d B:%d N:%d", 
    ZoneCapture:GetZoneName(), redCount, blueCount, neutralCount))
  
  return {
    red = redCount,
    blue = blueCount,
    neutral = neutralCount
  }
end

local function GetRedUnitMGRSCoords(ZoneCapture)
  local zone = ZoneCapture:GetZone()
  if not zone then return {} end
  
  local coords = {}
  local units = nil
  
  -- Try multiple methods to get units (same as GetZoneForceStrengths)
  local success1 = pcall(function()
    units = zone:GetScannedUnits()
  end)
  
  if not success1 or not units then
    local success2 = pcall(function()
      local unitSet = SET_UNIT:New():FilterZones({zone}):FilterStart()
      units = {}
      unitSet:ForEachUnit(function(unit)
        if unit then
          units[unit:GetName()] = unit
        end
      end)
    end)
  end
  
  if not units then
    local success3 = pcall(function()
      units = {}
      local unitSet = SET_UNIT:New():FilterZones({zone}):FilterStart()
      unitSet:ForEachUnit(function(unit)
        if unit and unit:IsInZone(zone) then
          units[unit:GetName()] = unit
        end
      end)
    end)
  end
  
  -- Extract RED unit coordinates
  if units then
    for unitName, unit in pairs(units) do
      -- Enhanced nil checking and safe method calls
      if unit and type(unit) == "table" and unit.IsAlive then
        local isAlive = false
        local success_alive = pcall(function()
          isAlive = unit:IsAlive()
        end)
        
        if success_alive and isAlive then
          local coalition_side = nil
          local success_coalition = pcall(function()
            coalition_side = unit:GetCoalition()
          end)
          
          if success_coalition and coalition_side == coalition.side.RED then
            local coord = unit:GetCoordinate()
            if coord then
              local success, mgrs = pcall(function()
                return coord:ToStringMGRS(5) -- 5-digit precision
              end)
          
              if success and mgrs then
                table.insert(coords, {
                  name = unit:GetName(),
                  type = unit:GetTypeName(),
                  mgrs = mgrs
                })
              end
            end
          end
        end
      end
    end
  end
  
  env.info(string.format("[CAPTURE Module] [TACTICAL] Found %d RED units with coordinates in %s", 
    #coords, ZoneCapture:GetZoneName()))
  
  return coords
end

local function CreateTacticalInfoMarker(ZoneCapture)
  local zone = ZoneCapture:GetZone() 
  if not zone then return end
  
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
    if #redCoords > 0 then
      tacticalText = tacticalText .. "\n\nRED UNITS:"
      for i, unit in ipairs(redCoords) do
        if i <= 6 then -- Limit to 6 entries to avoid text overflow
          -- Shorten unit type names to fit better
          local shortType = unit.type:gsub("^%w+%-", ""):gsub("%s.*", "")
          tacticalText = tacticalText .. string.format("\n%s: %s", shortType, unit.mgrs)
        end
      end
      if #redCoords > 6 then
        tacticalText = tacticalText .. string.format("\n+%d more", #redCoords - 6)
      end
    end
  end
  
  -- Create tactical marker offset from zone center
  local coord = zone:GetCoordinate()
  if coord then
    -- Offset the tactical marker slightly northeast of the main zone marker
    local offsetCoord = coord:Translate(200, 45) -- 200m northeast
    
    -- Remove any existing tactical marker first
    if ZoneCapture.TacticalMarkerID then
      env.info(string.format("[CAPTURE Module] [TACTICAL] Removing old marker ID %d for %s", ZoneCapture.TacticalMarkerID, zoneName))
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
      
      env.info(string.format("[CAPTURE Module] [TACTICAL] Created read-only marker for %s with %d RED, %d BLUE units", zoneName, forces.red, forces.blue))
    else
      env.info(string.format("[CAPTURE Module] [TACTICAL] Failed to create marker for %s", zoneName))
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
  ZoneCapture_The_Lakes
}

-- Victory condition monitoring
local function CheckVictoryCondition()
  local blueZonesCount = 0
  local totalZones = #zoneCaptureObjects
  
  for i, zoneCapture in ipairs(zoneCaptureObjects) do
    if zoneCapture and zoneCapture:GetCoalition() == coalition.side.BLUE then
      blueZonesCount = blueZonesCount + 1
    end
  end
  
  env.info(string.format("[CAPTURE Module] [VICTORY CHECK] Blue owns %d/%d zones", blueZonesCount, totalZones))
  
  if blueZonesCount >= totalZones then
    -- All zones captured by BLUE - trigger victory condition
    env.info("[CAPTURE Module] [VICTORY] All zones captured by BLUE! Triggering victory sequence...")
    
    -- Victory messages
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
    
    -- Optional: Add victory celebration effects
    for _, zoneCapture in ipairs(zoneCaptureObjects) do
      if zoneCapture then
        zoneCapture:Smoke( SMOKECOLOR.Blue )
        -- Add flares for celebration
        local zone = zoneCapture:GetZone()
        if zone then
          zone:FlareZone( FLARECOLOR.Blue, 90, 60 )
        end
      end
    end
    
    -- Schedule mission end after 60 seconds
    SCHEDULER:New( nil, function()
      env.info("[CAPTURE Module] [VICTORY] Ending mission due to complete zone capture by BLUE")
      -- You can trigger specific end-mission logic here
      -- For example: trigger.action.setUserFlag("MissionComplete", 1)
      -- Or call specific mission ending functions
      
      -- Example mission end trigger
      trigger.action.setUserFlag("BLUE_VICTORY", 1)
      
      -- Optional: Show final score/statistics
      US_CC:MessageTypeToCoalition( 
        "Mission Complete! Congratulations on your victory!\n" ..
        "Final Status: All 10 strategic zones secured.", 
        MESSAGE.Type.Information, 10 
      )
      
    end, {}, 60 )
    
    return true -- Victory achieved
  end
  
  return false -- Victory not yet achieved
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
  "The Lakes"
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
      env.info("[CAPTURE Module] ✓ Zone 'Capture " .. zoneName .. "' successfully created and linked")
      
      -- Initialize zone borders with initial RED color (all zones start as RED coalition)
      local drawSuccess, drawError = pcall(function()
        zone:DrawZone(-1, {1, 0, 0}, 0.5, {1, 0, 0}, 0.2, 2, true) -- Red initial boundary
      end)
      
      if not drawSuccess then
        env.info("[CAPTURE Module] ⚠ Zone 'Capture " .. zoneName .. "' border drawing failed: " .. tostring(drawError))
        -- Alternative: Try simpler zone marking
        pcall(function()
          zone:SmokeZone(SMOKECOLOR.Red, 30)
        end)
      else
        env.info("[CAPTURE Module] ✓ Zone 'Capture " .. zoneName .. "' border drawn successfully with RED initial color")
      end
    else
      env.info("[CAPTURE Module] ✗ ERROR: Zone 'Capture " .. zoneName .. "' not found in mission editor!")
      env.info("[CAPTURE Module]    Make sure you have a trigger zone named exactly: 'Capture " .. zoneName .. "'")
    end
  else
    env.info("[CAPTURE Module] ✗ ERROR: Zone capture object " .. i .. " (" .. (zoneNames[i] or "Unknown") .. ") is nil!")
  end
end

-- Additional specific check for Olenya
env.info("[CAPTURE Module] === OLENYA SPECIFIC DEBUG ===")
if ZoneCapture_Olenya then
  env.info("[CAPTURE Module] ✓ ZoneCapture_Olenya object exists")
  local success, result = pcall(function() return ZoneCapture_Olenya:GetZoneName() end)
  if success then
    env.info("[CAPTURE Module] ✓ Zone name: " .. tostring(result))
  else
    env.info("[CAPTURE Module] ✗ Could not get zone name: " .. tostring(result))
  end
  
  local success2, zone = pcall(function() return ZoneCapture_Olenya:GetZone() end)
  if success2 and zone then
    env.info("[CAPTURE Module] ✓ Underlying zone object exists")
    local coord = zone:GetCoordinate()
    if coord then
      env.info("[CAPTURE Module] ✓ Zone coordinate: " .. coord:ToStringLLDMS())
    end
  else
    env.info("[CAPTURE Module] ✗ Underlying zone object missing: " .. tostring(zone))
  end
else
  env.info("[CAPTURE Module] ✗ ZoneCapture_Olenya object is nil!")
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
  
  env.info("[CAPTURE Module] [ZONE STATUS] " .. reportMessage:gsub("\n", " | "))
  
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
  env.info("[CAPTURE Module] [ZONE COLORS] Running periodic zone color verification...")
  
  -- Verify each zone's visual marker matches its coalition
  for i, zoneCapture in ipairs(zoneCaptureObjects) do
    if zoneCapture then
      local zoneCoalition = zoneCapture:GetCoalition()
      local zoneName = zoneNames[i] or ("Zone " .. i)
      
      -- Force redraw the zone with correct color (helps prevent desync issues)
      zoneCapture:UndrawZone()
      
      if zoneCoalition == coalition.side.BLUE then
        zoneCapture:DrawZone(-1, {0, 0, 1}, 0.5, {0, 0, 1}, 0.2, 2, true) -- Blue
      elseif zoneCoalition == coalition.side.RED then
        zoneCapture:DrawZone(-1, {1, 0, 0}, 0.5, {1, 0, 0}, 0.2, 2, true) -- Red
      else
        zoneCapture:DrawZone(-1, {0, 1, 0}, 0.5, {0, 1, 0}, 0.2, 2, true) -- Green (neutral)
      end
    end
  end
  
end, {}, 60, 120 ) -- Start after 60 seconds, repeat every 120 seconds (2 minutes)

-- Periodic tactical marker update system (every 1 minute)
local TacticalMarkerUpdateScheduler = SCHEDULER:New( nil, function()
  env.info("[CAPTURE Module] [TACTICAL] Running periodic tactical marker update...")
  
  -- Update tactical markers for all zones
  for i, zoneCapture in ipairs(zoneCaptureObjects) do
    if zoneCapture then
      CreateTacticalInfoMarker(zoneCapture)
    end
  end
  
end, {}, 30, 60 ) -- Start after 30 seconds, repeat every 60 seconds (1 minute)

-- Function to refresh all zone colors based on current ownership
local function RefreshAllZoneColors()
  env.info("[CAPTURE Module] [ZONE COLORS] Refreshing all zone visual markers...")
  
  for i, zoneCapture in ipairs(zoneCaptureObjects) do
    if zoneCapture then
      local coalition = zoneCapture:GetCoalition()
      local zoneName = zoneNames[i] or ("Zone " .. i)
      
      -- Clear existing drawings
      zoneCapture:UndrawZone()
      
      -- Redraw with correct color based on current coalition
      if coalition == coalition.side.BLUE then
        zoneCapture:DrawZone(-1, {0, 0, 1}, 0.5, {0, 0, 1}, 0.2, 2, true) -- Blue
        env.info(string.format("[CAPTURE Module] [ZONE COLORS] %s: Set to BLUE", zoneName))
      elseif coalition == coalition.side.RED then
        zoneCapture:DrawZone(-1, {1, 0, 0}, 0.5, {1, 0, 0}, 0.2, 2, true) -- Red
        env.info(string.format("[CAPTURE Module] [ZONE COLORS] %s: Set to RED", zoneName))
      else
        zoneCapture:DrawZone(-1, {0, 1, 0}, 0.5, {0, 1, 0}, 0.2, 2, true) -- Green (neutral)
        env.info(string.format("[CAPTURE Module] [ZONE COLORS] %s: Set to NEUTRAL/GREEN", zoneName))
      end
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
  env.info("[CAPTURE Module] [VICTORY SYSTEM] Initializing zone monitoring system...")
  SetupZoneStatusCommands()
  
  -- Initial status report
  SCHEDULER:New( nil, function()
    env.info("[CAPTURE Module] [VICTORY SYSTEM] Broadcasting initial zone status...")
    BroadcastZoneStatus()
  end, {}, 30 ) -- Initial report after 30 seconds
  
end, {}, 5 ) -- Initialize after 5 seconds

env.info("[CAPTURE Module] [VICTORY SYSTEM] Zone capture victory monitoring system loaded successfully!")

