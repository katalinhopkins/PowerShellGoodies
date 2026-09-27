#Windows 11 Enterprise 25H2 Service Reset Script
# ================================
# Windows 11 Enterprise 25H2
# Full Service Reset Script
# ================================

Write-Host "Resetting Windows services to 25H2 defaults..." -ForegroundColor Cyan

# --- 1. Re-register all service manifests ---
$manifests = Get-ChildItem "C:\Windows\servicing\Packages" -Filter *.mum
foreach ($m in $manifests) {
    try {
        dism /online /add-package /packagepath:$m.FullName /quiet
    } catch {
        Write-Host "Skipped manifest: $($m.Name)"
    }
}

# --- 2. Reset core Windows services to default startup types ---
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
    try {
        Set-Service -Name $svc -StartupType $defaults[$svc]
        Write-Host "Reset $svc"
    } catch {
        Write-Host "Service not found: $svc"
    }
}

# --- 3. Remove duplicated per-user services ---
Get-Service | Where-Object { $_.Name -match "_[0-9a-f]{6}$" } | ForEach-Object {
    Write-Host "Removing duplicate user service: $($_.Name)"
    sc.exe delete $_.Name
}

# --- 4. Remove third-party services safely ---
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
    if (Get-Service -Name $svc -ErrorAction SilentlyContinue) {
        Write-Host "Removing third-party service: $svc"
        sc.exe delete $svc
    }
}

# --- 5. Rebuild WMI repository ---
Write-Host "Rebuilding WMI repository..."
winmgmt /verifyrepository
winmgmt /salvagerepository

# --- 6. Reset Windows Update stack ---
Write-Host "Resetting Windows Update..."
Stop-Service wuauserv -Force
Stop-Service bits -Force
Remove-Item -Recurse -Force C:\Windows\SoftwareDistribution
Remove-Item -Recurse -Force C:\Windows\System32\catroot2
Start-Service wuauserv
Start-Service bits

# --- 7. Re-register Credential Provider framework ---
Write-Host "Re-registering Credential Provider framework..."
regsvr32 /s credprovhost.dll
regsvr32 /s credui.dll

Write-Host "Service reset complete. Reboot required." -ForegroundColor Green
