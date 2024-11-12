--[[

  Code for the moose missions. 


--]]  
  
  WarehouseMission = MISSION
  :New( RedCC, "Overlord", "Primary", "Destroy enemy warehouse network!", coalition.side.RED )
  :AddScoring( Scoring )

  WarehouseMissionAttackGroups = SET_GROUP:New():FilterCoalitions( "red" ):FilterStart()


  WarehouseMissionTargetSetUnit = SET_UNIT:New():FilterCoalitions("blue"):FilterPrefixes( "WAREHOUSE" ):FilterStart()
  -- WarehouseMissionTargetSetUnit = SET_STATIC:FilterPrefixes("WAREHOUSE")
  
  

  WarehouseMissionTaskBAI = TASK_A2G_BAI:New( WarehouseMission, WarehouseMissionAttackGroups,"BAI", WarehouseMissionTargetSetUnit )