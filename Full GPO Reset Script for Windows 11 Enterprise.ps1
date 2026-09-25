<# 
    Full GPO Reset Script – Enterprise Debug + ACL Fix Edition
    ----------------------------------------------------------
    - Resets Local Group Policy (Computer + User)
    - Resets Local Security Policy (secedit / defltbase.inf)
    - Clears cached domain GPOs (if present)
    - Removes registry-based policy keys (with ACL fix)
    - Generates a gpresult report (overwrite-safe)
    - Deep debugging output for enterprise troubleshooting
#>

# region Elevation Check (Corrected + Debug)
Write-Host "=== [START] Full GPO Reset – Debug + ACL Fix Edition ===" -ForegroundColor Cyan

$startTime = Get-Date
Write-Host "[DEBUG] Script start time: $startTime"

Write-Host "[DEBUG] Checking elevation..." -ForegroundColor Cyan

$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator

if (-not ($principal.IsInRole($adminRole))) {
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


# region Remove Registry Policy Keys (ACL Fix)
Write-Host "`n=== [STEP 4] Remove Registry-Based Policy Keys (with ACL Fix) ===" -ForegroundColor Cyan

$regPaths = @(
    "HKLM:\Software\Policies",
    "HKCU:\Software\Policies"
)

foreach ($regPath in $regPaths) {

    Write-Host "[DEBUG] Checking registry path: $regPath"
    $existsBefore = Test-Path $regPath
    Write-Host "[DEBUG] Exists before delete: $existsBefore"

    if ($existsBefore) {

        Write-Host "[ACTION] Taking ownership of $regPath" -ForegroundColor DarkYellow
        try {
            $acl = Get-Acl $regPath
            $owner = New-Object System.Security.Principal.NTAccount("Administrators")
            $acl.SetOwner($owner)
            Set-Acl -Path $regPath -AclObject $acl
            Write-Host "[SUCCESS] Ownership changed to Administrators" -ForegroundColor Green
        } catch {
            Write-Host "[ERROR] Ownership change failed" -ForegroundColor Red
            Write-Host "[EXCEPTION] ${($_.Exception.Message)}"
        }

        Write-Host "[ACTION] Granting Administrators FullControl on $regPath" -ForegroundColor DarkYellow
        try {
            $rule = New-Object System.Security.AccessControl.RegistryAccessRule(
                "Administrators",
                "FullControl",
                "ContainerInherit,ObjectInherit",
                "None",
                "Allow"
            )
            $acl = Get-Acl $regPath
            $acl.SetAccessRule($rule)
            Set-Acl -Path $regPath -AclObject $acl
            Write-Host "[SUCCESS] ACL updated" -ForegroundColor Green
        } catch {
            Write-Host "[ERROR] ACL update failed" -ForegroundColor Red
            Write-Host "[EXCEPTION] ${($_.Exception.Message)}"
        }

        Write-Host "[ACTION] Deleting registry key: $regPath" -ForegroundColor DarkYellow
        try {
            Remove-Item -Path $regPath -Recurse -Force -ErrorAction Stop
            Write-Host "[SUCCESS] Deleted: $regPath" -ForegroundColor Green
        } catch {
            Write-Host "[ERROR] Delete failed even after ACL fix" -ForegroundColor Red
            Write-Host "[EXCEPTION] ${($_.Exception.Message)}"

            Write-Host "[ACTION] Attempting fallback deletion via .NET Registry API" -ForegroundColor DarkYellow
            try {
                $hive, $subkey = $regPath.Split(":\", 2)
                $root = switch ($hive) {
                    "HKLM" { [Microsoft.Win32.Registry]::LocalMachine }
                    "HKCU" { [Microsoft.Win32.Registry]::CurrentUser }
                }
                $root.DeleteSubKeyTree($subkey)
                Write-Host "[SUCCESS] Deleted via .NET API: $regPath" -ForegroundColor Green
            } catch {
                Write-Host "[ERROR] .NET fallback deletion failed" -ForegroundColor Red
                Write-Host "[EXCEPTION] ${($_.Exception.Message)}"
            }
        }

    } else {
        Write-Host "[DEBUG] Registry key not found: $regPath"
    }

    $existsAfter = Test-Path $regPath
    Write-Host "[DEBUG] Exists after delete: $existsAfter"
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


# region gpresult (Overwrite-Safe)
Write-Host "`n=== [STEP 6] Generate gpresult Report ===" -ForegroundColor Cyan

Write-Host "[DEBUG] Checking if gpresult file already exists: $gpResultPath"
if (Test-Path $gpResultPath) {
    Write-Host "[DEBUG] Existing gpresult file detected. Removing..." -ForegroundColor DarkYellow
    try {
        Remove-Item -Path $gpResultPath -Force -ErrorAction Stop
        Write-Host "[SUCCESS] Old gpresult file removed." -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Failed to remove existing gpresult file." -ForegroundColor Red
        Write-Host "[EXCEPTION] ${($_.Exception.Message)}"
        Write-Host "[INFO] Proceeding with gpresult /f overwrite anyway." -ForegroundColor Yellow
    }
}

try {
    Write-Host "[ACTION] Generating gpresult report (forced overwrite)..." -ForegroundColor DarkYellow
    gpresult /h $gpResultPath /f
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
