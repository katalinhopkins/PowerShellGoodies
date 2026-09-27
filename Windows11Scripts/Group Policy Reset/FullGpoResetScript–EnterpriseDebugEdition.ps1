<# 
    FullGpoResetScript–EnterpriseDebugEdition

    Full GPO Reset Script – Enterprise Debug Edition
    ------------------------------------------------
    - Adds deep debugging outputs
    - Tracks pre/post state for each action
    - Logs exceptions with full detail
    - Uses ${()} for safe variable expansion
#>

# region Elevation Check
Write-Host "=== [START] Full GPO Reset – Debug Edition ===" -ForegroundColor Cyan

$startTime = Get-Date
Write-Host "[DEBUG] Script start time: $startTime"

if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole( `
    [Security.Principal.WindowsBuiltInRole] "Administrator")) 
    { 

    Write-Host "[ERROR] Script must run as Administrator." -ForegroundColor Red
    exit 1
}

Write-Host "[DEBUG] Elevation confirmed." -ForegroundColor Green
# endregion


# region Paths
$gpRoot          = Join-Path $env:WINDIR "System32"
$gpFolder        = Join-Path $gpRoot "GroupPolicy"
$gpUsersFolder   = Join-Path $gpRoot "GroupPolicyUsers"
$gpDataStore     = Join-Path $gpRoot "GroupPolicy\DataStore"
$infFolder       = Join-Path $env:WINDIR "inf"
$defltBaseInf    = Join-Path $infFolder "defltbase.inf"
$gpResultPath    = Join-Path $env:TEMP "GPO_Reset_gpresult.html"

Write-Host "[DEBUG] Paths initialized:"
Write-Host "        gpFolder      = $gpFolder"
Write-Host "        gpUsersFolder = $gpUsersFolder"
Write-Host "        gpDataStore   = $gpDataStore"
Write-Host "        defltBaseInf  = $defltBaseInf"
Write-Host "        gpResultPath  = $gpResultPath"
# endregion


# region Reset Local Group Policy
Write-Host "`n=== [STEP 1] Reset Local Group Policy Folders ===" -ForegroundColor Cyan

foreach ($path in @($gpFolder, $gpUsersFolder)) {

    Write-Host "[DEBUG] Checking existence: $path"
    $existsBefore = Test-Path $path
    Write-Host "[DEBUG] Exists before delete: $existsBefore"

    if ($existsBefore) {
        Write-Host "[ACTION] Removing: $path" -ForegroundColor DarkYellow
        try {
            Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
            Write-Host "[SUCCESS] Removed: $path" -ForegroundColor Green
        } catch {
            Write-Host "[ERROR] Failed to remove $path" -ForegroundColor Red
            Write-Host "[EXCEPTION] ${($_.Exception.Message)}"
        }
    } else {
        Write-Host "[DEBUG] Path not found: $path"
    }

    $existsAfter = Test-Path $path
    Write-Host "[DEBUG] Exists after delete: $existsAfter"
}
# endregion


# region Reset Local Security Policy
Write-Host "`n=== [STEP 2] Reset Local Security Policy (secedit) ===" -ForegroundColor Cyan

Write-Host "[DEBUG] Checking defltbase.inf: $defltBaseInf"
if (Test-Path $defltBaseInf) {

    Write-Host "[ACTION] Running secedit baseline restore..." -ForegroundColor DarkYellow
    try {
        & secedit /configure /cfg $defltBaseInf /db defltbase.sdb /verbose
        Write-Host "[SUCCESS] secedit baseline applied." -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] secedit failed." -ForegroundColor Red
        Write-Host "[EXCEPTION] ${($_.Exception.Message)}"
    }

} else {
    Write-Host "[ERROR] defltbase.inf missing. Security policy reset skipped." -ForegroundColor Red
}
# endregion


# region Clear Domain GPO Cache
Write-Host "`n=== [STEP 3] Clear Cached Domain GPOs ===" -ForegroundColor Cyan

Write-Host "[DEBUG] Checking DataStore: $gpDataStore"
$dsExistsBefore = Test-Path $gpDataStore
Write-Host "[DEBUG] Exists before delete: $dsExistsBefore"

if ($dsExistsBefore) {
    Write-Host "[ACTION] Removing DataStore..." -ForegroundColor DarkYellow
    try {
        Remove-Item -Path $gpDataStore -Recurse -Force -ErrorAction Stop
        Write-Host "[SUCCESS] Domain GPO cache cleared." -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Failed to clear DataStore." -ForegroundColor Red
        Write-Host "[EXCEPTION] ${($_.Exception.Message)}"
    }
} else {
    Write-Host "[DEBUG] No DataStore found."
}

$dsExistsAfter = Test-Path $gpDataStore
Write-Host "[DEBUG] Exists after delete: $dsExistsAfter"
# endregion


# region Remove Registry Policy Keys
Write-Host "`n=== [STEP 4] Remove Registry-Based Policy Keys ===" -ForegroundColor Cyan

$regPaths = @(
    "HKLM:\Software\Policies",
    "HKCU:\Software\Policies"
)

foreach ($regPath in $regPaths) {

    Write-Host "[DEBUG] Checking registry path: $regPath"
    $regExistsBefore = Test-Path $regPath
    Write-Host "[DEBUG] Exists before delete: $regExistsBefore"

    if ($regExistsBefore) {
        Write-Host "[ACTION] Deleting registry key: $regPath" -ForegroundColor DarkYellow
        try {
            Remove-Item -Path $regPath -Recurse -Force -ErrorAction Stop
            Write-Host "[SUCCESS] Deleted: $regPath" -ForegroundColor Green
        } catch {
            Write-Host "[ERROR] Failed to delete $regPath" -ForegroundColor Red
            Write-Host "[EXCEPTION] ${($_.Exception.Message)}"
        }
    } else {
        Write-Host "[DEBUG] Registry key not found: $regPath"
    }

    $regExistsAfter = Test-Path $regPath
    Write-Host "[DEBUG] Exists after delete: $regExistsAfter"
}
# endregion


# region gpupdate
Write-Host "`n=== [STEP 5] Force Group Policy Update ===" -ForegroundColor Cyan

try {
    Write-Host "[ACTION] Running gpupdate /force..." -ForegroundColor DarkYellow
    $gpupdateOutput = gpupdate /force
    Write-Host "[SUCCESS] gpupdate completed." -ForegroundColor Green
    Write-Host "[DEBUG OUTPUT] $gpupdateOutput"
} catch {
    Write-Host "[ERROR] gpupdate failed." -ForegroundColor Red
    Write-Host "[EXCEPTION] ${($_.Exception.Message)}"
}
# endregion


# region gpresult
Write-Host "`n=== [STEP 6] Generate gpresult Report ===" -ForegroundColor Cyan

try {
    Write-Host "[ACTION] Generating gpresult report..." -ForegroundColor DarkYellow
    gpresult /h $gpResultPath
    Write-Host "[SUCCESS] gpresult saved to: $gpResultPath" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] gpresult failed." -ForegroundColor Red
    Write-Host "[EXCEPTION] ${($_.Exception.Message)}"
}
# endregion


# region End
$endTime = Get-Date
$duration = ($endTime - $startTime)

Write-Host "`n=== [COMPLETE] Full GPO Reset Finished ===" -ForegroundColor Cyan
Write-Host "[DEBUG] End time: $endTime"
Write-Host "[DEBUG] Duration: $duration"
Write-Host "[INFO] Reboot recommended." -ForegroundColor Yellow
# endregion
