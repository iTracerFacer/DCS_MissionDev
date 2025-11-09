# F10 Menu System - Update Notes

## Issues Fixed

### Issue 1: Duplicate "Mission Options" Menu
**Problem**: Two "Mission Options" menus appeared, one was empty.

**Cause**: MenuManager was creating three parent menus:
- MENU_COALITION for Blue (correct)
- MENU_COALITION for Red (correct)  
- MENU_MISSION for all players (unnecessary - this created the empty duplicate)

**Fix**: Removed the MENU_MISSION parent menu creation. Scripts that need mission-wide menus (like TADC) now create them directly at root level, which is the correct behavior.

### Issue 2: OnBirthMessage Menu Not Integrated
**Problem**: OnBirthMessage script created its own root-level menu without coordination with MenuManager.

**Cause**: OnBirthMessage uses `missionCommands.addSubMenuForGroup()` which creates per-group menus (like CTLD and FAC). These cannot be nested under coalition menus.

**Fix**: 
- Added configuration option to OnBirthMessage
- Added documentation explaining why it must remain at root level
- Updated load order guidance

---

## Understanding DCS Menu Types

### Three Types of F10 Menus

1. **MENU_COALITION** - Visible to one coalition only
   - Example: Blue Intel, Red Intel
   - Can be nested under other coalition menus
   - MenuManager creates "Mission Options" parent for these

2. **MENU_MISSION** - Visible to ALL players
   - Example: TADC Utilities
   - Cannot be nested under coalition-specific menus
   - Should be created at root level

3. **Group Menus** (missionCommands) - Visible per-group
   - Example: CTLD, FAC, Welcome Messages
   - Each player/group gets their own instance
   - **CANNOT be nested** under coalition or mission menus
   - Must remain at root level

---

## Corrected Menu Structure

```
F10 - Other Radio Items
  ├─ F1 - Mission Options (Blue)    ← MENU_COALITION (Blue players only)
  │    ├─ INTEL HQ
  │    ├─ Zone Control
  │    └─ CVN Command
  │
  ├─ F1 - Mission Options (Red)     ← MENU_COALITION (Red players only)
  │    ├─ INTEL HQ
  │    └─ (Red-specific items)
  │
  ├─ F2 - TADC Utilities             ← MENU_MISSION (all players)
  │
  ├─ F3 - CTLD                       ← Group menu (per-player)
  │
  ├─ F4 - AFAC Control               ← Group menu (per-player)
  │
  └─ F5 - Welcome Messages           ← Group menu (per-player)
```

**Note**: The F-key numbers will vary based on load order. What matters is:
- Coalition-specific menus go under "Mission Options"
- Group menus (CTLD, FAC, Welcome) stay at root
- Mission menus (visible to all) stay at root

---

## Updated Load Order

```
Mission Editor Triggers:
1. Moose.lua
2. Moose_MenuManager.lua       ← Creates "Mission Options" for Blue/Red
3. CTLD.lua                    ← Group menu (any position)
4. Moose_FAC2MarkRecceZone.lua ← Group menu (any position)
5. OnBirthMessage.lua          ← Group menu (any position)
6. Moose_Intel.lua             ← Under Mission Options
7. Moose_CaptureZones.lua      ← Under Mission Options
8. Moose_NavalGroup.lua        ← Under Mission Options
9. Moose_TADC_Load2nd.lua      ← MENU_MISSION (root level)
```

**Key Points**:
- Load MenuManager first (always)
- Group menu scripts (CTLD, FAC, Welcome) can be in any order
- Coalition-specific scripts register under "Mission Options"
- Mission-wide scripts create root-level menus

---

## Scripts by Menu Type

### Coalition Menus (Under "Mission Options")
- ✅ Moose_Intel.lua
- ✅ Moose_CaptureZones.lua
- ✅ Moose_NavalGroup.lua

### Mission Menus (Root Level)
- ✅ Moose_TADC_Load2nd.lua

### Group Menus (Root Level - Cannot Be Nested)
- ⚠️ CTLD.lua
- ⚠️ Moose_FAC2MarkRecceZone.lua
- ⚠️ OnBirthMessage.lua

---

## Configuration Changes

### OnBirthMessage.lua
Added configuration option:
```lua
-- At top of file (line 5)
local EnableF10Menu = true  -- Set to false to disable F10 menu
```

Set to `false` to hide the Welcome Messages F10 menu entirely while keeping the welcome messages active.

---

## Why Group Menus Can't Be Nested

**Technical Limitation**: DCS's `missionCommands.addSubMenuForGroup()` creates menus that are specific to each player's group. These exist in a different namespace than MOOSE's coalition/mission menus and cannot be nested under them.

**Analogy**: Think of it like this:
- Coalition menus are like "team channels" (Blue team sees Blue menus)
- Mission menus are like "global broadcast" (everyone sees same menu)
- Group menus are like "private DM" (each player has their own)

You can't put a private DM inside a team channel - they're different systems.

---

## What This Means for Users

### Blue Players See:
```
F10
 ├─ Mission Options          ← Their Blue-specific utilities
 ├─ TADC Utilities           ← Everyone sees this
 ├─ CTLD                     ← Their own CTLD instance
 ├─ AFAC Control             ← Their own FAC instance
 └─ Welcome Messages         ← Their own settings
```

### Red Players See:
```
F10
 ├─ Mission Options          ← Their Red-specific utilities
 ├─ TADC Utilities           ← Everyone sees this
 ├─ CTLD                     ← Their own CTLD instance
 ├─ AFAC Control             ← Their own FAC instance
 └─ Welcome Messages         ← Their own settings
```

**Key Benefit**: Each coalition's "Mission Options" is clean and organized, containing only their relevant utilities.

---

## Testing Checklist

After applying these fixes:
- [ ] Only ONE "Mission Options" appears (per coalition)
- [ ] "Mission Options" is NOT empty
- [ ] TADC Utilities appears at root (visible to all)
- [ ] CTLD appears at root (per-player)
- [ ] FAC appears at root (per-player)
- [ ] Welcome Messages appears at root (per-player)
- [ ] Blue players see Blue-specific items under Mission Options
- [ ] Red players see Red-specific items under Mission Options
- [ ] No duplicate or empty menus

---

## Files Modified

### c:\DCS_MissionDev\DCS_Kola\Operation_Polar_Shield\Moose_MenuManager.lua
- Removed MENU_MISSION parent menu creation
- Updated CreateMissionMenu() to create root-level menus
- Added documentation about menu types

### c:\DCS_MissionDev\DCS_Kola\Operation_Polar_Shield\OnBirthMessage.lua
- Added EnableF10Menu configuration option
- Added documentation about group menu limitations
- Improved error handling

---

## Summary

**What Changed**:
1. ✅ Removed duplicate "Mission Options" menu
2. ✅ Added config option to OnBirthMessage
3. ✅ Updated documentation about menu types
4. ✅ Clarified load order requirements

**What Stayed The Same**:
- All functionality preserved
- Menu organization still clean
- Coalition-specific items still grouped
- Backward compatible

**Key Takeaway**: 
- Coalition menus → Can be organized under "Mission Options"
- Mission menus → Must stay at root (everyone sees them)
- Group menus → Must stay at root (can't be nested)

This is a DCS limitation, not a bug!

---

*Updated: November 9, 2025*
