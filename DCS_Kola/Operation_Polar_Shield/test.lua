-- Add this at the very beginning after MOOSE loads
env.info("=== MOOSE DEBUG INFO ===")
env.info("MOOSE loaded: " .. tostring(MOOSE ~= nil))
env.info("OPS available: " .. tostring(OPS ~= nil))
env.info("_G.OPS available: " .. tostring(_G.OPS ~= nil))

-- Check what's in the global namespace
for k,v in pairs(_G) do
    if string.find(k, "OPS") then
        env.info("Found OPS-related: " .. k .. " = " .. tostring(v))
    end
end


-- Debug airbase availability
env.info("=== AIRBASE DEBUG ===")
env.info("AIRBASE table exists: " .. tostring(AIRBASE ~= nil))

if AIRBASE then
    env.info("AIRBASE.Kola exists: " .. tostring(AIRBASE.Kola ~= nil))
    
    -- List all airbases found on the map
    env.info("=== ALL AIRBASES ON MAP ===")
    
    -- Method 1: Try using SET_AIRBASE to get all airbases
    if SET_AIRBASE then
        env.info("Using SET_AIRBASE method...")
        local airbaseSet = SET_AIRBASE:New():FilterOnce()
        if airbaseSet then
            local count = airbaseSet:Count()
            env.info("Total airbases found: " .. count)
            airbaseSet:ForEach(function(airbase)
                if airbase then
                    local name = airbase:GetName()
                    local coalition = airbase:GetCoalition()
                    local coalitionName = "Unknown"
                    if coalition == 0 then coalitionName = "Neutral"
                    elseif coalition == 1 then coalitionName = "Red"  
                    elseif coalition == 2 then coalitionName = "Blue"
                    end
                    env.info("Airbase: '" .. name .. "' (" .. coalitionName .. ")")
                end
            end)
        end
    end
    
    -- Method 2: Try specific airbase names we expect
    env.info("=== TESTING SPECIFIC AIRBASES ===")
    local testNames = {
        "Severomorsk-1", "Severomorsk-3", "Kilpyavr", "Murmansk", 
        "Monchegorsk", "Olenya", "Afrikanda"
    }
    
    for _, name in pairs(testNames) do
        local airbase = AIRBASE:FindByName(name)
        env.info(name .. ": " .. tostring(airbase ~= nil))
        if airbase then
            env.info("  - Coalition: " .. airbase:GetCoalition())
        end
    end
    
    -- Alternative method - check AIRBASE.Kola if it exists
    if AIRBASE.Kola then
        env.info("=== AIRBASE.Kola CONSTANTS ===")
        for k,v in pairs(AIRBASE.Kola) do
            env.info("AIRBASE.Kola." .. k .. " = " .. tostring(v))
        end
    end
end