# Dynamic Ground Battle Plugin

## Overview

This is a **plugin version** of the Dynamic Ground Battle system designed to work alongside `Moose_DualCoalitionZoneCapture.lua`. 

**Key difference from the standalone version:**
- ✅ Uses zones from `Moose_DualCoalitionZoneCapture.lua` (no duplicate zone management)
- ✅ Handles ONLY warehouse system + AI spawning + task assignment
- ✅ Zone capture, colors, messaging, win conditions = handled by DualCoalitionZoneCapture
- ✅ Cleaner separation of concerns

## Load Order (Critical!)

In your Mission Editor → Triggers → Mission Start:

```
1. DO SCRIPT FILE Moose_.lua
2. DO SCRIPT FILE Moose_DualCoalitionZoneCapture.lua  ← Must load FIRST
3. DO SCRIPT FILE Moose_DynamicGroundBattle_Plugin.lua ← This file
4. DO SCRIPT FILE CTLD.lua (optional)
5. DO SCRIPT FILE CSAR.lua (optional)
```

## What This Plugin Does

### ✅ Warehouse System
- Red/Blue warehouses affect reinforcement spawn rates
- 100% alive = 100% spawn rate
- 50% alive = 50% spawn rate (2x delay)
- 0% alive = no more spawns
- Map markers show warehouse locations and intel

### ✅ Dynamic AI Spawning
- Spawns infantry and armor groups in **friendly zones only**
- Zones come from `DualCoalitionZoneCapture`'s `ZONE_CONFIG`
- As zones are captured/lost, spawn locations automatically update
- Configurable limits and spawn frequencies

### ✅ AI Task Assignment
- Groups patrol toward nearest enemy zone
- Reassignment every 600s (configurable)
- Only idle units get new orders (moving units ignored)
- Infantry movement can be disabled

### ✅ CTLD Integration
- Dropped troops automatically get AI tasking
- Works seamlessly with logistics operations

## What This Plugin Does NOT Do

- ❌ Zone capture logic (handled by DualCoalitionZoneCapture)
- ❌ Zone coloring/messaging (handled by DualCoalitionZoneCapture)
- ❌ Win conditions (handled by DualCoalitionZoneCapture)
- ❌ Scoring (handled by DualCoalitionZoneCapture)

## Configuration

Edit the top section of `Moose_DynamicGroundBattle_Plugin.lua`:

### Infantry Movement
```lua
local MOVING_INFANTRY_PATROLS = false  -- Set true to enable infantry patrols
```

### Warehouse Markers
```lua
local ENABLE_WAREHOUSE_MARKERS = true
local UPDATE_MARK_POINTS_SCHED = 300  -- Update every 5 minutes
```

### Spawn Settings
```lua
-- Red Side
local INIT_RED_INFANTRY = 5
local MAX_RED_INFANTRY = 100
local SPAWN_SCHED_RED_INFANTRY = 1800  -- Every 30 minutes

local INIT_RED_ARMOR = 25
local MAX_RED_ARMOR = 200
local SPAWN_SCHED_RED_ARMOR = 300      -- Every 5 minutes

-- Blue Side
local INIT_BLUE_INFANTRY = 5
local MAX_BLUE_INFANTRY = 100
local SPAWN_SCHED_BLUE_INFANTRY = 1800

local INIT_BLUE_ARMOR = 25
local MAX_BLUE_ARMOR = 200
local SPAWN_SCHED_BLUE_ARMOR = 300

-- Task Assignment
local ASSIGN_TASKS_SCHED = 600  -- Reassign idle units every 10 minutes
```

### Warehouses
```lua
local redWarehouses = {
    STATIC:FindByName("RedWarehouse1-1"),
    STATIC:FindByName("RedWarehouse2-1"),
    -- Add more as needed
}

local blueWarehouses = {
    STATIC:FindByName("BlueWarehouse1-1"),
    STATIC:FindByName("BlueWarehouse2-1"),
    -- Add more as needed
}
```

### Unit Templates
```lua
local redInfantryTemplates = {
    "RedInfantry1",
    "RedInfantry2",
    -- Add more for variety
}

local redArmorTemplates = {
    "RedArmor1",
    "RedArmor2",
    -- Add more for variety
}

-- Same for blue side...
```

## Mission Editor Setup

### Required Groups (All LATE ACTIVATE)

**Red Side:**
- Infantry: `RedInfantry1`, `RedInfantry2`, `RedInfantry3`, `RedInfantry4`, `RedInfantry5`, `RedInfantry6`
- Armor: `RedArmor1`, `RedArmor2`, `RedArmor3`, `RedArmor4`, `RedArmor5`, `RedArmor6`

**Blue Side:**
- Infantry: `BlueInfantry1`, `BlueInfantry2`, `BlueInfantry3`, `BlueInfantry4`, `BlueInfantry5`, `BlueInfantry6`
- Armor: `BlueArmor1`, `BlueArmor2`, `BlueArmor3`, `BlueArmor4`, `BlueArmor5`

### Required Static Objects (Warehouses)

**Red Side:**
- Static objects with **Unit Name** (not Name field!): `RedWarehouse1-1`, `RedWarehouse2-1`, `RedWarehouse3-1`, etc.

**Blue Side:**
- Static objects with **Unit Name**: `BlueWarehouse1-1`, `BlueWarehouse2-1`, `BlueWarehouse3-1`, etc.

⚠️ **Important:** Warehouses use the "Unit Name" field in the static object properties, not the "Name" field!

### Zone Configuration

Zones come from `Moose_DualCoalitionZoneCapture.lua`. Edit that file's `ZONE_CONFIG`:

```lua
local ZONE_CONFIG = {
  RED = {
    "Capture Zone-1",
    "Capture Zone-2",
    "Capture Zone-3",
  },
  
  BLUE = {
    "Capture Zone-4",
    "Capture Zone-5",
    "Capture Zone-6",
  },
  
  NEUTRAL = {}
}
```

## F10 Menu

- **Ground Battle → Check Warehouse Status** - Shows current warehouse count and reinforcement capacity

## Integration Points

### With DualCoalitionZoneCapture
- Reads `zoneCaptureObjects` and `zoneNames` arrays
- Dynamically spawns in zones controlled by the appropriate coalition
- AI routes to enemy zones based on current ownership

### With CTLD
- Any troops dropped via CTLD in friendly zones will automatically receive AI tasking
- They'll patrol toward nearest enemy zone like spawned units

## Performance & Memory Safety

This plugin version includes all the memory leak fixes from the standalone version:

✅ Marker cleanup prevents orphaning  
✅ Reuses SET_GROUP instead of recreating  
✅ Uses SCHEDULER instead of recursive TIMERs  
✅ Efficient zone polling

## Troubleshooting

### "ERROR: Moose_DualCoalitionZoneCapture.lua must be loaded BEFORE this plugin!"
- Check your trigger load order
- DualCoalitionZoneCapture must be loaded in an earlier trigger

### Units not spawning
- Check `dcs.log` for errors
- Verify warehouse static objects exist with correct **Unit Names**
- Verify template groups exist and are set to LATE ACTIVATE
- Check that friendly zones exist (units only spawn in controlled zones)

### Units not moving
- If infantry: check `MOVING_INFANTRY_PATROLS` setting
- Verify enemy zones exist for AI to target
- Check `dcs.log` for task assignment messages (`[DGB PLUGIN]`)

### Warehouse markers not showing
- Set `ENABLE_WAREHOUSE_MARKERS = true`
- Check warehouse static objects are alive
- Markers update every `UPDATE_MARK_POINTS_SCHED` seconds

## Version History

- **1.0.0** (2024-11-15) - Initial plugin version
  - Extracted from standalone Dynamic Ground Battle
  - Integrated with DualCoalitionZoneCapture
  - Added memory leak fixes
  - Dynamic zone-based spawning
