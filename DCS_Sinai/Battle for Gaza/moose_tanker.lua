-- Objective: Create a tanker that will start when called for, and fly to waypoints established by players via mark points. 
--- Get a list of mark points from the map.
--- Find mark points formated something like: TANKER:WP1 or TANKER-1 or TANKER-WP1 or something like that.
--- Feed mark points into the route points on currently flying tanker (or launch new one)




local msgTime = 15

Spawn_Blue_Texaco = SPAWN:New("Texaco")
:InitLimit(1, 500)
:SpawnScheduled(300,.3)

Spawn_Blue_Arco = SPAWN:New("Arco")
:InitLimit(1, 500)
:SpawnScheduled(300,.5)



--ControlTanker = CONTROLLABLE:New(Spawn_Blue_Texaco)
--
--function update_tanker_route()
--  
--  local tankerMarksPoints = 0
--  local all_mark_panels = world.getMarkPanels()
--  local route_table = {}  
--
--    MESSAGE:New("DEBUG: Total Mark Points: " .. #all_mark_panels, msgTime, "TANKER", false):ToBlue()
--    for i, v in ipairs(all_mark_panels) do
--        
--        if string.match(v.text, "TANKER") then -- If we found a tanker mark point, insert that into the route table.
--            local pos_str = "Index [" .. i .. "] " .. v.pos.x .. ", " .. v.pos.y .. ", " .. v.pos.z
--            MESSAGE:New(v.text .. ": " .. pos_str , 30, "TANKER", false):ToBlue()
--            tankerMarksPoints = tankerMarksPoints + 1
--            table.insert(route_table, v.pos)
--        end
--    end
--
--    function isTableEmpty(route_table)
--        return next(route_table) == nil
--    end
--
--    if isTableEmpty(route_table) then
--        MESSAGE:New("No TANKER mark points found.", msgTime, "TANKER", false):ToBlue()
--    else
--        MESSAGE:New("Tanker Waypoints Found: " .. tankerMarksPoints, msgTime, "TANKER", false):ToBlue()
--        ControlTanker:Route(route_table, 3)
--    end
--    
--end
--
--function get_tanker_gas()
--  
--  local gas = ControlTanker:GetFuel()
--  if gas == nil then 
--    MESSAGE:New("No tankers found", msgTime, "TANKER", false):ToBlue()
--  else
--    MESSAGE:New("Tanker has " .. gas .. " remaining.", msgTime, "TANKER", false):ToBlue()
--  end
--  
--
--end
--
--
--MenuBlue_Tanker_Operations = MENU_COALITION:New(coalition.side.BLUE, "Tanker Operations")
--MenuBlue_Tanker_OperationsUpdateRoute = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Update Tanker Waypoints", MenuBlue_Tanker_Operations, update_tanker_route)
--MenuBlue_Tanker_OperationsFuel = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Get Tanker Fuel Status", MenuBlue_Tanker_Operations, get_tanker_gas)
