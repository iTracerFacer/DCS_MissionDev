--_SETTINGS:SetPlayerMenuOff()
----env.info("Loading Main Script", true)
---- Setup Command Centers. See Moose_ErmenekLiberation_ZoneCapture.lua for remaining code.
---- Set SRS settings
--STTS.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone"
--STTS.SRS_PORT = "5002"

-- Define the SET of CLIENTs from the red coalition. This SET is filled during startup.
RU_PlanesClientSet = SET_CLIENT:New():FilterCountries( "RUSSIA" ):FilterCategories( "plane" ):FilterStart()
US_PlanesClientSet = SET_CLIENT:New():FilterCountries( "USA" ):FilterCategories( "plane" ):FilterStart()

-- Define the SPAWN object for the red AI plane template.
-- We use InitCleanUp to check every 20 seconds, if there are no planes blocked at the airbase, waithing for take-off.
-- If a blocked plane exists, this red plane will be ReSpawned.
RU_PlanesSpawn = SPAWN:New( "AI RU" ):InitCleanUp( 20 )
US_PlanesSpawn = SPAWN:New( "AI US" ):InitCleanUp( 20 )

-- Start the AI_BALANCER, using the SET of red CLIENTs, and the SPAWN object as a parameter.
RU_AI_Balancer = AI_BALANCER:New( RU_PlanesClientSet, RU_PlanesSpawn )
US_AI_Balancer = AI_BALANCER:New( US_PlanesClientSet, US_PlanesSpawn )


PatrolZone1 = ZONE:New("PatrolZone1")
PatrolZone2 = ZONE:New("PatrolZone2")


Spawn_US_AWACS = SPAWN:New("BLUE EWR E-2D Wizard Group")
  :InitLimit(1,500)
  :InitRepeatOnLanding()
  :SpawnScheduled(300, .4)

Spawn_RU_AWACS = SPAWN:New("RED EWR")
  :InitLimit(1,500)
  :InitRepeatOnLanding()
  :SpawnScheduled(300, .4)

function US_AI_Balancer:OnAfterSpawned( SetGroup, From, Event, To, AIGroup )

  --local Patrol = AI_PATROL_ZONE:New( PatrolZoneArray[math.random( 1, 2 )], 3000, 6000, 400, 600 )
  local Patrol = AI_CAP_ZONE:New(PatrolZone1,5000,30000,400,500)
  Patrol:ManageFuel( 0.2, 60 )
  Patrol:SetEngageZone(PatrolZone1)
  Patrol:SetControllable( AIGroup )
  Patrol:Start()
 
end

function RU_AI_Balancer:OnAfterSpawned( SetGroup, From, Event, To, AIGroup )

  --local Patrol = AI_PATROL_ZONE:New( PatrolZoneArray[math.random( 1, 2 )], 3000, 6000, 400, 600 )
  local Patrol = AI_CAP_ZONE:New(PatrolZone2,5000,30000,400,500) 
  Patrol:ManageFuel( 0.2, 60 )
  Patrol:SetEngageZone(PatrolZone2)
  Patrol:SetControllable( AIGroup )  
  Patrol:Start()
  

end

