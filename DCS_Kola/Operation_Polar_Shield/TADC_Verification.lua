-- TADC Verification Script
-- This script provides a simple way to verify that all TADC components are properly configured
-- Run this in DCS to check for missing functions, configuration errors, etc.

-- Verification function to check if all required elements exist
local function verifyTADC()
    local errors = {}
    local warnings = {}
    
    -- Check if GCI_Config exists and has required values
    if not GCI_Config then
        table.insert(errors, "GCI_Config not found")
    else
        local requiredConfig = {
            "threatRatio", "maxSimultaneousCAP", "useEWRDetection", "ewrDetectionRadius",
            "mainLoopInterval", "mainLoopDelay", "squadronCooldown", "supplyMode",
            "defaultSquadronSize", "reservePercent", "responseDelay", "capSetupDelay",
            "capOrbitRadius", "capEngagementRange", "capZoneConstraint",
            "statusReportInterval", "engagementUpdateInterval", "fighterVsFighter",
            "fighterVsBomber", "fighterVsHelicopter", "threatTimeout", "debugLevel"
        }
        
        for _, configKey in pairs(requiredConfig) do
            if GCI_Config[configKey] == nil then
                table.insert(errors, "Missing config: GCI_Config." .. configKey)
            end
        end
    end
    
    -- Check if TADC data structure exists
    if not TADC then
        table.insert(errors, "TADC data structure not found")
    else
        local requiredTADC = {"squadrons", "activeCAPs", "threats", "missions"}
        for _, key in pairs(requiredTADC) do
            if TADC[key] == nil then
                table.insert(errors, "Missing TADC." .. key)
            end
        end
    end
    
    -- Check if zones exist
    if not CCCPBorderZone then
        table.insert(errors, "CCCPBorderZone not found")
    end
    if not HeloBorderZone then
        table.insert(errors, "HeloBorderZone not found")
    end
    
    -- Check if main functions exist
    local requiredFunctions = {
        "TADC_Log", "validateConfiguration", "mainTADCLoop", "simpleDetectThreats",
        "launchCAP", "launchInterceptMission", "maintainPersistentCAP"
    }
    
    for _, funcName in pairs(requiredFunctions) do
        if not _G[funcName] then
            table.insert(errors, "Missing function: " .. funcName)
        end
    end
    
    -- Count squadrons
    local squadronCount = 0
    if TADC and TADC.squadrons then
        for _ in pairs(TADC.squadrons) do
            squadronCount = squadronCount + 1
        end
    end
    
    -- Print results
    env.info("=== TADC VERIFICATION RESULTS ===")
    
    if #errors > 0 then
        env.error("VERIFICATION FAILED - " .. #errors .. " errors found:")
        for _, error in pairs(errors) do
            env.error("  ❌ " .. error)
        end
    else
        env.info("✅ All critical components verified successfully!")
    end
    
    if #warnings > 0 then
        env.warning("Warnings found:")
        for _, warning in pairs(warnings) do
            env.warning("  ⚠️ " .. warning)
        end
    end
    
    env.info("📊 Squadron count: " .. squadronCount)
    env.info("📊 Config debug level: " .. (GCI_Config and GCI_Config.debugLevel or "N/A"))
    env.info("=== VERIFICATION COMPLETE ===")
    
    return #errors == 0
end

-- Run verification after a short delay to ensure everything is loaded
SCHEDULER:New(nil, function()
    env.info("Starting TADC verification...")
    verifyTADC()
end, {}, 10)