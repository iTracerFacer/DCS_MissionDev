# Download latest Moose_.lua from GitHub

[CmdletBinding()]
param(
    # Destination path for Moose_.lua. If not provided, defaults to repo root alongside Patch-MooseMissions folder
    [Parameter(Mandatory=$false)]
    [string]$MooseLuaPath,

    # Use -Force to actually download; otherwise runs in WhatIf/preview mode
    [Parameter(Mandatory=$false)]
    [switch]$Force
)

# Resolve a robust script root that works even when dot-sourced or in older hosts
$__scriptRoot = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($__scriptRoot)) {
    try { $__scriptRoot = Split-Path -Parent $PSCommandPath } catch {}
}
if ([string]::IsNullOrWhiteSpace($__scriptRoot)) {
    try { $__scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path } catch {}
}

# If destination wasn't provided, default to the repo root (parent of Patch-MooseMissions)
if ([string]::IsNullOrWhiteSpace($MooseLuaPath)) {
    $parentOfScriptRoot = $__scriptRoot
    if (-not [string]::IsNullOrWhiteSpace($parentOfScriptRoot)) {
        try { $parentOfScriptRoot = Split-Path -Path $parentOfScriptRoot -Parent } catch { $parentOfScriptRoot = $null }
    }
    if ([string]::IsNullOrWhiteSpace($parentOfScriptRoot)) {
        # Final fallback: current directory
        $parentOfScriptRoot = (Get-Location).Path
    }
    $MooseLuaPath = Join-Path -Path $parentOfScriptRoot -ChildPath 'Moose_.lua'
}

# Determine WhatIf mode (preview by default)
$runInWhatIfMode = -not $Force

# Ensure destination directory exists (avoid null/invalid path issues)
if ([string]::IsNullOrWhiteSpace($MooseLuaPath)) {
    throw "Destination path for Moose_.lua is empty. Provide -MooseLuaPath."
}

$destDir = Split-Path -Path $MooseLuaPath -Parent
if (-not [string]::IsNullOrWhiteSpace($destDir) -and -not (Test-Path $destDir)) {
    New-Item -Path $destDir -ItemType Directory -Force -WhatIf:$false | Out-Null
}

# Enable TLS 1.2 for GitHub downloads on older environments
try {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
} catch {}

if (-not $runInWhatIfMode) {
    Write-Host "Downloading latest Moose_.lua from GitHub..." -ForegroundColor Yellow

    $mooseGitHubUrl = "https://raw.githubusercontent.com/FlightControl-Master/MOOSE_INCLUDE/develop/Moose_Include_Static/Moose_.lua"
    $backupPath = "$MooseLuaPath.backup"

    try {
        # Create a single backup of existing Moose_.lua if it exists and backup doesn't exist yet
        if ((Test-Path $MooseLuaPath) -and -not (Test-Path $backupPath)) {
            Write-Host "  Creating backup: $backupPath" -ForegroundColor Gray
            Copy-Item $MooseLuaPath $backupPath -Force -WhatIf:$false
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