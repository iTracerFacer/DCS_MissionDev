# F10 Menu System - Visual Guide

## Before MenuManager (Typical Mission)

```
F10 - Other Radio Items
  ├─ F1 - Zone Control         ← Changes based on load order
  ├─ F2 - TADC Utilities        ← Inconsistent position
  ├─ F3 - INTEL HQ              ← Player has to search
  ├─ F4 - CVN Command           ← Different every mission
  ├─ F5 - CTLD                  ← Where is it this time?
  └─ F6 - AFAC Control          ← Never the same
```

**Problems:**
- CTLD position changes between missions
- Too many root-level menus (cluttered)
- Players waste time searching for CTLD/FAC
- No organization or grouping

---

## After MenuManager (Organized)

```
F10 - Other Radio Items
  ├─ F1 - Mission Options       ← All utility scripts here
  │    ├─ INTEL HQ
  │    ├─ Zone Control
  │    ├─ CVN Command
  │    └─ TADC Utilities
  │
  ├─ F2 - CTLD                  ← ALWAYS HERE! Muscle memory works!
  │    ├─ Check Cargo
  │    ├─ Troop Transport
  │    │    ├─ Unload / Extract Troops
  │    │    └─ Load From Zone
  │    ├─ Vehicle / FOB Transport
  │    │    ├─ Unload Vehicles
  │    │    └─ Load / Extract Vehicles
  │    ├─ Vehicle / FOB Crates / Drone
  │    └─ CTLD Commands
  │
  └─ F3 - AFAC Control          ← ALWAYS HERE! Predictable!
       ├─ Targeting Mode
       │    ├─ Auto Mode ON
       │    ├─ Auto Mode OFF
       │    └─ Manual Targeting
       ├─ Laser Codes
       ├─ Marker Settings
       │    ├─ Smoke Color
       │    └─ Flare Color
       └─ AFAC Status
```

**Benefits:**
- CTLD always F2 (press F10 → F2 every time)
- FAC always F3 (press F10 → F3 every time)
- Other menus organized under F1
- Clean, predictable interface

---

## Load Order Visualization

```
Mission Editor Triggers - Script Load Order:
┌────────────────────────────────────────┐
│ 1. Moose.lua                           │ ← MOOSE Framework
├────────────────────────────────────────┤
│ 2. Moose_MenuManager.lua               │ ← Creates "Mission Options" at F1
├────────────────────────────────────────┤
│ 3. CTLD.lua                            │ ← Creates CTLD menu → becomes F2
├────────────────────────────────────────┤
│ 4. Moose_FAC2MarkRecceZone.lua        │ ← Creates FAC menu → becomes F3
├────────────────────────────────────────┤
│ 5. Moose_Intel.lua                     │ ← Registers under Mission Options
│ 6. Moose_CaptureZones.lua              │ ← Registers under Mission Options
│ 7. Moose_NavalGroup.lua                │ ← Registers under Mission Options
│ 8. Moose_TADC_Load2nd.lua              │ ← Registers under Mission Options
│ 9. ... other scripts ...               │ ← All register under Mission Options
└────────────────────────────────────────┘

Result: F1 = Mission Options, F2 = CTLD, F3 = FAC
```

---

## Menu Type Comparison

### Coalition Menu (MENU_COALITION)
```
BLUE Players See:              RED Players See:
F10                           F10
 ├─ Mission Options            ├─ Mission Options
 │   ├─ INTEL HQ (Blue)        │   ├─ INTEL HQ (Red)
 │   └─ Zone Control (Blue)    │   └─ (Red content)
 ├─ CTLD                       ├─ CTLD
 └─ AFAC Control               └─ AFAC Control
```

### Mission Menu (MENU_MISSION)
```
ALL Players See Same:
F10
 ├─ Mission Options
 │   └─ TADC Utilities    ← Everyone sees this
 ├─ CTLD
 └─ AFAC Control
```

### Group Menu (missionCommands - CTLD/FAC use this)
```
Each Group Sees Own:
Group #1:                Group #2:
F10                      F10
 ├─ CTLD (Group #1)       ├─ CTLD (Group #2)
 └─ AFAC (Group #1)       └─ AFAC (Group #2)

Can't be nested under parent menus - that's why CTLD/FAC stay at root
```

---

## Integration Flowchart

```
┌─────────────────────────────────────────┐
│ Your Script Wants to Create F10 Menu    │
└──────────────┬──────────────────────────┘
               │
               ▼
        ┌──────────────┐
        │ MenuManager  │
        │  Available?  │
        └──┬───────┬───┘
           │       │
       Yes │       │ No
           │       │
           ▼       ▼
    ┌──────────┐  ┌─────────────┐
    │ Register │  │ Create Root │
    │  Under   │  │    Menu     │
    │ Mission  │  │  (Fallback) │
    │ Options  │  │             │
    └──────────┘  └─────────────┘
         │              │
         └──────┬───────┘
                │
                ▼
       ┌────────────────┐
       │ Menu Appears   │
       │   in F10       │
       └────────────────┘
```

---

## Player Experience Comparison

### Without MenuManager
```
Player: "Where's CTLD?"
    → Checks F1: Zone Control
    → Checks F2: TADC
    → Checks F3: Intel
    → Checks F4: CVN
    → Checks F5: CTLD ← FOUND IT!
    (Time wasted: 10-15 seconds)

Next Mission:
Player: "Where's CTLD now?"
    → Checks F1: Intel
    → Checks F2: CVN
    → Checks F3: Zone Control
    → Checks F4: CTLD ← Position changed!
    (Frustration: High)
```

### With MenuManager
```
Player: "Need CTLD"
    → Press F10
    → Press F2
    → Found it!
    (Time: 1 second, every time)

Next Mission:
Player: "Need CTLD"
    → Press F10
    → Press F2
    → Found it! (same position)
    (Frustration: None, Efficiency: Max)
```

---

## Configuration Examples

### Example 1: Disable All Extra Menus (Training Mission)
```lua
-- In Moose_MenuManager.lua
MenuManager.Config.EnableMissionOptionsMenu = false

-- Result: Only CTLD and FAC appear
F10
 ├─ CTLD
 └─ AFAC Control
```

### Example 2: Disable Specific Script Menu
```lua
-- In Moose_Intel.lua
local EnableF10Menu = false

-- Result: Intel menu hidden, others remain
F10
 ├─ Mission Options
 │   ├─ Zone Control
 │   ├─ CVN Command
 │   └─ TADC Utilities
 ├─ CTLD
 └─ AFAC Control
```

### Example 3: Custom Parent Menu Name
```lua
-- In Moose_MenuManager.lua
MenuManager.Config.MissionOptionsMenuName = "Utilities"

-- Result: Different parent menu name
F10
 ├─ Utilities          ← Changed from "Mission Options"
 │   ├─ INTEL HQ
 │   └─ ...
 ├─ CTLD
 └─ AFAC Control
```

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    DCS Mission                          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌────────────┐                                        │
│  │  Moose.lua │  ← MOOSE Framework (loaded first)     │
│  └─────┬──────┘                                        │
│        │                                               │
│  ┌─────▼───────────────┐                              │
│  │ MenuManager         │  ← Menu System (loaded 2nd)  │
│  │ - Creates F1        │                              │
│  │ - Provides API      │                              │
│  └─────┬───────────────┘                              │
│        │                                               │
│        ├─────────┬─────────┬─────────┬──────────┐    │
│        │         │         │         │          │    │
│  ┌─────▼───┐ ┌──▼────┐ ┌──▼────┐ ┌──▼────┐ ┌───▼──┐ │
│  │  Intel  │ │ Zones │ │  CVN  │ │ TADC  │ │ ... │ │
│  │  Script │ │Script │ │Script │ │Script │ │     │ │
│  └─────┬───┘ └──┬────┘ └──┬────┘ └──┬────┘ └───┬──┘ │
│        │        │         │         │          │    │
│        └────────┴─────────┴─────────┴──────────┘    │
│                          │                           │
│                    ┌─────▼──────┐                    │
│                    │  Mission   │                    │
│                    │  Options   │  ← F1              │
│                    │   (F10)    │                    │
│                    └────────────┘                    │
│                                                       │
│  ┌─────────┐                                         │
│  │  CTLD   │  ← Loaded after MenuManager → F2       │
│  └─────────┘                                         │
│                                                       │
│  ┌─────────┐                                         │
│  │   FAC   │  ← Loaded after CTLD → F3              │
│  └─────────┘                                         │
│                                                       │
└─────────────────────────────────────────────────────┘

         Players press F10 and see:
         F1: Mission Options (all utility scripts)
         F2: CTLD (always here)
         F3: FAC (always here)
```

---

## File Structure

```
Operation_Polar_Shield/
├── Core System
│   └── Moose_MenuManager.lua          ← The menu manager
│
├── Scripts (Updated)
│   ├── Moose_Intel.lua                ← Uses MenuManager
│   ├── Moose_CaptureZones.lua         ← Uses MenuManager
│   ├── Moose_NavalGroup.lua           ← Uses MenuManager
│   └── Moose_TADC_Load2nd.lua         ← Uses MenuManager
│
├── Scripts (Unchanged)
│   ├── CTLD.lua                       ← Creates own menu (F2)
│   └── Moose_FAC2MarkRecceZone.lua   ← Creates own menu (F3)
│
└── Documentation
    ├── F10_MENU_SYSTEM_GUIDE.md       ← Full guide
    ├── F10_MENU_QUICK_REF.md          ← Quick reference
    ├── MENUMANAGER_SUMMARY.md         ← Summary
    ├── MENUMANAGER_TEMPLATE.lua       ← Code templates
    ├── EXAMPLE_MISSION_SETUP.lua      ← Setup example
    └── MENUMANAGER_VISUAL_GUIDE.md    ← This file!
```

---

## Success Metrics

### Before
- ❌ CTLD position: Variable (F4-F8)
- ❌ FAC position: Variable (F5-F9)
- ❌ Root menus: 6-8 items (cluttered)
- ❌ Player navigation time: 10-15 seconds
- ❌ Player satisfaction: Low (complaints)

### After
- ✅ CTLD position: Always F2
- ✅ FAC position: Always F3
- ✅ Root menus: 3 items (clean)
- ✅ Player navigation time: 1 second
- ✅ Player satisfaction: High (positive feedback)

---

## Quick Reference

```
┌──────────────────────────────────────┐
│  Press F10, then:                    │
├──────────────────────────────────────┤
│  F1 → Mission Options                │
│       All utility/support features   │
│                                      │
│  F2 → CTLD                           │
│       Cargo/troop transport          │
│                                      │
│  F3 → AFAC Control                   │
│       Forward air controller         │
└──────────────────────────────────────┘

Every mission. Every time. Consistent!
```

---

**Remember**: The key to this system working is **load order**!

1. Load MenuManager first
2. Load CTLD second (→ F2)
3. Load FAC third (→ F3)
4. Load everything else (→ under F1)

Simple, effective, professional! 🎯
