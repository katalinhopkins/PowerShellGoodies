# Windows 11 Enterprise 25H2 — Full Service Reset Script (Verbose Debug Edition)
# ============================================================
# Windows 11 Enterprise 25H2 Service Reset Script (Verbose)
# ============================================================

$logFile = "C:\ServiceReset_25H2_DebugLog_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

function Log {
    param([string]$msg)
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $entry = "$timestamp :: $msg"
    Write-Host $entry
    Add-Content -Path $logFile -Value $entry
}

Log "=== BEGIN Windows 11 Enterprise 25H2 Service Reset ==="
Log "Debug log file: $logFile"

# ------------------------------------------------------------
# 1. Re-register all service manifests
# ------------------------------------------------------------
Log "Scanning service manifests..."
$manifests = Get-ChildItem "C:\Windows\servicing\Packages" -Filter *.mum

foreach ($m in $manifests) {
    Log "Processing manifest: $($m.Name)"
    try {
        dism /online /add-package /packagepath:$m.FullName /quiet
        Log "SUCCESS: Manifest applied: $($m.Name)"
    } catch {
        Log "ERROR: Failed to apply manifest: $($m.Name) :: $_"
    }
}

# ------------------------------------------------------------
# 2. Reset core Windows services to default startup types
# ------------------------------------------------------------
Log "Resetting core Windows services to 25H2 defaults..."

$defaults = @{
    "wuauserv" = "manual"
    "bits" = "delayed-auto"
    "cryptsvc" = "auto"
    "eventlog" = "auto"
    "themes" = "auto"
    "profsvc" = "auto"
    "gpsvc" = "auto"
    "winmgmt" = "auto"
    "lanmanworkstation" = "auto"
    "lanmanserver" = "auto"
    "dhcp" = "auto"
    "dnscache" = "auto"
    "bfe" = "auto"
    "mpssvc" = "auto"
    "tokenbroker" = "manual"
    "clipsvc" = "manual"
    "appxsvc" = "manual"
    "sppsvc" = "delayed-auto"
    "wsearch" = "delayed-auto"
    "wlansvc" = "auto"
    "dot3svc" = "manual"
    "scardsvr" = "manual"
    "camsvc" = "manual"
    "diagnosticshub.standardcollector.service" = "manual"
}

foreach ($svc in $defaults.Keys) {
    Log "Attempting to reset service: $svc → $($defaults[$svc])"
    try {
        Set-Service -Name $svc -StartupType $defaults[$svc]
        Log "SUCCESS: Startup type set for $svc"
    } catch {
        Log "ERROR: Service not found or failed to update: $svc :: $_"
    }
}

# ------------------------------------------------------------
# 3. Remove duplicated per-user services
# ------------------------------------------------------------
Log "Scanning for duplicated per-user services..."

$dupServices = Get-Service | Where-Object { $_.Name -match "_[0-9a-f]{6}$" }

foreach ($svc in $dupServices) {
    Log "Removing duplicate user service: $($svc.Name)"
    try {
        sc.exe delete $svc.Name | Out-Null
        Log "SUCCESS: Deleted $($svc.Name)"
    } catch {
        Log "ERROR: Failed to delete $($svc.Name) :: $_"
    }
}

# ------------------------------------------------------------
# 4. Remove third-party services
# ------------------------------------------------------------
Log "Removing third-party services..."

$thirdParty = @(
    "ExpressVPNService",
    "ExpressVPNUpdate",
    "Fing.Agent",
    "TechSmithUploaderService",
    "AdobeUpdateService",
    "AdobeARMservice",
    "GoogleUpdaterService",
    "GoogleUpdaterInternalService",
    "Everything",
    "LGUWPService",
    "MaximAudioService",
    "RealtekAudioUniversalService",
    "DolbyDAXAPI"
)

foreach ($svc in $thirdParty) {
    Log "Checking for third-party service: $svc"
    if (Get-Service -Name $svc -ErrorAction SilentlyContinue) {
        Log "Removing service: $svc"
        try {
            sc.exe delete $svc | Out-Null
            Log "SUCCESS: Deleted $svc"
        } catch {
            Log "ERROR: Failed to delete $svc :: $_"
        }
    } else {
        Log "INFO: Service not present: $svc"
    }
}

# ------------------------------------------------------------
# 5. Rebuild WMI repository
# ------------------------------------------------------------
Log "Rebuilding WMI repository..."

try {
    winmgmt /verifyrepository | Out-Null
    Log "WMI verifyrepository completed."

    winmgmt /salvagerepository | Out-Null
    Log "WMI salvagerepository completed."
} catch {
    Log "ERROR: WMI repair failed :: $_"
}

# ------------------------------------------------------------
# 6. Reset Windows Update stack
# ------------------------------------------------------------
Log "Resetting Windows Update components..."

try {
    Stop-Service wuauserv -Force
    Log "Stopped wuauserv"

    Stop-Service bits -Force
    Log "Stopped bits"

    Remove-Item -Recurse -Force C:\Windows\SoftwareDistribution
    Log "Deleted SoftwareDistribution"

    Remove-Item -Recurse -Force C:\Windows\System32\catroot2
    Log "Deleted catroot2"

    Start-Service wuauserv
    Log "Started wuauserv"

    Start-Service bits
    Log "Started bits"

    Log "SUCCESS: Windows Update reset completed."
} catch {
    Log "ERROR: Windows Update reset failed :: $_"
}

# ------------------------------------------------------------
# 7. Re-register Credential Provider framework
# ------------------------------------------------------------
Log "Re-registering Credential Provider framework..."

try {
    regsvr32 /s credprovhost.dll
    Log "Registered credprovhost.dll"

    regsvr32 /s credui.dll
    Log "Registered credui.dll"

    Log "SUCCESS: Credential Provider framework repaired."
} catch {
    Log "ERROR: Credential Provider re-registration failed :: $_"
}

Log "=== SERVICE RESET COMPLETE — REBOOT REQUIRED ==="
