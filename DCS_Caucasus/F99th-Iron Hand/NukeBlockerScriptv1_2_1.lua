weapRestrict = {}
weapRestrict.playerTakeOff ={}
weapRestrict.weapon2BAN={"weapons.bombs.RN-24","weapons.bombs.RN-28"}

function weapRestrict.playerTakeOff:onEvent(e)

    if e.id == world.event.S_EVENT_TAKEOFF and e.initiator then
        local playerGroup = e.initiator:getGroup()
        local playerGroupID = playerGroup:getID()
        local wCount
        local i
        local bCount
        local bwCount
        local checkPayload = e.initiator:getAmmo()
        local pUnitPos = e.initiator:getPoint()
        local uIdS

        uIdS = tostring(playerGroupID)

        if checkPayload then        
            for bCount =1, #checkPayload do
                for bwCount = 1, #weapRestrict.weapon2BAN do
                    if weapRestrict.weapon2BAN[bwCount] == checkPayload[bCount].desc.typeName then
                        local naughty_player = e.initiator:getPlayerName()
                        trigger.action.outText("Restricted Weapon detected: " .. checkPayload[bCount].desc.typeName .. ", this weapon is BANNED,  ".. naughty_player .. " kicking to spectator", 120)
                        trigger.action.outText("NukeUser:".. naughty_player, 0.01)
                        
                        return
                    end
                end
            end
        end
    end
end


world.addEventHandler(weapRestrict.playerTakeOff)