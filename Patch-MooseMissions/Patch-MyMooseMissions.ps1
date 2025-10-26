<#
.SYNOPSIS
    Batch updates all DCS missions with the latest Moose framework.

.DESCRIPTION
    This script scans through the DCS mission development folder structure,
    finds the latest version of each mission (.miz files with version numbers),
    and patches them with the updated Moose_.lua script using Patch-MooseMissions.ps1.
    
    It processes missions in the structure: C:\DCS_MissionDev\DCS_[Terrain]\[MissionFolder]\
    For each mission folder, it identifies the latest version (by version number or file date)
    and creates a new patched version.

.PARAMETER RootPath
    Root directory containing DCS terrain folders. Defaults to C:\DCS_MissionDev

.PARAMETER MooseLuaPath
    Path to the Moose_.lua file to patch into missions. Defaults to C:\DCS_MissionDev\Moose_.lua

.PARAMETER WhatIf
    Shows what would be processed without actually patching any files.

.PARAMETER ExcludeTerrain
    Array of terrain folder names to exclude from processing (e.g., @("DCS_Normandy", "DCS_Falklands"))

.EXAMPLE
    .\Patch-MyMooseMissions.ps1
    Shows what missions would be processed (WhatIf mode - no changes made)

.EXAMPLE
    .\Patch-MyMooseMissions.ps1 -Force
    Actually patches all missions with the latest Moose_.lua

.EXAMPLE
    .\Patch-MyMooseMissions.ps1 -Force -ExcludeTerrain @("DCS_Normandy", "DCS_Falklands")
    Processes all missions except those in Normandy and Falklands terrains

.NOTES
    Author: F99th-TracerFacer
    Version: 1.0
    Requires: Patch-MooseMissions.ps1 in the same directory
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$RootPath = "C:\DCS_MissionDev",
    
    [Parameter(Mandatory=$false)]
    [string]$MooseLuaPath = "C:\DCS_MissionDev\Moose_.lua",
    
    [Parameter(Mandatory=$false)]
    [string[]]$ExcludeTerrain = @(),
    
    [Parameter(Mandatory=$false)]
    [switch]$Force
)

Clear-Host

# Enable WhatIf mode by default unless -Force is specified
$runInWhatIfMode = -not $Force

if ($runInWhatIfMode) {
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host "RUNNING IN WHATIF MODE (Preview Only)" -ForegroundColor Magenta
    Write-Host "No files will be modified" -ForegroundColor Magenta
    Write-Host "Use -Force parameter to actually patch missions" -ForegroundColor Magenta
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host ""
}

# Verify paths exist
if (-not (Test-Path $RootPath)) {
    Write-Error "Root path not found: $RootPath"
    exit 1
}

# Verify the Patch-MooseMissions.ps1 script exists
$patchScriptPath = Join-Path $PSScriptRoot "Patch-MooseMissions.ps1"
if (-not (Test-Path $patchScriptPath)) {
    Write-Error "Patch-MooseMissions.ps1 not found in: $PSScriptRoot"
    exit 1
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Batch Moose Mission Patcher" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Root Path: $RootPath" -ForegroundColor Yellow
Write-Host "Moose Script: $MooseLuaPath" -ForegroundColor Yellow
Write-Host "Patch Script: $patchScriptPath" -ForegroundColor Yellow
if ($ExcludeTerrain.Count -gt 0) {
    Write-Host "Excluded Terrains: $($ExcludeTerrain -join ', ')" -ForegroundColor Yellow
}
Write-Host ""

# Download latest Moose_.lua from GitHub
if (-not $runInWhatIfMode) {
    Write-Host "Downloading latest Moose_.lua from GitHub..." -ForegroundColor Yellow

    $mooseGitHubUrl = "https://raw.githubusercontent.com/FlightControl-Master/MOOSE_INCLUDE/develop/Moose_Include_Static/Moose_.lua"
    $backupPath = "$MooseLuaPath.backup"

    try {
        # Create a single backup of existing Moose_.lua if it exists and backup doesn't exist yet
        if ((Test-Path $MooseLuaPath) -and -not (Test-Path $backupPath)) {
            Write-Host "  Creating backup: $backupPath" -ForegroundColor Gray
            Copy-Item $MooseLuaPath $backupPath -Force
        }
        
        # Download the file
        $ProgressPreference = 'SilentlyContinue'  # Speeds up Invoke-WebRequest
        Invoke-WebRequest -Uri $mooseGitHubUrl -OutFile $MooseLuaPath -ErrorAction Stop
        $ProgressPreference = 'Continue'
        
        # Verify the download
        if (Test-Path $MooseLuaPath) {
            $fileSize = (Get-Item $MooseLuaPath).Length
            Write-Host "  SUCCESS: Downloaded Moose_.lua ($([math]::Round($fileSize/1MB, 2)) MB)" -ForegroundColor Green
        } else {
            throw "Downloaded file not found after download"
        }
    }
    catch {
        Write-Error "Failed to download Moose_.lua from GitHub: $_"
        Write-Host "  URL: $mooseGitHubUrl" -ForegroundColor Red
        
        # Check if we have a backup or existing file to use
        if (Test-Path $MooseLuaPath) {
            Write-Warning "Using existing Moose_.lua file instead"
        } else {
            Write-Error "No Moose_.lua file available. Cannot proceed."
            exit 1
        }
    }

    Write-Host ""
} else {
    Write-Host "WHATIF: Would download latest Moose_.lua from GitHub" -ForegroundColor Magenta
    Write-Host "  URL: https://raw.githubusercontent.com/FlightControl-Master/MOOSE_INCLUDE/develop/Moose_Include_Static/Moose_.lua" -ForegroundColor Gray
    Write-Host "  Destination: $MooseLuaPath" -ForegroundColor Gray
    
    # Still need to verify file exists for WhatIf to show what would be patched
    if (-not (Test-Path $MooseLuaPath)) {
        Write-Warning "Moose_.lua not found at $MooseLuaPath - run with -Force to download it"
        Write-Warning "Continuing with WhatIf to show which missions would be processed..."
    }
    Write-Host ""
}

# Function to parse version number from filename
function Get-VersionNumber {
    param([string]$FileName)
    
    $nameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($FileName)
    
    # Try X.Y.Z pattern
    if ($nameWithoutExt -match '(\d+)\.(\d+)\.(\d+)') {
        $major = [int]$matches[1]
        $minor = [int]$matches[2]
        $patch = [int]$matches[3]
        return [PSCustomObject]@{
            Major = $major
            Minor = $minor
            Patch = $patch
            Value = ($major * 1000000) + ($minor * 1000) + $patch
            HasVersion = $true
        }
    }
    # Try X.Y pattern
    elseif ($nameWithoutExt -match '(\d+)\.(\d+)') {
        $major = [int]$matches[1]
        $minor = [int]$matches[2]
        return [PSCustomObject]@{
            Major = $major
            Minor = $minor
            Patch = 0
            Value = ($major * 1000000) + ($minor * 1000)
            HasVersion = $true
        }
    }
    # Try single version number
    elseif ($nameWithoutExt -match '(\d+)$') {
        $version = [int]$matches[1]
        return [PSCustomObject]@{
            Major = $version
            Minor = 0
            Patch = 0
            Value = $version * 1000000
            HasVersion = $true
        }
    }
    
    # No version found
    return [PSCustomObject]@{
        Major = 0
        Minor = 0
        Patch = 0
        Value = 0
        HasVersion = $false
    }
}

# Function to get the latest mission file from a directory
function Get-LatestMission {
    param([string]$DirectoryPath)
    
    # Get all .miz files in the directory (not subdirectories)
    $mizFiles = Get-ChildItem -Path $DirectoryPath -Filter "*.miz" -File -ErrorAction SilentlyContinue
    
    if ($mizFiles.Count -eq 0) {
        return $null
    }
    
    # Separate files with version numbers from those without
    $versionedFiles = @()
    $nonVersionedFiles = @()
    
    foreach ($file in $mizFiles) {
        $version = Get-VersionNumber -FileName $file.Name
        if ($version.HasVersion) {
            $versionedFiles += [PSCustomObject]@{
                File = $file
                Version = $version
            }
        } else {
            $nonVersionedFiles += $file
        }
    }
    
    # If we have versioned files, return the one with the highest version
    if ($versionedFiles.Count -gt 0) {
        $latest = $versionedFiles | Sort-Object -Property { $_.Version.Value } -Descending | Select-Object -First 1
        return $latest.File
    }
    
    # If no versioned files, return the most recently modified file
    if ($nonVersionedFiles.Count -gt 0) {
        return $nonVersionedFiles | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1
    }
    
    return $null
}

# Get all DCS terrain folders (folders starting with "DCS_")
$terrainFolders = Get-ChildItem -Path $RootPath -Directory | Where-Object { $_.Name -match '^DCS_' }

if ($terrainFolders.Count -eq 0) {
    Write-Warning "No DCS terrain folders found in: $RootPath"
    exit 0
}

Write-Host "Found $($terrainFolders.Count) terrain folder(s)" -ForegroundColor Green
Write-Host ""

# Track statistics
$totalMissionsFound = 0
$totalMissionsPatched = 0
$totalMissionsFailed = 0
$skippedTerrains = 0

# Process each terrain folder
foreach ($terrainFolder in $terrainFolders) {
    $terrainName = $terrainFolder.Name
    
    # Check if this terrain should be excluded
    if ($ExcludeTerrain -contains $terrainName) {
        Write-Host "SKIPPING TERRAIN: $terrainName (excluded)" -ForegroundColor DarkGray
        $skippedTerrains++
        continue
    }
    
    Write-Host "TERRAIN: $terrainName" -ForegroundColor Cyan
    
    # Get all subdirectories (mission folders)
    $missionFolders = Get-ChildItem -Path $terrainFolder.FullName -Directory -ErrorAction SilentlyContinue
    
    if ($missionFolders.Count -eq 0) {
        Write-Host "  No mission folders found" -ForegroundColor DarkGray
        Write-Host ""
        continue
    }
    
    Write-Host "  Found $($missionFolders.Count) mission folder(s)" -ForegroundColor Gray
    
    # Process each mission folder
    foreach ($missionFolder in $missionFolders) {
        $missionFolderName = $missionFolder.Name
        
        # Get the latest mission file
        $latestMission = Get-LatestMission -DirectoryPath $missionFolder.FullName
        
        if ($null -eq $latestMission) {
            Write-Host "    [$missionFolderName] No .miz files found" -ForegroundColor DarkGray
            continue
        }
        
        $totalMissionsFound++
        
        Write-Host "    [$missionFolderName] Latest: " -NoNewline -ForegroundColor White
        Write-Host "$($latestMission.Name)" -ForegroundColor Yellow
        
        # Execute the patch script
        if (-not $runInWhatIfMode) {
            try {
                # Call Patch-MooseMissions.ps1
                & $patchScriptPath -MissionPath $latestMission.FullName -LuaScriptPath $MooseLuaPath -ErrorAction Stop
                
                # Check if it succeeded (the script will output its own messages)
                if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
                    $totalMissionsPatched++
                } else {
                    $totalMissionsFailed++
                }
            }
            catch {
                Write-Host "      ERROR: Failed to patch mission - $_" -ForegroundColor Red
                $totalMissionsFailed++
            }
        }
        else {
            Write-Host "      WHATIF: Would patch this mission with Moose_.lua" -ForegroundColor Magenta
        }
    }
    
    Write-Host ""
}

# Final summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Batch Processing Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Terrains Processed: $($terrainFolders.Count - $skippedTerrains)" -ForegroundColor White
if ($skippedTerrains -gt 0) {
    Write-Host "Terrains Skipped: $skippedTerrains" -ForegroundColor DarkGray
}
Write-Host "Missions Found: $totalMissionsFound" -ForegroundColor White
Write-Host "Missions Patched: $totalMissionsPatched" -ForegroundColor Green
if ($totalMissionsFailed -gt 0) {
    Write-Host "Missions Failed: $totalMissionsFailed" -ForegroundColor Red
}
Write-Host ""

if ($runInWhatIfMode) {
    Write-Host "INFO: This was a WhatIf run - no files were modified" -ForegroundColor Magenta
    Write-Host "INFO: Run with -Force parameter to actually patch missions" -ForegroundColor Magenta
} elseif ($totalMissionsPatched -gt 0) {
    Write-Host "SUCCESS: All missions have been patched with the latest Moose framework!" -ForegroundColor Green
    Write-Host "TIP: Test your patched missions in DCS before deployment!" -ForegroundColor Yellow
}
