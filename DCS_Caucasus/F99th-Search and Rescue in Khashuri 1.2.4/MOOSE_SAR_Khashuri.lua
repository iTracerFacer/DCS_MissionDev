-- Create the Command Centers


REDHQ = GROUP:FindByName( "REDHQ", "Alpha HQ" )
REDCommandCenter = COMMANDCENTER:New( REDHQ, "Red" )
BLUEHQ = GROUP:FindByName( "BLUEHQ" )
BLUECommandCenter = COMMANDCENTER:New( BLUEHQ, "Blue" )


-- Create a zone table of the 2 zones.
ZoneTable = { ZONE:New( "Zone1" ), ZONE:New( "Zone2" ), ZONE:New( "Zone3" ), ZONE:New( "Zone4" ), ZONE:New( "Zone5" ), ZONE:New( "Zone6" ), ZONE:New( "Zone7" ) }
--SmallZoneTable = { ZONE:New( "Zone5" ) }
--  GroupPolygon = GROUP:FindByName( "AO_SpawnZone" )
--  ZoneTable = ZONE_POLYGON:New( "AO_SpawnZone", GroupPolygon )
  

TemplateTable = { "A", "B", "C", "D" }

Spawn_Vehicle_NotMoving = SPAWN:New( "No Path" )
  :InitLimit( 30, 0 )
  :InitRandomizeTemplate( TemplateTable )
  :InitRandomizeZones( ZoneTable )
  :SpawnScheduled( 1, .5 )



Spawn_Vehicle_1 = SPAWN:New( "Path 1" )
  :InitLimit( 10, 500 )
  :InitRandomizeRoute( 1, 50, 1000 )
  :InitRandomizeTemplate( TemplateTable ) 
  :InitRandomizeZones( ZoneTable )
  :SpawnScheduled( 300, .5 )
--
--
Spawn_Vehicle_2 = SPAWN:New( "Path 2" )
  :InitLimit( 10, 500 )
  :InitRandomizeRoute( 1, 50, 1000 )
  :InitRandomizeTemplate( TemplateTable ) 
  :InitRandomizeZones( ZoneTable )
  :SpawnScheduled( 300, .5 )
--
--
--
--Spawn_Vehicle_3 = SPAWN:New( "Path 3" )
----  :InitRandomizeRoute( 1, 50, 1000 )
--  :InitLimit( 10, 500 )
--  :InitRandomizeTemplate( TemplateTable ) 
--  :InitRandomizeZones( ZoneTable )
--  :SpawnScheduled( 300, .5 )


  




    --Setup the RedA2A dispatcher, and initialize it.
  local CCCPBorderZone = ZONE_POLYGON:New( "Red Engage Zone", GROUP:FindByName( "Red Engage Zone" ) )
    RedA2ADispatcher = AI_A2A_GCICAP:New( { "RU EWR" }, { "RED TEMPLATE" }, { "Red Engage Zone" }, 2 )
    RedA2ADispatcher:SetDefaultLandingAtRunway()
    RedA2ADispatcher:SetBorderZone( CCCPBorderZone )
    RedA2ADispatcher:SetTacticalDisplay(false)
    RedA2ADispatcher:SetDefaultFuelThreshold( 0.20 )
    RedA2ADispatcher:SetRefreshTimeInterval( 120 )
    --Setup the BlueA2A dispatcher, and initialize it.
  local USABorderZone = ZONE_POLYGON:New( "Blue Engage Zone", GROUP:FindByName( "Blue Engage Zone" ) )
    BlueA2ADispatcher = AI_A2A_GCICAP:New( { "US EWR" }, { "BLUE TEMPLATE" }, { "Blue Engage Zone" }, 2 )
    BlueA2ADispatcher:SetDefaultLandingAtRunway()
    BlueA2ADispatcher:SetBorderZone( USABorderZone )
    BlueA2ADispatcher:SetTacticalDisplay(false)
    BlueA2ADispatcher:SetDefaultFuelThreshold( 0.20 )
    BlueA2ADispatcher:SetRefreshTimeInterval( 120 )


