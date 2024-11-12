-- Create Operation Control Points on each of the air bases.
local msgTime = 15
local msgCat = "INTEL : "
local AirBaseDrawRadius = 2500 -- size of the draw lines around a zone.
local FarpDrawRadius = 10000
local delayStart = 10 -- How many seconds to delay before starting the zone FSM


 
-- Way Point zone1 Functions -------------------------------------------------------------------
zone1 = OPSZONE:New(ZONE:FindByName("FARP WARSAW",FarpDrawRadius),coalition.side.NEUTRAL)
zone1:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)


-- After Attacked
function zone1:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = zone1:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end



-- After Capture
function zone1:OnAfterCaptured(From, Event, To, Coalition)
  local name = zone1:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
    

    
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function zone1:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = zone1:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function zone1:OnAfterEmpty(From, Event, To)
  local name = zone1:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end