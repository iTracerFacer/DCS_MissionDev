-- Enhanced CTLD System with Aircraft Type Detection (like AFAC)
-- Automatically detects and adds aircraft based on their type rather than specific names

-- Switch the tracing On
--BASE:TraceOnOff( true )

local msgTime = 15

-- =====================================================
-- CTLD CONFIGURATION
-- =====================================================

CTLD_CONFIG = {
    -- Aircraft types that can perform CTLD operations
    transportAircraft = {
        -- Helicopters
        "UH-1H", "UH-60L", "UH-60A", "Mi-8MT", "Mi-24P", "Ka-50", "Ka-50_3", 
        "SA342L", "SA342M", "SA342Mistral", "SA342Minigun", 
        "CH-47F", "CH-53E", "AH-64D_BLK_II", "Mi-26",
        -- Fixed Wing
        "C-130", "An-26B", "Yak-40", "C-47"
    },
    
    debug = true
}

-- =====================================================
-- CTLD DATA STORAGE
-- =====================================================

CTLD_DATA = {
    pilots = {},           -- Store pilot information
    blueInstance = nil,    -- Blue CTLD instance
    redInstance = nil      -- Red CTLD instance
}

-- =====================================================
-- UTILITY FUNCTIONS
-- =====================================================

function CTLD_LOG(message)
    if CTLD_CONFIG.debug then
        env.info("CTLD_AUTO: " .. tostring(message))
    end
end

function CTLD_CONTAINS(table, value)
    for i = 1, #table do
        if table[i] == value then return true end
    end
    return false
end

function CTLD_GET_GROUP_ID(unit)
    local group = unit:getGroup()
    if group then return group:getID() end
    return nil
end

-- =====================================================
-- AIRCRAFT DETECTION
-- =====================================================

function CTLD_IS_TRANSPORT(unit)
    if not unit then return false end
    local unitType = unit:getTypeName()
    CTLD_LOG("Checking aircraft type: " .. unitType)
    local result = CTLD_CONTAINS(CTLD_CONFIG.transportAircraft, unitType)
    CTLD_LOG("isTransport result for " .. unitType .. ": " .. tostring(result))
    return result
end

-- =====================================================
-- CTLD INSTANCES SETUP
-- =====================================================

-- Initialize CTLD instances without specific group names (empty arrays)
local ctld_blue = CTLD:New(coalition.side.BLUE, {}, "Transport Aircraft")
local ctld_red = CTLD:New(coalition.side.RED, {}, "Transport Aircraft")

-- Store instances globally
CTLD_DATA.blueInstance = ctld_blue
CTLD_DATA.redInstance = ctld_red

-- Scores Awarded for Dropping, Building and Repairing logistics
local pointsAwardedTroopsDeployed = 1
local pointsAwardedTroopsExtracted = 1
local pointsAwardedTroopsPickedup = 1
local pointsAwardedTroopsRTB = 2
local pointsAwardedCrateDropped = 5
local pointsAwardedCrateBuilt = 2
local pointsAwardedCrateRepair = 5

-- =====================================================
-- SUPPLY ZONES SETUP
-- =====================================================

-- Blue Coalition Supply Zones
ctld_blue:AddCTLDZone("Luostari Supply", CTLD.CargoZoneType.LOAD, SMOKECOLOR.Blue, true, true)
ctld_blue:AddCTLDZone("Ivalo Supply", CTLD.CargoZoneType.LOAD, SMOKECOLOR.Blue, true, true)
ctld_blue:AddCTLDZone("FARP-1 Supply", CTLD.CargoZoneType.LOAD, SMOKECOLOR.Blue, true, true)
ctld_blue:AddCTLDZone("Dallas FARP Supply", CTLD.CargoZoneType.LOAD, SMOKECOLOR.Blue, true, true)
ctld_blue:AddCTLDZone("Paris FARP Supply", CTLD.CargoZoneType.LOAD, SMOKECOLOR.Blue, true, true)
--ctld_blue:AddCTLDZone("Tromso Airbase", CTLD.CargoZoneType.LOAD, SMOKECOLOR.Blue, true, true)

-- Red Coalition Supply Zones  
--ctld_red:AddCTLDZone("Murmansk Airbase", CTLD.CargoZoneType.LOAD, SMOKECOLOR.Red, true, true)
--ctld_red:AddCTLDZone("Severomorsk Airbase", CTLD.CargoZoneType.LOAD, SMOKECOLOR.Red, true, true)
--ctld_red:AddCTLDZone("Pechenga Airbase", CTLD.CargoZoneType.LOAD, SMOKECOLOR.Red, true, true)
--ctld_red:AddCTLDZone("Alakurtti Airbase", CTLD.CargoZoneType.LOAD, SMOKECOLOR.Red, true, true)

-- Neutral/Contested Zones (can be used by both sides)
-- Uncomment and modify as needed for your mission
-- ctld_blue:AddCTLDZone("Contested Zone 1", CTLD.CargoZoneType.LOAD, SMOKECOLOR.Green, true, true)
-- ctld_red:AddCTLDZone("Contested Zone 1", CTLD.CargoZoneType.LOAD, SMOKECOLOR.Green, true, true)

-- Set CTLD Options for Blue Side
ctld_blue.useprefix = false -- Set to false to allow all transport aircraft
ctld_blue.CrateDistance = 100
ctld_blue.dropcratesanywhere = true
ctld_blue.maximumHoverHeight = 15
ctld_blue.minimumHoverHeight = 4
ctld_blue.forcehoverload = false
ctld_blue.hoverautoloading = true
ctld_blue.smokedistance = 10000
ctld_blue.movetroopstowpzone = true
ctld_blue.movetroopsdistance = 2000
ctld_blue.suppressmessages = false
ctld_blue.repairtime = 300
ctld_blue.buildtime = 20
ctld_blue.cratecountry = country.id.USA
ctld_blue.allowcratepickupagain = true
ctld_blue.enableslingload = false
ctld_blue.pilotmustopendoors = false
ctld_blue.SmokeColor = SMOKECOLOR.Blue
ctld_blue.FlareColor = FLARECOLOR.Green
ctld_blue.basetype = "container_cargo"
ctld_blue.droppedbeacontimeout = 600
ctld_blue.usesubcats = true
ctld_blue.placeCratesAhead = true
ctld_blue.nobuildinloadzones = true
ctld_blue.movecratesbeforebuild = false
ctld_blue.surfacetypes = {land.SurfaceType.LAND, land.SurfaceType.ROAD, land.SurfaceType.RUNWAY, land.SurfaceType.SHALLOW_WATER}

-- Set CTLD Options for Red Side (similar to Blue)
ctld_red.useprefix = false -- Set to false to allow all transport aircraft
ctld_red.CrateDistance = 100
ctld_red.dropcratesanywhere = true
ctld_red.maximumHoverHeight = 15
ctld_red.minimumHoverHeight = 4
ctld_red.forcehoverload = false
ctld_red.hoverautoloading = true
ctld_red.smokedistance = 10000
ctld_red.movetroopstowpzone = true
ctld_red.movetroopsdistance = 2000
ctld_red.suppressmessages = false
ctld_red.repairtime = 300
ctld_red.buildtime = 20
ctld_red.cratecountry = country.id.RUSSIA
ctld_red.allowcratepickupagain = true
ctld_red.enableslingload = false
ctld_red.pilotmustopendoors = false
ctld_red.SmokeColor = SMOKECOLOR.Red
ctld_red.FlareColor = FLARECOLOR.Red
ctld_red.basetype = "container_cargo"
ctld_red.droppedbeacontimeout = 600
ctld_red.usesubcats = true
ctld_red.placeCratesAhead = true
ctld_red.nobuildinloadzones = true
ctld_red.movecratesbeforebuild = false
ctld_red.surfacetypes = {land.SurfaceType.LAND, land.SurfaceType.ROAD, land.SurfaceType.RUNWAY, land.SurfaceType.SHALLOW_WATER}

-- =====================================================
-- DYNAMIC UNIT DEFINITIONS
-- =====================================================

-- Unit definitions for dynamic spawning (no templates needed!)
CTLD_UNIT_DEFINITIONS = {
    BLUE = {
        -- Infantry/Troops
        ["2 Recon"] = {
            units = {
                {type = "Soldier M4", name = "Recon-1", x = 0, y = 0},
                {type = "Soldier M4", name = "Recon-2", x = 5, y = 0}
            },
            category = "TROOPS",
            seats = 2,
            stock = 10
        },
        ["4 Anti-Air"] = {
            units = {
                {type = "Soldier stinger", name = "AA-1", x = 0, y = 0},
                {type = "Soldier stinger", name = "AA-2", x = 5, y = 0},
                {type = "Soldier stinger", name = "AA-3", x = -5, y = 0},
                {type = "Soldier stinger", name = "AA-4", x = 0, y = 5}
            },
            category = "TROOPS",
            seats = 4,
            stock = 10
        },
        ["6 Anti-Tank"] = {
            units = {
                {type = "Soldier M4", name = "AT-1", x = 0, y = 0},
                {type = "Soldier M4", name = "AT-2", x = 5, y = 0},
                {type = "Soldier M4", name = "AT-3", x = -5, y = 0},
                {type = "Soldier M4", name = "AT-4", x = 0, y = 5},
                {type = "Soldier M4", name = "AT-5", x = 0, y = -5},
                {type = "Soldier M4", name = "AT-6", x = 10, y = 0}
            },
            category = "TROOPS",
            seats = 6,
            stock = 12
        },
        
        -- Vehicles
        ["ATGM HMMWV"] = {
            units = {
                {type = "M1045 HMMWV TOW", name = "ATGM-HMMWV", x = 0, y = 0}
            },
            category = "VEHICLE",
            crates = 1,
            stock = 10,
            subcategory = "Anti-Tank"
        },
        ["IFV M2A2 Bradley"] = {
            units = {
                {type = "M-2 Bradley", name = "Bradley-IFV", x = 0, y = 0}
            },
            category = "VEHICLE",
            crates = 1,
            stock = 10,
            subcategory = "Anti-Tank"
        },
        ["MBT M1A2 Abrams"] = {
            units = {
                {type = "M-1 Abrams", name = "Abrams-MBT", x = 0, y = 0}
            },
            category = "VEHICLE",
            crates = 2,
            stock = 10,
            subcategory = "Anti-Tank"
        },
        
        -- SAM Systems
        ["SAM Avenger"] = {
            units = {
                {type = "M1097 Avenger", name = "Avenger-1", x = 0, y = 0}
            },
            category = "VEHICLE",
            crates = 2,
            stock = 8,
            subcategory = "Anti-Air"
        },
        ["SAM Hawk Site"] = {
            units = {
                {type = "Hawk pcp", name = "Hawk-PCP", x = 0, y = 0},
                {type = "Hawk tr", name = "Hawk-TR", x = 20, y = 0},
                {type = "Hawk ln", name = "Hawk-LN-1", x = -15, y = 15},
                {type = "Hawk ln", name = "Hawk-LN-2", x = -15, y = -15},
                {type = "Hawk ln", name = "Hawk-LN-3", x = -30, y = 0}
            },
            category = "VEHICLE",
            crates = 4,
            stock = 3,
            subcategory = "Anti-Air"
        },
        ["SAM Patriot Site"] = {
            units = {
                {type = "Patriot ECS", name = "Patriot-ECS", x = 0, y = 0},
                {type = "Patriot AMG", name = "Patriot-AMG", x = 15, y = 0},
                {type = "Patriot ICC", name = "Patriot-ICC", x = -15, y = 0},
                {type = "Patriot ln", name = "Patriot-LN-1", x = 25, y = 25},
                {type = "Patriot ln", name = "Patriot-LN-2", x = 25, y = -25},
                {type = "Patriot ln", name = "Patriot-LN-3", x = -25, y = 25},
                {type = "Patriot ln", name = "Patriot-LN-4", x = -25, y = -25}
            },
            category = "VEHICLE",
            crates = 8,
            stock = 2,
            subcategory = "Anti-Air"
        },
        ["EWR Roland"] = {
            units = {
                {type = "Roland ADS", name = "Roland-ADS", x = 0, y = 0},
                {type = "Roland Radar", name = "Roland-Radar", x = 15, y = 0}
            },
            category = "VEHICLE",
            crates = 1,
            stock = 5,
            subcategory = "Anti-Air"
        },
        
        -- Support Vehicles
        ["Recon HMMWV"] = {
            units = {
                {type = "M1025 HMMWV", name = "Recon-HMMWV", x = 0, y = 0}
            },
            category = "VEHICLE",
            crates = 1,
            stock = 10,
            subcategory = "Ground Ops"
        },
        ["Supply Truck"] = {
            units = {
                {type = "M 818", name = "Supply-Truck", x = 0, y = 0}
            },
            category = "VEHICLE",
            crates = 1,
            stock = 10,
            subcategory = "Ground Ops"
        },
        ["FARP Equipment"] = {
            units = {
                {type = "FARP Fuel Truck", name = "FARP-Fuel", x = 0, y = 0},
                {type = "FARP Ammo Dump Coating", name = "FARP-Ammo", x = 15, y = 0},
                {type = "FARP CP Blindage", name = "FARP-CP", x = -15, y = 0},
                {type = "FARP Tent", name = "FARP-Tent", x = 0, y = 15}
            },
            category = "VEHICLE",
            crates = 4,
            stock = 4,
            subcategory = "Ground Ops"
        }
    },
    
    RED = {
        -- Infantry/Troops
        ["2 Saboteurs"] = {
            units = {
                {type = "Soldier AK", name = "Saboteur-1", x = 0, y = 0},
                {type = "Soldier AK", name = "Saboteur-2", x = 5, y = 0}
            },
            category = "TROOPS",
            seats = 2,
            stock = 50
        },
        ["4 Anti-Air"] = {
            units = {
                {type = "Soldier AK", name = "AA-1", x = 0, y = 0},
                {type = "Soldier AK", name = "AA-2", x = 5, y = 0},
                {type = "Soldier AK", name = "AA-3", x = -5, y = 0},
                {type = "Soldier AK", name = "AA-4", x = 0, y = 5}
            },
            category = "TROOPS",
            seats = 4,
            stock = 50
        },
        ["6 Anti-Tank"] = {
            units = {
                {type = "Soldier AK", name = "AT-1", x = 0, y = 0},
                {type = "Soldier AK", name = "AT-2", x = 5, y = 0},
                {type = "Soldier AK", name = "AT-3", x = -5, y = 0},
                {type = "Soldier AK", name = "AT-4", x = 0, y = 5},
                {type = "Soldier AK", name = "AT-5", x = 0, y = -5},
                {type = "Soldier AK", name = "AT-6", x = 10, y = 0}
            },
            category = "TROOPS",
            seats = 6,
            stock = 50
        },
        
        -- Vehicles
        ["ATGM BTR-RD"] = {
            units = {
                {type = "BTR-RD", name = "BTR-RD", x = 0, y = 0}
            },
            category = "VEHICLE",
            crates = 1,
            stock = 50,
            subcategory = "Anti-Tank"
        },
        ["APC IFV BMP"] = {
            units = {
                {type = "BMP-2", name = "BMP-IFV", x = 0, y = 0}
            },
            category = "VEHICLE",
            crates = 1,
            stock = 50,
            subcategory = "Anti-Tank"
        },
        ["MBT T-90"] = {
            units = {
                {type = "T-90", name = "T90-MBT", x = 0, y = 0}
            },
            category = "VEHICLE",
            crates = 2,
            stock = 50,
            subcategory = "Anti-Tank"
        },
        
        -- SAM Systems
        ["SA-8"] = {
            units = {
                {type = "Osa 9A33 ln", name = "SA8-LN", x = 0, y = 0}
            },
            category = "VEHICLE",
            crates = 2,
            stock = 10,
            subcategory = "Anti-Air"
        },
        ["SA-11"] = {
            units = {
                {type = "SA-11 Buk CC 9S470M1", name = "SA11-CC", x = 0, y = 0},
                {type = "SA-11 Buk SR 9S18M1", name = "SA11-SR", x = 20, y = 0},
                {type = "SA-11 Buk LN 9A310M1", name = "SA11-LN-1", x = -15, y = 15},
                {type = "SA-11 Buk LN 9A310M1", name = "SA11-LN-2", x = -15, y = -15}
            },
            category = "VEHICLE",
            crates = 4,
            stock = 10,
            subcategory = "Anti-Air"
        },
        ["SA-10 Site"] = {
            units = {
                {type = "S-300PS 40B6M tr", name = "SA10-TR", x = 0, y = 0},
                {type = "S-300PS 40B6MD sr", name = "SA10-SR", x = 25, y = 0},
                {type = "S-300PS 5P85C ln", name = "SA10-LN-1", x = -20, y = 20},
                {type = "S-300PS 5P85C ln", name = "SA10-LN-2", x = -20, y = -20},
                {type = "S-300PS 5P85D ln", name = "SA10-LN-3", x = -35, y = 0},
                {type = "S-300PS 5P85D ln", name = "SA10-LN-4", x = -50, y = 20}
            },
            category = "VEHICLE",
            crates = 8,
            stock = 5,
            subcategory = "Anti-Air"
        },
        
        -- Support
        ["Supply Truck"] = {
            units = {
                {type = "ZiL-131 APA-80", name = "Supply-Truck", x = 0, y = 0}
            },
            category = "VEHICLE",
            crates = 1,
            stock = 50,
            subcategory = "Ground Ops"
        }
    }
}

-- =====================================================
-- DYNAMIC UNIT SPAWNING FUNCTIONS
-- =====================================================

-- Generate unique group name
function CTLD_GENERATE_GROUP_NAME(basename, coalition)
    local timestamp = os.time()
    local coalitionName = coalition == coalition.side.BLUE and "BLUE" or "RED"
    return string.format("%s-%s-%d-%d", coalitionName, basename, timestamp, math.random(1000, 9999))
end

-- Calculate rotated position based on helicopter heading
function CTLD_CALCULATE_ROTATED_POSITION(baseX, baseY, heading)
    local headingRad = math.rad(heading)
    local cos_h = math.cos(headingRad)
    local sin_h = math.sin(headingRad)
    
    return {
        x = baseX * cos_h - baseY * sin_h,
        y = baseX * sin_h + baseY * cos_h
    }
end

-- Create dynamic group from definition
function CTLD_CREATE_DYNAMIC_GROUP(unitDef, spawnPoint, heading, coalition)
    local groupName = CTLD_GENERATE_GROUP_NAME(unitDef.units[1].name, coalition)
    local countryId = coalition == coalition.side.BLUE and country.id.USA or country.id.RUSSIA
    
    local groupData = {
        ["name"] = groupName,
        ["task"] = "Ground Nothing",
        ["units"] = {}
    }
    
    -- Create each unit in the group with proper positioning and heading
    for i, unitInfo in ipairs(unitDef.units) do
        local rotatedPos = CTLD_CALCULATE_ROTATED_POSITION(unitInfo.x, unitInfo.y, heading)
        
        local unitData = {
            ["name"] = string.format("%s-%d", groupName, i),
            ["type"] = unitInfo.type,
            ["x"] = spawnPoint.x + rotatedPos.x,
            ["y"] = spawnPoint.z + rotatedPos.y,
            ["heading"] = math.rad(heading),
            ["skill"] = "Average",
            ["playerCanDrive"] = false
        }
        
        table.insert(groupData.units, unitData)
    end
    
    -- Spawn the group
    local success, spawnedGroup = pcall(function()
        return coalition.addGroup(countryId, Group.Category.GROUND, groupData)
    end)
    
    if success and spawnedGroup then
        CTLD_LOG("Successfully spawned dynamic group: " .. groupName)
        return spawnedGroup
    else
        CTLD_LOG("Failed to spawn dynamic group: " .. groupName)
        return nil
    end
end

-- Setup dynamic cargo using the definitions (bypassing template checks)
function CTLD_SETUP_DYNAMIC_CARGO()
    CTLD_LOG("Starting TEMPLATE-FREE dynamic cargo setup...")
    
    -- Multiple approaches to disable template checking
    ctld_blue.checkTemplatePrefixes = false
    ctld_red.checkTemplatePrefixes = false
    
    -- Force disable template validation entirely
    local originalCheckTemplates = ctld_blue._CheckTemplates
    ctld_blue._CheckTemplates = function(self, templates)
        CTLD_LOG("Bypassing template check for: " .. tostring(templates))
        return true -- Always return success
    end
    
    local originalCheckTemplatesRed = ctld_red._CheckTemplates
    ctld_red._CheckTemplates = function(self, templates)
        CTLD_LOG("Bypassing RED template check for: " .. tostring(templates))
        return true -- Always return success
    end
    
    local blueCargoCount = 0
    local redCargoCount = 0
    
    -- Setup Blue cargo with bypassed template checking
    for cargoName, unitDef in pairs(CTLD_UNIT_DEFINITIONS.BLUE) do
        CTLD_LOG("Setting up Blue cargo: " .. cargoName .. " (Category: " .. unitDef.category .. ")")
        
        -- Create dummy template entries to satisfy CTLD's internal checks
        if unitDef.category == "TROOPS" then
            -- Add to troops cargo without template validation
            if not ctld_blue.TroopsCargo then ctld_blue.TroopsCargo = {} end
            ctld_blue.TroopsCargo[cargoName] = {
                name = cargoName,
                templates = {cargoName}, -- Dummy template name
                cargoType = CTLD_CARGO.Enum.TROOPS,
                seats = unitDef.seats,
                stock = unitDef.stock,
                template_found = true -- Force template found to true
            }
            blueCargoCount = blueCargoCount + 1
            
        elseif unitDef.category == "VEHICLE" then
            -- Add to crates cargo without template validation
            if not ctld_blue.CratesCargo then ctld_blue.CratesCargo = {} end
            ctld_blue.CratesCargo[cargoName] = {
                name = cargoName,
                templates = {cargoName}, -- Dummy template name
                cargoType = CTLD_CARGO.Enum.VEHICLE,
                cratesRequired = unitDef.crates,
                stock = unitDef.stock,
                subcategory = unitDef.subcategory,
                template_found = true -- Force template found to true
            }
            blueCargoCount = blueCargoCount + 1
        end
    end
    
    -- Setup Red cargo with bypassed template checking
    for cargoName, unitDef in pairs(CTLD_UNIT_DEFINITIONS.RED) do
        CTLD_LOG("Setting up Red cargo: " .. cargoName .. " (Category: " .. unitDef.category .. ")")
        
        if unitDef.category == "TROOPS" then
            if not ctld_red.TroopsCargo then ctld_red.TroopsCargo = {} end
            ctld_red.TroopsCargo[cargoName] = {
                name = cargoName,
                templates = {cargoName},
                cargoType = CTLD_CARGO.Enum.TROOPS,
                seats = unitDef.seats,
                stock = unitDef.stock,
                template_found = true
            }
            redCargoCount = redCargoCount + 1
            
        elseif unitDef.category == "VEHICLE" then
            if not ctld_red.CratesCargo then ctld_red.CratesCargo = {} end
            ctld_red.CratesCargo[cargoName] = {
                name = cargoName,
                templates = {cargoName},
                cargoType = CTLD_CARGO.Enum.VEHICLE,
                cratesRequired = unitDef.crates,
                stock = unitDef.stock,
                subcategory = unitDef.subcategory,
                template_found = true
            }
            redCargoCount = redCargoCount + 1
        end
    end
    
    -- Set engineer search range
    ctld_blue.EngineerSearch = 2000
    ctld_red.EngineerSearch = 2000
    
    CTLD_LOG("TEMPLATE-FREE dynamic cargo setup complete - Blue: " .. blueCargoCount .. " items, Red: " .. redCargoCount .. " items")
    
    -- Alternative approach: Try using standard CTLD functions with overridden template checking
    CTLD_LOG("Attempting fallback cargo registration...")
    
    -- Try the standard approach but with template checking disabled
    pcall(function()
        for cargoName, unitDef in pairs(CTLD_UNIT_DEFINITIONS.BLUE) do
            if unitDef.category == "TROOPS" then
                ctld_blue:AddTroopsCargo(cargoName, {cargoName}, CTLD_CARGO.Enum.TROOPS, unitDef.seats, nil, unitDef.stock)
            elseif unitDef.category == "VEHICLE" then
                ctld_blue:AddCratesCargo(cargoName, {cargoName}, CTLD_CARGO.Enum.VEHICLE, unitDef.crates, nil, unitDef.stock, unitDef.subcategory)
            end
        end
        
        for cargoName, unitDef in pairs(CTLD_UNIT_DEFINITIONS.RED) do
            if unitDef.category == "TROOPS" then
                ctld_red:AddTroopsCargo(cargoName, {cargoName}, CTLD_CARGO.Enum.TROOPS, unitDef.seats, nil, unitDef.stock)
            elseif unitDef.category == "VEHICLE" then
                ctld_red:AddCratesCargo(cargoName, {cargoName}, CTLD_CARGO.Enum.VEHICLE, unitDef.crates, nil, unitDef.stock, unitDef.subcategory)
            end
        end
        
        CTLD_LOG("Fallback cargo registration completed successfully")
    end)
    
    -- Force rebuild F10 menus with the new cargo
    if ctld_blue._buildF10Menu then
        ctld_blue:_buildF10Menu()
        CTLD_LOG("Rebuilt Blue F10 menu")
    end
    
    if ctld_red._buildF10Menu then
        ctld_red:_buildF10Menu()
        CTLD_LOG("Rebuilt Red F10 menu")
    end
end

-- =====================================================
-- AIRCRAFT MANAGEMENT FUNCTIONS
-- =====================================================

function CTLD_ADD_TRANSPORT_PILOT(unit)
    if not unit then 
        CTLD_LOG("CTLD_ADD_TRANSPORT_PILOT: unit is nil")
        return 
    end
    
    local unitName = unit:getName()
    local unitType = unit:getTypeName()
    local unitCoalition = unit:getCoalition()  -- Renamed to avoid conflict
    local groupId = CTLD_GET_GROUP_ID(unit)
    local playerName = unit:getPlayerName()
    
    CTLD_LOG("Attempting to add transport pilot: " .. unitName .. " (Type: " .. unitType .. ", Coalition: " .. unitCoalition .. ", Player: " .. tostring(playerName) .. ")")
    
    if not groupId then 
        CTLD_LOG("No group ID found for unit: " .. unitName)
        return 
    end
    
    -- Check if pilot is already registered
    if CTLD_DATA.pilots[unitName] then
        CTLD_LOG("Transport pilot " .. unitName .. " already registered, skipping")
        return
    end
    
    -- Store pilot data
    CTLD_DATA.pilots[unitName] = {
        name = unitName,
        unit = unit,
        coalition = unitCoalition,  -- Use renamed variable
        groupId = groupId,
        playerName = playerName
    }
    
    -- Get the appropriate CTLD instance
    local ctldInstance = nil
    if unitCoalition == coalition.side.BLUE then  -- Now coalition.side works properly
        ctldInstance = CTLD_DATA.blueInstance
    elseif unitCoalition == coalition.side.RED then
        ctldInstance = CTLD_DATA.redInstance
    end
    
    if ctldInstance then
        -- Force add the group to CTLD if it's not already there
        local groupName = unit:getGroup():getName()
        CTLD_LOG("Adding group to CTLD: " .. groupName)
        
        -- Add the group name to the CTLD instance
        if not ctldInstance.TransportGroups then
            ctldInstance.TransportGroups = {}
        end
        
        -- Check if group is already in the list
        local groupExists = false
        for _, existingGroup in ipairs(ctldInstance.TransportGroups) do
            if existingGroup == groupName then
                groupExists = true
                break
            end
        end
        
        if not groupExists then
            table.insert(ctldInstance.TransportGroups, groupName)
            CTLD_LOG("Added group " .. groupName .. " to CTLD TransportGroups")
        end
        
        -- Send welcome message with more detail
        local message = string.format("CTLD System Active\nAircraft: %s\nType: %s\nUse F10 Radio Menu → CTLD\n\nAvailable cargo types loaded!", 
            unitName, unitType)
        trigger.action.outTextForGroup(groupId, message, 20)
        
        -- Also send to coalition
        trigger.action.outTextForCoalition(unitCoalition, "CTLD Transport " .. unitName .. " (" .. unitType .. ") is now active!", 10)
        
        CTLD_LOG("Transport pilot " .. unitName .. " added successfully to CTLD system with group: " .. groupName)
    else
        CTLD_LOG("ERROR: Could not find CTLD instance for coalition: " .. unitCoalition)
    end
end

function CTLD_REMOVE_TRANSPORT_PILOT(unitName)
    if not CTLD_DATA.pilots[unitName] then return end
    
    CTLD_DATA.pilots[unitName] = nil
    CTLD_LOG("Removed transport pilot: " .. unitName)
end

-- =====================================================
-- EVENT HANDLER (similar to AFAC)
-- =====================================================

CTLD_EventHandler = {}

function CTLD_EventHandler:onEvent(event)
    if event.id == world.event.S_EVENT_BIRTH then
        local unit = event.initiator
        
        if unit and Object.getCategory(unit) == Object.Category.UNIT then
            local objDesc = unit:getDesc()
            if objDesc.category == Unit.Category.AIRPLANE or objDesc.category == Unit.Category.HELICOPTER then
                if CTLD_IS_TRANSPORT(unit) then
                    timer.scheduleFunction(function(args)
                        local u = args[1]
                        if u and u:isActive() then
                            CTLD_ADD_TRANSPORT_PILOT(u)
                        end
                    end, {unit}, timer.getTime() + 2)
                end
            end
        end
    end
    
    if event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT then
        local unit = event.initiator
        
        if unit and Object.getCategory(unit) == Object.Category.UNIT then
            local objDesc = unit:getDesc()
            if objDesc.category == Unit.Category.AIRPLANE or objDesc.category == Unit.Category.HELICOPTER then
                if CTLD_IS_TRANSPORT(unit) then
                    local unitName = unit:getName()
                    
                    if not CTLD_DATA.pilots[unitName] then
                        timer.scheduleFunction(function(args)
                            local u = args[1]
                            if u and u:isActive() then
                                CTLD_ADD_TRANSPORT_PILOT(u)
                            end
                        end, {unit}, timer.getTime() + 1)
                    end
                end
            end
        end
    end
    
    if event.id == world.event.S_EVENT_UNIT_LOST or event.id == world.event.S_EVENT_CRASH then
        local unit = event.initiator
        if unit then
            local unitName = unit:getName()
            CTLD_REMOVE_TRANSPORT_PILOT(unitName)
        end
    end
end

-- =====================================================
-- SCORING AND EVENT FUNCTIONS (from original CTLD)
-- =====================================================

-- Blue CTLD Event Functions
function ctld_blue:OnAfterTroopsDeployed(From, Event, To, Group, Unit, Troops)
    if Unit then
        local PlayerName = Unit:GetPlayerName()
        local vname = Troops:GetName()
        local points = pointsAwardedTroopsDeployed
        MESSAGE:New("Pilot " .. PlayerName .. " has deployed " .. vname .. " to the field!", msgTime, "[ Mission Info ]", false):ToBlue()
        -- Add scoring if you have a scoring system
        CTLD_LOG("Troops deployed by " .. PlayerName)
    end
end

function ctld_blue:OnAfterTroopsExtracted(From, Event, To, Group, Unit, Cargo)
    if Unit then
        local PlayerName = Unit:GetPlayerName()
        local vname = Cargo:GetName()
        local points = pointsAwardedTroopsExtracted
        MESSAGE:New("Pilot " .. PlayerName .. " has extracted " .. vname .. " from the field!", msgTime, "[ Mission Info ]", false):ToBlue()
        CTLD_LOG("Troops extracted by " .. PlayerName)
    end
end

function ctld_blue:OnBeforeCratesBuild(From, Event, To, Group, Unit, CargoName)
    if Unit and CargoName then
        local PlayerName = Unit:GetPlayerName()
        local unitCoalition = Unit:GetCoalition()
        local helicopterPos = Unit:GetCoordinate()
        local helicopterHeading = Unit:GetHeading()
        
        CTLD_LOG("OnBeforeCratesBuild called for: " .. CargoName .. " by " .. PlayerName)
        
        -- Find the unit definition in our custom definitions
        local unitDef = nil
        local coalitionDefs = unitCoalition == coalition.side.BLUE and CTLD_UNIT_DEFINITIONS.BLUE or CTLD_UNIT_DEFINITIONS.RED
        
        for cargoName, definition in pairs(coalitionDefs) do
            if cargoName == CargoName then
                unitDef = definition
                CTLD_LOG("Found unit definition for: " .. CargoName)
                break
            end
        end
        
        if unitDef and unitDef.category == "VEHICLE" then
            -- Create spawn point slightly ahead of helicopter
            local spawnPoint = helicopterPos:Translate(20, helicopterHeading)
            
            -- Spawn the dynamic group with helicopter's heading
            local spawnedGroup = CTLD_CREATE_DYNAMIC_GROUP(unitDef, spawnPoint, math.deg(helicopterHeading), unitCoalition)
            
            if spawnedGroup then
                CTLD_LOG("Dynamic spawn successful: " .. CargoName .. " by " .. PlayerName .. " facing " .. math.deg(helicopterHeading) .. " degrees")
                
                -- Create visual effects
                trigger.action.smoke(spawnPoint:GetVec3(), 4) -- Blue smoke
                
                local message = string.format("Dynamic %s deployed by %s and oriented %d degrees!", 
                    CargoName, PlayerName, math.deg(helicopterHeading))
                MESSAGE:New(message, msgTime, "[ Dynamic Spawn ]", false):ToCoalition(unitCoalition)
                
                -- Prevent CTLD from trying to spawn its own template
                return false -- Cancel the normal CTLD build process
            else
                CTLD_LOG("Dynamic spawn failed for: " .. CargoName)
            end
        else
            CTLD_LOG("No unit definition found for: " .. CargoName .. " or not a vehicle type")
        end
    end
end

-- Handle troop deployment dynamically
function ctld_blue:OnBeforeTroopsDeployed(From, Event, To, Group, Unit, TroopName)
    if Unit and TroopName then
        local PlayerName = Unit:GetPlayerName()
        local unitCoalition = Unit:GetCoalition()
        local helicopterPos = Unit:GetCoordinate()
        local helicopterHeading = Unit:GetHeading()
        
        CTLD_LOG("OnBeforeTroopsDeployed called for: " .. TroopName .. " by " .. PlayerName)
        
        -- Find the unit definition
        local unitDef = nil
        local coalitionDefs = unitCoalition == coalition.side.BLUE and CTLD_UNIT_DEFINITIONS.BLUE or CTLD_UNIT_DEFINITIONS.RED
        
        for cargoName, definition in pairs(coalitionDefs) do
            if cargoName == TroopName then
                unitDef = definition
                break
            end
        end
        
        if unitDef and unitDef.category == "TROOPS" then
            -- Create spawn point slightly ahead of helicopter
            local spawnPoint = helicopterPos:Translate(10, helicopterHeading)
            
            -- Spawn the dynamic troop group
            local spawnedGroup = CTLD_CREATE_DYNAMIC_GROUP(unitDef, spawnPoint, math.deg(helicopterHeading), unitCoalition)
            
            if spawnedGroup then
                CTLD_LOG("Dynamic troop spawn successful: " .. TroopName .. " by " .. PlayerName)
                
                local message = string.format("Dynamic %s deployed by %s!", TroopName, PlayerName)
                MESSAGE:New(message, msgTime, "[ Dynamic Troop Spawn ]", false):ToCoalition(unitCoalition)
                
                return false -- Cancel normal CTLD troop deployment
            end
        end
    end
end

function ctld_blue:OnAfterCratesBuild(From, Event, To, Group, Unit, Vehicle)
    if Unit then
        local points = pointsAwardedCrateBuilt
        local PlayerName = Unit:GetPlayerName()
        local vname = Vehicle:GetName()

        MESSAGE:New("Pilot " .. PlayerName .. " has deployed " .. vname .. " to the field!", msgTime, "[ Mission Info ]", false):ToBlue()
        
        -- FOB creation logic
        if string.match(vname, "FARP", 1, true) then
            local Coord = Vehicle:GetCoordinate():GetVec2()
            local mCoord = Vehicle:GetCoordinate()
            local zonename = "FARP-" .. math.random(1, 10000)
            local farpzone = ZONE_RADIUS:New(zonename, Coord, 500)
            local farpmarker = MARKER:New(mCoord, "FORWARD ARMING & REFUELING POINT:\nBUILT BY: " .. PlayerName .. "\n\nTransport aircraft may pick up troops and equipment from this location."):ReadOnly():ToCoalition(coalition.side.BLUE)
            farpzone:DrawZone(2, {.25, .63, .79}, 1, {0, 0, 0}, 0.25, 2, true)
            ctld_blue:AddCTLDZone(zonename, CTLD.CargoZoneType.LOAD, SMOKECOLOR.Blue, true, true)
            MESSAGE:New("Pilot " .. PlayerName .. " has created a new FARP loading zone! See your F10 Map for marker!", msgTime, "[ Mission Info ]", false):ToBlue()
        end
        
        CTLD_LOG("Built: " .. vname .. " by " .. PlayerName)
    end
end

-- Red CTLD Event Functions (similar structure)
function ctld_red:OnAfterTroopsDeployed(From, Event, To, Group, Unit, Troops)
    if Unit then
        local PlayerName = Unit:GetPlayerName()
        local vname = Troops:GetName()
        MESSAGE:New("Pilot " .. PlayerName .. " has deployed " .. vname .. " to the field!", msgTime, "[ Mission Info ]", false):ToRed()
        CTLD_LOG("Troops deployed by " .. PlayerName)
    end
end

function ctld_red:OnAfterTroopsExtracted(From, Event, To, Group, Unit, Cargo)
    if Unit then
        local PlayerName = Unit:GetPlayerName()
        local vname = Cargo:GetName()
        MESSAGE:New("Pilot " .. PlayerName .. " has extracted " .. vname .. " from the field!", msgTime, "[ Mission Info ]", false):ToRed()
        CTLD_LOG("Troops extracted by " .. PlayerName)
    end
end

function ctld_red:OnBeforeCratesBuild(From, Event, To, Group, Unit, CargoName)
    if Unit and CargoName then
        local PlayerName = Unit:GetPlayerName()
        local unitCoalition = Unit:GetCoalition()
        local helicopterPos = Unit:GetCoordinate()
        local helicopterHeading = Unit:GetHeading()
        
        CTLD_LOG("Red OnBeforeCratesBuild called for: " .. CargoName .. " by " .. PlayerName)
        
        -- Find the unit definition
        local unitDef = nil
        local coalitionDefs = unitCoalition == coalition.side.BLUE and CTLD_UNIT_DEFINITIONS.BLUE or CTLD_UNIT_DEFINITIONS.RED
        
        for cargoName, definition in pairs(coalitionDefs) do
            if cargoName == CargoName then
                unitDef = definition
                break
            end
        end
        
        if unitDef and unitDef.category == "VEHICLE" then
            -- Create spawn point slightly ahead of helicopter
            local spawnPoint = helicopterPos:Translate(20, helicopterHeading)
            
            -- Spawn the dynamic group with helicopter's heading
            local spawnedGroup = CTLD_CREATE_DYNAMIC_GROUP(unitDef, spawnPoint, math.deg(helicopterHeading), unitCoalition)
            
            if spawnedGroup then
                CTLD_LOG("Red dynamic spawn successful: " .. CargoName .. " by " .. PlayerName .. " facing " .. math.deg(helicopterHeading) .. " degrees")
                
                -- Create visual effects
                trigger.action.smoke(spawnPoint:GetVec3(), 1) -- Red smoke
                
                local message = string.format("Dynamic %s deployed by %s and oriented %d degrees!", 
                    CargoName, PlayerName, math.deg(helicopterHeading))
                MESSAGE:New(message, msgTime, "[ Dynamic Spawn ]", false):ToCoalition(unitCoalition)
                
                return false -- Cancel normal CTLD build
            else
                CTLD_LOG("Red dynamic spawn failed for: " .. CargoName)
            end
        end
    end
end

-- Handle Red troop deployment dynamically
function ctld_red:OnBeforeTroopsDeployed(From, Event, To, Group, Unit, TroopName)
    if Unit and TroopName then
        local PlayerName = Unit:GetPlayerName()
        local unitCoalition = Unit:GetCoalition()
        local helicopterPos = Unit:GetCoordinate()
        local helicopterHeading = Unit:GetHeading()
        
        CTLD_LOG("Red OnBeforeTroopsDeployed called for: " .. TroopName .. " by " .. PlayerName)
        
        -- Find the unit definition
        local unitDef = nil
        local coalitionDefs = unitCoalition == coalition.side.BLUE and CTLD_UNIT_DEFINITIONS.BLUE or CTLD_UNIT_DEFINITIONS.RED
        
        for cargoName, definition in pairs(coalitionDefs) do
            if cargoName == TroopName then
                unitDef = definition
                break
            end
        end
        
        if unitDef and unitDef.category == "TROOPS" then
            -- Create spawn point slightly ahead of helicopter
            local spawnPoint = helicopterPos:Translate(10, helicopterHeading)
            
            -- Spawn the dynamic troop group
            local spawnedGroup = CTLD_CREATE_DYNAMIC_GROUP(unitDef, spawnPoint, math.deg(helicopterHeading), unitCoalition)
            
            if spawnedGroup then
                CTLD_LOG("Red dynamic troop spawn successful: " .. TroopName .. " by " .. PlayerName)
                
                local message = string.format("Dynamic %s deployed by %s!", TroopName, PlayerName)
                MESSAGE:New(message, msgTime, "[ Dynamic Troop Spawn ]", false):ToCoalition(unitCoalition)
                
                return false -- Cancel normal CTLD troop deployment
            end
        end
    end
end

-- =====================================================
-- INITIALIZATION
-- =====================================================

function CTLD_CHECK_EXISTING_TRANSPORTS()
    for coalitionId = 1, 2 do
        local airGroups = coalition.getGroups(coalitionId, Group.Category.AIRPLANE)
        local heliGroups = coalition.getGroups(coalitionId, Group.Category.HELICOPTER)
        
        local allGroups = {}
        for _, group in ipairs(airGroups) do table.insert(allGroups, group) end
        for _, group in ipairs(heliGroups) do table.insert(allGroups, group) end
        
        for _, group in ipairs(allGroups) do
            local units = group:getUnits()
            if units then
                for _, unit in ipairs(units) do
                    if unit and unit:isActive() and CTLD_IS_TRANSPORT(unit) then
                        local unitName = unit:getName()
                        if unit:getPlayerName() and not CTLD_DATA.pilots[unitName] then
                            CTLD_ADD_TRANSPORT_PILOT(unit)
                        end
                    end
                end
            end
        end
    end
end

-- Register event handler
world.addEventHandler(CTLD_EventHandler)

-- Initialize CTLD instances first
CTLD_LOG("Starting CTLD instances...")
ctld_blue:__Start(2)
ctld_red:__Start(2)

-- Setup dynamic cargo definitions after CTLD starts
timer.scheduleFunction(function()
    CTLD_SETUP_DYNAMIC_CARGO()
    CTLD_LOG("CTLD instances started and cargo configured")
    trigger.action.outText("Enhanced CTLD System ready - Transport aircraft can now use CTLD!", 15)
end, nil, timer.getTime() + 3)

-- Check for existing pilots after everything is set up
timer.scheduleFunction(CTLD_CHECK_EXISTING_TRANSPORTS, nil, timer.getTime() + 5)

-- Periodic check for new pilots
function CTLD_PERIODIC_CHECK()
    CTLD_CHECK_EXISTING_TRANSPORTS()
    timer.scheduleFunction(CTLD_PERIODIC_CHECK, nil, timer.getTime() + 10)
end

timer.scheduleFunction(CTLD_PERIODIC_CHECK, nil, timer.getTime() + 15)

-- Add debug status function
function CTLD_DEBUG_STATUS()
    local message = "=== CTLD DEBUG STATUS ===\n\n"
    
    local pilotCount = 0
    for _ in pairs(CTLD_DATA.pilots) do pilotCount = pilotCount + 1 end
    message = message .. "Registered Pilots: " .. pilotCount .. "\n"
    
    for unitName, pilotData in pairs(CTLD_DATA.pilots) do
        message = message .. "- " .. unitName .. " (Coalition: " .. pilotData.coalition .. ")\n"
    end
    
    message = message .. "\nBlue CTLD Groups: "
    if ctld_blue.TransportGroups then
        local blueCount = 0
        for _ in pairs(ctld_blue.TransportGroups) do blueCount = blueCount + 1 end
        message = message .. blueCount .. "\n"
        for _, groupName in ipairs(ctld_blue.TransportGroups) do
            message = message .. "- " .. groupName .. "\n"
        end
    else
        message = message .. "0 (TransportGroups not initialized)\n"
    end
    
    message = message .. "\nRed CTLD Groups: "
    if ctld_red.TransportGroups then
        local redCount = 0
        for _ in pairs(ctld_red.TransportGroups) do redCount = redCount + 1 end
        message = message .. redCount .. "\n"
        for _, groupName in ipairs(ctld_red.TransportGroups) do
            message = message .. "- " .. groupName .. "\n"
        end
    else
        message = message .. "0 (TransportGroups not initialized)\n"
    end
    
    trigger.action.outText(message, 30)
    CTLD_LOG(message)
end

-- Schedule debug status after initialization
timer.scheduleFunction(CTLD_DEBUG_STATUS, nil, timer.getTime() + 10)

CTLD_LOG("Enhanced CTLD System with Aircraft Type Detection initialized successfully")
trigger.action.outText("Enhanced CTLD System loading - Transport aircraft will be automatically detected!", 10)