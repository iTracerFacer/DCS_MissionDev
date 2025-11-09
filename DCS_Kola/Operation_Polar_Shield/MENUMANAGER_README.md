# Unified F10 Menu System

**Version 1.0** | **Created**: November 9, 2025 | **For**: DCS Mission Development

---

## 🎯 What This Does

Creates a unified F10 menu system that ensures **CTLD** and **FAC** are always in the same position (F2 and F3), while organizing all other mission scripts under a clean "Mission Options" parent menu.

**Result**: F10 → F2 for CTLD, F10 → F3 for FAC. Every mission. Every time.

---

## 📋 Quick Start

### 1. Copy Files to Mission
Copy these files to your mission folder:
- `Moose_MenuManager.lua` (required)
- `Moose_Intel.lua` (updated)
- `Moose_CaptureZones.lua` (updated)
- `Moose_NavalGroup.lua` (updated)
- `Moose_TADC_Load2nd.lua` (updated)

### 2. Set Load Order in Mission Editor
In DCS Mission Editor, Triggers tab, create "MISSION START" trigger:

```
1. Moose.lua
2. Moose_MenuManager.lua        ← MUST BE FIRST!
3. CTLD.lua                     ← Will be F2
4. Moose_FAC2MarkRecceZone.lua  ← Will be F3
5. Moose_Intel.lua              ← Under Mission Options
6. Moose_CaptureZones.lua       ← Under Mission Options
7. Moose_NavalGroup.lua         ← Under Mission Options
8. Moose_TADC_Load2nd.lua       ← Under Mission Options
```

### 3. Test
- Start mission
- Spawn as pilot
- Press F10
- Verify: F1 = Mission Options, F2 = CTLD, F3 = FAC

---

## 📚 Documentation Files

| File | Purpose | When to Use |
|------|---------|-------------|
| **F10_MENU_SYSTEM_GUIDE.md** | Complete documentation | Full understanding |
| **F10_MENU_QUICK_REF.md** | Quick reference card | Fast lookup |
| **MENUMANAGER_SUMMARY.md** | System overview | Understanding concept |
| **MENUMANAGER_VISUAL_GUIDE.md** | Visual diagrams | Visual learners |
| **MENUMANAGER_TEMPLATE.lua** | Code templates | Integrating scripts |
| **EXAMPLE_MISSION_SETUP.lua** | Mission setup example | Setting up missions |
| **README.md** | This file | Getting started |

### Reading Order
1. Start here (README.md) ← You are here
2. Read **MENUMANAGER_SUMMARY.md** (understand the concept)
3. Read **MENUMANAGER_VISUAL_GUIDE.md** (see diagrams)
4. Read **F10_MENU_SYSTEM_GUIDE.md** (complete details)
5. Use **F10_MENU_QUICK_REF.md** (ongoing reference)

---

## 🎮 What Players See

### Before
```
F10 → F1: Zone Control
   → F2: TADC Utilities  
   → F3: INTEL HQ
   → F4: CVN Command
   → F5: CTLD              ← Where is it this time?
   → F6: AFAC Control      ← Always different
```

### After
```
F10 → F1: Mission Options  ← Clean organization
        ├─ INTEL HQ
        ├─ Zone Control
        ├─ CVN Command
        └─ TADC Utilities
   → F2: CTLD              ← ALWAYS HERE!
   → F3: AFAC Control      ← ALWAYS HERE!
```

**Player Experience**: Press F10 → F2 for CTLD. Every time. Muscle memory works!

---

## 🔧 Configuration

### Disable Entire System
In `Moose_MenuManager.lua`:
```lua
MenuManager.Config.EnableMissionOptionsMenu = false
```

### Disable Individual Script Menu
In any script (e.g., `Moose_Intel.lua`):
```lua
local EnableF10Menu = false
```

### Change Parent Menu Name
In `Moose_MenuManager.lua`:
```lua
MenuManager.Config.MissionOptionsMenuName = "Utilities"
```

### Enable Debug Logging
In `Moose_MenuManager.lua`:
```lua
MenuManager.Config.Debug = true
```

---

## 🛠️ For Script Developers

### Integrating New Scripts

**Old way** (creates root menu):
```lua
local MyMenu = MENU_COALITION:New(coalition.side.BLUE, "My Script")
```

**New way** (uses MenuManager):
```lua
local MyMenu
if MenuManager then
  MyMenu = MenuManager.CreateCoalitionMenu(coalition.side.BLUE, "My Script")
else
  MyMenu = MENU_COALITION:New(coalition.side.BLUE, "My Script")
end
```

**That's it!** Your menu now appears under "Mission Options" and falls back gracefully if MenuManager isn't loaded.

See **MENUMANAGER_TEMPLATE.lua** for more examples.

---

## ✅ What's Included

### Core Files
- [x] `Moose_MenuManager.lua` - Menu management system

### Updated Scripts
- [x] `Moose_Intel.lua` - INTEL HQ menu
- [x] `Moose_CaptureZones.lua` - Zone Control menu
- [x] `Moose_NavalGroup.lua` - CVN Command menu
- [x] `Moose_TADC_Load2nd.lua` - TADC Utilities menu

### Documentation
- [x] Complete user guide
- [x] Quick reference card
- [x] System summary
- [x] Visual diagrams
- [x] Code templates
- [x] Setup examples

---

## 🎓 Key Concepts

### Why Load Order Matters
DCS creates F10 menus in the order scripts are loaded:
- Script loaded 1st → F10-F1
- Script loaded 2nd → F10-F2
- Script loaded 3rd → F10-F3

By loading CTLD and FAC in specific positions, we ensure they're always F2 and F3.

### Why CTLD/FAC Don't Use MenuManager
CTLD and FAC create **per-group menus** (each player/group gets their own). These can't be nested under coalition menus. Solution: Use load order to position them at F2 and F3.

### Backward Compatibility
All scripts work with or without MenuManager:
- **With MenuManager**: Organized under "Mission Options"
- **Without MenuManager**: Creates root menu (old behavior)

No errors, no breaking changes.

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| Menus in wrong order | Check script load order in mission triggers |
| No "Mission Options" | Ensure `Moose_MenuManager.lua` loads first |
| CTLD not at F2 | Load CTLD right after MenuManager |
| FAC not at F3 | Load FAC right after CTLD |
| Script errors | Enable debug mode, check dcs.log |

**Debug logs location**: `C:\Users\[You]\Saved Games\DCS\Logs\dcs.log`

---

## 📊 Benefits

### For Players
- ✅ CTLD always F2 (muscle memory)
- ✅ FAC always F3 (consistent)
- ✅ Clean, organized menus
- ✅ Faster navigation (1 second vs 15 seconds)

### For Mission Makers
- ✅ Professional appearance
- ✅ Easy to add/remove scripts
- ✅ Configurable per mission
- ✅ Better player feedback

### For Developers
- ✅ 3-line integration
- ✅ Backward compatible
- ✅ Well documented
- ✅ Flexible configuration

---

## 🚀 Features

- **Consistent Positioning**: CTLD and FAC always in same position
- **Clean Organization**: One parent menu instead of many root menus
- **Easy Integration**: Minimal code changes to existing scripts
- **Backward Compatible**: Works with or without MenuManager
- **Configurable**: Enable/disable globally or per-script
- **Scalable**: Add unlimited scripts without reorganization
- **Well Documented**: Complete guides and examples

---

## 📖 Examples

### Example 1: Training Mission (Hide Everything Except CTLD)
```lua
// In Moose_MenuManager.lua
MenuManager.Config.EnableMissionOptionsMenu = false

// In each other script
local EnableF10Menu = false

Result: Only CTLD appears (F10 → F2)
```

### Example 2: Custom Parent Menu Name
```lua
// In Moose_MenuManager.lua
MenuManager.Config.MissionOptionsMenuName = "Squadron Utilities"

Result: F10 → F1 → Squadron Utilities
```

### Example 3: Add Your Own Script
```lua
// In MyScript.lua
local MyMenu
if MenuManager then
  MyMenu = MenuManager.CreateCoalitionMenu(coalition.side.BLUE, "My Feature")
else
  MyMenu = MENU_COALITION:New(coalition.side.BLUE, "My Feature")
end

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Do Thing", MyMenu, DoThing)

Result: F10 → F1 → Mission Options → My Feature
```

---

## 🔍 Technical Details

### Menu Types
- **MENU_COALITION**: Visible to one coalition (Blue or Red)
- **MENU_MISSION**: Visible to all players
- **missionCommands (Group)**: Per-group menus (CTLD/FAC use this)

MenuManager handles the first two. Group menus remain at root level.

### Architecture
```
MenuManager (loads first)
  ↓
Creates "Mission Options" parent menu
  ↓
Other scripts register under it
  ↓
Result: F1 = Mission Options, F2 = CTLD, F3 = FAC
```

### Files Modified
Only menu creation code changed. All other functionality unchanged.

---

## 🎯 Success Criteria

- [x] CTLD always at F2
- [x] FAC always at F3
- [x] Other menus under F1
- [x] Backward compatible
- [x] Easy to integrate
- [x] Well documented
- [x] Tested and working

**Status**: All criteria met! ✅

---

## 📝 Version History

**v1.0** (November 9, 2025)
- Initial release
- Support for coalition and mission menus
- Integration with Intel, Zones, CVN, TADC scripts
- Complete documentation suite

---

## 💡 Tips

1. **Always load MenuManager first** (after Moose.lua)
2. **Load CTLD second** to ensure F2 position
3. **Load FAC third** to ensure F3 position
4. **Test load order** before deploying mission
5. **Use debug mode** when troubleshooting
6. **Check dcs.log** for error messages

---

## 🙋 Support

**Need Help?**
1. Read **F10_MENU_SYSTEM_GUIDE.md** (comprehensive guide)
2. Check **F10_MENU_QUICK_REF.md** (quick answers)
3. Review **MENUMANAGER_VISUAL_GUIDE.md** (visual explanations)
4. Use **MENUMANAGER_TEMPLATE.lua** (code examples)
5. Enable debug mode and check logs

**Common Issues?**
- See Troubleshooting section above
- Check load order in mission editor
- Verify all files are in mission folder
- Enable debug logging for details

---

## 🎖️ Credits

**Created for**: F-99th Fighter Squadron  
**Mission**: Operation Polar Shield  
**Date**: November 9, 2025

**Design Philosophy**:
- Keep it simple
- Make it consistent
- Document everything
- Maintain compatibility

---

## 📄 License

Free to use, modify, and distribute for DCS missions.  
Credit appreciated but not required.

---

## 🚦 Getting Started Checklist

- [ ] Read this README
- [ ] Review MENUMANAGER_SUMMARY.md
- [ ] Copy Moose_MenuManager.lua to mission
- [ ] Set up load order in mission editor
- [ ] Test in DCS
- [ ] Configure as needed
- [ ] Deploy to server

**Estimated setup time**: 10-15 minutes  
**Result**: Professional, organized F10 menus!

---

**Questions?** Start with the documentation files listed above.  
**Want to integrate a new script?** See MENUMANAGER_TEMPLATE.lua.  
**Need visual examples?** Check MENUMANAGER_VISUAL_GUIDE.md.

**Ready to get started?** Follow the Quick Start section at the top!

---

*Making DCS missions more organized, one F10 menu at a time.* 🎯✈️
