-- TADC Diagnostic Script
-- This script will run diagnostics on the TADC system to identify why no aircraft are launching

env.info("=== TADC DIAGNOSTIC SCRIPT STARTING ===")

-- Test 1: Check if zones exist and are properly defined
local function testZones()
    env.info("=== ZONE DIAGNOSTIC ===")
    
    local redBorderGroup = GROUP:FindByName("RED BORDER")
    local heloBorderGroup = GROUP:FindByName("HELO BORDER")
    
    if redBorderGroup then
        env.info("✓ RED BORDER group found")
        local redZone = ZONE_POLYGON:New("RED BORDER TEST", redBorderGroup)
        if redZone then
            env.info("✓ RED BORDER zone created successfully")
            local coord = redZone:GetCoordinate()
            if coord then
                env.info("✓ RED BORDER zone coordinate: " .. coord:ToStringLLDMS())
            else
                env.info("✗ RED BORDER zone has no coordinate")
            end
        else
            env.info("✗ Failed to create RED BORDER zone")
        end
    else
        env.info("✗ RED BORDER group NOT found - this is likely the problem!")
    end
    
    if heloBorderGroup then
        env.info("✓ HELO BORDER group found")
        local heloZone = ZONE_POLYGON:New("HELO BORDER TEST", heloBorderGroup)
        if heloZone then
            env.info("✓ HELO BORDER zone created successfully")
            local coord = heloZone:GetCoordinate()
            if coord then
                env.info("✓ HELO BORDER zone coordinate: " .. coord:ToStringLLDMS())
            else
                env.info("✗ HELO BORDER zone has no coordinate")
            end
        else
            env.info("✗ Failed to create HELO BORDER zone")
        end
    else
        env.info("✗ HELO BORDER group NOT found - this may be the problem!")
    end
end

-- Test 2: Check if Blue aircraft exist on the map
local function testBlueAircraft()
    env.info("=== BLUE AIRCRAFT DIAGNOSTIC ===")
    
    local BlueAircraft = SET_GROUP:New():FilterCoalitions("blue"):FilterCategoryAirplane():FilterStart()
    local blueCount = BlueAircraft:Count()
    
    env.info("Total Blue aircraft on map: " .. blueCount)
    
    if blueCount > 0 then
        env.info("Blue aircraft found:")
        BlueAircraft:ForEach(function(blueGroup)
            if blueGroup and blueGroup:IsAlive() then
                local coord = blueGroup:GetCoordinate()
                local name = blueGroup:GetName()
                if coord then
                    env.info("  - " .. name .. " at " .. coord:ToStringLLDMS())
                else
                    env.info("  - " .. name .. " (no coordinate)")
                end
            end
        end)
    else
        env.info("✗ NO BLUE AIRCRAFT FOUND - this is likely why no intercepts are launching!")
        env.info("SOLUTION: Add Blue coalition aircraft to the mission or spawn some for testing")
    end
end

-- Test 3: Check if Blue aircraft are in the detection zones
local function testBlueInZones()
    env.info("=== BLUE AIRCRAFT IN ZONES DIAGNOSTIC ===")
    
    local redBorderGroup = GROUP:FindByName("RED BORDER")
    local heloBorderGroup = GROUP:FindByName("HELO BORDER")
    
    if not redBorderGroup or not heloBorderGroup then
        env.info("✗ Cannot test zones - border groups missing")
        return
    end
    
    local redZone = ZONE_POLYGON:New("RED BORDER TEST", redBorderGroup)
    local heloZone = ZONE_POLYGON:New("HELO BORDER TEST", heloBorderGroup)
    
    local BlueAircraft = SET_GROUP:New():FilterCoalitions("blue"):FilterCategoryAirplane():FilterStart()
    local blueCount = BlueAircraft:Count()
    
    if blueCount == 0 then
        env.info("✗ No Blue aircraft to test zone containment")
        return
    end
    
    local inRedZone = 0
    local inHeloZone = 0
    
    BlueAircraft:ForEach(function(blueGroup)
        if blueGroup and blueGroup:IsAlive() then
            local coord = blueGroup:GetCoordinate()
            local name = blueGroup:GetName()
            
            if coord then
                local inRed = redZone and redZone:IsCoordinateInZone(coord)
                local inHelo = heloZone and heloZone:IsCoordinateInZone(coord)
                
                if inRed then
                    inRedZone = inRedZone + 1
                    env.info("  ✓ " .. name .. " is in RED BORDER zone")
                elseif inHelo then
                    inHeloZone = inHeloZone + 1
                    env.info("  ✓ " .. name .. " is in HELO BORDER zone")
                else
                    env.info("  - " .. name .. " is NOT in any border zone")
                end
            end
        end
    end)
    
    env.info("Summary: " .. inRedZone .. " in RED zone, " .. inHeloZone .. " in HELO zone")
    
    if inRedZone == 0 and inHeloZone == 0 then
        env.info("✗ NO BLUE AIRCRAFT IN DETECTION ZONES - this is why no intercepts are launching!")
        env.info("SOLUTION: Move Blue aircraft into the border zones or expand the zone definitions")
    end
end

-- Test 4: Check squadron templates
local function testSquadronTemplates()
    env.info("=== SQUADRON TEMPLATE DIAGNOSTIC ===")
    
    local squadronTemplates = {
        "FIGHTER_SWEEP_RED_Kilpyavr",
        "FIGHTER_SWEEP_RED_Severomorsk-1", 
        "FIGHTER_SWEEP_RED_Severomorsk-3",
        "FIGHTER_SWEEP_RED_Murmansk",
        "FIGHTER_SWEEP_RED_Monchegorsk",
        "FIGHTER_SWEEP_RED_Olenya",
        "HELO_SWEEP_RED_Afrikanda"
    }
    
    local found = 0
    local total = #squadronTemplates
    
    for _, templateName in pairs(squadronTemplates) do
        local template = GROUP:FindByName(templateName)
        if template then
            env.info("✓ Found template: " .. templateName)
            
            -- Check if template is alive (should NOT be for Late Activation)
            local isAlive = template:IsAlive()
            if isAlive then
                env.info("  ⚠ WARNING: Template is ALIVE - should be set to Late Activation")
            else
                env.info("  ✓ Template correctly set to Late Activation")
            end
            
            -- Check coalition
            local coalition = template:GetCoalition()
            if coalition == 1 then
                env.info("  ✓ Template is Red coalition")
            else
                env.info("  ✗ Template is NOT Red coalition (coalition=" .. coalition .. ")")
            end
            
            found = found + 1
        else
            env.info("✗ Missing template: " .. templateName)
        end
    end
    
    env.info("Squadron templates found: " .. found .. "/" .. total)
    
    if found == 0 then
        env.info("✗ NO SQUADRON TEMPLATES FOUND - this is why no aircraft can launch!")
        env.info("SOLUTION: Create squadron groups in Mission Editor with the correct names and set to Late Activation")
    end
end

-- Test 5: Check airbases
local function testAirbases()
    env.info("=== AIRBASE DIAGNOSTIC ===")
    
    local airbases = {
        "Kilpyavr", "Severomorsk-1", "Severomorsk-3", 
        "Murmansk International", "Monchegorsk", "Olenya", "Afrikanda"
    }
    
    local found = 0
    local redBases = 0
    
    for _, airbaseName in pairs(airbases) do
        local airbase = AIRBASE:FindByName(airbaseName)
        if airbase then
            env.info("✓ Found airbase: " .. airbaseName)
            
            local coalition = airbase:GetCoalition()
            local coalitionName = coalition == 1 and "Red" or (coalition == 2 and "Blue" or "Neutral")
            env.info("  Coalition: " .. coalitionName)
            
            if coalition == 1 then
                redBases = redBases + 1
            end
            
            found = found + 1
        else
            env.info("✗ Airbase not found: " .. airbaseName)
        end
    end
    
    env.info("Airbases found: " .. found .. "/" .. #airbases .. " (Red: " .. redBases .. ")")
end

-- Test 6: Manual threat detection test
local function testThreatDetection()
    env.info("=== THREAT DETECTION TEST ===")
    
    -- Try to manually detect threats
    local BlueAircraft = SET_GROUP:New():FilterCoalitions("blue"):FilterCategoryAirplane():FilterStart()
    local blueCount = BlueAircraft:Count()
    
    env.info("Manual threat scan - found " .. blueCount .. " blue aircraft")
    
    if blueCount > 0 then
        local redBorderGroup = GROUP:FindByName("RED BORDER")
        local heloBorderGroup = GROUP:FindByName("HELO BORDER")
        
        if redBorderGroup and heloBorderGroup then
            local redZone = ZONE_POLYGON:New("RED BORDER TEST", redBorderGroup)
            local heloZone = ZONE_POLYGON:New("HELO BORDER TEST", heloBorderGroup)
            
            local threatsInZones = 0
            
            BlueAircraft:ForEach(function(blueGroup)
                if blueGroup and blueGroup:IsAlive() then
                    local coord = blueGroup:GetCoordinate()
                    local name = blueGroup:GetName()
                    
                    if coord then
                        local inRed = redZone:IsCoordinateInZone(coord)
                        local inHelo = heloZone:IsCoordinateInZone(coord)
                        
                        if inRed or inHelo then
                            threatsInZones = threatsInZones + 1
                            local classification = "UNKNOWN"
                            local category = blueGroup:GetCategory()
                            local typeName = blueGroup:GetTypeName() or "Unknown"
                            
                            if category == Group.Category.AIRPLANE then
                                if string.find(typeName:upper(), "B-") or string.find(typeName:upper(), "BOMBER") then
                                    classification = "BOMBER"
                                elseif string.find(typeName:upper(), "A-") or string.find(typeName:upper(), "ATTACK") then
                                    classification = "ATTACK"
                                else
                                    classification = "FIGHTER"
                                end
                            elseif category == Group.Category.HELICOPTER then
                                classification = "HELICOPTER"
                            end
                            
                            env.info("  THREAT DETECTED: " .. name .. " (" .. classification .. ") in " .. (inRed and "RED BORDER" or "HELO BORDER"))
                        end
                    end
                end
            end)
            
            if threatsInZones == 0 then
                env.info("✗ No threats detected in border zones")
            else
                env.info("✓ " .. threatsInZones .. " threats detected in border zones")
            end
        end
    end
end

-- Run all diagnostic tests
local function runAllDiagnostics()
    env.info("Starting comprehensive TADC diagnostic...")
    
    testZones()
    testBlueAircraft()
    testBlueInZones()
    testSquadronTemplates()
    testAirbases()
    testThreatDetection()
    
    env.info("=== DIAGNOSTIC COMPLETE ===")
    env.info("Check the log above for any ✗ (failed) items - these are likely the cause of the problem")
end

-- Schedule the diagnostic to run after a delay
SCHEDULER:New(nil, runAllDiagnostics, {}, 3)

-- Also create a repeating diagnostic every 60 seconds for ongoing monitoring
SCHEDULER:New(nil, function()
    env.info("=== PERIODIC THREAT CHECK ===")
    testBlueInZones()
end, {}, 10, 60) -- Start after 10 seconds, repeat every 60 seconds