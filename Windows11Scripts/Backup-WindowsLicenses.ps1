#requires -Version 5.1
#requires -RunAsAdministrator
<#
.SYNOPSIS
  Backs up Windows activation information, installed-software inventory,
  common license/activation artifacts, and application-related registry hives.

.NOTES
  Run in Windows PowerShell 5.1 as Administrator.
  The output can contain product keys and other sensitive information.
  Copying a license file does not guarantee that software can be reactivated.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Continue'
$Backup = "\\DS224\LGGram16\2026-10-04\LicenseBackup"
$Computer = $env:COMPUTERNAME
$RunStamp = Get-Date -Format 'yyyy-MM-dd_HHmmss'
$RunRoot = Join-Path $Backup ("{0}_{1}" -f $Computer, $RunStamp)
$InventoryDir = Join-Path $RunRoot 'Inventory'
$ActivationDir = Join-Path $RunRoot 'WindowsActivation'
$LicenseDir = Join-Path $RunRoot 'LicenseArtifacts'
$RegistryDir = Join-Path $RunRoot 'Registry'
$LogDir = Join-Path $RunRoot 'Logs'

function Write-Step {
    param([string]$Message)
    Write-Host ("[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'), $Message) -ForegroundColor Cyan
}

function New-SafeDirectory {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Convert-LicenseStatus {
    param([int]$Status)
    switch ($Status) {
        0 { 'Unlicensed' }
        1 { 'Licensed' }
        2 { 'OOBGrace' }
        3 { 'OOTGrace' }
        4 { 'NonGenuineGrace' }
        5 { 'Notification' }
        6 { 'ExtendedGrace' }
        default { "Unknown ($Status)" }
    }
}

function Copy-LicenseArtifact {
    param(
        [Parameter(Mandatory)][System.IO.FileInfo]$File,
        [Parameter(Mandatory)][string]$SourceRoot,
        [Parameter(Mandatory)][string]$RootLabel
    )
    try {
        $rootFull = [IO.Path]::GetFullPath($SourceRoot).TrimEnd([char]'\')
        $fileFull = [IO.Path]::GetFullPath($File.FullName)
        if (-not $fileFull.StartsWith($rootFull, [StringComparison]::OrdinalIgnoreCase)) { return }
        $relative = $fileFull.Substring($rootFull.Length).TrimStart([char]'\')
        $destination = Join-Path (Join-Path $LicenseDir $RootLabel) $relative
        New-SafeDirectory -Path (Split-Path -Parent $destination)
        Copy-Item -LiteralPath $fileFull -Destination $destination -Force -ErrorAction Stop
        [pscustomobject]@{
            Source       = $fileFull
            Destination  = $destination
            Length       = $File.Length
            LastWriteTime = $File.LastWriteTime
            SHA256       = (Get-FileHash -LiteralPath $destination -Algorithm SHA256 -ErrorAction SilentlyContinue).Hash
            Status       = 'Copied'
        }
    }
    catch {
        [pscustomobject]@{
            Source       = $File.FullName
            Destination  = $null
            Length       = $File.Length
            LastWriteTime = $File.LastWriteTime
            SHA256       = $null
            Status       = "Failed: $($_.Exception.Message)"
        }
    }
}

# Confirm the NAS share is reachable before doing any work.
if (-not (Test-Path -LiteralPath $Backup)) {
    throw "Backup destination is unavailable: $Backup. Connect to the NAS/share and verify permissions."
}

@($RunRoot, $InventoryDir, $ActivationDir, $LicenseDir, $RegistryDir, $LogDir) |
    ForEach-Object { New-SafeDirectory -Path $_ }

Start-Transcript -Path (Join-Path $LogDir 'Backup-Transcript.txt') -Force | Out-Null
$started = Get-Date

try {
    Write-Step 'Saving computer and operating-system information'
    Get-ComputerInfo -ErrorAction SilentlyContinue |
        Export-Clixml -Path (Join-Path $InventoryDir 'ComputerInfo.xml')
    Get-CimInstance Win32_OperatingSystem |
        Select-Object Caption, Version, BuildNumber, OSArchitecture, SerialNumber, InstallDate, LastBootUpTime |
        Export-Csv -Path (Join-Path $InventoryDir 'OperatingSystem.csv') -NoTypeInformation -Encoding UTF8

    Write-Step 'Saving Windows activation and licensing information'
    $products = Get-CimInstance -ClassName SoftwareLicensingProduct -ErrorAction SilentlyContinue |
        Where-Object { $_.PartialProductKey } |
        Select-Object Name, Description, ApplicationID, ID, LicenseStatus,
            @{Name='LicenseStatusText';Expression={ Convert-LicenseStatus $_.LicenseStatus }},
            LicenseStatusReason, PartialProductKey, ProductKeyID, LicenseFamily,
            GracePeriodRemaining, EvaluationEndDate, ProductKeyChannel, GenuineStatus
    $products | Export-Csv -Path (Join-Path $ActivationDir 'SoftwareLicensingProducts.csv') -NoTypeInformation -Encoding UTF8

    Get-CimInstance -ClassName SoftwareLicensingService -ErrorAction SilentlyContinue |
        Select-Object Version, KeyManagementServiceMachine, KeyManagementServicePort,
            RemainingWindowsReArmCount, RemainingSkuReArmCount, OA3xOriginalProductKey |
        Export-Csv -Path (Join-Path $ActivationDir 'SoftwareLicensingService.csv') -NoTypeInformation -Encoding UTF8

    & cscript.exe //nologo "$env:windir\System32\slmgr.vbs" /dli 2>&1 |
        Out-File -FilePath (Join-Path $ActivationDir 'slmgr-dli.txt') -Encoding UTF8
    & cscript.exe //nologo "$env:windir\System32\slmgr.vbs" /dlv 2>&1 |
        Out-File -FilePath (Join-Path $ActivationDir 'slmgr-dlv.txt') -Encoding UTF8
    & cscript.exe //nologo "$env:windir\System32\slmgr.vbs" /xpr 2>&1 |
        Out-File -FilePath (Join-Path $ActivationDir 'slmgr-xpr.txt') -Encoding UTF8

    Write-Step 'Inventorying installed desktop software'
    $uninstallPaths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    Get-ItemProperty -Path $uninstallPaths -ErrorAction SilentlyContinue |
        Where-Object DisplayName |
        Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, InstallLocation,
            InstallSource, UninstallString, QuietUninstallString, PSPath |
        Sort-Object DisplayName, DisplayVersion, Publisher -Unique |
        Export-Csv -Path (Join-Path $InventoryDir 'InstalledDesktopSoftware.csv') -NoTypeInformation -Encoding UTF8

    Write-Step 'Inventorying Microsoft Store/AppX packages'
    Get-AppxPackage -AllUsers -ErrorAction SilentlyContinue |
        Select-Object Name, PackageFullName, PackageFamilyName, Publisher, Version, InstallLocation, SignatureKind |
        Sort-Object Name, Version -Unique |
        Export-Csv -Path (Join-Path $InventoryDir 'AppxPackages.csv') -NoTypeInformation -Encoding UTF8

    Write-Step 'Exporting application-related registry hives'
    $registryExports = @(
        @{ Key = 'HKLM\SOFTWARE'; File = 'HKLM-SOFTWARE.reg' },
        @{ Key = 'HKCU\SOFTWARE'; File = 'HKCU-SOFTWARE.reg' }
    )
    foreach ($item in $registryExports) {
        $outFile = Join-Path $RegistryDir $item.File
        & reg.exe export $item.Key $outFile /y 2>&1 |
            Out-File -FilePath (Join-Path $LogDir ($item.File + '.log')) -Encoding UTF8
        if ($LASTEXITCODE -ne 0) { Write-Warning "Registry export failed: $($item.Key)" }
    }

    Write-Step 'Searching common locations for license and activation artifacts'
    $sourceRoots = @(
        @{ Path = $env:ProgramData; Label = 'ProgramData' },
        @{ Path = $env:LOCALAPPDATA; Label = 'LocalAppData' },
        @{ Path = $env:APPDATA; Label = 'RoamingAppData' }
    ) | Where-Object { $_.Path -and (Test-Path -LiteralPath $_.Path) }

    # Conservative matching: explicit license-like extensions or license/activation terms
    # in the file name. This avoids copying all of ProgramData/AppData.
    $licenseExtensions = @('.lic', '.license', '.key', '.cert', '.crt', '.pem')
    $nameRegex = '(?i)(license|licence|activation|activate|entitlement|serial|registration|product.?key)'
    $manifest = [System.Collections.Generic.List[object]]::new()

    foreach ($root in $sourceRoots) {
        Write-Step "Scanning $($root.Path)"
        Get-ChildItem -LiteralPath $root.Path -File -Recurse -Force -ErrorAction SilentlyContinue |
            Where-Object {
                ($licenseExtensions -contains $_.Extension.ToLowerInvariant()) -or
                ($_.BaseName -match $nameRegex)
            } |
            ForEach-Object {
                $entry = Copy-LicenseArtifact -File $_ -SourceRoot $root.Path -RootLabel $root.Label
                if ($entry) { $manifest.Add($entry) }
            }
    }

    $manifest |
        Sort-Object Source -Unique |
        Export-Csv -Path (Join-Path $LicenseDir 'LicenseArtifacts-Manifest.csv') -NoTypeInformation -Encoding UTF8

    Write-Step 'Creating summary'
    $summary = [pscustomobject]@{
        ComputerName = $Computer
        Started      = $started
        Completed    = Get-Date
        Destination  = $RunRoot
        LicensedProductsFound = @($products).Count
        LicenseArtifactsFound = @($manifest).Count
        ArtifactCopyFailures  = @($manifest | Where-Object Status -Like 'Failed:*').Count
    }
    $summary | ConvertTo-Json -Depth 3 |
        Out-File -FilePath (Join-Path $RunRoot 'Backup-Summary.json') -Encoding UTF8

    Write-Host "Backup completed: $RunRoot" -ForegroundColor Green
}
finally {
    Stop-Transcript | Out-Null
}
