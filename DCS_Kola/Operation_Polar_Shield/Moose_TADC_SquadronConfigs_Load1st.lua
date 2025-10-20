
--[[ THIS FILE MUST BE LOADED BEFORE THE MAIN Moose_TADC.lua SCRIPT
═══════════════════════════════════════════════════════════════════════════════
                              SQUADRON CONFIGURATION
═══════════════════════════════════════════════════════════════════════════════

INSTRUCTIONS:
1. Create fighter aircraft templates for BOTH coalitions in the mission editor
2. Place them at or near the airbases you want them to operate from  
3. Configure RED squadrons in RED_SQUADRON_CONFIG
4. Configure BLUE squadrons in BLUE_SQUADRON_CONFIG

TEMPLATE NAMING SUGGESTIONS:
• RED: "RED_CAP_Batumi_F15", "RED_INTERCEPT_Senaki_MiG29"
• BLUE: "BLUE_CAP_Nellis_F16", "BLUE_INTERCEPT_Creech_F22"
• Include coalition and airbase name for easy identification

AIRBASE NAMES:
• Use exact names as they appear in DCS (case sensitive)
• RED examples: "Batumi", "Senaki", "Gudauta"
• BLUE examples: "Nellis AFB", "McCarran International", "Tonopah Test Range"
• Find airbase names in the mission editor

AIRCRAFT NUMBERS:
• Set realistic numbers based on mission requirements
• Consider aircraft consumption and cargo replenishment
• Balance between realism and gameplay performance

ZONE-BASED AREAS OF RESPONSIBILITY:
• Create zones in mission editor (MOOSE polygons, circles, etc.)
• primaryZone: Squadron's main area (full response)
• secondaryZone: Backup/support area (reduced response)
• tertiaryZone: Emergency fallback area (enhanced response)
• Leave zones as nil for global threat response
• Multiple squadrons can share overlapping zones
• Use zone names exactly as they appear in mission editor

ZONE BEHAVIOR EXAMPLES:
• Border Defense: primaryZone = "SECTOR_ALPHA", secondaryZone = "BUFFER_ZONE"
• Base Defense: tertiaryZone = "BASE_PERIMETER", enableFallback = true
• Layered Defense: Different zones per squadron with overlap
• Emergency Response: High tertiaryResponse ratio for critical areas
]]

-- ═══════════════════════════════════════════════════════════════════════════
--                            RED COALITION SQUADRONS
-- ═══════════════════════════════════════════════════════════════════════════

RED_SQUADRON_CONFIG = {
    --[[ EXAMPLE RED SQUADRON - CUSTOMIZE FOR YOUR MISSION
    {
        templateName = "RED_CAP_Batumi_F15",     -- Template name from mission editor
        displayName = "Batumi F-15C CAP",        -- Human-readable name for logs
        airbaseName = "Batumi",                  -- Exact airbase name from DCS
        aircraft = 12,                           -- Maximum aircraft in squadron
        skill = AI.Skill.GOOD,                   -- AI skill level
        altitude = 20000,                        -- Patrol altitude (feet)
        speed = 350,                             -- Patrol speed (knots)
        patrolTime = 25,                         -- Time on station (minutes)
        type = "FIGHTER"

                -- Zone-based Areas of Responsibility (optional - leave nil for global response)
        primaryZone = "RED_BORDER",                       -- Main responsibility area (zone name from mission editor)
        secondaryZone = nil,                     -- Secondary coverage area (zone name)
        tertiaryZone = nil,                      -- Emergency/fallback zone (zone name)
        
        -- Zone behavior settings (optional - uses defaults if not specified)
        zoneConfig = {
            primaryResponse = 1.0,               -- Intercept ratio multiplier in primary zone
            secondaryResponse = 0.6,             -- Intercept ratio multiplier in secondary zone  
            tertiaryResponse = 1.4,              -- Intercept ratio multiplier in tertiary zone
            maxRange = 200,                      -- Maximum engagement range from airbase (nm)
            enableFallback = false,              -- Auto-switch to tertiary when base threatened
            priorityThreshold = 4,               -- Min aircraft count for "major threat"
            ignoreLowPriority = false,           -- Ignore threats below threshold in secondary zones
        }
    },
    ]]
    
    -- ADD YOUR RED SQUADRONS HERE
    {
        templateName = "FIGHTER_SWEEP_RED_Kilpyavr-MiG29A",            -- Change to your RED template name
        displayName = "Kilpyavr CAP MiG-29A",             -- Change to your preferred name
        airbaseName = "Kilpyavr",       -- Change to your RED airbase
        aircraft = 12,                           -- Adjust aircraft count
        skill = AI.Skill.ACE,                    -- AVERAGE, GOOD, HIGH, EXCELLENT, ACE
        altitude = 15400,                        -- Patrol altitude (feet)
        speed = 312,                             -- Patrol speed (knots)
        patrolTime = 32,                         -- Time on station (minutes)
        type = "FIGHTER",
        
        -- Zone-based Areas of Responsibility (optional - leave nil for global response)
        primaryZone = "RED BORDER",                       -- Main responsibility area (zone name from mission editor)
        secondaryZone = nil,                     -- Secondary coverage area (zone name)
        tertiaryZone = nil,                      -- Emergency/fallback zone (zone name)
        
        -- Zone behavior settings (optional - uses defaults if not specified)
        zoneConfig = {
            primaryResponse = 1.0,               -- Intercept ratio multiplier in primary zone
            secondaryResponse = 0.6,             -- Intercept ratio multiplier in secondary zone  
            tertiaryResponse = 1.4,              -- Intercept ratio multiplier in tertiary zone
            maxRange = 200,                      -- Maximum engagement range from airbase (nm)
            enableFallback = false,              -- Auto-switch to tertiary when base threatened
            priorityThreshold = 4,               -- Min aircraft count for "major threat"
            ignoreLowPriority = false,           -- Ignore threats below threshold in secondary zones
        }
    },

        {
        templateName = "FIGHTER_SWEEP_RED_Kilpyavr-MiG29S",            -- Change to your RED template name
        displayName = "Kilpyavr CAP MiG-29S",             -- Change to your preferred name
        airbaseName = "Kilpyavr",       -- Change to your RED airbase
        aircraft = 12,                           -- Adjust aircraft count
        skill = AI.Skill.ACE,                    -- AVERAGE, GOOD, HIGH, EXCELLENT, ACE
        altitude = 15400,                        -- Patrol altitude (feet)
        speed = 312,                             -- Patrol speed (knots)
        patrolTime = 32,                         -- Time on station (minutes)
        type = "FIGHTER",
        
        -- Zone-based Areas of Responsibility (optional - leave nil for global response)
        primaryZone = "RED BORDER",                       -- Main responsibility area (zone name from mission editor)
        secondaryZone = nil,                     -- Secondary coverage area (zone name)
        tertiaryZone = nil,                      -- Emergency/fallback zone (zone name)
        
        -- Zone behavior settings (optional - uses defaults if not specified)
        zoneConfig = {
            primaryResponse = 1.0,               -- Intercept ratio multiplier in primary zone
            secondaryResponse = 0.6,             -- Intercept ratio multiplier in secondary zone  
            tertiaryResponse = 1.4,              -- Intercept ratio multiplier in tertiary zone
            maxRange = 200,                      -- Maximum engagement range from airbase (nm)
            enableFallback = false,              -- Auto-switch to tertiary when base threatened
            priorityThreshold = 4,               -- Min aircraft count for "major threat"
            ignoreLowPriority = false,           -- Ignore threats below threshold in secondary zones
        }
    },

    {
        templateName = "FIGHTER_SWEEP_RED_Severomorsk-1-MiG23",            -- Change to your RED template name
        displayName = "Severomorsk-1 CAP MiG-23",             -- Change to your preferred name
        airbaseName = "Severomorsk-1",       -- Change to your RED airbase
        aircraft = 10,                           -- Adjust aircraft count
        skill = AI.Skill.ACE,                    -- AVERAGE, GOOD, HIGH, EXCELLENT, ACE
        altitude = 18800,                        -- Patrol altitude (feet)
        speed = 420,                             -- Patrol speed (knots)
        patrolTime = 23,                         -- Time on station (minutes)
        type = "FIGHTER",
        
        -- Zone-based Areas of Responsibility (optional - leave nil for global response)
        primaryZone = "RED BORDER",                       -- Main responsibility area (zone name from mission editor)
        secondaryZone = nil,                     -- Secondary coverage area (zone name)
        tertiaryZone = nil,                      -- Emergency/fallback zone (zone name)
        
        -- Zone behavior settings (optional - uses defaults if not specified)
        zoneConfig = {
            primaryResponse = 1.0,               -- Intercept ratio multiplier in primary zone
            secondaryResponse = 0.6,             -- Intercept ratio multiplier in secondary zone  
            tertiaryResponse = 1.4,              -- Intercept ratio multiplier in tertiary zone
            maxRange = 200,                      -- Maximum engagement range from airbase (nm)
            enableFallback = false,              -- Auto-switch to tertiary when base threatened
            priorityThreshold = 4,               -- Min aircraft count for "major threat"
            ignoreLowPriority = false,           -- Ignore threats below threshold in secondary zones
        }
    },

        {
        templateName = "FIGHTER_SWEEP_RED_Severomorsk-1-MiG25",            -- Change to your RED template name
        displayName = "Severomorsk-1 CAP MiG-25",             -- Change to your preferred name
        airbaseName = "Severomorsk-1",       -- Change to your RED airbase
        aircraft = 10,                           -- Adjust aircraft count
        skill = AI.Skill.ACE,                    -- AVERAGE, GOOD, HIGH, EXCELLENT, ACE
        altitude = 18800,                        -- Patrol altitude (feet)
        speed = 420,                             -- Patrol speed (knots)
        patrolTime = 23,                         -- Time on station (minutes)
        type = "FIGHTER",
        
        -- Zone-based Areas of Responsibility (optional - leave nil for global response)
        primaryZone = "RED BORDER",                       -- Main responsibility area (zone name from mission editor)
        secondaryZone = nil,                     -- Secondary coverage area (zone name)
        tertiaryZone = nil,                      -- Emergency/fallback zone (zone name)
        
        -- Zone behavior settings (optional - uses defaults if not specified)
        zoneConfig = {
            primaryResponse = 1.0,               -- Intercept ratio multiplier in primary zone
            secondaryResponse = 0.6,             -- Intercept ratio multiplier in secondary zone  
            tertiaryResponse = 1.4,              -- Intercept ratio multiplier in tertiary zone
            maxRange = 200,                      -- Maximum engagement range from airbase (nm)
            enableFallback = false,              -- Auto-switch to tertiary when base threatened
            priorityThreshold = 4,               -- Min aircraft count for "major threat"
            ignoreLowPriority = false,           -- Ignore threats below threshold in secondary zones
        }
    },

    {
        templateName = "FIGHTER_SWEEP_RED_Severomorsk-3-SU27",            -- Change to your RED template name
        displayName = "Severomorsk-3 CAP SU-27",             -- Change to your preferred name
        airbaseName = "Severomorsk-3",       -- Change to your RED airbase
        aircraft = 15,                           -- Adjust aircraft count
        skill = AI.Skill.ACE,                    -- AVERAGE, GOOD, HIGH, EXCELLENT, ACE
        altitude = 26700,                        -- Patrol altitude (feet)
        speed = 335,                             -- Patrol speed (knots)
        patrolTime = 28,                         -- Time on station (minutes)
        type = "FIGHTER",
        
        -- Zone-based Areas of Responsibility (optional - leave nil for global response)
        primaryZone = "RED BORDER",                       -- Main responsibility area (zone name from mission editor)
        secondaryZone = nil,                     -- Secondary coverage area (zone name)
        tertiaryZone = nil,                      -- Emergency/fallback zone (zone name)
        
        -- Zone behavior settings (optional - uses defaults if not specified)
        zoneConfig = {
            primaryResponse = 1.0,               -- Intercept ratio multiplier in primary zone
            secondaryResponse = 0.6,             -- Intercept ratio multiplier in secondary zone  
            tertiaryResponse = 1.4,              -- Intercept ratio multiplier in tertiary zone
            maxRange = 200,                      -- Maximum engagement range from airbase (nm)
            enableFallback = false,              -- Auto-switch to tertiary when base threatened
            priorityThreshold = 4,               -- Min aircraft count for "major threat"
            ignoreLowPriority = false,           -- Ignore threats below threshold in secondary zones
        }
    },

        {
        templateName = "FIGHTER_SWEEP_RED_Severomorsk-3-MiG-21",            -- Change to your RED template name
        displayName = "Severomorsk-3 CAP MiG-21",             -- Change to your preferred name
        airbaseName = "Severomorsk-3",       -- Change to your RED airbase
        aircraft = 15,                           -- Adjust aircraft count
        skill = AI.Skill.ACE,                    -- AVERAGE, GOOD, HIGH, EXCELLENT, ACE
        altitude = 26700,                        -- Patrol altitude (feet)
        speed = 335,                             -- Patrol speed (knots)
        patrolTime = 28,                         -- Time on station (minutes)
        type = "FIGHTER",
        
        -- Zone-based Areas of Responsibility (optional - leave nil for global response)
        primaryZone = "RED BORDER",                       -- Main responsibility area (zone name from mission editor)
        secondaryZone = nil,                     -- Secondary coverage area (zone name)
        tertiaryZone = nil,                      -- Emergency/fallback zone (zone name)
        
        -- Zone behavior settings (optional - uses defaults if not specified)
        zoneConfig = {
            primaryResponse = 1.0,               -- Intercept ratio multiplier in primary zone
            secondaryResponse = 0.6,             -- Intercept ratio multiplier in secondary zone  
            tertiaryResponse = 1.4,              -- Intercept ratio multiplier in tertiary zone
            maxRange = 200,                      -- Maximum engagement range from airbase (nm)
            enableFallback = false,              -- Auto-switch to tertiary when base threatened
            priorityThreshold = 4,               -- Min aircraft count for "major threat"
            ignoreLowPriority = false,           -- Ignore threats below threshold in secondary zones
        }
    },

    {
        templateName = "FIGHTER_SWEEP_RED_Murmansk-JF17",            -- Change to your RED template name
        displayName = "Murmansk CAP JF-17",             -- Change to your preferred name
        airbaseName = "Murmansk International",       -- Change to your RED airbase
        aircraft = 8,                           -- Adjust aircraft count
        skill = AI.Skill.ACE,                    -- AVERAGE, GOOD, HIGH, EXCELLENT, ACE
        altitude = 22100,                        -- Patrol altitude (feet)
        speed = 390,                             -- Patrol speed (knots)
        patrolTime = 20,                         -- Time on station (minutes)
        type = "FIGHTER",
        
        -- Zone-based Areas of Responsibility (optional - leave nil for global response)
        primaryZone = "RED BORDER",                       -- Main responsibility area (zone name from mission editor)
        secondaryZone = nil,                     -- Secondary coverage area (zone name)
        tertiaryZone = nil,                      -- Emergency/fallback zone (zone name)
        
        -- Zone behavior settings (optional - uses defaults if not specified)
        zoneConfig = {
            primaryResponse = 1.0,               -- Intercept ratio multiplier in primary zone
            secondaryResponse = 0.6,             -- Intercept ratio multiplier in secondary zone  
            tertiaryResponse = 1.4,              -- Intercept ratio multiplier in tertiary zone
            maxRange = 200,                      -- Maximum engagement range from airbase (nm)
            enableFallback = false,              -- Auto-switch to tertiary when base threatened
            priorityThreshold = 4,               -- Min aircraft count for "major threat"
            ignoreLowPriority = false,           -- Ignore threats below threshold in secondary zones
        }
    },    

        {
        templateName = "FIGHTER_SWEEP_RED_Murmansk-MiG29A",            -- Change to your RED template name
        displayName = "Murmansk CAP MiG-29A",             -- Change to your preferred name
        airbaseName = "Murmansk International",       -- Change to your RED airbase
        aircraft = 8,                           -- Adjust aircraft count
        skill = AI.Skill.ACE,                    -- AVERAGE, GOOD, HIGH, EXCELLENT, ACE
        altitude = 22100,                        -- Patrol altitude (feet)
        speed = 390,                             -- Patrol speed (knots)
        patrolTime = 20,                         -- Time on station (minutes)
        type = "FIGHTER",
        
        -- Zone-based Areas of Responsibility (optional - leave nil for global response)
        primaryZone = "RED BORDER",                       -- Main responsibility area (zone name from mission editor)
        secondaryZone = nil,                     -- Secondary coverage area (zone name)
        tertiaryZone = nil,                      -- Emergency/fallback zone (zone name)
        
        -- Zone behavior settings (optional - uses defaults if not specified)
        zoneConfig = {
            primaryResponse = 1.0,               -- Intercept ratio multiplier in primary zone
            secondaryResponse = 0.6,             -- Intercept ratio multiplier in secondary zone  
            tertiaryResponse = 1.4,              -- Intercept ratio multiplier in tertiary zone
            maxRange = 200,                      -- Maximum engagement range from airbase (nm)
            enableFallback = false,              -- Auto-switch to tertiary when base threatened
            priorityThreshold = 4,               -- Min aircraft count for "major threat"
            ignoreLowPriority = false,           -- Ignore threats below threshold in secondary zones
        }
    },    

    {
        templateName = "FIGHTER_SWEEP_RED_Monchegorsk-F4",            -- Change to your RED template name
        displayName = "Monchegorsk CAP F-4",             -- Change to your preferred name
        airbaseName = "Monchegorsk",       -- Change to your RED airbase
        aircraft = 16,                           -- Adjust aircraft count
        skill = AI.Skill.ACE,                    -- AVERAGE, GOOD, HIGH, EXCELLENT, ACE
        altitude = 12000,                        -- Patrol altitude (feet)
        speed = 305,                             -- Patrol speed (knots)
        patrolTime = 35,                         -- Time on station (minutes)
        type = "FIGHTER",
        
        -- Zone-based Areas of Responsibility (optional - leave nil for global response)
        primaryZone = "RED BORDER",                       -- Main responsibility area (zone name from mission editor)
        secondaryZone = nil,                     -- Secondary coverage area (zone name)
        tertiaryZone = nil,                      -- Emergency/fallback zone (zone name)
        
        -- Zone behavior settings (optional - uses defaults if not specified)
        zoneConfig = {
            primaryResponse = 1.0,               -- Intercept ratio multiplier in primary zone
            secondaryResponse = 0.6,             -- Intercept ratio multiplier in secondary zone  
            tertiaryResponse = 1.4,              -- Intercept ratio multiplier in tertiary zone
            maxRange = 200,                      -- Maximum engagement range from airbase (nm)
            enableFallback = false,              -- Auto-switch to tertiary when base threatened
            priorityThreshold = 4,               -- Min aircraft count for "major threat"
            ignoreLowPriority = false,           -- Ignore threats below threshold in secondary zones
        }
    },  
    
     {
        templateName = "FIGHTER_SWEEP_RED_Monchegorsk-F5",            -- Change to your RED template name
        displayName = "Monchegorsk CAP F-5",             -- Change to your preferred name
        airbaseName = "Monchegorsk",       -- Change to your RED airbase
        aircraft = 16,                           -- Adjust aircraft count
        skill = AI.Skill.ACE,                    -- AVERAGE, GOOD, HIGH, EXCELLENT, ACE
        altitude = 15000,                        -- Patrol altitude (feet)
        speed = 305,                             -- Patrol speed (knots)
        patrolTime = 35,                         -- Time on station (minutes)
        type = "FIGHTER",
        
        -- Zone-based Areas of Responsibility (optional - leave nil for global response)
        primaryZone = "RED BORDER",                       -- Main responsibility area (zone name from mission editor)
        secondaryZone = nil,                     -- Secondary coverage area (zone name)
        tertiaryZone = nil,                      -- Emergency/fallback zone (zone name)
        
        -- Zone behavior settings (optional - uses defaults if not specified)
        zoneConfig = {
            primaryResponse = 1.0,               -- Intercept ratio multiplier in primary zone
            secondaryResponse = 0.6,             -- Intercept ratio multiplier in secondary zone  
            tertiaryResponse = 1.4,              -- Intercept ratio multiplier in tertiary zone
            maxRange = 200,                      -- Maximum engagement range from airbase (nm)
            enableFallback = false,              -- Auto-switch to tertiary when base threatened
            priorityThreshold = 4,               -- Min aircraft count for "major threat"
            ignoreLowPriority = false,           -- Ignore threats below threshold in secondary zones
        }
    },  

    {
        templateName = "FIGHTER_SWEEP_RED_Olenya-MiG21",            -- Change to your RED template name
        displayName = "Olenya CAP MiG-21",             -- Change to your preferred name
        airbaseName = "Olenya",       -- Change to your RED airbase
        aircraft = 12,                           -- Adjust aircraft count
        skill = AI.Skill.ACE,                    -- AVERAGE, GOOD, HIGH, EXCELLENT, ACE
        altitude = 17800,                        -- Patrol altitude (feet)
        speed = 445,                             -- Patrol speed (knots)
        patrolTime = 27,                         -- Time on station (minutes)
        type = "FIGHTER",
        
        -- Zone-based Areas of Responsibility (optional - leave nil for global response)
        primaryZone = "RED BORDER",                       -- Main responsibility area (zone name from mission editor)
        secondaryZone = nil,                     -- Secondary coverage area (zone name)
        tertiaryZone = nil,                      -- Emergency/fallback zone (zone name)
        
        -- Zone behavior settings (optional - uses defaults if not specified)
        zoneConfig = {
            primaryResponse = 1.0,               -- Intercept ratio multiplier in primary zone
            secondaryResponse = 0.6,             -- Intercept ratio multiplier in secondary zone  
            tertiaryResponse = 1.4,              -- Intercept ratio multiplier in tertiary zone
            maxRange = 200,                      -- Maximum engagement range from airbase (nm)
            enableFallback = false,              -- Auto-switch to tertiary when base threatened
            priorityThreshold = 4,               -- Min aircraft count for "major threat"
            ignoreLowPriority = false,           -- Ignore threats below threshold in secondary zones
        }
    }, 

        {
        templateName = "FIGHTER_SWEEP_RED_Olenya-MiG31",            -- Change to your RED template name
        displayName = "Olenya CAP MiG-31",             -- Change to your preferred name
        airbaseName = "Olenya",       -- Change to your RED airbase
        aircraft = 12,                           -- Adjust aircraft count
        skill = AI.Skill.ACE,                    -- AVERAGE, GOOD, HIGH, EXCELLENT, ACE
        altitude = 17800,                        -- Patrol altitude (feet)
        speed = 445,                             -- Patrol speed (knots)
        patrolTime = 27,                         -- Time on station (minutes)
        type = "FIGHTER",
        
        -- Zone-based Areas of Responsibility (optional - leave nil for global response)
        primaryZone = "RED BORDER",                       -- Main responsibility area (zone name from mission editor)
        secondaryZone = nil,                     -- Secondary coverage area (zone name)
        tertiaryZone = nil,                      -- Emergency/fallback zone (zone name)
        
        -- Zone behavior settings (optional - uses defaults if not specified)
        zoneConfig = {
            primaryResponse = 1.0,               -- Intercept ratio multiplier in primary zone
            secondaryResponse = 0.6,             -- Intercept ratio multiplier in secondary zone  
            tertiaryResponse = 1.4,              -- Intercept ratio multiplier in tertiary zone
            maxRange = 200,                      -- Maximum engagement range from airbase (nm)
            enableFallback = false,              -- Auto-switch to tertiary when base threatened
            priorityThreshold = 4,               -- Min aircraft count for "major threat"
            ignoreLowPriority = false,           -- Ignore threats below threshold in secondary zones
        }
    }, 
    
}

-- ═══════════════════════════════════════════════════════════════════════════
--                           BLUE COALITION SQUADRONS
-- ═══════════════════════════════════════════════════════════════════════════

BLUE_SQUADRON_CONFIG = {
    --[[ EXAMPLE BLUE SQUADRON - CUSTOMIZE FOR YOUR MISSION
    {
        templateName = "BLUE_CAP_Nellis_F16",    -- Template name from mission editor
        displayName = "Nellis F-16C CAP",        -- Human-readable name for logs
        airbaseName = "Nellis AFB",              -- Exact airbase name from DCS
        aircraft = 14,                           -- Maximum aircraft in squadron
        skill = AI.Skill.EXCELLENT,              -- AI skill level
        altitude = 22000,                        -- Patrol altitude (feet)
        speed = 380,                             -- Patrol speed (knots)
        patrolTime = 28,                         -- Time on station (minutes)
        type = "FIGHTER"                         -- Aircraft type
    },
    ]]
    
    -- ADD YOUR BLUE SQUADRONS HERE
 
    {
        templateName = "FIGHTER_SWEEP_BLUE_Luostari",            -- Change to your BLUE template name
        displayName = "Luostari CAP",             -- Change to your preferred name
        airbaseName = "Luostari Pechenga",                 -- Change to your BLUE airbase
        aircraft = 10,                           -- Adjust aircraft count
        skill = AI.Skill.EXCELLENT,              -- AVERAGE, GOOD, HIGH, EXCELLENT
        altitude = 18000,                        -- Patrol altitude (feet)
        speed = 320,                             -- Patrol speed (knots)
        patrolTime = 22,                         -- Time on station (minutes)
        type = "FIGHTER",
        
        -- Zone-based Areas of Responsibility (optional - leave nil for global response)
        primaryZone = "BLUE BORDER",             -- Main responsibility area (zone name from mission editor)
        secondaryZone = nil,                     -- Secondary coverage area (zone name)
        tertiaryZone = nil,                      -- Emergency/fallback zone (zone name)
        
        -- Zone behavior settings (optional - uses defaults if not specified)
        zoneConfig = {
            primaryResponse = 1.0,               -- Intercept ratio multiplier in primary zone
            secondaryResponse = 0.6,             -- Intercept ratio multiplier in secondary zone  
            tertiaryResponse = 1.4,              -- Intercept ratio multiplier in tertiary zone
            maxRange = 200,                      -- Maximum engagement range from airbase (nm)
            enableFallback = true,               -- Auto-switch to tertiary when base threatened
            priorityThreshold = 4,               -- Min aircraft count for "major threat"
            ignoreLowPriority = false,           -- Ignore threats below threshold in secondary zones
        }
    },

    {
        templateName = "FIGHTER_SWEEP_BLUE_Ivalo",             -- Change to your BLUE template name
        displayName = "Ivalo CAP",              -- Change to your preferred name
        airbaseName = "Ivalo",                  -- Change to your BLUE airbase
        aircraft = 10,                           -- Adjust aircraft count
        skill = AI.Skill.EXCELLENT,              -- AVERAGE, GOOD, HIGH, EXCELLENT
        altitude = 18000,                        -- Patrol altitude (feet)
        speed = 320,                             -- Patrol speed (knots)
        patrolTime = 22,                         -- Time on station (minutes)
        type = "FIGHTER",
        
        -- Zone-based Areas of Responsibility (optional - leave nil for global response)
        primaryZone = "BLUE BORDER",           -- Main responsibility area (zone name from mission editor)
        secondaryZone = nil,           -- Secondary coverage area (zone name)
        tertiaryZone = nil,          -- Emergency/fallback zone (zone name)
        
        -- Zone behavior settings (optional - uses defaults if not specified)
        zoneConfig = {
            primaryResponse = 1.0,               -- Intercept ratio multiplier in primary zone
            secondaryResponse = 0.6,             -- Intercept ratio multiplier in secondary zone  
            tertiaryResponse = 1.4,              -- Intercept ratio multiplier in tertiary zone
            maxRange = 200,                      -- Maximum engagement range from airbase (nm)
            enableFallback = true,               -- Auto-switch to tertiary when base threatened
            priorityThreshold = 4,               -- Min aircraft count for "major threat"
            ignoreLowPriority = false,           -- Ignore threats below threshold in secondary zones
        }
    },

    {
        templateName = "FIGHTER_SWEEP_BLUE_Alakurtti",             -- Change to your BLUE template name
        displayName = "Alakurtti CAP",              -- Change to your preferred name
        airbaseName = "Alakurtti",                  -- Change to your BLUE airbase
        aircraft = 10,                           -- Adjust aircraft count
        skill = AI.Skill.EXCELLENT,              -- AVERAGE, GOOD, HIGH, EXCELLENT
        altitude = 18000,                        -- Patrol altitude (feet)
        speed = 320,                             -- Patrol speed (knots)
        patrolTime = 22,                         -- Time on station (minutes)
        type = "FIGHTER",
        
        -- Zone-based Areas of Responsibility (optional - leave nil for global response)
        primaryZone = "BLUE BORDER",           -- Main responsibility area (zone name from mission editor)
        secondaryZone = nil,           -- Secondary coverage area (zone name)
        tertiaryZone = nil,          -- Emergency/fallback zone (zone name)
        
        -- Zone behavior settings (optional - uses defaults if not specified)
        zoneConfig = {
            primaryResponse = 1.0,               -- Intercept ratio multiplier in primary zone
            secondaryResponse = 0.6,             -- Intercept ratio multiplier in secondary zone  
            tertiaryResponse = 1.4,              -- Intercept ratio multiplier in tertiary zone
            maxRange = 200,                      -- Maximum engagement range from airbase (nm)
            enableFallback = true,               -- Auto-switch to tertiary when base threatened
            priorityThreshold = 4,               -- Min aircraft count for "major threat"
            ignoreLowPriority = false,           -- Ignore threats below threshold in secondary zones
        }
    },
}


