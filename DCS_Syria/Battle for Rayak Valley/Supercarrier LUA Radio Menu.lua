
local level_1_group = missionCommands.addSubMenu("Deck Layouts")


local action = missionCommands.addCommand("Clear the Deck", level_1_group, trigger.action.setUserFlag, 1, 1)
local level_2_group = missionCommands.addSubMenu("Swith Deck Layout", level_1_group)


local level_3_group = missionCommands.addSubMenu("Launch", level_2_group)
local action = missionCommands.addCommand("Launch 2 Spawn Cat 34", level_3_group, trigger.action.setUserFlag, 2, 1)
local action = missionCommands.addCommand("Launch 2 Spawn Cat 234", level_3_group, trigger.action.setUserFlag, 3, 1)
local action = missionCommands.addCommand("Launch 4 Spawn Cat 34", level_3_group, trigger.action.setUserFlag, 4, 1)
local action = missionCommands.addCommand("Launch 4 Spawn Cat 134", level_3_group, trigger.action.setUserFlag, 5, 1)
local action = missionCommands.addCommand("Launch 9 Spawn Cat 134", level_3_group, trigger.action.setUserFlag, 6, 1)
local action = missionCommands.addCommand("Launch 11 Spawn Cat 234", level_3_group, trigger.action.setUserFlag, 7, 1)
local action = missionCommands.addCommand("Launch 11 Spawn Cat 1234", level_3_group, trigger.action.setUserFlag, 8, 1)

local level_3_group = missionCommands.addSubMenu("Flex & Recovery", level_2_group)
local action = missionCommands.addCommand("Flex 2 Spawn Cat 234", level_3_group, trigger.action.setUserFlag, 9, 1)
local action = missionCommands.addCommand("Flex 4 Spawn Cat 134 Cat 2 Parking", level_3_group, trigger.action.setUserFlag, 10, 1)
local action = missionCommands.addCommand("Flex 10 Spawn Cat 134 Sixpack Parking", level_3_group, trigger.action.setUserFlag, 11, 1)
local action = missionCommands.addCommand("Flex 9 Spawn Cat 134 Cat 2 Parking", level_3_group, trigger.action.setUserFlag, 12, 1)
local action = missionCommands.addCommand("Recovery 2 Spawn Cat 2 Parking", level_3_group, trigger.action.setUserFlag, 13, 1)

local action = missionCommands.addCommand("Locked Deck", level_2_group, trigger.action.setUserFlag, 14, 1)

local action = missionCommands.addCommand("Clear Deck", level_2_group, trigger.action.setUserFlag, 15, 1)





