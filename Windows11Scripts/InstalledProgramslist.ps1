<#
    Installed ProgramsList
    InstalledProgramslist
.ps1
    Generates a tab-delimited file containing:
        - Win32 installed programs (from registry)
        - Windows Store apps (AppX packages)
    Output file: InstalledProgramsAndApps.txt
#>

#$OutputFile = "$env:USERPROFILE\InstalledProgramsAndApps.txt"
$OutputFile = "\\DS224\LGGram16\2026-10-04\InstalledProgramsAndApps.txt"


# Collect Win32 programs from registry
$win32 = @()

$registryPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

foreach ($path in $registryPaths) {
    $win32 += Get-ItemProperty $path -ErrorAction SilentlyContinue |
        Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, UninstallString
}

# Collect Windows Store apps
$storeApps = Get-AppxPackage |
    Select-Object Name, PackageFullName, Publisher, InstallLocation, Version

# Build tab-delimited output
$lines = @()

# Win32 header
$lines += "Type`tName`tVersion`tPublisher`tInstallDate`tUninstallString"

foreach ($app in $win32) {
    $lines += "Win32`t$($app.DisplayName)`t$($app.DisplayVersion)`t$($app.Publisher)`t$($app.InstallDate)`t$($app.UninstallString)"
}

# Store apps header
$lines += "`nType`tName`tVersion`tPublisher`tInstallLocation`tPackageFullName"

foreach ($app in $storeApps) {
    $lines += "StoreApp`t$($app.Name)`t$($app.Version)`t$($app.Publisher)`t$($app.InstallLocation)`t$($app.PackageFullName)"
}

# Write to file
$lines | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "Tab-delimited file created at: $OutputFile"
