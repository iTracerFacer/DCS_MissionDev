-- TADC Manual Launch Test
-- This script will attempt to manually launch one aircraft to test if the spawn system works

env.info("=== TADC MANUAL LAUNCH TEST ===")

-- Wait a few seconds for MOOSE to initialize, then try a manual launch
SCHEDULER:New(nil, function()
    
    env.info("Attempting manual aircraft launch...")
    
    -- Test configuration - using the first squadron
    local testConfig = {
        templateName = "FIGHTER_SWEEP_RED_Severomorsk-1",
        displayName = "Severomorsk-1 TEST",
        airbaseName = "Severomorsk-1",
        aircraft = 1,
        skill = AI.Skill.GOOD,
        altitude = 20000,
        speed = 350,
        patrolTime = 25,
        type = "FIGHTER"
    }
    
    -- Manual launch function (simplified version)
    local function manualLaunch(config)
        env.info("=== MANUAL LAUNCH ATTEMPT ===")
        env.info("Template: " .. config.templateName)
        env.info("Airbase: " .. config.airbaseName)
        
        local success, errorMsg = pcall(function()
            -- Check if template exists
            local templateGroup = GROUP:FindByName(config.templateName)
            if not templateGroup then
                env.info("✗ CRITICAL: Template group not found: " .. config.templateName)
                env.info("DIAGNOSIS: This template does not exist in the mission!")
                env.info("SOLUTION: Create a group named '" .. config.templateName .. "' in Mission Editor")
                return
            end
            
            env.info("✓ Template group found: " .. config.templateName)
            
            -- Check template properties
            local coalition = templateGroup:GetCoalition()
            local isAlive = templateGroup:IsAlive()
            
            env.info("Template coalition: " .. (coalition == 1 and "Red" or (coalition == 2 and "Blue" or "Neutral")))
            env.info("Template alive: " .. tostring(isAlive))
            
            if coalition ~= 1 then
                env.info("✗ CRITICAL: Template is not Red coalition!")
                env.info("SOLUTION: Set '" .. config.templateName .. "' to Red coalition in Mission Editor")
                return
            end
            
            if isAlive then
                env.info("⚠ WARNING: Template is alive - Late Activation may not be set")
                env.info("RECOMMENDATION: Set '" .. config.templateName .. "' to Late Activation in Mission Editor")
            end
            
            -- Check airbase
            local airbaseObj = AIRBASE:FindByName(config.airbaseName)
            if not airbaseObj then
                env.info("✗ CRITICAL: Airbase not found: " .. config.airbaseName)
                env.info("SOLUTION: Check airbase name spelling or use a different airbase")
                return
            end
            
            env.info("✓ Airbase found: " .. config.airbaseName)
            
            local airbaseCoalition = airbaseObj:GetCoalition()
            env.info("Airbase coalition: " .. (airbaseCoalition == 1 and "Red" or (airbaseCoalition == 2 and "Blue" or "Neutral")))
            
            -- Create SPAWN object
            env.info("Creating SPAWN object...")
            local spawner = SPAWN:New(config.templateName)
            
            -- Try to spawn
            env.info("Attempting to spawn aircraft...")
            local spawnedGroup = nil
            
            -- Method 1: Air spawn
            local airbaseCoord = airbaseObj:GetCoordinate()
            local spawnCoord = airbaseCoord:Translate(2000, math.random(0, 360)):SetAltitude(config.altitude * 0.3048)
            
            env.info("Trying air spawn at " .. config.altitude .. "ft...")
            spawnedGroup = spawner:SpawnFromCoordinate(spawnCoord, nil, SPAWN.Takeoff.Air)
            
            if not spawnedGroup then
                env.info("Air spawn failed, trying hot start at airbase...")
                spawnedGroup = spawner:SpawnAtAirbase(airbaseObj, SPAWN.Takeoff.Hot)
            end
            
            if not spawnedGroup then
                env.info("Hot start failed, trying cold start at airbase...")
                spawnedGroup = spawner:SpawnAtAirbase(airbaseObj, SPAWN.Takeoff.Cold)
            end
            
            if spawnedGroup then
                env.info("✓ SUCCESS: Aircraft spawned successfully!")
                env.info("Spawned group: " .. spawnedGroup:GetName())
                
                -- Set basic CAP task after a delay
                SCHEDULER:New(nil, function()
                    if spawnedGroup and spawnedGroup:IsAlive() then
                        env.info("Setting up basic CAP task...")
                        
                        local currentCoord = spawnedGroup:GetCoordinate()
                        if currentCoord then
                            env.info("Aircraft position: " .. currentCoord:ToStringLLDMS())
                            
                            -- Clear tasks and set basic patrol
                            spawnedGroup:ClearTasks()
                            spawnedGroup:OptionROEOpenFire()
                            
                            -- Simple patrol task
                            local patrolCoord = currentCoord:Translate(10000, math.random(0, 360)):SetAltitude(config.altitude * 0.3048)
                            
                            local patrolTask = {
                                id = 'Orbit',
                                params = {
                                    pattern = 'Circle',
                                    point = {x = patrolCoord.x, y = patrolCoord.z},
                                    radius = 5000,
                                    altitude = config.altitude * 0.3048,
                                    speed = config.speed * 0.514444,
                                }
                            }
                            spawnedGroup:PushTask(patrolTask, 1)
                            
                            env.info("✓ Basic CAP task assigned")
                            
                            -- Clean up after 10 minutes
                            SCHEDULER:New(nil, function()
                                if spawnedGroup and spawnedGroup:IsAlive() then
                                    env.info("Test complete - cleaning up spawned aircraft")
                                    spawnedGroup:Destroy()
                                end
                            end, {}, 600) -- 10 minutes
                            
                        else
                            env.info("⚠ Could not get aircraft coordinate")
                        end
                    else
                        env.info("⚠ Aircraft not alive for task assignment")
                    end
                end, {}, 5) -- 5 second delay
                
            else
                env.info("✗ CRITICAL: All spawn methods failed!")
                env.info("DIAGNOSIS: There may be an issue with the template or MOOSE setup")
            end
        end)
        
        if not success then
            env.info("✗ CRITICAL ERROR in manual launch: " .. tostring(errorMsg))
        end
    end
    
    -- Attempt the manual launch
    manualLaunch(testConfig)
    
end, {}, 5) -- Wait 5 seconds for MOOSE initialization

env.info("Manual launch test scheduled - check log in 5 seconds")