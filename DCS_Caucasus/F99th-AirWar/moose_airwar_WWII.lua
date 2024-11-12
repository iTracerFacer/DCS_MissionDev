--_SETTINGS:SetPlayerMenuOff()
----env.info("Loading Main Script", true)
---- Setup Command Centers. See Moose_ErmenekLiberation_ZoneCapture.lua for remaining code.
---- Set SRS settings
--STTS.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone"
--STTS.SRS_PORT = "5002"

-- Define the SET of CLIENTs from the red coalition. This SET is filled during startup.
RU_PlanesClientSetFW190 = SET_CLIENT:New():FilterCountries( "RUSSIA" ):FilterPrefixes("FW190"):FilterStart()
RU_PlanesClientSetBF109 = SET_CLIENT:New():FilterCountries( "RUSSIA" ):FilterPrefixes("BF109"):FilterStart()

US_PlanesClientSetP51 = SET_CLIENT:New():FilterCountries( "USA" ):FilterCategories( "plane" ):FilterPrefixes("P51"):FilterStart()
US_PlanesClientSetSpitFire = SET_CLIENT:New():FilterCountries( "USA" ):FilterCategories( "plane" ):FilterPrefixes("Spitfire"):FilterStart()

-- Define the SPAWN object for the red AI plane template.
-- We use InitCleanUp to check every 20 seconds, if there are no planes blocked at the airbase, waithing for take-off.
-- If a blocked plane exists, this red plane will be ReSpawned.
RU_PlanesSpawnFW190 = SPAWN:New( "AI RU-FW190" ):InitCleanUp( 20 )
RU_PlanesSpawnBF109 = SPAWN:New( "AI RU-BF109" ):InitCleanUp( 20 )


US_PlanesSpawnP51 = SPAWN:New( "AI US-P51" ):InitCleanUp( 20 )
US_PlanesSpawnSpitFire = SPAWN:New( "AI US-SPITFIRE" ):InitCleanUp( 20 )

-- Start the AI_BALANCER, using the SET of red CLIENTs, and the SPAWN object as a parameter.
RU_AI_BalancerFW190 = AI_BALANCER:New( RU_PlanesClientSetFW190, RU_PlanesSpawnFW190 )
RU_AI_BalancerBF109 = AI_BALANCER:New( RU_PlanesClientSetBF109, RU_PlanesSpawnBF109 )

US_AI_BalancerP51 = AI_BALANCER:New( US_PlanesClientSetP51, US_PlanesSpawnP51 )
US_AI_BalancerSpitFire = AI_BALANCER:New( US_PlanesClientSetSpitFire, US_PlanesSpawnSpitFire )


PatrolZone1 = ZONE:New("PatrolZone1")
PatrolZone2 = ZONE:New("PatrolZone2")

function US_AI_BalancerP51:OnAfterSpawned( SetGroup, From, Event, To, AIGroup )

  --local Patrol = AI_PATROL_ZONE:New( PatrolZoneArray[math.random( 1, 2 )], 3000, 6000, 400, 600 )
  local Patrol = AI_CAP_ZONE:New(PatrolZone1,5000,30000,400,500)
  Patrol:ManageFuel( 0.2, 60 )
  Patrol:SetEngageZone(PatrolZone1)
  Patrol:SetControllable( AIGroup )
  Patrol:Start()
 
end

function US_AI_BalancerSpitFire:OnAfterSpawned( SetGroup, From, Event, To, AIGroup )

  --local Patrol = AI_PATROL_ZONE:New( PatrolZoneArray[math.random( 1, 2 )], 3000, 6000, 400, 600 )
  local Patrol = AI_CAP_ZONE:New(PatrolZone1,5000,30000,400,500)
  Patrol:ManageFuel( 0.2, 60 )
  Patrol:SetEngageZone(PatrolZone1)
  Patrol:SetControllable( AIGroup )
  Patrol:Start()
 
end

function RU_AI_BalancerFW190:OnAfterSpawned( SetGroup, From, Event, To, AIGroup )

  --local Patrol = AI_PATROL_ZONE:New( PatrolZoneArray[math.random( 1, 2 )], 3000, 6000, 400, 600 )
  local Patrol = AI_CAP_ZONE:New(PatrolZone2,5000,30000,400,500) 
  Patrol:ManageFuel( 0.2, 60 )
  Patrol:SetEngageZone(PatrolZone2)
  Patrol:SetControllable( AIGroup )  
  Patrol:Start()
  

end

function RU_AI_BalancerBF109:OnAfterSpawned( SetGroup, From, Event, To, AIGroup )

  --local Patrol = AI_PATROL_ZONE:New( PatrolZoneArray[math.random( 1, 2 )], 3000, 6000, 400, 600 )
  local Patrol = AI_CAP_ZONE:New(PatrolZone2,5000,30000,400,500) 
  Patrol:ManageFuel( 0.2, 60 )
  Patrol:SetEngageZone(PatrolZone2)
  Patrol:SetControllable( AIGroup )  
  Patrol:Start()
  

end


Spawn_US_AWACS = SPAWN:New("BLUE EWR E-2D Wizard Group")
  :InitLimit(1,500)
  :InitRepeatOnLanding()
  :SpawnScheduled(300, .4)

Spawn_RU_AWACS = SPAWN:New("RED EWR")
  :InitLimit(1,500)
  :InitRepeatOnLanding()
  :SpawnScheduled(300, .4)