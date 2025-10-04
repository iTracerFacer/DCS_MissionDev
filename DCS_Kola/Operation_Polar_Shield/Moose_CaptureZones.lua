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
env.info("[DEBUG] Initializing Capture Zone: Kilpyavr")
CaptureZone_Kilpyavr = ZONE:New( "Capture Kilpyavr" )
ZoneCapture_Kilpyavr = ZONE_CAPTURE_COALITION:New( CaptureZone_Kilpyavr, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_Kilpyavr:__Guard( 1 )
ZoneCapture_Kilpyavr:Start( 30, 30 )
env.info("[DEBUG] Kilpyavr zone initialization complete")

env.info("[DEBUG] Initializing Capture Zone: Severomorsk-1")
CaptureZone_Severomorsk_1 = ZONE:New( "Capture Severomorsk-1" )
ZoneCapture_Severomorsk_1 = ZONE_CAPTURE_COALITION:New( CaptureZone_Severomorsk_1, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_Severomorsk_1:__Guard( 1 )
ZoneCapture_Severomorsk_1:Start( 30, 30 )
env.info("[DEBUG] Severomorsk-1 zone initialization complete")

env.info("[DEBUG] Initializing Capture Zone: Severomorsk-3")
CaptureZone_Severomorsk_3 = ZONE:New( "Capture Severomorsk-3" )
ZoneCapture_Severomorsk_3 = ZONE_CAPTURE_COALITION:New( CaptureZone_Severomorsk_3, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_Severomorsk_3:__Guard( 1 )
ZoneCapture_Severomorsk_3:Start( 30, 30 )
env.info("[DEBUG] Severomorsk-3 zone initialization complete")

env.info("[DEBUG] Initializing Capture Zone: Murmansk International")
CaptureZone_Murmansk_International = ZONE:New( "Capture Murmansk International" )
ZoneCapture_Murmansk_International = ZONE_CAPTURE_COALITION:New( CaptureZone_Murmansk_International, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_Murmansk_International:__Guard( 1 )
ZoneCapture_Murmansk_International:Start( 30, 30 )
env.info("[DEBUG] Murmansk International zone initialization complete")

env.info("[DEBUG] Initializing Capture Zone: Monchegorsk")
CaptureZone_Monchegorsk = ZONE:New( "Capture Monchegorsk" )
ZoneCapture_Monchegorsk = ZONE_CAPTURE_COALITION:New( CaptureZone_Monchegorsk, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_Monchegorsk:__Guard( 1 )
ZoneCapture_Monchegorsk:Start( 30, 30 )
env.info("[DEBUG] Monchegorsk zone initialization complete")

env.info("[DEBUG] Initializing Capture Zone: Olenya")
CaptureZone_Olenya = ZONE:New( "Capture Olenya" )
ZoneCapture_Olenya = ZONE_CAPTURE_COALITION:New( CaptureZone_Olenya, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_Olenya:__Guard( 1 )
ZoneCapture_Olenya:Start( 30, 30 )
env.info("[DEBUG] Olenya zone initialization complete")

env.info("[DEBUG] Initializing Capture Zone: Afrikanda")
CaptureZone_Afrikanda = ZONE:New( "Capture Afrikanda" )
ZoneCapture_Afrikanda = ZONE_CAPTURE_COALITION:New( CaptureZone_Afrikanda, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_Afrikanda:__Guard( 1 )
ZoneCapture_Afrikanda:Start( 30, 30 )
env.info("[DEBUG] Afrikanda zone initialization complete")

env.info("[DEBUG] Initializing Capture Zone: The Mountain")
CaptureZone_The_Mountain = ZONE:New( "Capture The Mountain" )
ZoneCapture_The_Mountain = ZONE_CAPTURE_COALITION:New( CaptureZone_The_Mountain, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_The_Mountain:__Guard( 1 )
ZoneCapture_The_Mountain:Start( 30, 30 )
env.info("[DEBUG] The Mountain zone initialization complete")

env.info("[DEBUG] Initializing Capture Zone: The River")
CaptureZone_The_River = ZONE:New( "Capture The River" )
ZoneCapture_The_River = ZONE_CAPTURE_COALITION:New( CaptureZone_The_River, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_The_River:__Guard( 1 )  
ZoneCapture_The_River:Start( 30, 30 )
env.info("[DEBUG] The River zone initialization complete")

env.info("[DEBUG] Initializing Capture Zone: The Gulf")
CaptureZone_The_Gulf = ZONE:New( "Capture The Gulf" )
ZoneCapture_The_Gulf = ZONE_CAPTURE_COALITION:New( CaptureZone_The_Gulf, coalition.side.RED )
-- SetMarkReadOnly method not available in this MOOSE version - feature disabled
ZoneCapture_The_Gulf:__Guard( 1 )
ZoneCapture_The_Gulf:Start( 30, 30 )
env.info("[DEBUG] The Gulf zone initialization complete")



-- Event handler functions - define them separately for each zone
local function OnEnterGuarded(ZoneCapture, From, Event, To)
  if From ~= To then
    local Coalition = ZoneCapture:GetCoalition()
    if Coalition == coalition.side.BLUE then
      ZoneCapture:Smoke( SMOKECOLOR.Blue )
      US_CC:MessageTypeToCoalition( string.format( "%s is under protection of the USA", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
      RU_CC:MessageTypeToCoalition( string.format( "%s is under protection of the USA", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
    else
      ZoneCapture:Smoke( SMOKECOLOR.Red )
      RU_CC:MessageTypeToCoalition( string.format( "%s is under protection of Russia", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
      US_CC:MessageTypeToCoalition( string.format( "%s is under protection of Russia", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
    end
  end
end

local function OnEnterEmpty(ZoneCapture)
  ZoneCapture:Smoke( SMOKECOLOR.Green )
  US_CC:MessageTypeToCoalition( string.format( "%s is unprotected, and can be captured!", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
  RU_CC:MessageTypeToCoalition( string.format( "%s is unprotected, and can be captured!", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
end

local function OnEnterAttacked(ZoneCapture)
  ZoneCapture:Smoke( SMOKECOLOR.White )
  local Coalition = ZoneCapture:GetCoalition()
  if Coalition == coalition.side.BLUE then
    US_CC:MessageTypeToCoalition( string.format( "%s is under attack by Russia", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
    RU_CC:MessageTypeToCoalition( string.format( "We are attacking %s", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
  else
    RU_CC:MessageTypeToCoalition( string.format( "%s is under attack by the USA", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
    US_CC:MessageTypeToCoalition( string.format( "We are attacking %s", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
  end
end

-- Victory condition monitoring
local function CheckVictoryCondition()
  local blueZonesCount = 0
  local totalZones = #zoneCaptureObjects
  
  for i, zoneCapture in ipairs(zoneCaptureObjects) do
    if zoneCapture and zoneCapture:GetCoalition() == coalition.side.BLUE then
      blueZonesCount = blueZonesCount + 1
    end
  end
  
  env.info(string.format("[VICTORY CHECK] Blue owns %d/%d zones", blueZonesCount, totalZones))
  
  if blueZonesCount >= totalZones then
    -- All zones captured by BLUE - trigger victory condition
    env.info("[VICTORY] All zones captured by BLUE! Triggering victory sequence...")
    
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
      env.info("[VICTORY] Ending mission due to complete zone capture by BLUE")
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
    RU_CC:MessageTypeToCoalition( string.format( "%s is captured by the USA, we lost it!", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
    US_CC:MessageTypeToCoalition( string.format( "We captured %s, Excellent job!", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
  else
    US_CC:MessageTypeToCoalition( string.format( "%s is captured by Russia, we lost it!", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
    RU_CC:MessageTypeToCoalition( string.format( "We captured %s, Excellent job!", ZoneCapture:GetZoneName() ), MESSAGE.Type.Information )
  end
  
  ZoneCapture:AddScore( "Captured", "Zone captured: Extra points granted.", 200 )    
  ZoneCapture:__Guard( 30 )
  
  -- Check victory condition after any zone capture
  CheckVictoryCondition()
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
  ZoneCapture_The_Gulf
}

-- Set up event handlers for each zone with proper MOOSE methods and debugging
local zoneNames = {
  "Kilpyavr", "Severomorsk-1", "Severomorsk-3", "Murmansk International", 
  "Monchegorsk", "Olenya", "Afrikanda", "The Mountain", "The River", "The Gulf"
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
      env.info("✓ Zone 'Capture " .. zoneName .. "' successfully created and linked")
      
      -- Try to make zone borders visible with different approach
      local drawSuccess, drawError = pcall(function()
        zone:DrawZone(-1, {1, 0, 0}, 0.5, {1, 0, 0}, 0.2, 2, true)
      end)
      
      if not drawSuccess then
        env.info("⚠ Zone 'Capture " .. zoneName .. "' border drawing failed: " .. tostring(drawError))
        -- Alternative: Try simpler zone marking
        pcall(function()
          zone:SmokeZone(SMOKECOLOR.Red, 30)
        end)
      else
        env.info("✓ Zone 'Capture " .. zoneName .. "' border drawn successfully")
      end
    else
      env.info("✗ ERROR: Zone 'Capture " .. zoneName .. "' not found in mission editor!")
      env.info("   Make sure you have a trigger zone named exactly: 'Capture " .. zoneName .. "'")
    end
  else
    env.info("✗ ERROR: Zone capture object " .. i .. " (" .. (zoneNames[i] or "Unknown") .. ") is nil!")
  end
end

-- Additional specific check for Olenya
env.info("=== OLENYA SPECIFIC DEBUG ===")
if ZoneCapture_Olenya then
  env.info("✓ ZoneCapture_Olenya object exists")
  local success, result = pcall(function() return ZoneCapture_Olenya:GetZoneName() end)
  if success then
    env.info("✓ Zone name: " .. tostring(result))
  else
    env.info("✗ Could not get zone name: " .. tostring(result))
  end
  
  local success2, zone = pcall(function() return ZoneCapture_Olenya:GetZone() end)
  if success2 and zone then
    env.info("✓ Underlying zone object exists")
    local coord = zone:GetCoordinate()
    if coord then
      env.info("✓ Zone coordinate: " .. coord:ToStringLLDMS())
    end
  else
    env.info("✗ Underlying zone object missing: " .. tostring(zone))
  end
else
  env.info("✗ ZoneCapture_Olenya object is nil!")
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
      
      if zoneCoalition == coalitionTable.side.BLUE then
        status.blue = status.blue + 1
        status.zones[zoneName] = "BLUE"
      elseif zoneCoalition == coalitionTable.side.RED then
        status.red = status.red + 1
        status.zones[zoneName] = "RED"
      else
        status.neutral = status.neutral + 1
        status.zones[zoneName] = "NEUTRAL"
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
  
  env.info("[ZONE STATUS] " .. reportMessage:gsub("\n", " | "))
  
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
  end
end

-- Initialize zone status monitoring
SCHEDULER:New( nil, function()
  env.info("[VICTORY SYSTEM] Initializing zone monitoring system...")
  SetupZoneStatusCommands()
  
  -- Initial status report
  SCHEDULER:New( nil, function()
    env.info("[VICTORY SYSTEM] Broadcasting initial zone status...")
    BroadcastZoneStatus()
  end, {}, 30 ) -- Initial report after 30 seconds
  
end, {}, 5 ) -- Initialize after 5 seconds

env.info("[VICTORY SYSTEM] Zone capture victory monitoring system loaded successfully!")

