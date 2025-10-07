-- Simple AFAC Test Script
-- This is a minimal version to test if scripts load at all

-- Test if script loads
trigger.action.outText("TEST SCRIPT: Loading AFAC test...", 15)
env.info("AFAC TEST: Script is loading")

-- Basic data structure
AFAC = {
    pilots = {},
    debug = true
}

-- Simple logging
function AFAC.log(message)
    env.info("AFAC TEST: " .. tostring(message))
    trigger.action.outText("AFAC: " .. tostring(message), 5)
end

AFAC.log("Test script initialized")

-- Simple aircraft check
AFAC.afacTypes = {
    "UH-1H"
}

function AFAC.isAFAC(unit)
    if not unit then return false end
    local unitType = unit:getTypeName()
    AFAC.log("Checking aircraft type: " .. unitType)
    
    for _, afacType in ipairs(AFAC.afacTypes) do
        if unitType == afacType then
            AFAC.log("MATCH FOUND: " .. unitType .. " is AFAC!")
            return true
        end
    end
    return false
end

function AFAC.addPilot(unit)
    local unitName = unit:getName()
    AFAC.log("Adding AFAC pilot: " .. unitName)
    
    local groupId = unit:getGroup():getID()
    trigger.action.outTextForGroup(groupId, "AFAC ACTIVE: " .. unit:getTypeName(), 20)
    
    -- Add simple F10 menu
    local mainMenu = missionCommands.addSubMenuForGroup(groupId, "AFAC TEST")
    missionCommands.addCommandForGroup(groupId, "Test Command", mainMenu, function()
        trigger.action.outTextForGroup(groupId, "AFAC Test Menu Works!", 10)
    end)
    
    AFAC.pilots[unitName] = unit
end

-- Event handler
AFAC.EventHandler = {}

function AFAC.EventHandler:onEvent(event)
    AFAC.log("Event received: " .. tostring(event.id))
    
    if event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT then
        AFAC.log("Player entered unit event")
        local unit = event.initiator
        
        if unit then
            AFAC.log("Unit type: " .. unit:getTypeName())
            if AFAC.isAFAC(unit) then
                AFAC.log("AFAC detected, adding pilot")
                AFAC.addPilot(unit)
            end
        end
    end
    
    if event.id == world.event.S_EVENT_BIRTH then
        AFAC.log("Birth event")
        local unit = event.initiator
        
        if unit and Object.getCategory(unit) == Object.Category.UNIT then
            local objDesc = unit:getDesc()
            if objDesc.category == Unit.Category.AIRPLANE or objDesc.category == Unit.Category.HELICOPTER then
                AFAC.log("Aircraft born: " .. unit:getTypeName())
                if AFAC.isAFAC(unit) then
                    timer.scheduleFunction(function(args)
                        if args[1]:isActive() then
                            AFAC.addPilot(args[1])
                        end
                    end, {unit}, timer.getTime() + 2)
                end
            end
        end
    end
end

-- Add event handler
world.addEventHandler(AFAC.EventHandler)
AFAC.log("Event handler added")

-- Check existing units
timer.scheduleFunction(function()
    AFAC.log("Checking existing units...")
    
    for coalitionId = 1, 2 do
        local heliGroups = coalition.getGroups(coalitionId, Group.Category.HELICOPTER)
        AFAC.log("Found " .. #heliGroups .. " helicopter groups for coalition " .. coalitionId)
        
        for _, group in ipairs(heliGroups) do
            local units = group:getUnits()
            if units then
                for _, unit in ipairs(units) do
                    if unit and unit:isActive() then
                        AFAC.log("Found helicopter: " .. unit:getTypeName())
                        if AFAC.isAFAC(unit) and unit:getPlayerName() then
                            AFAC.log("Found player AFAC: " .. unit:getName())
                            AFAC.addPilot(unit)
                        end
                    end
                end
            end
        end
    end
end, nil, timer.getTime() + 3)

AFAC.log("AFAC Test Script loaded successfully!")
trigger.action.outText("AFAC Test Script loaded!", 10)