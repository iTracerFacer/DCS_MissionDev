-- This script takes Layouts orginally created by Redkite: https://www.youtube.com/user/RedKiteRender/ 
-- and rotates through the layouts to spawn them on the carrier deck.
-- Adds a menu item to clear the deck of all spawned objects.

local RotateLayoutInterval = 300 -- Time in seconds to rotate through the layouts


local function CarrierCleanDeck()
    
    do
        local statObj = coalition.getStaticObjects(2) 					--1 Red coalition 2 blue coalition
            for i, static in pairs(statObj) do
                local staticName = static:getName()
                    if string.match(staticName, "8temp.*") then
                        static:destroy()				-- removes the object
                    end
            end
        end

    do
        local statObj = coalition.getStaticObjects(2) 					--1 Red coalition 2 blue coalition
            for i, static in pairs(statObj) do
                local staticName = static:getName()
                    if string.match(staticName, "8temp Block.*") then
                        static:destroy()				-- removes the object
                    end
            end
        end

        do
            local statObj = coalition.getStaticObjects(2) 					--1 Red coalition 2 blue coalition
                for i, static in pairs(statObj) do
                    local staticName = static:getName()
                        if string.match(staticName, "4temp Block.*") then
                            static:destroy()				-- removes the object
                        end
                end
            end

    do
        local statObj = coalition.getStaticObjects(2) 					--1 Red coalition 2 blue coalition
            for i, static in pairs(statObj) do
                local staticName = static:getName()
                    if string.match(staticName, "4temp.*") then
                        static:destroy()				-- removes the object
                    end
            end
        end

    do
        local statObj = coalition.getStaticObjects(2) 					--1 Red coalition 2 blue coalition
            for i, static in pairs(statObj) do
                local staticName = static:getName()
                    if string.match(staticName, "MassRecoverCat.*") then
                        static:destroy()				-- removes the object
                    end
            end
        end
end

local function CarrierClearDeck8Spawns()
    env.info("Clearing Deck 8 Spawns")
    CarrierCleanDeck()
    -- Created by Redkite: https://www.youtube.com/user/RedKiteRender/

    local staticObj = {

        ["name"] = "8temp EL1 Hornet 2", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VFA-37",
                                            ["category"] = "Planes",
                                            ["type"] = "FA-18C_hornet",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 31.035356269975,
                                                ["angle"] = 4.7123889803847,
                                                ["x"] = 23.392320767991,
                                            }, -- end of ["offsets"]
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "8temp EL1 Hornet 1", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VFA-37",
                                            ["category"] = "Planes",
                                            ["type"] = "FA-18C_hornet",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 31.61437411001,
                                                ["angle"] = 4.7123889803847,
                                                ["x"] = 33.698838333992,
                                            }, -- end of ["offsets"]
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "8temp Finger Seahawk", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "standard",
                                            ["category"] = "Helicopters",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -25.023610410048,
                                                ["angle"] = 1.7976891295542,
                                                ["x"] = -120.511512843,
                                            }, -- end of ["offsets"]
                                            ["type"] = "SH-60B",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "8temp Corral Crane", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["category"] = "ADEquipment",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 33.281995239959,
                                                ["angle"] = 4.6600291028249,
                                                ["x"] = 0.755692206003,
                                            }, -- end of ["offsets"]
                                            ["type"] = "AS32-36A",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "8temp Point Firetruck", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["category"] = "ADEquipment",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 32.424999079958,
                                                ["angle"] = 5.4279739737024,
                                                ["x"] = 72.724640796994,
                                            }, -- end of ["offsets"]
                                            ["type"] = "AS32-p25",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "8temp Junk Yard Tug", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["category"] = "ADEquipment",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 30.242116749985,
                                                ["angle"] = 2.4958208303519,
                                                ["x"] = -79.610005513998,
                                            }, -- end of ["offsets"]
                                            ["type"] = "AS32-31A",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************

    local staticObj = {

        ["name"] = "8temp Corral E2", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "E-2D Demo",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 30.665721859958,
                                                ["angle"] = 4.6949356878647,
                                                ["x"] = 8.8025239199924,
                                            }, -- end of ["offsets"]
                                            ["type"] = "E-2C",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************

    local staticObj = {

        ["name"] = "8temp Point Hornet", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VFA-37",
                                            ["category"] = "Planes",
                                            ["type"] = "FA-18C_hornet",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 34.190822379955,
                                                ["angle"] = 3.3335788713092,
                                                ["x"] = 61.561528349994,
                                            }, -- end of ["offsets"]
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "8temp LSO Station 3", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -22.370473980031,
                                                ["angle"] = 2.4434609527921,
                                                ["x"] = -130.61201797701,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_lso_usa",
                                            ["type"] = "Carrier LSO Personell",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {
        ["name"] = "8temp LSO Station 1", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -21.789118479996,
                                                ["angle"] = 4.2935099599061,
                                                ["x"] = -129.42353100701,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_lso1_usa",
                                            ["type"] = "Carrier LSO Personell 1",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {
        ["name"] = "8temp LSO Station 2", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "white",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -22.656188270019,
                                                ["angle"] = 1.850049007114,
                                                ["x"] = -129.497732263,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {
        ["name"] = "8temp Point Tech 3", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "white",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 31.799837369996,
                                                ["angle"] = 1.850049007114,
                                                ["x"] = 58.869844022993,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {
        ["name"] = "8temp Point Tech 2", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "purple",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 36.657607259986,
                                                ["angle"] = 5.9341194567807,
                                                ["x"] = 60.15744568099,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {
        ["name"] = "8temp Point Tech 1", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "purple",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 32.502165549959,
                                                ["angle"] = 2.460914245312,
                                                ["x"] = 67.356309497001,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {
        ["name"] = "8temp Corral Tech 1", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "yellow",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 25.203805239988,
                                                ["angle"] = 4.7472955654246,
                                                ["x"] = 15.325497041995,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {
        ["name"] = "8temp Corral Tech 2", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "yellow",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 24.753144659975,
                                                ["angle"] = 5.218534463463,
                                                ["x"] = 13.844755134996,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {
        ["name"] = "8temp Junk Yard Seaman", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 31.255831669958,
                                                ["angle"] = 4.7472955654246,
                                                ["x"] = -78.473079361007,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_seaman_USA",
                                            ["type"] = "Carrier Seaman",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {
        ["name"] = "8temp Corral Tech 2 #001", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "yellow",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 19.767758169968,
                                                ["angle"] = 1.5882496193148,
                                                ["x"] = -19.085825937,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {
        ["name"] = "8temp JY Seaman #001", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -35.76436746004,
                                                ["angle"] = 1.6580627893946,
                                                ["x"] = -87.794107105001,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = tshipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {
        ["name"] = "8temp JY Seaman #002", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "green",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -33.335796030005,
                                                ["angle"] = 3.6651914291881,
                                                ["x"] = -89.908392819008,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {
        ["name"] = "8temp Point Firetruck #001", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["category"] = "ADEquipment",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 18.819578160008,
                                                ["angle"] = 4.1713369122664,
                                                ["x"] = -0.2022494480043,
                                            }, -- end of ["offsets"]
                                            ["type"] = "AS32-31A",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {
        ["name"] = "8temp Corral Tech 2 #002", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "yellow",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 19.479165099969,
                                                ["angle"] = 5.1312680008633,
                                                ["x"] = -2.0930653510004,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************

    local staticObj = {
        ["name"] = "8temp Corral Tech 2 #003", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "yellow",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 17.940128899994,
                                                ["angle"] = 1.0471975511966,
                                                ["x"] = -2.3569001290016,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {
        ["name"] = "8temp Patio Tug", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["category"] = "ADEquipment",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 29.150888629956,
                                                ["angle"] = 5.1138147083434,
                                                ["x"] = -111.66933041,
                                            }, -- end of ["offsets"]
                                            ["type"] = "AS32-31A",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {
        ["name"] = "8temp Patio Tech", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "yellow",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 32.040782110009,
                                                ["angle"] = 4.6425758103049,
                                                ["x"] = -111.053451471,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)
end

local function CarrierClearDeck4Spawns()
    env.info("Clearing Deck 4 Spawns")
    CarrierCleanDeck()
    -- Created by Redkite: https://www.youtube.com/user/RedKiteRender/

    local staticObj = {

        ["groupId"] = 400,		-- ids of the unit we're spawning (will auto increment if id taken)
        ["unitId"] = 401,
        ["rate"] = 30,
        ["name"] = "4temp EL1 Hornet 1", -- unit name (Name this something identifiable if you wish to remove it later)

        ["type"] = "FA-18C_hornet", 			-- unit, category and livery of unit to place.
        ["category"] = "Planes",
        ["livery_id"] = "VFA-37",

        ["y"] = -274433.54379664,
        ["heading"] = 37.55948550292,		-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -90767.765053252,

        ["offsets"] = {				-- The offsets that choose where on the deck it will spawn
            ["y"] = 31.035356269975,
            ["angle"] = 4.7123889803847,
            ["x"] = 23.392320767991
        }, -- end of ["offsets"]
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************



    local staticObj = {

        ["groupId"] = 401,		-- ids of the unit we're spawning (will auto increment if id taken)
        ["unitId"] = 401,
        ["rate"] = 30,
        ["name"] = "4temp EL1 Hornet 2", -- unit name (Name this something identifiable if you wish to remove it later)

        ["type"] = "FA-18C_hornet", 			-- unit, category and livery of unit to place.
        ["category"] = "Planes",
        ["livery_id"] = "VFA-37",

        ["y"] = 274432.9647788,
        ["heading"] =  4.7123889803847,		-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] =  -90757.458535686,

        ["offsets"] = {				-- The offsets that choose where on the deck it will spawn
            ["y"] = 31.61437411001,
            ["angle"] = 4.7123889803847,
            ["x"] = 33.698838333992,
        }, -- end of ["offsets"]
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************



    local staticObj = {

        ["groupId"] = 403,		-- ids of the unit we're spawning (will auto increment if id taken)
        ["unitId"] = 403,
        ["rate"] = 30,
        ["name"] = "4temp EL2 S3", -- unit name (Name this something identifiable if you wish to remove it later)

        ["type"] = "S-3B Tanker", 			-- unit, category and livery of unit to place.
        ["category"] = "Planes",
        ["livery_id"] = "usaf standard",
        
        ["offsets"] = {				-- The offsets that choose where on the deck it will spawn
            ["y"] = 29.84889531997,
            ["angle"] =  4.4505895925855,
            ["x"] = -14.761768433003,
        }, -- end of ["offsets"]

        ["y"] = -274434.73025759,	-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] =  -90805.919142453,
        ["heading"] =  4.4505895925855,	

        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************

    local staticObj = {
        
    -- Segment you need to change start  
        ["groupId"] = 1,		-- id's of the unit we're spawning (will auto increment if id taken)
        ["unitId"] = 1,
        ["name"] = "4temp EL2 Hornet", -- unit name (Name this something identifiable if you wish to remove it later)
        
        
    
        ["livery_id"] = "VFA-37",
        ["category"] = "Planes",
        ["offsets"] = {				-- The offsets that choose where on the deck it will spawn
            ["y"] = 31.382766969968,
            ["angle"] = 4.7123889803847,
            ["x"] = -25.013570722003,
        }, -- end of ["offsets"]
        ["type"] = "FA-18C_hornet", 			-- unit, category and livery of unit to place.
    -- Segment you need to change end


        ["x"] = -90816.170944742,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["y"] = -274433.19638594,
        ["heading"] = 4.7123889803847,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************


    local staticObj = {

    -- Segment you need to change start  

        ["name"] = "4temp Finger Seahawk", -- unit name (Name this something identifiable if you wish to remove it later)


        ["livery_id"] = "standard",
        ["category"] = "Helicopters",
        ["offsets"] = {				-- The offsets that choose where on the deck it will spawn
            ["y"] = -25.023610410048,
            ["angle"] = 1.7976891295542,
            ["x"] = -120.511512843,
        }, -- end of ["offsets"]
        ["type"] = "SH-60B",			-- unit, category and livery of unit to place.
    -- Segment you need to change end

    -- these can be left as is, but are required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************


    local staticObj = {

    -- Segment you need to change start  

        ["name"] = "4temp Corral Crane", -- unit name (Name this something identifiable if you wish to remove it later)


        ["category"] = "ADEquipment",
        ["offsets"] = {				-- The offsets that choose where on the deck it will spawn
            ["y"] = 33.351427629997,
            ["angle"] = 4.6600291028249,
            ["x"] = -0.92642854900623,
        }, -- end of ["offsets"]
        ["type"] = "AS32-36A",			-- unit, category and livery of unit to place.
    -- Segment you need to change end

    -- these can be left as is, but are required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************

    local staticObj = {

    -- Segment you need to change start  

        ["name"] = "4temp Point Firetruck", -- unit name (Name this something identifiable if you wish to remove it later)


        ["category"] = "ADEquipment",
        ["offsets"] = {				-- The offsets that choose where on the deck it will spawn
                                                ["y"] = 32.424999079958,
                                                ["angle"] = 5.4279739737024,
                                                ["x"] = 72.724640796994,
        }, -- end of ["offsets"]
        ["type"] = "AS32-p25",			-- unit, category and livery of unit to place.
    -- Segment you need to change end

    -- these can be left as is, but are required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************

    local staticObj = {
        
    -- Segment you need to change start  

        ["name"] = "4temp Junk Yard Tug", -- unit name (Name this something identifiable if you wish to remove it later)


        ["category"] = "ADEquipment",
        ["offsets"] = {				-- The offsets that choose where on the deck it will spawn
                                                ["y"] = 30.242116749985,
                                                ["angle"] = 2.4958208303519,
                                                ["x"] = -79.610005513998,
        }, -- end of ["offsets"]
        ["type"] = "AS32-31A",			-- unit, category and livery of unit to place.
    -- Segment you need to change end

    -- these can be left as is, but are required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)


    -- ********************************************************

    local staticObj = {
    -- Segment you need to change start  

        ["name"] = "4temp EL4 Tomcat 1", -- unit name (Name this something identifiable if you wish to remove it later)

                                            ["livery_id"] = "VF-102 Diamondbacks",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -32.180430089997,
                                                ["angle"] = 1.9373154697137,
                                                ["x"] = -98.393250321998,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14B",
    -- Segment you need to change end

    -- these can be left as is, but are required.
    --	["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************


    local staticObj = {

        ["name"] = "4temp EL4 Tomcat 2", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                        ["livery_id"] = "VF-102 Diamondbacks 102",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -32.924847350048,
                                                ["angle"] = 1.7627825445143,
                                                ["x"] = -110.574623714,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14B",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************

    local staticObj = {

        ["name"] = "4temp Corral E2", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                        ["livery_id"] = "E-2D Demo",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 30.665721859958,
                                                ["angle"] = 4.6949356878647,
                                                ["x"] = 8.8025239199924,
                                            }, -- end of ["offsets"]
                                            ["type"] = "E-2C",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************

    local staticObj = {

        ["name"] = "4temp Point Hornet", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VFA-37",
                                            ["category"] = "Planes",
                                            ["type"] = "FA-18C_hornet",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 34.190822379955,
                                                ["angle"] = 3.3335788713092,
                                                ["x"] = 61.561528349994,
                                            }, -- end of ["offsets"]
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************


    local staticObj = {

        ["name"] = "4temp LSO Station 3", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -22.370473980031,
                                                ["angle"] = 2.4434609527921,
                                                ["x"] = -130.61201797701,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_lso_usa",
                                            ["type"] = "Carrier LSO Personell",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************



    local staticObj = {

        ["name"] = "4temp LSO Station 1", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -21.789118479996,
                                                ["angle"] = 4.2935099599061,
                                                ["x"] = -129.42353100701,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_lso1_usa",
                                            ["type"] = "Carrier LSO Personell 1",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************


    local staticObj = {

        ["name"] = "4temp LSO Station 2", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                        ["livery_id"] = "white",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -22.656188270019,
                                                ["angle"] = 1.850049007114,
                                                ["x"] = -129.497732263,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
                                            ["unitId"] = 17,
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************

    local staticObj = {

        ["name"] = "4temp Point Tech 3", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "white",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 31.799837369996,
                                                ["angle"] = 1.850049007114,
                                                ["x"] = 58.869844022993,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)
    -- ********************************************************
    local staticObj = {

        ["name"] = "4temp Point Tech 2", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "purple",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 36.657607259986,
                                                ["angle"] = 5.9341194567807,
                                                ["x"] = 60.15744568099,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)
    -- ********************************************************
    local staticObj = {

        ["name"] = "4temp Point Tech 1", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "purple",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 32.502165549959,
                                                ["angle"] = 2.460914245312,
                                                ["x"] = 67.356309497001,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)
    -- ********************************************************
    local staticObj = {

        ["name"] = "4temp Corral Tech 1", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "yellow",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 25.203805239988,
                                                ["angle"] = 4.7472955654246,
                                                ["x"] = 15.325497041995,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)
    -- ********************************************************
    local staticObj = {

        ["name"] = "4temp Corral Tech 2", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "yellow",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 24.753144659975,
                                                ["angle"] = 5.218534463463,
                                                ["x"] = 13.844755134996,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)
    -- ********************************************************
    local staticObj = {

        ["name"] = "4temp Junk Yard Seaman", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 31.255831669958,
                                                ["angle"] = 4.7472955654246,
                                                ["x"] = -78.473079361007,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_seaman_USA",
                                            ["type"] = "Carrier Seaman",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)
    -- ********************************************************
    local staticObj = {

        ["name"] = "4temp EL2 Tug", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["category"] = "ADEquipment",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 25.035044669989,
                                                ["angle"] = 2.4958208303519,
                                                ["x"] = -22.810439552006,
                                            }, -- end of ["offsets"]
                                            ["type"] = "AS32-31A",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)
    -- ********************************************************

end

local function CarrierMassRecoveryCat2Tomcats()
    env.info("MassRecoveryCat2Tomcats")
    CarrierCleanDeck()

    
        -- Created by Redkite: https://www.youtube.com/user/RedKiteRender/

    local staticObj = {

        ["name"] = "MassRecoverCat 2 Tomcat 1", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VF-102 Diamondbacks",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -8.5679547744221,
                                                ["angle"] = 0.4014257279587,
                                                ["x"] = 153.03426857338,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14B",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "MassRecoverCat 2 Tomcat 2", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VF-102 Diamondbacks",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -8.656340524496,
                                                ["angle"] = 0.59341194567807,
                                                ["x"] = 135.26873280854,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14B",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "MassRecoverCat 2 Tomcat 3", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VF-143 Pukin Dogs Low Vis",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -9.2750407750136,
                                                ["angle"] = 0.69813170079773,
                                                ["x"] = 118.21028304429,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14B",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "MassRecoverCat 2 Tomcat 4", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VF-211 Fighting Checkmates",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -8.3027975242003,
                                                ["angle"] = 0.78539816339745,
                                                ["x"] = 101.68214778043,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14B",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "MassRecoverCat 2 Tomcat 5", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VF-211 Fighting Checkmates",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -4.705670082476,
                                                ["angle"] = 0.55850536063819,
                                                ["x"] = 83.441810281671,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14B",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************

    local staticObj = {

        ["name"] = "MassRecoverCat 2 Tomcat 6", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VF-74 BeDevilers 1991",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -2.2444017659291,
                                                ["angle"] = 0.34906585039887,
                                                ["x"] = 63.863539581915,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14B",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = trigger.misc.getUserFlag('404'), -- This flag MUST contain the unit ID of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************

end

local function CarrierBlockedDeck8Spawns()
    env.info("BlockedDeck8Spawns")
    CarrierCleanDeck()

        -- Created by Redkite: https://www.youtube.com/user/RedKiteRender/

    local staticObj = {

        ["name"] = "8temp Blocker Patio S3", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "usaf standard",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 26.462317789963,
                                                ["angle"] = 0.034906585039887,
                                                ["x"] = -136.44656968401,
                                            }, -- end of ["offsets"]
                                            ["type"] = "S-3B Tanker",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "8temp Blocker Patio Tomcat", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VF-102 Diamondbacks",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 26.834156429977,
                                                ["angle"] = 3.7699111843078,
                                                ["x"] = -123.20911407401,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14B",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "8temp Blocker EL3 Tomcat", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VF-102 Diamondbacks",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 33.229781050002,
                                                ["angle"] = 4.6949356878647,
                                                ["x"] = -104.617182038,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14B",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "8temp Blocker EL3 Hornet", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VF-102 Diamondbacks",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 32.607335179986,
                                                ["angle"] = 4.6949356878647,
                                                ["x"] = -91.664486535999,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14B",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "8temp Blocker Island Hornet 1", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VFA-37",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 20.882562899962,
                                                ["angle"] = 5.3930673886625,
                                                ["x"] = -71.796896190004,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "8temp Blocker Island Hornet 2", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VFA-97",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 17.046432009956,
                                                ["angle"] = 5.7770398241012,
                                                ["x"] = -58.370438072001,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "8temp Blocker Island Hornet 3", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VFA-97",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 14.469786549977,
                                                ["angle"] = 5.3407075111026,
                                                ["x"] = -45.576714306007,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
end

local function CarrierBlockedDeck4Spawns()
    env.info("BlockedDeck4Spawns")
    CarrierCleanDeck()
    -- Created by Redkite: https://www.youtube.com/user/RedKiteRender/

    local staticObj = {

        ["name"] = "4temp Block Island Seahawk", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "standard",
                                            ["category"] = "Helicopters",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 13.940469299967,
                                                ["angle"] = 5.2883476335428,
                                                ["x"] = -53.007764027003,
                                            }, -- end of ["offsets"]
                                            ["type"] = "SH-60B",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "4temp Block Island E2", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                        ["livery_id"] = "E-2D Demo",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 19.286680730002,
                                                ["angle"] = 5.7421332390613,
                                                ["x"] = -66.808449347009,
                                            }, -- end of ["offsets"]
                                            ["type"] = "E-2C",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "4temp Block EL3 Tomcat 1", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VF-32 Fighting Swordsmen 102",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 33.290550209989,
                                                ["angle"] = 4.607669225265,
                                                ["x"] = -92.26798636101,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14B",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "4temp Block EL3 Tomcat 2", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VF-32 Fighting Swordsmen 101",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 33.290550209989,
                                                ["angle"] = 4.7647488579445,
                                                ["x"] = -104.84876127,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14B",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "4temp Block Patio Hornet 1", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VFA-106",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 26.055655829958,
                                                ["angle"] = 5.3756140961425,
                                                ["x"] = -114.693982315,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "4temp Block Patio Hornet 2", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VFA-106",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 24.606041149993,
                                                ["angle"] = 5.3756140961425,
                                                ["x"] = -123.874875294,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "4temp Block Patio Hornet 3", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VFA-106",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 24.702682129981,
                                                ["angle"] = 5.9864793343406,
                                                ["x"] = -136.24492057001,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************

end

local function CarrierCleanDeck16Spawns()

    -- Created by Redkite: https://www.youtube.com/user/RedKiteRender/

    local staticObj = {

        ["name"] = "16temp Finger Seahawk", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "standard",
                                            ["category"] = "Helicopters",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -25.023610410048,
                                                ["angle"] = 1.7976891295542,
                                                ["x"] = -120.511512843,
                                            }, -- end of ["offsets"]
                                            ["type"] = "SH-60B",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "16temp Junk Yard Tug", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["offsets"] = 
                                            {
                                                ["y"] = 29.219321732642,
                                                ["angle"] = 2.4958208303519,
                                                ["x"] = -77.186823118536,
                                            }, -- end of ["offsets"]
                                            ["type"] = "AS32-31A",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "16temp LSO Station 3", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -22.370473980031,
                                                ["angle"] = 2.4434609527921,
                                                ["x"] = -130.61201797701,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_lso_usa",
                                            ["type"] = "Carrier LSO Personell",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "16temp LSO Station 1", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -21.789118479996,
                                                ["angle"] = 4.2935099599061,
                                                ["x"] = -129.42353100701,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_lso1_usa",
                                            ["type"] = "Carrier LSO Personell 1",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "16temp LSO Station 2", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "white",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -22.656188270019,
                                                ["angle"] = 1.850049007114,
                                                ["x"] = -129.497732263,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "16temp Corral Tech 1", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "yellow",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 24.378384780779,
                                                ["angle"] = 3.1764992386297,
                                                ["x"] = -1.862423344297,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************

    local staticObj = {

        ["name"] = "16temp Corral Tech 2", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "yellow",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 24.943464248674,
                                                ["angle"] = 5.218534463463,
                                                ["x"] = -2.5415543022973,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "16temp Yunk Yard Seaman", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 30.850786532392,
                                                ["angle"] = 4.7472955654246,
                                                ["x"] = -76.189816852042,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_seaman_USA",
                                            ["type"] = "Carrier Seaman",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "16temp Corral Tug", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["category"] = "ADEquipment",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 25.915128857188,
                                                ["angle"] = 2.4958208303519,
                                                ["x"] = -1.4404247678031,
                                            }, -- end of ["offsets"]
                                            ["type"] = "AS32-31A",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "16temp EL1 Tech 1", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "yellow",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 19.968042107823,
                                                ["angle"] = 1.5707963267949,
                                                ["x"] = 28.511725836535,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "16temp Patio Firetruck", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                        ["category"] = "ADEquipment",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 29.26265261037,
                                                ["angle"] = 1.7453292519943,
                                                ["x"] = -112.85393314034,
                                            }, -- end of ["offsets"]
                                            ["type"] = "AS32-p25",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "16temp Patio Tech", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "white",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 26.2488428746,
                                                ["angle"] = 3.700098014228,
                                                ["x"] = -111.91510989917,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************

end

local function CarrierBlockedDeck16Spawns()

    -- Created by Redkite: https://www.youtube.com/user/RedKiteRender/

    local staticObj = {

        ["name"] = "16temp Blocker Point S3", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "usaf standard",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 34.469735879975,
                                                ["angle"] = 6.0911990894602,
                                                ["x"] = 67.739295549996,
                                            }, -- end of ["offsets"]
                                            ["type"] = "S-3B",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "16temp Blocker Island Seahawk", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "standard",
                                            ["category"] = "Helicopters",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 15.023588829965,
                                                ["angle"] = 6.0039326268605,
                                                ["x"] = -44.319651074009,
                                            }, -- end of ["offsets"]
                                            ["type"] = "SH-60B",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "16temp Blocker Island Hornet", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VFA-37",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 17.969597139978,
                                                ["angle"] = 5.7595865315813,
                                                ["x"] = -61.257363910001,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************
    local staticObj = {

        ["name"] = "16temp Blocker Yunk Yard Tomcat", -- unit name (Name this something identifiable if you wish to remove it later)
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VF-102 Diamondbacks",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 20.798515920003,
                                                ["angle"] = 5.7246799465414,
                                                ["x"] = -78.309457666997,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14B",
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 33,
        ["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
        ["x"] = -00126557,			
        ["heading"] = 37.55948550292,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
        ["rate"] = 30,
    }
    coalition.addStaticObject(country.id.USA, staticObj)

    -- ********************************************************

end


local carrierLayouts = {
    CarrierClearDeck8Spawns,
    CarrierBlockedDeck8Spawns,
    CarrierClearDeck4Spawns,
    CarrierBlockedDeck4Spawns,
    CarrierMassRecoveryCat2Tomcats,
    CarrierCleanDeck16Spawns,
    CarrierBlockedDeck16Spawns
}

local currentLayoutIndex = 1

local function cycleCarrierLayouts()
    -- Clean the deck before changing the layout
    CarrierCleanDeck()

    -- Get the current layout function
    local layoutFunction = carrierLayouts[currentLayoutIndex]

    -- Call the layout function
    layoutFunction()

    -- Move to the next layout in the list
    currentLayoutIndex = currentLayoutIndex % #carrierLayouts + 1

    -- Schedule the next execution in 15 minutes (900 seconds)
    timer.scheduleFunction(cycleCarrierLayouts, nil, timer.getTime() + RotateLayoutInterval)
end

-- Start the cycle
cycleCarrierLayouts()

CarrierMenu = MENU_MISSION:New("Carrier Operations", missionMenu)   
CarrierLayoutCleanDeck = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Clear Deck", CarrierMenu, CarrierCleanDeck)