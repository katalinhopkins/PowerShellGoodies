<#
    EnahncedInstalledProgramsList
    Generates a CSV file containing:
        - Win32 installed programs (registry)
        - Windows Store apps (AppX)
    Includes enhancements:
        - Installed size (MB + KB)
        - Install source
        - Registry key path
        - AppX permissions
        - Normalized schema
#>

$OutputFile = "$env:USERPROFILE\InstalledProgramsAndApps.csv"
Write-Host "Starting inventory collection..." -ForegroundColor Cyan

# -----------------------------
# Helper: Convert bytes to MB/KB
# -----------------------------
function Convert-Size
{
    param([long]$Bytes)

    if ($Bytes -le 0)
    {
        return "0 MB 0 KB"
    }

    $mb = [math]::Floor($Bytes / 1MB)
    $kb = [math]::Floor(($Bytes % 1MB) / 1KB)

    return "$mb MB $kb KB"
} #end Convert-Size


# -----------------------------
# Collect Win32 Programs
# -----------------------------
Write-Host "Collecting Win32 programs..." -ForegroundColor Yellow

$win32 = @()
$registryPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
)

foreach ($path in $registryPaths)
{
    Get-ChildItem $path -ErrorAction SilentlyContinue | ForEach-Object {

        $props = Get-ItemProperty $_.PsPath -ErrorAction SilentlyContinue

        $sizeBytes = 0
        if ($props.EstimatedSize)
        {
            # EstimatedSize is in KB
            $sizeBytes = $props.EstimatedSize * 1KB
        }

        $win32 += [PSCustomObject]@{
            Type             = "Win32"
            Name             = $props.DisplayName
            Version          = $props.DisplayVersion
            Publisher        = $props.Publisher
            InstallDate      = $props.InstallDate
            InstallSource    = $props.InstallSource
            RegistryKeyPath  = $_.PsPath
            Size             = Convert-Size $sizeBytes
            UninstallString  = $props.UninstallString
            PackageFullName  = ""
            InstallLocation  = ""
            Permissions      = ""
        }
    }
} #end foreach Win32


# -----------------------------
# Collect Windows Store Apps
# -----------------------------
Write-Host "Collecting Windows Store apps..." -ForegroundColor Yellow

$storeApps = Get-AppxPackage | ForEach-Object {

    # Try to get permissions (AppX manifest)
    $perm = ""
    try
    {
        $manifestPath = Join-Path $_.InstallLocation "AppxManifest.xml"
        if (Test-Path $manifestPath)
        {
            $xml = [xml](Get-Content $manifestPath)
            $perm = ($xml.Package.Capabilities.Capability.Name) -join "; "
        }
    }
    catch
    {
        $perm = ""
    }

    [PSCustomObject]@{
        Type             = "StoreApp"
        Name             = $_.Name
        Version          = $_.Version
        Publisher        = $_.Publisher
        InstallDate      = ""
        InstallSource    = ""
        RegistryKeyPath  = ""
        Size             = ""
        UninstallString  = ""
        PackageFullName  = $_.PackageFullName
        InstallLocation  = $_.InstallLocation
        Permissions      = $perm
    }
} #end foreach StoreApps


# -----------------------------
# Combine + Export
# -----------------------------
Write-Host "Combining results..." -ForegroundColor Yellow

$combined = $win32 + $storeApps

Write-Host "Exporting to CSV: $OutputFile" -ForegroundColor Green
$combined | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8

Write-Host "Inventory complete." -ForegroundColor Cyan
