# =========================================================
# ROG ALLY X - AUTOMATED GPU CONFIG SWAPPER (JSON EDITION)
# =========================================================

# Define the path to the JSON config file (Same folder as script)
$JsonPath = Join-Path $PSScriptRoot "games.json"

param (
    [switch]$Monitor
)

# --- HELPER FUNCTIONS ---

Function Get-Config {
    if (Test-Path $JsonPath) {
        try {
            $rawJson = Get-Content -Raw -Path $JsonPath -ErrorAction Stop
            return ($rawJson | ConvertFrom-Json)
        }
        catch {
            Write-Host "[ERROR] Could not parse games.json. Please check your syntax (commas, brackets)." -ForegroundColor Red
            return $null
        }
    }
    else {
        Write-Host "[ERROR] games.json not found in $PSScriptRoot" -ForegroundColor Red
        return $null
    }
}

Function Get-GpuStatus {
    param ($keyword)
    if ([string]::IsNullOrWhiteSpace($keyword)) { return $false }

    $videoCards = Get-CimInstance Win32_VideoController
    foreach ($card in $videoCards) {
        if ($card.Name -match $keyword) {
            return $true
        }
    }
    return $false
}

Function Apply-Settings {
    param ([bool]$isDocked)
    
    # Reload Config every time settings are applied (Hot-Reload)
    $Config = Get-Config
    if (-not $Config) { return }

    if ($isDocked) {
        Write-Host "`n[DETECTED] eGPU ($($Config.eGPUKeyword)) connected. Switching to DOCKED mode..." -ForegroundColor Green
    } else {
        Write-Host "`n[NOT DETECTED] eGPU disconnected. Switching to HANDHELD mode..." -ForegroundColor Magenta
    }

    foreach ($game in $Config.Games) {
        $source = if ($isDocked) { $game.DockedSource } else { $game.HandheldSource }
        
        if (Test-Path $source) {
            Copy-Item -Path "$source\*" -Destination "$($game.Destination)" -Recurse -Force
            Write-Host "  -> Updated: $($game.Name)" -ForegroundColor Gray
        } else {
             Write-Host "  -> [ERROR] Source path not found: $source" -ForegroundColor Red
        }
    }
}

# --- MAIN EXECUTION ---

# Load config initially to get the keyword
$InitialConfig = Get-Config
if (-not $InitialConfig) {
    Write-Host "Script cannot start without valid config."
    Start-Sleep -Seconds 10
    Exit
}

# 1. Initial Check (Run immediately on start)
Write-Host "Performing initial check..." -ForegroundColor Cyan
$currentStatus = Get-GpuStatus -keyword $InitialConfig.eGPUKeyword
Apply-Settings -isDocked $currentStatus

# 2. Event Monitor Mode
if ($Monitor) {
    Write-Host "`nEntering Passive Monitor Mode..." -ForegroundColor Cyan
    Write-Host "Waiting for hardware events (0% CPU usage)..." -ForegroundColor Gray
    
    # Unregister old events if script crashed previously
    Unregister-Event -SourceIdentifier "HardwareChange" -ErrorAction SilentlyContinue
    
    # Register for Windows PnP Device Events (Arrival or Removal)
    $wmiQuery = "SELECT * FROM Win32_DeviceChangeEvent WHERE EventType = 2 OR EventType = 3"
    Register-WmiEvent -Query $wmiQuery -SourceIdentifier "HardwareChange" | Out-Null
    
    $lastStatus = $currentStatus

    while ($true) {
        # Sleep unti Windows signals an event
        Wait-Event -SourceIdentifier "HardwareChange" | Out-Null
        
        Write-Host "`nHardware change detected! Waiting 5s for drivers to settle..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
        
        # Clear queue
        Get-Event -SourceIdentifier "HardwareChange" | Remove-Event
        
        # Reload config to get potentially updated Keyword
        $RuntimeConfig = Get-Config
        if ($RuntimeConfig) {
            $newStatus = Get-GpuStatus -keyword $RuntimeConfig.eGPUKeyword
            
            if ($newStatus -ne $lastStatus) {
                Apply-Settings -isDocked $newStatus
                $lastStatus = $newStatus
            } else {
                 Write-Host "No GPU change detected. (Event was unrelated)" -ForegroundColor DarkGray
            }
        }
    }
}
else {
    Write-Host "`nDone. (Run with -Monitor to keep running in background)" -ForegroundColor Gray
    Start-Sleep -Seconds 3
}
