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


CaptureZone_Puerto_Williams = ZONE:New( "Capture Puerto Williams" )
ZoneCapture_Puerto_Williams = ZONE_CAPTURE_COALITION:New( CaptureZone_Puerto_Williams, coalition.side.RED ) 
ZoneCapture_Puerto_Williams:__Guard( 1 )
ZoneCapture_Puerto_Williams:Start( 30, 30 )



CaptureZone_Aerodrome_De_Tolhuin = ZONE:New( "Capture Aerodrome De Tolhuin" )
ZoneCapture_Aerodrome_De_Tolhuin = ZONE_CAPTURE_COALITION:New( CaptureZone_Aerodrome_De_Tolhuin, coalition.side.RED )
ZoneCapture_Aerodrome_De_Tolhuin:__Guard( 1 )
ZoneCapture_Aerodrome_De_Tolhuin:Start( 30, 30 )

CaptureZone_Capture_Rio_Grande = ZONE:New( "Capture Rio Grande" )
ZoneCapture_Capture_Rio_Grande = ZONE_CAPTURE_COALITION:New( CaptureZone_Capture_Rio_Grande, coalition.side.RED )
ZoneCapture_Capture_Rio_Grande:__Guard( 1 )
ZoneCapture_Capture_Rio_Grande:Start( 30, 30 )

CaptureZone_Almirante_Schroeders = ZONE:New( "Capture Almirante Schroeders" )
ZoneCapture_Almirante_Schroeders = ZONE_CAPTURE_COALITION:New( CaptureZone_Almirante_Schroeders, coalition.side.RED )
ZoneCapture_Almirante_Schroeders:__Guard( 1 )
ZoneCapture_Almirante_Schroeders:Start( 30, 30 )

CaptureZone_Porvenir_Airfield = ZONE:New( "Capture Porvenir Airfield" )
ZoneCapture_Porvenir_Airfield = ZONE_CAPTURE_COALITION:New( CaptureZone_Porvenir_Airfield, coalition.side.RED )
ZoneCapture_Porvenir_Airfield:__Guard( 1 )
ZoneCapture_Porvenir_Airfield:Start( 30, 30 )


--- @param Functional.ZoneCaptureCoalition#ZONE_CAPTURE_COALITION self
function ZoneCaptureCoalition:OnEnterGuarded( From, Event, To )
  if From ~= To then
    local Coalition = self:GetCoalition()
    self:E( { Coalition = Coalition } )
    if Coalition == coalition.side.BLUE then
      ZoneCaptureCoalition:Smoke( SMOKECOLOR.Blue )
      US_CC:MessageTypeToCoalition( string.format( "%s is under protection of the USA", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      RU_CC:MessageTypeToCoalition( string.format( "%s is under protection of the USA", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
    else
      ZoneCaptureCoalition:Smoke( SMOKECOLOR.Red )
      RU_CC:MessageTypeToCoalition( string.format( "%s is under protection of Russia", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      US_CC:MessageTypeToCoalition( string.format( "%s is under protection of Russia", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
    end
  end
end

--- @param Functional.Protect#ZONE_CAPTURE_COALITION self
function ZoneCaptureCoalition:OnEnterEmpty()
  ZoneCaptureCoalition:Smoke( SMOKECOLOR.Green )
  US_CC:MessageTypeToCoalition( string.format( "%s is unprotected, and can be captured!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
  RU_CC:MessageTypeToCoalition( string.format( "%s is unprotected, and can be captured!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
end


--- @param Functional.Protect#ZONE_CAPTURE_COALITION self
function ZoneCaptureCoalition:OnEnterAttacked()
  ZoneCaptureCoalition:Smoke( SMOKECOLOR.White )
  local Coalition = self:GetCoalition()
  self:E({Coalition = Coalition})
  if Coalition == coalition.side.BLUE then
    US_CC:MessageTypeToCoalition( string.format( "%s is under attack by Russia", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
    RU_CC:MessageTypeToCoalition( string.format( "We are attacking %s", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
  else
    RU_CC:MessageTypeToCoalition( string.format( "%s is under attack by the USA", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
    US_CC:MessageTypeToCoalition( string.format( "We are attacking %s", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
  end
end

--- @param Functional.Protect#ZONE_CAPTURE_COALITION self
function ZoneCaptureCoalition:OnEnterCaptured()
  local Coalition = self:GetCoalition()
  self:E({Coalition = Coalition})
  if Coalition == coalition.side.BLUE then
    RU_CC:MessageTypeToCoalition( string.format( "%s is captured by the USA, we lost it!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
    US_CC:MessageTypeToCoalition( string.format( "We captured %s, Excellent job!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
  else
    US_CC:MessageTypeToCoalition( string.format( "%s is captured by Russia, we lost it!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
    RU_CC:MessageTypeToCoalition( string.format( "We captured %s, Excellent job!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
  end
  
  self:AddScore( "Captured", "Zone captured: Extra points granted.", 200 )    
  
  self:__Guard( 30 )
end

ZoneCaptureCoalition:__Guard( 1 )
  
ZoneCaptureCoalition:Start( 30, 30 )
  


