USHQ = GROUP:FindByName( "US HQ", "US HQ" )
RUSSHQ = GROUP:FindByName( "Russian HQ", "Russian HQ" )

USCommandCenter = COMMANDCENTER:New( USHQ, "US HQ" )
RUSCommandCenter = COMMANDCENTER:New( RUSSHQ, "Russian HQ" )

Scoring = SCORING:New( "Operation Black Gold" )

Scoring:SetScaleDestroyScore( 10 )

Scoring:SetScaleDestroyPenalty( 40 )


        --Setup the BLUEA2A dispatcher, and initialize it.
  local BLUEBorderZone = ZONE_POLYGON:New( "BLUE BORDER", GROUP:FindByName( "BLUE BORDER" ) )
  BLUEA2ADispatcher = AI_A2A_GCICAP:New( { "BLUE EWR" }, { "FIGHTER SWEEP BLUE" }, { "BLUE BORDER" }, 2 )  
  BLUEA2ADispatcher:SetDefaultLandingAtRunway()
  BLUEA2ADispatcher:SetBorderZone( BLUEBorderZone )
  BLUEA2ADispatcher:SetTacticalDisplay(false)
  BLUEA2ADispatcher:SetDefaultFuelThreshold( 0.20 )
  BLUEA2ADispatcher:SetRefreshTimeInterval( 600 )


      --Setup the RedA2A dispatcher, and initialize it.
  local CCCPBorderZone = ZONE_POLYGON:New( "RED BORDER", GROUP:FindByName( "RED BORDER" ) )
  RedA2ADispatcher = AI_A2A_GCICAP:New( { "RED EWR" }, { "FIGHTER SWEEP RED" }, { "RED BORDER" }, 2 )
  RedA2ADispatcher:SetDefaultLandingAtRunway()
  RedA2ADispatcher:SetBorderZone( CCCPBorderZone )
  RedA2ADispatcher:SetTacticalDisplay(false)
  RedA2ADispatcher:SetDefaultFuelThreshold( 0.20 )
  RedA2ADispatcher:SetRefreshTimeInterval( 600 )
  
  
  Spawn_REDATTACK_Su25 = SPAWN:New("RED ATTACK"):InitLimit( 2, 200 )
  Spawn_REDATTACK_Su25:InitRepeatOnLanding()
  Spawn_REDATTACK_Su25:SpawnScheduled(900,0.5)

  Spawn_REDATTACK_Helo1 = SPAWN:New("RED ATTACK HELO1"):InitLimit( 1, 200 )
  Spawn_REDATTACK_Helo1:InitRepeatOnLanding()
  Spawn_REDATTACK_Helo1:SpawnScheduled(900,0.5)
  
  Spawn_REDATTACK_Helo2 = SPAWN:New("RED ATTACK HELO2"):InitLimit( 1, 200 )
  Spawn_REDATTACK_Helo2:InitRepeatOnLanding()
  Spawn_REDATTACK_Helo2:SpawnScheduled(900,0.5)