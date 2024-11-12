--env.info("Loading OPS Script", true)
-- Create Operation Control Points on each of the air bases.
local msgTime = 15
local msgCat = "INTEL : "
local delayStart = 10 -- How many seconds to delay before starting the zone FSM

-- Roadblock OPS Zones
RoadBlock_A1 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-1"),coalition.side.RED)
RoadBlock_A1:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A2 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-2"),coalition.side.RED)
RoadBlock_A2:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A3 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-3"),coalition.side.RED)
RoadBlock_A3:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A4 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-4"),coalition.side.RED)
RoadBlock_A4:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A5 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-5"),coalition.side.RED)
RoadBlock_A5:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A6 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-6"),coalition.side.RED)
RoadBlock_A6:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A7 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-7"),coalition.side.RED)
RoadBlock_A7:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A8 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-8"),coalition.side.RED)
RoadBlock_A8:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A9 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-9"),coalition.side.RED)
RoadBlock_A9:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A10 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-10"),coalition.side.RED)
RoadBlock_A10:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A11 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-11"),coalition.side.RED)
RoadBlock_A11:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A12 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-12"),coalition.side.RED)
RoadBlock_A12:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A13 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-13"),coalition.side.RED)
RoadBlock_A13:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A14 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-14"),coalition.side.RED)
RoadBlock_A14:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A15 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-15"),coalition.side.RED)
RoadBlock_A15:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A16 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-16"),coalition.side.RED)
RoadBlock_A16:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A17 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-17"),coalition.side.RED)
RoadBlock_A17:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A18 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-18"),coalition.side.RED)
RoadBlock_A18:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A19 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-19"),coalition.side.RED)
RoadBlock_A19:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A20 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-20"),coalition.side.RED)
RoadBlock_A20:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A21 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-21"),coalition.side.RED)
RoadBlock_A21:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A22 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-22"),coalition.side.RED)
RoadBlock_A22:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A23 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-23"),coalition.side.RED)
RoadBlock_A23:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A24 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-24"),coalition.side.RED)
RoadBlock_A24:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A25 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-25"),coalition.side.RED)
RoadBlock_A25:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A26 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-26"),coalition.side.RED)
RoadBlock_A26:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A27 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-27"),coalition.side.RED)
RoadBlock_A27:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A28 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-28"),coalition.side.RED)
RoadBlock_A28:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A29 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-29"),coalition.side.RED)
RoadBlock_A29:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoadBlock_A30 = OPSZONE:New(ZONE:FindByName("ROAD BLOCK A-30"),coalition.side.RED)
RoadBlock_A30:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)

----Airbase OPS Zones
--AirBase_Ramon = OPSZONE:New(ZONE:FindByName("Ramon"),coalition.side.BLUE)
--AirBase_Ramon:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
--AirBase_Nevatim = OPSZONE:New(ZONE:FindByName("Nevatim"),coalition.side.BLUE)
--AirBase_Nevatim:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
--AirBase_Kedem = OPSZONE:New(ZONE:FindByName("Kedem"),coalition.side.BLUE)
--AirBase_Kedem:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
--AirBase_Hatzerim = OPSZONE:New(ZONE:FindByName("Hatzerim"),coalition.side.BLUE)
--AirBase_Hatzerim:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
--AirBase_Hatzor = OPSZONE:New(ZONE:FindByName("Hatzor"),coalition.side.BLUE)
--AirBase_Hatzor:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
--AirBase_Tel_Nof = OPSZONE:New(ZONE:FindByName("Tel Nof"),coalition.side.BLUE)
--AirBase_Tel_Nof:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
--AirBase_Ben_Gurion = OPSZONE:New(ZONE:FindByName("Ben Gurion"),coalition.side.BLUE)
--AirBase_Ben_Gurion:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
--Airbase_Palmahim = OPSZONE:New(ZONE:FindByName("Palmahim Zone"),coalition.side.BLUE)
--Airbase_Palmahim:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
--Airbase_Sde_Dov = OPSZONE:New(ZONE:FindByName("Sde Dov"),coalition.side.BLUE)
--Airbase_Sde_Dov:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)

-- Refugee Camp
--Refugee_Camp_1 = OPSZONE:New(ZONE:FindByName("Refugee Camp 1"),coalition.side.BLUE)
--Refugee_Camp_1:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)

---- After Attacked
--function Refugee_Camp_1:OnAfterAttacked(From, Event, To, AttackerCoalition)
--  local name = Refugee_Camp_1:GetName()
--  local coa = AttackerCoalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio1.ogg"):ToAll()
--end
---- After Capture
--function Refugee_Camp_1:OnAfterCaptured(From, Event, To, Coalition)
--  local name = Refugee_Camp_1:GetName()
--  local coa = Coalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio2.ogg"):ToAll()
--end
----- After Defeated
--function Refugee_Camp_1:OnAfterDefeated(From, Event, To, DefeatedCoalition)
--  local name = Refugee_Camp_1:GetName()
--  local coa = DefeatedCoalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio3.ogg"):ToAll()
--end
---- After Empty
--function Refugee_Camp_1:OnAfterEmpty(From, Event, To)
--  local name = Refugee_Camp_1:GetName()
--  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
--  USERSOUND:New("combatAudio4.ogg"):ToAll()  
--end

---- After Attacked
--function Airbase_Sde_Dov:OnAfterAttacked(From, Event, To, AttackerCoalition)
--  local name = Airbase_Sde_Dov:GetName()
--  local coa = AttackerCoalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio1.ogg"):ToAll()
--end
---- After Capture
--function Airbase_Sde_Dov:OnAfterCaptured(From, Event, To, Coalition)
--  local name = Airbase_Sde_Dov:GetName()
--  local coa = Coalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio2.ogg"):ToAll()
--end
----- After Defeated
--function Airbase_Sde_Dov:OnAfterDefeated(From, Event, To, DefeatedCoalition)
--  local name = Airbase_Sde_Dov:GetName()
--  local coa = DefeatedCoalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio3.ogg"):ToAll()
--end
---- After Empty
--function Airbase_Sde_Dov:OnAfterEmpty(From, Event, To)
--  local name = Airbase_Sde_Dov:GetName()
--  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
--  USERSOUND:New("combatAudio4.ogg"):ToAll()  
--end
--
--
---- After Attacked
--function Airbase_Palmahim:OnAfterAttacked(From, Event, To, AttackerCoalition)
--  local name = Airbase_Palmahim:GetName()
--  local coa = AttackerCoalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio1.ogg"):ToAll()
--end
---- After Capture
--function Airbase_Palmahim:OnAfterCaptured(From, Event, To, Coalition)
--  local name = Airbase_Palmahim:GetName()
--  local coa = Coalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio2.ogg"):ToAll()
--end
----- After Defeated
--function Airbase_Palmahim:OnAfterDefeated(From, Event, To, DefeatedCoalition)
--  local name = Airbase_Palmahim:GetName()
--  local coa = DefeatedCoalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio3.ogg"):ToAll()
--end
---- After Empty
--function Airbase_Palmahim:OnAfterEmpty(From, Event, To)
--  local name = Airbase_Palmahim:GetName()
--  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
--  USERSOUND:New("combatAudio4.ogg"):ToAll()  
--end
--
---- After Attacked
--function AirBase_Ben_Gurion:OnAfterAttacked(From, Event, To, AttackerCoalition)
--  local name = AirBase_Ben_Gurion:GetName()
--  local coa = AttackerCoalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio1.ogg"):ToAll()
--end
---- After Capture
--function AirBase_Ben_Gurion:OnAfterCaptured(From, Event, To, Coalition)
--  local name = AirBase_Ben_Gurion:GetName()
--  local coa = Coalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio2.ogg"):ToAll()
--end
----- After Defeated
--function AirBase_Ben_Gurion:OnAfterDefeated(From, Event, To, DefeatedCoalition)
--  local name = AirBase_Ben_Gurion:GetName()
--  local coa = DefeatedCoalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio3.ogg"):ToAll()
--end
---- After Empty
--function AirBase_Ben_Gurion:OnAfterEmpty(From, Event, To)
--  local name = AirBase_Ben_Gurion:GetName()
--  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
--  USERSOUND:New("combatAudio4.ogg"):ToAll()  
--end
--
---- After Attacked
--function AirBase_Tel_Nof:OnAfterAttacked(From, Event, To, AttackerCoalition)
--  local name = AirBase_Tel_Nof:GetName()
--  local coa = AttackerCoalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio1.ogg"):ToAll()
--end
---- After Capture
--function AirBase_Tel_Nof:OnAfterCaptured(From, Event, To, Coalition)
--  local name = AirBase_Tel_Nof:GetName()
--  local coa = Coalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio2.ogg"):ToAll()
--end
----- After Defeated
--function AirBase_Tel_Nof:OnAfterDefeated(From, Event, To, DefeatedCoalition)
--  local name = AirBase_Tel_Nof:GetName()
--  local coa = DefeatedCoalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio3.ogg"):ToAll()
--end
---- After Empty
--function AirBase_Tel_Nof:OnAfterEmpty(From, Event, To)
--  local name = AirBase_Tel_Nof:GetName()
--  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
--  USERSOUND:New("combatAudio4.ogg"):ToAll()  
--end
--
--
---- After Attacked
--function AirBase_Hatzor:OnAfterAttacked(From, Event, To, AttackerCoalition)
--  local name = AirBase_Hatzor:GetName()
--  local coa = AttackerCoalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio1.ogg"):ToAll()
--end
---- After Capture
--function AirBase_Hatzor:OnAfterCaptured(From, Event, To, Coalition)
--  local name = AirBase_Hatzor:GetName()
--  local coa = Coalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio2.ogg"):ToAll()
--end
----- After Defeated
--function AirBase_Hatzor:OnAfterDefeated(From, Event, To, DefeatedCoalition)
--  local name = AirBase_Hatzor:GetName()
--  local coa = DefeatedCoalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio3.ogg"):ToAll()
--end
---- After Empty
--function AirBase_Hatzor:OnAfterEmpty(From, Event, To)
--  local name = AirBase_Hatzor:GetName()
--  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
--  USERSOUND:New("combatAudio4.ogg"):ToAll()  
--end
--
---- After Attacked
--function AirBase_Hatzerim:OnAfterAttacked(From, Event, To, AttackerCoalition)
--  local name = AirBase_Hatzerim:GetName()
--  local coa = AttackerCoalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio1.ogg"):ToAll()
--end
---- After Capture
--function AirBase_Hatzerim:OnAfterCaptured(From, Event, To, Coalition)
--  local name = AirBase_Hatzerim:GetName()
--  local coa = Coalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio2.ogg"):ToAll()
--end
----- After Defeated
--function AirBase_Hatzerim:OnAfterDefeated(From, Event, To, DefeatedCoalition)
--  local name = AirBase_Hatzerim:GetName()
--  local coa = DefeatedCoalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio3.ogg"):ToAll()
--end
---- After Empty
--function AirBase_Hatzerim:OnAfterEmpty(From, Event, To)
--  local name = AirBase_Hatzerim:GetName()
--  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
--  USERSOUND:New("combatAudio4.ogg"):ToAll()  
--end
--
---- After Attacked
--function AirBase_Kedem:OnAfterAttacked(From, Event, To, AttackerCoalition)
--  local name = AirBase_Kedem:GetName()
--  local coa = AttackerCoalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio1.ogg"):ToAll()
--end
---- After Capture
--function AirBase_Kedem:OnAfterCaptured(From, Event, To, Coalition)
--  local name = AirBase_Kedem:GetName()
--  local coa = Coalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio2.ogg"):ToAll()
--end
----- After Defeated
--function AirBase_Kedem:OnAfterDefeated(From, Event, To, DefeatedCoalition)
--  local name = AirBase_Kedem:GetName()
--  local coa = DefeatedCoalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio3.ogg"):ToAll()
--end
---- After Empty
--function AirBase_Kedem:OnAfterEmpty(From, Event, To)
--  local name = AirBase_Kedem:GetName()
--  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
--  USERSOUND:New("combatAudio4.ogg"):ToAll()  
--end
--
---- After Attacked
--function AirBase_Nevatim:OnAfterAttacked(From, Event, To, AttackerCoalition)
--  local name = AirBase_Nevatim:GetName()
--  local coa = AttackerCoalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio1.ogg"):ToAll()
--end
---- After Capture
--function AirBase_Nevatim:OnAfterCaptured(From, Event, To, Coalition)
--  local name = AirBase_Nevatim:GetName()
--  local coa = Coalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio2.ogg"):ToAll()
--end
----- After Defeated
--function AirBase_Nevatim:OnAfterDefeated(From, Event, To, DefeatedCoalition)
--  local name = AirBase_Nevatim:GetName()
--  local coa = DefeatedCoalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio3.ogg"):ToAll()
--end
---- After Empty
--function AirBase_Nevatim:OnAfterEmpty(From, Event, To)
--  local name = AirBase_Nevatim:GetName()
--  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
--  USERSOUND:New("combatAudio4.ogg"):ToAll()  
--end
--
---- After Attacked
--function AirBase_Ramon:OnAfterAttacked(From, Event, To, AttackerCoalition)
--  local name = AirBase_Ramon:GetName()
--  local coa = AttackerCoalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio1.ogg"):ToAll()
--end
---- After Capture
--function AirBase_Ramon:OnAfterCaptured(From, Event, To, Coalition)
--  local name = AirBase_Ramon:GetName()
--  local coa = Coalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio2.ogg"):ToAll()
--end
----- After Defeated
--function AirBase_Ramon:OnAfterDefeated(From, Event, To, DefeatedCoalition)
--  local name = AirBase_Ramon:GetName()
--  local coa = DefeatedCoalition
--  if (coa == 2) then -- usa
--    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
--  else -- it was some other bad guy..
--    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
--  end
--  USERSOUND:New("combatAudio3.ogg"):ToAll()
--end
---- After Empty
--function AirBase_Ramon:OnAfterEmpty(From, Event, To)
--  local name = AirBase_Ramon:GetName()
--  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
--  USERSOUND:New("combatAudio4.ogg"):ToAll()  
--end


-- After Attacked
function RoadBlock_A30:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A30:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end
-- After Capture
function RoadBlock_A30:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A30:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A30:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A30:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A30:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A30:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- After Attacked
function RoadBlock_A29:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A29:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end
-- After Capture
function RoadBlock_A29:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A29:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A29:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A29:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A29:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A29:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- After Attacked
function RoadBlock_A28:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A28:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end
-- After Capture
function RoadBlock_A28:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A28:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A28:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A28:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A28:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A28:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- After Attacked
function RoadBlock_A27:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A27:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end
-- After Capture
function RoadBlock_A27:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A27:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A27:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A27:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A27:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A27:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- After Attacked
function RoadBlock_A26:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A26:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end
-- After Capture
function RoadBlock_A26:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A26:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A26:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A26:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A26:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A26:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- After Attacked
function RoadBlock_A25:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A25:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end
-- After Capture
function RoadBlock_A25:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A25:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A25:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A25:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A25:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A25:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- After Attacked
function RoadBlock_A24:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A24:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end
-- After Capture
function RoadBlock_A24:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A24:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A24:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A24:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A24:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A24:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end
-- After Attacked
function RoadBlock_A23:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A23:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end
-- After Capture
function RoadBlock_A23:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A23:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A23:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A23:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A23:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A23:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- After Attacked
function RoadBlock_A22:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A22:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end
-- After Capture
function RoadBlock_A22:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A22:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A22:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A22:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A22:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A22:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- After Attacked
function RoadBlock_A21:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A21:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end
-- After Capture
function RoadBlock_A21:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A21:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A21:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A21:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A21:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A21:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- After Attacked
function RoadBlock_A20:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A20:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end
-- After Capture
function RoadBlock_A20:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A20:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A20:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A20:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A20:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A20:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- After Attacked
function RoadBlock_A19:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A19:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end
-- After Capture
function RoadBlock_A19:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A19:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A19:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A19:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A19:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A19:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end
-- After Attacked
function RoadBlock_A18:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A18:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end
-- After Capture
function RoadBlock_A18:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A18:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A18:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A18:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A18:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A18:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- After Attacked
function RoadBlock_A17:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A17:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end
-- After Capture
function RoadBlock_A17:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A17:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A17:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A17:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A17:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A17:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- After Attacked
function RoadBlock_A16:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A16:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end
-- After Capture
function RoadBlock_A16:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A16:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A16:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A16:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A16:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A16:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- After Attacked
function RoadBlock_A15:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A15:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end
-- After Capture
function RoadBlock_A15:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A15:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A15:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A15:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A15:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A15:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- After Attacked
function RoadBlock_A14:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A14:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end
-- After Capture
function RoadBlock_A14:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A14:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A14:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A14:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A14:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A14:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- After Attacked
function RoadBlock_A13:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A13:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end
-- After Capture
function RoadBlock_A13:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A13:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A13:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A13:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A13:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A13:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- After Attacked
function RoadBlock_A12:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A12:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end
-- After Capture
function RoadBlock_A12:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A12:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A12:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A12:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A12:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A12:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- After Attacked
function RoadBlock_A11:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A11:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end
-- After Capture
function RoadBlock_A11:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A11:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A11:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A11:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A11:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A11:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- After Attacked
function RoadBlock_A10:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A10:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end
-- After Capture
function RoadBlock_A10:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A10:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A10:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A10:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A10:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A10:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- After Attacked
function RoadBlock_A9:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A9:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end
-- After Capture
function RoadBlock_A9:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A9:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A9:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A9:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A9:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A9:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- After Attacked
function RoadBlock_A8:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A8:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end
-- After Capture
function RoadBlock_A8:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A8:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A8:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A8:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A8:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A8:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- After Attacked
function RoadBlock_A7:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A7:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end
-- After Capture
function RoadBlock_A7:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A7:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A7:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A7:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A7:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A7:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- After Attacked
function RoadBlock_A6:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A6:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end
-- After Capture
function RoadBlock_A6:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A6:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A6:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A6:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A6:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A6:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- After Attacked
function RoadBlock_A5:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A5:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end
-- After Capture
function RoadBlock_A5:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A5:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A5:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A5:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A5:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A5:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end


-- After Attacked
function RoadBlock_A4:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A4:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function RoadBlock_A4:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A4:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A4:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A4:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A4:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A4:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end


-- After Attacked
function RoadBlock_A3:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A3:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function RoadBlock_A3:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A3:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A3:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A3:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A3:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A3:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- After Attacked
function RoadBlock_A2:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A2:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function RoadBlock_A2:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A2:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A2:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A2:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A2:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A2:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- After Attacked
function RoadBlock_A1:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoadBlock_A1:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function RoadBlock_A1:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoadBlock_A1:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function RoadBlock_A1:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoadBlock_A1:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Insurgent forces has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function RoadBlock_A1:OnAfterEmpty(From, Event, To)
  local name = RoadBlock_A1:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

