--[[
    EXAMPLE: How to Add MenuManager to Your Mission
    
    This file shows the proper load order and trigger setup
    for using the Unified F10 Menu System in your DCS mission.
]]--

--[[
===============================================================================
STEP 1: MISSION EDITOR - TRIGGERS TAB
===============================================================================

Create a new trigger:

Trigger Name: "Load Mission Scripts"
Type: ONCE
Event: MISSION START

CONDITIONS:
  - TIME MORE (1) [This ensures mission is fully initialized]

ACTIONS (in this exact order):
  1. DO SCRIPT FILE: Moose.lua
  2. DO SCRIPT FILE: Moose_MenuManager.lua
  3. DO SCRIPT FILE: CTLD.lua
  4. DO SCRIPT FILE: Moose_FAC2MarkRecceZone.lua
  5. DO SCRIPT FILE: Moose_Intel.lua
  6. DO SCRIPT FILE: Moose_CaptureZones.lua
  7. DO SCRIPT FILE: Moose_NavalGroup.lua
  8. DO SCRIPT FILE: Moose_TADC_Load2nd.lua
  9. DO SCRIPT FILE: Moose_TADC_SquadronConfigs_Load1st.lua
  10. DO SCRIPT FILE: OnBirthMessage.lua
  11. ... (any other scripts)

===============================================================================
STEP 2: FILE PLACEMENT
===============================================================================

Place all .lua files in your mission folder:
C:\Users\[YourName]\Saved Games\DCS\Missions\[MissionName].miz\

Or use the mission editor:
1. Right-click mission in editor
2. "Edit Mission" 
3. Click "Load/Unload lua scripts"
4. Add files in order shown above

===============================================================================
STEP 3: VERIFY LOAD ORDER
===============================================================================

After mission loads, press F10 and verify:
- F1: Mission Options (with submenus)
- F2: CTLD
- F3: AFAC Control

If order is wrong, check your trigger actions order.

===============================================================================
STEP 4: CONFIGURATION (OPTIONAL)
===============================================================================

Edit Moose_MenuManager.lua to customize:
]]--

MenuManager.Config = {
    EnableMissionOptionsMenu = true,      -- Set to false to disable parent menu
    MissionOptionsMenuName = "Mission Options",  -- Change to "Utilities" or whatever
    Debug = false                         -- Set to true for debug logging
}

--[[
===============================================================================
STEP 5: TESTING
===============================================================================

1. Save mission
2. Load mission in DCS
3. Spawn as pilot
4. Press F10
5. Check menu structure matches expected layout

Expected result:
F10 → Other Radio Items
  ├─ F1: Mission Options
  │    ├─ INTEL HQ
  │    ├─ Zone Control
  │    ├─ CVN Command
  │    └─ TADC Utilities
  ├─ F2: CTLD
  └─ F3: AFAC Control

===============================================================================
TROUBLESHOOTING
===============================================================================

Problem: Menus in wrong order
Solution: Check trigger actions are in correct order

Problem: "Mission Options" missing
Solution: Verify Moose_MenuManager.lua loaded before other scripts

Problem: CTLD not at F2
Solution: Ensure CTLD.lua loads right after Moose_MenuManager.lua

Problem: Script errors
Solution: Check dcs.log file at:
  C:\Users\[YourName]\Saved Games\DCS\Logs\dcs.log

Enable debug mode in MenuManager for detailed logging:
  MenuManager.Config.Debug = true

===============================================================================
ADVANCED: MULTIPLE COALITION MENUS
===============================================================================

If your mission has both RED and BLUE players:

The MenuManager automatically creates "Mission Options" for both:
- BLUE players see: F10 → F1: Mission Options (BLUE)
- RED players see: F10 → F1: Mission Options (RED)

Each coalition's scripts only appear in their respective menu.

===============================================================================
ADVANCED: DISABLING INDIVIDUAL MENUS
===============================================================================

To hide a specific script's F10 menu without removing the script:

In Moose_Intel.lua:
  local EnableF10Menu = false  -- Disables Intel menu

In Moose_CaptureZones.lua:
  -- Comment out the SetupZoneStatusCommands() call

This is useful for:
- Training missions (hide complexity)
- Specific mission types (no CVN = no CVN menu)
- Server performance (reduce menu overhead)

===============================================================================
EXAMPLE: ADDING YOUR OWN SCRIPT
===============================================================================

If you create a new script "MyCustomScript.lua":

1. Add to trigger after Moose_MenuManager.lua
2. In your script, use this pattern:
]]--

-- MyCustomScript.lua
local MyMenu
if MenuManager then
  -- Will be under "Mission Options"
  MyMenu = MenuManager.CreateCoalitionMenu(coalition.side.BLUE, "My Custom Feature")
else
  -- Fallback if MenuManager not loaded
  MyMenu = MENU_COALITION:New(coalition.side.BLUE, "My Custom Feature")
end

-- Add your commands
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Do Something Cool", MyMenu, function()
  MESSAGE:New("Cool thing happened!", 10):ToBlue()
end)

--[[
===============================================================================
EXAMPLE: MISSION-WIDE MENU (Both Coalitions)
===============================================================================

For features available to all players:
]]--

local UtilityMenu
if MenuManager then
  UtilityMenu = MenuManager.CreateMissionMenu("Server Utilities")
else
  UtilityMenu = MENU_MISSION:New("Server Utilities")
end

MENU_MISSION_COMMAND:New("Show Server Time", UtilityMenu, function()
  local time = timer.getAbsTime()
  local hours = math.floor(time / 3600)
  local minutes = math.floor((time % 3600) / 60)
  MESSAGE:New(string.format("Server Time: %02d:%02d", hours, minutes), 5):ToAll()
end)

--[[
===============================================================================
COMPLETE TRIGGER EXAMPLE (COPY/PASTE)
===============================================================================

Trigger Name: Load Mission Scripts
Type: ONCE
Event: MISSION START
Condition: TIME MORE (1)

Actions:
DO SCRIPT FILE: Moose.lua
DO SCRIPT FILE: Moose_MenuManager.lua
DO SCRIPT FILE: CTLD.lua
DO SCRIPT FILE: Moose_FAC2MarkRecceZone.lua
DO SCRIPT FILE: Moose_Intel.lua
DO SCRIPT FILE: Moose_CaptureZones.lua
DO SCRIPT FILE: Moose_NavalGroup.lua
DO SCRIPT FILE: Moose_TADC_Load2nd.lua

===============================================================================
NOTES
===============================================================================

- MenuManager is backward compatible: scripts work with or without it
- CTLD and FAC use group menus (not coalition), so they stay at root level
- Load order determines F-key positions
- Mission Options will be F1 because it loads after CTLD (F2) and FAC (F3)
- All other scripts nest under Mission Options automatically

===============================================================================
]]--
