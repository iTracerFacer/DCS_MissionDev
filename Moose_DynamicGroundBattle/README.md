# Moose Dynamic Ground Battle

**Version:** 1.0.3  
**Author:** F99th-TracerFacer  
**Date:** November 12, 2024

## Overview

Moose Dynamic Ground Battle is a sophisticated DCS World mission script that creates an engaging, dynamic ground warfare system between Red and Blue coalitions. The script uses the MOOSE framework to simulate realistic battlefield conditions with zone capture mechanics, intelligent AI movement, and warehouse-based reinforcement systems.

## Features

### 🎯 Zone Capture System
- **Multiple Zone States:** Captured, Guarded, Empty, Attacked, and Neutral
- **Visual Indicators:** 
  - 🔴 Red: Captured by Red forces
  - 🔵 Blue: Captured by Blue forces
  - 🟠 Orange: Contested zone
  - 🟢 Green: Empty/Neutral zone
- **Real-time Updates:** Zone status changes trigger messages and visual updates

### 🚁 Intelligent AI Behavior
- **Automated Spawning:** Infantry and armor groups spawn at random locations within friendly zones
- **Smart Pathfinding:** Units automatically calculate and move to the nearest enemy zone
- **Periodic Task Assignment:** Every configurable interval, units receive new orders based on zone states
- **CTLD Integration:** Troops dropped via CTLD will automatically join the battle
- **Stuck Unit Recovery:** Units that become stuck can be reset to receive new patrol orders

### 🏭 Warehouse System
- **Dynamic Reinforcement Rate:** Spawn frequency adjusts based on warehouse survival
- **Proportional Impact:** 100% warehouses = 100% reinforcement rate, 50% warehouses = 50% rate
- **Intelligence Markers:** Automatic map markers showing warehouse locations and nearby units
- **Strategic Importance:** Warehouses become critical targets affecting enemy reinforcement capability

### 📊 Spawn Management
- **Configurable Limits:** Set initial spawn counts and maximum unit limits
- **Template Randomization:** Multiple unit templates for variety
- **Frequency Control:** Adjustable spawn intervals for infantry and armor
- **Coalition Balance:** Independent settings for Red and Blue forces

## Installation Requirements

### Prerequisites
1. **MOOSE Framework:** This script requires the MOOSE framework for DCS World
   - Download from [MOOSE GitHub](https://github.com/FlightControl-Master/MOOSE)
   - Load MOOSE in your mission before this script
2. **DCS World:** Compatible with current DCS World versions
3. **Mission Editor:** All groups, zones, and warehouses must be pre-configured

### Mission Editor Setup

#### Required Groups (All LATE ACTIVATE)

**Red Forces:**
```
Infantry: RedInfantry1, RedInfantry2, RedInfantry3, RedInfantry4, RedInfantry5, RedInfantry6
Armor: RedArmor1, RedArmor2, RedArmor3, RedArmor4, RedArmor5, RedArmor6
```

**Blue Forces:**
```
Infantry: BlueInfantry1, BlueInfantry2, BlueInfantry3, BlueInfantry4, BlueInfantry5, BlueInfantry6
Armor: BlueArmor1, BlueArmor2, BlueArmor3, BlueArmor4, BlueArmor5
```

#### Required Zones

**Red Zones:**
```
FrontLine1, FrontLine2, FrontLine3, FrontLine4, FrontLine5, FrontLine6
```

**Blue Zones:**
```
FrontLine7, FrontLine8, FrontLine9, FrontLine10, FrontLine11, FrontLine12
```

#### Required Warehouses (Static Objects)

**Red Warehouses:**
```
RedWarehouse1-1, RedWarehouse2-1, RedWarehouse3-1, 
RedWarehouse4-1, RedWarehouse5-1, RedWarehouse6-1
```

**Blue Warehouses:**
```
BlueWarehouse1-1, BlueWarehouse2-1, BlueWarehouse3-1, 
BlueWarehouse4-1, BlueWarehouse5-1, BlueWarehouse6-1
```

⚠️ **Important:** Warehouse names are based on the static **unit name** in the mission editor, not the display name.

#### Optional: Command Centers
If not using another script for command centers, create these units:
- `BLUEHQ` - Blue coalition HQ unit
- `REDHQ` - Red coalition HQ unit

## Configuration

### Basic Settings

```lua
-- Infantry Movement
MOVING_INFANTRY_PATROLS = false  -- Set true to enable infantry movement

-- Warehouse Markers
ENABLE_WAREHOUSE_MARKERS = true
UPDATE_MARK_POINTS_SCHED = 60    -- Update interval in seconds
MAX_WAREHOUSE_UNIT_LIST_DISTANCE = 5000  -- Search radius in meters

-- Task Assignment
ASSIGN_TASKS_SCHED = 600  -- Reassign tasks every 600 seconds
```

### Spawn Configuration

**Red Forces:**
```lua
INIT_RED_INFANTRY = 5           -- Initial infantry groups
MAX_RED_INFANTRY = 100          -- Maximum infantry groups
SPAWN_SCHED_RED_INFANTRY = 1800 -- Spawn interval (seconds)

INIT_RED_ARMOR = 25             -- Initial armor groups
MAX_RED_ARMOR = 200             -- Maximum armor groups
SPAWN_SCHED_RED_ARMOR = 300     -- Spawn interval (seconds)
```

**Blue Forces:**
```lua
INIT_BLUE_INFANTRY = 5          -- Initial infantry groups
MAX_BLUE_INFANTRY = 100         -- Maximum infantry groups
SPAWN_SCHED_BLUE_INFANTRY = 1800 -- Spawn interval (seconds)

INIT_BLUE_ARMOR = 25            -- Initial armor groups
MAX_BLUE_ARMOR = 200            -- Maximum armor groups
SPAWN_SCHED_BLUE_ARMOR = 300    -- Spawn interval (seconds)
```

### Zone Configuration

Zones can be arranged in any configuration - along a front line, following roads, or scattered across the map:

```lua
local redZones = {
    ZONE:New("FrontLine1"),
    ZONE:New("FrontLine2"),
    -- Add more zones as needed
}

local blueZones = {
    ZONE:New("FrontLine7"),
    ZONE:New("FrontLine8"),
    -- Add more zones as needed
}
```

### Template Customization

Add variety by creating multiple unit templates:

```lua
local redInfantryTemplates = {
    "RedInfantry1",
    "RedInfantry2",
    -- Add more templates for variety
}

local redArmorTemplates = {
    "RedArmor1",
    "RedArmor2",
    -- Add more templates for variety
}
```

## Gameplay Mechanics

### Zone Capture
- Zones change ownership based on unit presence
- Zones transition through states: Empty → Attacked → Captured → Guarded
- Players receive notifications when zones change status
- Visual indicators (smoke and map colors) show current ownership

### Unit Behavior
1. **Spawn:** Units spawn at random locations in friendly zones
2. **Task Assignment:** Units calculate the nearest enemy zone
3. **Movement:** Units patrol to and around enemy zones
4. **Reassignment:** Stationary units receive new orders periodically
5. **Combat:** Units engage enemies encountered during patrols

### Warehouse Impact
- **Full Capacity:** All warehouses alive = normal spawn rate
- **Reduced Capacity:** 50% warehouses alive = 2x spawn delay
- **No Capacity:** 0% warehouses alive = no more spawns
- **Strategic Target:** Destroying enemy warehouses significantly impacts their reinforcement rate

### Win Conditions
- Mission ends when one coalition captures all zones
- Periodic checks every 60 seconds
- Victory message and sound plays for winning side

## In-Game Menu

Access warehouse status via the F10 menu:
```
F10 → Warehouse Monitoring → Check Warehouse Status
```

This displays:
- Number of warehouses alive per side
- Current reinforcement capacity percentage
- Real-time battlefield intelligence

## Customization Tips

### Adjusting Difficulty
- **Increase Challenge:** Reduce friendly spawn rates, increase enemy spawn rates
- **Balance Forces:** Adjust MAX values to limit unit counts
- **Strategic Depth:** Add more zones and warehouses
- **Terrain Adaptation:** Disable infantry movement for mountainous terrain

### Adding More Units
1. Create new templates in mission editor
2. Add template names to the appropriate arrays
3. Ensure templates are set to LATE ACTIVATE
4. Test spawn behavior and patrol patterns

### Zone Layouts
- **Linear Front:** Place zones in a line for traditional front-line combat
- **Scattered:** Distribute zones for multi-front warfare
- **Road Network:** Follow roads for realistic vehicle movement
- **Strategic Points:** Place zones at key terrain features

## Troubleshooting

### Common Issues

**Units Not Spawning:**
- Verify all template groups exist in mission editor
- Check that groups are set to LATE ACTIVATE
- Review DCS.log for error messages

**Units Not Moving:**
- Check `MOVING_INFANTRY_PATROLS` setting for infantry
- Verify zones are properly named and created
- Check that units aren't already moving when tasks are assigned

**Warehouse Markers Not Showing:**
- Ensure `ENABLE_WAREHOUSE_MARKERS = true`
- Verify warehouse static objects exist
- Check that warehouse names match unit names (not display names)

**Zones Not Capturing:**
- Verify MOOSE framework is loaded
- Check zone names match exactly
- Ensure units are fully inside zones

## Script Structure

```
├── Configuration Section (User Editable)
│   ├── Spawn Settings
│   ├── Zone Definitions
│   ├── Warehouse Definitions
│   └── Template Definitions
│
├── Core Functions (Do Not Edit)
│   ├── Zone Capture System
│   ├── Task Assignment Logic
│   ├── Warehouse Monitoring
│   ├── Spawn Frequency Calculator
│   └── Win Condition Checker
│
└── Initialization
    ├── Spawn Schedulers
    ├── Event Handlers
    └── Menu Creation
```

## Performance Considerations

- **Unit Limits:** Higher MAX values increase computational load
- **Update Frequency:** Longer intervals reduce CPU usage but decrease responsiveness
- **Zone Count:** More zones = more calculations per update
- **Template Variety:** More templates add minimal overhead

## Credits

- **Script Author:** F99th-TracerFacer
- **Framework:** MOOSE Framework by FlightControl
- **Community:** DCS World Mission Editing Community

## Version History

- **1.0.3** (November 12, 2024) - Current release
- **1.0.0** (November 11, 2024) - Initial release

## License

This script is provided as-is for the DCS World community. Feel free to modify and distribute with credit to the original author.

## Support

For issues, suggestions, or improvements, please contact the author or submit issues through your community channels.

---

**Happy Mission Building! 🚁**
