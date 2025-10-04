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
    
  US_Score = SCORING:New( "Capture Airfields" )
    
  US_Mission_Capture_Airfields:AddScoring( US_Score )
  
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

