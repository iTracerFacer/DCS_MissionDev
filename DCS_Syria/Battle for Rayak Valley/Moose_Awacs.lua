



RedAWACS = SPAWN:New("RED EWR AWACS")
    :InitLimit(1, 99)
    :InitRepeatOnLanding()
    :SpawnScheduled(30, 0.5)





    --[[
------------------------------------------------------------------------------------------------------------------
-- Blue AWACS
------------------------------------------------------------------------------------------------------------------

-- Patrol zone.
local BlueAwacsZone = ZONE:New("BLUE AWACS ZONE")

-- AWACS mission. Orbit at 22000 ft, 350 KIAS, heading 270 for 20 NM.
local BlueAWACS=AUFTRAG:NewAWACS(BlueAwacsZone:GetCoordinate(), 22000, 350, 270, 20)
BlueAWACS:SetTime("8:00", "24:00") -- Set time of operation to 8:00 to 24:00.
BlueAWACS:SetTACAN(29, "DXS") -- Set TACAN to 29Y.
BlueAWACS:SetRadio(251)       -- Set radio to 225 MHz AM.

-- Create a flightgroup and set default callsign to Darkstar 1-1
local BlueAWACSFlightGroup=FLIGHTGROUP:New("BLUE EWR AWACS")
BlueAWACSFlightGroup:SetDefaultCallsign(CALLSIGN.AWACS.Darkstar, 1)

-- Assign mission to pilot.
BlueAWACSFlightGroup:AddMission(BlueAWACS)

------------------------------------------------------------------------------------------------------------------
-- Red AWACS
------------------------------------------------------------------------------------------------------------------

-- Patrol zone.
local RedAwacsZone = ZONE:New("RED AWACS ZONE")

-- AWACS mission. Orbit at 22000 ft, 350 KIAS, heading 90 for 20 NM.
local RedAWACS = AUFTRAG:NewAWACS(RedAwacsZone:GetCoordinate(), 22000, 350, 90, 20)
RedAWACS:SetTime("8:00", "24:00") -- Set time of operation to 8:00 to 24:00.
RedAWACS:SetTACAN(30, "RXS") -- Set TACAN to 30Y.
RedAWACS:SetRadio(252)       -- Set radio to 252 MHz AM.

-- Create a flightgroup and set default callsign to Magic 1-1
local RedAWACSFlightGroup = FLIGHTGROUP:New("RED EWR AWACS")
RedAWACSFlightGroup:SetDefaultCallsign(CALLSIGN.AWACS.Magic, 1)

-- Assign mission to pilot.
RedAWACSFlightGroup:AddMission(RedAWACS)

]]