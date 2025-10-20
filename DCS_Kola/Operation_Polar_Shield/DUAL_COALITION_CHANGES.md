# Dual Coalition Zone Capture - Full Analysis & Changes

## Summary
The script has been refactored to provide **complete parity between RED and BLUE coalitions**. Both sides now have equal access to all features, information, and victory conditions.

---

## ✅ Changes Made for Full Dual-Coalition Support

### 1. **Tactical Markers** (Lines ~390-440)
**BEFORE:** Only BLUE coalition received tactical markers
**AFTER:** Both RED and BLUE receive separate tactical markers
- Each coalition sees enemy unit positions (when ≤10 units)
- Markers are coalition-specific and read-only
- Uses `TacticalMarkerID_BLUE` and `TacticalMarkerID_RED` for tracking

### 2. **Victory Conditions** (Lines ~490-600)
**BEFORE:** Only checked for BLUE victory
**AFTER:** Both coalitions can win
- BLUE Victory: All zones captured → "BLUE_VICTORY" flag set
- RED Victory: All zones captured → "RED_VICTORY" flag set
- Each side gets appropriate celebration effects (smoke colors, flares)
- Proper victory/defeat messages for both sides

### 3. **Zone Status Reports** (Lines ~710-740)
**BEFORE:** Only BLUE received status broadcasts
**AFTER:** Both coalitions receive status reports
- Each coalition sees their specific victory progress percentage
- Same zone ownership data, customized messaging per coalition

### 4. **Victory Progress Monitoring** (Lines ~745-780)
**BEFORE:** Only warned BLUE when approaching victory
**AFTER:** Both sides get symmetric warnings
- BLUE approaching victory (80%+) → BLUE gets encouragement, RED gets warning
- RED approaching victory (80%+) → RED gets encouragement, BLUE gets warning

### 5. **F10 Radio Menu Commands** (Lines ~840-900)
**BEFORE:** Only BLUE had F10 menu access
**AFTER:** Both coalitions have identical F10 menus
- "Get Zone Status Report" - Shows current zone ownership
- "Check Victory Progress" - Shows their specific progress percentage
- "Refresh Zone Colors" - Forces zone border redraw

### 6. **Zone Color Refresh Messages** (Line ~835)
**BEFORE:** Only BLUE notified when colors refreshed
**AFTER:** Both coalitions receive confirmation message

### 7. **Mission Definitions** (Lines 52-88)
**BEFORE:** Only BLUE mission defined
**AFTER:** Both coalitions have missions
- BLUE: "Capture the Airfields" (offensive mission)
- RED: "Defend the Motherland" (defensive mission)

---

## 🎯 Features Now Available to BOTH Coalitions

| Feature | BLUE | RED |
|---------|------|-----|
| Mission Objectives | ✅ | ✅ |
| Tactical Markers (enemy positions) | ✅ | ✅ |
| Zone Status Reports | ✅ | ✅ |
| Victory Progress Tracking | ✅ | ✅ |
| Victory Conditions | ✅ | ✅ |
| F10 Menu Commands | ✅ | ✅ |
| Zone Color Indicators | ✅ | ✅ |
| Capture/Attack/Guard Messages | ✅ | ✅ |

---

## 🔧 Configuration

Mission makers can now set up asymmetric scenarios by configuring the `ZONE_CONFIG` table:

```lua
local ZONE_CONFIG = {
  RED = {
    "Kilpyavr",
    "Severomorsk-1",
    -- ... more zones
  },
  
  BLUE = {
    "Banak",  -- Example: BLUE starting zone
    "Kirkenes"
  },
  
  NEUTRAL = {
    "Contested Valley"  -- Starts empty
  }
}
```

---

## 🎮 Gameplay Impact

### Balanced Competition
- Both sides can now win by capturing all zones
- Victory celebrations are coalition-specific (blue/red smoke & flares)
- Mission end triggers coalition-specific flags

### Equal Information Access
- Both coalitions see enemy positions in contested zones
- Both receive periodic status updates
- Both have access to F10 menu commands

### Symmetric Design
- All event handlers work equally for both sides
- Messages are dynamically generated based on zone ownership
- No hardcoded coalition bias anywhere in the code

---

## 📝 Technical Notes

### Global Variables Used
- `US_CC` - BLUE coalition command center
- `RU_CC` - RED coalition command center
- Both must be defined before loading this script

### User Flags Set on Victory
- `BLUE_VICTORY` = 1 when BLUE wins
- `RED_VICTORY` = 1 when RED wins

### Storage Structure
- `zoneCaptureObjects[]` - Array of zone capture objects
- `zoneNames[]` - Array of zone names
- `zoneMetadata{}` - Dictionary with coalition info
- All zones accessible via table iteration (no global zone variables)

---

## 🚀 Migration from Old Script

If migrating from `Moose_CaptureZones.lua`:

1. **Update zone configuration** - Move zone names to `ZONE_CONFIG` table
2. **Remove manual zone creation** - The loop handles it now
3. **No code changes needed** for existing trigger zones in mission editor
4. **F10 menus now available** to RED players automatically

---

## ✨ Benefits of Refactoring

1. **Easy to configure** - Simple table instead of repetitive code
2. **Coalition agnostic** - Works equally for RED/BLUE/NEUTRAL
3. **Maintainable** - Zone logic centralized in loops
4. **Extensible** - Easy to add new features for both sides
5. **Balanced** - True dual-coalition gameplay

---

*Last Updated: Analysis completed with full dual-coalition parity*
