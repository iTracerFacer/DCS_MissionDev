# DCS Mission Patcher

PowerShell script to automatically patch DCS mission files (.miz) with updated Lua scripts and increment version numbers.

## Features

- ✅ Updates Lua scripts in .miz files without opening DCS Mission Editor
- ✅ **Automatically increments version numbers** in mission filenames (e.g., 1.2.3 → 1.2.4)
- ✅ **Preserves original missions** - creates new versioned files instead of overwriting
- ✅ Supports single or batch processing of multiple missions
- ✅ Can output to a different directory
- ✅ Handles both new script insertion and existing script replacement
- ✅ Pipeline support for processing multiple missions
- ✅ Smart version detection (supports X.Y.Z, X.Y, and X formats)

## Version Increment Examples

| Input Filename | Output Filename |
|----------------|-----------------|
| `Mission-1.2.3.miz` | `Mission-1.2.4.miz` |
| `Operation Black Gold 2.8.miz` | `Operation Black Gold 2.9.miz` |
| `F99th-Battle of Gori 1.3.miz` | `F99th-Battle of Gori 1.4.miz` |
| `MyMission-5.miz` | `MyMission-6.miz` |
| `Test.miz` | `Test-1.0.1.miz` |

## Usage

### Basic Usage

Update a mission with automatic version increment:

```powershell
.\Patch-MooseMissions.ps1 -MissionPath "MyMission-1.2.3.miz" -LuaScriptPath "Moose_.lua"
# Original: MyMission-1.2.3.miz (untouched)
# Creates: MyMission-1.2.4.miz
```

### Batch Processing

Update all .miz files in a directory:

```powershell
Get-ChildItem "C:\DCS_Missions\*.miz" | .\Patch-MooseMissions.ps1 -LuaScriptPath "C:\Scripts\Moose_.lua"
# Each mission gets a new version
```

### Output to Different Directory

Patch missions and save versioned outputs to a different folder:

```powershell
.\Patch-MooseMissions.ps1 -MissionPath "Mission-1.5.miz" -LuaScriptPath "Moose_.lua" -OutputPath "C:\PatchedMissions"
# Creates: C:\PatchedMissions\Mission-1.6.miz
```

### Disable Version Increment (CAUTION!)

⚠️ Overwrite the original mission file without creating a new version:

```powershell
.\Patch-MooseMissions.ps1 -MissionPath "Mission-1.2.3.miz" -LuaScriptPath "Moose_.lua" -NoVersionIncrement
# WARNING: Overwrites Mission-1.2.3.miz (original is lost!)
```

### Custom Script Name

Insert a script with a different name than the source file:

```powershell
.\Patch-MooseMissions.ps1 -MissionPath "Mission.miz" -LuaScriptPath "MyScript.lua" -ScriptName "CustomName.lua"
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-MissionPath` | Yes | Path to .miz mission file(s) to patch |
| `-LuaScriptPath` | Yes | Path to the Lua script to insert/replace |
| `-ScriptName` | No | Name for the script inside the mission (defaults to source filename) |
| `-OutputPath` | No | Directory for patched missions (defaults to source directory) |
| `-NoVersionIncrement` | No | **CAUTION:** Overwrites original instead of creating new version |

## Examples

### Example 1: Update All Caucasus Missions with Version Increment

```powershell
Get-ChildItem "C:\DCS_MissionDev\DCS_Caucasus\*.miz" | .\Patch-MooseMissions.ps1 -LuaScriptPath "C:\Moose\Moose_.lua"
# Each mission gets a new version: 1.2.miz -> 1.3.miz
# Originals remain untouched
```

### Example 2: Update Specific Missions to Output Folder

```powershell
$missions = @(
    "F99th-Operation Black Gold 2.8.miz",
    "F99th-Operation Ronin 1.4.miz",
    "F99th-Battle of Gori 1.3.miz"
)

$missions | .\Patch-MooseMissions.ps1 -LuaScriptPath "Moose_.lua" -OutputPath "C:\UpdatedMissions"
# Creates: Operation Black Gold 2.9.miz, Operation Ronin 1.5.miz, Battle of Gori 1.4.miz in C:\UpdatedMissions
```

### Example 3: Overwrite Original (Use with Caution)

```powershell
.\Patch-MooseMissions.ps1 -MissionPath "TestMission-1.0.miz" -LuaScriptPath "Moose_.lua" -NoVersionIncrement
# WARNING: Overwrites TestMission-1.0.miz (original is lost)
```

## How It Works

1. **Extraction**: The script treats .miz files as ZIP archives and extracts them to a temporary directory
2. **Script Replacement**: Locates the Lua script in `l10n/DEFAULT/` folder and replaces/adds it
3. **Version Increment**: Automatically detects version pattern and increments the patch number
4. **Repackaging**: Compresses the modified mission into a new .miz file with incremented version
5. **Cleanup**: Removes temporary files

## Version Detection Logic

The script intelligently detects and increments version numbers:

- **X.Y.Z format** (e.g., `Mission-1.2.3.miz`) → Increments Z: `Mission-1.2.4.miz`
- **X.Y format** (e.g., `Mission-2.8.miz`) → Increments Y: `Mission-2.9.miz`  
- **X format** (e.g., `Mission-5.miz`) → Increments X: `Mission-6.miz`
- **No version** (e.g., `Mission.miz`) → Adds version: `Mission-1.0.1.miz`

Supports various separators: `-`, `_`, or space

## Mission File Structure

DCS mission files (.miz) are ZIP archives with this structure:

```
Mission.miz
├── mission
├── options
├── warehouses
├── l10n/
│   └── DEFAULT/
│       ├── dictionary
│       ├── mapResource
│       └── *.lua           ← Scripts are stored here
```

## Important Notes

⚠️ **Always test patched missions** before using them in production or multiplayer!

⚠️ **Originals are safe**: By default, the script creates NEW versioned files and never modifies originals

⚠️ **Script order matters**: If your mission has script load order dependencies, this tool only replaces the file content, not the trigger order

⚠️ **Version increment default**: By default, versions are incremented. Use `-NoVersionIncrement` to overwrite originals (NOT recommended)

✅ **Safe for**: Updating framework files like Moose_.lua, mist.lua, or any embedded Lua script

✅ **Preserves originals**: Original missions remain untouched (new versioned files are created)

✅ **No backups needed**: Since originals aren't modified, you always have your previous version

## Troubleshooting

### "File is not a .miz mission file"
- Ensure you're pointing to a valid .miz file, not a .lua or other file type

### "Lua script not found"
- Verify the path to your Lua script is correct and the file exists

### Mission doesn't work after patching
- Restore from backup
- Verify the Lua script is valid
- Check DCS.log for script errors
- Ensure you updated the correct script name

### Permission errors
- Run PowerShell as Administrator if modifying files in protected directories
- Ensure mission files are not read-only

## Requirements

- Windows PowerShell 5.1 or later (or PowerShell Core 7+)
- Write permissions to mission file locations
- Valid .miz mission files
- Valid Lua script to insert

## Author

**F99th-TracerFacer**

Discord: https://discord.gg/7wBVWKK3

## License

Free to use and modify for the DCS community.
