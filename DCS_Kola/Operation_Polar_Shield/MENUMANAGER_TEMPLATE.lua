--[[
    TEMPLATE: Integrating Scripts with MenuManager
    
    Use this template when updating existing scripts or creating new ones
    to work with the Unified F10 Menu System.
]]--

--=============================================================================
-- PATTERN 1: Coalition Menu (most common)
--=============================================================================

-- Configuration (add at top of script)
local EnableF10Menu = true  -- Set to false to disable F10 menu

-- Your existing script code here...

-- At the point where you create your menu (usually near the end):
if EnableF10Menu then
  local MyScriptMenu
  
  -- Use MenuManager if available, otherwise fallback to standard
  if MenuManager then
    MyScriptMenu = MenuManager.CreateCoalitionMenu(coalition.side.BLUE, "My Script Name")
  else
    MyScriptMenu = MENU_COALITION:New(coalition.side.BLUE, "My Script Name")
  end
  
  -- Add your menu commands
  MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Command 1", MyScriptMenu, MyFunction1)
  MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Command 2", MyScriptMenu, MyFunction2)
  
  -- Add submenus if needed
  local SubMenu = MENU_COALITION:New(coalition.side.BLUE, "Advanced Options", MyScriptMenu)
  MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Advanced Command", SubMenu, MyAdvancedFunction)
end

--=============================================================================
-- PATTERN 2: Mission Menu (available to all players)
--=============================================================================

if EnableF10Menu then
  local MyScriptMenu
  
  if MenuManager then
    MyScriptMenu = MenuManager.CreateMissionMenu("My Script Name")
  else
    MyScriptMenu = MENU_MISSION:New("My Script Name")
  end
  
  MENU_MISSION_COMMAND:New("Command 1", MyScriptMenu, MyFunction1)
  MENU_MISSION_COMMAND:New("Command 2", MyScriptMenu, MyFunction2)
end

--=============================================================================
-- PATTERN 3: Dual Coalition Menu (separate for each side)
--=============================================================================

if EnableF10Menu then
  -- Blue Coalition Menu
  local BlueMenu
  if MenuManager then
    BlueMenu = MenuManager.CreateCoalitionMenu(coalition.side.BLUE, "My Script Name")
  else
    BlueMenu = MENU_COALITION:New(coalition.side.BLUE, "My Script Name")
  end
  MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Blue Command", BlueMenu, MyBlueFunction)
  
  -- Red Coalition Menu
  local RedMenu
  if MenuManager then
    RedMenu = MenuManager.CreateCoalitionMenu(coalition.side.RED, "My Script Name")
  else
    RedMenu = MENU_COALITION:New(coalition.side.RED, "My Script Name")
  end
  MENU_COALITION_COMMAND:New(coalition.side.RED, "Red Command", RedMenu, MyRedFunction)
end

--=============================================================================
-- PATTERN 4: Complex Menu with Multiple Levels
--=============================================================================

if EnableF10Menu then
  -- Create main menu
  local MainMenu
  if MenuManager then
    MainMenu = MenuManager.CreateCoalitionMenu(coalition.side.BLUE, "My Script")
  else
    MainMenu = MENU_COALITION:New(coalition.side.BLUE, "My Script")
  end
  
  -- Create submenus (these don't use MenuManager, just standard MOOSE)
  local SettingsMenu = MENU_COALITION:New(coalition.side.BLUE, "Settings", MainMenu)
  local ActionsMenu = MENU_COALITION:New(coalition.side.BLUE, "Actions", MainMenu)
  
  -- Add commands to submenus
  MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Enable Feature", SettingsMenu, EnableFeature)
  MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Disable Feature", SettingsMenu, DisableFeature)
  
  MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Do Action 1", ActionsMenu, Action1)
  MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Do Action 2", ActionsMenu, Action2)
end

--=============================================================================
-- PATTERN 5: Dynamic Menu (populated at runtime)
--=============================================================================

local MainMenu = nil

function CreateDynamicMenu()
  if EnableF10Menu then
    -- Create main menu if it doesn't exist
    if not MainMenu then
      if MenuManager then
        MainMenu = MenuManager.CreateCoalitionMenu(coalition.side.BLUE, "Dynamic Menu")
      else
        MainMenu = MENU_COALITION:New(coalition.side.BLUE, "Dynamic Menu")
      end
    end
    
    -- Clear and rebuild menu items
    -- Note: MOOSE doesn't have a built-in clear, so you may need to track menu items
    -- and remove them, or just add new items dynamically
    
    -- Example: Add menu items based on game state
    for i = 1, #SomeGameStateArray do
      local item = SomeGameStateArray[i]
      MENU_COALITION_COMMAND:New(
        coalition.side.BLUE, 
        "Option " .. i .. ": " .. item.name,
        MainMenu,
        function() HandleOption(i) end
      )
    end
  end
end

-- Call this whenever game state changes
SCHEDULER:New(nil, CreateDynamicMenu, {}, 30, 30)  -- Rebuild every 30 seconds

--=============================================================================
-- PATTERN 6: Conditional Menu Creation
--=============================================================================

-- Only create menu if certain conditions are met
if EnableF10Menu then
  -- Check if feature is enabled in mission
  if CVN_GROUP and CVN_GROUP:IsAlive() then
    local CVNMenu
    if MenuManager then
      CVNMenu = MenuManager.CreateCoalitionMenu(coalition.side.BLUE, "CVN Command")
    else
      CVNMenu = MENU_COALITION:New(coalition.side.BLUE, "CVN Command")
    end
    
    MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Request CVN Status", CVNMenu, GetCVNStatus)
  end
  
  -- Check if airbase is available
  if AIRBASE:FindByName("Kutaisi") then
    local AirbaseMenu
    if MenuManager then
      AirbaseMenu = MenuManager.CreateCoalitionMenu(coalition.side.BLUE, "Kutaisi ATC")
    else
      AirbaseMenu = MENU_COALITION:New(coalition.side.BLUE, "Kutaisi ATC")
    end
    
    MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Request Landing", AirbaseMenu, RequestLanding)
  end
end

--=============================================================================
-- PATTERN 7: Menu with Event Handlers
--=============================================================================

if EnableF10Menu then
  local SettingsMenu
  if MenuManager then
    SettingsMenu = MenuManager.CreateCoalitionMenu(coalition.side.BLUE, "Settings")
  else
    SettingsMenu = MENU_COALITION:New(coalition.side.BLUE, "Settings")
  end
  
  -- Toggle setting with feedback
  local FeatureEnabled = false
  
  local function ToggleFeature()
    FeatureEnabled = not FeatureEnabled
    local status = FeatureEnabled and "ENABLED" or "DISABLED"
    MESSAGE:New("Feature is now " .. status, 5):ToBlue()
    
    -- Update menu text (by recreating menu or showing status elsewhere)
    -- Note: MOOSE doesn't allow changing menu text dynamically
  end
  
  MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Toggle Feature", SettingsMenu, ToggleFeature)
  MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Show Status", SettingsMenu, function()
    local status = FeatureEnabled and "ENABLED" or "DISABLED"
    MESSAGE:New("Feature Status: " .. status, 5):ToBlue()
  end)
end

--=============================================================================
-- PATTERN 8: Integrating Existing Script with Minimal Changes
--=============================================================================

-- BEFORE (typical existing script):
-- local MyMenu = MENU_COALITION:New(coalition.side.BLUE, "My Script")
-- MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Command", MyMenu, MyFunction)

-- AFTER (minimal change for MenuManager support):
local MyMenu
if MenuManager then
  MyMenu = MenuManager.CreateCoalitionMenu(coalition.side.BLUE, "My Script")
else
  MyMenu = MENU_COALITION:New(coalition.side.BLUE, "My Script")  -- Keep original as fallback
end
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Command", MyMenu, MyFunction)

-- That's it! Only 3 lines changed, and it's backward compatible.

--=============================================================================
-- BEST PRACTICES
--=============================================================================

--[[
1. Always check if MenuManager exists before using it
   - Ensures backward compatibility
   - Script works even if MenuManager not loaded

2. Add EnableF10Menu config option
   - Allows mission makers to disable menus without editing code
   - Useful for training missions or specific scenarios

3. Use descriptive menu names
   - "INTEL HQ" is better than "Intel"
   - "CVN Command" is better than "CVN"

4. Group related functions in submenus
   - Keeps main menu clean
   - Easier to navigate for players

5. Provide feedback for actions
   - Use MESSAGE:New() to confirm actions
   - Let players know what happened

6. Consider coalition-specific menus
   - Some features should only be available to one side
   - Use MENU_COALITION instead of MENU_MISSION

7. Test without MenuManager
   - Ensure fallback works
   - Don't rely on MenuManager being present

8. Document your menu structure
   - Comment what each menu does
   - Makes maintenance easier

9. Clean up menus when no longer needed
   - Remove dynamic menus when feature is destroyed
   - Example: Remove CVN menu when CVN is sunk

10. Use consistent naming
    - All scripts should follow same naming convention
    - Makes F10 menu predictable for players
]]--

--=============================================================================
-- COMMON MISTAKES TO AVOID
--=============================================================================

--[[
MISTAKE 1: Not checking if MenuManager exists
❌ local MyMenu = MenuManager.CreateCoalitionMenu(coalition.side.BLUE, "My Script")
✅ if MenuManager then
    MyMenu = MenuManager.CreateCoalitionMenu(coalition.side.BLUE, "My Script")
   else
    MyMenu = MENU_COALITION:New(coalition.side.BLUE, "My Script")
   end

MISTAKE 2: Creating menu too early
❌ Creating menu before MOOSE is fully initialized
✅ Create menus after all required objects exist
   Use SCHEDULER:New() with delay if needed

MISTAKE 3: Wrong menu type
❌ Using MENU_MISSION when coalition-specific menu needed
✅ Use MENU_COALITION for per-coalition features

MISTAKE 4: Not wrapping in EnableF10Menu check
❌ Always creating menu even when not wanted
✅ if EnableF10Menu then ... end

MISTAKE 5: Creating too many root menus
❌ Each script creates its own root menu
✅ Use MenuManager to group under "Mission Options"
]]--

--=============================================================================
-- TESTING CHECKLIST
--=============================================================================

--[[
After integrating MenuManager:

□ Script loads without errors
□ Menu appears in correct location (under Mission Options)
□ All menu commands work
□ Script works WITHOUT MenuManager (fallback)
□ EnableF10Menu = false hides menu
□ No duplicate menus created
□ Menu names are clear and descriptive
□ Coalition-specific menus only show to correct side
□ dcs.log shows no errors
□ Test in multiplayer (if applicable)
]]--

--=============================================================================
-- EXAMPLE: Complete Script Integration
--=============================================================================

-- Here's a complete example showing how to integrate a typical script:

--[[
-- Original Script: MyFeatureScript.lua

local function DoSomething()
  MESSAGE:New("Did something!", 5):ToBlue()
end

local function DoSomethingElse()
  MESSAGE:New("Did something else!", 5):ToBlue()
end

local MyMenu = MENU_COALITION:New(coalition.side.BLUE, "My Feature")
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Do Something", MyMenu, DoSomething)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Do Something Else", MyMenu, DoSomethingElse)
]]--

-- Updated Script: MyFeatureScript.lua (MenuManager Compatible)

-- Configuration
local EnableF10Menu = true  -- Set to false to disable F10 menu

-- Feature functions (unchanged)
local function DoSomething()
  MESSAGE:New("Did something!", 5):ToBlue()
end

local function DoSomethingElse()
  MESSAGE:New("Did something else!", 5):ToBlue()
end

-- Menu creation (updated)
if EnableF10Menu then
  local MyMenu
  if MenuManager then
    MyMenu = MenuManager.CreateCoalitionMenu(coalition.side.BLUE, "My Feature")
  else
    MyMenu = MENU_COALITION:New(coalition.side.BLUE, "My Feature")
  end
  
  MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Do Something", MyMenu, DoSomething)
  MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Do Something Else", MyMenu, DoSomethingElse)
end

-- That's it! Your script now works with MenuManager and remains backward compatible.

--=============================================================================
