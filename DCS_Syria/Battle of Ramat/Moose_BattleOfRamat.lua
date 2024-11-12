-- Setup Command Centers. See Moose_ErmenekLiberation_ZoneCapture.lua for remaining code.
  
  RU_CC = COMMANDCENTER:New( GROUP:FindByName( "REDHQ" ), "Russia HQ" )
  US_CC = COMMANDCENTER:New( GROUP:FindByName( "BLUEHQ" ), "USA HQ" )

  US_Mission = MISSION:New( US_CC, "Battle of Ramat", "Primary",
    "Keep The Megiddo Valley Clear for the duration of the mission.\n", coalition.side.BLUE)
    
  US_Score = SCORING:New( "Battle of Ramat" )
    
  US_Mission:AddScoring( US_Score )
  
  US_Mission:Start()

