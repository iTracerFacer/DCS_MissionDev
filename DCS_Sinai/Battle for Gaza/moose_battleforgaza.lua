_SETTINGS:SetPlayerMenuOff()
--env.info("Loading Main Script", true)
-- Setup Command Centers. See Moose_ErmenekLiberation_ZoneCapture.lua for remaining code.
-- Set SRS settings
STTS.DIRECTORY = "C:\\Program Files\\DCS-SimpleRadio-Standalone"
STTS.SRS_PORT = "5002"

Airbase_Ramon = CLEANUP_AIRBASE:New( AIRBASE.Sinai.Ramon_Airbase )
Airbase_Ramon:SetCleanMissiles(false)

local msgTime = 15

-- Ground Limits
local red_shilka = 10
local red_closeAAA = 25
local red_mortar_team = 10
local red_scout_dshk = 25
local red_scout_kord = 25
local red_manpads = 40
local red_roadblock_infantry = 25

--Sam Limits
local red_sa10_limit = 60
local red_sa10_max = 90
local red_sa11_limit = 24
local red_sa11_max = 24
local red_sa02_limit = 20
local red_sa02_max = 40
local red_sa08_limit = 5
local red_sa08_max = 5
local red_sa15_limit = 3
local red_sa15_max = 5



-- _limit = limit number of alive units at a time.
-- _max = max number of units that can spawn over the course of the mission.



local palhim_attack_limit = 8
local palhim_attack_max = 200
local palmahim_defense_limit = 8
local palmahim_defense_max = 200

local hatzor_attack_limit = 8
local hatzor_attack_max = 200
local hatzor_attack_defense_limit = 8
local hatzor_attack_defense_max = 200

local telnof_attack_limit = 8
local telnof_attack_max = 200
local telnof_attack_defense_limit = 8
local telnof_attack_defense_max = 200


local red_cap = 2
local blue_cap = 2
local RedA2ADefaultOverhead = 1.5 -- Default 1 - This is a multipler. If you set to 2 - you will have 2 enemy aircraft spawn for every 1 you have in their zone.
local BlueA2ADefaultOverhead = 1 -- Default 1 - This is a multipler. If you set to 2 - you will have 2 enemy aircraft spawn for every 1 you have in their zone.

  --Build Command Center and Mission for Blue
US_CC = COMMANDCENTER:New( GROUP:FindByName( "BLUEHQ" ), "USA HQ" )
US_Mission = MISSION:New( US_CC, "Battle for Gaza", "Primary", "Free the city of Gaza from insurgent forces.", coalition.side.BLUE)    
US_Score = SCORING:New( "Battle for Gaza - Blue" )
US_Mission:AddScoring( US_Score )
US_Mission:Start()
US_Score:SetMessagesHit(false)
US_Score:SetMessagesDestroy(false)
US_Score:SetMessagesScore(false)  
    
--Build Command Center and Mission Red
RU_CC = COMMANDCENTER:New( GROUP:FindByName( "REDHQ" ), "Russia HQ" )
RU_Mission = MISSION:New (RU_CC, "Battle for Gaza", "Primary", "Destroy U.S. and Israeli forces", coalition.side.RED)
RU_Score = SCORING:New("Battle for Gaza - Red")
RU_Mission:AddScoring( RU_Score)
RU_Mission:Start()
RU_Score:SetMessagesHit(false)
RU_Score:SetMessagesDestroy(false)
RU_Score:SetMessagesScore(false)




PlayerClients = SET_PLAYER:New():FilterStart()
  :HandleEvent( EVENTS.Crash )
function PlayerClients:OnEventCrash( EventData )
  
  local coal = EventData.initiator:getCoalition()
  local side, oside
  if coal == 1 then
      side = 'RED'
      oside = 'BLUE'
      MissionPlayerName = EventData.initiator:getPlayerName() 
      if MissionPlayerName ~= nil then
        MESSAGE:New("\n\nA " .. side .. " player ( " .. MissionPlayerName .. " ) has crashed! ", msgTime, "Alert!"):ToAll()
        end
 
    elseif coal == 2 then 
     
    side = 'BLUE'
    oside = 'RED'
    MissionPlayerName = EventData.initiator:getPlayerName() 
    if  MissionPlayerName ~= nil then

      local current_time = os.time()     -- Get the current date and time
      local formatted_time = os.date("%A, %B %d, %Y %I:%M:%S %p", current_time) -- Format the date and time
      MESSAGE:New("\n\nAt .. " .. formatted_time .. ": " .. MissionPlayerName .. " ) was shot down over the skies of Israel. Insurgent fighters could be heard screaming something over the radio about aloha and snack bars..", msgTime, "Alert!"):ToAll()
      USERSOUND:New("AllahuAkbar.ogg"):ToAll()
    end
  else
    env.info("**** We should not have gotten here! moose_battleforgaza.lua ****")
  end    
end


Refugee_Zone_1 = ZONE:New("Refugee Camp 1")
Refugee_Zone_2 = ZONE:New("Refugee Camp 2")
Medical_Supplies_1 = ZONE:New("Medcal Supplies 1")
Medical_Supplies_2 = ZONE:New("Medcal Supplies 2")







local GAZA = ZONE_POLYGON:New( "GAZA", GROUP:FindByName( "GAZA" ))
local GazaZoneTable = {
  GAZA
}


local RED_SAM_ZONE_1 = ZONE:New("RED SAM ZONE-1")
local RED_SAM_ZONE_2 = ZONE:New("RED SAM ZONE-2")

local red_same_zone_table = {
  RED_SAM_ZONE_1,
  RED_SAM_ZONE_2,

}

 



local ROADBLOCK_A1 = ZONE:New("ROAD BLOCK A-1")
local ROADBLOCK_A2 = ZONE:New("ROAD BLOCK A-2")
local ROADBLOCK_A3 = ZONE:New("ROAD BLOCK A-3")
local ROADBLOCK_A4 = ZONE:New("ROAD BLOCK A-4")
local ROADBLOCK_A5 = ZONE:New("ROAD BLOCK A-5")
local ROADBLOCK_A6 = ZONE:New("ROAD BLOCK A-6")
local ROADBLOCK_A7 = ZONE:New("ROAD BLOCK A-7")
local ROADBLOCK_A8 = ZONE:New("ROAD BLOCK A-8")
local ROADBLOCK_A9 = ZONE:New("ROAD BLOCK A-9")
local ROADBLOCK_A10 = ZONE:New("ROAD BLOCK A-10")
local ROADBLOCK_A11 = ZONE:New("ROAD BLOCK A-11")
local ROADBLOCK_A12 = ZONE:New("ROAD BLOCK A-12")
local ROADBLOCK_A13 = ZONE:New("ROAD BLOCK A-13")
local ROADBLOCK_A14 = ZONE:New("ROAD BLOCK A-14")
local ROADBLOCK_A15 = ZONE:New("ROAD BLOCK A-15")
local ROADBLOCK_A16 = ZONE:New("ROAD BLOCK A-16")
local ROADBLOCK_A17 = ZONE:New("ROAD BLOCK A-17")
local ROADBLOCK_A18 = ZONE:New("ROAD BLOCK A-18")
local ROADBLOCK_A19 = ZONE:New("ROAD BLOCK A-19")
local ROADBLOCK_A20 = ZONE:New("ROAD BLOCK A-20")
local ROADBLOCK_A21 = ZONE:New("ROAD BLOCK A-21")
local ROADBLOCK_A22 = ZONE:New("ROAD BLOCK A-22")
local ROADBLOCK_A23 = ZONE:New("ROAD BLOCK A-23")
local ROADBLOCK_A24 = ZONE:New("ROAD BLOCK A-24")
local ROADBLOCK_A25 = ZONE:New("ROAD BLOCK A-25")
local ROADBLOCK_A26 = ZONE:New("ROAD BLOCK A-26")
local ROADBLOCK_A27 = ZONE:New("ROAD BLOCK A-27")
local ROADBLOCK_A28 = ZONE:New("ROAD BLOCK A-28")
local ROADBLOCK_A29 = ZONE:New("ROAD BLOCK A-29")
local ROADBLOCK_A30 = ZONE:New("ROAD BLOCK A-30")


local ZoneTableRoadBlocks = {
  ROADBLOCK_A1,
  ROADBLOCK_A2,
  ROADBLOCK_A3,
  ROADBLOCK_A4,
  ROADBLOCK_A5,
  ROADBLOCK_A6,
  ROADBLOCK_A7,
  ROADBLOCK_A8,
  ROADBLOCK_A9,
  ROADBLOCK_A10,
  ROADBLOCK_A12,
  ROADBLOCK_A13,
  ROADBLOCK_A14,
  ROADBLOCK_A15,
  ROADBLOCK_A16,
  ROADBLOCK_A17,
  ROADBLOCK_A18,
  ROADBLOCK_A19,
  ROADBLOCK_A20,
  ROADBLOCK_A21,
  ROADBLOCK_A22,
  ROADBLOCK_A23,
  ROADBLOCK_A24,
  ROADBLOCK_A25,
  ROADBLOCK_A26,
  ROADBLOCK_A27,
  ROADBLOCK_A28,
  ROADBLOCK_A29,
  ROADBLOCK_A30,
  
}

Spawn_Blue_Israel_Reinforcements = SPAWN:New("Israel Reinforcements")
:InitRandomizeZones(GazaZoneTable)
--:Spawn() Spawned elsewhere upon sucessful task completion.  




Spawn_SA10 = SPAWN:New("RED EWR SA10")
:InitLimit(red_sa10_limit, red_sa10_max)
:InitRandomizeZones(red_same_zone_table)
:SpawnScheduled(1500,.3)

Spawn_SA11 = SPAWN:New("RED EWR SA11")
:InitLimit(red_sa11_limit, red_sa11_max)
:InitRandomizeZones(red_same_zone_table)
:SpawnScheduled(1500,.2)

--Spawn_SA02 = SPAWN:New("RED EWR SA02")
--:InitLimit(red_sa02_limit, red_sa02_max)
--:InitRandomizeZones(red_same_zone_table)
--:SpawnScheduled(1500,.5)
--
Spawn_SA15 = SPAWN:New("RED EWR SA15")
:InitLimit(red_sa15_limit, red_sa15_max)
:InitRandomizeZones(red_same_zone_table)
:SpawnScheduled(1500,.5)

Spawn_RED_SAM_Shilka = SPAWN:New("RED SAM Shilka")
:InitLimit(red_shilka, red_shilka)
:InitRandomizeZones(GazaZoneTable)
:SpawnScheduled(1,.5)

Spawn_RED_Mortar_Team = SPAWN:New("red_mortar_team")
:InitLimit(red_mortar_team, red_mortar_team)
:InitRandomizeZones(GazaZoneTable)
:SpawnScheduled(1,.5)  

Spawn_RED_Scout_dshk = SPAWN:New("RED SCOUNT DSHK")
:InitLimit(red_scout_dshk, red_scout_dshk)
:InitRandomizeZones(GazaZoneTable)
:SpawnScheduled(1,.5)  

Spawn_RED_Scout_kord = SPAWN:New("RED SCOUNT KORD")
:InitLimit(red_scout_kord, red_scout_kord)
:InitRandomizeZones(GazaZoneTable)
:SpawnScheduled(1,.5) 
  
Spawn_RED_ManPad = SPAWN:New("red_manpad")
:InitLimit(red_manpads, red_manpads)
:InitRandomizeZones(GazaZoneTable)
:SpawnScheduled(1,.5)

Spawn_red_closeAAA = SPAWN:New("red_closeAAA")
:InitLimit(red_closeAAA, red_closeAAA)
:InitRandomizeZones(GazaZoneTable)
:SpawnScheduled(1,.5)



Spawn_RED_RoadBlockInfantry = SPAWN:New("Insurgents")
:InitLimit(red_roadblock_infantry, red_roadblock_infantry)
:InitRandomizeZones(ZoneTableRoadBlocks)
:SpawnScheduled(1,.5)

Spawn_Palmahim_Attack_Group = SPAWN:New("Palmahim_Attack_1")
:InitLimit(palhim_attack_limit, palhim_attack_max)
:SpawnScheduled(1200,.2)

Spawn_TelNof_Group = SPAWN:New("Palmahim_Defense")
:InitLimit(telnof_attack_limit, telnof_attack_max)
:SpawnScheduled(1200,.2) 

Spawn_Hatzor_Attack_Group = SPAWN:New("Hatzor_Attack")
:InitLimit(hatzor_attack_limit, hatzor_attack_max)
:SpawnScheduled(1200,.2)

Spawn_TelNof_Group = SPAWN:New("TelNof_Attack")
:InitLimit(telnof_attack_limit, telnof_attack_max)
:SpawnScheduled(1200,.2)

Spawn_TelNof_Group = SPAWN:New("Palmahim_Defense")
:InitLimit(telnof_attack_limit, telnof_attack_max)
:SpawnScheduled(1200,.2)    


Spawn_RED_EWR_AWACS = SPAWN:New("RED EWR AWACS")
:InitLimit(1, 500)
:SpawnScheduled(1,.5)

Spawn_Egypt_Incursion_Force = SPAWN:New("Egypt Incursion Force")
:InitLimit(1, 125)
:SpawnScheduled(2500,.5)
:InitDelayOn()

Spawn_Egypt_Incursion_Force = SPAWN:New("Russian Incursion Force")
:InitLimit(1, 125)
:SpawnScheduled(2400,.3)
:InitDelayOn()


  -- Setup AI A2A Dispatchers

  -- Setup AI A2A Dispatchers
--Red
StCatherineBorderZone = ZONE:New( "RED SAM ZONE-1" )
RedA2ADispatcher = AI_A2A_GCICAP:New( { "RED EWR" }, { "Catherine CAP" }, { "RED SAM ZONE-1" }, red_cap )
RedA2ADispatcher:SetDefaultLandingAtRunway()
RedA2ADispatcher:SetDefaultTakeoffFromRunway()
RedA2ADispatcher:SetBorderZone( StCatherineBorderZone )
RedA2ADispatcher:SetTacticalDisplay(false)
RedA2ADispatcher:SetDefaultFuelThreshold( 0.20 )
RedA2ADispatcher:SetRefreshTimeInterval( 300 )
RedA2ADispatcher:SetDefaultOverhead(2)

--Red
CCCPBorderZone = ZONE_POLYGON:New( "RED BORDER", GROUP:FindByName( "RED BORDER" ) )
RedA2ADispatcher = AI_A2A_GCICAP:New( { "RED EWR" }, { "FIGHTER SWEEP RED" }, { "RED BORDER" }, red_cap )
RedA2ADispatcher:SetDefaultLandingAtEngineShutdown()
RedA2ADispatcher:SetDefaultTakeoffFromParkingHot()
RedA2ADispatcher:SetBorderZone( CCCPBorderZone )
RedA2ADispatcher:SetTacticalDisplay(false)
RedA2ADispatcher:SetDefaultFuelThreshold( 0.20 )
RedA2ADispatcher:SetRefreshTimeInterval( 300 )
RedA2ADispatcher:SetDefaultOverhead(RedA2ADefaultOverhead)

--Blue
BLUEBorderZone = ZONE_POLYGON:New( "BLUE BORDER", GROUP:FindByName( "BLUE BORDER" ) )
BLUEA2ADispatcher = AI_A2A_GCICAP:New( { "BLUE EWR" }, { "FIGHTER SWEEP BLUE" }, { "BLUE BORDER" }, blue_cap )  
BLUEA2ADispatcher:SetDefaultLandingAtEngineShutdown()
BLUEA2ADispatcher:SetDefaultTakeoffFromParkingHot()
BLUEA2ADispatcher:SetBorderZone( BLUEBorderZone )
BLUEA2ADispatcher:SetTacticalDisplay(false)
BLUEA2ADispatcher:SetDefaultFuelThreshold( 0.20 )
BLUEA2ADispatcher:SetRefreshTimeInterval( 300 )
BLUEA2ADispatcher:SetDefaultOverhead(BlueA2ADefaultOverhead)



  