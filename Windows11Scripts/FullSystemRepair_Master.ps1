# ============================================================
# FULL SYSTEM REPAIR - MASTER SCRIPT
# Loads all SECTION scripts and exposes unified execution
# This calls the orchestrator inside SECTION 9, which then calls:
# Manifest processing
# Core service reset
# Duplicate per‑user cleanup
# Third‑party cleanup
# WMI repair
# Windows Update repair
# Credential Provider repair
# All with your logging framework active.

# ============================================================

<#
 1. Run the master script
 .\FullSystemRepair_Master.ps1
 2. Execute the full repair
 Invoke-FullSystemRepair
#>

# ============================================================

cd D:\GitHub\PowerShellGoodies\Windows11Scripts

# Base path where your SECTION scripts live
$basePath = "D:\GitHub\PowerShellGoodies\Windows11Scripts"

# List of SECTION files in correct order
$sections = @(
    "SECTION 1 - LOGGING FRAMEWORK.ps1",
    "SECTION 2 - MANIFEST PROCESSING SUBSYSTEM.ps1",
    "SECTION 3 - CORE WINDOWS SERVICE RESET SUBSYSTEM.ps1",
    "SECTION 4 - DUPLICATE PER-USER SERVICE CLEANUP SUBSYSTEM.ps1",
    "SECTION 5 - THIRD-PARTY SERVICE REMOVAL SUBSYSTEM.ps1",
    "SECTION 6 - WMI REPOSITORY REPAIR SUBSYSTEM.ps1",
    "SECTION 7 - WINDOWS UPDATE REPAIR SUBSYSTEM.ps1",
    "SECTION 8 - CREDENTIAL PROVIDER REPAIR SUBSYSTEM.ps1",
    "SECTION 9 - MAIN EXECUTION BLOCK (FINAL ASSEMBLY).ps1"
)

Write-Host "Loading subsystem modules..." -ForegroundColor Cyan

foreach ($file in $sections)
{
    $fullPath = Join-Path $basePath $file

    if (Test-Path $fullPath)
    {
        Write-Host "Importing: $file" -ForegroundColor White
        . $fullPath
    }#end if block
    else
    {
        Write-Host "ERROR: Missing file → $file" -ForegroundColor Red
    }#end else block
}#end foreach block

Write-Host "All subsystem modules loaded." -ForegroundColor Green


# ============================================================
# PROGRESS + STOPWATCH + SUMMARY ENGINE
# ============================================================

# Ordered list of subsystem names for progress tracking
$Subsystems = @(
    "Manifest Processing",
    "Core Windows Service Reset",
    "Duplicate Per-User Cleanup",
    "Third-Party Service Removal",
    "WMI Repository Repair",
    "Windows Update Repair",
    "Credential Provider Repair"
)

# Hashtable to store elapsed times
$RuntimeSummary = @{}

function Start-SubsystemTimer
{
    param([string]$Name)

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $RuntimeSummary[$Name] = $sw
}#end function Start-SubsystemTimer

function Stop-SubsystemTimer
{
    param([string]$Name)

    $RuntimeSummary[$Name].Stop()
}#end function Stop-SubsystemTimer

function Show-Progress
{
    param(
        [int]$Index,
        [string]$Name
    )

    $percent = [math]::Round(($Index / $Subsystems.Count) * 100)
    $elapsed = $RuntimeSummary[$Name].Elapsed.ToString("hh\:mm\:ss")

    Write-Host "[$percent%] $Name (Elapsed: $elapsed)" -ForegroundColor Cyan
}#end function Show-Progress

function Show-FinalRuntimeSummary
{
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Yellow
    Write-Host "FULL RUNTIME SUMMARY" -ForegroundColor Yellow
    Write-Host "------------------------------------------------------------" -ForegroundColor Yellow

    $total = [System.TimeSpan]::Zero

    foreach ($key in $RuntimeSummary.Keys)
    {
        $elapsed = $RuntimeSummary[$key].Elapsed
        $total += $elapsed

        Write-Host ("{0,-35} {1}" -f $key, $elapsed.ToString("hh\:mm\:ss")) -ForegroundColor White
    }

    Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
    Write-Host ("TOTAL RUNTIME:{0,30}" -f $total.ToString("hh\:mm\:ss")) -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Yellow
}#end function Show-FinalRuntimeSummary


# ============================================================
# DISM HEARTBEAT MONITOR
# ============================================================

function Start-DISMHeartbeat
{
    param(
        [int]$IntervalSeconds = 30,
        [int]$IdleThresholdSeconds = 300   # 5 minutes
    )

    Log -Level "INFO" -Category "DISMHeartbeat" -Operation "Start" -Message "DISM heartbeat monitor activated."

    $lastCpu = 0
    $lastMem = 0
    $lastHandles = 0
    $lastChange = Get-Date

    while ($true)
    {
        $proc = Get-Process -Name dism -ErrorAction SilentlyContinue

        if (-not $proc)
        {
            Log -Level "INFO" -Category "DISMHeartbeat" -Operation "Stop" -Message "DISM process ended. Heartbeat monitor stopping."
            break
        }

        $cpu = $proc.CPU
        $mem = $proc.WorkingSet64
        $handles = $proc.Handles

        Log -Level "INFO" -Category "DISMHeartbeat" -Operation "Heartbeat" -Message "CPU: $cpu  WS(K): $([math]::Round($mem/1KB))  Handles: $handles"

        # Detect idle state
        if ($cpu -ne $lastCpu -or $mem -ne $lastMem -or $handles -ne $lastHandles)
        {
            # DISM is doing work
            $lastChange = Get-Date
        }
        else
        {
            # DISM unchanged � check idle duration
            $idleTime = (Get-Date) - $lastChange

            if ($idleTime.TotalSeconds -ge $IdleThresholdSeconds)
            {
                Log -Level "WARN" -Category "DISMHeartbeat" -Operation "IdleWarning" -Message "DISM has been idle for $($idleTime.TotalMinutes.ToString('0.0')) minutes."
            }
        }

        $lastCpu = $cpu
        $lastMem = $mem
        $lastHandles = $handles

        Start-Sleep -Seconds $IntervalSeconds
    }#end while block
}#end function Start-DISMHeartbeat


# ============================================================
# Unified Execution Function
# ============================================================

function Invoke-FullSystemRepair
{
    Write-Host "Executing full Windows 11 Enterprise 25H2 repair sequence..." -ForegroundColor Magenta

    try
    {
        Run-FullSystemRepair

        Write-Host "Full repair sequence completed successfully." -ForegroundColor Green
    }#end try block
    catch
    {
        Write-Host "Critical failure during full repair sequence." -ForegroundColor Red
        Write-Host $_ -ForegroundColor DarkRed
    }#end catch block
}#end function Invoke-FullSystemRepair

Write-Host "Master script initialized. Use Invoke-FullSystemRepair to begin." -ForegroundColor Cyan

Invoke-FullSystemRepair
