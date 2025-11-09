# Mission Setup Checklist - F10 Menu System

## Pre-Setup
- [ ] Back up your current mission file (.miz)
- [ ] Have all script files ready
- [ ] Have DCS Mission Editor open

---

## Step 1: File Preparation (5 minutes)

### Required Files
- [ ] `Moose.lua` (MOOSE Framework)
- [ ] `Moose_MenuManager.lua` (NEW - Menu System)
- [ ] `CTLD.lua`
- [ ] `Moose_FAC2MarkRecceZone.lua`

### Optional Files (Your Scripts)
- [ ] `Moose_Intel.lua`
- [ ] `Moose_CaptureZones.lua`
- [ ] `Moose_NavalGroup.lua`
- [ ] `Moose_TADC_Load2nd.lua`
- [ ] Other custom scripts...

### Copy Files
- [ ] Extract mission .miz file to folder (or use editor)
- [ ] Place all .lua files in mission folder
- [ ] Note: Mission Editor can also load scripts directly

---

## Step 2: Mission Editor Setup (5 minutes)

### Open Mission
- [ ] Open mission in DCS Mission Editor
- [ ] Go to Triggers tab

### Create Load Trigger
- [ ] Create new trigger: "Load Mission Scripts"
- [ ] Set Type: **ONCE**
- [ ] Set Event: **MISSION START**

### Add Condition
- [ ] Add condition: **TIME MORE**
- [ ] Set time: **1 second**
- [ ] (Ensures mission is initialized)

### Add Script Actions (IN THIS ORDER!)
- [ ] Action 1: DO SCRIPT FILE → `Moose.lua`
- [ ] Action 2: DO SCRIPT FILE → `Moose_MenuManager.lua` ⚠️ CRITICAL ORDER!
- [ ] Action 3: DO SCRIPT FILE → `CTLD.lua`
- [ ] Action 4: DO SCRIPT FILE → `Moose_FAC2MarkRecceZone.lua`
- [ ] Action 5: DO SCRIPT FILE → `Moose_Intel.lua`
- [ ] Action 6: DO SCRIPT FILE → `Moose_CaptureZones.lua`
- [ ] Action 7: DO SCRIPT FILE → `Moose_NavalGroup.lua`
- [ ] Action 8: DO SCRIPT FILE → `Moose_TADC_Load2nd.lua`
- [ ] Action 9+: (Any other scripts...)

### Save Mission
- [ ] Save mission
- [ ] Note the file path for testing

---

## Step 3: Testing (5 minutes)

### Basic Test
- [ ] Start mission in DCS
- [ ] Spawn as any pilot (Blue coalition recommended)
- [ ] Press **F10**

### Verify Menu Structure
- [ ] F1: "Mission Options" exists
- [ ] F1 → Contains: INTEL HQ, Zone Control, CVN Command, TADC Utilities
- [ ] F2: "CTLD" exists
- [ ] F2 → Contains: Check Cargo, Troop Transport, etc.
- [ ] F3: "AFAC Control" exists
- [ ] F3 → Contains: Targeting Mode, Laser Codes, etc.

### If Wrong Order
- [ ] Exit mission
- [ ] Check trigger action order in editor
- [ ] Verify MenuManager is action #2
- [ ] Verify CTLD is action #3
- [ ] Verify FAC is action #4
- [ ] Save and retest

---

## Step 4: Configuration (Optional)

### Global Settings
Open `Moose_MenuManager.lua`:
- [ ] Review `EnableMissionOptionsMenu` (true/false)
- [ ] Review `MissionOptionsMenuName` (change if desired)
- [ ] Review `Debug` (enable for troubleshooting)

### Individual Script Settings
For each script (Intel, Zones, CVN, TADC):
- [ ] Check `EnableF10Menu` variable (top of file)
- [ ] Set to `false` to hide that script's menu
- [ ] Useful for training missions or specific scenarios

---

## Step 5: Advanced Testing (Optional)

### Test Both Coalitions
- [ ] Spawn as Blue pilot → Verify Blue menus
- [ ] Spawn as Red pilot → Verify Red menus
- [ ] Each coalition should see their own "Mission Options"

### Test Multiple Players
- [ ] Host multiplayer server (or local)
- [ ] Have multiple clients join
- [ ] Each client sees consistent menus
- [ ] CTLD/FAC menus are per-group (expected)

### Test Debug Mode
- [ ] Enable debug in `Moose_MenuManager.lua`
- [ ] Start mission
- [ ] Check `dcs.log` file
- [ ] Location: `C:\Users\[You]\Saved Games\DCS\Logs\dcs.log`
- [ ] Look for "MenuManager:" messages
- [ ] Verify menus created successfully

---

## Step 6: Troubleshooting

### Problem: No "Mission Options" Menu
Cause: MenuManager not loaded or disabled
- [ ] Verify `Moose_MenuManager.lua` is in mission folder
- [ ] Verify it's action #2 in trigger (after Moose.lua)
- [ ] Check `EnableMissionOptionsMenu = true` in config
- [ ] Enable debug mode and check logs

### Problem: CTLD Not at F2
Cause: Load order incorrect
- [ ] Verify CTLD.lua is action #3 (after MenuManager)
- [ ] Check no other script loads between MenuManager and CTLD
- [ ] Reorder trigger actions
- [ ] Save and retest

### Problem: FAC Not at F3
Cause: Load order incorrect
- [ ] Verify FAC.lua is action #4 (after CTLD)
- [ ] Check no other script loads between CTLD and FAC
- [ ] Reorder trigger actions
- [ ] Save and retest

### Problem: Script Errors on Load
Cause: Syntax error or missing dependency
- [ ] Check `dcs.log` for error messages
- [ ] Verify all files are present
- [ ] Verify Moose.lua loads first
- [ ] Enable debug mode for detailed logging
- [ ] Check file paths in trigger actions

### Problem: Menus Appear at Root Level
Cause: Script doesn't use MenuManager
- [ ] Verify script has MenuManager integration code
- [ ] Check pattern: `if MenuManager then ... else ... end`
- [ ] Review MENUMANAGER_TEMPLATE.lua for correct pattern
- [ ] Update script accordingly

---

## Step 7: Documentation

### For Mission Makers
- [ ] Read `F10_MENU_SYSTEM_GUIDE.md` (comprehensive)
- [ ] Bookmark `F10_MENU_QUICK_REF.md` (quick reference)
- [ ] Save `EXAMPLE_MISSION_SETUP.lua` for future missions

### For Players
- [ ] Create mission briefing mentioning menu structure
- [ ] Example: "CTLD is at F10→F2, FAC is at F10→F3"
- [ ] Note any disabled menus (if applicable)

### For Server Admins
- [ ] Document any configuration changes
- [ ] Note which scripts/menus are active
- [ ] Keep backup of working configuration

---

## Step 8: Deployment

### Pre-Deployment
- [ ] Final test of all menus
- [ ] Verify no script errors
- [ ] Test with multiple players (if multiplayer)
- [ ] Backup final working version

### Deployment
- [ ] Upload mission to server (if multiplayer)
- [ ] Update mission briefing/description
- [ ] Notify players of menu structure
- [ ] Monitor first mission for issues

### Post-Deployment
- [ ] Collect player feedback
- [ ] Monitor for errors
- [ ] Adjust configuration if needed
- [ ] Document any issues for future missions

---

## Quick Reference Card (Print This!)

```
┌─────────────────────────────────────────┐
│   F10 MENU SYSTEM - LOAD ORDER          │
├─────────────────────────────────────────┤
│  1. Moose.lua                           │
│  2. Moose_MenuManager.lua  ← FIRST!     │
│  3. CTLD.lua               ← F2         │
│  4. Moose_FAC2MarkRecceZone.lua ← F3    │
│  5. Other scripts...       ← Under F1   │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│   RESULT IN GAME                        │
├─────────────────────────────────────────┤
│  F10 → F1: Mission Options              │
│        F2: CTLD                         │
│        F3: AFAC Control                 │
└─────────────────────────────────────────┘
```

---

## Common Mistakes

### ❌ Mistake 1: Loading Scripts Before MenuManager
```
❌ Wrong:
1. Moose.lua
2. Moose_Intel.lua
3. Moose_MenuManager.lua  ← Too late!

✅ Correct:
1. Moose.lua
2. Moose_MenuManager.lua  ← First!
3. Moose_Intel.lua
```

### ❌ Mistake 2: Loading Other Scripts Between MenuManager and CTLD
```
❌ Wrong:
1. Moose.lua
2. Moose_MenuManager.lua
3. Moose_Intel.lua        ← Pushes CTLD down!
4. CTLD.lua               ← Not F2 anymore!

✅ Correct:
1. Moose.lua
2. Moose_MenuManager.lua
3. CTLD.lua               ← F2!
4. Moose_Intel.lua
```

### ❌ Mistake 3: Not Using MenuManager in Script
```lua
❌ Wrong (creates root menu):
local MyMenu = MENU_COALITION:New(coalition.side.BLUE, "My Script")

✅ Correct (uses MenuManager):
local MyMenu
if MenuManager then
  MyMenu = MenuManager.CreateCoalitionMenu(coalition.side.BLUE, "My Script")
else
  MyMenu = MENU_COALITION:New(coalition.side.BLUE, "My Script")
end
```

---

## Success Checklist

After setup, you should have:
- [ ] ✅ Mission loads without errors
- [ ] ✅ F1 shows "Mission Options" with submenus
- [ ] ✅ F2 shows "CTLD" (always)
- [ ] ✅ F3 shows "AFAC Control" (always)
- [ ] ✅ All menu commands work
- [ ] ✅ Both coalitions see correct menus
- [ ] ✅ Players can find CTLD/FAC quickly
- [ ] ✅ No duplicate or orphaned menus
- [ ] ✅ dcs.log shows no errors
- [ ] ✅ Professional, organized appearance

**All checked?** You're ready to go! 🎉

---

## Time Estimates

| Task | Time | Difficulty |
|------|------|-----------|
| Copy files | 2 min | Easy |
| Set up triggers | 5 min | Easy |
| Basic testing | 5 min | Easy |
| Configuration | 5 min | Medium |
| Troubleshooting | 0-15 min | Varies |
| **Total** | **15-30 min** | **Easy** |

---

## Help & Resources

**Getting Started:**
- This checklist (you are here)
- `MENUMANAGER_README.md`

**Understanding:**
- `MENUMANAGER_SUMMARY.md`
- `MENUMANAGER_VISUAL_GUIDE.md`

**Reference:**
- `F10_MENU_QUICK_REF.md`
- `F10_MENU_SYSTEM_GUIDE.md`

**Development:**
- `MENUMANAGER_TEMPLATE.lua`
- `EXAMPLE_MISSION_SETUP.lua`

---

## Final Notes

✅ **Backup** your mission before making changes  
✅ **Test** thoroughly before deploying  
✅ **Document** your configuration  
✅ **Monitor** first live mission  
✅ **Iterate** based on feedback  

**Remember**: The key is load order!
1. MenuManager first
2. CTLD second (F2)
3. FAC third (F3)
4. Everything else

**Good luck and happy mission making!** 🚁✈️

---

*Last updated: November 9, 2025*
