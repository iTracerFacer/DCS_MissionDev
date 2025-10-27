<#
.SYNOPSIS
    Patches DCS mission files (.miz) with updated Lua scripts.

.DESCRIPTION
    This script extracts a DCS mission file (which is a ZIP archive), replaces or adds
    a Lua script file, and repackages the mission. This allows you to update scripts
    like Moose_.lua across multiple missions without opening the DCS Mission Editor.

.PARAMETER MissionPath
    Path to the .miz mission file to patch. Can be a single file or multiple files.

.PARAMETER LuaScriptPath
    Path to the Lua script file to insert/replace in the mission.

.PARAMETER ScriptName
    Optional. The name the script should have inside the mission file.
    If not specified, uses the filename from LuaScriptPath.

.PARAMETER OutputPath
    Optional. Directory where patched missions should be saved.
    If not specified, saves to the same directory as the input mission.

.PARAMETER NoVersionIncrement
    If specified, does not increment the version number in the filename.
    By default, the script automatically increments the patch version (e.g., 1.1.2 -> 1.1.3).
    WARNING: Using this flag will OVERWRITE the original mission file!

.EXAMPLE
    .\Patch-MooseMissions.ps1 -MissionPath "C:\Missions\MyMission-1.2.3.miz" -LuaScriptPath "C:\Scripts\Moose_.lua"
    Creates: MyMission-1.2.4.miz (original 1.2.3 remains untouched)

.EXAMPLE
    Get-ChildItem "C:\Missions\*.miz" | .\Patch-MooseMissions.ps1 -LuaScriptPath "C:\Scripts\Moose_.lua"

.EXAMPLE
    .\Patch-MooseMissions.ps1 -MissionPath "Mission-2.1.miz" -LuaScriptPath "MyScript.lua" -NoVersionIncrement
    WARNING: Overwrites Mission-2.1.miz

.NOTES
    Author: F99th-TracerFacer
    Version: 2.0
    DCS mission files are ZIP archives containing a 'l10n' folder with a 'DEFAULT' subfolder
    where Lua scripts are stored.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [Alias("FullName", "Path")]
    [string[]]$MissionPath,
    
    [Parameter(Mandatory=$true)]
    [string]$LuaScriptPath,
    
    [Parameter(Mandatory=$false)]
    [string]$ScriptName,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath,
    
    [Parameter(Mandatory=$false)]
    [switch]$NoVersionIncrement
)

begin {
    # Verify Lua script exists
    if (-not (Test-Path $LuaScriptPath)) {
        throw "Lua script not found: $LuaScriptPath"
    }
    
    # Determine script name to use inside mission
    if ([string]::IsNullOrWhiteSpace($ScriptName)) {
        $ScriptName = Split-Path $LuaScriptPath -Leaf
    }
    
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "DCS Mission Patcher" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Lua Script: $ScriptName" -ForegroundColor Yellow
    Write-Host "Source: $LuaScriptPath" -ForegroundColor Gray
    Write-Host "Version Increment: $(if ($NoVersionIncrement) { 'Disabled (OVERWRITES ORIGINAL!)' } else { 'Enabled' })" -ForegroundColor $(if ($NoVersionIncrement) { 'Red' } else { 'Green' })
    Write-Host ""
    
    # Validate output path if specified
    if ($OutputPath -and -not (Test-Path $OutputPath)) {
        Write-Host "Creating output directory: $OutputPath" -ForegroundColor Yellow
        New-Item -Path $OutputPath -ItemType Directory -Force -WhatIf:$false | Out-Null
    }
    
    $successCount = 0
    $failCount = 0
    
    # Function to increment version number in filename
    function Get-IncrementedFilename {
        param(
            [string]$FileName
        )
        
        # Remove extension
        $nameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($FileName)
        $extension = [System.IO.Path]::GetExtension($FileName)
        
        # Try to find version patterns: X.Y.Z or X.Y or just X at the end
        # Patterns to match (in order of specificity):
        # 1. Major.Minor.Patch (e.g., 1.2.3)
        # 2. Major.Minor (e.g., 1.2)
        # 3. Just version number at end (e.g., v5 or -5)
        
        # Pattern 1: X.Y.Z (most common)
        if ($nameWithoutExt -match '^(.+?)[-_\s]?(\d+)\.(\d+)\.(\d+)$') {
            $baseName = $matches[1]
            $major = $matches[2]
            $minor = $matches[3]
            $patch = [int]$matches[4]
            $newPatch = $patch + 1
            $separator = if ($nameWithoutExt -match '[-_\s](\d+\.\d+\.\d+)$') { $matches[0][0] } else { '' }
            return "$baseName$separator$major.$minor.$newPatch$extension"
        }
        # Pattern 2: X.Y
        elseif ($nameWithoutExt -match '^(.+?)[-_\s]?(\d+)\.(\d+)$') {
            $baseName = $matches[1]
            $major = $matches[2]
            $minor = [int]$matches[3]
            $newMinor = $minor + 1
            $separator = if ($nameWithoutExt -match '[-_\s](\d+\.\d+)$') { $matches[0][0] } else { '' }
            return "$baseName$separator$major.$newMinor$extension"
        }
        # Pattern 3: Just a number at the end
        elseif ($nameWithoutExt -match '^(.+?)[-_\s]?(\d+)$') {
            $baseName = $matches[1]
            $version = [int]$matches[2]
            $newVersion = $version + 1
            $separator = if ($nameWithoutExt -match '[-_\s]\d+$') { $matches[0][0] } else { '' }
            return "$baseName$separator$newVersion$extension"
        }
        # No version found - append .1
        else {
            return "$nameWithoutExt-1.0.1$extension"
        }
    }
}

process {
    foreach ($mission in $MissionPath) {
        try {
            # Resolve full path
            $missionFile = Resolve-Path $mission -ErrorAction Stop
            
            Write-Host "Processing: " -NoNewline -ForegroundColor White
            Write-Host "$missionFile" -ForegroundColor Cyan
            
            # Verify mission file exists and is a .miz file
            if (-not (Test-Path $missionFile)) {
                throw "Mission file not found: $missionFile"
            }
            
            if ([System.IO.Path]::GetExtension($missionFile) -ne ".miz") {
                throw "File is not a .miz mission file: $missionFile"
            }
            
            # Create temporary extraction directory
            $tempDir = Join-Path $env:TEMP ("DCS_Mission_Patch_" + [System.Guid]::NewGuid().ToString())
            New-Item -Path $tempDir -ItemType Directory -Force -WhatIf:$false | Out-Null
            
            try {
                # Extract mission file (it's a ZIP archive)
                # Use .NET classes instead of Expand-Archive for better .miz support
                Write-Host "  Extracting mission..." -ForegroundColor Gray
                
                Add-Type -Assembly System.IO.Compression.FileSystem
                [System.IO.Compression.ZipFile]::ExtractToDirectory($missionFile, $tempDir)
                
                # Determine Lua script destination in mission structure
                # DCS stores Lua scripts in: l10n/DEFAULT/ folder
                $luaDestDir = Join-Path $tempDir "l10n\DEFAULT"
                
                # Create directory if it doesn't exist
                if (-not (Test-Path $luaDestDir)) {
                    Write-Host "  Creating l10n/DEFAULT directory..." -ForegroundColor Yellow
                    New-Item -Path $luaDestDir -ItemType Directory -Force -WhatIf:$false | Out-Null
                }
                
                $luaDestPath = Join-Path $luaDestDir $ScriptName
                
                # Check if script already exists
                if (Test-Path $luaDestPath) {
                    Write-Host "  Replacing existing script: $ScriptName" -ForegroundColor Yellow
                } else {
                    Write-Host "  Adding new script: $ScriptName" -ForegroundColor Green
                }
                
                # Copy Lua script to mission
                Copy-Item $LuaScriptPath $luaDestPath -Force -WhatIf:$false
                
                # Determine output filename and location
                $originalFileName = Split-Path $missionFile -Leaf
                
                if ($NoVersionIncrement) {
                    # Keep original filename
                    $outputFileName = $originalFileName
                } else {
                    # Increment version number
                    $outputFileName = Get-IncrementedFilename -FileName $originalFileName
                    Write-Host "  Version increment: $originalFileName -> $outputFileName" -ForegroundColor Cyan
                }
                
                # Determine output directory
                if ($OutputPath) {
                    $outputDir = $OutputPath
                } else {
                    $outputDir = Split-Path $missionFile -Parent
                }
                
                $outputMission = Join-Path $outputDir $outputFileName
                
                # Remove existing mission file if it exists
                if (Test-Path $outputMission) {
                    Remove-Item $outputMission -Force -WhatIf:$false
                }
                
                # Repackage mission file
                Write-Host "  Repackaging mission..." -ForegroundColor Gray
                
                # Use .NET classes for better compatibility
                Add-Type -Assembly System.IO.Compression.FileSystem
                $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
                
                # Create ZIP manually to ensure proper path separators (forward slashes required by ZIP spec)
                # CreateFromDirectory uses backslashes on Windows which corrupts DCS mission files
                $zipStream = New-Object System.IO.FileStream($outputMission, [System.IO.FileMode]::Create)
                $archive = New-Object System.IO.Compression.ZipArchive($zipStream, [System.IO.Compression.ZipArchiveMode]::Create)
                
                try {
                    # Get all files in temp directory and add them to ZIP
                    $files = Get-ChildItem -Path $tempDir -Recurse -File
                    
                    foreach ($file in $files) {
                        # Get relative path for entry name
                        $relativePath = $file.FullName.Substring($tempDir.Length + 1)
                        # CRITICAL: Normalize path separators to forward slashes (ZIP standard)
                        # DCS will fail to load missions with backslashes in ZIP entry names
                        $entryName = $relativePath.Replace('\', '/')
                        
                        # Create entry in ZIP
                        $entry = $archive.CreateEntry($entryName, $compressionLevel)
                        
                        # Write file content to entry
                        $entryStream = $entry.Open()
                        try {
                            $fileStream = [System.IO.File]::OpenRead($file.FullName)
                            try {
                                $fileStream.CopyTo($entryStream)
                            }
                            finally {
                                $fileStream.Close()
                            }
                        }
                        finally {
                            $entryStream.Close()
                        }
                    }
                }
                finally {
                    $archive.Dispose()
                    $zipStream.Close()
                }
                
                Write-Host "  SUCCESS: Mission patched successfully!" -ForegroundColor Green
                Write-Host "  Output: $outputMission" -ForegroundColor Gray
                Write-Host ""
                
                $successCount++
            }
            finally {
                # Clean up temporary directory
                if (Test-Path $tempDir) {
                    Remove-Item $tempDir -Recurse -Force -WhatIf:$false
                }
            }
        }
        catch {
            Write-Host "  ERROR: $_" -ForegroundColor Red
            Write-Host ""c
            $failCount++
        }
    }
}

end {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Patching Complete" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Successful: $successCount" -ForegroundColor Green
    Write-Host "Failed: $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Gray" })
    Write-Host ""
    
    if ($successCount -gt 0) {
        if ($NoVersionIncrement) {
            Write-Host "WARNING: Original mission files were OVERWRITTEN!" -ForegroundColor Red
        } else {
            Write-Host "INFO: Original mission files remain untouched. New versioned files created." -ForegroundColor Green
        }
        Write-Host "TIP: Test your patched missions in DCS before using them!" -ForegroundColor Yellow
    }
}