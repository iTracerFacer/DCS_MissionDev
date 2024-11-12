-- Switch the tracing On
--BASE:TraceOnOff( true )

-- Create Operation Control Points on each of the air bases.
local msgTime = 15
local msgCat = "INTEL : "
local FarpDrawRadius = 10000

local delayStart = 5 -- How many seconds to delay before starting the zone FSM


--Airbases

EynSheMerAirbase = OPSZONE:New(ZONE:FindByName("Eyn Shemer Airbase"),coalition.side.NEUTRAL)
EynSheMerAirbase:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(false,false):__Start(delayStart)
EynSheMerAirbase:TraceAll()

EynSheMerArea = OPSZONE:New(ZONE:FindByName("Eyn Shemer Area"),coalition.side.NEUTRAL)
EynSheMerArea:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
EynSheMerArea:TraceAll()

MegiddoArea = OPSZONE:New(ZONE:FindByName("Megiddo Area"),coalition.side.NEUTRAL)
MegiddoArea:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
MegiddoArea:TraceAll()

MegiddoAirbase = OPSZONE:New(ZONE:FindByName("Megiddo Airbase"),coalition.side.NEUTRAL)
MegiddoAirbase:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
MegiddoAirbase:TraceAll()

RamatAirBase = OPSZONE:New(ZONE:FindByName("Ramat Airbase"),coalition.side.NEUTRAL)
RamatAirBase:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RamatAirBase:TraceAll()

HaifaAirbase = OPSZONE:New(ZONE:FindByName("Haifa Airbase"),coalition.side.NEUTRAL)
HaifaAirbase:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(false,false):__Start(delayStart)
HaifaAirbase:TraceAll()

HaifaArea = OPSZONE:New(ZONE:FindByName("Haifa Area"),coalition.side.NEUTRAL)
HaifaArea:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
HaifaArea:TraceAll()

RoshPinaAirbase = OPSZONE:New(ZONE:FindByName("Rosh Pina Airbase"),coalition.side.NEUTRAL)
RoshPinaAirbase:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(false,false):__Start(delayStart)
RoshPinaAirbase:TraceAll()

RoshPinaArea = OPSZONE:New(ZONE:FindByName("Rosh Pina Area"),coalition.side.NEUTRAL)
RoshPinaArea:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RoshPinaArea:TraceAll()

NaqouraAirbase = OPSZONE:New(ZONE:FindByName("Naqoura Airbase"),coalition.side.NEUTRAL)
NaqouraAirbase:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(false,false):__Start(delayStart)
NaqouraAirbase:TraceAll()

NaqouraArea = OPSZONE:New(ZONE:FindByName("Naqoura Area"),coalition.side.NEUTRAL)
NaqouraArea:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
NaqouraArea:TraceAll()

KirvatAirbase = OPSZONE:New(ZONE:FindByName("Kiryat Shmona Airbase"),coalition.side.NEUTRAL)
KirvatAirbase:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(false,false):__Start(delayStart)
KirvatAirbase:TraceAll()

KirvatArea = OPSZONE:New(ZONE:FindByName("Kiryat Shmona Area"),coalition.side.NEUTRAL)
KirvatArea:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
KirvatArea:TraceAll()

RayakAirbase = OPSZONE:New(ZONE:FindByName("Kiryat Shmona Airbase"),coalition.side.NEUTRAL)
RayakAirbase:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(false,false):__Start(delayStart)
RayakAirbase:TraceAll()

RayakArea = OPSZONE:New(ZONE:FindByName("Kiryat Shmona Area"),coalition.side.NEUTRAL)
RayakArea:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RayakArea:TraceAll()

WujahAirbase = OPSZONE:New(ZONE:FindByName("Wujah Airbase"),coalition.side.NEUTRAL)
WujahAirbase:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(false,false):__Start(delayStart)
WujahAirbase:TraceAll()

WujahArea = OPSZONE:New(ZONE:FindByName("Wujah Area"),coalition.side.NEUTRAL)
WujahArea:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
WujahArea:TraceAll()

DamascusArea = OPSZONE:New(ZONE:FindByName("Damascus Area"),coalition.side.NEUTRAL)
DamascusArea:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
DamascusArea:TraceAll()

MarjRuhAirbase = OPSZONE:New(ZONE:FindByName("Marj Ruhayyil Airbase"),coalition.side.NEUTRAL)
MarjRuhAirbase:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
MarjRuhAirbase:TraceAll()

DamascusAirbase = OPSZONE:New(ZONE:FindByName("Damascus Airbase"),coalition.side.NEUTRAL)
DamascusAirbase:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
DamascusAirbase:TraceAll()

MarjSultanSouthAirbase = OPSZONE:New(ZONE:FindByName("Marj Sultan South Airbase"),coalition.side.NEUTRAL)
MarjSultanSouthAirbase:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
MarjSultanSouthAirbase:TraceAll()

MarjSultanNorthAirbase = OPSZONE:New(ZONE:FindByName("Marj Sultan North Airbase"),coalition.side.NEUTRAL)
MarjSultanNorthAirbase:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
MarjSultanNorthAirbase:TraceAll()

MezzehAirbase = OPSZONE:New(ZONE:FindByName("Mezzeh Airbase"),coalition.side.NEUTRAL)
MezzehAirbase:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
MezzehAirbase:TraceAll()

QabrasSittAirbase = OPSZONE:New(ZONE:FindByName("Mezzeh Airbase"),coalition.side.NEUTRAL)
QabrasSittAirbase:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
QabrasSittAirbase:TraceAll()

AlDumayrAirbase = OPSZONE:New(ZONE:FindByName("Al Dumayr Airbase"),coalition.side.NEUTRAL)
AlDumayrAirbase:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(false,false):__Start(delayStart)
AlDumayrAirbase:TraceAll()

AlDumayrArea = OPSZONE:New(ZONE:FindByName("Al Dumayr Area"),coalition.side.NEUTRAL)
AlDumayrArea:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
AlDumayrArea:TraceAll()

SayqalAirbase = OPSZONE:New(ZONE:FindByName("Sayqal Airbase"),coalition.side.NEUTRAL)
SayqalAirbase:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(false,false):__Start(delayStart)
SayqalAirbase:TraceAll()

SayqalArea = OPSZONE:New(ZONE:FindByName("Sayqal Area"),coalition.side.NEUTRAL)
SayqalArea:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
SayqalArea:TraceAll()

AnNasiriyahAirbase = OPSZONE:New(ZONE:FindByName("An Nasiriyah Airbase"),coalition.side.NEUTRAL)
AnNasiriyahAirbase:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(false,false):__Start(delayStart)
AnNasiriyahAirbase:TraceAll()

AnNasiriyahArea = OPSZONE:New(ZONE:FindByName("An Nasiriyah Area"),coalition.side.NEUTRAL)
AnNasiriyahArea:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
AnNasiriyahArea:TraceAll()

KhalkhalahAirbase = OPSZONE:New(ZONE:FindByName("Khalkhalah Airbase"),coalition.side.NEUTRAL)
KhalkhalahAirbase:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(false,false):__Start(delayStart)
KhalkhalahAirbase:TraceAll()

KhalkhalahArea = OPSZONE:New(ZONE:FindByName("Khalkhalah Area"),coalition.side.NEUTRAL)
KhalkhalahArea:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
KhalkhalahArea:TraceAll()

ThalahAirbase = OPSZONE:New(ZONE:FindByName("Thalah Airbase"),coalition.side.NEUTRAL)
ThalahAirbase:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(false,false):__Start(delayStart)
ThalahAirbase:TraceAll()

ThalahArea = OPSZONE:New(ZONE:FindByName("Thalah Area"),coalition.side.NEUTRAL)
ThalahArea:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
ThalahArea:TraceAll()

KingHussenAirbase = OPSZONE:New(ZONE:FindByName("King Hussen Airbase"),coalition.side.NEUTRAL)
KingHussenAirbase:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(false,false):__Start(delayStart)
KingHussenAirbase:TraceAll()

KingHussenArea = OPSZONE:New(ZONE:FindByName("King Hussen Area"),coalition.side.NEUTRAL)
KingHussenArea:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
KingHussenArea:TraceAll()

BeirutAirbase = OPSZONE:New(ZONE:FindByName("Beirut Airbase"),coalition.side.NEUTRAL)
BeirutAirbase:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(false,false):__Start(delayStart)
BeirutAirbase:TraceAll()

BeirutArea = OPSZONE:New(ZONE:FindByName("Beirut Area"),coalition.side.NEUTRAL)
BeirutArea:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
BeirutArea:TraceAll()

RayakAirbase = OPSZONE:New(ZONE:FindByName("Rayak Airbase"),coalition.side.NEUTRAL)
RayakAirbase:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(false,false):__Start(delayStart)
RayakAirbase:TraceAll()

RayakArea = OPSZONE:New(ZONE:FindByName("Rayak Area"),coalition.side.NEUTRAL)
RayakArea:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
RayakArea:TraceAll()

QabrasSittAirbase = OPSZONE:New(ZONE:FindByName("Qabr as Sitt Airbase"),coalition.side.NEUTRAL)
QabrasSittAirbase:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
QabrasSittAirbase:TraceAll()

--FARPS
farpWarsaw = OPSZONE:New(ZONE:FindByName("FARP WARSAW",FarpDrawRadius),coalition.side.NEUTRAL)
farpWarsaw:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
farpWarsaw:TraceAll()

farpDallas = OPSZONE:New(ZONE:FindByName("FARP DALLAS",FarpDrawRadius),coalition.side.NEUTRAL)
farpDallas:SetObjectCategories({Object.Category.UNIT}):SetDrawZone(true):SetMarkZone(true,true):__Start(delayStart)
farpDallas:TraceAll()

----------------------
--You don't need to use any of these functions below in order for map and mark points to update. If you want to take action 
--based on the events in the zones then use them as needed. I use them mostly for audio and text messaging, but they can also
--be used to enable slots or add other things when these events happen. 

-- Way Point 1 Functions -------------------------------------------------------------------
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
    addStockBlue()
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

-- Way Point 1 Functions -------------------------------------------------------------------
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
    addStockBlue()
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

-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function QabrasSittAirbase:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = QabrasSittAirbase:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function QabrasSittAirbase:OnAfterCaptured(From, Event, To, Coalition)
  local name = QabrasSittAirbase:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function QabrasSittAirbase:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = QabrasSittAirbase:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function QabrasSittAirbase:OnAfterEmpty(From, Event, To)
  local name = QabrasSittAirbase:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end




-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function RayakArea:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RayakArea:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function RayakArea:OnAfterCaptured(From, Event, To, Coalition)
  local name = RayakArea:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function RayakArea:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RayakArea:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function RayakArea:OnAfterEmpty(From, Event, To)
  local name = RayakArea:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end



-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function RayakAirbase:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RayakAirbase:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function RayakAirbase:OnAfterCaptured(From, Event, To, Coalition)
  local name = RayakAirbase:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function RayakAirbase:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RayakAirbase:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function RayakAirbase:OnAfterEmpty(From, Event, To)
  local name = RayakAirbase:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end



-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function BeirutArea:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = BeirutArea:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function BeirutArea:OnAfterCaptured(From, Event, To, Coalition)
  local name = BeirutArea:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function BeirutArea:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = BeirutArea:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function BeirutArea:OnAfterEmpty(From, Event, To)
  local name = BeirutArea:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end


-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function BeirutAirbase:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = BeirutAirbase:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function BeirutAirbase:OnAfterCaptured(From, Event, To, Coalition)
  local name = BeirutAirbase:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function BeirutAirbase:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = BeirutAirbase:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function BeirutAirbase:OnAfterEmpty(From, Event, To)
  local name = BeirutAirbase:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end


-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function KingHussenArea:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = KingHussenArea:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function KingHussenArea:OnAfterCaptured(From, Event, To, Coalition)
  local name = KingHussenArea:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function KingHussenArea:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = KingHussenArea:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function KingHussenArea:OnAfterEmpty(From, Event, To)
  local name = KingHussenArea:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end


-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function KingHussenAirbase:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = KingHussenAirbase:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function KingHussenAirbase:OnAfterCaptured(From, Event, To, Coalition)
  local name = KingHussenAirbase:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function KingHussenAirbase:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = KingHussenAirbase:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function KingHussenAirbase:OnAfterEmpty(From, Event, To)
  local name = KingHussenAirbase:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function ThalahArea:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = ThalahArea:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function ThalahArea:OnAfterCaptured(From, Event, To, Coalition)
  local name = ThalahArea:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function ThalahArea:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = ThalahArea:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function ThalahArea:OnAfterEmpty(From, Event, To)
  local name = ThalahArea:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end




-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function ThalahAirbase:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = ThalahAirbase:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function ThalahAirbase:OnAfterCaptured(From, Event, To, Coalition)
  local name = ThalahAirbase:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function ThalahAirbase:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = ThalahAirbase:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function ThalahAirbase:OnAfterEmpty(From, Event, To)
  local name = ThalahAirbase:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end


-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function KhalkhalahArea:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = KhalkhalahArea:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function KhalkhalahArea:OnAfterCaptured(From, Event, To, Coalition)
  local name = KhalkhalahArea:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function KhalkhalahArea:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = KhalkhalahArea:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function KhalkhalahArea:OnAfterEmpty(From, Event, To)
  local name = KhalkhalahArea:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end



-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function KhalkhalahAirbase:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = KhalkhalahAirbase:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function KhalkhalahAirbase:OnAfterCaptured(From, Event, To, Coalition)
  local name = KhalkhalahAirbase:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function KhalkhalahAirbase:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = KhalkhalahAirbase:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function KhalkhalahAirbase:OnAfterEmpty(From, Event, To)
  local name = KhalkhalahAirbase:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end



-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function AnNasiriyahArea:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = AnNasiriyahArea:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function AnNasiriyahArea:OnAfterCaptured(From, Event, To, Coalition)
  local name = AnNasiriyahArea:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function AnNasiriyahArea:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = AnNasiriyahArea:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function AnNasiriyahArea:OnAfterEmpty(From, Event, To)
  local name = AnNasiriyahArea:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end



-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function AnNasiriyahAirbase:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = AnNasiriyahAirbase:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function AnNasiriyahAirbase:OnAfterCaptured(From, Event, To, Coalition)
  local name = AnNasiriyahAirbase:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function AnNasiriyahAirbase:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = AnNasiriyahAirbase:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function AnNasiriyahAirbase:OnAfterEmpty(From, Event, To)
  local name = AnNasiriyahAirbase:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end




-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function SayqalArea:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = SayqalArea:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function SayqalArea:OnAfterCaptured(From, Event, To, Coalition)
  local name = SayqalArea:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function SayqalArea:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = SayqalArea:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function SayqalArea:OnAfterEmpty(From, Event, To)
  local name = SayqalArea:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end


-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function SayqalAirbase:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = SayqalAirbase:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function SayqalAirbase:OnAfterCaptured(From, Event, To, Coalition)
  local name = SayqalAirbase:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function SayqalAirbase:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = SayqalAirbase:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function SayqalAirbase:OnAfterEmpty(From, Event, To)
  local name = SayqalAirbase:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end



-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function AlDumayrArea:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = AlDumayrArea:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function AlDumayrArea:OnAfterCaptured(From, Event, To, Coalition)
  local name = AlDumayrArea:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function AlDumayrArea:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = AlDumayrArea:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function AlDumayrArea:OnAfterEmpty(From, Event, To)
  local name = AlDumayrArea:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end



-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function AlDumayrAirbase:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = AlDumayrAirbase:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function AlDumayrAirbase:OnAfterCaptured(From, Event, To, Coalition)
  local name = AlDumayrAirbase:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function AlDumayrAirbase:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = AlDumayrAirbase:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function AlDumayrAirbase:OnAfterEmpty(From, Event, To)
  local name = AlDumayrAirbase:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end



-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function QabrasSittAirbase:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = QabrasSittAirbase:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function QabrasSittAirbase:OnAfterCaptured(From, Event, To, Coalition)
  local name = QabrasSittAirbase:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function QabrasSittAirbase:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = QabrasSittAirbase:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function QabrasSittAirbase:OnAfterEmpty(From, Event, To)
  local name = QabrasSittAirbase:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end


-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function MezzehAirbase:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = MezzehAirbase:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function MezzehAirbase:OnAfterCaptured(From, Event, To, Coalition)
  local name = MezzehAirbase:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function MezzehAirbase:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = MezzehAirbase:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function MezzehAirbase:OnAfterEmpty(From, Event, To)
  local name = MezzehAirbase:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end


-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function MarjSultanNorthAirbase:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = MarjSultanNorthAirbase:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function MarjSultanNorthAirbase:OnAfterCaptured(From, Event, To, Coalition)
  local name = MarjSultanNorthAirbase:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function MarjSultanNorthAirbase:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = MarjSultanNorthAirbase:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function MarjSultanNorthAirbase:OnAfterEmpty(From, Event, To)
  local name = MarjSultanNorthAirbase:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end



-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function MarjSultanSouthAirbase:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = MarjSultanSouthAirbase:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function MarjSultanSouthAirbase:OnAfterCaptured(From, Event, To, Coalition)
  local name = MarjSultanSouthAirbase:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function MarjSultanSouthAirbase:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = MarjSultanSouthAirbase:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function MarjSultanSouthAirbase:OnAfterEmpty(From, Event, To)
  local name = MarjSultanSouthAirbase:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end



-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function DamascusAirbase:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = DamascusAirbase:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function DamascusAirbase:OnAfterCaptured(From, Event, To, Coalition)
  local name = DamascusAirbase:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function DamascusAirbase:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = DamascusAirbase:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function DamascusAirbase:OnAfterEmpty(From, Event, To)
  local name = DamascusAirbase:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end



-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function MarjRuhAirbase:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = MarjRuhAirbase:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function MarjRuhAirbase:OnAfterCaptured(From, Event, To, Coalition)
  local name = MarjRuhAirbase:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function MarjRuhAirbase:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = MarjRuhAirbase:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function MarjRuhAirbase:OnAfterEmpty(From, Event, To)
  local name = MarjRuhAirbase:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end

-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function DamascusArea:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = DamascusArea:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function DamascusArea:OnAfterCaptured(From, Event, To, Coalition)
  local name = DamascusArea:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function DamascusArea:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = DamascusArea:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function DamascusArea:OnAfterEmpty(From, Event, To)
  local name = DamascusArea:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end


-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function WujahArea:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = WujahArea:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function WujahArea:OnAfterCaptured(From, Event, To, Coalition)
  local name = WujahArea:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function WujahArea:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = WujahArea:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function WujahArea:OnAfterEmpty(From, Event, To)
  local name = WujahArea:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end


-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function WujahAirbase:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = WujahAirbase:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function WujahAirbase:OnAfterCaptured(From, Event, To, Coalition)
  local name = WujahAirbase:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function WujahAirbase:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = WujahAirbase:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function WujahAirbase:OnAfterEmpty(From, Event, To)
  local name = WujahAirbase:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end


-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function RayakArea:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RayakArea:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function RayakArea:OnAfterCaptured(From, Event, To, Coalition)
  local name = RayakArea:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function RayakArea:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RayakArea:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function RayakArea:OnAfterEmpty(From, Event, To)
  local name = RayakArea:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end



-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function RayakAirbase:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RayakAirbase:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function RayakAirbase:OnAfterCaptured(From, Event, To, Coalition)
  local name = RayakAirbase:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function RayakAirbase:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RayakAirbase:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function RayakAirbase:OnAfterEmpty(From, Event, To)
  local name = RayakAirbase:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end


-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function KirvatArea:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = KirvatArea:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function KirvatArea:OnAfterCaptured(From, Event, To, Coalition)
  local name = KirvatArea:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function KirvatArea:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = KirvatArea:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function KirvatArea:OnAfterEmpty(From, Event, To)
  local name = KirvatArea:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end




-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function KirvatAirbase:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = KirvatAirbase:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function KirvatAirbase:OnAfterCaptured(From, Event, To, Coalition)
  local name = KirvatAirbase:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function KirvatAirbase:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = KirvatAirbase:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function KirvatAirbase:OnAfterEmpty(From, Event, To)
  local name = KirvatAirbase:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end


-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function NaqouraArea:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = NaqouraArea:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function NaqouraArea:OnAfterCaptured(From, Event, To, Coalition)
  local name = NaqouraArea:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function NaqouraArea:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = NaqouraArea:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function NaqouraArea:OnAfterEmpty(From, Event, To)
  local name = NaqouraArea:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end



-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function NaqouraAirbase:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = NaqouraAirbase:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function NaqouraAirbase:OnAfterCaptured(From, Event, To, Coalition)
  local name = NaqouraAirbase:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function NaqouraAirbase:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = NaqouraAirbase:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function NaqouraAirbase:OnAfterEmpty(From, Event, To)
  local name = NaqouraAirbase:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end



-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function RoshPinaArea:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoshPinaArea:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function RoshPinaArea:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoshPinaArea:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function RoshPinaArea:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoshPinaArea:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function RoshPinaArea:OnAfterEmpty(From, Event, To)
  local name = RoshPinaArea:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end



-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function RoshPinaAirbase:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = RoshPinaAirbase:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function RoshPinaAirbase:OnAfterCaptured(From, Event, To, Coalition)
  local name = RoshPinaAirbase:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function RoshPinaAirbase:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = RoshPinaAirbase:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function RoshPinaAirbase:OnAfterEmpty(From, Event, To)
  local name = RoshPinaAirbase:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end



-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function HaifaArea:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = HaifaArea:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function HaifaArea:OnAfterCaptured(From, Event, To, Coalition)
  local name = HaifaArea:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function HaifaArea:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = HaifaArea:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function HaifaArea:OnAfterEmpty(From, Event, To)
  local name = HaifaArea:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end


-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function HaifaAirbase:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = HaifaAirbase:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function HaifaAirbase:OnAfterCaptured(From, Event, To, Coalition)
  local name = HaifaAirbase:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function HaifaAirbase:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = HaifaAirbase:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function HaifaAirbase:OnAfterEmpty(From, Event, To)
  local name = HaifaAirbase:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end



-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function MegiddoAirbase:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = MegiddoAirbase:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function MegiddoAirbase:OnAfterCaptured(From, Event, To, Coalition)
  local name = MegiddoAirbase:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function MegiddoAirbase:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = MegiddoAirbase:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function MegiddoAirbase:OnAfterEmpty(From, Event, To)
  local name = MegiddoAirbase:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end


-- After Attacked
function MegiddoArea:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = MegiddoArea:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function MegiddoArea:OnAfterCaptured(From, Event, To, Coalition)
  local name = MegiddoArea:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function MegiddoArea:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = MegiddoArea:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function MegiddoArea:OnAfterEmpty(From, Event, To)
  local name = MegiddoArea:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end


-- Way Point 1 Functions -------------------------------------------------------------------
-- After Attacked
function EynSheMerArea:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = EynSheMerArea:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function EynSheMerArea:OnAfterCaptured(From, Event, To, Coalition)
  local name = EynSheMerArea:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end

--- After Defeated
function EynSheMerArea:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = EynSheMerArea:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end

-- After Empty
function EynSheMerArea:OnAfterEmpty(From, Event, To)
  local name = EynSheMerArea:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end



-- After Attacked
function EynSheMerAirbase:OnAfterAttacked(From, Event, To, AttackerCoalition)
  local name = EynSheMerAirbase:GetName()
  local coa = AttackerCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has attacked " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio1.ogg"):ToAll()
end

-- After Capture
function EynSheMerAirbase:OnAfterCaptured(From, Event, To, Coalition)
  local name = EynSheMerAirbase:GetName()
  local coa = Coalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has captured " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has captured " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio2.ogg"):ToAll()
end
--- After Defeated
function EynSheMerAirbase:OnAfterDefeated(From, Event, To, DefeatedCoalition)
  local name = EynSheMerAirbase:GetName()
  local coa = DefeatedCoalition
  if (coa == 2) then -- usa
    MESSAGE:New("NATO has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()
  else -- it was some other bad guy..
    MESSAGE:New("Russia has been defeated at " .. name .. "!", msgTime, msgCat, false):ToAll()  
  end
  USERSOUND:New("combatAudio3.ogg"):ToAll()
end
-- After Empty
function EynSheMerAirbase:OnAfterEmpty(From, Event, To)
  local name = EynSheMerAirbase:GetName()
  MESSAGE:New(name .. " has been cleared of enemy forces and can be captured!", msgTime, msgCat, false):ToAll()
  USERSOUND:New("combatAudio4.ogg"):ToAll()  
end



