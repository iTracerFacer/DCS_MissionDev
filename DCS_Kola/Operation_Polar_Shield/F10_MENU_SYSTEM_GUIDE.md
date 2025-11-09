# Unified F10 Menu System Guide

## Overview

The Unified F10 Menu Manager provides a consistent and organized F10 radio menu structure across all mission scripts. It ensures that the most frequently used menus (CTLD and FAC) maintain consistent positions while organizing all other mission options under a single parent menu.

## Menu Structure

```
F10 - Other Radio Items
  ├─ F1 - Mission Options          <-- All other scripts go here
  │    ├─ INTEL HQ
  │    ├─ Zone Control
  │    ├─ CVN Command
  │    ├─ TADC Utilities
  │    └─ (any other scripts)
  │
  ├─ F2 - CTLD                      <-- Reserved, always in position 2
  │    ├─ Check Cargo
  │    ├─ Troop Transport
  │    ├─ Vehicle / FOB Transport
  │    └─ ...
  │
  └─ F3 - AFAC Control              <-- Reserved, always in position 3
       ├─ Targeting Mode
       ├─ Laser Codes
       ├─ Marker Settings
       └─ ...
```

## Benefits

1. **Consistent Positioning**: CTLD and FAC are always F10-F2 and F10-F3
2. **Reduced Clutter**: All other menus are grouped under "Mission Options"
3. **Easy Navigation**: Players know where to find commonly used functions
4. **Scalable**: Easy to add new scripts without menu reorganization

## Installation

### 1. Load Order in Mission Editor

The scripts must be loaded in this specific order in your DCS mission:

```
1. Moose.lua                                    (MOOSE Framework)
2. Moose_MenuManager.lua                        (Menu Manager - LOAD FIRST!)
3. CTLD.lua                                     (Will be F10-F2)
4. Moose_FAC2MarkRecceZone.lua                 (Will be F10-F3)
5. Moose_Intel.lua                              (Will be under Mission Options)
6. Moose_CaptureZones.lua                       (Will be under Mission Options)
7. Moose_NavalGroup.lua                         (Will be under Mission Options)
8. Moose_TADC_Load2nd.lua                       (Will be under Mission Options)
9. ... any other scripts ...
```

**CRITICAL**: `Moose_MenuManager.lua` must be loaded BEFORE any script that creates F10 menus (except CTLD and FAC which use their own system).

### 2. Script Triggers in DCS

In the DCS Mission Editor, create triggers for "MISSION START":

```
MISSION START
  └─ DO SCRIPT FILE: Moose.lua
  └─ DO SCRIPT FILE: Moose_MenuManager.lua
  └─ DO SCRIPT FILE: CTLD.lua
  └─ DO SCRIPT FILE: Moose_FAC2MarkRecceZone.lua
  └─ DO SCRIPT FILE: Moose_Intel.lua
  └─ DO SCRIPT FILE: Moose_CaptureZones.lua
  └─ DO SCRIPT FILE: Moose_NavalGroup.lua
  └─ DO SCRIPT FILE: Moose_TADC_Load2nd.lua
```

## Configuration

### MenuManager Configuration

Edit `Moose_MenuManager.lua` to customize behavior:

```lua
MenuManager.Config = {
    EnableMissionOptionsMenu = true,      -- Set to false to disable parent menu
    MissionOptionsMenuName = "Mission Options",  -- Change parent menu name
    Debug = false                         -- Enable debug logging
}
```

### Individual Script Configuration

Each script has been updated to support the MenuManager. If you want to disable a specific script's F10 menu, edit that script:

**Example - Disable Intel Menu:**
```lua
-- In Moose_Intel.lua, line 10
local EnableF10Menu = false  -- Changed from true to false
```

## For Script Developers

### Adding New Scripts to the System

If you're creating a new script that needs an F10 menu, use the MenuManager:

#### Coalition Menu Example
```lua
-- Old way (creates root menu)
local MyMenu = MENU_COALITION:New(coalition.side.BLUE, "My Script")

-- New way (creates under Mission Options)
local MyMenu
if MenuManager then
  MyMenu = MenuManager.CreateCoalitionMenu(coalition.side.BLUE, "My Script")
else
  -- Fallback if MenuManager not loaded
  MyMenu = MENU_COALITION:New(coalition.side.BLUE, "My Script")
end

-- Add commands to your menu
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Do Something", MyMenu, MyFunction)
```

#### Mission Menu Example
```lua
-- Old way
local MyMenu = MENU_MISSION:New("My Script")

-- New way
local MyMenu
if MenuManager then
  MyMenu = MenuManager.CreateMissionMenu("My Script")
else
  MyMenu = MENU_MISSION:New("My Script")
end
```

#### Creating Submenus
```lua
-- Create a parent menu under Mission Options
local ParentMenu = MenuManager.CreateCoalitionMenu(coalition.side.BLUE, "Parent")

-- Create a submenu under your parent
local SubMenu = MENU_COALITION:New(coalition.side.BLUE, "Submenu", ParentMenu)
```

## CTLD and FAC Positioning

### Why CTLD and FAC Don't Use MenuManager

CTLD and FAC create **per-group menus** using `missionCommands.addSubMenuForGroup()`, which means each player/group gets their own instance. These are fundamentally different from coalition/mission menus.

The key is **load order**: 
- By loading CTLD first (after MenuManager), it becomes F10-F2
- By loading FAC second, it becomes F10-F3
- Mission Options loads third, becoming F10-F1

This ensures consistent positioning without code modifications to CTLD/FAC.

### If You Need to Modify CTLD or FAC

If you control the CTLD or FAC script source and want to move them under Mission Options, you would need to:

1. Keep them as group menus (they need to be)
2. Accept that group menus can't be nested under coalition menus in DCS
3. Load them in the desired order for consistent F-key positioning

**Recommendation**: Keep CTLD and FAC as-is (F2 and F3) since they're used most frequently.

## Troubleshooting

### Menus Appear in Wrong Order
- **Cause**: Scripts loaded in wrong order
- **Fix**: Check your mission triggers and ensure MenuManager loads first

### "Mission Options" Not Appearing
- **Cause**: `EnableMissionOptionsMenu = false` in config
- **Fix**: Edit `Moose_MenuManager.lua` and set to `true`

### Script Menu Appears at Root Instead of Under Mission Options
- **Cause**: Script doesn't use MenuManager, or MenuManager not loaded
- **Fix**: Update the script to use MenuManager API

### CTLD or FAC Position Changes
- **Cause**: Another script is loading before them
- **Fix**: Adjust load order so CTLD and FAC load immediately after MenuManager

### Debug Mode

Enable debug logging to troubleshoot menu creation:

```lua
-- In Moose_MenuManager.lua
MenuManager.Config = {
    Debug = true  -- Changed from false
}
```

Check `dcs.log` for messages like:
```
MenuManager: Initialized parent menus
MenuManager: Created coalition menu 'INTEL HQ' for BLUE
```

## Advanced Usage

### Disabling the System at Runtime

You can disable/enable the parent menu system during mission execution:

```lua
-- Disable (all new menus will be created at root)
MenuManager.DisableParentMenus()

-- Re-enable
MenuManager.EnableParentMenus()
```

### Creating Direct Root Menus

If you want a specific menu at the root level instead of under Mission Options:

```lua
-- Pass 'nil' as parent to force root creation
local RootMenu = MENU_COALITION:New(coalition.side.BLUE, "Special Root Menu", nil)
```

### Custom Parent Menus

Create your own parent menu and pass it to MenuManager:

```lua
local MyParent = MENU_COALITION:New(coalition.side.BLUE, "Advanced Options")
local SubMenu = MenuManager.CreateCoalitionMenu(coalition.side.BLUE, "Sub Option", MyParent)
```

## Updates and Maintenance

### Version History
- **v1.0** - Initial release with support for Intel, Zones, CVN, and TADC scripts

### Modified Scripts
The following scripts have been updated to use MenuManager:
- `Moose_Intel.lua` - INTEL HQ menu
- `Moose_CaptureZones.lua` - Zone Control menu
- `Moose_NavalGroup.lua` - CVN Command menu
- `Moose_TADC_Load2nd.lua` - TADC Utilities menu

### Backward Compatibility
All scripts retain backward compatibility. If `MenuManager` is not loaded, they will create root-level menus as before.

## Questions and Support

For issues or questions about the Unified F10 Menu System, check:
1. Load order in mission editor
2. Debug logs in `dcs.log`
3. Configuration settings in each script
4. This guide's troubleshooting section

---

**Author**: Created for Operation Polar Shield mission series  
**Last Updated**: November 9, 2025  
**Version**: 1.0
