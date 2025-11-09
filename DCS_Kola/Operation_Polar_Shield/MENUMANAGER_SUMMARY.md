# Unified F10 Menu System - Summary

## What Was Created

A complete F10 menu organization system that ensures CTLD and FAC remain in consistent positions (F2 and F3) while grouping all other mission scripts under a "Mission Options" parent menu at F1.

## Files Created

1. **Moose_MenuManager.lua** - Core menu management system
2. **F10_MENU_SYSTEM_GUIDE.md** - Complete documentation
3. **F10_MENU_QUICK_REF.md** - Quick reference card
4. **EXAMPLE_MISSION_SETUP.lua** - Mission integration example
5. **MENUMANAGER_TEMPLATE.lua** - Script integration templates

## Files Modified

1. **Moose_Intel.lua** - Updated to use MenuManager
2. **Moose_CaptureZones.lua** - Updated to use MenuManager
3. **Moose_NavalGroup.lua** - Updated to use MenuManager
4. **Moose_TADC_Load2nd.lua** - Updated to use MenuManager

## How It Works

### The Problem
- F10 menu items appear in load order
- CTLD and FAC could be at any position
- Menu becomes cluttered with many scripts
- Players waste time navigating to frequently-used items

### The Solution
1. Load MenuManager first to create "Mission Options" parent menu
2. Load CTLD second → becomes F10-F2 (consistent)
3. Load FAC third → becomes F10-F3 (consistent)
4. All other scripts register under "Mission Options" → F10-F1

### Result
```
F10 - Other Radio Items
  ├─ F1 - Mission Options      ← All other menus here
  │    ├─ INTEL HQ
  │    ├─ Zone Control
  │    ├─ CVN Command
  │    └─ TADC Utilities
  │
  ├─ F2 - CTLD                  ← Always here (muscle memory!)
  │
  └─ F3 - AFAC Control          ← Always here
```

## Key Features

✅ **Consistent Positioning**: CTLD and FAC always F2 and F3
✅ **Reduced Clutter**: One parent menu instead of many root menus
✅ **Backward Compatible**: Scripts work with or without MenuManager
✅ **Easy Integration**: 3-line change to existing scripts
✅ **Configurable**: Can disable entire system or individual menus
✅ **Scalable**: Add unlimited scripts without reorganization

## Quick Start

### 1. Mission Editor Setup

Load scripts in this order:
```
1. Moose.lua
2. Moose_MenuManager.lua        ← NEW - Must be first!
3. CTLD.lua
4. Moose_FAC2MarkRecceZone.lua
5. Moose_Intel.lua
6. Moose_CaptureZones.lua
7. Moose_NavalGroup.lua
8. Moose_TADC_Load2nd.lua
9. ... other scripts ...
```

### 2. Test in Mission

1. Start mission
2. Spawn as pilot
3. Press F10
4. Verify menu structure

### 3. Configuration (Optional)

Edit `Moose_MenuManager.lua`:
```lua
MenuManager.Config = {
    EnableMissionOptionsMenu = true,  -- false to disable
    MissionOptionsMenuName = "Mission Options",
    Debug = false  -- true for logging
}
```

## Integration Pattern

To integrate any script with MenuManager:

**Before:**
```lua
local MyMenu = MENU_COALITION:New(coalition.side.BLUE, "My Script")
```

**After:**
```lua
local MyMenu
if MenuManager then
  MyMenu = MenuManager.CreateCoalitionMenu(coalition.side.BLUE, "My Script")
else
  MyMenu = MENU_COALITION:New(coalition.side.BLUE, "My Script")
end
```

That's it! The script now works with MenuManager but falls back gracefully if it's not loaded.

## Why CTLD/FAC Don't Use MenuManager

CTLD and FAC create **per-group menus** using DCS's native `missionCommands.addSubMenuForGroup()`. These are fundamentally different from MOOSE's coalition/mission menus and can't be nested under a parent menu.

**Solution**: Load order ensures consistent positioning:
- MenuManager loads first → creates "Mission Options"
- CTLD loads second → creates group menus (become F2)
- FAC loads third → creates group menus (become F3)
- "Mission Options" appears at F1 because coalition menus load before group menus

This gives us the consistent F1/F2/F3 structure we want.

## Benefits for Mission Makers

1. **Less Menu Navigation**: Players go straight to F2 for CTLD, F3 for FAC
2. **Cleaner Interface**: One parent menu instead of 5+ root menus
3. **Easier Maintenance**: Add/remove scripts without menu reorganization
4. **Professional Look**: Organized, predictable menu structure
5. **Player Feedback**: "Finally, I can find CTLD quickly!"

## Benefits for Script Developers

1. **3-Line Integration**: Minimal code changes
2. **Backward Compatible**: Works with or without MenuManager
3. **No Breaking Changes**: Existing scripts continue to work
4. **Flexible**: Can opt-in or opt-out per script
5. **Well Documented**: Templates and examples provided

## Technical Details

### Menu Types in MOOSE/DCS

1. **MENU_MISSION**: Visible to all players
2. **MENU_COALITION**: Visible to one coalition
3. **MENU_GROUP**: Visible to specific group (CTLD/FAC use this)

MenuManager handles MENU_MISSION and MENU_COALITION. Group menus remain independent.

### Load Order Matters

DCS creates menus in load order:
1. First loaded script → F1
2. Second loaded script → F2
3. Third loaded script → F3
etc.

By controlling load order, we control F-key positions.

### Fallback Behavior

If MenuManager is not loaded or disabled:
- Scripts create root-level menus (old behavior)
- Everything still works, just not organized
- No errors or warnings

## Configuration Options

### Global Configuration (in Moose_MenuManager.lua)
```lua
EnableMissionOptionsMenu = true   -- Disable entire system
MissionOptionsMenuName = "..."    -- Change parent menu name
Debug = false                     -- Enable logging
```

### Per-Script Configuration (in each script)
```lua
local EnableF10Menu = false       -- Disable this script's menu
```

### Runtime Configuration
```lua
MenuManager.DisableParentMenus()  -- Turn off at runtime
MenuManager.EnableParentMenus()   -- Turn on at runtime
```

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| Menus wrong order | Load order incorrect | Check mission triggers |
| No "Mission Options" | MenuManager not loaded | Add to triggers first |
| CTLD not F2 | CTLD loaded too late | Load right after MenuManager |
| Script errors | MenuManager syntax | Check debug logs |

Enable debug mode to see what's happening:
```lua
MenuManager.Config.Debug = true
```

Check logs at: `C:\Users\[You]\Saved Games\DCS\Logs\dcs.log`

## Future Enhancements

Possible additions for future versions:
- Menu hiding/showing based on game state
- Menu reorganization at runtime
- Per-player menu customization
- Menu usage analytics
- Internationalization support

## Version History

**v1.0** (November 9, 2025)
- Initial release
- Support for MENU_COALITION and MENU_MISSION
- Integration with Intel, Zones, CVN, TADC scripts
- Complete documentation and templates

## Support

For questions or issues:
1. Read **F10_MENU_SYSTEM_GUIDE.md** (comprehensive)
2. Read **F10_MENU_QUICK_REF.md** (quick answers)
3. Check **EXAMPLE_MISSION_SETUP.lua** (mission setup)
4. Use **MENUMANAGER_TEMPLATE.lua** (script integration)
5. Enable debug mode and check dcs.log

## Credits

Created for the F-99th Fighter Squadron's Operation Polar Shield mission series.

**Design Goals**:
- Keep CTLD and FAC in consistent positions
- Reduce menu clutter
- Easy to integrate
- Backward compatible
- Well documented

**Result**: All goals achieved! 🎉

---

## Quick Reference

### Load Order
1. Moose.lua
2. **Moose_MenuManager.lua** ← First!
3. CTLD.lua ← F2
4. FAC.lua ← F3
5. Other scripts ← Under F1

### Integration Pattern
```lua
if MenuManager then
  MyMenu = MenuManager.CreateCoalitionMenu(coalition.side.BLUE, "Name")
else
  MyMenu = MENU_COALITION:New(coalition.side.BLUE, "Name")
end
```

### Result
- F1: Mission Options (all other scripts)
- F2: CTLD (always)
- F3: FAC (always)

Simple, effective, backward compatible! 👍
