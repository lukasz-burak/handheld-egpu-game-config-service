# =========================================================
# ROG ALLY X - AUTOMATED GPU CONFIG SWAPPER (EVENT DRIVEN)
# =========================================================

# --- CONFIGURATION (EDIT THESE PATHS) ---

# 1. The keyword to identify your eGPU (Check Device Manager > Display Adapters)
#    Common examples: "NVIDIA", "RTX", "RX 7600", "XG Mobile"
$eGPUKeyword = "NVIDIA"

# 2. LIST OF GAMES (Add your games here)
#    Copy the block from @{ to }, to add a new game.
$Games = @(
    @{
        Name = "Cyberpunk 2077"
        Destination = "C:\Users\YourUser\AppData\Local\CD Projekt Red\Cyberpunk 2077"
        HandheldSource = "C:\Configs\Cyberpunk\Handheld"
        DockedSource = "C:\Configs\Cyberpunk\Docked"
    },
    @{
        Name = "Elden Ring"
        Destination = "C:\Users\YourUser\AppData\Roaming\EldenRing"
        HandheldSource = "C:\Configs\EldenRing\Handheld"
        DockedSource = "C:\Configs\EldenRing\Docked"
    }
    # Add more games here if needed...
)

# =========================================================
# SCRIPT LOGIC (DO NOT EDIT BELOW)
# =========================================================

param (
    [switch]$Monitor
)

Function Get-GpuStatus {
    $videoCards = Get-CimInstance Win32_VideoController
    foreach ($card in $videoCards) {
        if ($card.Name -match $eGPUKeyword) {
            return $true
        }
    }
    return $false
}

Function Apply-Settings {
    param ([bool]$isDocked)

    if ($isDocked) {
        Write-Host "`n[DETECTED] eGPU connected. Switching to DOCKED mode..." -ForegroundColor Green
    } else {
        Write-Host "`n[NOT DETECTED] eGPU disconnected. Switching to HANDHELD mode..." -ForegroundColor Magenta
    }

    foreach ($game in $Games) {
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

# 1. Initial Check (Run immediately on start)
Write-Host "Performing initial check..." -ForegroundColor Cyan
$currentStatus = Get-GpuStatus
Apply-Settings -isDocked $currentStatus

# 2. Event Monitor Mode
if ($Monitor) {
    Write-Host "`nEntering Passive Monitor Mode..." -ForegroundColor Cyan
    Write-Host "Waiting for hardware events (0% CPU usage)..." -ForegroundColor Gray

    # Unregister old events if script crashed previously
    Unregister-Event -SourceIdentifier "HardwareChange" -ErrorAction SilentlyContinue

    # Register for Windows PnP Device Events (Arrival or Removal)
    # EventType 2 = Device Arrival, EventType 3 = Device Removal
    $wmiQuery = "SELECT * FROM Win32_DeviceChangeEvent WHERE EventType = 2 OR EventType = 3"
    Register-WmiEvent -Query $wmiQuery -SourceIdentifier "HardwareChange" | Out-Null

    $lastStatus = $currentStatus

    while ($true) {
        # This command pauses the script entirely until Windows signals an event
        Wait-Event -SourceIdentifier "HardwareChange" | Out-Null

        Write-Host "`nHardware change detected! Waiting 5s for drivers to settle..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5

        # Clear the event queue (because one plug-in causes multiple events)
        Get-Event -SourceIdentifier "HardwareChange" | Remove-Event

        # Check status again
        $newStatus = Get-GpuStatus

        if ($newStatus -ne $lastStatus) {
            Apply-Settings -isDocked $newStatus
            $lastStatus = $newStatus
        } else {
            Write-Host "No GPU change detected. (Event was unrelated)" -ForegroundColor DarkGray
        }
    }
}
else {
    Write-Host "`nDone. (Run with -Monitor to keep running in background)" -ForegroundColor Gray
    Start-Sleep -Seconds 3
}