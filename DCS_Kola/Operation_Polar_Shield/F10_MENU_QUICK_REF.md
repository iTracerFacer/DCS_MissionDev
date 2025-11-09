# F10 Menu System - Quick Reference

## Menu Structure
```
F10 → Mission Options (Blue players)
      ├─ INTEL HQ
      ├─ Zone Control  
      └─ CVN Command

F10 → Mission Options (Red players)
      ├─ INTEL HQ
      └─ (Red items)

F10 → TADC Utilities (all players)

F10 → CTLD (per-player, like CTLD always was)

F10 → AFAC Control (per-player, like FAC always was)

F10 → Welcome Messages (per-player)
```

**Note**: Group menus (CTLD, FAC, Welcome) cannot be nested under coalition menus due to DCS limitations.

## Load Order (CRITICAL!)
```
1. Moose.lua
2. Moose_MenuManager.lua        ← Must be FIRST
3. CTLD.lua                     ← Group menu (any order)
4. Moose_FAC2MarkRecceZone.lua  ← Group menu (any order)
5. OnBirthMessage.lua           ← Group menu (any order)
6. Moose_Intel.lua              ← Under Mission Options
7. Moose_CaptureZones.lua       ← Under Mission Options
8. Moose_NavalGroup.lua         ← Under Mission Options
9. Moose_TADC_Load2nd.lua       ← Mission menu (root level)
```

## Script Integration Pattern

### For Coalition Menus:
```lua
local MyMenu
if MenuManager then
  MyMenu = MenuManager.CreateCoalitionMenu(coalition.side.BLUE, "My Menu")
else
  MyMenu = MENU_COALITION:New(coalition.side.BLUE, "My Menu")
end
```

### For Mission Menus:
```lua
local MyMenu
if MenuManager then
  MyMenu = MenuManager.CreateMissionMenu("My Menu")
else
  MyMenu = MENU_MISSION:New("My Menu")
end
```

## Configuration (in Moose_MenuManager.lua)
```lua
EnableMissionOptionsMenu = true    -- false to disable
MissionOptionsMenuName = "Mission Options"  -- change name
Debug = false                      -- true for logging
```

## Disable Individual Script Menus
```lua
-- In each script (e.g., Moose_Intel.lua)
local EnableF10Menu = false
```

## Common Issues
| Problem | Solution |
|---------|----------|
| Duplicate "Mission Options" | Fixed in v1.1 - only coalition menus now |
| Empty menu | Check that scripts are loaded |
| Group menus not under Mission Options | That's correct - DCS limitation |
| TADC at root level | Correct - it's a mission menu (all players) |

## Files Modified
- ✅ Moose_Intel.lua
- ✅ Moose_CaptureZones.lua  
- ✅ Moose_NavalGroup.lua
- ✅ Moose_TADC_Load2nd.lua
- ✅ OnBirthMessage.lua (v1.1)

## New Files
- ✅ Moose_MenuManager.lua (Core system v1.1)
- ✅ F10_MENU_SYSTEM_GUIDE.md (Full documentation)
- ✅ MENUMANAGER_UPDATE_NOTES.md (v1.1 changes)
