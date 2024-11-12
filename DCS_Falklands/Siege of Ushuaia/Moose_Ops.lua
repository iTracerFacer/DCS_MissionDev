-- Create Operation Control Points on each of the air bases.
local msgTime = 15
local msgCat = "INTEL : "
local AirBaseDrawRadius = 2500 -- size of the draw lines around a zone.
local FarpDrawRadius = 10000
local delayStart = 10 -- How many seconds to delay before starting the zone FSM
--Airbases
 wp1h = OPSZONE:New(ZONE_AIRBASE:New("Ushuaia Helo Port",AirBaseDrawRadius),coalition.side.BLUE) -- helo port at WP1
 wp1a = OPSZONE:New(ZONE_AIRBASE:New("Ushuaia",AirBaseDrawRadius),coalition.side.BLUE)           -- Airfield at WP1
 wp2 = OPSZONE:New(ZONE_AIRBASE:New("Puerto Williams",AirBaseDrawRadius),coalition.side.RED)
 wp3 = OPSZONE:New(ZONE_AIRBASE:New("Aerodromo De Tolhuin",AirBaseDrawRadius),coalition.side.RED)
 wp4 = OPSZONE:New(ZONE_AIRBASE:New("Rio Grande",AirBaseDrawRadius),coalition.side.RED)
 wp5 = OPSZONE:New(ZONE_AIRBASE:New("Pampa Guanaco",AirBaseDrawRadius),coalition.side.RED)
 wp6 = OPSZONE:New(ZONE_AIRBASE:New("Almirante Schroeders",AirBaseDrawRadius),coalition.side.RED)
 wp7 = OPSZONE:New(ZONE_AIRBASE:New("Porvenir Airfield",AirBaseDrawRadius),coalition.side.RED)
 wp8 = OPSZONE:New(ZONE_AIRBASE:New("Punta Arenas",AirBaseDrawRadius),coalition.side.RED)
--FARPS
 farpWarsaw = OPSZONE:New(ZONE:FindByName("FARP WARSAW",FarpDrawRadius),coalition.side.NEUTRAL)
 farpParis = OPSZONE:New(ZONE:FindByName("FARP PARIS",FarpDrawRadius),coalition.side.NEUTRAL)
 farpBerlin = OPSZONE:New(ZONE:FindByName("FARP BERLIN",FarpDrawRadius),coalition.side.NEUTRAL)
 farpDallas = OPSZONE:New(ZONE:FindByName("FARP DALLAS",FarpDrawRadius),coalition.side.BLUE)
 farpRome = OPSZONE:New(ZONE:FindByName("FARP ROME",FarpDrawRadius),coalition.side.BLUE)
 farpLondon = OPSZONE:New(ZONE:FindByName("FARP LONDON",FarpDrawRadius),coalition.side.BLUE)
 UshNRoadBlock = OPSZONE:New(ZONE:FindByName("Ushuaia Northern Road Block",2000),coalition.side.BLUE)
 UshWRoadBlock = OPSZONE:New(ZONE:FindByName("Ushuaia Western Road Block",5000),coalition.side.BLUE)
--Other Locations
 UshValley = OPSZONE:New(ZONE:FindByName("Ushuaia Valley",15000),coalition.side.NEUTRAL)




--Set Zone Options and start
wp1h:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
wp1a:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
wp2:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
wp3:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
wp4:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
wp5:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
wp6:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
wp7:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
wp8:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
farpBerlin:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
farpDallas:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
farpLondon:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
farpParis:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
farpRome:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
farpWarsaw:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
UshNRoadBlock:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
UshWRoadBlock:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
UshValley:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)


-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function UshValley:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = UshValley:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function UshValley:OnAfterCaptured(From, Event, To, Coalition)
  local name = UshValley:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function UshValley:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = UshValley:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function UshValley:OnAfterEmpty(From, Event, To)
  local name = UshValley:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end





-- After Attacked
function UshWRoadBlock:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = UshWRoadBlock:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function UshWRoadBlock:OnAfterCaptured(From, Event, To, Coalition)
  local name = UshWRoadBlock:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function UshWRoadBlock:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = UshWRoadBlock:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function UshWRoadBlock:OnAfterEmpty(From, Event, To)
  local name = UshWRoadBlock:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end


-- After Attacked
function wp1h:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = wp1h:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function wp1h:OnAfterCaptured(From, Event, To, Coalition)
  local name = wp1h:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function wp1h:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = wp1h:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function wp1h:OnAfterEmpty(From, Event, To)
  local name = wp1h:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end


-- Way Point 1A Functions -------------------------------------------------------------------

-- After Attacked
function wp1a:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = wp1a:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function wp1a:OnAfterCaptured(From, Event, To, Coalition)
  local name = wp1a:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function wp1a:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = wp1a:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function wp1a:OnAfterEmpty(From, Event, To)
  local name = wp1a:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end


-- Way Point 2 Functions -------------------------------------------------------------------
-- After Attacked
function wp2:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = wp2:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function wp2:OnAfterCaptured(From, Event, To, Coalition)
  local name = wp2:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function wp2:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = wp2:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function wp2:OnAfterEmpty(From, Event, To)
  local name = wp2:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end


-- Way Point 3 Functions -------------------------------------------------------------------

-- After Attacked
function wp3:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = wp3:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function wp3:OnAfterCaptured(From, Event, To, Coalition)
  local name = wp3:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function wp3:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = wp3:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function wp3:OnAfterEmpty(From, Event, To)
  local name = wp3:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end


-- Way Point 4 Functions -------------------------------------------------------------------

-- After Attacked
function wp4:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = wp4:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function wp4:OnAfterCaptured(From, Event, To, Coalition)
  local name = wp4:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function wp4:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = wp4:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function wp4:OnAfterEmpty(From, Event, To)
  local name = wp4:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end


-- Way Point 5 Functions -------------------------------------------------------------------

-- After Attacked
function wp5:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = wp5:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function wp5:OnAfterCaptured(From, Event, To, Coalition)
  local name = wp5:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function wp5:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = wp5:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function wp5:OnAfterEmpty(From, Event, To)
  local name = wp5:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end



-- Way Point 6 Functions -------------------------------------------------------------------

-- After Attacked
function wp6:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = wp6:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function wp6:OnAfterCaptured(From, Event, To, Coalition)
  local name = wp6:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function wp6:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = wp6:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function wp6:OnAfterEmpty(From, Event, To)
  local name = wp6:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio41.ogg"):ToAll()  
end



-- Way Point 7 Functions -------------------------------------------------------------------

-- After Attacked
function wp7:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = wp7:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function wp7:OnAfterCaptured(From, Event, To, Coalition)
  local name = wp7:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function wp7:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = wp7:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function wp7:OnAfterEmpty(From, Event, To)
  local name = wp7:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- Way Point 8 Functions -------------------------------------------------------------------

-- After Attacked
function wp8:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = wp8:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function wp8:OnAfterCaptured(From, Event, To, Coalition)
  local name = wp8:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function wp8:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = wp8:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function wp8:OnAfterEmpty(From, Event, To)
  local name = wp8:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end


-- Way Point farpWarsaw Functions -------------------------------------------------------------------

-- After Attacked
function farpWarsaw:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = farpWarsaw:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function farpWarsaw:OnAfterCaptured(From, Event, To, Coalition)
  local name = farpWarsaw:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
    
    trigger.action.setUserFlag("APACHE WARSAW FARP-1",0)
    trigger.action.setUserFlag("APACHE WARSAW FARP-2",0)
    trigger.action.setUserFlag("BLACKSHARK WARSAW FARP-1",0)
    trigger.action.setUserFlag("BLACKSHARK WARSAW FARP-1",0)
    trigger.action.setUserFlag("TRANSPORT WARSAW FARP-1",0)
    trigger.action.setUserFlag("TRANSPORT WARSAW FARP-2",0)
    trigger.action.setUserFlag("TRANSPORT WARSAW FARP-3",0)
    trigger.action.setUserFlag("TRANSPORT WARSAW FARP-4",0)
    
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function farpWarsaw:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = farpWarsaw:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function farpWarsaw:OnAfterEmpty(From, Event, To)
  local name = farpWarsaw:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end



-- Way Point farpParis Functions -------------------------------------------------------------------

-- After Attacked
function farpParis:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = farpParis:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function farpParis:OnAfterCaptured(From, Event, To, Coalition)
  local name = farpParis:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
    trigger.action.setUserFlag("APACHE PARIS FARP-1",0)
    trigger.action.setUserFlag("APACHE PARIS FARP-2",0)
    trigger.action.setUserFlag("BLACKSHARK PARIS FARP-1",0)
    trigger.action.setUserFlag("BLACKSHARK PARIS FARP-2",0)
    trigger.action.setUserFlag("TRANSPORT PARIS FARP-1",0)
    trigger.action.setUserFlag("TRANSPORT PARIS FARP-2",0)
    trigger.action.setUserFlag("TRANSPORT PARIS FARP-3",0)
    trigger.action.setUserFlag("TRANSPORT PARIS FARP-4",0)
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function farpParis:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = farpParis:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function farpParis:OnAfterEmpty(From, Event, To)
  local name = farpParis:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end



-- Way Point farpBerlin Functions ----------------------------------------------------------------

-- After Attacked
function farpBerlin:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = farpBerlin:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function farpBerlin:OnAfterCaptured(From, Event, To, Coalition)
  local name = farpBerlin:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
    trigger.action.setUserFlag("APACHE BERLIN FARP-1",0)
    trigger.action.setUserFlag("APACHE BERLIN FARP-2",0)
    trigger.action.setUserFlag("BLACKSHARK BERLIN FARP-1",0)
    trigger.action.setUserFlag("BLACKSHARK BERLIN FARP-2",0)
    trigger.action.setUserFlag("TRANSPORT BERLIN FARP-1",0)
    trigger.action.setUserFlag("TRANSPORT BERLIN FARP-2",0)
    trigger.action.setUserFlag("TRANSPORT BERLIN FARP-3",0)
    trigger.action.setUserFlag("TRANSPORT BERLIN FARP-4",0)
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function farpBerlin:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = farpBerlin:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function farpBerlin:OnAfterEmpty(From, Event, To)
  local name = farpBerlin:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- Way Point farpDallas Functions ------------------------------------------------------------------

-- After Attacked
function farpDallas:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = farpDallas:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function farpDallas:OnAfterCaptured(From, Event, To, Coalition)
  local name = farpDallas:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function farpDallas:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = farpDallas:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function farpDallas:OnAfterEmpty(From, Event, To)
  local name = farpDallas:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end



-- Way Point farpRome Functions ------------------------------------------------------------------

-- After Attacked
function farpRome:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = farpRome:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function farpRome:OnAfterCaptured(From, Event, To, Coalition)
  local name = farpRome:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function farpRome:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = farpRome:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function farpRome:OnAfterEmpty(From, Event, To)
  local name = farpRome:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end


-- Way Point farpLondon Functions ------------------------------------------------------------------

-- After Attacked
function farpLondon:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = farpLondon:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function farpLondon:OnAfterCaptured(From, Event, To, Coalition)
  local name = farpLondon:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function farpLondon:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = farpLondon:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function farpLondon:OnAfterEmpty(From, Event, To)
  local name = farpLondon:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end


-- Way Point UshNRoadBlock Functions ------------------------------------------------------------------

-- After Attacked
function UshNRoadBlock:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = UshNRoadBlock:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function UshNRoadBlock:OnAfterCaptured(From, Event, To, Coalition)
  local name = UshNRoadBlock:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function UshNRoadBlock:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = UshNRoadBlock:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function UshNRoadBlock:OnAfterEmpty(From, Event, To)
  local name = UshNRoadBlock:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end
---- After Base Captured
--function UshNRoadBlock:OnEventBaseCaptured(EventData)
--  local name = UshNRoadBlock:GetName()
--  local coa = EventData.TgtCoalition
--  if (coa == 2) then -- usa
--    MESSAGE:New(name .. " has been captured by NATO Forces!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy
--    MESSAGE:New(name .. " has been captured by Russian Forces!", msgTime, msgCat, false):ToAll()
--  end
--end

















