-- Facilitate the detection of enemy units within the battle zone executed by FACs (Forward Air Controllers) or RECCEs (Reconnaissance Units). 
-- It uses the in-built detection capabilities of DCS World, but adds new functionalities.


--local FACBlue = SET_CLIENT:New():FilterCoalitions("blue"):FilterActive(true):FilterTypes( {"SA342M", "SA342L", "SA342Mistral", "SA342Minigun"} ):FilterStart()

local FACBlue = SET_CLIENT:New():FilterCoalitions("blue"):FilterActive(true):FilterCategories("helicopter"):FilterStart()
local FACBlueAttackers = SET_CLIENT:New():FilterCoalitions("blue"):FilterStart()
local RECCEBlue = PLAYERRECCE:New("RECCE/AFAC Controller",coalition.side.BLUE,FACBlue)
RECCEBlue:SetAttackSet(FACBlueAttackers)


