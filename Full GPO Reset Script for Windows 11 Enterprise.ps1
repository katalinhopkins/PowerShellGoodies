<# 
    Full GPO Reset Script for Windows 11 Enterprise
    ------------------------------------------------
    - Resets Local Group Policy (Computer + User)
    - Resets Local Security Policy (secedit / defltbase.inf)
    - Clears cached domain GPOs (if present)
    - Removes registry-based policy keys (tattooed settings)
    - Generates a gpresult report for verification

    Run as: Administrator
#>

# region Safety & elevation check
Write-Host "=== Full Group Policy Reset (Windows 11 Enterprise) ===" -ForegroundColor Cyan

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as Administrator. Exiting." -ForegroundColor Red
    exit 1
}

# Optional: create a simple restore point-like backup note
Write-Host "Proceeding will reset ALL local Group Policy and security policy settings." -ForegroundColor Yellow
Write-Host "Press Ctrl+C to cancel, or Enter to continue..." -ForegroundColor Yellow
[void][System.Console]::ReadLine()
# endregion


# region Paths
$gpRoot          = Join-Path $env:WINDIR "System32"
$gpFolder        = Join-Path $gpRoot "GroupPolicy"
$gpUsersFolder   = Join-Path $gpRoot "GroupPolicyUsers"
$gpDataStore     = Join-Path $gpRoot "GroupPolicy\DataStore"
$infFolder       = Join-Path $env:WINDIR "inf"
$defltBaseInf    = Join-Path $infFolder "defltbase.inf"
$gpResultPath    = Join-Path $env:TEMP "GPO_Reset_gpresult.html"
# endregion


# region Reset Local Group Policy folders
Write-Host "`n[1/5] Resetting Local Group Policy folders..." -ForegroundColor Cyan

foreach ($path in @($gpFolder, $gpUsersFolder)) {
    if (Test-Path $path) {
        Write-Host "  Removing $path" -ForegroundColor DarkYellow
        try {
            Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
        } catch {
            Write-Host "  Failed to remove $path: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "  Not found: $path (already clean)" -ForegroundColor DarkGray
    }
}
# endregion


# region Reset Local Security Policy via secedit
Write-Host "`n[2/5] Resetting Local Security Policy (secedit / defltbase.inf)..." -ForegroundColor Cyan

if (Test-Path $defltBaseInf) {
    $seceditCmd = "secedit /configure /cfg `"$defltBaseInf`" /db defltbase.sdb /verbose"
    Write-Host "  Running: $seceditCmd" -ForegroundColor DarkYellow
    try {
        & secedit /configure /cfg $defltBaseInf /db defltbase.sdb /verbose
        Write-Host "  secedit completed. Check above for any errors." -ForegroundColor Green
    } catch {
        Write-Host "  secedit failed: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "  defltbase.inf not found at $defltBaseInf. Security policy reset skipped." -ForegroundColor Red
}
# endregion


# region Clear cached domain GPOs (if present)
Write-Host "`n[3/5] Clearing cached domain GPOs (DataStore)..." -ForegroundColor Cyan

if (Test-Path $gpDataStore) {
    Write-Host "  Removing $gpDataStore" -ForegroundColor DarkYellow
    try {
        Remove-Item -Path $gpDataStore -Recurse -Force -ErrorAction Stop
        Write-Host "  Domain GPO cache cleared." -ForegroundColor Green
    } catch {
        Write-Host "  Failed to clear DataStore: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "  No DataStore cache found (machine may be standalone or already clean)." -ForegroundColor DarkGray
}
# endregion


# region Remove registry-based policy keys (tattooed settings)
Write-Host "`n[4/5] Removing registry-based policy keys (tattooed settings)..." -ForegroundColor Cyan

$regPaths = @(
    "HKLM:\Software\Policies",
    "HKCU:\Software\Policies"
)

foreach ($regPath in $regPaths) {
    if (Test-Path $regPath) {
        Write-Host "  Deleting $regPath" -ForegroundColor DarkYellow
        try {
            Remove-Item -Path $regPath -Recurse -Force -ErrorAction Stop
            Write-Host "  Deleted $regPath" -ForegroundColor Green
        } catch {
            Write-Host "  Failed to delete $regPath: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "  Not found: $regPath (no tattooed policies here)" -ForegroundColor DarkGray
    }
}
# endregion


# region Force Group Policy update
Write-Host "`n[5/5] Forcing Group Policy update (gpupdate /force)..." -ForegroundColor Cyan

try {
    & gpupdate /force
    Write-Host "  gpupdate /force completed." -ForegroundColor Green
} catch {
    Write-Host "  gpupdate failed: $($_.Exception.Message)" -ForegroundColor Red
}
# endregion


# region Generate gpresult report
Write-Host "`nGenerating gpresult report for verification..." -ForegroundColor Cyan

try {
    & gpresult /h $gpResultPath
    Write-Host "  gpresult report saved to: $gpResultPath" -ForegroundColor Green
    Write-Host "  Open this file in a browser to review resultant policies." -ForegroundColor Yellow
} catch {
    Write-Host "  Failed to generate gpresult: $($_.Exception.Message)" -ForegroundColor Red
}
# endregion


Write-Host "`n=== Full Group Policy reset sequence completed. ===" -ForegroundColor Cyan
Write-Host "Recommended: Reboot the machine now to ensure all changes are fully applied." -ForegroundColor Yellow
