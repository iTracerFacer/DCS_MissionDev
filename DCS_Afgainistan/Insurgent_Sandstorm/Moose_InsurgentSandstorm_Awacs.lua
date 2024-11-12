-- Define the patrol zone
local patrolZone = ZONE:New("AWACS_PatrolZone")

-- Define AWACS and its escorts
local awacsGroup = "BLUE EWR AWACS"  -- Name of AWACS group from mission editor
local escortGroup1 = "BlueAWACS_Escort_Group1"  -- First escort group
local escortGroup2 = "BlueAWACS_Escort_Group2"  -- Second escort group

-- Spawn the AWACS and set up patrol behavior
local awacs = SPAWN:New(awacsGroup)
  :InitLimit(1, 0)  -- Limit to one active instance of AWACS
  :OnSpawnGroup(function(group)
    -- Define patrol within the zone
    local awacsPatrol = AI_PATROL_ZONE:New(group, patrolZone, 5000, 10000, 500, 800)
    awacsPatrol:ManageFuelOn(.7, 300)  -- AWACS returns to base when low on fuel

    -- Event handler for AWACS being attacked
    group:HandleEvent(EVENTS.Hit)
    function group:OnEventHit(EventData)
      group:RouteRTB()  -- AWACS returns to base when attacked
    end
  end)
  :Spawn()

-- Spawn the first escort and attach to AWACS
local escort1 = SPAWN:New(escortGroup1)
  :InitLimit(1, 0)
  :OnSpawnGroup(function(escortGroup)
    -- Attach the escort to follow AWACS
    local awacsEscort1 = ESCORT:New(awacs, escortGroup)
    awacsEscort1:Escort()
  end)
  :Spawn()

-- Spawn the second escort and attach to AWACS
local escort2 = SPAWN:New(escortGroup2)
  :InitLimit(1, 0)
  :OnSpawnGroup(function(escortGroup)
    -- Attach the second escort to follow AWACS
    local awacsEscort2 = ESCORT:New(awacs, escortGroup)
    awacsEscort2:Escort()
  end)
  :Spawn()
