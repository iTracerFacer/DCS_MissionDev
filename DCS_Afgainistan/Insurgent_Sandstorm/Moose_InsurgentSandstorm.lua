

  --Build Command Center and Mission for Blue
US_CC = COMMANDCENTER:New( GROUP:FindByName( "BLUEHQ" ), "USA HQ" )
US_Mission = MISSION:New( US_CC, "Insurgent Sandstorm", "Primary", "Clear the front lines of enemy activity.", coalition.side.BLUE)    
US_Score = SCORING:New( "Insurgent Sandstorm - Blue" )
US_Mission:AddScoring( US_Score )
US_Mission:Start()
US_Score:SetMessagesHit(false)
US_Score:SetMessagesDestroy(false)
US_Score:SetMessagesScore(false)  
    
--Build Command Center and Mission Red
RU_CC = COMMANDCENTER:New( GROUP:FindByName( "REDHQ" ), "Russia HQ" )
RU_Mission = MISSION:New (RU_CC, "Insurgent Sandstorm", "Primary", "Destroy U.S. and NATO forces.", coalition.side.RED)
RU_Score = SCORING:New("Insurgent Sandstorm - Red")
RU_Mission:AddScoring( RU_Score)
RU_Mission:Start()
RU_Score:SetMessagesHit(false)
RU_Score:SetMessagesDestroy(false)
RU_Score:SetMessagesScore(false)


-- How many red/blue aircraft are in the air by default.
local RedA2ADefaultOverhead = 2
local BlueA2ADefaultOverhead = 2


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
        MESSAGE:New("\n\nAt .. " .. formatted_time .. ": " .. MissionPlayerName .. " ) was shot down! Insurgent fighters could be heard screaming something over the radio about aloha and snack bars..", msgTime, "Alert!"):ToAll()
        USERSOUND:New("AllahuAkbar.ogg"):ToAll()
      end
  else
    env.info("**** We should not have gotten here! Moose_insurgentSandstorm.lua ****")
  end    
end


-- Setup AI A2A Dispatchers
--Red

CCCPBorderZone = ZONE_POLYGON:New( "RED BORDER", GROUP:FindByName( "RED BORDER" ) )
RedA2ADispatcher = AI_A2A_GCICAP:New( { "RED EWR" }, { "FIGHTER SWEEP RED" }, { "RED BORDER" }, CCCPBorderZone )
RedA2ADispatcher:SetDefaultLandingAtEngineShutdown()
RedA2ADispatcher:SetDefaultTakeoffFromParkingHot()
RedA2ADispatcher:SetBorderZone( CCCPBorderZone )
RedA2ADispatcher:SetTacticalDisplay(false)
RedA2ADispatcher:SetDefaultFuelThreshold( 0.20 )
RedA2ADispatcher:SetRefreshTimeInterval( 300 )
RedA2ADispatcher:SetDefaultOverhead(RedA2ADefaultOverhead)

--Blue
BLUEBorderZone = ZONE_POLYGON:New( "BLUE BORDER", GROUP:FindByName( "BLUE BORDER" ) )
BLUEA2ADispatcher = AI_A2A_GCICAP:New( { "BLUE EWR" }, { "FIGHTER SWEEP BLUE" }, { "BLUE BORDER" }, BLUEBorderZone )  
BLUEA2ADispatcher:SetDefaultLandingAtEngineShutdown()
BLUEA2ADispatcher:SetDefaultTakeoffFromParkingHot()
BLUEA2ADispatcher:SetBorderZone( BLUEBorderZone )
BLUEA2ADispatcher:SetTacticalDisplay(false)
BLUEA2ADispatcher:SetDefaultFuelThreshold( 0.20 )
BLUEA2ADispatcher:SetRefreshTimeInterval( 300 )
BLUEA2ADispatcher:SetDefaultOverhead(BlueA2ADefaultOverhead)

Blue_Drone = SPAWN:New("BLUE DRONE")
  :InitLimit(1, 25)
  :SpawnScheduled(600, 0.5)
