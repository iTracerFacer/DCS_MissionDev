--env.info("Loading AWACS Script", true)

  Spawn_RED_AWACS = SPAWN:New("REDAWACS")
  :InitLimit(1, 100)
  :SpawnScheduled(120,.5)

-- Define the AWACS
local REDAWACS = GROUP:FindByName("REDAWACS")
-- Get the mission waypoints
local waypoints = REDAWACS:GetTemplateRoutePoints()

-- Set up the AWACS to patrol between the waypoints
REDAWACS:

-- Set up fuel check every 20 minutes
SCHEDULER:New(nil, function()
    local fuelState = REDAWACS:GetFuel()

    if fuelState < 0.2 then
      MESSAGE:New("AWACS is RTB due to low fuel!", 15, "AWACS", false):ToRed()
      REDAWACS:RouteRTB("Al Mansurah",330)
    else
        REDAWACS:MessageToRED(string.format("AWACS fuel state is %.1f%%", fuelState * 100), 15)
            end
end, {}, 1200, 1200)


